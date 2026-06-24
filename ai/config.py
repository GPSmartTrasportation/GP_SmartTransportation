from __future__ import annotations

import os
from pathlib import Path

from dotenv import load_dotenv

AI_ROOT = Path(__file__).resolve().parent
DOCUMENTS_DIR = AI_ROOT / "rag" / "documents"
CHROMA_DIR = AI_ROOT / "rag" / "chroma_db"
ASSETS_DIR = AI_ROOT / "assets"
LOGO_PATH = ASSETS_DIR / "massar_logo.png"

BRAND_PRIMARY = "#1A2D42"
BRAND_SECONDARY = "#59A472"
BRAND_BACKGROUND = "#F5F7FA"
BRAND_SURFACE = "#FFFFFF"

load_dotenv(AI_ROOT / ".env")

LLM_PROVIDER = os.getenv("LLM_PROVIDER", "openai").lower()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
OPENAI_EMBEDDING_MODEL = os.getenv("OPENAI_EMBEDDING_MODEL", "text-embedding-3-small")

AZURE_OPENAI_API_KEY = os.getenv("AZURE_OPENAI_API_KEY", "")
AZURE_OPENAI_ENDPOINT_RAW = os.getenv("AZURE_OPENAI_ENDPOINT", "")
AZURE_OPENAI_API_VERSION = os.getenv("AZURE_OPENAI_API_VERSION", "2024-12-01-preview")
AZURE_OPENAI_DEPLOYMENT_CHAT = os.getenv("AZURE_OPENAI_DEPLOYMENT_CHAT", "gpt-4o-mini")
AZURE_OPENAI_DEPLOYMENT_EMBEDDINGS = os.getenv(
    "AZURE_OPENAI_DEPLOYMENT_EMBEDDINGS", "text-embedding-3-small"
)


def _normalize_azure_endpoint(endpoint: str) -> str:
    """Classic Azure OpenAI base URL (no /openai/v1 suffix)."""
    value = endpoint.strip().rstrip("/")
    lower = value.lower()
    if lower.endswith("/openai/v1"):
        value = value[: -len("/openai/v1")]
    elif lower.endswith("/openai"):
        value = value[: -len("/openai")]
    return value.rstrip("/") + "/"


def _azure_v1_base_url(endpoint: str) -> str:
    """Unified Azure OpenAI v1 base URL used by AI Foundry."""
    value = endpoint.strip().rstrip("/")
    if value.lower().endswith("/openai/v1"):
        return value
    return f"{value}/openai/v1"


_use_v1_env = os.getenv("AZURE_OPENAI_USE_V1", "").lower() in {"1", "true", "yes"}
AZURE_OPENAI_USE_V1 = _use_v1_env or "/openai/v1" in AZURE_OPENAI_ENDPOINT_RAW.lower()
AZURE_OPENAI_ENDPOINT = _normalize_azure_endpoint(AZURE_OPENAI_ENDPOINT_RAW)
AZURE_OPENAI_BASE_URL = _azure_v1_base_url(AZURE_OPENAI_ENDPOINT_RAW)

DB_SERVER = os.getenv("DB_SERVER", "localhost")
DB_NAME = os.getenv("DB_NAME", "GP_SmartTransportDWH")
DB_SCHEMA = os.getenv("DB_SCHEMA", "semantic")
DB_DRIVER = os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server")
DB_TRUSTED_CONNECTION = os.getenv("DB_TRUSTED_CONNECTION", "yes").lower() in {
    "1",
    "true",
    "yes",
}
DB_UID = os.getenv("DB_UID", "")
DB_PWD = os.getenv("DB_PWD", "")

MAX_QUERY_ROWS = int(os.getenv("MAX_QUERY_ROWS", "500"))
SQL_QUERY_TIMEOUT_SECONDS = int(os.getenv("SQL_QUERY_TIMEOUT_SECONDS", "30"))

POWERBI_REPORT_URL = os.getenv("POWERBI_REPORT_URL", "")

ALLOWED_VIEWS: tuple[str, ...] = (
    "vw_ride_kpis_daily",
    "vw_cancellation_summary",
    "vw_zone_demand",
    "vw_ride_sla",
    "vw_rating_summary",
)

FORBIDDEN_SQL_KEYWORDS: tuple[str, ...] = (
    "INSERT",
    "UPDATE",
    "DELETE",
    "MERGE",
    "DROP",
    "ALTER",
    "CREATE",
    "TRUNCATE",
    "EXEC",
    "EXECUTE",
    "GRANT",
    "REVOKE",
    "INTO",
    "OPENROWSET",
    "OPENDATASOURCE",
    "xp_",
)
