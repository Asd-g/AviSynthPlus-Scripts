@echo off

start cmd /c avsr64 chunk1.avs
start cmd /c avsr64 chunk2.avs
start cmd /c avsr64 chunk3.avs
start cmd /c avsr64 chunk4.avs

SETLOCAL EnableExtensions
set EXE=avsr64.exe
:LOOPSTART
FOR /F %%x IN ('tasklist /NH /FI "IMAGENAME eq %EXE%"') DO IF %%x == %EXE% goto FOUND
goto FIN
:FOUND
TIMEOUT /T 5 /nobreak > nul
goto LOOPSTART
:FIN
endlocal

avsr64 final_step.avs -frames=0

echo.
pause
