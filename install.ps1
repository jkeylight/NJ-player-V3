# ============================================
# NJ PLAYER 3.0 - INSTALLATION SCRIPT
# ============================================

param(
    [switch]$Force
)

$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  NJ PLAYER 3.0 - INSTALLATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --- Paths ---
$RootDir = $PSScriptRoot
$MpvDir = Join-Path $RootDir "mpv"
$ShaderDir = Join-Path $RootDir "shaders"
$ScriptDir = Join-Path $RootDir "scripts"

# --- Create directories ---
foreach ($dir in @($MpvDir, $ShaderDir, $ScriptDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  Created: $dir" -ForegroundColor Gray
    }
}

# --- Find 7-Zip ---
$SevenZip = $null
$possiblePaths = @(
    "C:\Program Files\7-Zip\7z.exe",
    "C:\Program Files (x86)\7-Zip\7z.exe",
    (Join-Path $RootDir "7z.exe")
)
foreach ($p in $possiblePaths) {
    if (Test-Path $p) {
        $SevenZip = $p
        break
    }
}

# --- Download URLs ---
$YtDlpUrl = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"

# --- Shader URLs (from Zabooby/mpv-config, verified working) ---
$ShaderUrls = @{
    # Adaptive sharpening (replaces igv/adaptive-sharpen)
    "adaptive-sharpen.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/adasharp_luma.glsl"
    # KrigBilateral color (replaces igv/KrigBilateral)
    "krigbilateral.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/krigbl.glsl"
    # SSimSuperRes de-ringing (replaces igv/SSimSuperRes)
    "ssimsuperres.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/ssimsr.glsl"
    # SSimDownscaler (replaces igv/SSimDownscaler)
    "ssimdownscaler.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/ssimds.glsl"
    # RAUV upscaler (replaces FSRCNNX which is too heavy for most GPUs)
    "ravu-z-ar-r3.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/ravu_z_ar_r3.glsl"
    # NNEDI3 upscale
    "nnedi3-nns64-win8x4.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/nnedi3_nns64_win8x4.glsl"
    # NLMeans noise reduction (replaces igv/denoise-skin)
    "nlmeans-luma.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/nlmeans_luma.glsl"
    # Anime4K Restore CNN Soft (replaces bloc97/Anime4K restore)
    "anime4k-restore-cnn-soft.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/A4K_Restore_CNN_Soft_M.glsl"
    # Anime4K ArtCNN upscale (replaces bloc97/Anime4K upscale)
    "anime4k-artcnn-x2.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/Ani4Kv2_ArtCNN_C4F32_i2.glsl"
    # Anime4K Clamp Highlights
    "anime4k-clamp-highlights.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/A4K_Clamp_Highlights.glsl"
    # F8 film emulation
    "f8.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/F8.glsl"
}

# ============================================
# DOWNLOAD MPV (via GitHub API - dynamic URL)
# ============================================
$MpvExePath = Join-Path $MpvDir "mpv.exe"

if ((-not (Test-Path $MpvExePath)) -or $Force) {
    Write-Host "Finding latest mpv build..." -ForegroundColor Yellow
    try {
        # Use GitHub API to get the latest release
        $releaseUrl = "https://api.github.com/repos/shinchiro/mpv-winbuild-cmake/releases/latest"
        $releaseData = Invoke-RestMethod -Uri $releaseUrl -UseBasicParsing

        # Find the mpv-x86_64 (non-v3, non-dev) asset
        $mpvAsset = $null
        foreach ($asset in $releaseData.assets) {
            $name = $asset.name
            if ($name -match "mpv-x86_64-" -and $name -notmatch "v3" -and $name -notmatch "dev") {
                $mpvAsset = $asset
                break
            }
        }

        if (-not $mpvAsset) {
            # Fallback: accept dev builds too
            foreach ($asset in $releaseData.assets) {
                $name = $asset.name
                if ($name -match "mpv.*x86_64-" -and $name -notmatch "v3") {
                    $mpvAsset = $asset
                    break
                }
            }
        }

        if ($mpvAsset) {
            Write-Host "  Found: $($mpvAsset.name)" -ForegroundColor Gray
            Write-Host "  Downloading mpv..." -ForegroundColor Yellow

            $MpvArchive = Join-Path $MpvDir $mpvAsset.name
            Invoke-WebRequest -Uri $mpvAsset.browser_download_url -OutFile $MpvArchive -UseBasicParsing

            # Extract using 7-Zip
            if ($SevenZip) {
                Write-Host "  Extracting with 7-Zip..." -ForegroundColor Gray
                & $SevenZip x $MpvArchive "-o$MpvDir" -y | Out-Null
            } else {
                # Try Expand-Archive (only works for .zip)
                try {
                    Expand-Archive -Path $MpvArchive -DestinationPath $MpvDir -Force
                }
                catch {
                    Write-Host "  [WARN] Cannot extract .7z without 7-Zip. Install 7-Zip and re-run." -ForegroundColor Yellow
                    Write-Host "  Download 7-Zip from: https://7-zip.org" -ForegroundColor Gray
                }
            }

            # Clean up archive
            Remove-Item $MpvArchive -Force -ErrorAction SilentlyContinue

            # Verify extraction
            if (Test-Path $MpvExePath) {
                Write-Host "  [OK] mpv installed" -ForegroundColor Green
            } else {
                # Check subdirectories
                $found = Get-ChildItem -Path $MpvDir -Filter "mpv.exe" -Recurse | Select-Object -First 1
                if ($found) {
                    Copy-Item $found.FullName $MpvExePath -Force
                    Write-Host "  [OK] mpv installed" -ForegroundColor Green
                } else {
                    Write-Host "  [WARN] mpv downloaded but mpv.exe not found after extraction" -ForegroundColor Yellow
                }
            }
        } else {
            Write-Host "  [FAIL] Could not find mpv-x86_64 in latest release" -ForegroundColor Red
            Write-Host "  Download manually from: https://sourceforge.net/projects/mpv-player-windows/files/" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "  [FAIL] Failed to download mpv: $_" -ForegroundColor Red
        Write-Host "  Download manually from: https://sourceforge.net/projects/mpv-player-windows/files/" -ForegroundColor Yellow
    }
}
else {
    Write-Host "  [OK] mpv already installed" -ForegroundColor Green
}

# ============================================
# DOWNLOAD YT-DLP
# ============================================
$YtDlpPath = Join-Path $MpvDir "yt-dlp.exe"

if ((-not (Test-Path $YtDlpPath)) -or $Force) {
    Write-Host "Downloading yt-dlp..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $YtDlpUrl -OutFile $YtDlpPath -UseBasicParsing
        Write-Host "  [OK] yt-dlp installed" -ForegroundColor Green
    }
    catch {
        Write-Host "  [FAIL] Failed to download yt-dlp: $_" -ForegroundColor Red
        Write-Host "  Download manually from: https://github.com/yt-dlp/yt-dlp" -ForegroundColor Yellow
    }
}
else {
    Write-Host "  [OK] yt-dlp already installed" -ForegroundColor Green
}

# ============================================
# DOWNLOAD FFMPEG (from shinchiro release)
# ============================================
$FfmpegExePath = Join-Path $MpvDir "ffmpeg.exe"

if ((-not (Test-Path $FfmpegExePath)) -or $Force) {
    Write-Host "Downloading ffmpeg..." -ForegroundColor Yellow
    try {
        # Make sure release metadata is available even when mpv was already installed
        if (-not $releaseData) {
            $releaseUrl = "https://api.github.com/repos/shinchiro/mpv-winbuild-cmake/releases/latest"
            $releaseData = Invoke-RestMethod -Uri $releaseUrl -UseBasicParsing
        }

        # Find ffmpeg in the same release
        $ffmpegAsset = $null
        foreach ($asset in $releaseData.assets) {
            $name = $asset.name
            if ($name -match "ffmpeg-x86_64-" -and $name -notmatch "v3") {
                $ffmpegAsset = $asset
                break
            }
        }

        if ($ffmpegAsset) {
            $FfmpegArchive = Join-Path $MpvDir $ffmpegAsset.name
            Invoke-WebRequest -Uri $ffmpegAsset.browser_download_url -OutFile $FfmpegArchive -UseBasicParsing

            if ($SevenZip) {
                & $SevenZip x $FfmpegArchive "-o$MpvDir" -y | Out-Null
            } else {
                Expand-Archive -Path $FfmpegArchive -DestinationPath $MpvDir -Force
            }

            Remove-Item $FfmpegArchive -Force -ErrorAction SilentlyContinue

            # Find and copy ffmpeg.exe
            $found = Get-ChildItem -Path $MpvDir -Filter "ffmpeg.exe" -Recurse | Select-Object -First 1
            if ($found) {
                Copy-Item $found.FullName $FfmpegExePath -Force
                Write-Host "  [OK] ffmpeg installed" -ForegroundColor Green
            } else {
                Write-Host "  [WARN] ffmpeg downloaded but ffmpeg.exe not found" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  [SKIP] ffmpeg not found in mpv release" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "  [FAIL] Failed to download ffmpeg: $_" -ForegroundColor Red
    }
}
else {
    Write-Host "  [OK] ffmpeg already installed" -ForegroundColor Green
}

# ============================================
# DOWNLOAD ENHANCEMENT SHADERS
# ============================================
Write-Host "Downloading enhancement shaders..." -ForegroundColor Yellow
$shaderCount = 0
$shaderTotal = $ShaderUrls.Count

foreach ($shader in $ShaderUrls.Keys) {
    $shaderPath = Join-Path $ShaderDir $shader
    if ((-not (Test-Path $shaderPath)) -or $Force) {
        try {
            Invoke-WebRequest -Uri $ShaderUrls[$shader] -OutFile $shaderPath -UseBasicParsing
            $shaderCount++
            Write-Host "  [OK] $shader" -ForegroundColor Green
        }
        catch {
            Write-Host "  [FAIL] $shader - download failed" -ForegroundColor Red
        }
    }
    else {
        $shaderCount++
        Write-Host "  [OK] $shader (already installed)" -ForegroundColor Green
    }
}

Write-Host "  Shaders: $shaderCount/$shaderTotal installed" -ForegroundColor Gray

# ============================================
# CHECK PYTHON + CRYPTOGRAPHY
# ============================================
Write-Host ""
Write-Host "Checking Python..." -ForegroundColor Yellow
$pythonFound = $false
try {
    $pythonVersion = & python --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $pythonFound = $true
        Write-Host "  [OK] $pythonVersion" -ForegroundColor Green

        & python -c "import cryptography" 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  Installing cryptography..." -ForegroundColor Yellow
            & pip install cryptography
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  [OK] cryptography installed" -ForegroundColor Green
            }
        }
        else {
            Write-Host "  [OK] cryptography already installed" -ForegroundColor Green
        }
    }
}
catch {
    # Python not found
}

if (-not $pythonFound) {
    Write-Host "  [SKIP] Python not found (optional - needed for encryption)" -ForegroundColor Yellow
    Write-Host "  Download: https://python.org/downloads" -ForegroundColor Gray
}

# ============================================
# DONE
# ============================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INSTALLATION COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Installed:" -ForegroundColor Yellow
Write-Host "    mpv:     $(if (Test-Path $MpvExePath) {'[OK]'} else {'[MISSING]'})" -ForegroundColor White
Write-Host "    yt-dlp:  $(if (Test-Path $YtDlpPath) {'[OK]'} else {'[MISSING]'})" -ForegroundColor White
Write-Host "    ffmpeg:  $(if (Test-Path $FfmpegExePath) {'[OK]'} else {'[MISSING]'})" -ForegroundColor White
Write-Host "    shaders: $shaderCount/$shaderTotal" -ForegroundColor White
Write-Host "    python:  $(if ($pythonFound) {'[OK]'} else {'[SKIP]'})" -ForegroundColor White
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor Yellow
Write-Host "  1. Double-click START-HERE.bat to launch" -ForegroundColor White
Write-Host "  2. Or double-click NJ-Player-GUI.bat for the launcher" -ForegroundColor White
Write-Host "  3. Drag a video onto NJ-Player.bat" -ForegroundColor White
Write-Host "  4. Press CTRL+1..9 to switch enhancement presets" -ForegroundColor White
Write-Host ""
