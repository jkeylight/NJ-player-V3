# ============================================
# NJ PLAYER 3.0 — SHADER UPDATER
# Fetches the latest enhancement shaders from
# Zabooby/mpv-config and refreshes the local
# shaders/ folder so presets improve over time.
# ============================================

param(
    [switch]$Force
)

$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

$RootDir = $PSScriptRoot
$ShaderDir = Join-Path $RootDir "shaders"

Write-Host ""
Write-Host "NJ Player 3.0 — Shader Updater" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $ShaderDir)) {
    New-Item -ItemType Directory -Path $ShaderDir -Force | Out-Null
    Write-Host "  Created $ShaderDir" -ForegroundColor Gray
}

# These filenames match the profiles in mpv.conf.
$ShaderUrls = @{
    "adaptive-sharpen.glsl"          = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/adasharp_luma.glsl"
    "krigbilateral.glsl"             = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/krigbl.glsl"
    "ssimsuperres.glsl"              = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/ssimsr.glsl"
    "ssimdownscaler.glsl"            = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/ssimds.glsl"
    "ravu-z-ar-r3.glsl"              = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/ravu_z_ar_r3.glsl"
    "nnedi3-nns64-win8x4.glsl"       = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/nnedi3_nns64_win8x4.glsl"
    "nlmeans-luma.glsl"              = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/nlmeans_luma.glsl"
    "anime4k-restore-cnn-soft.glsl"  = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/A4K_Restore_CNN_Soft_M.glsl"
    "anime4k-artcnn-x2.glsl"         = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/Ani4Kv2_ArtCNN_C4F32_i2.glsl"
    "anime4k-clamp-highlights.glsl"  = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/A4K_Clamp_Highlights.glsl"
    "f8.glsl"                        = "https://raw.githubusercontent.com/Zabooby/mpv-config/main/portable_config/shaders/F8.glsl"
}

$updated = 0
$skipped = 0
$total = $ShaderUrls.Count

foreach ($shader in $ShaderUrls.Keys) {
    $dest = Join-Path $ShaderDir $shader

    try {
        $fetch = Invoke-WebRequest -Uri $ShaderUrls[$shader] -UseBasicParsing

        # Compare content length (a lightweight change signal) unless -Force.
        $changed = -not (Test-Path $dest) -or (Get-Item $dest).Length -ne $fetch.RawContentLength

        if ($changed -or $Force) {
            Invoke-WebRequest -Uri $ShaderUrls[$shader] -OutFile $dest -UseBasicParsing
            $updated++
            Write-Host "  [OK] Updated: $shader" -ForegroundColor Green
        } else {
            $skipped++
            Write-Host "  [OK] Unchanged: $shader" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  [FAIL] $shader - download failed: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "  Result: $updated updated, $skipped unchanged, $total total" -ForegroundColor Yellow

if ($updated -gt 0) {
    Write-Host "  Restart NJ Player for shader changes to take effect." -ForegroundColor Gray
}

Write-Host ""
Write-Host "Shader update complete!" -ForegroundColor Cyan
Write-Host ""
