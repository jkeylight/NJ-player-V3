# ============================================
# NJ PLAYER 3.0 — CLEAR HISTORY
# Wipes resume positions and remembered folder
# ============================================

$RootDir = $PSScriptRoot
$WatchLaterDir = Join-Path $RootDir "watch_later"
$LastFolderFile = Join-Path $RootDir ".last-folder.txt"

Write-Host ""
Write-Host "NJ Player 3.0 — Clear History" -ForegroundColor Cyan
Write-Host ""

# Confirm action
$confirm = Read-Host "Clear all resume positions and remembered folder? (Y/N)"
if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit 0
}

# Clear watch later directory
if (Test-Path $WatchLaterDir) {
    $files = Get-ChildItem -Path $WatchLaterDir -File
    foreach ($file in $files) {
        Remove-Item -Path $file.FullName -Force
    }
    Write-Host "✓ Cleared resume positions ($($files.Count) files)" -ForegroundColor Green
} else {
    Write-Host "  No resume positions found" -ForegroundColor Gray
}

# Clear last folder file
if (Test-Path $LastFolderFile) {
    Remove-Item -Path $LastFolderFile -Force
    Write-Host "✓ Cleared remembered folder" -ForegroundColor Green
} else {
    Write-Host "  No remembered folder found" -ForegroundColor Gray
}

Write-Host ""
Write-Host "History cleared!" -ForegroundColor Cyan
Write-Host ""
