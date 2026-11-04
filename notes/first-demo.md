# First demonstration plan — not yet performed

Keep the explanation to five steps:

1. I deliberately change a harmless text file in `C:\SOC-Lab-Test`.
2. The Wazuh agent notices the change using file integrity monitoring.
3. The agent sends the event to the local Wazuh manager.
4. The manager applies its rules and sends an alert to the indexer.
5. I open the dashboard, examine the file path and change details, and explain that the activity was an authorized lab test.

The important distinction: an alert means a rule matched. It does not automatically mean an attack occurred.

Do not add a rule ID, severity, timestamp, screenshot, or CV claim until the actual alert has been verified. FIM alerts originate in the agent's file monitoring module; Windows Event Log demonstrations are a separate event source.

Planned tests: create, modify, rename, and delete a disposable text file. Renaming may appear as removal of the old path and addition of the new path rather than a single rename alert.
