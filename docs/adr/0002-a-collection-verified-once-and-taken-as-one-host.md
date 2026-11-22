---
status: accepted
date: 2026-11-21
---

# A collection is verified once, on input, and taken as one host

## Context and Problem Statement

This decision is for the analyser's planned pipeline, in work and not
yet released. It reads one host's triage collection a run: a
collector's zip or its split zip's volumes with the collector's log,
an extracted collection, a Velociraptor or KAPE collection, a mounted
image, or loose files. It extracts only the files its tools need into
a working folder of its own and runs Eric Zimmerman's tools over them.

Two questions decide what intake costs and what an analyst can rely
on afterwards:

- How often the input is hashed: once, against the collector's own
  record, or again at every step (each file extracted, each file
  staged, before and after each tool), and whether the analyser hashes
  what no record vouches for.
- Which host the timeline's rows belong to, when the files given
  carry the host's name in different places, or not at all.

## Considered Options

Verification:

- Verify once, on input: the zip, or each split volume, against the
  SHA-256 the collector's log recorded; nothing beneath a verified zip
  hashed again.
- Hash each entry again as it is extracted and staged, against its
  manifest row, as well as the zip.
- Also check a verified zip's entry list against its manifest, each
  entry by its path and size.
- Hash, once as received, an input no reference hash vouches for (a
  zip without one, loose files), so the run records what it read.
- On a hash mismatch, analyse anyway, with the failed check at the head
  of the Warnings section, rather than stop.
- For an extracted collection, which nothing vouches for: check
  nothing, and report it unverified.

The host:

- Take everything given as one host unless something shows otherwise,
  the host's name from the best host basis present, a disagreement
  shown.
- Refuse the run when two host bases disagree.
- Mark every run through the loose fallback "one host assumed, not
  checked", whether or not anything disagrees.
- Let only a hive inside the collection set the host, a hive placed
  beside it counting as a cross-check alone.

## Decision Outcome

Chosen options: verify once, on input, because a zip whose SHA-256
matches the one the collector's log recorded is, at intake, the zip
that log describes (as far as the log itself can be trusted), and
hashing each extracted file again, or checking the entry list, adds
nothing about the zip's integrity (an examiner verifies an image once
and works from it): what either could still catch, the collector's
manifest disagreeing with its own zip or a fault in extraction, is not
looked for beyond what the run meets; hash an input only to compare it
with a hash the collector recorded, because the analyser verifies what
it was given and does not begin a chain of custody of its own; stop on a
mismatch, because the fix for a bad zip is to fetch it again, and
nothing inside it can vouch for it; check an extracted collection's
files as they are read, because that is the one check it offers; and
take the input as one host unless something shows otherwise, because
the pipeline reads one collection a run, attribution needs a single
host, and the people who run it do not mix hosts' artefacts in one
input, with every disagreement shown rather than refused or
reconciled, and a hive placed beside the collection second, after one
inside it, as the analyst's own retrieval.

- The zip, or each split volume, is checked against the collector's
  log. A mismatch stops the run before analysis, naming both hashes.
  A split zip must be complete and in order, every volume but the last
  of the collector's fixed size, and, where the log is given, exactly
  the volumes the log lists; otherwise it is refused before analysis,
  naming the volume.
- A verified zip is taken as written. Each entry the run reads takes
  its source path from its row in the collector's manifest
  (`collection.csv`); an entry it reads with no row, or a row it needs
  whose entry is not in the zip, is named in the Warnings section when
  met. A row that records a file the collector could not write is a
  collection gap, reported as one with the collector's outcome.
- With no reference hash (no log, a log that names no hash, a hash the
  collector could not calculate), the zip is read as it is, not hashed,
  and reported as unverified, "no reference hash"; the run log names it
  by path, size and times. Volumes that do carry a hash are still
  checked against it. A log that names no hash for the zip is not tied
  to it: nothing from it is used for the host or the version, and it is
  named in Warnings.
- An extracted collection has nothing that vouches for it. Each file
  the run reads is compared once with its manifest row's SHA-256 as it
  is staged; a file whose hash differs, or that has no row, fails the
  check: it is not read, and is named in Warnings. The collection stays
  unverified, "manifest only", since the manifest sits in the same
  folder.
- A Velociraptor or KAPE collection is checked once against its own
  records where it carries them. A mounted image is read unverified,
  "not verified by the analyser": verifying the image is left to the
  imager's own tools.
- Loose files are not hashed and are unverified, "no reference hash". A
  loose file that shares a name with a file in the collection is hashed
  against that file's manifest hash, to find a duplicate.
- The host's name comes from the first host basis present: a SYSTEM
  hive inside the collection (or on the mounted image's Windows disk
  volume); a SYSTEM hive placed beside it, when the folder holding the
  collection is given; in an input with no collection, a SYSTEM hive
  among the loose files; the collector's own record of the host, from a
  log tied to the zip or its volumes by hash; the zip's or folder's
  name. Every other host basis present is shown with its value. A host
  basis that differs goes in Warnings, naming each value and where it
  came from, and is never reconciled. Two collections in one input are
  refused. With no host basis, the host is "not determined". A run
  through the loose fallback says that one host is assumed, not
  checked.

### Consequences

- The check covers the input as received, against the collector's
  log, and is only as good as that log: a zip and a log changed
  together before intake still agree. A verified zip's entries are not
  checked against their manifest rows, and a fault in extraction or a
  change after intake, to the zip or to a staged copy, is not looked
  for.
- An input no reference hash vouches for is hashed only where a
  manifest row gives a hash to compare with, and the run's record
  names it by path, size and times, so it cannot later show which
  bytes it read; that is left to the analyst's own custody of the
  input.
- A loose file placed beside the wrong collection is taken as from that
  collection's host. Only a disagreement between host names, where the
  loose files carry one, shows it.
- Two hosts' files in one folder read without a collection are taken
  as from one host. Where their host names differ, the
  difference is shown in Warnings; the rows are not split.
- An extracted collection or loose files can never be reported as
  verified: what they agree with is a record nothing vouches for, or
  nothing at all.
