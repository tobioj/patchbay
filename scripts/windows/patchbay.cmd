@echo off
REM patchbay for Windows. Runs patchbay.ps1 without changing your PowerShell settings.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0patchbay.ps1" %*
