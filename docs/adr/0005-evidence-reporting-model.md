# ADR 0005: Evidence and Reporting Model

Status: Draft

Date: 2026-06-08

## Context

Traceability: BACKLOG P5-ADR-003; AUDIT: Test-DscConfiguration; AUDIT:
Get-DscConfiguration; AUDIT: Get-DscConfigurationStatus; AUDIT: Reporting/status
behavior; AUDIT: Checksums/pull server/publishing.

TargetState needs compliance-review-friendly evidence without inheriting DSC's
LCM status store or pull-service reporting model. The Phase 4 audit says to
adapt DSC's current-state, test, and status ideas, but to avoid DSC's local
configuration store and pull reporting infrastructure for the Registry proof.

## Decision

Propose that every TargetState operation emit structured PowerShell objects and,
where requested later, serialize those objects to explicit evidence files. The
evidence model should be operation-centered rather than LCM-centered.

The common result shape should include:

- Run identity: run id, timestamp, document path or document name, operation, and
  TargetState version when known.
- Resource identity: resource type, resource name, and property key used to
  identify the instance.
- Desired input: normalized desired properties when the operation has desired
  state.
- Observed state: current properties returned by the resource `Get` operation.
- Difference list: per-property desired value, actual value, and proposed action
  where applicable.
- Status: one of `Observed`, `Compliant`, `NonCompliant`, `PlannedChange`,
  `Changed`, `NoChange`, `Skipped`, or `Error`.
- Mutation flag: whether a live mutation was attempted and whether anything
  changed.
- Messages and errors: PowerShell-friendly message text and error records,
  without secrets or host-specific evidence committed to the public repository.

Operation-specific behavior:

- `Get` returns observed state and status `Observed`.
- `Test` returns desired-vs-actual comparison, an `InDesiredState` boolean, and
  status `Compliant`, `NonCompliant`, or `Error`.
- `Plan` returns the same comparison plus proposed actions such as create,
  update, delete, or no-op. It must not mutate state.
- `Apply` returns planned action, pre-state, attempted mutation, post-state where
  safe to read, changed flag, and errors. It is allowed only under ADR 0006.

For Phase 6, the Registry proof should first validate object shape in tests
before choosing durable file output. JSON is the likely first serialized format
because Windows PowerShell 5.1 has `ConvertTo-Json`, but this ADR does not lock
the file format.

## Consequences

Structured evidence gives reviewers something better than console text while
keeping TargetState independent of DSC's status database and pull server. Tests
can assert object shape and status transitions before live mutation exists.

The model also creates a clear boundary for sensitive data. Evidence generated
on a real host may contain host-specific or compliance-sensitive facts and must
not be committed by default under the public repository rules.

The cost is that every resource needs a disciplined result shape. Registry can
prove the pattern first, and later resource families can reuse it only after the
owner accepts the direction.

## Open questions for owner

- Should the first durable evidence format be JSON only, or should command output
  plus optional JSON be enough for Phase 6?
- Where should local evidence files live, and should that path be ignored by
  default like `_recovery/`?
- What is the minimum redaction policy before any evidence can be shared or
  committed?
- Should noncompliance produce a nonzero process exit code in test mode, or
  should exit-code policy wait for the engine phase?

## Owner gate

This ADR remains Draft. Owner approval of the evidence model direction is
required before Phase 6 treats it as the result contract. Approval of direction
does not change this ADR to `Accepted` unless the owner explicitly approves that
status transition.
