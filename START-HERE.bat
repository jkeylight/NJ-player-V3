@echo off
title NJ Player 3.0
color 0A

:menu
cls
echo.
echo  ============================================
echo     NJ PLAYER 3.0
echo     Offline Video Enhancement ^& Encryption
echo  ============================================
echo.
echo     [1] Launch GUI Player
echo     [2] Open Video Folder
echo     [3] Encrypt a Video
echo     [4] Decrypt and Play
echo     [5] Settings
echo     [6] Check Installation
echo     [7] Help
echo     [8] Exit
echo.
echo  ============================================
echo.
set /p choice="  Select option (1-8): "

if "%choice%"=="1" goto launch_gui
if "%choice%"=="2" goto open_folder
if "%choice%"=="3" goto encrypt
if "%choice%"=="4" goto decrypt
if "%choice%"=="5" goto settings
if "%choice%"=="6" goto check
if "%choice%"=="7" goto help
if "%choice%"=="8" exit
goto menu

:launch_gui
cls
echo.
echo  Launching NJ Player GUI...
echo.
call "%~dp0NJ-Player-GUI.bat"
goto menu

:open_folder
cls
echo.
echo  Opening video folder...
echo.
start explorer "%~dp0library"
goto menu

:encrypt
cls
echo.
echo  Encrypt a video:
echo  Drag and drop your video onto security\encrypt.ps1
echo  Or right-click any file and select "Encrypt with NJ Player"
echo.
pause
goto menu

:decrypt
cls
echo.
echo  Decrypt and Play:
echo  Double-click any .enc file
echo  Or drag it onto NJ-Player.bat
echo.
pause
goto menu

:settings
cls
echo.
echo  Settings:
echo  Edit nj-config\settings.json to customize
echo.
echo  Opening settings folder...
start explorer "%~dp0config"
goto menu

:check
cls
echo.
echo  Checking installation...
echo.
if exist "%~dp0mpv\mpv.exe" (
    echo  [OK] mpv player
) else (
    echo  [MISSING] mpv player - Run install.ps1
)

if exist "%~dp0mpv\yt-dlp.exe" (
    echo  [OK] yt-dlp
) else (
    echo  [MISSING] yt-dlp - Run install.ps1
)

if exist "%~dp0mpv\ffmpeg.exe" (
    echo  [OK] ffmpeg
) else (
    echo  [MISSING] ffmpeg - Run install.ps1
)

if exist "%~dp0shaders\adaptive-sharpen.glsl" (
    echo  [OK] Enhancement shaders
) else (
    echo  [MISSING] Enhancement shaders - Run install.ps1
)

if exist "%~dp0security\gencrypt.py" (
    echo  [OK] Encryption engine
) else (
    echo  [MISSING] Encryption engine - Run install-security.ps1
)

python --version >nul 2>&1
if %errorlevel%==0 (
    echo  [OK] Python
) else (
    echo  [MISSING] Python - Required for encryption
)

echo.
pause
goto menu

:help
cls
echo.
echo  ============================================
echo     NJ PLAYER 3.0 — HELP
echo  ============================================
echo.
echo  QUICK START:
echo    1. Run install.ps1 (one-time setup)
echo    2. Double-click START-HERE.bat
echo    3. Select option 1 to launch GUI
echo.
echo  ENHANCEMENT:
echo    CTRL+1  Lucid (adaptive sharpening)
echo    CTRL+2  Cinema (full pipeline)
echo    CTRL+3  Anime (Anime4K)
echo    CTRL+7  Auto (smart detection)
echo    CTRL+8  Compare (split-screen)
echo.
echo  AUDIO:
echo    CTRL+SHIFT+A  Toggle enhancement
echo    CTRL+SHIFT+D  Dialogue boost
echo.
echo  SECURITY:
echo    CTRL+E  Encrypt current video
echo    CTRL+D  Decrypt and play
echo.
echo  For full documentation, see README.md
echo.
pause
goto menu
