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

For the first read-only Registry proof, the owner approved Pester mocks as the
test-isolation strategy. Phase 6 tests must mock every registry-access cmdlet
they exercise, including reads such as `Test-Path`, `Get-Item`, and
`Get-ItemProperty`. Those tests must not read from or write to ordinary live
HKLM/HKCU paths.

Future side-effecting Registry tests still need a separate owner-approved
strategy before they are written. Acceptable later strategies may include
temporary isolated hives, temporary PSDrives backed by disposable files, or
owner-approved isolated registry paths.

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

- Which registry test-isolation strategy should future apply-mode tests use:
  disposable hive files, a tightly scoped owner-approved registry path, or
  another explicitly approved approach?
- Should Registry apply mode require an explicit `-Apply` switch in addition to
  an operation name, or is a top-level `Apply` command enough?
- What `ConfirmImpact` should Registry mutation use for key creation, value
  writes, hive mounts, and provider setup?
- Should TargetState ever grow a long-running agent, or should the Registry proof
  keep all mutation explicit and command-scoped?

## Owner gate

This ADR remains Draft. The owner approved Pester mocks for the first read-only
Registry proof. Live mutation and side-effecting registry tests remain blocked
until separately approved. Approval of direction does not change this ADR to
`Accepted` unless the owner explicitly approves that status transition.
