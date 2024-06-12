@echo off

start cmd /c avsr64 getnative_chunk1.avs
start cmd /c avsr64 getnative_chunk2.avs
start cmd /c avsr64 getnative_chunk3.avs
start cmd /c avsr64 getnative_chunk4.avs

TIMEOUT /T 1 /nobreak > nul

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

avsr64 getnative_final_step.avs -frames=0

echo.
pause
