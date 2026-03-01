# RalphWSL: run commands inside WSL in ~/coding/RalphWSL.
# Usage (PowerShell):
#   .\scripts\rwsl-run.ps1 -- ./scripts/doctor.sh

$ErrorActionPreference = "Stop"

if ($args.Count -lt 1 -or $args[0] -ne "--") {
  Write-Host "Usage: .\scripts\rwsl-run.ps1 -- <command> [args...]" -ForegroundColor Yellow
  exit 2
}

$cmdArgs = $args[1..($args.Count-1)]

function Quote-Bash([string]$s) {
  return "'" + ($s -replace "'", "'\''") + "'"
}

$joined = ($cmdArgs | ForEach-Object { Quote-Bash $_ }) -join " "
$bashCmd = "set -euo pipefail; cd ~/coding/RalphWSL; $joined"

wsl --cd ~ bash -lc $bashCmd
