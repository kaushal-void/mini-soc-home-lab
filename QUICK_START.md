# Open the lab again

1. Sign into Windows and open **Docker Desktop** from Start. Wait for the engine to run.
2. Open this `soc-lab` folder and double-click **Launch-SOC-Lab.cmd**.
3. Allow about a minute for initialization, then use **https://localhost:8443** in Microsoft Edge.
4. Username: `admin`. Read the password privately in `private/dashboard-login.txt`.
5. Check the overview for one active agent. For the demonstration, open File Integrity Monitoring → Events and search `agent.name: "soc-windows" AND rule.id: "550"`.

The launch helper uses Docker's CLI directly. It does not change PowerShell execution policy, reinstall software, or reset Docker. Keep it in this project folder beside `deployment` and `private`. Its native Docker start operation was checked against the existing running stack; a full laptop reboot test has not been performed.

If Edge shows the known certificate warning, review that the address is exactly localhost:8443. The lab uses a locally generated certificate. Do not turn off browser security globally.

## Stop

Double-click **Stop-SOC-Lab.cmd**. This stops the three Wazuh containers and preserves their volumes. The native Windows agent starts automatically with Windows and remains installed. Closing a browser tab does not stop Wazuh.

## Dark theme

Dark mode is enabled in the persistent dashboard configuration with `uiSettings.overrides.theme:darkMode: true`. Refresh the Edge tab after the dashboard restart. The original evidence screenshots show the light theme used before this change.

## Maintenance

Keep at least 80 GiB free on C:. The launcher refuses a new start below 100 GiB as an early guard. Seven-day index retention does not preserve historical demonstration rows forever, so use the saved screenshots and JSON evidence after that period.

For manager archive cleanup, run `scripts/Maintain-Lab.ps1` weekly if the containers run continuously. If Windows PowerShell blocks that local script, the process-only RemoteSigned setting used during setup is documented in the README. No automatic cleanup task has been scheduled.

If Docker repeats the old socket error, stop and inspect it. The setup log records the previous reversible recovery. Do not repeatedly launch, factory-reset, unregister WSL, or delete volumes to troubleshoot blindly.
