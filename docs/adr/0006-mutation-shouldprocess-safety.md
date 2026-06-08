# ADR 0006: Mutation and ShouldProcess Safety

Status: Draft

Date: 2026-06-08

## Context

Traceability: BACKLOG P5-ADR-004; AUDIT: Start-DscConfiguration; AUDIT: LCM
responsibilities; AUDIT: Set-DscLocalConfigurationManager; AUDIT:
Resource discovery/module loading; GAP:D07; GAP:D08.

TargetState needs mutation eventually, but the repo rules explicitly block live
Windows registry or system changes without owner approval. The Phase 4 audit
says to replace DSC's LCM service model with explicit TargetState runner
behavior. The recovery gaps show that `Mount-RegistryHive` (GAP:D07) and
`Start-ProviderSetup` (GAP:D08) have registry provider or setup side effects and
must wait for an approved test-isolation strategy.

## Decision

Propose a hard separation between read-only operation and mutation:

- `Get`, `Test`, and `Plan` are read-only modes. They must not call resource
  `Set` operations or live mutation helpers.
- `Apply` is the only mode allowed to call resource `Set` operations.
- Apply mode remains owner-gated for the Registry proof and must not be enabled
  merely because the ADRs exist.
- There is no DSC LCM equivalent in the Registry proof: no background service,
  no hidden consistency loop, no meta-MOF, and no implicit pull refresh.

PowerShell mutation functions should use Windows PowerShell 5.1-compatible
`ShouldProcess` behavior where mutation is possible. Resource `Set` operations
and setup helpers should use `[CmdletBinding(SupportsShouldProcess = $true)]`
and call `$PSCmdlet.ShouldProcess(...)` around each live change. The runner
should preserve `-WhatIf` and confirmation semantics instead of bypassing them.

For Registry work, Phase 6 must approve a test-isolation strategy before any
side-effecting tests are written. Acceptable strategies may include mocks,
temporary isolated hives, temporary PSDrives backed by disposable files, or
owner-approved isolated registry paths. Tests must not mutate ordinary live
HKLM/HKCU paths by default.

`Mount-RegistryHive` and `Start-ProviderSetup` should remain deferred until the
test-isolation design proves setup, cleanup, and failure behavior. Any apply-mode
implementation should produce ADR 0005 evidence that records what was planned,
what was attempted, what changed, and what failed.

## Consequences

The first Registry proof can build confidence in parsing, normalization,
current-state reads, and plan output before mutating anything. That matches the
public-repo and live-machine safety rules.

The downside is that apply mode will arrive later than test and plan mode. That
is acceptable because unsafe mutation would be harder to review than a smaller
read-only proof.

This proposal also avoids accidental DSC LCM drift. TargetState mutation is an
explicit command choice, not a background node policy.

## Open questions for owner

- Which registry test-isolation strategy should Phase 6 use first: mocks,
  disposable hive files, or a tightly scoped owner-approved registry path?
- Should Registry apply mode require an explicit `-Apply` switch in addition to
  an operation name, or is a top-level `Apply` command enough?
- What `ConfirmImpact` should Registry mutation use for key creation, value
  writes, hive mounts, and provider setup?
- Should TargetState ever grow a long-running agent, or should the Registry proof
  keep all mutation explicit and command-scoped?

## Owner gate

This ADR remains Draft. Owner approval of the mutation-safety direction and the
separate registry test-isolation strategy is required before Phase 6 performs
live mutation or writes side-effecting registry tests. Approval of direction does
not change this ADR to `Accepted` unless the owner explicitly approves that
status transition.
