#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

PRD_FILE="${PRD_FILE:-ralph/prd.json}"
RULES_FILE="${RULES_FILE:-ralph/rules.md}"
VERIFY_CMD="${VERIFY_CMD:-scripts/verify.sh}"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 2
  }
}

need_cmd git
need_cmd codex
need_cmd python

if [[ ! -f "$PRD_FILE" ]]; then
  echo "PRD_FILE not found: $PRD_FILE" >&2
  exit 2
fi

echo "RalphWSL runner initialized."
echo "PRD_FILE=$PRD_FILE"
echo "RULES_FILE=$RULES_FILE"
echo "VERIFY_CMD=$VERIFY_CMD"

# Story S1 skeleton:
# - No project-specific assumptions
# - No eval
# - Non-interactive codex usage will be added next step

exit 0
