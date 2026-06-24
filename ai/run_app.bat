@echo off
title Massar AI - Streamlit
cd /d "%~dp0"

if not exist ".venv\Scripts\python.exe" (
    echo [ERROR] Virtual environment not found.
    echo Run: python -m venv .venv
    echo Then: .venv\Scripts\pip install -r requirements.txt
    pause
    exit /b 1
)

echo Starting Massar AI on http://localhost:8501
echo Keep this window OPEN while using the app.
echo.

".venv\Scripts\python.exe" -m streamlit run streamlit_app.py --server.port 8501 --server.address localhost

echo.
echo Streamlit stopped.
pause
