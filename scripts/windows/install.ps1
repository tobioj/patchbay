# One-time setup for Windows. Run from the app folder:
#   powershell -ExecutionPolicy Bypass -File scripts\windows\install.ps1
# It adds "Patchbay" to your Desktop and Start menu, and lets you type `patchbay`
# in any new terminal. Nothing else on your system is changed. Run it again any time; it's safe.
$ErrorActionPreference = "Stop"
$Here = $PSScriptRoot
# From source this is scripts\windows; in the downloaded app it's the Patchbay folder itself.
$AppDir = if (Test-Path (Join-Path $Here "app\server.js")) { $Here } else { Split-Path -Parent (Split-Path -Parent $Here) }
$PowerShellExe = Join-Path $env:SystemRoot "System32\WindowsPowerShell\v1.0\powershell.exe"
$Launcher = Join-Path $Here "patchbay.ps1"

# 1. Shortcuts (Desktop + Start menu). They start minimized so you can see progress on the first build.
$shell = New-Object -ComObject WScript.Shell
$places = @([Environment]::GetFolderPath("Desktop"), [Environment]::GetFolderPath("Programs"))
foreach ($dir in $places) {
  $shortcut = $shell.CreateShortcut((Join-Path $dir "Patchbay.lnk"))
  $shortcut.TargetPath = $PowerShellExe
  $shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$Launcher`""
  $shortcut.WorkingDirectory = $AppDir
  $shortcut.IconLocation = (Join-Path $Here "patchbay.ico")
  $shortcut.WindowStyle = 7  # minimized
  $shortcut.Description = "Patchbay"
  $shortcut.Save()
  Write-Host "Added shortcut: $(Join-Path $dir 'Patchbay.lnk')"
}

# 2. The `patchbay` command: add this folder to *your* PATH (not the system-wide one).
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$parts = @($userPath -split ";" | Where-Object { $_ })
if ($parts -notcontains $Here) {
  [Environment]::SetEnvironmentVariable("Path", (($parts + $Here) -join ";"), "User")
  Write-Host "Added $Here to your PATH. Open a new terminal to use: patchbay"
} else {
  Write-Host "patchbay is already on your PATH."
}

Write-Host ""
Write-Host "Done. Open Patchbay from the Desktop or Start menu, or run: patchbay" -ForegroundColor Green
