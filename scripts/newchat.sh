#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

export GIT_PAGER="${GIT_PAGER:-cat}"

echo "=== RalphWSL: NEW CHAT HANDOFF ==="
echo "Paste this into a new chat."
echo
echo "Context:"
echo "- Repo: $(pwd)"
echo "- Branch: $(git rev-parse --abbrev-ref HEAD)"
echo "- Ahead/behind: $(git rev-list --left-right --count origin/main...HEAD 2>/dev/null || echo 'origin unknown')"
echo "- Time: $(date -Is)"
echo

echo "Doctor:"
if [[ -x scripts/doctor.sh ]]; then
  scripts/doctor.sh
else
  echo "MISSING: scripts/doctor.sh"
fi
echo

echo "Git status:"
git status
echo

echo "Recent commits (top 15):"
git --no-pager log --oneline -n 15
echo

echo "PRD (pending story):"
python - <<'PY'
import json
from pathlib import Path
prd = json.loads(Path("ralph/prd.json").read_text(encoding="utf-8"))
pending = None
for s in prd.get("stories", []):
    if not s.get("passes"):
        pending = s
        break
print(pending if pending else "No pending stories")
PY
echo

echo "Next commands:"
echo "- ./scripts/verify.sh"
echo "- ./scripts/ralph.sh --codex-dry-run   # proves it would run (no Codex call)"
echo "- (When ready) ./scripts/ralph.sh --codex"
