#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

export GIT_PAGER="${GIT_PAGER:-cat}"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 2
  }
}

need_cmd git
need_cmd python
need_cmd codex

# Hygiene: avoid accidental env leakage changing defaults
unset PRD_FILE RULES_FILE VERIFY_CMD || true

# Token + safety discipline: never run Codex on a dirty tree
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Refusing to run Codex: working tree is dirty." >&2
  echo "Run ./scripts/verify.sh and commit/stash first." >&2
  exit 2
fi

if [[ ! -f scripts/build_prompt.py ]]; then
  echo "Missing scripts/build_prompt.py" >&2
  exit 2
fi

echo "== Codex once =="
echo "cwd=$(pwd)"
echo "prompt=python scripts/build_prompt.py | codex exec"
echo

# Non-interactive Codex usage: prompt is piped via stdin to `codex exec`.
python scripts/build_prompt.py | codex exec
