@echo off
setlocal
REM RalphWSL: Enter WSL in the canonical repo folder and stay there.

wsl --cd ~ bash -lc "cd ~/coding/RalphWSL && exec bash -l"

endlocal
