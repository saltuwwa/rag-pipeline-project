# Справочные материалы RAG Pipeline Project

Ссылки из ТЗ (rag_проект_4модуль.pdf) для быстрого доступа при отладке.

## Парсинг PDF (Visual Layout)

| Инструмент | URL | Примечание |
|------------|-----|------------|
| **DocLing** | https://github.com/docling-project/docling | Требует Developer Mode на Windows (symlinks) |
| **DocLing docs** | https://ds4sd.github.io/docling/ | Официальная документация |
| **Unstructured** | https://docs.unstructured.io/welcome | Работает на Windows без symlinks |
| **LlamaParse** | https://docs.cloud.llamaindex.ai/llamaparse/getting_started | Альтернатива (облачный API) |

## Оркестрация и RAG

| Ресурс | URL |
|--------|-----|
| **LangChain** | https://python.langchain.com/docs/introduction/ |
| **LlamaIndex** | https://docs.llamaindex.ai/en/stable/ |

## Векторные БД

| Ресурс | URL |
|--------|-----|
| **ChromaDB** | https://docs.trychroma.com/ |
| **Qdrant** | https://qdrant.tech/documentation/ |

## Embeddings и Reranking

| Ресурс | URL |
|--------|-----|
| **Sentence Transformers** | https://www.sbert.net/ |
| **FlagEmbedding (BGE)** | https://github.com/FlagOpen/FlagEmbedding |
| **MTEB Leaderboard** | https://huggingface.co/spaces/mteb/leaderboard |

## Оценка RAG

| Ресурс | URL |
|--------|-----|
| **RAGAS** | https://docs.ragas.io/en/stable/ |

## Бонус: GraphRAG

| Ресурс | URL |
|--------|-----|
| **Neo4j** | https://neo4j.com/docs/ |

---

## Quick Install (из ТЗ)

```bash
pip install langchain langchain-community langchain-openai langchain-text-splitters chromadb qdrant-client ragas sentence-transformers unstructured FlagEmbedding
```

> **Примечание:** `docling` может вызывать WinError 1314 на Windows — используйте `unstructured[pdf]` вместо него.

Для бонусного задания (GraphRAG):
```bash
pip install neo4j
docker run -d --name neo4j -p 7474:7474 -p 7687:7687 -e NEO4J_AUTH=neo4j/password neo4j:latest
```

## Рекомендуемые модели (из ТЗ)

| Категория | Модель |
|-----------|--------|
| Embedding | intfloat/multilingual-e5-large |
| Reranker | BAAI/bge-reranker-v2-m3 |
| LLM | GPT-4o-mini (API) |

## Типичные проблемы и решения

| Проблема | Решение |
|----------|---------|
| WinError 1314 (symlinks) на Windows | `parse_backend="unstructured"` или включить Developer Mode |
| langchain.text_splitter не найден | `pip install langchain-text-splitters` |
| ValueError: prefix not accepted | Используется paraphrase-multilingual-mpnet (по умолчанию) |
| Долгая загрузка | Нормально: парсинг PDF + загрузка embedding-модели + создание эмбеддингов |
