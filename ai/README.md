# Massar AI Module

LangChain-based RAG + governed text-to-SQL over dbt semantic KPI views.

## Architecture

```
Streamlit UI
    -> agent.py
        -> retriever.py (LangChain + Chroma RAG)
        -> text_to_sql.py (LangChain LLM)
        -> sql_guard.py (whitelist semantic.vw_*)
        -> db.py (read-only SQL Server)
```

Semantic views are defined in:

`massar_analytics/models/gold/semantic/`

## Setup

```powershell
cd E:\GP_SmartTransportation\ai
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
```

Edit `.env`:
- set `OPENAI_API_KEY` (or Azure settings)
- confirm `DB_SERVER` and `DB_NAME`

Build embeddings:

```powershell
python embed_pipeline.py
```

Run the chat UI:

```powershell
streamlit run streamlit_app.py
```

## Allowed semantic views

- `semantic.vw_ride_kpis_daily`
- `semantic.vw_cancellation_summary`
- `semantic.vw_zone_demand`
- `semantic.vw_ride_sla`
- `semantic.vw_rating_summary`

## Recommended SQL permission

Grant the AI login SELECT on schema `semantic` only.

## Demo flow for viva

1. Explain a KPI (RAG only)
2. Ask for top zones or monthly ride totals (text-to-SQL)
3. Show generated SQL + guardrails
4. Explain that Power BI uses mart tables while AI uses semantic views

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `Chroma store not found` | Run `python embed_pipeline.py` |
| ODBC error | Install ODBC Driver 18 for SQL Server |
| SQL guard blocked query | Rephrase question; check allowed views |
| OpenAI auth error | Verify `.env` API key |
