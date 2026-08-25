@echo off
title NJ Player 3.0 - Installer
echo.
echo  NJ PLAYER 3.0 - INSTALLER
echo  =========================
echo.
echo  This will download mpv, shaders, and other tools.
echo  It may take a few minutes on first run.
echo.
echo  Press any key to start...
pause >nul
echo.
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0install.ps1"
echo.
echo  Done! Press any key to exit.
pause >nul
