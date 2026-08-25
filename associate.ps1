# ============================================
# NJ PLAYER 3.0 — RIGHT-CLICK INTEGRATION
# Adds "Open with NJ Player" to context menu
# ============================================

param(
    [switch]$Remove
)

$ErrorActionPreference = 'Stop'

$RootDir = $PSScriptRoot
$PlayerBat = Join-Path $RootDir "NJ-Player.bat"
$IconPath = Join-Path $RootDir "nj-player.ico"

Write-Host ""
Write-Host "NJ Player 3.0 — Right-Click Integration" -ForegroundColor Cyan
Write-Host ""

if ($Remove) {
    # Remove context menu
    $regPath = "HKCU:\Software\Classes\*\shell\NJPlayer"
    if (Test-Path $regPath) {
        Remove-Item -Path $regPath -Recurse -Force
        Write-Host "✓ Removed 'Open with NJ Player' from context menu" -ForegroundColor Green
    } else {
        Write-Host "Context menu not found" -ForegroundColor Yellow
    }
    
    # Remove history clearing
    $historyPath = "HKCU:\Software\Classes\*\shell\NJClearHistory"
    if (Test-Path $historyPath) {
        Remove-Item -Path $historyPath -Recurse -Force
        Write-Host "✓ Removed 'Clear NJ Player History' from context menu" -ForegroundColor Green
    }
    
    exit 0
}

# --- Add context menu items ---

# Main "Open with NJ Player" item
$regPath = "HKCU:\Software\Classes\*\shell\NJPlayer"
New-Item -Path $regPath -Force | Out-Null
Set-ItemProperty -Path $regPath -Name "(Default)" -Value "Open with NJ Player"
if (Test-Path $IconPath) {
    Set-ItemProperty -Path $regPath -Name "Icon" -Value $IconPath
} else {
    Set-ItemProperty -Path $regPath -Name "Icon" -Value "mpv.exe"
}

$cmdPath = "$regPath\command"
New-Item -Path $cmdPath -Force | Out-Null
Set-ItemProperty -Path $cmdPath -Name "(Default)" -Value "`"$PlayerBat`" `"%1`""

Write-Host "✓ Added 'Open with NJ Player' to context menu" -ForegroundColor Green

# "Clear History" item
$historyPath = "HKCU:\Software\Classes\*\shell\NJClearHistory"
New-Item -Path $historyPath -Force | Out-Null
Set-ItemProperty -Path $historyPath -Name "(Default)" -Value "Clear NJ Player History"
Set-ItemProperty -Path $historyPath -Name "Icon" -Value "powershell.exe"

$historyCmdPath = "$historyPath\command"
New-Item -Path $historyCmdPath -Force | Out-Null
$clearHistoryScript = Join-Path $RootDir "clear-history.ps1"
Set-ItemProperty -Path $historyCmdPath -Name "(Default)" -Value "powershell -ExecutionPolicy Bypass -File `"$clearHistoryScript`""

Write-Host "✓ Added 'Clear NJ Player History' to context menu" -ForegroundColor Green

Write-Host ""
Write-Host "Done! Right-click any video to open with NJ Player." -ForegroundColor Cyan
Write-Host "Note: You may need to restart File Explorer for changes to appear." -ForegroundColor Gray
Write-Host ""
