# Beginner investigation guide

## What was actually investigated

Six demonstration alerts were retrieved from the local Wazuh indexer and checked against the actions performed on the Windows endpoint. Their sanitized fields are saved in `evidence/verified-demo-alerts.json`. Browser login and an overview screenshot are verified; the FIM Events view now shows the verified rule 550 modification alert. Expanded event-field screenshots are still optional follow-up evidence.

## Sources and processing

For the five FIM alerts, Windows filesystem changes are the underlying activity. The Windows agent's real-time FIM module detects them; Windows Event Logs are not their source. The agent sends its event to the manager, which decodes it and applies the FIM rules. Filebeat forwards generated alerts to the indexer. The dashboard reads indexed alerts.

For the marker alert, Windows Event Log stores an Application event from `MiniSOCLab`, event ID 777. The agent reads the Application channel through its eventchannel collector. The manager's Windows decoder and custom rule 100100 classify it as a lab demonstration. The same indexing and display path follows.

## Every demonstrated alert

Times are 23 September 2026, UTC+05:30.

| Time | What happened | Rule / level | What to examine | Assessment |
|---|---|---|---|---|
| 08:25:02.286 | Created `test.txt` | 554 / 5 | Endpoint, new path, timestamp, initial hash | Correct detection of a benign authorized addition |
| 08:26:51.355 | Added another line | 550 / 7 | Path; size and time changes; before/after checksums | Correct detection of an authorized content change |
| 08:27:26.282 | Old path disappeared during rename | 553 / 7 | Old path, timing, matching addition | Benign rename when correlated with the next alert |
| 08:27:26.300 | `test-renamed.txt` appeared | 554 / 5 | New path, same final hash as old file | Benign rename; not evidence of an additional malicious file |
| 08:31:11.430 | Deleted renamed test file | 553 / 7 | Path, last known hash, authorized test timeline | Correct detection of deliberate cleanup |
| 08:31:11.442 | Wrote harmless Application marker | 100100 / 3 | Provider `MiniSOCLab`, event ID 777, channel, test message | Intentional test signal; no suspicious behavior claimed |

Rule levels are Wazuh priorities, not probabilities that a file is malicious. These tests are true detections of file changes/test activity, classified as benign; they are not successful attacks or security incidents.

## Walk through the modification alert

1. Identify the endpoint: `soc-windows`.
2. Confirm the path: `c:\soc-lab-test\test.txt`.
3. Read rule 550, level 7: `Integrity checksum changed.`
4. Check `changed_attributes`: size, mtime, md5, sha1, sha256.
5. Compare SHA-256 values. Before: `2f590d7d3858c6674ec40f97106d09c075df55da93fdfe35b78f1ed4026bcc56`. After: `fe828ad33a6cb0658b30dde9d815a9510b5696af0c20f41bd3011619a96e8063`.
6. Correlate the 08:26:51 alert with the deliberate text append in our test.
7. Record: authorized benign modification, no containment required.

The alert alone does not establish who changed the file. This configuration uses real-time FIM, not Windows who-data auditing. Do not claim that the file editor's identity was captured.

For an unexpected change, ask whether it was approved, what program/user caused it, whether the file is important, and what related events occurred. Additional evidence would be needed before deciding it was malicious.

## Locate the same data in the dashboard

After signing into https://localhost:8443, set the time range to **Last 24 hours** on the test day, or an absolute range covering 23 September 2026 at 08:20–08:40 in India time. Saved JSON evidence remains available after live indexes age out of seven-day retention.

- Open **Agents management → Summary**, find `soc-windows`, and confirm Active.
- Open **Endpoint security → File Integrity Monitoring → Events** for file alerts.
- Open **Threat intelligence → Threat Hunting** for the Windows Application marker and other events.

Use these query-bar filters individually:

```text
agent.name: "soc-windows" AND rule.id: "550"
```

```text
agent.name: "soc-windows" AND (rule.id: "554" OR rule.id: "553")
```

```text
agent.name: "soc-windows" AND rule.id: "100100"
```

Expand a matching event to inspect `rule.id`, `rule.level`, `rule.description`, `agent.name`, `syscheck.path`, the hashes, or `data.win.system.eventID`. If no rows appear, first check the time range and agent filter.

These navigation steps are based on Wazuh documentation; they are not a claim that screenshots were collected in this session.

References: https://documentation.wazuh.com/current/user-manual/wazuh-dashboard/navigating-the-wazuh-dashboard.html and https://documentation.wazuh.com/current/user-manual/capabilities/file-integrity/advanced-settings.html

