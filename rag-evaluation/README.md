# Эксперименты и оценка RAG-пайплайна

Оценка влияния гиперпараметров на качество RAG-системы для годовых отчётов КТЖ и Матен Петролеум через RAGAS.



## Результаты экспериментов

| # | Эксперимент | faithfulness | answer_relevancy | context_recall | context_precision |
|---|-------------|--------------|------------------|----------------|-------------------|
| 0 | Baseline    | 0.827        | 0.721            | 0.867          | 0.676             |
| 1 | Chunk Size 512 | 0.900     | 0.740            | 0.900          | 0.797             |
| 2 | Chunk Size 2048 | 0.837    | 0.533            | 0.600          | 0.451             |
| 3 | Top-K 3 | 0.908            | 0.747            | 0.833          | 0.728             |
| 4 | Top-K 10 | 0.916           | 0.750            | 0.867          | 0.738             |
| 5 | Alpha 0 (BM25) | 0.824     | 0.722            | 0.900          | 0.699             |
| 6 | Alpha 1 (Vector) | 0.857   | 0.769            | 0.800          | 0.680             |
| 7 | Reranking Вкл | 0.849      | 0.751            | 0.833          | 0.761             |
| 8 | Chunking: Naive | 0.880    | 0.658            | 0.767          | 0.690             |
| 9 | Chunking: Layout-Aware| 0.892| 0.648          | 0.767          |0.681              |

**Выводы:**
- **Лучшая конфигурация:** Chunk 512 + Top-K 10
- **Наибольшее влияние:** Chunk Size — при 2048 context_recall падает до 0.60
- **Наименьшее влияние:** Alpha
- **Reranking:** прирост context_precision (~0.76 vs 0.68)

---

## Структура ноутбука

- **Разделы 1–4:** конфигурация, импорты, функции пайплайна, RAGAS
- **Раздел 5:** EXPERIMENTS, модели, запуск экспериментов (~119 мин)
- **Раздел 6:** таблица, лучший/худший по метрикам, диаграммы — **захардкожены**, работают без перезапуска
- **Раздел 7:** анализ метрик RAGAS, поэкспериментальный анализ, итоговый вывод

---

## Модели под капотом

### 1. Эмбеддинги: paraphrase-multilingual-mpnet-base-v2
- База: XLM-RoBERTa. Выход: 768 dim, mean pooling. Dense retrieval по косинусному сходству.

### 2. LLM: GPT-4o-mini
Генерация ответов и RAGAS. Temperature=0.

### 3. Reranker: BAAI/bge-reranker-v2-m3
oderCross-enc — пара [query, passage] → score. Точнее bi-encoder, но дороже.

### 4. BM25 (rank_bm25)
Лексический поиск. В гибриде комбинируется с dense через RRF (alpha).

---

## RAGAS: метрики

| Метрика | Что измеряет | Под капотом |
|---------|--------------|-------------|
| **Faithfulness** | Галлюцинации | Claims из ответа → проверка по контексту |
| **Answer Relevancy** | Релевантность ответа | Генерация вопросов из ответа → сравнение с исходным |
| **Context Recall** | Полнота retrieval | Ground truth vs контекст |
| **Context Precision** | Точность retrieval | Релевантные чанки выше нерелевантных |

---

## Трудности и время

- **~119 мин** — полный прогон 10 экспериментов
- **Таймауты RAGAS** → NaN для части сэмплов
- **«LLM returned 1 generations instead of 3»** — ожидаемо для answer_relevancy
- **Pydantic v1** — патч для RAGAS
- **OpenAIEmbeddings** — вместо фабрик RAGAS (embed_query/embed_documents)

---

## Запуск

1. Выполните `rag-pipeline/rag_pipeline.ipynb` → `data/ktj_parsed.md`, `data/matnp_parsed.md`
2. `golden_dataset.json` — в `rag-evaluation/`
3. `.env` с `OPENAI_API_KEY` (в корне или `rag-evaluation/`)
4. `pip install ragas datasets sentence-transformers langchain langchain-openai rank-bm25 FlagEmbedding python-dotenv tiktoken`
5. `rag_evaluation.ipynb` — секция 6 (таблица, диаграммы) работает автономно, перезапуск экспериментов не нужен

## Зависимости

```
ragas datasets sentence-transformers langchain langchain-openai
rank-bm25 FlagEmbedding python-dotenv tiktoken
```
