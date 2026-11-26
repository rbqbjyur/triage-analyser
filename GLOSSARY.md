# The analyser

The language of the analyser's planned pipeline, in work and not yet
released: one Windows host's triage collection in, the Eric Zimmerman
command-line tools run over it, and a timeline of what happened on the
host out. A definition says what a term is; what the analyser does with
it is in `docs/adr/`.

Terms marked *(provisional)* belong to the domain of the curated
artefact knowledge base the analyser takes its knowledge from (not
public). Their words are that knowledge base's to set, and the analyser
takes them as given; until then the word shown is the analyser's own.

## Language

### Actions and records

**Action** *(provisional)*:
Something that happened on the examined host, at the level a DFIR
analyst would write it up, such as a program running or an account
logging on. One row of the timeline stands for one action.
_Avoid_: analyst-level event, event (for this)

**Record** *(provisional)*:
One unit a tool parsed from an artefact, such as an MFT file record,
one event record or one registry value.
_Avoid_: event ID (for a record), entry, item

**Kind of record** *(provisional)*:
Records alike in what they show, in the sense that a 4624 of one logon
type is a kind of record and every 4624 is not. A kind of record shows
a kind of action.

**Artefact** *(provisional)*:
The class a record comes from, such as an event log or a registry hive,
held in a collection as one or more files.
_Avoid_: artifact (except in other parties' names)

**Sources** *(provisional)*:
The records an action rests on.
_Avoid_: proof, evidence (for these)

**Foundational** *(provisional)*:
Said of a record, or of a minimum set of records, that shows an action
on its own.

**Complementary** *(provisional)*:
Said of a record that adds to an action only alongside records that
show it.

**Descriptor** *(provisional)*:
The short phrase that says what an action was, the same whichever of
its foundational records were found.
_Avoid_: Map/Tag, tag, label, description, event name

**Details** *(provisional)*:
The relevant values an action's records contribute, each value once;
also the timeline column that holds them.
_Avoid_: payload, fields, key values

**Row**:
On its own, always a timeline row. It stands for one action, whether
one record shows it or several, from one artefact or more.

**Source** (the column):
The timeline's last column, listing an action's sources, each by a
source reference.
_Avoid_: proof, evidence, origin, provenance, citation

**Source reference**:
One entry in Source, locating one record in the kept native output.

**Source path**:
The path a file had on the examined host, as the collection records
it. A loose file has none known.
_Avoid_: logical path, original path, source (alone)

**Join** *(provisional)*:
Putting the records of one action, from one or more artefacts, into
one row.
_Avoid_: correlation, merge, combine, aggregate

**Join rule**:
The analyser's rule, written from what the knowledge base holds of how
records belong together, saying which records make one action's row.

**Native output** *(provisional)*:
What an Eric Zimmerman tool writes for its run within the analyser, in
the tool's own form. Nothing the analyser writes itself is native
output.
_Avoid_: full native output, raw output, EZ output

**Noise** *(provisional)*:
What the knowledge base holds as showing nothing an analyst needs,
routine or benign activity, under the conditions it states.
_Avoid_: benign (as a term of its own), normal, whitelisted, false
positive

**Known-bad** *(provisional)*:
Something in the input that matches what is held as known to be
malicious, together with what it matched. It reports the match, not a
judgement beyond it.
_Avoid_: IoC, detection, alert, hit, finding

**Unreviewed test**:
A test the analyser's project ran on another party's tool and sent to
the knowledge base, with its input, output and process, on which the
knowledge base has not yet decided.
_Avoid_: finding

### Inputs

**Input**:
What the analyst gives a run: one path, and what it brings with it.

**Collection**:
One host's artefacts in a recognised form, however packed: a
collector's output (latro, Velociraptor, KAPE) or a mounted image's
Windows disk volume.
_Avoid_: source, source folder, dataset, case

**Form**:
The layout a collection is in: a collector's (latro's, Velociraptor's,
KAPE's) or a plain Windows layout. Zipped, split or extracted is how a
collector's output is packed, not a form.
_Avoid_: kind, type, input form

**Loose fallback**:
How the analyser reads an input in which it recognises no collection:
each file by its file type alone, with no collector's record behind it.
_Avoid_: fallback (alone), folder mode

**Loose file**:
A file given outside any collection, or beside one. Its host is the
analyst's placement, and its source path is not known.
_Avoid_: associated file, companion file

**Duplicate**:
A loose file whose SHA-256 equals that of a file in the collection.
_Avoid_: copy

**Transfer wrapper**:
Compression around one file, added to move it, such as a `.gz` around
a downloaded file. It is neither a form nor a way of packing a
collection.
_Avoid_: archive, container

**Split zip**:
One collection's zip delivered as numbered volumes (`.zip.001`,
`.zip.002`, ...).
_Avoid_: split set, parts, segments, joined zip

**Volume** *(provisional)*:
One numbered piece of a split zip. A disk volume is always called a
disk volume.

**Extracted collection**:
A collection's zip unpacked into a folder before the run.
_Avoid_: extracted folder

**Collection root** *(provisional)*:
The top folder of an extracted collection, where the collector's own
records sit.

**Drive folder** *(provisional)*:
The folder in a collection that stands for one of the host's drives.

**Mounted image**:
A disk image the analyst has mounted, given at the root of its Windows
disk volume.
_Avoid_: volume root, image root

**Manifest** *(provisional)*:
The collector's own list of the files it set out to take and what
happened to each, such as latro's `collection.csv`.

**Collector's log** *(provisional)*:
The collector's own log of its run, such as latro's `.log`, with its
reference hashes where it printed them.
_Avoid_: companion log, the log (alone), the collector's run log

**Outcome** *(provisional)*:
The collector's own word, in its manifest, for what happened to one
file it set out to take.
_Avoid_: status, result (for this)

**Collection gap** *(provisional)*:
A manifest row for a file the collector set out to take but wrote
nothing for.
_Avoid_: gap (alone), missing file

### Intake

**Intake**:
The analyser's checking of what it was given against the collector's
own records, before anything from it is analysed.

**Reference hash**:
A SHA-256 the collector recorded outside the files it describes, such
as its log's line for a zip or for each volume. A manifest's per-file
hashes are not reference hashes.
_Avoid_: source hash, expected hash, known-good hash

**Verified**:
Said of a collection that matches its reference hash at intake: a zip,
or a collection whose collector's own records hold a reference hash
for it. A split zip is verified only when every volume is.

**Unverified**:
Said of a collection or loose file that no reference hash vouches for,
always with its reason: no reference hash (a zip without one, loose
files, a split zip with a volume lacking one), manifest only (an
extracted collection with no reference hash, whose files are compared
with per-file hashes held inside it, which nothing vouches for), not
verified by the analyser (a mounted image), or the collector's records
not held (where what a collector's own records hold is a knowledge
gap).

**Check**:
One named thing a run establishes, with a status of its own.
_Avoid_: test

**Fails the check**:
Said of what disagrees with the record it is compared against: a zip
or volume against its reference hash, a split zip against the volumes
its log lists, an extracted collection's file against its manifest
row.

**Not passed**:
Said of a check that could not establish what it checks, whatever the
reason. It is never a pass.

**Processing**:
The second of the two checks a run's verdict rests on, after intake:
that everything the run read went through its tool and into the
outputs without error, each tool's output read, every record accounted
for, and the outputs written and hashed. It says nothing of what the
collection holds.

**Tied**:
Said of the collector's log, which belongs to the zip or volumes its
hash lines name. A log that names no hash is not tied.

### Times

**Tool reading**:
A time or value a row carries under a tool's own column name, word for
word and named as that tool's, because what the column holds is not
yet known. No meaning is claimed for it.
_Avoid_: reading (alone), raw value, observation

**Time label**:
The tool and output column a row's time was read from, word for word,
such as "EvtxECmd TimeCreated". It claims nothing about what the time
marks.

**Row time**:
The time a row is sorted by.

**Zone basis**:
What a time's zone rests on: UTC as the knowledge base states it, UTC
by the analyser's own test not yet reviewed, host local time or the
analysis machine's local time as the knowledge base states it, or
unknown zone.

**Unknown zone**:
Said of a time whose zone is not established.
_Avoid_: unknown time zone

**Host local time**:
A time given in the examined host's own zone.
_Avoid_: local time (alone)

**Date window**:
The optional start and end, in UTC, that an analyst sets for a run,
limiting the run to what falls between them, or, for a time not known
to be UTC, to what could fall between them in some zone from UTC-12:00
to UTC+14:00.
_Avoid_: date range, time window, window (alone)

### What a run cannot say

**Caveat**:
The analyser's own wording on a row, naming something the row rests on
that is not settled, such as a time whose zone is not known to be UTC,
a test of the analyser's own not yet reviewed, a descriptor resting on
knowledge whose certainty is not settled, a file whose collector's
outcome is incomplete or size changed, or records that may repeat
another file's.
_Avoid_: warning, note, marker

**Not determined**:
What the analyser writes where it cannot establish a value, always
with its reason: the knowledge it needs is not held, what would show
it was found but not read or was unreadable, or the input does not
show it. It is never a guess and never left empty. A descriptor whose
knowledge is not held is shown by its stand-in instead.

**Knowledge gap**:
Knowledge a release's design needs that was not held when the release
was built. A release names each one it has.
_Avoid_: gap (alone)

### Scope and what a run finds

**In scope**:
Said of an artefact in the overlap of latro's artefact scope (what it
collects and what it cannot) and what the Eric Zimmerman command-line
tools fuligin installs read: the scope of the 2.x releases as a whole.
What one release reads is "read by this release"; what one run needs,
"needed by the run".
_Avoid_: coverage, supported

**Found**:
Said of an in-scope artefact in the input, in the collection given or
among the loose files read with it. It says nothing of whether it was
read or what it held.
_Avoid_: present, available, collected, parsed

**Not in the input**:
Said of an artefact the release reads with nothing of it in the input.
It says nothing of the examined host or of how the collection was
made.
_Avoid_: missing, absent, not found, gap

**Not read**:
Said of a file or folder in the input whose records the run does not
take in, always with its reason: given to no tool, or its tool's
output not taken in.
_Avoid_: empty, skipped, ignored

**Unreadable**:
Said of a found file that the analyser or its tool could not read.

**Unaccounted for**:
Said of something in the input that nothing accounts for.

### Filtering

**Filter**:
What limits a tool's run to what the timeline needs (the event set,
keys, paths, the date window), whether the tool applies it during its
run or the analyser after it.
_Avoid_: selection, scope

**Filtered out**:
What a filter leaves out.

**Event set**:
The events, each by its channel, provider and ID, whose records a
release can make rows from.

**Noise rule**:
The analyser's rule, written from a condition the knowledge base
holds, that keeps noise off the timeline.

**Drop**:
What a noise rule keeps off the timeline.
_Avoid_: filtered out (for this), removed

### Accounts and hosts

**Logon session** *(provisional)*:
One logon of one account on the examined host, from logon to logoff.
_Avoid_: session (alone)

**Account** *(provisional)*:
A security principal, local or domain, as the examined host's records
name it. It is never the account the analyser runs as.
_Avoid_: user

**Active window**:
A span in which one account on the examined host is taken as able to
act: inside a logon session, outside any lock or sleep. Lock and sleep
are *(provisional)*, as logon session is.
_Avoid_: window (alone), session

**Attribution**:
The account or accounts a row names as having acted, with its
attribution basis. It is always about accounts, never a host or a
threat actor.
_Avoid_: potential attribution, actor attribution, temporal correlation

**Definitive attribution**:
Attribution where the row's own records name the account, in a field
or through a link the knowledge base holds to a record that names it.
It names the account the records name, not the person at the keyboard.

**Attribution by active window**:
Attribution where no record names the account, so the row names every
account with an active window containing its time. It says who could
have acted, not who did.

**Attribution basis**:
What a row's attribution rests on: definitive, by active window, or
not determined.

**Accounts output**:
The analyser's output of the accounts that had active windows on the
examined host, with those windows.

**Examined host**:
The one Windows machine whose artefacts a run reads.
_Avoid_: analysed host, target, endpoint, machine (alone)

**Analysis machine**:
The Windows machine a run executes on, where the tools are installed.
It is never the examined host.
_Avoid_: workstation, analysis host

**Host basis**:
What the examined host's name rests on: a SYSTEM hive inside the
collection, one beside it, one among loose files in an input with no
collection, the collector's log tied by hash, or the zip's or folder's
name; for other loose files, the analyst's placement; otherwise not
determined.
_Avoid_: host source

**Host facts**:
What a run establishes about the examined host, such as its name, its
Windows release and its time zone, each with what it rests on.
_Avoid_: host profile, target info

### Runs

**Prompted run**:
A run given no parameter bar the ones that only choose how its output
looks; it asks the analyst for its input and its date window.
_Avoid_: interactive run, interactive mode

**Unprompted run**:
A run given any parameter bar the ones that only choose how its output
looks; it never asks the analyst anything, and needs its input given.
_Avoid_: unattended run, command-line run, batch mode

**Refusal**:
The analyser declining a run before any analysis, because of how it
was called or of the input given (what it holds, or where it is): a
usage error. A refused run's verdict is STOPPED.
_Avoid_: rejection

**Tools folder**:
A folder holding the Eric Zimmerman tools as Get-ZimmermanTools lays
them out, given for a run in place of looking the tools up.

### Outputs

**Output parent**:
The folder a run creates its run folder in.
_Avoid_: output folder (for this)

**Timeline**:
The analyser's main output for one examined host: its actions, one row
each, in order of row time, each row citing its sources last. It is
never a super-timeline.
_Avoid_: super-timeline, merged timeline, unified timeline, report

**Overview**:
The analyser's output that sums up one run for the analyst: the host
facts, known-bad, the DFIQ part, and what the run read, verified, could
not read and does not know.
_Avoid_: summary, report

**Run folder**:
The folder one run creates for its outputs and records: the analyser's
outputs, the native outputs and the run log.
_Avoid_: output folder, results folder

**Run log**:
The analyser's own plain-text log of one run, kept with its outputs.
_Avoid_: run record, the collector's log

**Working folder**:
The folder the analyser makes for one run to hold the evidence files it
places there for its tools.
_Avoid_: temp folder, scratch folder

**Staging**:
Making an evidence file ready for a tool, with its source path recorded
against it where one is known: placing it in the working folder (taken
from a zip, unwrapped or copied), or giving the tool the file where it
is.

## Relationships

- An **Input** holds at most one **Collection**, and any number of
  **Loose files**; an input with no collection is read by the **Loose
  fallback**
- A **Collection** is in one **Form**
- An **Artefact** is held as one or more files; a **Record** comes from
  one **Artefact**
- A **Kind of record** shows a kind of **Action**; an **Action**'s
  **Sources** include at least one **Foundational** record or set, and
  any number of **Complementary** records
- An **Action** has one **Descriptor** and its **Details**
- A **Collection** or **Loose file** is **Verified** or **Unverified**
  at **Intake**; only a **Reference hash** makes it verified
- A row has one **Row time**, with its **Time label** and **Zone
  basis**

## Flagged ambiguities

- "Associated file" (the collector's log and the files beside a
  collection, taken together) is no longer a term: the two are handled
  apart, and the collector's log is the collector's own record.
- "Source" names neither the input nor a collection: an input is what
  the analyst gives, and an action's sources are the records it rests
  on.
- A check that fails has one of three consequences: nothing is
  analysed and the verdict is FAIL (a zip's or volume's hash), the
  input is refused and the verdict is STOPPED (a split zip not
  complete and in order; likewise two collections in one input), or
  one file is left unread (an extracted collection's file).
- STOPPED covers a run refused before it began as well as one cut off
  before its work was done; a hash mismatch is FAIL, never STOPPED.
- "Verified" and "unverified" are said only of what is given at intake,
  never of a tool or its output.
- "Basis" never stands alone: a zone basis, an attribution basis and a
  host basis are different things. "Time kind" is no longer a term: it
  named the time label, what a time marks and the zone basis at once.
- "Gap" never stands alone.
- What a filter leaves out is never a drop, and a feature taken out of
  the analyser is "removed", never dropped.
- The console header's Host and Account fields name the analysis
  machine and the account the run executes as; the timeline's Host and
  Account columns name the examined host and the accounts its records
  name.
- "Timeline" alone is the analyser's output; the Windows artefact is
  always "Windows Timeline".
- "Session" never stands alone: an active window is not a logon
  session, and a logon session may hold several active windows.
- "Event" *(provisional)* means only an event of a Windows event log
  (its channel, provider and ID), never a row or an action.
- "Finding" is not used in the analyser's outputs: a test of its own
  not yet reviewed is an unreviewed test.
