# Removes only this lab's compressed manager alert archives older than seven days.
# Indexed alert retention is managed separately by the indexer policy.
$ErrorActionPreference = 'Stop'
docker exec soc-lab-wazuh.manager-1 find /var/ossec/logs/alerts -mindepth 2 -type f '(' -name '*.gz' -o -name '*.sum' ')' -mtime +7 -delete
if ($LASTEXITCODE -ne 0) { throw 'Manager archive maintenance failed.' }
$free = [math]::Round(([IO.DriveInfo]::new('C')).AvailableFreeSpace/1GB,2)
Write-Host "C: free space: $free GiB. Keep at least 80 GiB free; investigate below 100 GiB."
docker stats --no-stream --format '{{.Name}} | {{.MemUsage}}'
