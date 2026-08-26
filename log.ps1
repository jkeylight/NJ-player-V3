# ============================================
# NJ PLAYER 3.0 — SHARED LOGGING HELPER
# Provides a Write-NJLog function used by the
# GUI and scripts to write errors/activity to
# logs/nj-player.log inside the app folder.
#
# Usage (dot-source, then call):
#   . "$PSScriptRoot\log.ps1"
#   Write-NJLog "Something happened"
# ============================================

# --- Deterministic path resolution ---
if ($PSScriptRoot) {
    $script:NJLogDir = Join-Path $PSScriptRoot "logs"
} elseif ($RootDir) {
    $script:NJLogDir = Join-Path $RootDir "logs"
} else {
    $script:NJLogDir = Join-Path (Get-Location) "logs"
}

$script:NJLogFile = Join-Path $script:NJLogDir "nj-player.log"

function Write-NJLog {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [ValidateSet('INFO', 'WARN', 'ERROR')]
        [string]$Level = 'INFO'
    )

    try {
        if (-not (Test-Path $script:NJLogDir)) {
            New-Item -ItemType Directory -Path $script:NJLogDir -Force | Out-Null
        }

        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $line = "[$timestamp] [$Level] $Message"
        Add-Content -Path $script:NJLogFile -Value $line -Encoding UTF8
    } catch {
        # Logging must never break the app.
    }
}

# Convenient wrappers
function Write-NJError {
    param([string]$Message)
    Write-NJLog -Message $Message -Level 'ERROR'
}

function Write-NJWarn {
    param([string]$Message)
    Write-NJLog -Message $Message -Level 'WARN'
}
