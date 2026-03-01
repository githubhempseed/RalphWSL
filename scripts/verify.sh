#!/usr/bin/env bash
set -euo pipefail

# Minimal verification for the runner itself.
bash -n scripts/ralph.sh

# Optional: add more checks later (shellcheck, json parse smoke, --help output)
python - <<'PY'
import json
from pathlib import Path
p = Path("ralph/prd.json")
json.loads(p.read_text(encoding="utf-8"))
print("PASS: ralph/prd.json parses")
PY
