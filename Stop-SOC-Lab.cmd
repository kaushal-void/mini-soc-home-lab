@echo off
setlocal
docker compose --env-file "%~dp0private\lab.env" -f "%~dp0deployment\docker-compose.yml" stop
if errorlevel 1 (
  echo The lab could not stop. Read the error above.
) else (
  echo Wazuh containers stopped. Stored data remains in Docker volumes.
  echo The Windows agent stays installed and may queue events while the manager is off.
)
pause
