---
status: accepted
date: 2026-11-20
---

# What a timeline time is

## Context and Problem Statement

This decision is for the analyser's planned pipeline, in work and not
yet released, which runs Eric Zimmerman's command-line tools over a
collection and builds its timeline from their output. Every time on
that timeline comes from a column in a tool's output, such as
EvtxECmd's `TimeCreated`. Two things about such
a time are often not established: what it marks (when the record was
written, or when the action it reports took place), and its time zone.
A bare timestamp in a CSV does not say whether it is UTC, the analysis
machine's local time, or the examined host's local time passed through
from the artefact. The pipeline takes artefact and tool facts from a
curated artefact knowledge base, not public, which states an output's
time zone and what a time column marks where they have been
established, and leaves them unstated where they have not.

## Considered Options

- Use a time only once its meaning and zone are established, and leave
  everything else off the timeline.
- Label each time by the tool and column it came from, claim no meaning
  for it, and place it even where its zone is not established, with
  the uncertainty shown.
- Assume UTC wherever the zone is not established.

## Decision Outcome

Chosen option: label each time by the tool and column it came from,
and place it even where its zone is not established, because leaving a
time off could hide
something an analyst needs to see, and an analyst can often tell the
zone from context, while assuming UTC would put a guess in a UTC
column as if it were known.

- A row's time is labelled with the tool and the column it came from,
  word for word (for example "EvtxECmd TimeCreated"). No meaning is
  claimed for it until the knowledge base holds one.
- A time counts as UTC when the knowledge base states that its output
  is UTC. Where it states nothing yet, the analyser may rely on its own
  test, sent to the knowledge base, until the knowledge base has
  decided: only for the time columns the test observed, the kind of
  input tested and the options the analyser runs the tool with, on
  the tool version tested and later ones (a later version is presumed
  to write its times the same way until shown otherwise); only where
  its runs made UTC, the analysis machine's local time and the
  examined host's local time give different values for every record
  compared and the column matched an output held as UTC on every one;
  and with each row that relies on it marked as resting on the
  analyser's own test, not yet reviewed, naming it. Outside those limits
  the time is treated as of unknown zone.
- A time with no such basis is still placed, written as the tool gave
  it, unconverted and without a trailing `Z`, and marked on its row as
  of unknown zone, naming the output. The Warnings section lists
  each such output with its row count, and the overview counts these
  rows apart.
- A time the knowledge base states is in the examined host's local
  time, or in the analysis machine's, has that zone as its basis. It
  is marked on its row with that zone, and, where it is converted to
  UTC, with what the conversion rested on: a host's time-zone setting
  read from the collection may not be the one in force when the record
  was written. Where it is not converted, it is placed as a time of
  unknown zone is, without a trailing `Z`. Either way the Warnings
  section lists each such output with its row count, and the overview
  counts these rows apart. (Added 2026-11-26.)

### Consequences

- The timeline's sort is exact only among times known to be UTC. A row
  of unknown zone may sit hours away from where it belongs, and its
  row says so.
- A row timed only by a tool's column, with no established meaning,
  is never merged with other records into one action and never gives a
  definitive attribution, since both depend on what the time marks.
