#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

export GIT_PAGER="${GIT_PAGER:-cat}"

echo "== RalphWSL doctor =="
echo "pwd=$(pwd)"
echo "user=$(whoami)"
echo "uname=$(uname -sr)"
echo "home=$HOME"
echo

echo "== Commands =="
for c in git python python3 codex; do
  if command -v "$c" >/dev/null 2>&1; then
    echo "OK: $c -> $(command -v "$c")"
  else
    echo "MISSING: $c"
  fi
done
echo

echo "== Repo files =="
for f in ralph/prd.json ralph/rules.md scripts/ralph.sh scripts/verify.sh; do
  if [[ -f "$f" ]]; then
    echo "OK: $f"
  else
    echo "MISSING: $f"
  fi
done
echo

echo "== Git state (no pager) =="
git status
echo

echo "== Verification =="
./scripts/verify.sh
echo

echo "Doctor tips:"
echo "- If you started in /mnt/*, always: cd ~/coding/RalphWSL"
echo "- Phase 0 (Windows beginners): scripts\\PHASE0_WINDOWS.cmd"
echo "- Next: ./scripts/ralph.sh --once"
