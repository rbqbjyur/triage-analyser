@echo off
::  SPDX-License-Identifier: 0BSD
::  Copyright (C) 2024-2026 by outis
::  EvtxAnalyser (TriageAnalyser project): runs EvtxECmd against an EVTX
::  directory with per-log event ID filters. Changelog: see CHANGELOG.md

:: Read the script directory before enabling delayed expansion, so a "!" in
:: the path survives. From here on, paths are expanded with !var! for the same
:: reason.
setlocal
set "script_dir=%~dp0"
set "script_dir=%script_dir:~0,-1%"
setlocal enabledelayedexpansion

echo Script: EvtxAnalyser
echo Version: 1.0.6
echo Author: outis
echo Requires EvtxECmd.exe
echo.

:: Get EvtxECmd.exe directory
set "evtxecmd_dir=!script_dir!"

:find_evtxecmd
if not exist "!evtxecmd_dir!\EvtxECmd.exe" (
    echo EvtxECmd.exe not found.
    echo "!evtxecmd_dir!\EvtxECmd.exe" doesn't exist.
    echo Provide directory that contains EvtxECmd.exe
    set "evtxecmd_dir="
    set /p "evtxecmd_dir=> "
    call :strip_quotes evtxecmd_dir
    echo.
    goto :find_evtxecmd
)

:evtx_path
:: Prompt the user for the location of the log files
echo What is the EVTX Directory?
echo Blank for current OS default
set "evtx_dir="
set /p "evtx_dir=> "
call :strip_quotes evtx_dir
echo.
if not defined evtx_dir (
    set "evtx_dir=!SystemRoot!\System32\winevt\Logs"
)
if not exist "!evtx_dir!" (
    echo Directory does not exist
    goto :evtx_path
)

:: Date range: start and end are each optional. Validated values are held as
:: yyyy-MM-dd HH:mm in range_start / range_end.
:input_date
set "date_flags="
set "range_start="
set "range_end="

:input_start_date
echo What is the start date [UTC 0]? Format: ^(yyyy-MM-dd HH:mm^)
echo Leave blank for no start date
set "date_range_start="
set /p "date_range_start=> "
call :strip_quotes date_range_start
if not defined date_range_start goto :input_end_date
call :validate_date date_range_start " 00:00" range_start
if errorlevel 1 goto :input_start_date

:input_end_date
echo.
:ask_end_date
echo What is the end date [UTC 0]? Format: ^(yyyy-MM-dd HH:mm^)
echo Leave blank for no end date
set "date_range_end="
set /p "date_range_end=> "
call :strip_quotes date_range_end
if not defined date_range_end goto :check_date_range
call :validate_date date_range_end " 23:59" range_end
if errorlevel 1 goto :ask_end_date

:check_date_range
:: Same fixed-width format, so a string comparison orders them correctly
if defined range_start if defined range_end if "!range_start!" GTR "!range_end!" (
    echo.
    echo End date is before start date.
    echo.
    goto :input_date
)
if defined range_start set "date_flags=--sd "!range_start!:00.0000000""
if defined range_end set "date_flags=!date_flags! --ed "!range_end!:59.9999999""
echo.


:: Store evtx files and respective event IDs
:: Indices must be consecutive from 0: processing stops at the first gap.
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

:: Count the table entries
set "evtx_count=0"
:count_evtxs
if defined evtxs[!evtx_count!] (
    set /a evtx_count+=1
    goto :count_evtxs
)
set /a evtx_last=evtx_count-1

:: Update maps if DNS reachable
ping -n 1 1.1.1.1 >nul
if not errorlevel 1 (
    "!evtxecmd_dir!\EvtxECmd.exe" --sync
    echo.
)

:: Output Directory
call :get_utc_timestamp datetime
set "output_dir=!script_dir!\EvtxAnalyser_!datetime!"

:: Run EvtxECmd.exe
for /l %%I in (0,1,%evtx_last%) do (
    call :process_evtx "!evtxs[%%I]!" "!event_ids[%%I]!" "!output[%%I]!"
)


:: Pause the script to see the output before closing
pause
endlocal
exit /b


:strip_quotes <var_name>
:: Removes double quotes from a variable, e.g. a path pasted with "Copy as path"
if defined %~1 set "%~1=!%~1:"=!"
goto :eof


:validate_date <input_var> <default_time> <output_var>
:: Checks that the value of <input_var> is yyyy-MM-dd or yyyy-MM-dd HH:mm and a
:: real date and time. Date-only input gets <default_time> (" HH:mm") appended.
:: Sets <output_var> to yyyy-MM-dd HH:mm and returns 0, or prints why and
:: returns 1.
setlocal
set "value=!%~1!"
if "!value:~10!"=="" set "value=!value!%~2"

:: Exactly 16 characters, separators in place, digits elsewhere
if "!value:~15!"=="" goto :validate_date_invalid
if not "!value:~16!"=="" goto :validate_date_invalid
if not "!value:~4,1!!value:~7,1!!value:~10,1!!value:~13,1!"=="-- :" goto :validate_date_invalid
set "digits=!value:~0,4!!value:~5,2!!value:~8,2!!value:~11,2!!value:~14,2!"
for %%D in (0 1 2 3 4 5 6 7 8 9) do if defined digits set "digits=!digits:%%D=!"
if defined digits goto :validate_date_invalid

:: Ranges. The 1xx-100 form stops leading zeros (08, 09) being read as octal.
set /a year=1!value:~0,4!-10000, month=1!value:~5,2!-100, day=1!value:~8,2!-100
set /a hour=1!value:~11,2!-100, minute=1!value:~14,2!-100
set /a max_day=31, r4=year %% 4, r100=year %% 100, r400=year %% 400
for %%M in (4 6 9 11) do if !month! EQU %%M set /a max_day=30
if !month! EQU 2 (
    set /a max_day=28
    if !r4! EQU 0 if !r100! NEQ 0 set /a max_day=29
    if !r400! EQU 0 set /a max_day=29
)
if !year! LSS 1000 goto :validate_date_invalid
if !year! GTR 2999 goto :validate_date_invalid
if !month! LSS 1 goto :validate_date_invalid
if !month! GTR 12 goto :validate_date_invalid
if !day! LSS 1 goto :validate_date_invalid
if !day! GTR !max_day! goto :validate_date_invalid
if !hour! GTR 23 goto :validate_date_invalid
if !minute! GTR 59 goto :validate_date_invalid

endlocal & set "%~3=%value%"
exit /b 0

:validate_date_invalid
echo Invalid date. Please enter a valid date in YYYY-MM-DD or YYYY-MM-DD HH:mm format.
echo.
endlocal
exit /b 1


:get_utc_timestamp <var_name>
:: Sets <var_name> to the current UTC time as yyyy-MM-dd_HH-mm-ssZ, trying each
:: source in turn. If none works, uses a unique name that is clearly not a
:: timestamp rather than a local time.
setlocal
set "utc_ts="

:: 1. PowerShell
for /f "usebackq delims=" %%T in (`powershell.exe -NoProfile -NonInteractive -Command "[DateTime]::UtcNow.ToString('yyyy-MM-dd_HH-mm-ss', [Globalization.CultureInfo]::InvariantCulture)" 2^>nul`) do (
    set "utc_ts=%%T"
)
if defined utc_ts if "!utc_ts:~18!"=="" set "utc_ts="
if defined utc_ts if not "!utc_ts:~19!"=="" set "utc_ts="
if defined utc_ts goto :get_utc_timestamp_done

:: 2. WMI Win32_UTCTime via wmic (not present on current Windows 11 releases).
:: The inner for /f drops the stray carriage return wmic leaves on each line.
for /f "delims=" %%L in ('wmic path Win32_UTCTime get Day^,Hour^,Minute^,Month^,Second^,Year /value 2^>nul') do (
    for /f "tokens=1,2 delims==" %%A in ("%%L") do set "utc_%%A=%%B"
)
if defined utc_Year if defined utc_Month if defined utc_Day if defined utc_Hour if defined utc_Minute if defined utc_Second (
    for %%P in (Month Day Hour Minute Second) do (
        set "utc_%%P=0!utc_%%P!"
        set "utc_%%P=!utc_%%P:~-2!"
    )
    set "utc_ts=!utc_Year!-!utc_Month!-!utc_Day!_!utc_Hour!-!utc_Minute!-!utc_Second!"
    goto :get_utc_timestamp_done
)

:: 3. No source: never pass off local time as UTC
echo Could not determine the current UTC time.
endlocal & set "%~1=time-unknown_%random%"
goto :eof

:get_utc_timestamp_done
endlocal & set "%~1=%utc_ts%Z"
goto :eof


:process_evtx
if exist "!evtx_dir!\%~1" (
    call :create_output_dir
    "!evtxecmd_dir!\EvtxECmd.exe" -f "!evtx_dir!\%~1" %date_flags% --inc "%~2" --csv "!output_dir!" --csvf "%~3"

    :: Delete <= 306 byte files
    if exist "!output_dir!\%~3" (
        for %%A in ("!output_dir!\%~3") do (
            if %%~zA LEQ 306 (
                del "%%~fA" 2>nul
                if exist "%%~fA" (
                    echo Could not delete %%~zA byte "%%~fA"
                ) else (
                    echo Deleted %%~zA byte "%%~fA"
                )
            )
        )
    )
)
goto :eof


:create_output_dir
if not exist "!output_dir!" (
    mkdir "!output_dir!"
)
goto :eof
