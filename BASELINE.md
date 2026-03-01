# RalphWSL – Baseline

## Project Intent

RalphWSL is a WSL-first, safety-hardened story-driven automation loop
built around non-interactive Codex CLI execution.

Its purpose is to:

- Provide deterministic, repeatable implementation loops.
- Maintain a clean separation between product code and automation tooling.
- Enforce disciplined Git hygiene and human approval.
- Operate safely under Linux/WSL as the canonical environment.
- Remain portable, transparent, and anti-lock-in.

This project is infrastructure-first.  
It is designed to outlive any specific product repository.

---

## Core Philosophy

### 1. WSL Is Canonical

All automation runs inside WSL under `~/coding`.

We do not treat mounted Windows paths (`/mnt/*`) as canonical.
Shell ambiguity is treated as a risk factor.

---

### 2. Humans Decide

AI assists.  
Humans approve.

No push occurs without:

- `git status`
- `git diff --stat`
- `git diff`
- verification output

No automation arrogance.  
No silent commits.

---

### 3. Non-Interactive Execution Only

Codex must run via:


prompt | codex exec


No interactive flows.  
No undocumented flags.  
No assumption of `-f` support.

Determinism over convenience.

---

### 4. Clean Repository Discipline

The product repository contains:

- Source code
- Documentation
- Safety infrastructure

It does NOT contain:

- `.logs/`
- `.codex/`
- temp files
- runner artifacts
- caches
- local counters

Tooling remains local unless explicitly promoted.

---

### 5. Story-Driven Implementation

Work is organized via `prd.json` stories:

Each story contains:

- id
- title
- acceptance criteria
- passes (boolean)

The runner:

1. Selects the next story where `passes = false`
2. Builds a prompt
3. Pipes to Codex
4. Runs verification
5. Marks story passed only if verification succeeds

Stories are atomic.
Commits are intention-revealing.
Exploratory commits are discouraged.

---

### 6. Safety Layers

RalphWSL enforces:

- Strict bash (`set -euo pipefail`)
- No `eval`
- Clean-tree check before Codex
- Doctor preflight environment inspection
- Environment override hygiene
- SSH key isolation discipline
- Deterministic argument parsing

Safety is layered, not implied.

---

### 7. Conversation Discipline

When interacting with AI:

- Only runnable commands appear in code blocks.
- Narrative never appears inside executable blocks.
- Shell context must be explicit.
- "." means continue without repetition.

Clarity reduces error surface.

---

## Long-Term Direction

RalphWSL aims to become:

- A reusable automation chassis
- A portable story-driven runner template
- A reference implementation for safe AI-assisted development
- A teaching artifact for disciplined infrastructure design

It prioritizes:

- Stability over novelty
- Transparency over magic
- Determinism over speed
- Human authority over automation

---

AI assists.  
Humans decide.
