# ADR 0007: Test/Set Execution Dispatch

Status: Draft

Date: 2026-06-09

## Context

The faithful canonical source now uses the A-spine: `Start-ProviderSetup`
accepts a single `[PSCustomObject]$InputObject`, normalizes fields, calls
`Mount-RegistryHive`, and emits a rich setup object. The canonical
`Get-TargetResource` consumes that setup object, reads current Registry state,
and soft-returns a hashtable with key/value existence and observed value data.

The DSC audit says to adapt the `Get`/`Test`/`Set` contract and direct dispatch
ideas, while replacing DSC `Configuration`, generated MOF, LCM, and job/pull
mechanics. ADR 0003 proposes TargetState `Get`, `Test`, and `Set` operations
with direct dispatch. ADR 0005 proposes structured operation evidence for
Get/Test/Plan/Apply. ADR 0006 requires a hard boundary between read-only
Get/Test/Plan and owner-gated mutation, with `ShouldProcess` around live
changes.

`docs/design/execution-map.md` records the recovered unified-path intent, the
missing Test and Set legs, and the post-synthesis correction that A is a
complete JSON-driven path. `docs/design/test-set-unification.md` compares three
routes:

- R1: one public mode-driven body.
- R2: shared setup plus thin `Get-/Test-/Set-TargetResource` method shims.
- R3: one internal dispatcher plus thin compatibility shims.

This ADR cites ADR 0003 for the resource contract, ADR 0004 for the no-MOF
declaration-document boundary, ADR 0005 for evidence shape, and ADR 0006 for
mutation and `ShouldProcess` safety.

## Decision

Propose R3: one internal Registry operation dispatcher plus thin public
compatibility shims.

The internal dispatcher is the real single execution path for the Registry
proof. Working name: `Invoke-RegistryResourceOperation`. The owner may choose
the recovered sketch name `Get-TargetResourceInternal` instead, but that name is
not currently implemented and should be an explicit owner decision.

The public operation names remain:

- `Get-TargetResource`: thin wrapper for current-state observation.
- `Test-TargetResource`: thin wrapper for desired-vs-actual comparison.
- `Set-TargetResource`: thin wrapper for the resource mutation leg.

The dispatcher accepts a normalized input object and an operation such as
`Get`, `Test`, `Plan`, or `Set`. A TargetState runner may expose external
`Apply`, but `Apply` is the only runner mode allowed to dispatch resource
`Set`. Direct calls to the resource mutation leg must still use
`ShouldProcess`.

The dispatcher owns this sequence:

1. Call `Start-ProviderSetup` once for the resource invocation.
2. Read current state once using the canonical `Get-TargetResource` read logic,
   or a later extracted read helper based on that body.
3. For `Get`, return observed-state evidence.
4. For `Test`, compare normalized desired state to observed state and return an
   `InDesiredState` boolean plus ADR 0005 evidence.
5. For `Plan`, return the same comparison plus proposed actions, without
   mutation.
6. For `Set`, require runner Apply mode and `ShouldProcess`, perform only the
   planned mutation, and return apply evidence.

The dispatcher must stay Registry-specific during the proof. It is not a broad
engine, resource loader, or document parser.

## Consequences

This design preserves the owner's single-path intent without losing the
DSC-familiar `Get-TargetResource`, `Test-TargetResource`, and
`Set-TargetResource` names. It also gives TargetState one place to enforce the
ADR 0005 evidence envelope and ADR 0006 read-only/apply split.

Compared with one public mode-driven body, this design avoids turning the public
resource surface into a large all-purpose function. Compared with three
independent methods, it prevents setup/read/compare/mutate logic from drifting
across separate bodies.

The cost is one extra internal abstraction. That abstraction is justified only
while it remains the Registry operation path and does not become a generic
engine ahead of Phase 6.

Implementation remains blocked on later owner-gated work:

- `Start-ProviderSetup` currently calls `Mount-RegistryHive`, and ADR 0006 says
  setup/provider side effects need approved test isolation.
- `Get-TypedObject` is unfinished and calls missing data-shaping helpers.
- The final evidence shape must decide whether the observed Registry payload
  keeps A's `KeyExists`/`ValueExists` shape, adopts B's archived `Ensure` shape,
  or wraps either inside the ADR 0005 envelope.
- Live mutation remains disallowed until the owner approves apply-mode safety
  and registry test isolation.

## Open Questions For Owner

- Should the internal dispatcher be named `Invoke-RegistryResourceOperation`,
  `Get-TargetResourceInternal`, or something else?
- Should `Get-TargetResource` return the A `KeyExists`/`ValueExists` payload, the
  archived B `Ensure`/`Key` payload, or an ADR 0005 wrapper containing one of
  those payloads?
- Should read-only `Get`/`Test`/`Plan` be allowed to perform the session-local
  PSDrive setup in `Mount-RegistryHive`, or must provider mounting be mocked or
  split out until the registry isolation strategy is approved?
- Should `Set-TargetResource` be callable directly by advanced users, or only by
  the TargetState runner's Apply mode?
- Should typed desired-value comparison complete `Get-TypedObject`, or should
  Phase 6 design a fresh conversion helper?

## Owner Gate

This ADR remains Draft. Owner approval of the dispatch route is required before
Phase 6 treats this as the implementation contract. Approval of direction does
not change this ADR to `Accepted` unless the owner explicitly approves that
status transition.
