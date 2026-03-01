#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/ralph.sh [--once] [--codex] [--help]

A learning-first, WSL-canonical runner entrypoint.

Modes:
  --once   Run verification once and exit (default behavior).
  --codex  If the working tree is clean, run Codex once via stdin piping, then verify.
           If the tree is dirty, do NOT run Codex; verify only.

Environment:
  PRD_FILE    Path to PRD JSON (default: ralph/prd.json)
  RULES_FILE  Path to rules markdown (default: ralph/rules.md)
  VERIFY_CMD  Verification command (default: scripts/verify.sh)

Notes:
  - No eval. Strict bash.
  - Codex usage is non-interactive: build_prompt.py | codex exec (stdin).
  - Token conservation: if the working tree is dirty, we do NOT call Codex.
USAGE
}

ONCE=0
MODE="once"
DO_CODEX=0

case "${1:-}" in
  --help|-h)
    usage
    exit 0
    ;;
  --once|"")
    ONCE=1
    ;;
  --codex)
    ONCE=1
    DO_CODEX=1
    ;;
  *)
    echo "Unexpected argument. Use --help." >&2
    exit 2
    ;;
esac

if [[ $# -gt 1 ]]; then
  echo "Unexpected arguments. Use --help." >&2
  exit 2
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

PRD_FILE="${PRD_FILE:-ralph/prd.json}"
RULES_FILE="${RULES_FILE:-ralph/rules.md}"
VERIFY_CMD="${VERIFY_CMD:-scripts/verify.sh}"

# Noob safety: ignore leaked env vars that point into .codex/ or missing paths.
sanitize_path() {
  local name="$1"
  local val="${!name:-}"
  local fallback="$2"
  if [[ -z "$val" ]]; then
    printf -v "$name" "%s" "$fallback"
    return 0
  fi
  if [[ "$val" == .codex/* || "$val" == */.codex/* || ! -f "$val" ]]; then
    echo "WARN: $name was set to an unsafe/missing path ($val); resetting to $fallback" >&2
    printf -v "$name" "%s" "$fallback"
  fi
}

sanitize_path PRD_FILE "ralph/prd.json"
sanitize_path RULES_FILE "ralph/rules.md"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 2
  }
run_newchat() {
  scripts/newchat.sh
}

run_codex_dry_run() {
  # Same gates as real codex run, but never calls codex.
  need_cmd codex
  if dirty_tree; then
    echo "DRY-RUN: would NOT run Codex because working tree is dirty."
    return 2
  fi
  if [[ ! -f scripts/build_prompt.py ]]; then
    echo "DRY-RUN: missing scripts/build_prompt.py"
    return 2
  fi
  echo "DRY-RUN: would run:"
  echo "  python scripts/build_prompt.py | codex exec"
  echo
  echo "DRY-RUN: prompt preview (first 25 lines):"
  python scripts/build_prompt.py | sed -n '1,25p'
}

}

need_cmd git
need_cmd python

if [[ ! -f "$PRD_FILE" ]]; then
  # Learning-first: print active config before failing.
  echo "RalphWSL runner initialized."
  echo "PRD_FILE=$PRD_FILE"
  echo "RULES_FILE=$RULES_FILE"
  echo "VERIFY_CMD=$VERIFY_CMD"

if [[ "$MODE" == "newchat" ]]; then
  run_newchat
  exit 0
fi

if [[ "$MODE" == "codex_dry_run" ]]; then
  run_codex_dry_run
  exit $?
fi

  echo "PRD_FILE not found: $PRD_FILE" >&2
  exit 2
fi

run_verify() {
  # Safe execution: parse VERIFY_CMD without invoking a shell. No eval.
  VERIFY_CMD="$VERIFY_CMD" python - <<'PY'
import os, shlex, subprocess, sys
cmd = os.environ.get("VERIFY_CMD", "").strip()
if not cmd:
    print("VERIFY_CMD is empty", file=sys.stderr)
    raise SystemExit(2)
args = shlex.split(cmd)
try:
    p = subprocess.run(args, check=False)
    raise SystemExit(p.returncode)
except FileNotFoundError:
    print(f"VERIFY_CMD executable not found: {args[0]}", file=sys.stderr)
    raise SystemExit(2)
PY
}

dirty_tree() {
  ! git diff --quiet || ! git diff --cached --quiet
}

run_codex_once() {
  scripts/codex_once.sh
  return $?

  # (legacy path below, kept intentionally unreachable)


  if [[ ! -f scripts/build_prompt.py ]]; then
    echo "Missing scripts/build_prompt.py (required for --codex)" >&2
    exit 2
  fi

  # Non-interactive Codex execution: prompt is piped via stdin.
  PRD_FILE="$PRD_FILE" RULES_FILE="$RULES_FILE" python scripts/build_prompt.py | codex exec
}

echo "RalphWSL runner initialized."
echo "PRD_FILE=$PRD_FILE"
echo "RULES_FILE=$RULES_FILE"
echo "VERIFY_CMD=$VERIFY_CMD"

if [[ "$MODE" == "newchat" ]]; then
  run_newchat
  exit 0
fi

if [[ "$MODE" == "codex_dry_run" ]]; then
  run_codex_dry_run
  exit $?
fi


# Token + safety discipline: never run Codex on a dirty tree.
if dirty_tree; then
  echo "Working tree is dirty. Running verification only (no Codex)."
  run_verify
  exit $?
fi

if [[ "$DO_CODEX" -eq 1 ]]; then
  run_codex_once
fi

run_verify
exit $?
