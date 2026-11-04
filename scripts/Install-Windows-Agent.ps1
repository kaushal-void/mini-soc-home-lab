# Run once from an Administrator PowerShell after the Wazuh manager is ready.
$ErrorActionPreference = 'Stop'
$principal = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Open PowerShell as Administrator first.' }
$labRoot = Split-Path -Parent $PSScriptRoot
$workspace = Split-Path -Parent (Split-Path -Parent $labRoot)
$installer = Join-Path $workspace 'work\downloads\wazuh-agent-4.14.7-1.msi'
if (Get-Service WazuhSvc -ErrorAction SilentlyContinue) { throw 'Wazuh is already installed; do not reinstall it. Ask Codex to inspect the existing service.' }
if ((Get-FileHash -LiteralPath $installer -Algorithm SHA256).Hash -ne 'E967F36B75589D6210244FD58239C7021FA53A77C38D92315C3B3BD115002EDE') { throw 'Installer checksum changed.' }
$signature = Get-AuthenticodeSignature -LiteralPath $installer
if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch 'Wazuh') { throw 'Installer signature is not valid for Wazuh.' }
$installerArgs = '/i "' + $installer + '" /qn /norestart WAZUH_MANAGER="127.0.0.1" WAZUH_REGISTRATION_SERVER="127.0.0.1" WAZUH_AGENT_NAME="soc-windows"'
$process = Start-Process msiexec.exe -ArgumentList $installerArgs -WindowStyle Hidden -Wait -PassThru
if ($process.ExitCode -notin @(0,3010)) { throw ('Agent installer returned ' + $process.ExitCode) }
if ((Get-Service WazuhSvc).Status -eq 'Running') { Stop-Service WazuhSvc }
$agentRoot = 'C:\Program Files (x86)\ossec-agent'
$config = Join-Path $agentRoot 'ossec.conf'
Copy-Item -LiteralPath $config -Destination (Join-Path $agentRoot 'ossec.conf.before-soc-lab')
New-Item -ItemType Directory -Path 'C:\SOC-Lab-Test' -Force | Out-Null
@'
<ossec_config>
  <client>
    <server><address>127.0.0.1</address><port>1514</port><protocol>tcp</protocol></server>
    <config-profile>windows</config-profile>
    <crypto_method>aes</crypto_method>
    <notify_time>10</notify_time>
    <time-reconnect>60</time-reconnect>
    <auto_restart>yes</auto_restart>
    <enrollment><enabled>yes</enabled><manager_address>127.0.0.1</manager_address><agent_name>soc-windows</agent_name></enrollment>
  </client>
  <client_buffer><disabled>no</disabled><queue_size>5000</queue_size><events_per_second>100</events_per_second></client_buffer>
  <localfile><location>Application</location><log_format>eventchannel</log_format></localfile>
  <localfile><location>System</location><log_format>eventchannel</log_format></localfile>
  <localfile>
    <location>Security</location><log_format>eventchannel</log_format>
    <query>Event/System[EventID=4624 or EventID=4625 or EventID=4634 or EventID=4648 or EventID=4672 or EventID=4720 or EventID=4726 or EventID=1102]</query>
  </localfile>
  <localfile><location>Microsoft-Windows-Windows Defender/Operational</location><log_format>eventchannel</log_format></localfile>
  <syscheck>
    <disabled>no</disabled><frequency>3600</frequency><scan_on_start>yes</scan_on_start>
    <directories check_all="yes" realtime="yes">C:\SOC-Lab-Test</directories>
  </syscheck>
  <rootcheck><disabled>yes</disabled></rootcheck>
  <sca><enabled>no</enabled></sca>
  <wodle name="syscollector">
    <disabled>no</disabled><interval>12h</interval><scan_on_start>yes</scan_on_start>
    <hardware>yes</hardware><os>yes</os><network>no</network><packages>no</packages><ports all="no">no</ports><processes>no</processes>
  </wodle>
  <active-response><disabled>yes</disabled></active-response>
  <logging><log_format>plain</log_format></logging>
</ossec_config>
'@ | Set-Content -LiteralPath $config -Encoding UTF8
if (-not [Diagnostics.EventLog]::SourceExists('MiniSOCLab')) { New-EventLog -LogName Application -Source 'MiniSOCLab' }
Start-Service WazuhSvc
Write-Host 'Agent installed and service started. Ask Codex to verify enrollment and alert delivery.'
if ($process.ExitCode -eq 3010) { Write-Host 'Installer requested a reboot; do not reboot until current work is saved.' }
