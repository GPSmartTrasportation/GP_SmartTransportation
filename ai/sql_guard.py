from __future__ import annotations

import re

from config import ALLOWED_VIEWS, DB_SCHEMA, FORBIDDEN_SQL_KEYWORDS, MAX_QUERY_ROWS


class SqlGuardError(ValueError):
    pass


def _normalize(sql: str) -> str:
    cleaned = sql.strip().rstrip(";")
    cleaned = re.sub(r"--.*$", "", cleaned, flags=re.MULTILINE)
    cleaned = re.sub(r"/\*.*?\*/", "", cleaned, flags=re.DOTALL)
    return cleaned.strip()


def _qualified_view(name: str) -> str:
    return f"{DB_SCHEMA}.{name}"


def allowed_relations() -> list[str]:
    return [_qualified_view(view) for view in ALLOWED_VIEWS]


def validate_sql(sql: str) -> str:
    if not sql or not sql.strip():
        raise SqlGuardError("Generated SQL is empty.")

    normalized = _normalize(sql)
    upper = normalized.upper()

    if not upper.startswith("SELECT"):
        raise SqlGuardError("Only SELECT queries are allowed.")

    if ";" in normalized:
        raise SqlGuardError("Multiple SQL statements are not allowed.")

    for keyword in FORBIDDEN_SQL_KEYWORDS:
        if re.search(rf"\b{keyword}\b", upper):
            raise SqlGuardError(f"Forbidden SQL keyword detected: {keyword}")

    referenced = set(re.findall(r"\b(?:\w+\.)?(vw_[a-z0-9_]+)\b", normalized, flags=re.IGNORECASE))
    if not referenced:
        raise SqlGuardError(
            "Query must reference at least one allowed semantic view: "
            + ", ".join(ALLOWED_VIEWS)
        )

    allowed_names = {view.lower() for view in ALLOWED_VIEWS}
    for relation in referenced:
        view_name = relation.split(".")[-1].lower()
        if view_name not in allowed_names:
            raise SqlGuardError(f"View not allowed: {view_name}")

    if "TOP " not in upper:
        normalized = re.sub(
            r"(?i)^SELECT\s+",
            f"SELECT TOP {MAX_QUERY_ROWS} ",
            normalized,
            count=1,
        )

    return normalized
