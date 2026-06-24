@echo off
chcp 65001 >nul
title Massar - Smart Transportation
cd /d "%~dp0"

echo.
echo  ========================================
echo    MASSAR - Smart Transportation
echo  ========================================
echo.

where node >nul 2>nul
if errorlevel 1 (
    echo  [ERROR] Node.js is not installed.
    echo.
    echo  Download and install Node.js from:
    echo  https://nodejs.org
    echo.
    echo  Then double-click START.bat again.
    echo.
    pause
    exit /b 1
)

echo  Node version:
node -v
echo.

if not exist "node_modules\" (
    echo  First run - installing dependencies...
    echo  This may take a few minutes...
    echo.
    call npm install
    if errorlevel 1 (
        echo.
        echo  [ERROR] Installation failed. Check your internet connection.
        pause
        exit /b 1
    )
    echo.
    echo  Installation complete!
    echo.
)

echo  Starting the app...
echo  Open your browser at: http://localhost:4200
echo.
echo  To stop the app, close this window or press Ctrl+C
echo.

timeout /t 3 /nobreak >nul
start "" "http://localhost:4200"

call npm start

pause
