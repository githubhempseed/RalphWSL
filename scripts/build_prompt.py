#!/usr/bin/env python3
import json
import os
from pathlib import Path


def sanitize_path(env_name: str, fallback: str) -> Path:
    val = os.environ.get(env_name, "").strip()
    # Ignore leaked .codex paths and missing files; use repo defaults.
    if (not val) or val.startswith(".codex/") or "/.codex/" in val:
        return Path(fallback)
    p = Path(val)
    if env_name in ("PRD_FILE", "RULES_FILE") and not p.exists():
        return Path(fallback)
    return p

MAX_RULES_CHARS = 1500  # keep prompts small

def main() -> None:
    prd_file = sanitize_path("PRD_FILE", "ralph/prd.json")
    rules_file = sanitize_path("RULES_FILE", "ralph/rules.md")

    prd = json.loads(prd_file.read_text(encoding="utf-8"))

    story = None
    for s in prd.get("stories", []):
        if not s.get("passes"):
            story = s
            break

    rules = ""
    if rules_file.exists():
        rules = rules_file.read_text(encoding="utf-8")
        rules = rules[:MAX_RULES_CHARS]

    lines = []
    lines.append("Implement the next pending story for this repo.")
    lines.append("")
    lines.append("Hard requirements:")
    lines.append("- WSL/Linux under ~/coding is canonical.")
    lines.append("- Codex CLI must be non-interactive via stdin to `codex exec`.")
    lines.append("- Strict bash: set -euo pipefail. No eval.")
    lines.append("- Never commit artifacts (.logs/, .codex/, .tmp/, zips, caches).")
    lines.append("- No push. Human approval required.")
    lines.append("")
    if rules:
        lines.append("Repo rules (excerpt):")
        lines.append(rules)
        lines.append("")
    if story:
        lines.append("Story (JSON):")
        lines.append(json.dumps(story, ensure_ascii=False))
    else:
        lines.append("No pending stories. Do not change anything; explain what you checked.")

    print("\n".join(lines))

if __name__ == "__main__":
    main()
