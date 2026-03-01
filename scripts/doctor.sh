#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

export GIT_PAGER="${GIT_PAGER:-cat}"

echo "== RalphWSL doctor =="
echo "pwd=$(pwd)"
echo "user=$(whoami)"
echo "uname=$(uname -sr)"
echo

echo "== Tooling =="
for c in git python codex; do
  if command -v "$c" >/dev/null 2>&1; then
    echo "OK: $c -> $(command -v "$c")"
  else
    echo "MISSING: $c"
  fi
done
echo

echo "== Repo sanity =="
for f in ralph/prd.json ralph/rules.md scripts/ralph.sh scripts/verify.sh; do
  [[ -f "$f" ]] && echo "OK: $f" || echo "MISSING: $f"
done
echo

echo "== Env (relevant) =="
echo "PRD_FILE=${PRD_FILE-<unset>}"
echo "RULES_FILE=${RULES_FILE-<unset>}"
echo "VERIFY_CMD=${VERIFY_CMD-<unset>}"
echo

echo "== Git status =="
git status
echo

echo "== Verify =="
./scripts/verify.sh
