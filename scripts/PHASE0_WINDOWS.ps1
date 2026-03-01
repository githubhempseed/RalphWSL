# RalphWSL Phase 0 (Windows): get a total beginner to a working WSL + Ubuntu + Python + git + ~/coding
# Run from Windows PowerShell:
#   powershell -ExecutionPolicy Bypass -File .\scripts\phase0.ps1
#
# Notes:
# - Some steps may require a reboot.
# - The very first Ubuntu launch may ask the user to create a Linux username/password.
# - This script avoids assuming the user starts in WSL.

$ErrorActionPreference = "Stop"

Write-Host "== RalphWSL Phase 0: Windows -> WSL readiness =="

function Has-Command($name) {
  return $null -ne (Get-Command $name -ErrorAction SilentlyContinue)
}

if (-not (Has-Command "wsl")) {
  Write-Host "ERROR: 'wsl' command not found."
  Write-Host "This Windows installation does not have WSL available/enabled."
  Write-Host "If you're on Windows 10/11, enable WSL and try again."
  exit 2
}

# Detect WSL state
$wslStatus = & wsl --status 2>$null
if ($LASTEXITCODE -ne 0) {
  Write-Host "WSL appears not initialized. Attempting: wsl --install -d Ubuntu"
  Write-Host "If prompted, reboot Windows, then re-run this script."
  & wsl --install -d Ubuntu
  exit 0
}

# Ensure at least one distro exists
$distroList = & wsl -l -q 2>$null
if ($LASTEXITCODE -ne 0 -or -not $distroList -or $distroList.Count -eq 0) {
  Write-Host "No WSL distros found. Attempting: wsl --install -d Ubuntu"
  Write-Host "If prompted, reboot Windows, then re-run this script."
  & wsl --install -d Ubuntu
  exit 0
}

Write-Host "Found WSL distro(s):"
$distroList | ForEach-Object { Write-Host "  - $_" }

# Pick Ubuntu if present, else default
$targetDistro = $null
foreach ($d in $distroList) {
  if ($d -match "Ubuntu") { $targetDistro = $d; break }
}
if (-not $targetDistro) { $targetDistro = $distroList[0] }

Write-Host ""
Write-Host "Using distro: $targetDistro"

# Important: first-time Ubuntu launch requires interactive username/password setup.
# We can't automate that. We detect it by trying a non-interactive command first.
Write-Host ""
Write-Host "Checking whether the distro is initialized..."
& wsl -d $targetDistro -- bash -lc "echo WSL_READY; whoami; true" 2>$null
if ($LASTEXITCODE -ne 0) {
  Write-Host ""
  Write-Host "Ubuntu likely needs first-run initialization (create Linux user/password)."
  Write-Host "Launching Ubuntu now. Complete the prompts, then close the window and re-run Phase 0."
  Write-Host ""
  & wsl -d $targetDistro
  exit 0
}

Write-Host ""
Write-Host "Updating Ubuntu packages and installing prerequisites (git, python3, pip)..."
$payload = @'
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo "== Inside WSL =="

# Update + install
sudo apt-get update -y
sudo apt-get install -y git python3 python3-pip

# Canonical workspace
mkdir -p ~/coding

echo
echo "== WSL readiness complete =="
echo "Linux user: $(whoami)"
echo "Python: $(python3 --version)"
echo "Git: $(git --version)"
echo "Canonical workspace: ~/coding"
echo
echo "Next:"
echo "  cd ~/coding"
echo "  # clone RalphWSL into ~/coding/RalphWSL (or copy it there)"
echo "  # then run:"
echo "  cd ~/coding/RalphWSL"
echo "  ./scripts/verify.sh"
echo "  ./scripts/ralph.sh --once"
'@

# Run inside the distro
& wsl -d $targetDistro -- bash -lc $payload
if ($LASTEXITCODE -ne 0) {
  Write-Host "ERROR: WSL setup commands failed. Re-run this script after fixing the issue."
  exit 2
}

Write-Host ""
Write-Host "Phase 0 complete."
