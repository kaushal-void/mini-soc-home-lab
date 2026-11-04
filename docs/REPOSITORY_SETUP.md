# Using this repository

This repository preserves the Windows Wazuh lab's source configuration, scripts, documentation and sanitized evidence. It does not contain a backup of the running services.

## Existing configured laptop

Use the original soc-lab directory, which still holds its protected private files. Open Docker Desktop, then run Launch-SOC-Lab.cmd there. The separate Git checkout cannot start without those private dependencies.

## New installation prerequisites

1. Install Docker Desktop with its WSL2 backend and review the official Wazuh requirements.
2. Create a local private directory, excluded by .gitignore.
3. Generate certificates using deployment/generate-indexer-certs.yml and deployment/config/certs.yml. Review the official Wazuh Docker guide before running the generator.
4. Create private/lab.env containing INDEXER_PASSWORD, DASHBOARD_PASSWORD and API_PASSWORD with unique values. Do not commit this file.
5. Create private/internal_users.yml with properly generated password hashes matching the admin and kibanaserver passwords, and private/wazuh.yml with the dashboard's Wazuh API connection credentials. Use the matching official release's configuration format. These private configuration files are required by the Compose mounts.
6. Start the deployment using the launch helper only after all private dependencies exist.
7. Obtain the official signed Windows agent installer. The included Install-Windows-Agent.ps1 was written for the original workspace and expects its MSI at work/downloads in that workspace. Review and adapt that path for another computer; do not blindly run an installer script on an existing agent.

This is a project record, not a fully automated clean-machine bootstrap. Paths and screenshots in the PDF, slides and setup log describe the original laptop.

Official source: https://github.com/wazuh/wazuh-docker/tree/v4.14.7
Official Docker guide: https://documentation.wazuh.com/current/deployment-options/docker/wazuh-container.html

## Third-party attribution

Deployment files were adapted from Wazuh's v4.14.7 single-node example (commit adcc5b57d2f7edfcbe6c399272dc76fbdf12b623). See WAZUH-LICENSE for upstream licensing. Wazuh and Docker images are downloaded separately and are not redistributed in this repository.
