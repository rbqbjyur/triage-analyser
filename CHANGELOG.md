# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/) and the project
uses [Semantic Versioning](https://semver.org/). Dates are UTC.

Versions up to 1.0.x are the EVTX-only batch script `EvtxAnalyser.bat`.

## 1.0.5 - 2026-01-15

### Added
- Security: 4768, 4769 (Kerberos TGT and service ticket requests).

### Fixed
- Output folder timestamp no longer uses `wmic`, which is not present on current
  Windows 11 releases.

## 1.0.4 - 2025-03-14

### Added
- Blank EVTX directory defaults to `C:\Windows\System32\winevt\Logs`; the
  directory is checked to exist.
- Date input: start and end are each optional (blank = unbounded), date-only
  input is accepted (start 00:00, end 23:59), format is validated.
- Header-only CSVs (306 bytes or less) are deleted after parsing.
- System: 9009. TerminalServices-LocalSessionManager/Operational: 23.

### Changed
- Removed the "All time / specific date range" menu in favour of the optional
  start and end prompts.

## 1.0.3 - 2025-02-18

### Added
- Application: 1022, 1033, 1034, 1042, 11707.
- SmbClient/Security: 31001. TaskScheduler/Operational: 106, 140, 141, 200, 201.
- Security: 507, 4697, 4698, 4699, 4700, 4701, 4702.
- System: 7035, 7036, 7040.

## 1.0.2 - 2024-09-26

### Added
- EvtxECmd.exe is looked for next to the script, otherwise its directory is
  prompted for.
- Output goes to a timestamped `EvtxAnalyser_<timestamp>` folder next to the
  script, created only when a log is parsed.
- Logs missing from the EVTX directory are skipped.
- EvtxECmd maps are synced only when 1.1.1.1 answers a ping.

### Changed
- Logs, event IDs and output names held in one indexed table, processed in a
  loop.

## 1.0.1 - 2024-09-25

### Added
- Optional date range (UTC) passed to EvtxECmd as `--sd` / `--ed`.

## 1.0.0 - 2024-09-19

### Added
- Banner with script name, version, author and requirements.

### Removed
- Merged `combined_output.csv`.

## 0.9.0 - 2024-08-22

### Added
- First version: runs EvtxECmd against a user-supplied EVTX directory with a
  per-log event ID filter, one CSV per log, and syncs EvtxECmd maps first.
- Logs: System, Security, PowerShell/Operational,
  RemoteDesktopServices-RdpCoreTS/Operational,
  TerminalServices-LocalSessionManager/Operational,
  TerminalServices-RDPClient/Operational,
  TerminalServices-RemoteConnectionManager/Operational, Winlogon/Operational,
  WinRM/Operational, WMI-Activity/Operational, Windows PowerShell.
- Merges all CSVs into `combined_output.csv`.
- Must sit in the same directory as EvtxECmd.exe; output goes there too.
