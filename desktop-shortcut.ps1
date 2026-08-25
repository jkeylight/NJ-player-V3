# ============================================
# NJ PLAYER 3.0 — DESKTOP SHORTCUT
# Creates a desktop shortcut for NJ Player
# ============================================

param(
    [switch]$Remove
)

$RootDir = $PSScriptRoot
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$ShortcutPath = Join-Path $DesktopPath "NJ Player.lnk"
$GuiBat = Join-Path $RootDir "NJ-Player-GUI.bat"
$IconPath = Join-Path $RootDir "nj-player.ico"

Write-Host ""
Write-Host "NJ Player 3.0 — Desktop Shortcut" -ForegroundColor Cyan
Write-Host ""

if ($Remove) {
    if (Test-Path $ShortcutPath) {
        Remove-Item -Path $ShortcutPath -Force
        Write-Host "✓ Removed NJ Player desktop shortcut" -ForegroundColor Green
    } else {
        Write-Host "Desktop shortcut not found" -ForegroundColor Yellow
    }
    exit 0
}

# Create shortcut
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $GuiBat
$Shortcut.WorkingDirectory = $RootDir
$Shortcut.Description = "NJ Player 3.0 — Offline Video Enhancement & Encryption"
$Shortcut.WindowStyle = 1

# Set icon
if (Test-Path $IconPath) {
    $Shortcut.IconLocation = "$IconPath,0"
} else {
    $Shortcut.IconLocation = "mpv.exe,0"
}

$Shortcut.Save()

Write-Host "✓ Created NJ Player desktop shortcut" -ForegroundColor Green
Write-Host "  Location: $ShortcutPath" -ForegroundColor Gray
Write-Host ""
