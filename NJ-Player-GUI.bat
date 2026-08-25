@echo off
cd /d "%~dp0"
start "" powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0NJ-Player-GUI.ps1"
