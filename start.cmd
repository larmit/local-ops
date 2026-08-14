@echo off
setlocal

set "START_SCRIPT=%~dp0start.ps1"
set "PWSH_EXE=%ProgramFiles%\PowerShell\7\pwsh.exe"

if exist "%PWSH_EXE%" (
  "%PWSH_EXE%" -NoLogo -NoProfile -File "%START_SCRIPT%" %*
) else (
  "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%START_SCRIPT%" %*
)

exit /b %errorlevel%
