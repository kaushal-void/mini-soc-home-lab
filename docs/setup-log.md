# Setup log

## 2026-09-23: inspection

- Windows 11 Home Single Language 25H2, build 26200.9457.
- Intel Core i7-14650HX, 16 cores / 24 logical processors.
- 15.61 GiB usable RAM; approximately 4.65–5.23 GiB available during inspection.
- C: 181.85 GiB free.
- WSL 2.7.12.0; `docker-desktop` registered as WSL2, initially stopped.
- Docker Desktop 4.89.0 and Compose 5.5.0 installed; engine initially unavailable.
- Defender real-time protection and all firewall profiles enabled.
- Docker data VHDX located under `%LOCALAPPDATA%\Docker\wsl\disk` on C:, approximately 1.55 GiB. Backend VHDX approximately 0.09 GiB.
- No user `.wslconfig` present. No resource limits changed.
- Feature-state inspection requires elevation and remains pending.

## Startup error and targeted recovery

`docker desktop start --timeout 60` displayed an unexpected-error dialog. The log identified failure to rename `%LOCALAPPDATA%\Docker\run\sailor-ingest.sock` to its stale name. These were old zero-byte reparse-point socket entries.

The user clicked Quit. With the Docker backend and GUI stopped, the runtime directory was renamed to `run.soc-lab-backup-20260923-075903` in the same Docker directory. Its absolute path and directory type were checked before renaming. No files were deleted.

`docker desktop start --detach` then progressed to a similar error for `%LOCALAPPDATA%\docker-secrets-engine\engine.sock`. That directory contained only two zero-byte socket entries. Recovery continues; engine success has not yet been verified.

No factory reset, reinstall, WSL unregister, data-volume removal, security-software disabling, or partition changes were performed.

The second socket folder was preserved as `docker-secrets-engine.soc-lab-backup-20260923-080054`. A third launch encountered the new socket left by the second attempt in the first folder. Its creation timestamp confirmed the sequence. After the user closed Docker, that newly created folder was preserved as `run.soc-lab-backup-20260923-080231`; both runtime paths were then verified absent before starting Docker once more.

Recovery succeeded. `docker version` returned a Linux/amd64 server, and `docker info` reported approximately 7.56 GiB of backend RAM, zero containers, and zero images before testing. `docker run --rm hello-world` downloaded and ran the official test image successfully. The temporary test container removed itself. `vm.max_map_count` was already 262144; no kernel setting change was necessary. No guarantee is made yet that the socket issue will not recur after a future Docker restart.

The official deployment repository was cloned with `git clone --depth 1 --branch v4.14.7 https://github.com/wazuh/wazuh-docker.git outputs/soc-lab/vendor/wazuh-docker`. Resolved commit: `adcc5b57d2f7edfcbe6c399272dc76fbdf12b623`.

Registry manifests report compressed sizes of 875.0 MiB (manager), 1026.9 MiB (indexer), 465.9 MiB (dashboard), and 141.8 MiB (certificate generator), before shared-layer deduplication. Approval was requested before these downloads.

## Deployment and verification

The user approved the image downloads. All four official images downloaded successfully. The single-node files were copied into `deployment/` and adjusted for this lab. Generated passwords are in the protected `private/` directory, not in this log. The private directory grants access to the user's Windows account, the execution sandbox account, SYSTEM, and Administrators.

Actual deployment commands, from the workspace:

```powershell
docker compose -f outputs/soc-lab/vendor/wazuh-docker/single-node/docker-compose.yml pull --quiet
docker pull --quiet wazuh/wazuh-certs-generator:0.0.4
docker compose -f outputs/soc-lab/deployment/generate-indexer-certs.yml run --rm generator
docker compose --env-file outputs/soc-lab/private/lab.env -f outputs/soc-lab/deployment/docker-compose.yml config --quiet
docker compose --env-file outputs/soc-lab/private/lab.env -f outputs/soc-lab/deployment/docker-compose.yml up -d
docker exec soc-lab-wazuh.manager-1 /var/ossec/bin/wazuh-control status
docker exec soc-lab-wazuh.manager-1 /var/ossec/bin/wazuh-analysisd -t
docker stats --no-stream
```

The certificate generator emitted `find: command not found` but exited successfully. All ten required certificate/key files were verified present and nonempty. The indexer and dashboard then used the generated files successfully.

Verified manager daemons include analysisd, remoted, authd, db, apid, modulesd, logcollector, and monitord. Unused cluster/mail/agentless services are intentionally inactive. Rule validation returned success.

Authenticated indexer health returned green, one node, and no unassigned shards. The HTTPS dashboard returned HTTP 200. Published ports were verified as loopback-only. Actual container memory in one snapshot: manager 364 MiB, indexer 1.35 GiB, dashboard 241 MiB. These values fluctuate and exclude some backend cache/overhead.

The `soc-lab-7-days` ISM policy was created through the local authenticated indexer API and assigned to existing alert and monitoring indexes. Its template covers future alert, monitoring, and statistics indexes. The explain endpoint confirmed the policy was enabled on the alert index; actual age-based deletion cannot be verified on day one.

The Windows agent MSI (4.14.7-1, 5.66 MiB) was downloaded from packages.wazuh.com. Authenticode reported Valid and signer Wazuh, Inc. SHA-256: `E967F36B75589D6210244FD58239C7021FA53A77C38D92315C3B3BD115002EDE`. The prepared administrator installation script verifies this hash and signature again before installing. User execution and enrollment are pending.

Browser navigation encountered `ERR_CERT_AUTHORITY_INVALID` because the lab uses a locally generated certificate authority. No browser warning was bypassed. Browser login and screenshots are pending user certificate review. PowerShell API checks used certificate-check skipping only for these explicit localhost requests; Windows trust stores and global TLS settings were not changed.

At the latest deployment checkpoint, C: had 174.05 GiB free. See `evidence/deployment-checks.json` for a sanitized status record.

## Endpoint and test completion

The user enabled RemoteSigned for the current Administrator PowerShell process only and ran the prepared agent script. The manager subsequently reported agent 001, `soc-windows`, Active with Windows 11 Home Single Language and Wazuh 4.14.7.

Harmless file creation, append, rename, and deletion were performed only in `C:\SOC-Lab-Test`. The disposable file's content was checked before its deletion. Creation generated rule 554 level 5; modification generated rule 550 level 7; rename generated rules 553/554; final deletion generated rule 553 level 7.

An Application marker was written with `[Diagnostics.EventLog]::WriteEntry('MiniSOCLab', <harmless test message>, [Diagnostics.EventLogEntryType]::Information, 777)`. The initial custom rule did not generate an alert. Inspection of the installed rules identified parent 60600 for Application informational events. After editing `deployment/config/local_rules.xml`, configuration validation passed and only the manager container was restarted. A fresh event then generated rule 100100 level 3. Six sanitized demonstration alerts are saved in `evidence/verified-demo-alerts.json`.

The user opened https://localhost:8443 in Edge, reviewed its certificate warning, and signed in. Their screenshot confirms the overview with one active agent and is preserved as `evidence/01-dashboard-overview.png`. Detailed alert screenshots and the user's guided investigation walkthrough remain pending. No authentication-failure or Defender-malware test was performed.

## Presentation, launch helpers and dark mode

Created a 30-slide dark PowerPoint covering the verified build and operation, plus Launch-SOC-Lab.cmd, Stop-SOC-Lab.cmd and QUICK_START.md. Enabled uiSettings.overrides.theme:darkMode: true in the persistent dashboard configuration and restarted only the dashboard. HTTPS returned 200 and injected browser metadata confirmed darkMode:true. The launch helper Compose up operation returned all three containers Running; agent 001 remained Active. Full Windows reboot recovery has not been tested. Original light screenshots are preserved as historical evidence.


