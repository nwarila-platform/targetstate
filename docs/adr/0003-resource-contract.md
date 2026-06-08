# ADR 0003: TargetState Resource Contract

Status: Draft

Date: 2026-06-08

## Context

Traceability: BACKLOG P5-ADR-001 and P5-SCOPE-005; AUDIT: DSC resource
contract conventions; AUDIT: Get-DscResource; AUDIT: Invoke-DscResource;
AUDIT: Resource discovery/module loading; AUDIT: Test-DscConfiguration;
AUDIT: Get-DscConfiguration; AUDIT: Get-DscConfigurationStatus.

TargetState needs a resource contract before the Registry proof can move from
recovered helper functions to an executable resource. The Phase 4 audit says to
adapt DSC's Get/Test/Set and discovery ideas, replace the Configuration/MOF/LCM
model, and explicitly skip DSC pull, publish, checksum, debug, restore, stop,
update, and MOF-store cleanup surfaces for the Registry proof.

The recovered source already contains 10 parseable helpers that are useful for a
Registry resource contract, but the source also has missing helper names and
deferred orchestration functions. Those gaps must not be hidden by inventing
aliases or treating recovered code as a complete engine.

## Decision

Propose a TargetState resource as a small PowerShell-native contract with these
parts:

- Resource identity: a resource type such as `Registry`, a per-document instance
  name, and a property bag supplied by the declaration document.
- Resource metadata: the resource type, supported operations, property schema,
  key properties, required properties, allowed values, and notes about whether a
  property can be returned as evidence. This metadata replaces MOF schema for the
  Registry proof.
- Operations: `Get`, `Test`, and `Set`. `Get` returns current state, `Test`
  compares desired and current state without mutation, and `Set` performs
  idempotent mutation only when apply mode is explicitly selected and safety
  gates allow it.
- Direct dispatch: TargetState may dispatch a resource operation directly from a
  resource type and property bag, adapting the useful shape of
  `Invoke-DscResource` while owning the parameter contract and evidence output.
- `Ensure`: resources may use `Ensure` with `Present` and `Absent` as the common
  existence convention. The Registry proof should use that convention for keys
  and values where the declaration needs existence semantics.
- Typed properties: resource properties have declared types before operation
  dispatch. Registry properties include hive, path, key name, value name, value
  kind, value data, and `Ensure`. String normalization helpers can feed this
  contract, but the resource contract is not string-only.
- Evidence-friendly returns: every operation returns structured objects suitable
  for the evidence model in ADR 0005. Operation returns should include resource
  identity, operation, normalized desired input where relevant, observed state,
  result status, differences, messages, and errors.

For the Registry proof, the 10 stabilized recovered functions fit as inputs to
normalization, conversion, and error handling:

- `Get-NormalizedRegistryKey.ps1`, `Get-RegistryKeyHive.ps1`,
  `Get-RegistryKeyPath.ps1`, `Get-RegistryKeyPathStr.ps1`, and
  `Get-RegistryKeyNameStr.ps1` support canonical Registry key addressing.
- `Get-RegistryValueNameStr.ps1` and `Get-RegistryValueKindStr.ps1` support
  value-property normalization.
- `Convert-ByteArrayToHexString.ps1` and `ConvertFrom-Array.ps1` support value
  data representation and evidence formatting.
- `ThrowError.ps1` supports consistent PowerShell error records.

The following helper designs are proposed as fresh TargetState design work, not
recovered aliases: `Get-NormalizedRegistryKeyString`, `ArrayToString`, and
`Get-RegistryKeyType`. The Phase 6 implementation may add those only after tests
define the intended behavior.

Compatibility boundary: TargetState should adapt DSC's resource discovery,
Get/Test/Set operation pattern, `Ensure` convention, and direct dispatch concept.
TargetState should not provide DSC `Configuration` blocks, generated MOF,
LCM-managed consistency, pull/publish/checksum behavior, DSC debug commands,
DSC restore/stop/update commands, or MOF document cleanup in the Registry proof.

## Consequences

The Registry proof can be reviewed against a narrow contract before a broad
engine exists. The contract keeps the recovered functions useful without letting
their incomplete orchestration shape dictate the product.

This proposal also makes Phase 6 testable: pure normalization and metadata tests
can come first, current-state and test-mode orchestration can follow, and apply
mode remains blocked behind ADR 0006 and owner approval.

The cost is that TargetState will not be a drop-in DSC command replacement. That
is intentional for the current mission: plain declaration documents in git,
explicit dispatch, and auditable evidence are more important than matching DSC's
MOF and LCM surfaces.

## Open questions for owner

- Should resource metadata be expressed as PowerShell data (`.psd1` or objects),
  YAML alongside declarations, or a simple script-returned schema for the first
  Registry proof?
- Should the first operation names stay generic (`Get`, `Test`, `Set`) inside a
  resource module, or use explicit TargetState names to avoid colliding with DSC
  `Get-TargetResource` naming?
- Should Phase 6 preserve DSC-style `Get-TargetResource` naming as a compatibility
  adapter, or keep that only as recovered-code provenance?
- What minimum discovery surface is enough for the first proof: resource listing,
  schema output, direct dispatch, or all three?

## Owner gate

This ADR remains Draft. Owner approval of the contract direction is required
before Phase 6 treats it as the implementation contract. Approval of direction
does not change this ADR to `Accepted` unless the owner explicitly approves that
status transition.
