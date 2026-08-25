# ============================================
# NJ PLAYER 3.0 — DECRYPT & PLAY
# ============================================

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath
)

$ErrorActionPreference = 'Stop'

# --- Paths ---
$RootDir = Split-Path -Parent $PSScriptRoot
$PythonScript = Join-Path $PSScriptRoot "gencrypt.py"
$PlayerScript = Join-Path $RootDir "NJ-Player.bat"

# --- Get password ---
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "NJ Player — Decrypt & Play"
$form.Size = New-Object System.Drawing.Size(380, 180)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 15)
$form.ForeColor = [System.Drawing.Color]::White

# Icon label
$iconLabel = New-Object System.Windows.Forms.Label
$iconLabel.Text = "🔒"
$iconLabel.Location = New-Object System.Drawing.Point(20, 20)
$iconLabel.Size = New-Object System.Drawing.Size(40, 40)
$iconLabel.Font = New-Object System.Drawing.Font("Segoe UI", 24)
$form.Controls.Add($iconLabel)

# Title label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Encrypted Video"
$titleLabel.Location = New-Object System.Drawing.Point(70, 20)
$titleLabel.Size = New-Object System.Drawing.Size(280, 25)
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($titleLabel)

# File label
$fileLabel = New-Object System.Windows.Forms.Label
$fileLabel.Text = Split-Path $FilePath -Leaf
$fileLabel.Location = New-Object System.Drawing.Point(70, 45)
$fileLabel.Size = New-Object System.Drawing.Size(280, 20)
$fileLabel.ForeColor = [System.Drawing.Color]::FromArgb(176, 176, 192)
$form.Controls.Add($fileLabel)

# Password input
$passInput = New-Object System.Windows.Forms.TextBox
$passInput.Location = New-Object System.Drawing.Point(70, 75)
$passInput.Size = New-Object System.Drawing.Size(270, 25)
$passInput.UseSystemPasswordChar = $true
$passInput.PlaceholderText = "Enter password..."
$passInput.BackColor = [System.Drawing.Color]::FromArgb(26, 26, 36)
$passInput.ForeColor = [System.Drawing.Color]::White
$passInput.BorderStyle = "FixedSingle"
$form.Controls.Add($passInput)

# Buttons
$playBtn = New-Object System.Windows.Forms.Button
$playBtn.Text = "DECRYPT & PLAY"
$playBtn.Location = New-Object System.Drawing.Point(70, 110)
$playBtn.Size = New-Object System.Drawing.Size(130, 30)
$playBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 212, 255)
$playBtn.ForeColor = [System.Drawing.Color]::Black
$playBtn.FlatStyle = "Flat"
$playBtn.Cursor = "Hand"
$form.Controls.Add($playBtn)

$cancelBtn = New-Object System.Windows.Forms.Button
$cancelBtn.Text = "CANCEL"
$cancelBtn.Location = New-Object System.Drawing.Point(210, 110)
$cancelBtn.Size = New-Object System.Drawing.Size(130, 30)
$cancelBtn.BackColor = [System.Drawing.Color]::FromArgb(26, 26, 36)
$cancelBtn.ForeColor = [System.Drawing.Color]::White
$cancelBtn.FlatStyle = "Flat"
$cancelBtn.Cursor = "Hand"
$form.Controls.Add($cancelBtn)

$cancelBtn.Add_Click({
    $form.Close()
})

$playBtn.Add_Click({
    $pass = $passInput.Text

    if ($pass.Length -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a password", "Error", "OK", "Error")
        return
    }

    $form.Close()

    # Decrypt to temp
    $tempDir = Join-Path $env:TEMP "nj-player-temp"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    $tempFile = Join-Path $tempDir "decrypted_video.mp4"

    Write-Host "Decrypting..." -ForegroundColor Yellow
    $cmd = "python `"$PythonScript`" decrypt `"$FilePath`" --password `"$pass`" --output `"$tempFile`""
    Invoke-Expression $cmd

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Playing..." -ForegroundColor Green
        # Play with NJ Player
        & $PlayerScript $tempFile

        # Secure delete after playback
        Write-Host "Shredding temp file..." -ForegroundColor Yellow
        $shredCmd = "python `"$PythonScript`" shred `"$tempFile`" --passes 35"
        Invoke-Expression $shredCmd
    } else {
        Write-Host "Decryption failed — wrong password?" -ForegroundColor Red
        Start-Sleep -Seconds 3
    }
})

$form.ShowDialog()
