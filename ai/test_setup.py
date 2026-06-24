"""Quick setup checker. Run: python test_setup.py"""
from __future__ import annotations

import sys


def check_env() -> bool:
    print("1) Checking .env ...")
    from config import (
        AZURE_OPENAI_API_KEY,
        AZURE_OPENAI_BASE_URL,
        AZURE_OPENAI_DEPLOYMENT_CHAT,
        AZURE_OPENAI_DEPLOYMENT_EMBEDDINGS,
        AZURE_OPENAI_ENDPOINT,
        AZURE_OPENAI_ENDPOINT_RAW,
        AZURE_OPENAI_USE_V1,
        DB_NAME,
        DB_SCHEMA,
        DB_SERVER,
        LLM_PROVIDER,
        OPENAI_API_KEY,
    )

    ok = True
    print(f"   [i] LLM_PROVIDER={LLM_PROVIDER}")

    if LLM_PROVIDER == "azure":
        if not AZURE_OPENAI_API_KEY or AZURE_OPENAI_API_KEY.startswith("PASTE"):
            print("   [X] AZURE_OPENAI_API_KEY is not set in ai/.env")
            ok = False
        else:
            print(f"   [OK] Azure key loaded (starts with {AZURE_OPENAI_API_KEY[:6]}...)")
        if "PASTE" in AZURE_OPENAI_ENDPOINT:
            print("   [X] AZURE_OPENAI_ENDPOINT is not set in ai/.env")
            ok = False
        else:
            print(f"   [i] Endpoint (raw): {AZURE_OPENAI_ENDPOINT_RAW}")
            print(f"   [i] Azure mode: {'v1 (Foundry)' if AZURE_OPENAI_USE_V1 else 'classic'}")
            if AZURE_OPENAI_USE_V1:
                print(f"   [i] Base URL used: {AZURE_OPENAI_BASE_URL}")
            else:
                print(f"   [i] Endpoint used: {AZURE_OPENAI_ENDPOINT}")
        print(f"   [i] Chat deployment:       {AZURE_OPENAI_DEPLOYMENT_CHAT}")
        print(f"   [i] Embeddings deployment: {AZURE_OPENAI_DEPLOYMENT_EMBEDDINGS}")
    else:
        if not OPENAI_API_KEY or OPENAI_API_KEY.startswith("PASTE"):
            print("   [X] OPENAI_API_KEY is not set in ai/.env")
            ok = False
        else:
            print(f"   [OK] OpenAI key loaded (starts with {OPENAI_API_KEY[:7]}...)")

    print(f"   [i] DB_SERVER={DB_SERVER}  DB_NAME={DB_NAME}  DB_SCHEMA={DB_SCHEMA}")
    return ok


def check_db() -> bool:
    print("2) Checking SQL Server connection + semantic views ...")
    try:
        from config import ALLOWED_VIEWS, DB_SCHEMA
        from db import run_query

        cols, rows = run_query(
            f"SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS "
            f"WHERE TABLE_SCHEMA = '{DB_SCHEMA}'"
        )
        found = {r[0].lower() for r in rows}
        print(f"   [OK] Connected. Views in schema '{DB_SCHEMA}': {sorted(found)}")
        missing = [v for v in ALLOWED_VIEWS if v.lower() not in found]
        if missing:
            print(f"   [!] Missing expected views: {missing}")
            print("       (Check the schema name or run: dbt run --select tag:semantic)")
            return False
        return True
    except Exception as exc:
        print(f"   [X] DB connection failed: {exc}")
        return False


def check_llm() -> bool:
    print("3) Checking OpenAI access ...")
    try:
        from text_to_sql import get_chat_model

        model = get_chat_model()
        reply = model.invoke("Reply with the single word: OK")
        print(f"   [OK] LLM responded: {reply.content.strip()[:40]}")
        return True
    except Exception as exc:
        print(f"   [X] OpenAI call failed: {exc}")
        return False


if __name__ == "__main__":
    results = [check_env(), check_db(), check_llm()]
    print("\nSummary:", "ALL GOOD" if all(results) else "FIX THE [X] ITEMS ABOVE")
    sys.exit(0 if all(results) else 1)
