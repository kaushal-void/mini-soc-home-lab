$ErrorActionPreference = 'Stop'
$labRoot = Split-Path -Parent $PSScriptRoot
docker compose --env-file "$labRoot\private\lab.env" -f "$labRoot\deployment\docker-compose.yml" stop
if ($LASTEXITCODE -ne 0) { throw 'Could not stop the lab. Read the error above.' }
Write-Host 'Wazuh containers stopped; stored data remains in Docker volumes.'
