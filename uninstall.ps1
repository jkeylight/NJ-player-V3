# ============================================
# NJ PLAYER 3.0 — UNINSTALLER
# Removes all traces of NJ Player
# ============================================

param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  NJ PLAYER 3.0 — UNINSTALLER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Confirmation
if (-not $Force) {
    Write-Host "  This will remove NJ Player completely." -ForegroundColor Yellow
    Write-Host "  Including all settings, history, and encrypted files." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Are you sure? [Y/N]" -ForegroundColor Red
    $response = Read-Host

    if ($response -notin @('Y', 'y')) {
        Write-Host "  Uninstall cancelled" -ForegroundColor Gray
        exit 0
    }
}

$RootDir = $PSScriptRoot

# ============================================
# REMOVE RIGHT-CLICK INTEGRATION
# ============================================
Write-Host "Removing right-click integration..." -ForegroundColor Yellow

$RegistryPaths = @(
    "HKCU:\Software\Classes\*\shell\NJEncrypt",
    "HKCU:\Software\Classes\*\shell\NJPlayer",
    "HKCU:\Software\Classes\*\shell\NJDecrypt",
    "HKCU:\Software\Classes\*\shell\NJClearHistory",
    "HKCU:\Software\Classes\Applications\mpv.exe"
)

foreach ($path in $RegistryPaths) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force
        Write-Host "  OK: Removed $path" -ForegroundColor Green
    }
}

# ============================================
# REMOVE DESKTOP SHORTCUT
# ============================================
Write-Host "Removing desktop shortcut..." -ForegroundColor Yellow

$DesktopPath = [Environment]::GetFolderPath("Desktop")
$ShortcutPath = Join-Path $DesktopPath "NJ Player.lnk"

if (Test-Path $ShortcutPath) {
    Remove-Item $ShortcutPath -Force
    Write-Host "  OK: Removed desktop shortcut" -ForegroundColor Green
}

# ============================================
# CLEAR WATCH LATER
# ============================================
Write-Host "Clearing watch history..." -ForegroundColor Yellow

$WatchLaterPath = Join-Path $RootDir "watch_later"
if (Test-Path $WatchLaterPath) {
    Remove-Item $WatchLaterPath -Recurse -Force
    Write-Host "  OK: Cleared watch history" -ForegroundColor Green
}

# ============================================
# CLEAR TEMP FILES
# ============================================
Write-Host "Clearing temp files..." -ForegroundColor Yellow

$TempPaths = @(
    Join-Path $RootDir "temp",
    Join-Path $RootDir "thumbnails",
    Join-Path $env:TEMP "nj-player-temp"
)

foreach ($path in $TempPaths) {
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force
        Write-Host "  OK: Cleared $path" -ForegroundColor Green
    }
}

# ============================================
# CLEAR LAST FOLDER
# ============================================
Write-Host "Clearing remembered folder..." -ForegroundColor Yellow

$LastFolderFile = Join-Path $RootDir ".last-folder.txt"
if (Test-Path $LastFolderFile) {
    Remove-Item $LastFolderFile -Force
    Write-Host "  OK: Cleared remembered folder" -ForegroundColor Green
}

# ============================================
# FINAL MESSAGE
# ============================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  UNINSTALL COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  To fully remove NJ Player:" -ForegroundColor Yellow
Write-Host "  Delete the NJ Player folder:" -ForegroundColor White
Write-Host "  $RootDir" -ForegroundColor Gray
Write-Host ""
