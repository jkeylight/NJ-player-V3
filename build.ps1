# ============================================
# NJ PLAYER 3.0 — BUILD SYSTEM
# Packages everything into a distributable
# ============================================

param(
    [ValidateSet('portable', 'installer', 'zip')]
    [string]$Target = 'portable',

    [switch]$Clean,
    [switch]$SkipDownload
)

$ErrorActionPreference = 'Stop'

# ============================================
# CONFIGURATION
# ============================================
$BuildConfig = @{
    AppName = "NJ Player"
    Version = "3.0.0"
    Author = "NJ"
    Description = "Offline Video Enhancement & Encryption Suite"
    OutputDir = "dist"
    BuildDir = "build"
}

# ============================================
# PATHS
# ============================================
$RootDir = $PSScriptRoot
$OutputDir = Join-Path $RootDir $BuildConfig.OutputDir
$BuildDir = Join-Path $RootDir $BuildConfig.BuildDir

# ============================================
# CLEAN
# ============================================
if ($Clean) {
    Write-Host "Cleaning build directories..." -ForegroundColor Yellow

    foreach ($dir in @($OutputDir, $BuildDir)) {
        if (Test-Path $dir) {
            Remove-Item -Path $dir -Recurse -Force
            Write-Host "  Removed: $dir" -ForegroundColor Gray
        }
    }
}

# ============================================
# CREATE DIRECTORIES
# ============================================
foreach ($dir in @($OutputDir, $BuildDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  NJ PLAYER 3.0 — BUILD SYSTEM" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# VERIFY FILES
# ============================================
Write-Host "Verifying project files..." -ForegroundColor Yellow

$RequiredFiles = @(
    "NJ-Player.bat",
    "NJ-Player-GUI.bat",
    "NJ-Player-GUI.ps1",
    "START-HERE.bat",
    "mpv.conf",
    "input.conf",
    "install.ps1",
    "associate.ps1",
    "desktop-shortcut.ps1",
    "clear-history.ps1",
    "make-icon.ps1",
    "scripts\nj-presets.lua",
    "scripts\player-overlay.lua",
    "scripts\audio-enhance.lua",
    "scripts\auto-enhance.lua",
    "scripts\zoom-control.lua",
    "scripts\performance-monitor.lua",
    "scripts\compare-mode.lua",
    "security\gencrypt.py",
    "security\encrypt.ps1",
    "security\decrypt-play.ps1",
    "security\install-security.ps1"
)

$MissingFiles = @()

foreach ($file in $RequiredFiles) {
    $fullPath = Join-Path $RootDir $file
    if (-not (Test-Path $fullPath)) {
        $MissingFiles += $file
        Write-Host "  Missing: $file" -ForegroundColor Red
    } else {
        Write-Host "  OK: $file" -ForegroundColor Green
    }
}

if ($MissingFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "ERROR: $($MissingFiles.Count) required files missing" -ForegroundColor Red
    Write-Host "Cannot proceed with build" -ForegroundColor Red
    exit 1
}

# ============================================
# CREATE BUILD DIRECTORY STRUCTURE
# ============================================
Write-Host ""
Write-Host "Creating build structure..." -ForegroundColor Yellow

$BuildStructure = @(
    "mpv",
    "shaders",
    "scripts",
    "security",
    "config",
    "config\profiles",
    "audio",
    "library",
    "encrypted",
    "thumbnails",
    "watch_later",
    "screenshots",
    "temp"
)

foreach ($dir in $BuildStructure) {
    $fullPath = Join-Path $BuildDir $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
    }
}

Write-Host "  Build structure created" -ForegroundColor Green

# ============================================
# COPY CORE FILES
# ============================================
Write-Host ""
Write-Host "Copying core files..." -ForegroundColor Yellow

$CoreFiles = @(
    "NJ-Player.bat",
    "NJ-Player-GUI.bat",
    "NJ-Player-GUI.ps1",
    "START-HERE.bat",
    "mpv.conf",
    "input.conf",
    "install.ps1",
    "uninstall.ps1",
    "associate.ps1",
    "desktop-shortcut.ps1",
    "clear-history.ps1",
    "make-icon.ps1",
    "build.ps1",
    "README.md",
    "VERSION.txt"
)

foreach ($file in $CoreFiles) {
    $source = Join-Path $RootDir $file
    $dest = Join-Path $BuildDir $file

    if (Test-Path $source) {
        Copy-Item $source $dest -Force
        Write-Host "  OK: $file" -ForegroundColor Green
    }
}

# ============================================
# COPY SCRIPTS
# ============================================
Write-Host ""
Write-Host "Copying scripts..." -ForegroundColor Yellow

$ScriptFiles = @(
    "nj-presets.lua",
    "player-overlay.lua",
    "audio-enhance.lua",
    "auto-enhance.lua",
    "zoom-control.lua",
    "performance-monitor.lua",
    "compare-mode.lua"
)

foreach ($file in $ScriptFiles) {
    $source = Join-Path $RootDir "scripts\$file"
    $dest = Join-Path $BuildDir "scripts\$file"

    if (Test-Path $source) {
        Copy-Item $source $dest -Force
        Write-Host "  OK: scripts\$file" -ForegroundColor Green
    }
}

# ============================================
# COPY SECURITY FILES
# ============================================
Write-Host ""
Write-Host "Copying security files..." -ForegroundColor Yellow

$SecurityFiles = @(
    "gencrypt.py",
    "encrypt.ps1",
    "decrypt-play.ps1",
    "install-security.ps1"
)

foreach ($file in $SecurityFiles) {
    $source = Join-Path $RootDir "security\$file"
    $dest = Join-Path $BuildDir "security\$file"

    if (Test-Path $source) {
        Copy-Item $source $dest -Force
        Write-Host "  OK: security\$file" -ForegroundColor Green
    }
}

# ============================================
# COPY CONFIG
# ============================================
Write-Host ""
Write-Host "Copying config..." -ForegroundColor Yellow

$ConfigFiles = @(
    "config\settings.json",
    "config\settings-loader.lua"
)

foreach ($file in $ConfigFiles) {
    $source = Join-Path $RootDir $file
    $dest = Join-Path $BuildDir $file

    if (Test-Path $source) {
        Copy-Item $source $dest -Force
        Write-Host "  OK: $file" -ForegroundColor Green
    }
}

# ============================================
# DOWNLOAD DEPENDENCIES
# ============================================
if (-not $SkipDownload) {
    Write-Host ""
    Write-Host "Downloading dependencies..." -ForegroundColor Yellow

    # mpv
    $MpvUrl = "https://github.com/shinchiro/mpv-winbuild-cmake/releases/latest/download/mpv-x86_64-w64-mingw32.zip"
    $MpvZip = Join-Path $BuildDir "mpv.zip"

    Write-Host "  Downloading mpv..." -ForegroundColor Gray
    try {
        Invoke-WebRequest -Uri $MpvUrl -OutFile $MpvZip
        Expand-Archive -Path $MpvZip -DestinationPath (Join-Path $BuildDir "mpv") -Force
        Remove-Item $MpvZip -Force
        Write-Host "  OK: mpv downloaded" -ForegroundColor Green
    } catch {
        Write-Host "  WARNING: Failed to download mpv" -ForegroundColor Yellow
    }

    # yt-dlp
    $YtDlpUrl = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
    $YtDlpPath = Join-Path $BuildDir "mpv\yt-dlp.exe"

    Write-Host "  Downloading yt-dlp..." -ForegroundColor Gray
    try {
        Invoke-WebRequest -Uri $YtDlpUrl -OutFile $YtDlpPath
        Write-Host "  OK: yt-dlp downloaded" -ForegroundColor Green
    } catch {
        Write-Host "  WARNING: Failed to download yt-dlp" -ForegroundColor Yellow
    }

    # ffmpeg
    $FfmpegUrl = "https://github.com/BtbN/FFmpeg-Builds/releases/latest/download/ffmpeg-master-latest-win64-gpl.zip"
    $FfmpegZip = Join-Path $BuildDir "ffmpeg.zip"

    Write-Host "  Downloading ffmpeg..." -ForegroundColor Gray
    try {
        Invoke-WebRequest -Uri $FfmpegUrl -OutFile $FfmpegZip
        Expand-Archive -Path $FfmpegZip -DestinationPath (Join-Path $BuildDir "mpv") -Force

        $FfmpegExe = Get-ChildItem -Path (Join-Path $BuildDir "mpv") -Filter "ffmpeg.exe" -Recurse | Select-Object -First 1
        if ($FfmpegExe) {
            Copy-Item $FfmpegExe.FullName (Join-Path $BuildDir "mpv\ffmpeg.exe") -Force
        }
        Remove-Item $FfmpegZip -Force
        Write-Host "  OK: ffmpeg downloaded" -ForegroundColor Green
    } catch {
        Write-Host "  WARNING: Failed to download ffmpeg" -ForegroundColor Yellow
    }
}

# ============================================
# DOWNLOAD SHADERS
# ============================================
if (-not $SkipDownload) {
    Write-Host ""
    Write-Host "Downloading enhancement shaders..." -ForegroundColor Yellow

    $ShaderUrls = @{
        "adaptive-sharpen.glsl" = "https://raw.githubusercontent.com/igv/adaptive-sharpen/master/adaptive-sharpen.glsl"
        "krigbilateral.glsl" = "https://raw.githubusercontent.com/igv/KrigBilateral/master/KrigBilateral.glsl"
        "fsrcnnx_x2_8-0-4-1.glsl" = "https://raw.githubusercontent.com/igv/FSRCNN-TensorFlow/master/FSRCNNX_x2_8-0-4-1.glsl"
        "ssimsuperres.glsl" = "https://raw.githubusercontent.com/igv/SSimSuperRes/master/SSimSuperRes.glsl"
        "anime4k_restore_soft.glsl" = "https://raw.githubusercontent.com/bloc97/Anime4K/master/glsl/Restore/Anime4K_Restore_Soft.glsl"
        "anime4k_upscale_x2.glsl" = "https://raw.githubusercontent.com/bloc97/Anime4K/master/glsl/Upscale/Anime4K_Upscale_x2.glsl"
        "anime4k_aa.glsl" = "https://raw.githubusercontent.com/bloc97/Anime4K/master/glsl/AA/Anime4K_AA.glsl"
        "deband.glsl" = "https://raw.githubusercontent.com/haasn/gentoo-conf/master/xorg/mpv-shaders/deband.glsl"
        "denoise-skin.glsl" = "https://raw.githubusercontent.com/igv/Denoise/master/denoise-skin.glsl"
        "deblock.glsl" = "https://raw.githubusercontent.com/igv/Deblock/master/deblock.glsl"
        "hdr-tonemap.glsl" = "https://raw.githubusercontent.com/igv/HDR-to-SDR/master/hdr-tonemap.glsl"
        "motion-interpolate.glsl" = "https://raw.githubusercontent.com/igv/MotionInterpolate/master/motion-interpolate.glsl"
        "compare-mode.glsl" = "https://raw.githubusercontent.com/igv/CompareMode/master/compare-mode.glsl"
    }

    foreach ($shader in $ShaderUrls.Keys) {
        $shaderPath = Join-Path $BuildDir "shaders\$shader"

        try {
            Write-Host "  Downloading $shader..." -ForegroundColor Gray
            Invoke-WebRequest -Uri $ShaderUrls[$shader] -OutFile $shaderPath -ErrorAction SilentlyContinue
            Write-Host "  OK: $shader" -ForegroundColor Green
        } catch {
            Write-Host "  Skipped: $shader" -ForegroundColor Yellow
        }
    }
}

# ============================================
# CREATE VERSION FILE
# ============================================
Write-Host ""
Write-Host "Creating version file..." -ForegroundColor Yellow

$versionInfo = @"
NJ Player $($BuildConfig.Version)
Build Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Author: $($BuildConfig.Author)
Description: $($BuildConfig.Description)

Components:
- mpv media player (portable)
- yt-dlp (web link support)
- ffmpeg (video processing)
- Enhancement shaders (GPU-accelerated)
- Audio enhancement engine
- GenCrypt encryption (AES-256-GCM)
- Secure deletion (35-pass Gutmann)
- Auto-detection system
- Compare mode
- Performance monitor
"@

$versionInfo | Out-File (Join-Path $BuildDir "VERSION.txt") -Encoding UTF8
Write-Host "  OK: VERSION.txt" -ForegroundColor Green

# ============================================
# CREATE README
# ============================================
Write-Host "Creating README..." -ForegroundColor Yellow

$readme = @"
# NJ Player 3.0

## Offline Video Enhancement & Encryption Suite

### Quick Start
1. Run install.ps1 (one-time setup)
2. Double-click NJ-Player-GUI.bat
3. Browse to your video folder
4. Select a video and click PLAY

### Enhancement Presets
| Key | Preset | Description |
|-----|--------|-------------|
| CTRL+0 | Off | Clean playback |
| CTRL+1 | Lucid | Adaptive sharpening |
| CTRL+2 | Cinema | Full pipeline |
| CTRL+3 | Anime | Anime4K restoration |
| CTRL+4 | HDR | Tone mapping |
| CTRL+5 | Denoise | Skin-preserving |
| CTRL+6 | Motion | Frame interpolation |
| CTRL+7 | Auto | Smart detection |
| CTRL+8 | Compare | Split-screen |
| CTRL+9 | Restore | Full restoration |

### Security
- AES-256-GCM encryption
- 35-pass secure deletion
- PBKDF2 key derivation
- RAM-only password handling

### Audio Enhancement
- Noise reduction
- Dialogue boost
- Volume normalization
- Bass restoration
- Stereo widening
- Night mode

### Requirements
- Windows 10/11 (x64)
- 4GB RAM minimum (8GB recommended)
- GPU with OpenGL 3.3+ support

### Installation
Run install.ps1 for one-time setup.
No admin rights required. Fully portable.

### Uninstall
Delete the NJ Player folder. Done.
"@

$readme | Out-File (Join-Path $BuildDir "README.md") -Encoding UTF8
Write-Host "  OK: README.md" -ForegroundColor Green

# ============================================
# PACKAGE
# ============================================
Write-Host ""
Write-Host "Packaging..." -ForegroundColor Yellow

$ZipName = "NJ-Player-$($BuildConfig.Version)-portable.zip"
$ZipPath = Join-Path $OutputDir $ZipName

if (Test-Path $ZipPath) {
    Remove-Item $ZipPath -Force
}

Compress-Archive -Path (Join-Path $BuildDir "*") -DestinationPath $ZipPath -CompressionLevel Optimal

$ZipSize = (Get-Item $ZipPath).Length
$ZipSizeMB = [Math]::Round($ZipSize / 1MB, 1)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  BUILD COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Output: $ZipPath" -ForegroundColor White
Write-Host "  Size: $ZipSizeMB MB" -ForegroundColor White
Write-Host ""
Write-Host "  Distribution:" -ForegroundColor Yellow
Write-Host "  1. Extract the ZIP to any folder" -ForegroundColor White
Write-Host "  2. Run START-HERE.bat" -ForegroundColor White
Write-Host "  3. Follow on-screen instructions" -ForegroundColor White
Write-Host ""
