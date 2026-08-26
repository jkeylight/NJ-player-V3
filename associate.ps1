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

    # Remove folder "Play in NJ Player"
    $folderPath = "HKCU:\Software\Classes\Directory\shell\NJPlayFolder"
    if (Test-Path $folderPath) {
        Remove-Item -Path $folderPath -Recurse -Force
        Write-Host "✓ Removed 'Play Folder in NJ Player' from folder menu" -ForegroundColor Green
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

# --- Folder "Play in NJ Player" (queue whole folder) ---
$folderPath = "HKCU:\Software\Classes\Directory\shell\NJPlayFolder"
New-Item -Path $folderPath -Force | Out-Null
Set-ItemProperty -Path $folderPath -Name "(Default)" -Value "Play Folder in NJ Player"
if (Test-Path $IconPath) {
    Set-ItemProperty -Path $folderPath -Name "Icon" -Value $IconPath
}

$folderCmdPath = "$folderPath\command"
New-Item -Path $folderCmdPath -Force | Out-Null
# %1 = the folder path; the GUI launcher adds every video inside it.
Set-ItemProperty -Path $folderCmdPath -Name "(Default)" -Value "`"$PlayerBat`" `"%1`""

Write-Host "✓ Added 'Play Folder in NJ Player' to folder menu" -ForegroundColor Green

Write-Host ""
Write-Host "Done! Right-click any video or folder to open with NJ Player." -ForegroundColor Cyan
Write-Host "Note: You may need to restart File Explorer for changes to appear." -ForegroundColor Gray
Write-Host ""
