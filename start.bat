@echo off
cd /d "%~dp0ComfyUI"
if not exist ".venv\Scripts\python.exe" (
    echo Environment not installed yet. Please run setup.ps1 first.
    pause
    exit /b 1
)
echo Starting ComfyUI... opening http://127.0.0.1:8188
start "" http://127.0.0.1:8188
".venv\Scripts\python.exe" main.py
pause
