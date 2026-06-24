from __future__ import annotations

import pyodbc

from config import (
    DB_DRIVER,
    DB_NAME,
    DB_PWD,
    DB_SERVER,
    DB_TRUSTED_CONNECTION,
    DB_UID,
    SQL_QUERY_TIMEOUT_SECONDS,
)


def build_connection_string() -> str:
    parts = [
        f"DRIVER={{{DB_DRIVER}}}",
        f"SERVER={DB_SERVER}",
        f"DATABASE={DB_NAME}",
        "TrustServerCertificate=yes",
    ]

    if DB_TRUSTED_CONNECTION:
        parts.append("Trusted_Connection=yes")
    else:
        parts.append(f"UID={DB_UID}")
        parts.append(f"PWD={DB_PWD}")

    return ";".join(parts)


def run_query(sql: str) -> tuple[list[str], list[tuple]]:
    connection_string = build_connection_string()
    with pyodbc.connect(connection_string, timeout=SQL_QUERY_TIMEOUT_SECONDS) as conn:
        conn.timeout = SQL_QUERY_TIMEOUT_SECONDS
        cursor = conn.cursor()
        cursor.execute(sql)
        columns = [column[0] for column in cursor.description]
        rows = cursor.fetchall()
        return columns, [tuple(row) for row in rows]
