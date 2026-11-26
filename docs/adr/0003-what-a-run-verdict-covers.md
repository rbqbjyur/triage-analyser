---
status: accepted
date: 2026-11-26
---

# What a run's verdict covers

## Context and Problem Statement

This decision is for the analyser's planned pipeline, in work and not
yet released. A run ends with one verdict, PASS, WARN or FAIL (or
STOPPED, for a run cut off before its work was done), and an exit code
to match. Many things a run meets are not settled, and the verdict has
to say which of them it covers:

- whether the collection given matches its reference hash, or has none;
- whether every file the run read went through its tool and into the
  outputs without error;
- what the collection holds: an artefact the analyser reads may not be
  in it at all;
- what the knowledge base does not yet hold, so that some cells cannot
  be filled;
- rows resting on knowledge that is not settled, or on a time whose
  zone is not known to be UTC.

The evidence rules the analyser follows say that what cannot be
determined is never reported as fine and counts as not passed. A
verdict that grades everything on that list would almost never be
PASS, and a verdict that grades only the run's own processing would
let an unverified input look verified.

## Considered Options

- Grade everything: the input's verification, the processing, every
  artefact not in the collection, every knowledge gap met and every
  caveated row; PASS only when none is met.
- Grade two checks, intake and processing; show the collection's
  contents, the knowledge gaps, the caveats and the host facts without
  grading them.
- The same two checks, with an extracted collection whose files all
  match its manifest counting as an intake PASS.
- Grade the processing only, with the input's verification as
  information.

## Decision Outcome

Chosen option: two checks, intake and processing, because the
analyser's job is to verify what it was given and to process it
correctly, not to judge the collection. Collecting artefacts is the
collector's scope, and collections differ (latro's, Velociraptor's and
KAPE's targets, an analyst's own), so an artefact not in one is not a
fault of the run. Counting a manifest match as an intake PASS, or
grading the processing alone, would report an input nothing vouches
for as verified, or as fine.

The rule above is read accordingly: the verdict says exactly what it
covers, no check claims what cannot be determined, and a cell that
cannot be filled says so. The rule itself is unchanged.

- Intake:
  - PASS where the collection matches its reference hash: the zip's,
    each split volume's, or one a Velociraptor or KAPE collection's own
    records hold outside the files it covers.
  - WARN where it cannot be verified: no reference hash, an extracted
    collection checked only against per-file hashes held inside it, a
    mounted image, loose files, or, in a release shipped without
    knowing what a collector's own records hold, that collector's
    collection. The run still processes everything it can. No
    confirmation is asked, since an unverifiable input is not a mode
    the analyst chooses; it is labelled on the reference-hash line, in
    the Warnings section and in the overview.
  - FAIL on a mismatch, both hashes named: nothing is analysed, every
    later check is not run, and the verdict is FAIL, not STOPPED.
  - A split zip that is not complete or not in order is refused before
    analysis, naming the volume, as any other refusal.
- Processing: every file read went through its tool, each tool's
  output was read, every record its tools wrote is accounted for (in a
  row, filtered out by the analyser after the run, dropped by a noise
  rule, or not in a row with its reason; what a tool filtered during
  its own run is never part of the sum, and a record not accounted for
  fails the check), and every output was written and hashed.
  - WARN where the tool reports a file damaged and only partly reads
    it, or reports it unreadable and takes nothing from it.
  - FAIL on a processing error: a tool's run failed or its output
    could not be read; a file the analyser could not read, extract or
    stage; a file that fails its manifest check (it is not read, and
    the run goes on); counts that do not reconcile; an output not
    written or not hashed; and, where a missing tool or an untested
    output form does not stop the run, a tool the run needed that was
    not found, or a tool output of an untested form whose rows are not
    read.
- The verdict is PASS only when both checks pass, WARN when the worse
  is WARN, FAIL when either fails. Exit codes: 0 PASS, 1 WARN, 2 FAIL,
  3 STOPPED (a fatal error, Ctrl+C where it can be caught, or the loose
  fallback's index reaching its limit, which stops the run before
  analysis; every later check not run).
- Not graded, always shown:
  - the collection's contents: the artefacts the release reads that
    are not in the input are listed as "not in the input", never
    "missing", with no reason given bar the collector's own outcome,
    quoted, where a manifest row exists for the file; in-scope
    artefacts the release does not read are listed as "not read by this
    release";
  - the knowledge gaps met, the caveats and the host facts.

  A cell that cannot be filled says "not determined" with its reason
  (knowledge not held, not read, not in the input: the first that holds
  is given); a descriptor whose knowledge is not held shows a stand-in
  instead, only in a release shipped with that knowledge gap named. The
  result block gives the graded lines first, then information lines
  for the host with its host basis, the knowledge gaps and the caveats.
  The Warnings section lists each caveat with its row count, host bases
  that differ, an event log with no record of the analyser's events,
  each descriptor stand-in in use (its row count also on the
  knowledge-gaps information line), and the other entries decided for
  intake; the overview lists the rest. A Warnings entry never changes the verdict.

### Consequences

- The verdict line names the examined host and says what it covers,
  for example "PASS - WKS-07: zip verified, every file read processed
  (exit code 0)".
- An extracted collection checked only against hashes inside it, a
  mounted image or loose files can at best give WARN, since nothing
  vouches for them.
- A run with many caveated rows or knowledge gaps can still PASS; the
  analyst reads those in the Warnings section and the overview, not in
  the verdict.
- A collection that holds few of the artefacts the analyser reads is
  processed as given and can PASS; the overview and the display show
  which of them it held and which it did not.
