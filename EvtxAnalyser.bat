@echo off

:: Change to the directory where the script is located
set "evtxecmd_dir=%~dp0"
set "evtxecmd_dir=%evtxecmd_dir:~0,-1%"
cd /d "%evtxecmd_dir%"

:: Prompt the user for the location of the log files
set /p evtx_dir="EVTX Directory: "

::  Update maps
"%evtxecmd_dir%\EvtxECmd.exe" --sync


:: Store evtx files and respective event IDs
set "system_evtx=System.evtx"
set "system_event_ids=1,41,42,1074,6005,6006,6008,7045"
set "system_output=system.csv"

set "security_evtx=Security.evtx"
set "security_event_ids=1100,1101,1102,1104,4608,4609,4624,4625,4634,4647,4648,4672,4720,4722,4723,4724,4725,4726,4778,4779,4781,4800,4801,4802,4803,5140"
set "security_output=security.csv"

set "powershell_operational_evtx=Microsoft-Windows-PowerShell%%4Operational.evtx"
set "powershell_operational_event_ids=4103,4104,8193,8194,8197,40961,40962,53504"
set "powershell_operational_output=powershell_operational.csv"

set "rdp_core_ts_operational_evtx=Microsoft-Windows-RemoteDesktopServices-RdpCoreTS%%4Operational.evtx"
set "rdp_core_ts_operational_event_ids=98,131"
set "rdp_core_ts_operational_output=rdp_core_ts_operational.csv"

set "local_session_manager_operational_evtx=Microsoft-Windows-TerminalServices-LocalSessionManager%%4Operational.evtx"
set "local_session_manager_operational_event_ids=21,22,24,25,41"
set "local_session_manager_operational_output=local_session_manager_operational.csv"

set "rdp_client_operational_evtx=Microsoft-Windows-TerminalServices-RDPClient%%4Operational.evtx"
set "rdp_client_operational_event_ids=1024,1102"
set "rdp_client_operational_output=rdp_client_operational.csv"

set "remote_connection_manager_operational_evtx=Microsoft-Windows-TerminalServices-RemoteConnectionManager%%4Operational.evtx"
set "remote_connection_manager_operational_event_ids=1149"
set "remote_connection_manager_operational_output=remote_connection_manager_operational.csv"

set "winlogon_operational_evtx=Microsoft-Windows-Winlogon%%4Operational.evtx"
set "winlogon_operational_event_ids=811,812"
set "winlogon_operational_output=winlogon_operational.csv"

set "winrm_operational_evtx=Microsoft-Windows-WinRM%%4Operational.evtx"
set "winrm_operational_event_ids=6,8,15,16,33,91,168"
set "winrm_operational_output=winrm_operational.csv"

set "wmi_activity_operational_evtx=Microsoft-Windows-WMI-Activity%%4Operational.evtx"
set "wmi_activity_operational_event_ids=5857,5860,5861"
set "wmi_activity_operational_output=wmi_activity_operational.csv"

set "powershell_evtx=Windows PowerShell.evtx"
set "powershell_event_ids=400,403,800"
set "powershell_output=powershell.csv"

:: Run EvtxECmd.exe
"%evtxecmd_dir%\EvtxECmd.exe" -f "%evtx_dir%\%system_evtx%" --inc "%system_event_ids%" --csv "%evtxecmd_dir%" --csvf "%system_output%"
"%evtxecmd_dir%\EvtxECmd.exe" -f "%evtx_dir%\%security_evtx%" --inc "%security_event_ids%" --csv "%evtxecmd_dir%" --csvf "%security_output%"
"%evtxecmd_dir%\EvtxECmd.exe" -f "%evtx_dir%\%powershell_operational_evtx%" --inc "%powershell_operational_event_ids%" --csv "%evtxecmd_dir%" --csvf "%powershell_operational_output%"
"%evtxecmd_dir%\EvtxECmd.exe" -f "%evtx_dir%\%rdp_core_ts_operational_evtx%" --inc "%rdp_core_ts_operational_event_ids%" --csv "%evtxecmd_dir%" --csvf "%rdp_core_ts_operational_output%"
"%evtxecmd_dir%\EvtxECmd.exe" -f "%evtx_dir%\%local_session_manager_operational_evtx%" --inc "%local_session_manager_operational_event_ids%" --csv "%evtxecmd_dir%" --csvf "%local_session_manager_operational_output%"
"%evtxecmd_dir%\EvtxECmd.exe" -f "%evtx_dir%\%rdp_client_operational_evtx%" --inc "%rdp_client_operational_event_ids%" --csv "%evtxecmd_dir%" --csvf "%rdp_client_operational_output%"
"%evtxecmd_dir%\EvtxECmd.exe" -f "%evtx_dir%\%remote_connection_manager_operational_evtx%" --inc "%remote_connection_manager_operational_event_ids%" --csv "%evtxecmd_dir%" --csvf "%remote_connection_manager_operational_output%"
"%evtxecmd_dir%\EvtxECmd.exe" -f "%evtx_dir%\%winlogon_operational_evtx%" --inc "%winlogon_operational_event_ids%" --csv "%evtxecmd_dir%" --csvf "%winlogon_operational_output%"
"%evtxecmd_dir%\EvtxECmd.exe" -f "%evtx_dir%\%winrm_operational_evtx%" --inc "%winrm_operational_event_ids%" --csv "%evtxecmd_dir%" --csvf "%winrm_operational_output%"
"%evtxecmd_dir%\EvtxECmd.exe" -f "%evtx_dir%\%wmi_activity_operational_evtx%" --inc "%wmi_activity_operational_event_ids%" --csv "%evtxecmd_dir%" --csvf "%wmi_activity_operational_output%"
"%evtxecmd_dir%\EvtxECmd.exe" -f "%evtx_dir%\%powershell_evtx%" --inc "%powershell_event_ids%" --csv "%evtxecmd_dir%" --csvf "%powershell_output%"


set "combined_output=%evtxecmd_dir%\combined_output.csv"

:: Copy the header from the first file to the merged file
for /f "usebackq tokens=* delims=" %%A in ("%system_output%") do (
	echo %%A >> "%combined_output%"
	goto skip_header
)

:skip_header
for /f "usebackq skip=1 tokens=* delims=" %%A in ("%system_output%") do (
    echo %%A >> "%combined_output%"
)
for /f "usebackq skip=1 tokens=* delims=" %%A in ("%security_output%") do (
    echo %%A >> "%combined_output%"
)
for /f "usebackq skip=1 tokens=* delims=" %%A in ("%powershell_operational_output%") do (
    echo %%A >> "%combined_output%"
)
for /f "usebackq skip=1 tokens=* delims=" %%A in ("%rdp_core_ts_operational_output%") do (
    echo %%A >> "%combined_output%"
)
for /f "usebackq skip=1 tokens=* delims=" %%A in ("%local_session_manager_operational_output%") do (
    echo %%A >> "%combined_output%"
)
for /f "usebackq skip=1 tokens=* delims=" %%A in ("%rdp_client_operational_output%") do (
    echo %%A >> "%combined_output%"
)
for /f "usebackq skip=1 tokens=* delims=" %%A in ("%remote_connection_manager_operational_output%") do (
    echo %%A >> "%combined_output%"
)
for /f "usebackq skip=1 tokens=* delims=" %%A in ("%winlogon_operational_output%") do (
    echo %%A >> "%combined_output%"
)
for /f "usebackq skip=1 tokens=* delims=" %%A in ("%winrm_operational_output%") do (
    echo %%A >> "%combined_output%"
)
for /f "usebackq skip=1 tokens=* delims=" %%A in ("%wmi_activity_operational_output%") do (
    echo %%A >> "%combined_output%"
)
for /f "usebackq skip=1 tokens=* delims=" %%A in ("%powershell_output%") do (
    echo %%A >> "%combined_output%"
)


:: TODO
:: Check if empty/1st row - delete
:: Merge Outputs into 1 file (1 headers)
:: Sort by time column

:: Instead of changing location, maybe just add path before.exe
:: Loop through
:: Ask if can be made more efficient

:: zip results?


:: Pause the script to see the output before closing
pause