$ErrorActionPreference = 'Stop'
$labRoot = Split-Path -Parent $PSScriptRoot
$drive = [IO.DriveInfo]::new('C')
if ($drive.AvailableFreeSpace -lt 100GB) { throw 'Less than 100 GiB free on C:. Check storage before starting the lab.' }
docker info --format '{{.OSType}}' | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Open Docker Desktop and wait for the engine before starting the lab.' }
docker compose --env-file "$labRoot\private\lab.env" -f "$labRoot\deployment\docker-compose.yml" up -d
if ($LASTEXITCODE -ne 0) { throw 'Wazuh startup failed. Read the error above.' }
& "$PSScriptRoot\Maintain-Lab.ps1"
Write-Host 'Allow the services to initialize, then open https://localhost:8443.'
