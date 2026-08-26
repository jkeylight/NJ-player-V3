@echo off
cd /d "%~dp0"
start "" powershell -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File "%~dp0NJ-Player-GUI.ps1"
