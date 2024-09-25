@echo off
setlocal enabledelayedexpansion

echo Script: EvtxAnalyser
echo Version: 1.0.1
echo Author: outis
echo Requires being in same directory as EvtxECmd.exe
echo.

:: Change to the directory where the script is located
set "evtxecmd_dir=%~dp0"
set "evtxecmd_dir=%evtxecmd_dir:~0,-1%"
cd /d "%evtxecmd_dir%"


:: Prompt the user for the location of the log files
set /p evtx_dir="EVTX Directory: "
echo.

:: Decide if date range or not
set DATE_FLAGS= 

: date_range_decision
echo Do you want all time, or specific date range?
echo 1. All Time
echo 2. Specific Date Range
set /p date_range_choice="> "
echo.
if "%date_range_choice%"=="1" (
	:: All Time
    set DATE_FLAGS= 
) else if "%date_range_choice%"=="2" (
	:: Specific Date Range; Ask date range
	echo What is the start date [UTC 0]? Format: ^(yyyy-MM-dd HH:mm^)
	set /p date_range_start="> "
	set DATE_FLAGS= --sd "!date_range_start!:00.0000000"
	echo.
	echo What is the end date [UTC 0]? Format: ^(yyyy-MM-dd HH:mm^)
	set /p date_range_end="> "
	set DATE_FLAGS=!DATE_FLAGS! --ed "!date_range_end!:59.9999999" 
	echo.
) else (
    echo Invalid Input %date_range_choice%
	echo.
	goto date_range_decision
)
echo.


::  Update maps
"%evtxecmd_dir%\EvtxECmd.exe" --sync
echo.


:: Store evtx files and respective event IDs
set "system_evtx=System.evtx"
set "system_event_ids=1,41,42,1074,6005,6006,6008,7045"
set "system_output=system.csv"

set "security_evtx=Security.evtx"
set "security_event_ids=1100,1101,1102,1104,4608,4609,4624,4625,4634,4647,4648,4672,4720,4722,4723,4724,4725,4726,4778,4779,4781,4800,4801,4802,4803,5140"
set "security_output=security.csv"

set "powershell_operational_evtx=Microsoft-Windows-PowerShell%%%%4Operational.evtx"
set "powershell_operational_event_ids=4103,4104,8193,8194,8197,40961,40962,53504"
set "powershell_operational_output=powershell_operational.csv"

set "rdp_core_ts_operational_evtx=Microsoft-Windows-RemoteDesktopServices-RdpCoreTS%%%%4Operational.evtx"
set "rdp_core_ts_operational_event_ids=98,131"
set "rdp_core_ts_operational_output=rdp_core_ts_operational.csv"

set "local_session_manager_operational_evtx=Microsoft-Windows-TerminalServices-LocalSessionManager%%%%4Operational.evtx"
set "local_session_manager_operational_event_ids=21,22,24,25,41"
set "local_session_manager_operational_output=local_session_manager_operational.csv"

set "rdp_client_operational_evtx=Microsoft-Windows-TerminalServices-RDPClient%%%%4Operational.evtx"
set "rdp_client_operational_event_ids=1024,1102"
set "rdp_client_operational_output=rdp_client_operational.csv"

set "remote_connection_manager_operational_evtx=Microsoft-Windows-TerminalServices-RemoteConnectionManager%%%%4Operational.evtx"
set "remote_connection_manager_operational_event_ids=1149"
set "remote_connection_manager_operational_output=remote_connection_manager_operational.csv"

set "winlogon_operational_evtx=Microsoft-Windows-Winlogon%%%%4Operational.evtx"
set "winlogon_operational_event_ids=811,812"
set "winlogon_operational_output=winlogon_operational.csv"

set "winrm_operational_evtx=Microsoft-Windows-WinRM%%%%4Operational.evtx"
set "winrm_operational_event_ids=6,8,15,16,33,91,168"
set "winrm_operational_output=winrm_operational.csv"

set "wmi_activity_operational_evtx=Microsoft-Windows-WMI-Activity%%%%4Operational.evtx"
set "wmi_activity_operational_event_ids=5857,5860,5861"
set "wmi_activity_operational_output=wmi_activity_operational.csv"

set "powershell_evtx=Windows PowerShell.evtx"
set "powershell_event_ids=400,403,800"
set "powershell_output=powershell.csv"

:: Create Output Subdirectory
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set UTC=%datetime:~0,14%

:: Run EvtxECmd.exe
call :process_evtx "%system_evtx%" "%system_event_ids%" "%system_output%"
call :process_evtx "%security_evtx%" "%security_event_ids%" "%security_output%"
call :process_evtx "%powershell_operational_evtx%" "%powershell_operational_event_ids%" "%powershell_operational_output%"
call :process_evtx "%rdp_core_ts_operational_evtx%" "%rdp_core_ts_operational_event_ids%" "%rdp_core_ts_operational_output%"
call :process_evtx "%local_session_manager_operational_evtx%" "%local_session_manager_operational_event_ids%" "%local_session_manager_operational_output%"
call :process_evtx "%rdp_client_operational_evtx%" "%rdp_client_operational_event_ids%" "%rdp_client_operational_output%"
call :process_evtx "%remote_connection_manager_operational_evtx%" "%remote_connection_manager_operational_event_ids%" "%remote_connection_manager_operational_output%"
call :process_evtx "%winlogon_operational_evtx%" "%winlogon_operational_event_ids%" "%winlogon_operational_output%"
call :process_evtx "%winrm_operational_evtx%" "%winrm_operational_event_ids%" "%winrm_operational_output%"
call :process_evtx "%wmi_activity_operational_evtx%" "%wmi_activity_operational_event_ids%" "%wmi_activity_operational_output%"
call :process_evtx "%powershell_evtx%" "%powershell_event_ids%" "%powershell_output%"


:: TODO
:: Instead of changing location, maybe just add path before.exe
:: Ask if can be made more efficient

:: zip results?

:: Check if empty/1st row - delete
:: Merge Outputs into 1 file (1 headers)
:: Sort by time column


:: Pause the script to see the output before closing
pause
endlocal
exit /b


:process_evtx
echo.
echo "%evtx_dir%\%~1"
echo "%~2"
echo "%~3"
echo.
goto :eof


:create_output_dir
if not exist %evtxecmd_dir%\EvtxAnalyser_%UTC% (
	mkdir %evtxecmd_dir%\EvtxAnalyser_%UTC%
)
goto :eof