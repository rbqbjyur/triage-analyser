---
status: accepted
date: 2026-11-26
---

# What a run's date window covers

## Context and Problem Statement

This decision is for the analyser's planned pipeline, in work and not
yet released. An analyst may give a run a date window, an optional
start and end in UTC, to limit the run to what falls between them.
Each Eric Zimmerman tool is run only for what the timeline needs,
filtered by the tool itself where it can; what a tool writes for its
run is kept, hashed and never trimmed. This decision has the analyser
apply the date window after every run, whether or not the tool
filtered. Several things make a date window harder than a
comparison of two times:

- a tool's own date filter may compare a different time from the one
  the analyser would compare, and its zone and bounds may not be known;
- many tool times are of unknown zone, or in the examined host's local
  time, and ADR 0001 places such times on the timeline rather than
  leave them out;
- some records outside the date window are needed by rows inside it: the
  records that bound an active window or link a row to its account, and
  the ones the host facts are read from.

## Considered Options

- Use a tool's own date filter wherever the tool has one.
- Use a tool's own date filter only where it keeps every record the
  analyser's date window would keep, and apply the date window in the
  analyser after every run.
- For a time not known to be UTC: compare it as UTC; never filter it out
  by the date window; or keep it where, read in any zone from UTC-12:00
  to UTC+14:00, it could fall inside the date window.

## Decision Outcome

Chosen option: the analyser applies the date window itself after every
run, and a tool's own date filter is used only where it keeps every
record the date window would keep; a time not known to be UTC is kept
on the margin of UTC-12:00 to UTC+14:00. Because a tool's filter that
compares another time, or the same time in an unknown zone, can leave out records that fall inside the date window, and nothing in the kept native
output would show it; and because comparing a time of unknown zone as
UTC can leave out records hours inside the date window, while never
filtering such times out would make the date window do nothing for a
tool whose times are all of unknown zone.

- The bounds are inclusive: `yyyy-MM-dd`, `yyyy-MM-dd HH:mm` or
  `yyyy-MM-dd HH:mm:ss`, with up to seven digits of a second, a `T`,
  and a trailing `Z` or `+00:00`; an end given as a day, minute or
  second covers all of it. Any other offset, or an end before the
  start, is refused.
- The analyser compares each record's own time, the time a row made
  from that record alone would be sorted by, per tool output and before
  records are joined into rows. Each record it leaves out is counted as
  filtered out by the analyser after the run (ADR 0003).
- A tool's filter known to compare that same time as the tool writes
  it, against the bounds as given and with both bounds inclusive, but
  whose time's zone is not known to be UTC, is given the date window
  widened by the margin (the start less 12 hours, the end plus 14
  hours); the analyser then applies the date window itself. A tool's
  filter whose comparison is not known in that way is not used: the
  tool runs without its date filter.
- A record whose time's zone basis is not UTC (unknown zone, or host
  local time or the analysis machine's local time not converted) is
  kept where that time could fall inside the date window in some zone
  of the margin, and filtered out otherwise. A time that is UTC by the
  analyser's own test, not yet reviewed, is compared as UTC.
- Not limited by the date window: the runs that read the host facts,
  and the records that open, close or split an active window or link a
  row to its account. A row inside the date window whose account rests
  on a record outside it says so.

### Consequences

- A date window given is stated, to the tick, in the console header,
  the run log, the overview and the verdict line, for example "PASS -
  WKS-07: zip verified, every file read processed, date window
  2026-10-01T00:00:00.0000000Z to 2026-10-31T23:59:59.9999999Z (exit
  code 0)".
- The Warnings section counts the records kept on the margin, with the
  rows they make, each row carrying its caveat; the overview states,
  for each tool output, whether the date window was applied, applied
  with the margin, or not applied.
- Where a tool's times are of unknown zone, the date window narrows its
  rows only to the date window widened by 12 hours before its start and 14
  hours after its end, not exactly.
- A tool may run with no date filter of its own until what its filter
  compares is known, so a run with a date window may take as long as
  one without; its native output is then not narrowed by date.
- Neither the margin nor any other option catches a wrong clock on the
  examined host.
- The date window narrows what a run covers, and says so; it is not a
  mode unsuitable for evidence, and no confirmation is asked.
