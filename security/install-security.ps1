# ============================================
# NJ PLAYER 3.0 — SECURITY SETUP
# ============================================

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  NJ PLAYER — SECURITY SETUP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --- Check Python ---
Write-Host "Checking Python..." -ForegroundColor Yellow
try {
    python --version
    if ($LASTEXITCODE -ne 0) { throw "Python not found" }
    Write-Host "  ✓ Python installed" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Python not found" -ForegroundColor Red
    Write-Host "  Download: https://python.org/downloads" -ForegroundColor Yellow
    Write-Host "  IMPORTANT: Check 'Add to PATH' during installation" -ForegroundColor Yellow
    exit 1
}

# --- Install cryptography ---
Write-Host "Checking cryptography library..." -ForegroundColor Yellow
try {
    python -c "import cryptography; print(f'  ✓ cryptography {cryptography.__version__}')" 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Not installed" }
} catch {
    Write-Host "  Installing cryptography..." -ForegroundColor Yellow
    pip install cryptography
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ cryptography installed" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Failed to install cryptography" -ForegroundColor Red
        exit 1
    }
}

# --- Create security directory ---
$SecurityDir = $PSScriptRoot
if (-not (Test-Path $SecurityDir)) {
    New-Item -ItemType Directory -Path $SecurityDir -Force | Out-Null
    Write-Host "  ✓ Created security directory" -ForegroundColor Green
}

# --- Register right-click integration (optional) ---
Write-Host ""
Write-Host "Register right-click integration?" -ForegroundColor Yellow
Write-Host "  This adds 'Encrypt with NJ Player' to right-click menu" -ForegroundColor Gray
Write-Host "  [Y] Yes  [N] No" -ForegroundColor Gray
$response = Read-Host "Choice"

if ($response -eq 'Y' -or $response -eq 'y') {
    $regPath = "HKCU:\Software\Classes\*\shell\NJEncrypt"
    New-Item -Path $regPath -Force | Out-Null
    Set-ItemProperty -Path $regPath -Name "(Default)" -Value "🔒 Encrypt with NJ Player"
    Set-ItemProperty -Path $regPath -Name "Icon" -Value "powershell.exe"

    $cmdPath = "$regPath\command"
    New-Item -Path $cmdPath -Force | Out-Null
    $encryptScript = Join-Path $PSScriptRoot "encrypt.ps1"
    Set-ItemProperty -Path $cmdPath -Name "(Default)" -Value "powershell -ExecutionPolicy Bypass -File `"$encryptScript`" `"%1`""

    Write-Host "  ✓ Right-click integration registered" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SECURITY SETUP COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Usage:" -ForegroundColor Yellow
Write-Host "  Encrypt:  python security\gencrypt.py encrypt video.mp4 --password `"Pass123!`"" -ForegroundColor White
Write-Host "  Decrypt:  python security\gencrypt.py decrypt video.mp4.enc --password `"Pass123!`"" -ForegroundColor White
Write-Host "  Shred:    python security\gencrypt.py shred secret.mp4" -ForegroundColor White
Write-Host ""
