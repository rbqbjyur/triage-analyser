@echo off
::  SPDX-License-Identifier: 0BSD
::  Copyright (C) 2024-2026 by outis
::  EvtxAnalyser (TriageAnalyser project): runs EvtxECmd against an EVTX
::  directory with per-log event ID filters. Changelog: see CHANGELOG.md
setlocal enabledelayedexpansion

echo Script: EvtxAnalyser
echo Version: 1.0.5
echo Author: outis
echo Requires EvtxECmd.exe
echo.

:: Get script and EvtxECmd.exe directories
set "script_dir=%~dp0"
set "script_dir=%script_dir:~0,-1%"
set "evtxecmd_dir=%script_dir%"

:find_evtxecmd
if not exist "%evtxecmd_dir%\EvtxECmd.exe" (
    echo EvtxECmd.exe not found.
    echo "%evtxecmd_dir%\EvtxECmd.exe" doesn't exist.
    echo Provide directory that contains EvtxECmd.exe
    set /p evtxecmd_dir="> "
    echo.
    goto :find_evtxecmd
)

:evtx_path
:: Prompt the user for the location of the log files
echo What is the EVTX Directory?
echo Blank for current OS default
set /p evtx_dir="> "
echo.
if "%evtx_dir%"=="" (
    set evtx_dir=C:\Windows\System32\winevt\Logs
)
if not exist "%evtx_dir%" (
    echo Directory does not exist
    goto :evtx_path
)

:: Decide if date range or not
set date_flags= 

:input_date
set time_present=
set date_flags= 
:: Specific Date Range; Ask date range
echo What is the start date [UTC 0]? Format: ^(yyyy-MM-dd HH:mm^)
echo Leave blank for no start date
set /p date_range_start="> "

if "!date_range_start!"=="" (
    goto :end_date
) else (
    call :validate_date "!date_range_start!"
    set date_flags=!date_flags!--sd "!date_range_start!
    if "!time_present!"=="false" (
        set date_flags=!date_flags! 00:00
    )
    set date_flags=!date_flags!:00.0000000" 
)
:end_date
echo.
echo What is the end date [UTC 0]? Format: ^(yyyy-MM-dd HH:mm^)
echo Leave blank for no end date
set /p date_range_end="> "

if "!date_range_end!"=="" (
    goto :date_finish
) else (
    call :validate_date "!date_range_end!"
    set date_flags=!date_flags!--ed "!date_range_end!
    if "!time_present!"=="false" (
        set date_flags=!date_flags! 23:59
    )
    set date_flags=!date_flags!:59.9999999" 
)
:date_finish
echo.


:: Store evtx files and respective event IDs
set evtxs[0]=Application.evtx
set event_ids[0]=1022,1033,1034,1042,11707
set output[0]=application.csv

set evtxs[1]=Security.evtx
set event_ids[1]=507,1100,1101,1102,1104,4608,4609,4624,4625,4634,4647,4648,4672,4697,4698,4699,4700,4701,4702,4720,4722,4723,4724,4725,4726,4768,4769,4778,4779,4781,4800,4801,4802,4803,5140
set output[1]=security.csv

set evtxs[2]=System.evtx
set event_ids[2]=1,41,42,1074,6005,6006,6008,7035,7036,7040,7045,9009
set output[2]=system.csv

set evtxs[3]=Microsoft-Windows-PowerShell%%%%4Operational.evtx
set event_ids[3]=4103,4104,8193,8194,8197,40961,40962,53504
set output[3]=powershell_operational.csv

set evtxs[4]=Microsoft-Windows-RemoteDesktopServices-RdpCoreTS%%%%4Operational.evtx
set event_ids[4]=98,131
set output[4]=rdp_core_ts_operational.csv

set evtxs[5]=Microsoft-Windows-SmbClient%%%%4Security.evtx
set event_ids[5]=31001
set output[5]=smb_client_security.csv

set evtxs[6]=Microsoft-Windows-TaskScheduler%%%%4Operational.evtx
set event_ids[6]=106,140,141,200,201
set output[6]=task_scheduler_operational.csv

set evtxs[7]=Microsoft-Windows-TerminalServices-LocalSessionManager%%%%4Operational.evtx
set event_ids[7]=21,22,23,24,25,41
set output[7]=local_session_manager_operational.csv

set evtxs[8]=Microsoft-Windows-TerminalServices-RDPClient%%%%4Operational.evtx
set event_ids[8]=1024,1102
set output[8]=rdp_client_operational.csv

set evtxs[9]=Microsoft-Windows-TerminalServices-RemoteConnectionManager%%%%4Operational.evtx
set event_ids[9]=1149
set output[9]=remote_connection_manager_operational.csv

set evtxs[10]=Microsoft-Windows-Winlogon%%%%4Operational.evtx
set event_ids[10]=811,812
set output[10]=winlogon_operational.csv

set evtxs[11]=Microsoft-Windows-WinRM%%%%4Operational.evtx
set event_ids[11]=6,8,15,16,33,91,168
set output[11]=winrm_operational.csv

set evtxs[12]=Microsoft-Windows-WMI-Activity%%%%4Operational.evtx
set event_ids[12]=5857,5860,5861
set output[12]=wmi_activity_operational.csv

set evtxs[13]=Windows PowerShell.evtx
set event_ids[13]=400,403,800
set output[13]=powershell.csv

:: Update maps if DNS reachable
ping -n 1 1.1.1.1 >nul
if not errorlevel 1 (
    "%evtxecmd_dir%\EvtxECmd.exe" --sync
    echo.
)

:: Output Directory
set "datetime=%date:~6,4%-%date:~3,2%-%date:~0,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%"
set output_dir=%script_dir%\EvtxAnalyser_%datetime%

:: Run EvtxECmd.exe
for /l %%I in (0,1,13) do (
    call :process_evtx "!evtxs[%%I]!" "!event_ids[%%I]!" "!output[%%I]!"
)


:: Pause the script to see the output before closing
pause
endlocal
exit /b


:validate_date
set time_present=
set "date_range=%~1"

set "input_len=0"
for /l %%A in (0,1,16) do if "!date_range:~%%A,1!" NEQ "" set /a input_len+=1

if %input_len% EQU 10 (
    echo !date_range!|findstr /R "^[1-2][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]$" >nul || (
        echo Invalid format. Please enter in YYYY-MM-DD format.
        echo.
        goto :input_date
    )
    set time_present=false
) else if %input_len% EQU 16 (
    echo !date_range!|findstr /R "^[1-2][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]$" >nul || (
        echo Invalid format. Please enter in YYYY-MM-DD HH:mm format.
        echo.
        goto :input_date
    )
    set time_present=true
) else (
    echo Invalid format. Please enter in YYYY-MM-DD or YYYY-MM-DD HH:mm format.
    echo.
    goto :input_date
)
goto :eof


:process_evtx
if exist "%evtx_dir%\%~1" (
    call :create_output_dir
    "%evtxecmd_dir%\EvtxECmd.exe" -f "%evtx_dir%\%~1" %date_flags%--inc "%~2" --csv "%output_dir%" --csvf "%~3"

    :: Delete <= 306 byte files
    for %%A in ("%output_dir%\%~3") do (
        if %%~zA LEQ 306 (
            del "%output_dir%\%~3"
            echo Deleted %%~zA byte "%output_dir%\%~3"
        )
    )
)
goto :eof


:create_output_dir
if not exist "%output_dir%" (
    mkdir "%output_dir%"
)
goto :eof
