#!/usr/bin/env bash
set -euo pipefail

echo "== RalphWSL doctor =="

# Detect environment
if grep -qi microsoft /proc/version 2>/dev/null; then
  ENVIRONMENT="WSL"
else
  ENVIRONMENT="Linux"
fi

echo
echo "== Environment =="
echo "Detected: $ENVIRONMENT"
echo "pwd=$(pwd)"
echo "user=$(whoami)"
echo "uname=$(uname -sr)"

# Guard: prevent PowerShell paste inside WSL
if [[ "${PSModulePath:-}" != "" ]]; then
  echo
  echo "WARNING: PowerShell environment variables detected."
  echo "You may be mixing shells."
fi

# Detect common PowerShell paste patterns in history (best-effort)
if history 2>/dev/null | grep -E '\$ErrorActionPreference|Write-Host|@'\''|powershell' >/dev/null 2>&1; then
  echo
  echo "WARNING: It looks like PowerShell syntax was pasted into WSL."
  echo "If your prompt starts with sven@...$, paste BASH blocks only."
fi

echo
echo "== Tooling =="
for cmd in git python codex; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "OK: $cmd -> $(command -v "$cmd")"
  else
    echo "MISSING: $cmd"
  fi
done

echo
echo "== Repo sanity =="
for f in ralph/prd.json ralph/rules.md scripts/ralph.sh scripts/verify.sh; do
  if [[ -f "$f" ]]; then
    echo "OK: $f"
  else
    echo "MISSING: $f"
  fi
done

echo

echo
echo "== Env safety check =="

unsafe=0

if [[ "${PRD_FILE:-}" == .codex/* ]]; then
  echo "WARNING: Unsafe PRD_FILE override detected: $PRD_FILE"
  unsafe=1
fi

if [[ "${RULES_FILE:-}" == .codex/* ]]; then
  echo "WARNING: Unsafe RULES_FILE override detected: $RULES_FILE"
  unsafe=1
fi

if [[ "$unsafe" -eq 1 ]]; then
  echo "These overrides are ignored by ralph.sh for safety."
  echo "You can clear them with:"
  echo "  unset PRD_FILE RULES_FILE VERIFY_CMD"
fi

echo "== Env (relevant) =="
echo "PRD_FILE=${PRD_FILE:-<unset>}"
echo "RULES_FILE=${RULES_FILE:-<unset>}"
echo "VERIFY_CMD=${VERIFY_CMD:-<unset>}"

echo
echo "== Git status (short) =="
git status --short || true

echo
echo "== Verify =="
if [[ -x ./scripts/verify.sh ]]; then
  ./scripts/verify.sh || true
else
  echo "verify.sh not executable or missing"
fi

echo
echo "Doctor complete."
