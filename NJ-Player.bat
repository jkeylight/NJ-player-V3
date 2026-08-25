@echo off
setlocal enabledelayedexpansion

:: ============================================
:: NJ PLAYER 3.0 — DRAG-AND-DROP LAUNCHER
:: ============================================

set "ROOT_DIR=%~dp0"
set "MPV_EXE=%ROOT_DIR%mpv\mpv.exe"

:: Check if mpv exists
if not exist "%MPV_EXE%" (
    echo.
    echo  ERROR: mpv not found.
    echo  Run install.ps1 first.
    echo.
    pause
    exit /b 1
)

:: Check if files were dropped
if "%~1"=="" (
    echo.
    echo  NJ Player 3.0
    echo  Drag and drop video files onto this script.
    echo  Or run NJ-Player-GUI.bat for the launcher.
    echo.
    pause
    exit /b 0
)

:: Process each dropped file
:process_files
if "%~1"=="" goto done

set "FILE_PATH=%~1"
set "FILE_EXT=%~x1"

:: Check if encrypted
if /i "%FILE_EXT%"==".enc" (
    echo.
    echo  Encrypted file detected: %~nx1
    echo  Launching decryption...
    echo.
    powershell -ExecutionPolicy Bypass -File "%ROOT_DIR%security\decrypt-play.ps1" "%FILE_PATH%"
    goto next_file
)

:: Launch mpv with NJ Player config
echo.
echo  Playing: %~nx1
echo.

"%MPV_EXE%" --config-dir="%ROOT_DIR%" "%FILE_PATH%"

:next_file
shift
goto process_files

:done
exit /b 0
