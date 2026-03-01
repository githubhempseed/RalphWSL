#!/usr/bin/env bash
set -euo pipefail

# Minimal verification that is portable and cheap.
bash -n scripts/ralph.sh
bash -n scripts/newchat.sh
bash -n scripts/codex_once.sh 2>/dev/null || true

python - <<'PY'
import json
from pathlib import Path
p = Path("ralph/prd.json")
json.loads(p.read_text(encoding="utf-8"))
print("PASS: ralph/prd.json parses")
PY
