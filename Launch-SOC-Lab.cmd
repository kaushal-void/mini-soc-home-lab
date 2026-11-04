@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -Command "if (([IO.DriveInfo]::new('C')).AvailableFreeSpace -lt 100GB) { Write-Host 'Less than 100 GiB free on C:. Check storage first.'; exit 2 }"
if errorlevel 1 goto failed
docker info >nul 2>&1
if errorlevel 1 (
  echo Open Docker Desktop from the Start menu and wait for its engine to run.
  echo Then double-click this launcher again.
  pause
  exit /b 1
)
docker compose --env-file "%~dp0private\lab.env" -f "%~dp0deployment\docker-compose.yml" up -d
if errorlevel 1 goto failed
docker compose --env-file "%~dp0private\lab.env" -f "%~dp0deployment\docker-compose.yml" ps
echo.
echo Open https://localhost:8443 in Edge. Allow a minute for startup if needed.
echo Login details are in private\dashboard-login.txt. Keep them private.
start "" msedge.exe https://localhost:8443
pause
exit /b 0
:failed
echo Lab startup stopped. Read the error above. Do not reinstall or reset Docker.
pause
exit /b 1
