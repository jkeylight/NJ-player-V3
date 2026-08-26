# ============================================
# NJ PLAYER 3.0 — ICON GENERATOR
# Draws the NJ Player logo at multiple sizes
# ============================================

Add-Type -AssemblyName System.Drawing

$RootDir = $PSScriptRoot
$IconPath = Join-Path $RootDir "nj-player.ico"

Write-Host ""
Write-Host "NJ Player 3.0 — Icon Generator" -ForegroundColor Cyan
Write-Host ""

# Icon sizes (standard Windows icon sizes)
$sizes = @(16, 24, 32, 48, 64, 128, 256)

# Colors
$BgColor = [System.Drawing.Color]::FromArgb(10, 10, 15)      # Dark background
$AccentColor = [System.Drawing.Color]::FromArgb(0, 212, 255)  # Cyan accent
$TextColor = [System.Drawing.Color]::FromArgb(255, 255, 255)  # White text

# Create temp directory for icon generation
$tempDir = Join-Path $env:TEMP "nj-player-icon"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
}

$iconFiles = @()

foreach ($size in $sizes) {
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($bmp)
    
    # Enable anti-aliasing
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
    
    # Fill background
    $graphics.Clear($BgColor)
    
    # Draw rounded rectangle background
    $brush = New-Object System.Drawing.SolidBrush($BgColor)
    $pen = New-Object System.Drawing.Pen($AccentColor, 2)
    
    $rect = New-Object System.Drawing.Rectangle(1, 1, ($size - 2), ($size - 2))
    $graphics.FillRectangle($brush, $rect)
    $graphics.DrawRectangle($pen, $rect)
    
    # Draw play button (triangle)
    $playBrush = New-Object System.Drawing.SolidBrush($AccentColor)
    $margin = $size * 0.25
    $points = @(
        (New-Object System.Drawing.PointF($margin, $margin)),
        (New-Object System.Drawing.PointF($margin, ($size - $margin))),
        (New-Object System.Drawing.PointF(($size - $margin), ($size / 2)))
    )
    $graphics.FillPolygon($playBrush, $points)
    
    # Draw "NJ" text below play button (for larger icons)
    if ($size -ge 48) {
        $fontSize = $size * 0.2
        $font = New-Object System.Drawing.Font("Segoe UI", $fontSize, [System.Drawing.FontStyle]::Bold)
        $textBrush = New-Object System.Drawing.SolidBrush($TextColor)
        
        $text = "NJ"
        $textSize = $graphics.MeasureString($text, $font)
        $textX = ($size - $textSize.Width) / 2
        $textY = $size * 0.75
        
        $graphics.DrawString($text, $font, $textBrush, $textX, $textY)
    }
    
    # Save as PNG
    $pngPath = Join-Path $tempDir "icon_${size}.png"
    $bmp.Save($pngPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $iconFiles += $pngPath
    
    $graphics.Dispose()
    $bmp.Dispose()
    
    Write-Host "  ✓ Generated ${size}x${size} icon" -ForegroundColor Green
}

# Combine into .ico file
# Note: Creating a proper .ico file requires binary manipulation
# For simplicity, we'll create a basic .ico file

Write-Host ""
Write-Host "  Creating .ico file..." -ForegroundColor Yellow

# Create a simple .ico file (header + PNG data)
# This is a simplified version - in production, use a proper icon library

$icoHeader = New-Object System.IO.MemoryStream
$writer = New-Object System.IO.BinaryWriter($icoHeader)

# ICO header
$writer.Write([System.UInt16]0)      # Reserved
$writer.Write([System.UInt16]1)      # Type (1 = ICO)
$writer.Write([System.UInt16]($iconFiles.Count))  # Number of images

# Directory entries + running image data offset
$dirEntrySize = 16
$runningOffset = 6 + ($dirEntrySize * $iconFiles.Count)

foreach ($pngPath in $iconFiles) {
    $pngData = [System.IO.File]::ReadAllBytes($pngPath)
    # Extract the numeric size from "icon_<size>.png"
    $size = [int]([System.IO.Path]::GetFileNameWithoutExtension($pngPath) -replace 'icon_', '')

    # In the ICO format, a width/height byte of 0 means 256 pixels
    $dimByte = if ($size -ge 256) { 0 } else { $size }

    # ICO directory entry (16 bytes)
    $writer.Write([System.Byte]$dimByte)             # Width
    $writer.Write([System.Byte]$dimByte)             # Height
    $writer.Write([System.Byte]0)                    # Color palette
    $writer.Write([System.Byte]0)                    # Reserved
    $writer.Write([System.UInt16]1)                  # Color planes
    $writer.Write([System.UInt16]32)                 # Bits per pixel
    $writer.Write([System.UInt32]$pngData.Length)    # Image size
    $writer.Write([System.UInt32]$runningOffset)     # Image offset

    $runningOffset += $pngData.Length
}

# Write PNG image data (in the same order as the directory entries)
foreach ($pngPath in $iconFiles) {
    $pngData = [System.IO.File]::ReadAllBytes($pngPath)
    $writer.Write($pngData)
}

# Save .ico file
$icoData = $icoHeader.ToArray()
[System.IO.File]::WriteAllBytes($IconPath, $icoData)

Write-Host "  ✓ Icon saved: $IconPath" -ForegroundColor Green

# Cleanup temp files
foreach ($pngPath in $iconFiles) {
    Remove-Item -Path $pngPath -Force
}
Remove-Item -Path $tempDir -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Icon generation complete!" -ForegroundColor Cyan
Write-Host ""
