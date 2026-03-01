#!/usr/bin/env bash
set -euo pipefail

# Minimal verification that is portable and cheap.
bash -n scripts/ralph.sh

python - <<'PY'
import json
from pathlib import Path
p = Path("ralph/prd.json")
json.loads(p.read_text(encoding="utf-8"))
print("PASS: ralph/prd.json parses")
PY
