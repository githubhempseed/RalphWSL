# RalphWSL Help

## Phase 0 (Windows beginners — start here)
If you don’t know what WSL is, start in **Windows PowerShell**:

1) Open PowerShell
2) Change directory to the repo folder on Windows (where this file exists)
3) Run:

    powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\PHASE0_WINDOWS.ps1

Or double-click:

    scripts\PHASE0_WINDOWS.cmd

This installs/initializes WSL + Ubuntu (if needed), installs Python + Git, and creates `~/coding`.

## Phase 1 (inside WSL)
After Phase 0:

- Open WSL (Ubuntu)
- Put the repo at: `~/coding/RalphWSL`
- Then run:
  - `./scripts/verify.sh`
  - `./scripts/ralph.sh --once`
