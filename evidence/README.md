# Evidence

Collected evidence:

- `01-dashboard-overview.png`: user-supplied Edge screenshot showing a successful dashboard login, one active agent, and alert totals. No passwords or private keys are visible. The 46 overview alerts include background events; only six are the controlled demonstration alerts.
- `02-fim-modification-alert.png`: user-supplied screenshot of File Integrity Monitoring → Events, filtered to `soc-windows` and rule 550. Shows the test path, modified event, checksum-change description, level 7, and one matching result.
- `verified-demo-alerts.json`: six sanitized indexed alerts for creation, modification, rename (two events), deletion, and Windows Application marker 777.
- `deployment-checks.json`: deployment status record; see its timestamp and status fields.

Still useful to capture: the named active Windows endpoint, a file integrity alert, and its expanded investigation fields. Exclude passwords, tokens, private keys, personal paths, and unnecessary machine identifiers.

References:
- https://documentation.wazuh.com/current/deployment-options/docker/wazuh-container.html
- https://docs.docker.com/desktop/features/wsl/
- https://docs.docker.com/desktop/troubleshoot-and-support/troubleshoot/
- https://github.com/docker/desktop-feedback/issues/676 (similar reported socket error; not a verified fix)
