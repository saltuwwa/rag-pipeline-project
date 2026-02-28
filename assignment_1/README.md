# RAG Pipeline для годовых отчётов

RAG-пайплайн (Retrieval-Augmented Generation) для ответов на вопросы по годовым отчётам казахстанских компаний **КТЖ** (АО «НК «ҚТЖ») и **Матен Петролеум** (АО «Матен Петролеум»). Документы содержат таблицы и сложную вёрстку — используется LlamaParse (облачный API) для корректного извлечения таблиц.

---

## Архитектура

```
PDF (ktj.pdf, matnp_2024_rus.pdf)
    │
    ▼ LlamaParse (облачный API) / DocLing (локально, опционально)   (LlamaParse was more accurate and performed better when parsing tables, than Docling)
Markdown → data/ktj_parsed.md, data/matnp_parsed.md
    │
    ▼ Chunking (Naive / Recursive / Layout-Aware)
Chunks
    │
    ▼ SentenceTransformer.encode()
Embeddings (768 dim)
    │
    ├─► Qdrant (векторная БД) / in-memory
    │
    ▼ По запросу:
[Query Rewriting] → Hybrid Search (Vector + BM25, RRF) → Reranker → LLM → Ответ
```

---

## Как это работает

### 1. Парсинг PDF (LlamaParse)

**Инструмент:** LlamaParse (LlamaCloud API)

**Зачем:** Лучше сохраняет структуру таблиц, нет дублей заголовков. DocLing (локальный) доступен как альтернатива.

**Переключение:** `CONFIG["parser"] = "llamaparse"` или `"docling"`.

**Сохранение:** Результат записывается в `data/ktj_parsed.md` и `data/matnp_parsed.md`. Naive RAG кэширует парсинг и эмбеддинги в `data/rag_cache.pkl`.

---

### 2. Чанкинг

| Стратегия   | Описание |
|-------------|----------|
| **Naive**   | Фиксированный размер 1024 токена, overlap 200 (tiktoken cl100k_base). |
| **Recursive** | RecursiveCharacterTextSplitter — разбиение по логическим границам. |
| **Layout-Aware** | Блоки Markdown (заголовки, таблицы) — таблица не разрывается. |

---

### 3. Embeddings

**Модель:** `paraphrase-multilingual-mpnet-base-v2` (Sentence Transformers)

- Поддержка русского и казахского
- 768 dim, косинусное сходство
- Работает на CPU без GPU

---

### 4. Векторная БД (Qdrant)

**Хранение:** Локальная папка `./qdrant_data`.

**Структура:** Коллекция `rag_chunks`, векторы 768 dim, COSINE. В payload — текст чанка (`text`).

---

### 5. Retrieval

| Режим | Описание |
|-------|----------|
| **Dense** | Косинусное сходство эмбеддингов |
| **BM25** | Ключевые слова (точные совпадения, цифры) |
| **Hybrid (RRF)** | Reciprocal Rank Fusion: Dense + BM25, α=0.5 |

---

### 6. Reranker

**Модель:** `BAAI/bge-reranker-v2-m3` (FlagEmbedding)

После Hybrid Search берётся top-10, reranker переранжирует и выбирается top-3. Cross-Encoder точнее оценивает релевантность.

---

### 7. Query Rewriting

LLM переформулирует вопрос, добавляет ключевые термины — улучшает retrieval для коротких запросов.

---

## Зависимости

```
docling llama-parse sentence-transformers langchain langchain-openai 
langchain-text-splitters rank-bm25 FlagEmbedding python-dotenv 
tiktoken qdrant-client nest_asyncio
```

Установка: ячейка в ноутбуке или `pip install -r requirements.txt`.

---

## Подготовка

1. Создать папку `data/` и положить:
   - `ktj.pdf` — отчёт КТЖ
   - `matnp_2024_rus.pdf` — отчёт Матен Петролеум

2. Создать `.env` в `assignment_1/`:
   ```
   OPENAI_API_KEY=sk-...
   LLAMAPARSE_API_KEY=llx-...
   ```

3. Установить зависимости.

---

## Запуск

1. Открыть `assignment_1_rag_pipeline.ipynb` в Jupyter.
2. Выполнить ячейки по порядку: Config → Imports → Функции → Naive RAG → Qdrant → Advanced RAG.
3. **LlamaParse:** парсинг ~1–2 мин (облако). **DocLing:** ~6–8 мин (локально). Кэш в `rag_cache.pkl` — повторные запуски без парсинга.
4. Advanced RAG: `build_advanced_rag()` — hybrid search, reranker, query rewriting.

---

## Структура проекта

```
assignment_1/
├── data/
│   ├── ktj.pdf
│   ├── matnp_2024_rus.pdf
│   ├── ktj_parsed.md           # результат парсинга (используется пайплайном)
│   ├── matnp_parsed.md
│   ├── ktj_parsed_docling.md    # DocLing — для наглядного сравнения
│   ├── matnp_parsed_docling.md
│   ├── ktj_parsed_llamaparse.md  # LlamaParse — для наглядного сравнения
│   ├── matnp_parsed_llamaparse.md
│   └── rag_cache.pkl           # кэш (парсинг + эмбеддинги)
├── qdrant_data/                # векторная БД
├── assignment_1_rag_pipeline.ipynb
├── REFERENCE_LINKS.md
└── README.md
```

**Сравнение парсеров:** файлы `*_parsed_docling.md` и `*_parsed_llamaparse.md` создаются ячейкой «0. Сравнение парсеров» — можно открыть их рядом и сравнить качество таблиц.

---

## Типичные проблемы

| Проблема | Решение |
|----------|---------|
| Qdrant «already accessed» | Перезапустить ядро или изменить путь на `qdrant_data_2` в коде |
| Долгий парсинг | LlamaParse ~1–2 мин, DocLing ~6–8 мин. Кэш в `rag_cache.pkl` |
| Смена парсера | Поменять `CONFIG["parser"]`, удалить `rag_cache.pkl`, перезапустить Naive RAG |
| ValueError: prefix not accepted | Используется mpnet (без префиксов) |
| Reranker на CPU | `use_fp16=False` в FlagReranker (автоматически, если нет CUDA) |
