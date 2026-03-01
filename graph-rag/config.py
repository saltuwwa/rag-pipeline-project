"""Конфигурация GraphRAG: пути к данным, Neo4j."""
from pathlib import Path
import os
from dotenv import load_dotenv

# .env — из graph-rag/, assignment_1/, корня
for p in [Path(__file__).parent, Path(__file__).parent.parent / "assignment_1", Path(__file__).parent.parent]:
    env_path = p / ".env"
    if env_path.exists():
        load_dotenv(env_path)
        break

# Путь к распарсенным отчётам (assignment_1/data)
PROJECT_ROOT = Path(__file__).parent.parent
DATA_DIR = PROJECT_ROOT / "assignment_1" / "data"
KTJ_PATH = DATA_DIR / "ktj_parsed.md"
MATNP_PATH = DATA_DIR / "matnp_parsed.md"

# Neo4j
NEO4J_URI = os.getenv("NEO4J_URI", "bolt://localhost:7687")
NEO4J_USER = os.getenv("NEO4J_USER", "neo4j")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD", "password")

# OpenAI (для извлечения сущностей)
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
