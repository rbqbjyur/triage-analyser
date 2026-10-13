# TriageAnalyser

Fast, targeted parsing of Windows triage collections. TriageAnalyser runs
artefact (artifact) parsers against a triage collection or a live system and
pulls out the high-value records straight away, without waiting for a full
timeline (plaso / log2timeline) or a kitchen-sink forensic suite.

The current release, `EvtxAnalyser.bat`, covers Windows event logs (EVTX): it
runs [EvtxECmd](https://github.com/EricZimmerman/evtx) against a set of logs, each
with an event ID filter aimed at logons, RDP, remote execution, services,
scheduled tasks, PowerShell, account changes and log clearing, and writes one
CSV per log. More parsers are planned.

## What it does

- Prompts for the EVTX directory (blank = the live system's
  `%SystemRoot%\System32\winevt\Logs`), then an optional start and end date/time
  (UTC; date-only input means 00:00 for the start and 23:59 for the end).
- Runs EvtxECmd once per log in the table below with `--inc` set to that log's
  event IDs, and `--sd` / `--ed` when a range is given.
- Writes `<name>.csv` per log to `EvtxAnalyser_yyyy-MM-dd_HH-mm-ssZ\` (UTC)
  next to the script. CSVs containing only the header row are deleted, with a
  console message.
- Syncs EvtxECmd's maps first (`--sync`) if 1.1.1.1 answers a ping.

| Log | Event IDs | CSV |
|-----|-----------|-----|
| Application | 1022, 1033, 1034, 1042, 11707 | `application.csv` |
| Security | 507, 1100, 1101, 1102, 1104, 4608, 4609, 4624, 4625, 4634, 4647, 4648, 4672, 4697, 4698, 4699, 4700, 4701, 4702, 4720, 4722, 4723, 4724, 4725, 4726, 4768, 4769, 4778, 4779, 4781, 4800, 4801, 4802, 4803, 5140 | `security.csv` |
| System | 1, 41, 42, 1074, 6005, 6006, 6008, 7035, 7036, 7040, 7045, 9009 | `system.csv` |
| Microsoft-Windows-PowerShell/Operational | 4103, 4104, 8193, 8194, 8197, 40961, 40962, 53504 | `powershell_operational.csv` |
| Microsoft-Windows-RemoteDesktopServices-RdpCoreTS/Operational | 98, 131 | `rdp_core_ts_operational.csv` |
| Microsoft-Windows-SmbClient/Security | 31001 | `smb_client_security.csv` |
| Microsoft-Windows-TaskScheduler/Operational | 106, 140, 141, 200, 201 | `task_scheduler_operational.csv` |
| Microsoft-Windows-TerminalServices-LocalSessionManager/Operational | 21, 22, 23, 24, 25, 41 | `local_session_manager_operational.csv` |
| Microsoft-Windows-TerminalServices-RDPClient/Operational | 1024, 1102 | `rdp_client_operational.csv` |
| Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational | 1149 | `remote_connection_manager_operational.csv` |
| Microsoft-Windows-Winlogon/Operational | 811, 812 | `winlogon_operational.csv` |
| Microsoft-Windows-WinRM/Operational | 6, 8, 15, 16, 33, 91, 168 | `winrm_operational.csv` |
| Microsoft-Windows-WMI-Activity/Operational | 5857, 5860, 5861 | `wmi_activity_operational.csv` |
| Windows PowerShell | 400, 403, 800 | `powershell.csv` |

## Requirements

- Windows (batch script).
- `EvtxECmd.exe` (and its `Maps` folder). Looked for next to the script,
  otherwise its directory is prompted for.

## Usage

Run `EvtxAnalyser.bat` and answer the prompts. Point it at the directory that
holds the `.evtx` files, e.g. the `...\Windows\System32\winevt\Logs` folder of
a KAPE or other triage collection.

## Example

Live system, no date range (EvtxECmd's own output trimmed):

```
Script: EvtxAnalyser
Version: 1.0.6
Author: outis
Requires EvtxECmd.exe

What is the EVTX Directory?
Blank for current OS default
>
What is the start date [UTC 0]? Format: (yyyy-MM-dd HH:mm)
Leave blank for no start date
>
What is the end date [UTC 0]? Format: (yyyy-MM-dd HH:mm)
Leave blank for no end date
>
EvtxECmd version 2026.5.0
...
Processing C:\windows\System32\winevt\Logs\Application.evtx...
...
Records included: 305 Errors: 0 Events dropped: 18,987
...
Deleted 306 byte "C:\Tools\EvtxECmd\EvtxAnalyser_2026-10-13_15-53-04Z\rdp_core_ts_operational.csv"
...
Press any key to continue . . .
```

```
C:\Tools\EvtxECmd\EvtxAnalyser_2026-10-13_15-53-04Z\
  application.csv                               144,116
  security.csv                                4,671,040
  system.csv                                  1,523,783
  powershell_operational.csv                 11,278,331
  local_session_manager_operational.csv         118,070
  rdp_client_operational.csv                     41,361
  winlogon_operational.csv                    1,295,904
  wmi_activity_operational.csv                  304,751
  powershell.csv                              2,258,584
```

## Limitations

- Interactive only; no command-line parameters.
- Looks for the exact log filenames above in one directory: no recursion into
  a collection's folder structure and no handling of collector-specific
  filename encoding.
- No run log or summary; console output only.
- Map sync changes EvtxECmd's maps in place and is not recorded; tool versions
  are not recorded.

## Licence

[0BSD](LICENSE).
