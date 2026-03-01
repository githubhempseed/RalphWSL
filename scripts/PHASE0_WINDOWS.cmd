@echo off
setlocal
REM RalphWSL Phase 0 launcher (double-click friendly)
REM This runs the PowerShell script with a per-run execution policy bypass.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0PHASE0_WINDOWS.ps1" -RepoUrl "%~1"
echo.
echo If this was blocked by your organization policy, ask IT or run WSL install manually:
echo   wsl --install -d Ubuntu
pause
endlocal
