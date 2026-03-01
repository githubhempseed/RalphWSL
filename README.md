# RalphWSL

RalphWSL is a WSL-first automation loop (“Ralph runner”) built specifically for OpenAI Codex CLI.

It runs implementation stories from a PRD file in a deterministic, reviewable loop:

1. Select next incomplete story
2. Build prompt from global rules + story
3. Invoke `codex exec` non-interactively (stdin)
4. Run verification command
5. On success, mark story passed and prepare commit
6. Human reviews before push

## Design Principles

- WSL/Linux is canonical environment
- No interactive Codex usage (batch only)
- Clean, reviewable Git history
- No artifact pollution in repo
- Configurable verification commands
- Human remains in control

## Non-Goals

- Not agent-agnostic (Codex CLI focused)
- Not a SaaS product
- Not Windows-native

## Philosophy

Automation should amplify developers — not replace them.

This project prioritizes:
- Local-first workflows
- Portability
- Clean version control practices
- Minimal platform lock-in