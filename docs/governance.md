# TargetState Governance

This document is the Phase 0 rule ledger for the public
`nwarila-platform/targetstate` repository.

## Roles

- Claude plans and reviews. Claude owns `_handoff/PLAN.md`,
  `_handoff/TASK.md`, and `_handoff/CLAUDE-RESTART-PROMPT.md`.
- Codex challenges the plan and implements scoped tasks. Codex owns
  `_handoff/REPORT.md` and `_handoff/REPORT-ARCHIVE.md`.
- The owner gates merges to `main`, live machine changes, ADR acceptance, and
  public publication decisions.

## Branch And Commit Rules

- Work lands on a working branch, never directly on `main`.
- Phase 0 uses `recovery/phase-0-governance`.
- Commit signing stays enabled. Do not bypass signing to make progress.
- Stage only explicit intended paths. Do not use `git add -A`, `git add .`, or
  wildcard staging for this recovery workflow.

## Public Repository Rules

- Treat every pushed commit as permanent and world-readable.
- Do not commit secrets, credentials, private keys, host-specific evidence,
  generated machine state, or personally identifying data.
- Do not commit files larger than 1 MB, PDFs, or other large binaries without
  explicit owner approval recorded in the handoff change log.

## ADR Rules

- ADRs live under `docs/adr/`.
- ADR filenames use `NNNN-kebab-title.md`.
- Every ADR starts as `Status: Draft`.
- No ADR becomes `Accepted` without owner approval.

## Technical Guardrails

- Target Windows PowerShell 5.1 first.
- Prefer PowerShell-native patterns and Pester tests.
- Do not touch live Windows registry or system state without owner approval.
- Do not create a broad engine before the resource contract is reviewed.
- Registry tests must use isolated test hives, isolated paths, or mocks until a
  live-change test strategy is approved.
- Do not promise STIG compliance until controls are mapped, testable, and backed
  by evidence.

## PDF And Recovery Disposition

Recorded Phase 0 disposition: local-only + SHA-256 manifest.

- `06042026.pdf` is local-only by default and ignored by git.
- `06042026_001.pdf` is local-only by default and ignored by git.
- `/_recovery/` is local-only by default and ignored by git.
- No git-lfs filter is used while the PDFs are local-only.
- Phase 0 records each PDF SHA-256 and byte size in `_handoff/REPORT.md`.
- Phase 1 is expected to create the `_recovery/manifest.json` SHA-256 manifest
  if and when Gate 0 -> 1 is green. Phase 0 does not create `_recovery/`.

## Tooling And Extraction Rules

- Do not install or download tooling without explicit owner approval.
- Do not open, parse, OCR, extract, or audit PDF contents outside the phase that
  authorizes that work.
- Extraction and OCR, when later authorized, run locally/offline unless the owner
  approves otherwise.
