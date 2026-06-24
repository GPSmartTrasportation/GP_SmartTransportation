# Massar AI Module

LangChain-based **agentic analytics assistant**: RAG + governed text-to-SQL over dbt **semantic** KPI views (`schema: semantic`).

Power BI uses **mart tables**; the AI chatbot uses **semantic views only** (`vw_*`).

---

## Architecture

```
Streamlit UI (streamlit_app.py)
    └── agent.py
            ├── memory.py          (conversation follow-ups)
            ├── retriever.py       (LangChain + Chroma RAG)
            ├── kpi_queries.py     (Power BI–aligned KPI SQL)
            ├── text_to_sql.py     (LangChain LLM)
            ├── insights.py        (agentic insights)
            ├── sql_guard.py       (SELECT-only whitelist)
            └── db.py              (SQL Server)
```

Semantic views live in:

`massar_analytics/models/gold/semantic/`

---

## Prerequisites

- Python 3.10+
- SQL Server DW running (`GP_SmartTransportDWH`)
- Semantic views built:

```powershell
cd massar_analytics
dbt run --select tag:semantic
dbt test --select tag:semantic
```

- Azure OpenAI (or OpenAI) API access
- ODBC Driver 18 for SQL Server

---

## Setup (team)

```powershell
cd ai
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
```

Edit `.env`:

| Variable | Description |
|----------|-------------|
| `LLM_PROVIDER` | `azure` or `openai` |
| `AZURE_OPENAI_API_KEY` | From Azure AI Foundry |
| `AZURE_OPENAI_ENDPOINT` | **Azure OpenAI endpoint** (not Project endpoint) |
| `AZURE_OPENAI_DEPLOYMENT_CHAT` | e.g. `gpt-4.1-mini` |
| `AZURE_OPENAI_DEPLOYMENT_EMBEDDINGS` | e.g. `text-embedding-3-small` |
| `DB_SERVER` | `localhost` |
| `DB_NAME` | `GP_SmartTransportDWH` |
| `DB_SCHEMA` | `semantic` |
| `POWERBI_REPORT_URL` | Optional — published Power BI link |

Verify setup:

```powershell
python test_setup.py
```

Build RAG embeddings (once, or when docs change):

```powershell
python embed_pipeline.py
```

Run the app:

```powershell
streamlit run streamlit_app.py
```

Or double-click `run_app.bat` (Windows).

Open: **http://localhost:8501**

---

## Allowed semantic views

| View | Purpose |
|------|---------|
| `semantic.vw_ride_kpis_daily` | Daily rides, revenue, completion/cancellation |
| `semantic.vw_cancellation_summary` | Cancellations by reason / zone |
| `semantic.vw_zone_demand` | Pickup zone demand |
| `semantic.vw_ride_sla` | Peak hours, accept/complete times |
| `semantic.vw_rating_summary` | Ratings by role and score |

---

## Branding

- Primary: `#1A2D42`
- Secondary: `#59A472`
- Logo path: `ai/assets/massar_logo.png`

---

## Demo questions (viva)

1. `What is completion rate?` → live KPI % from DW  
2. `What about cancellation rate?` → conversation memory  
3. `Total rides by month in 2025` → chart + table  
4. `Top 5 pickup zones by ride count`  
5. `Cancellation reasons during Ramadan 2025`

---

## Security

- `sql_guard.py` allows **SELECT** on `semantic.vw_*` only  
- Never commit `ai/.env`  
- Recommended: read-only SQL login with `SELECT` on schema `semantic` only  

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `localhost refused to connect` | Start Streamlit; keep terminal open |
| `Chroma store not found` | Run `python embed_pipeline.py` |
| `DeploymentNotFound` / Azure 404 | Check deployment names and **Azure OpenAI endpoint** |
| `insufficient_quota` (OpenAI) | Add billing or use Azure OpenAI |
| ODBC error | Install ODBC Driver 18 for SQL Server |
| SQL guard blocked query | Rephrase; use allowed views only |

Run diagnostics:

```powershell
python diagnose_startup.py
```

---

## Project structure

```
ai/
├── agent.py
├── branding.py
├── charts.py
├── config.py
├── db.py
├── embed_pipeline.py
├── insights.py
├── kpi_queries.py
├── memory.py
├── retriever.py
├── sql_guard.py
├── streamlit_app.py
├── text_to_sql.py
├── test_setup.py
├── run_app.bat
├── requirements.txt
├── .env.example
├── assets/massar_logo.png
└── rag/documents/          # RAG corpus for LangChain
```

---

## For the graduation report (one line)

*Massar AI uses LangChain RAG and agentic text-to-SQL over a governed semantic layer (dbt views), with SQL guardrails and Streamlit UI, complementing Power BI dashboards for standard KPI reporting.*
