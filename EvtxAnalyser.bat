@echo off
setlocal enabledelayedexpansion

echo Script: EvtxAnalyser
echo Version: 1.0.2
echo Author: outis
echo Requires EvtxECmd.exe
echo.

:: Get script and EvtxECmd.exe directories
set "script_dir=%~dp0"
set "script_dir=%script_dir:~0,-1%"
set "evtxecmd_dir=%script_dir%"

: find_evtxecmd
if not exist "%evtxecmd_dir%\EvtxECmd.exe" (
	echo EvtxECmd.exe not found.
    echo "%evtxecmd_dir%\EvtxECmd.exe" doesn't exist.
	echo Provide directory that contains EvtxECmd.exe
    set /p evtxecmd_dir="> "
	echo.
)
if not exist "%evtxecmd_dir%\EvtxECmd.exe" (
	goto find_evtxecmd
)


:: Prompt the user for the location of the log files
echo What is the EVTX Directory?
set /p evtx_dir="> "
echo.

:: Decide if date range or not
set date_flags= 

: date_range_decision
echo Do you want all time, or specific date range?
echo 1. All Time
echo 2. Specific Date Range
set /p date_range_choice="> "
echo.
if "%date_range_choice%"=="1" (
	:: All Time
    set date_flags= 
) else if "%date_range_choice%"=="2" (
	:: Specific Date Range; Ask date range
	echo What is the start date [UTC 0]? Format: ^(yyyy-MM-dd HH:mm^)
	set /p date_range_start="> "
	set date_flags= --sd "!date_range_start!:00.0000000"
	echo.
	echo What is the end date [UTC 0]? Format: ^(yyyy-MM-dd HH:mm^)
	set /p date_range_end="> "
	set date_flags=!date_flags! --ed "!date_range_end!:59.9999999" 
	echo.
) else (
    echo Invalid Input %date_range_choice%
	echo.
	goto date_range_decision
)
echo.

:: Store evtx files and respective event IDs
set evtxs[0]=System.evtx
set event_ids[0]=1,41,42,1074,6005,6006,6008,7045
set output[0]=system.csv

set evtxs[1]=Security.evtx
set event_ids[1]=1100,1101,1102,1104,4608,4609,4624,4625,4634,4647,4648,4672,4720,4722,4723,4724,4725,4726,4778,4779,4781,4800,4801,4802,4803,5140
set output[1]=security.csv

set evtxs[2]=Microsoft-Windows-PowerShell%%%%4Operational.evtx
set event_ids[2]=4103,4104,8193,8194,8197,40961,40962,53504
set output[2]=powershell_operational.csv

set evtxs[3]=Microsoft-Windows-RemoteDesktopServices-RdpCoreTS%%%%4Operational.evtx
set event_ids[3]=98,131
set output[3]=rdp_core_ts_operational.csv

set evtxs[4]=Microsoft-Windows-TerminalServices-LocalSessionManager%%%%4Operational.evtx
set event_ids[4]=21,22,24,25,41
set output[4]=local_session_manager_operational.csv

set evtxs[5]=Microsoft-Windows-TerminalServices-RDPClient%%%%4Operational.evtx
set event_ids[5]=1024,1102
set output[5]=rdp_client_operational.csv

set evtxs[6]=Microsoft-Windows-TerminalServices-RemoteConnectionManager%%%%4Operational.evtx
set event_ids[6]=1149
set output[6]=remote_connection_manager_operational.csv

set evtxs[7]=Microsoft-Windows-Winlogon%%%%4Operational.evtx
set event_ids[7]=811,812
set output[7]=winlogon_operational.csv

set evtxs[8]=Microsoft-Windows-WinRM%%%%4Operational.evtx
set event_ids[8]=6,8,15,16,33,91,168
set output[8]=winrm_operational.csv

set evtxs[9]=Microsoft-Windows-WMI-Activity%%%%4Operational.evtx
set event_ids[9]=5857,5860,5861
set output[9]=wmi_activity_operational.csv

set evtxs[10]=Windows PowerShell.evtx
set event_ids[10]=400,403,800
set output[10]=powershell.csv

:: Update maps if DNS reachable
ping -n 1 1.1.1.1 >nul
if not errorlevel 1 (
    "%evtxecmd_dir%\EvtxECmd.exe" --sync
    echo.
)

:: Output Directory
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set UTC=%datetime:~0,14%
set output_dir=%script_dir%\EvtxAnalyser_%UTC%

:: Run EvtxECmd.exe
for /l %%I in (0,1,10) do (
    call :process_evtx "!evtxs[%%I]!" "!event_ids[%%I]!" "!output[%%I]!"
)


:: TODO
:: Error Handling
:: zip results
:: Check if empty/1st row - delete
:: Merge Outputs into 1 file (1 headers)
:: Sort by time column


:: Pause the script to see the output before closing
pause
endlocal
exit /b


:process_evtx
if exist "%evtx_dir%\%~1" (
	call :create_output_dir
	"%evtxecmd_dir%\EvtxECmd.exe" -f "%evtx_dir%\%~1" %DATE_FLAGS%--inc "%~2" --csv "%output_dir%" --csvf "%~3"
)
goto :eof


:create_output_dir
if not exist "%output_dir%" (
	mkdir "%output_dir%"
)
goto :eof