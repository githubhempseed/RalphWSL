#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

export GIT_PAGER="${GIT_PAGER:-cat}"

VERIFY_CMD="${VERIFY_CMD:-scripts/verify.sh}"

echo "== Preflight: git status =="
git status

echo
echo "== Preflight: git diff --stat =="
git diff --stat

echo
echo "== Preflight: git diff =="
git diff

echo
echo "== Preflight: verification summary =="
# Run verify without eval/shell expansion. Keep it simple and repo-owned.
if [[ "$VERIFY_CMD" == "scripts/verify.sh" ]]; then
  scripts/verify.sh
else
  echo "VERIFY_CMD is set to a non-default value:"
  echo "  VERIFY_CMD=$VERIFY_CMD"
  echo "For safety, this preflight only runs the default scripts/verify.sh"
  echo "Unset VERIFY_CMD or set it to scripts/verify.sh to run verification here."
  exit 2
fi

echo
echo "== Preflight complete (no push performed) =="
