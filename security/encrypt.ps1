# ============================================
# NJ PLAYER 3.0 — ENCRYPT FILE (Right-Click)
# ============================================

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath
)

$ErrorActionPreference = 'Stop'

# --- Paths ---
$RootDir = Split-Path -Parent $PSScriptRoot
$PythonScript = Join-Path $PSScriptRoot "gencrypt.py"

# --- Check Python ---
try {
    python --version 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Python not found"
    }
} catch {
    Write-Host "ERROR: Python required" -ForegroundColor Red
    Write-Host "Download: https://python.org/downloads" -ForegroundColor Yellow
    Write-Host "Check 'Add to PATH' during installation" -ForegroundColor Yellow
    exit 1
}

# --- Check cryptography library ---
try {
    python -c "import cryptography" 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Installing cryptography library..." -ForegroundColor Yellow
        pip install cryptography
    }
} catch {
    Write-Host "Installing cryptography library..." -ForegroundColor Yellow
    pip install cryptography
}

# --- Get password via dialog ---
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "NJ Player — Encrypt File"
$form.Size = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 15)
$form.ForeColor = [System.Drawing.Color]::White

# File label
$fileLabel = New-Object System.Windows.Forms.Label
$fileLabel.Text = "File: $(Split-Path $FilePath -Leaf)"
$fileLabel.Location = New-Object System.Drawing.Point(20, 20)
$fileLabel.Size = New-Object System.Drawing.Size(340, 20)
$fileLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 212, 255)
$form.Controls.Add($fileLabel)

# Password label
$passLabel = New-Object System.Windows.Forms.Label
$passLabel.Text = "Password:"
$passLabel.Location = New-Object System.Drawing.Point(20, 55)
$passLabel.Size = New-Object System.Drawing.Size(80, 20)
$form.Controls.Add($passLabel)

# Password input
$passInput = New-Object System.Windows.Forms.TextBox
$passInput.Location = New-Object System.Drawing.Point(100, 52)
$passInput.Size = New-Object System.Drawing.Size(260, 25)
$passInput.UseSystemPasswordChar = $true
$passInput.BackColor = [System.Drawing.Color]::FromArgb(26, 26, 36)
$passInput.ForeColor = [System.Drawing.Color]::White
$passInput.BorderStyle = "FixedSingle"
$form.Controls.Add($passInput)

# Confirm label
$confirmLabel = New-Object System.Windows.Forms.Label
$confirmLabel.Text = "Confirm:"
$confirmLabel.Location = New-Object System.Drawing.Point(20, 85)
$confirmLabel.Size = New-Object System.Drawing.Size(80, 20)
$form.Controls.Add($confirmLabel)

# Confirm input
$confirmInput = New-Object System.Windows.Forms.TextBox
$confirmInput.Location = New-Object System.Drawing.Point(100, 82)
$confirmInput.Size = New-Object System.Drawing.Size(260, 25)
$confirmInput.UseSystemPasswordChar = $true
$confirmInput.BackColor = [System.Drawing.Color]::FromArgb(26, 26, 36)
$confirmInput.ForeColor = [System.Drawing.Color]::White
$confirmInput.BorderStyle = "FixedSingle"
$form.Controls.Add($confirmInput)

# Delete original checkbox
$deleteCheck = New-Object System.Windows.Forms.CheckBox
$deleteCheck.Text = "Delete original after encryption (35-pass)"
$deleteCheck.Location = New-Object System.Drawing.Point(20, 115)
$deleteCheck.Size = New-Object System.Drawing.Size(340, 20)
$deleteCheck.ForeColor = [System.Drawing.Color]::FromArgb(176, 176, 192)
$form.Controls.Add($deleteCheck)

# Encrypt button
$encryptBtn = New-Object System.Windows.Forms.Button
$encryptBtn.Text = "ENCRYPT"
$encryptBtn.Location = New-Object System.Drawing.Point(140, 145)
$encryptBtn.Size = New-Object System.Drawing.Size(120, 30)
$encryptBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 212, 255)
$encryptBtn.ForeColor = [System.Drawing.Color]::Black
$encryptBtn.FlatStyle = "Flat"
$encryptBtn.Cursor = "Hand"
$form.Controls.Add($encryptBtn)

# Button click handler
$encryptBtn.Add_Click({
    $pass = $passInput.Text
    $confirm = $confirmInput.Text

    if ($pass.Length -lt 8) {
        [System.Windows.Forms.MessageBox]::Show(
            "Password must be at least 8 characters",
            "Weak Password",
            "OK",
            "Warning"
        )
        return
    }

    if ($pass -ne $confirm) {
        [System.Windows.Forms.MessageBox]::Show(
            "Passwords do not match",
            "Error",
            "OK",
            "Error"
        )
        return
    }

    $form.Close()

    # Build arguments and launch python directly (avoids shell injection /
    # mangled passwords that Invoke-Expression would cause).
    $argList = "`"$PythonScript`" encrypt `"$FilePath`" --password `"$pass`""
    if ($deleteCheck.Checked) {
        $argList += " --delete-original"
    }

    Write-Host "Encrypting..." -ForegroundColor Yellow
    $proc = Start-Process -FilePath "python" -ArgumentList $argList -Wait -PassThru -NoNewWindow

    if ($proc.ExitCode -eq 0) {
        Write-Host "Encryption complete!" -ForegroundColor Green
    } else {
        Write-Host "Encryption failed" -ForegroundColor Red
    }

    Start-Sleep -Seconds 2
})

$form.ShowDialog()
