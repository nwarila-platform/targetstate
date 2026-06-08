# ADR 0002: Deny-by-Default Tracking

Status: Draft

Date: 2026-06-08

## Context

TargetState is a public repository that is being used to recover scanned source
material. The root PDFs are large binaries, and the generated `_recovery/` OCR
evidence may contain PII or machine-identifying content. An allow-by-default
ignore policy creates a leak risk because an accidental broad `git add` can stage
new files that were never reviewed for public publication.

## Decision

Use a deny-by-default `.gitignore` policy based on `/*` plus explicit allowlist
entries for the tracked top-level paths. Directories in the allowlist use a
trailing slash so tracked content beneath those directories remains addable.

The source PDFs and `_recovery/` are hard-denied and are never allowlisted. To
track a new top-level directory later, add a matching `!/<dir>/` allowlist entry
after review. One-off publication of an ignored file requires deliberate
force-add behavior and remains subject to the governance rules.

## Consequences

New files are ignored unless they live under an allowlisted path or the
allowlist is updated. That friction is deliberate: it makes accidental public
publication harder in a repository that handles scanned PII and large binaries.

Contributors who need to add a new top-level directory must update `.gitignore`
with an explicit allowlist line. Contributors who need a one-off ignored file
must use `git add -f` intentionally and only when the publication is approved by
the relevant owner gate.

## Owner gate

This ADR remains Draft until the owner accepts it. It supersedes the Phase 0
allow-by-default `.gitignore` after owner approval and merge.
