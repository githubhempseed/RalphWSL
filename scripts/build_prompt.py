#!/usr/bin/env python3
from __future__ import annotations

import json
import os
from pathlib import Path


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _read_json(path: Path) -> dict:
    return json.loads(_read_text(path))


def _next_pending_story(prd: dict) -> dict | None:
    for s in prd.get("stories", []):
        if not s.get("passes"):
            return s
    return None


def main() -> int:
    prd_file = Path(os.environ.get("PRD_FILE", "ralph/prd.json"))
    rules_file = Path(os.environ.get("RULES_FILE", "ralph/rules.md"))

    prd = _read_json(prd_file)
    story = _next_pending_story(prd)

    rules = ""
    if rules_file.exists():
        rules = _read_text(rules_file).strip()

    # Token-minimal prompt: keep it short and precise.
    # The runner enforces: no eval, strict bash, no push, WSL canonical.
    lines: list[str] = []
    lines.append("You are implementing the next pending story for this repo.")
    lines.append("")
    lines.append("Hard requirements:")
    lines.append("- WSL/Linux under ~/coding is canonical.")
    lines.append("- Codex CLI must be non-interactive via stdin to `codex exec`.")
    lines.append("- Strict bash: set -euo pipefail. No eval.")
    lines.append("- Never commit artifacts (.logs/, .codex/, .tmp/, zips, caches).")
    lines.append("- No push. Human approval required.")
    lines.append("")
    if rules:
        # Keep rules bounded to avoid prompt bloat.
        rules_snip = rules
        if len(rules_snip) > 2000:
            rules_snip = rules_snip[:2000] + "\n... (truncated)\n"
        lines.append("Repo rules (excerpt):")
        lines.append(rules_snip)
        lines.append("")

    if story is None:
        lines.append("No pending stories. Do not change anything. Explain what you checked.")
        print("\n".join(lines))
        return 0

    # Keep story compact: id + title + any extra fields present.
    lines.append("Story to implement (JSON):")
    lines.append(json.dumps(story, indent=2, ensure_ascii=False))
    lines.append("")
    lines.append("Guidance:")
    lines.append("- Make the smallest safe change that advances this story.")
    lines.append("- After changes: run repo verification (VERIFY_CMD) and ensure it passes.")
    lines.append("- If the story is completed, update ralph/prd.json to mark it passes=true.")
    lines.append("")
    lines.append("Now implement.")
    print("\n".join(lines))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
