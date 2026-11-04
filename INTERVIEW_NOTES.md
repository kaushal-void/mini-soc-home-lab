# Mini SOC Home Lab — interview notes

## Honest project introduction

“I built a small Wazuh monitoring lab on my Windows laptop. A native Windows agent sends events to a local manager, indexer, and dashboard running through Docker Desktop and WSL2. I verified file-change alerts and a harmless Windows Application event, then examined their rule IDs, levels, paths, and checksums.”

Current limit: alert analysis was verified through the indexer API. Browser login and an overview screenshot showing one active agent are now verified. The user also located rule 550 in the dashboard FIM Events view; its screenshot is saved. Expanded event fields have not yet been shown in a screenshot.

## What is a SOC?

A Security Operations Center is a team and set of processes for monitoring security activity, investigating alerts, and coordinating responses. My project practices a small part of that workflow; it is not a staffed or enterprise SOC.

## What is a SIEM?

Security Information and Event Management software collects and analyzes events from systems in one place. It helps people find and investigate suspicious activity. In my lab, Wazuh analyzes endpoint events and stores searchable alerts.

## What is Wazuh?

Wazuh is an open-source security monitoring platform. I used version 4.14.7 for log analysis and file integrity monitoring. I did not enable every feature.

## What is a Wazuh agent?

It is software installed on the computer being monitored. My Windows agent runs as `WazuhSvc`, reads configured event channels, monitors the test folder, and sends events to the manager. It appears as `soc-windows` and was verified Active.

## What is an endpoint?

An endpoint is a device such as a laptop or server. My only monitored endpoint is this Windows 11 laptop.

## What are Windows Event Logs?

They are records produced by Windows and applications, such as service activity or authentication events. Channels include Application, System, and Security. My controlled example is Application event 777 from the `MiniSOCLab` source.

## What is file integrity monitoring?

FIM detects changes to monitored files. A checksum is a value calculated from file contents; changing the contents generally changes the checksum. I tested creation, modification, rename, and deletion in `C:\SOC-Lab-Test`. FIM produces its own events rather than relying on Windows Event Logs for every file change.

## What is the difference between IDS and IPS?

An intrusion detection system detects and alerts. An intrusion prevention system can also block activity. My lab is configured for monitoring and investigation, with Wazuh automated response disabled. I did not demonstrate prevention.

## What is the difference between IDS and SOC?

An IDS is a detection tool. A SOC is the people and processes that use tools, assess evidence, and coordinate action. Installing a detection tool does not by itself create professional SOC experience.

## What happens when Wazuh detects suspicious activity?

The manager matches an event to a rule and may generate an alert. That alert is indexed and can be examined through the dashboard. A person checks the context before deciding whether further action is needed. My harmless changes generated alerts even though no attack happened.

## Explain your architecture

Windows event or file change → native Windows agent → Wazuh manager and rules → alert → indexer → dashboard → analyst. The three central services are Linux containers inside Docker Desktop's WSL2 environment. Their published ports are limited to localhost. My dual-boot Ubuntu installation is not used.

## Walk through an alert you investigated

“I appended a line to my harmless test file. Wazuh generated rule 550, level 7, with the description ‘Integrity checksum changed.’ I checked the endpoint, path, timestamp, changed size and modification time, and before/after SHA-256 values. They matched the authorized test, so I classified it as benign activity. I did not treat the alert level as proof of an attack.”

The alert was at 08:26:51 on 23 September 2026, India time. The sanitized evidence is in `evidence/verified-demo-alerts.json`. File-editor identity was not captured by this real-time FIM configuration.

## What problems did you encounter?

Docker could not start because of stale temporary socket files. Preserving both affected runtime folders enabled a fresh startup without resetting container data. PowerShell initially blocked the installation script; I used a session-only RemoteSigned setting. My first marker rule used the wrong parent; inspecting the installed Application rules and using parent 60600 produced the expected alert after a manager restart.

The dashboard has a locally generated certificate that requires browser review. RAM is limited, so I bounded container memory and kept the feature set small.

## What would you improve next?

Finish visual dashboard evidence, test restart behavior, measure daily storage growth, investigate selected authentication events safely, and improve the local certificate setup. Security/Defender channels are configured, but I have not demonstrated failed-login or malware detections.

## What I should not claim

This is a personal learning project. It does not establish enterprise SOC employment, professional incident response, penetration testing, malware analysis, prevention capability, high availability, or monitoring of multiple endpoints.

## CV bullets — verified scope only

- Built a local Wazuh 4.14.7 monitoring lab with Docker Desktop/WSL2 and enrolled a native Windows 11 endpoint.
- Validated file creation, modification, rename, and deletion alerts, and implemented a custom rule for a harmless Windows Application event.
- Examined alert rule IDs, severity levels, file paths, and checksums; documented benign findings and configured localhost access, log rotation, and seven-day index retention.

