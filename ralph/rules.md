# RalphWSL Rules

- WSL/Linux under `~/coding` is canonical.
- Codex CLI must be non-interactive via stdin to `codex exec`.
- Strict bash. `set -euo pipefail`. No `eval`.
- Never commit artifacts: `.logs/`, `.codex/`, `.tmp/`, caches, zips.
- No push without: `git status`, `git diff --stat`, `git diff`, verification summary.
