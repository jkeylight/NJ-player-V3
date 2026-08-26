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
    Version = "3.0.1"
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
    "nj-config",
    "nj-config\profiles",
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
    "nj-config\settings.json",
    "nj-config\settings-loader.lua"
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
# COPY EXISTING RUNTIME ASSETS (self-contained fallback)
# Anything already present in the repo is copied into the build
# so the package is complete even if downloads fail.
# ============================================
Write-Host ""
Write-Host "Copying existing runtime assets..." -ForegroundColor Yellow

# Shaders already present in the repo (match mpv.conf)
if (Test-Path (Join-Path $RootDir "shaders")) {
    Copy-Item -Path (Join-Path $RootDir "shaders\*") -Destination (Join-Path $BuildDir "shaders") -Recurse -Force
    $shaderCountOnDisk = (Get-ChildItem -Path (Join-Path $RootDir "shaders") -File).Count
    Write-Host "  OK: $shaderCountOnDisk bundled shaders copied" -ForegroundColor Green
}

# mpv runtime files already present in the repo (dlls, docs, etc.)
if (Test-Path (Join-Path $RootDir "mpv")) {
    Copy-Item -Path (Join-Path $RootDir "mpv\*") -Destination (Join-Path $BuildDir "mpv") -Recurse -Force
    Write-Host "  OK: bundled mpv runtime files copied" -ForegroundColor Green
}

# Custom preset config created by the GUI
if (Test-Path (Join-Path $RootDir "nj-config\preset-custom.json")) {
    Copy-Item -Path (Join-Path $RootDir "nj-config\preset-custom.json") -Destination (Join-Path $BuildDir "nj-config") -Force
    Write-Host "  OK: preset-custom.json copied" -ForegroundColor Green
}

# Icon (generated by make-icon.ps1) if present
if (Test-Path (Join-Path $RootDir "nj-player.ico")) {
    Copy-Item -Path (Join-Path $RootDir "nj-player.ico") -Destination (Join-Path $BuildDir "nj-player.ico") -Force
    Write-Host "  OK: nj-player.ico copied" -ForegroundColor Green
} else {
    # No icon in the repo - generate it from make-icon.ps1 inside the build dir
    try {
        & (Join-Path $BuildDir "make-icon.ps1") | Out-Null
        if (Test-Path (Join-Path $BuildDir "nj-player.ico")) {
            Write-Host "  OK: nj-player.ico generated" -ForegroundColor Green
        } else {
            Write-Host "  [WARN] Could not generate nj-player.ico" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  [WARN] Could not generate nj-player.ico: $_" -ForegroundColor Yellow
    }
}

# Find 7-Zip for extracting archives (needed for .7z mpv builds)
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

# ============================================
# DOWNLOAD DEPENDENCIES
# ============================================
if (-not $SkipDownload) {
    Write-Host ""
    Write-Host "Downloading dependencies..." -ForegroundColor Yellow

    # ---- mpv (via GitHub API so the asset name is always current) ----
    $MpvExePath = Join-Path $BuildDir "mpv\mpv.exe"
    Write-Host "  Finding latest mpv build..." -ForegroundColor Gray
    try {
        $releaseUrl = "https://api.github.com/repos/shinchiro/mpv-winbuild-cmake/releases/latest"
        $releaseData = Invoke-RestMethod -Uri $releaseUrl -UseBasicParsing

        $mpvAsset = $null
        foreach ($asset in $releaseData.assets) {
            $name = $asset.name
            if ($name -match "mpv-x86_64-" -and $name -notmatch "v3" -and $name -notmatch "dev") {
                $mpvAsset = $asset
                break
            }
        }

        if ($mpvAsset) {
            $MpvArchive = Join-Path $BuildDir $mpvAsset.name
            Write-Host "  Downloading mpv ($($mpvAsset.name))..." -ForegroundColor Gray
            Invoke-WebRequest -Uri $mpvAsset.browser_download_url -OutFile $MpvArchive -UseBasicParsing

            if ($SevenZip) {
                & $SevenZip x $MpvArchive "-o$(Join-Path $BuildDir 'mpv')" -y | Out-Null
            } elseif ($mpvAsset.name -match '\.zip$') {
                Expand-Archive -Path $MpvArchive -DestinationPath (Join-Path $BuildDir "mpv") -Force
            } else {
                Write-Host "  [WARN] Cannot extract .7z without 7-Zip; installing 7-Zip and re-running is required." -ForegroundColor Yellow
            }
            Remove-Item $MpvArchive -Force -ErrorAction SilentlyContinue

            if (-not (Test-Path $MpvExePath)) {
                $found = Get-ChildItem -Path (Join-Path $BuildDir "mpv") -Filter "mpv.exe" -Recurse | Select-Object -First 1
                if ($found) { Copy-Item $found.FullName $MpvExePath -Force }
            }
            if (Test-Path $MpvExePath) {
                Write-Host "  OK: mpv installed" -ForegroundColor Green
            } else {
                Write-Host "  WARNING: mpv downloaded but mpv.exe not found" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  WARNING: Could not find mpv-x86_64 in latest release" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  WARNING: Failed to download mpv: $_" -ForegroundColor Yellow
    }

    # ---- yt-dlp ----
    $YtDlpUrl = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
    $YtDlpPath = Join-Path $BuildDir "mpv\yt-dlp.exe"

    Write-Host "  Downloading yt-dlp..." -ForegroundColor Gray
    try {
        Invoke-WebRequest -Uri $YtDlpUrl -OutFile $YtDlpPath -UseBasicParsing
        Write-Host "  OK: yt-dlp downloaded" -ForegroundColor Green
    } catch {
        Write-Host "  WARNING: Failed to download yt-dlp" -ForegroundColor Yellow
    }

    # ---- ffmpeg ----
    $FfmpegUrl = "https://github.com/BtbN/FFmpeg-Builds/releases/latest/download/ffmpeg-master-latest-win64-gpl.zip"
    $FfmpegZip = Join-Path $BuildDir "ffmpeg.zip"

    Write-Host "  Downloading ffmpeg..." -ForegroundColor Gray
    try {
        Invoke-WebRequest -Uri $FfmpegUrl -OutFile $FfmpegZip -UseBasicParsing
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

    # These filenames match the profiles in mpv.conf (Zabooby/mpv-config).
    $ShaderUrls = @{
        "adaptive-sharpen.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/adasharp_luma.glsl"
        "krigbilateral.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/krigbl.glsl"
        "ssimsuperres.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/ssimsr.glsl"
        "ssimdownscaler.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/ssimds.glsl"
        "ravu-z-ar-r3.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/ravu_z_ar_r3.glsl"
        "nnedi3-nns64-win8x4.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/nnedi3_nns64_win8x4.glsl"
        "nlmeans-luma.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/nlmeans_luma.glsl"
        "anime4k-restore-cnn-soft.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/A4K_Restore_CNN_Soft_M.glsl"
        "anime4k-artcnn-x2.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/Ani4Kv2_ArtCNN_C4F32_i2.glsl"
        "anime4k-clamp-highlights.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/A4K_Clamp_Highlights.glsl"
        "f8.glsl" = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/F8.glsl"
    }

    $shaderCount = 0
    $shaderTotal = $ShaderUrls.Count
    foreach ($shader in $ShaderUrls.Keys) {
        $shaderPath = Join-Path $BuildDir "shaders\$shader"

        if (-not (Test-Path $shaderPath)) {
            try {
                Write-Host "  Downloading $shader..." -ForegroundColor Gray
                Invoke-WebRequest -Uri $ShaderUrls[$shader] -OutFile $shaderPath -UseBasicParsing
                $shaderCount++
                Write-Host "  OK: $shader" -ForegroundColor Green
            } catch {
                Write-Host "  Skipped: $shader" -ForegroundColor Yellow
            }
        } else {
            $shaderCount++
            Write-Host "  OK: $shader (bundled)" -ForegroundColor Green
        }
    }

    Write-Host "  Shaders: $shaderCount/$shaderTotal installed" -ForegroundColor Gray
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
