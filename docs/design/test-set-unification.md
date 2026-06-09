# Test/Set Execution-Dispatch Design

## Scope

This is a design analysis for folding `Get`, `Test`, and `Set` into the owner's
single Registry execution path. It proposes a route for owner review only. It
does not authorize source, tests, module metadata, `.mof`, live registry changes,
or ADR acceptance.

## Evidence Base

- The canonical-selection ledger chooses the A-spine: A `Start-ProviderSetup`,
  A `Get-TargetResource`, A separated-field normalizers, A `Mount-RegistryHive`,
  and selected B helpers such as `Get-TypedObject` and
  `Convert-ByteArrayToHexString` (`docs/design/canonical-selection.md`).
- The execution-map audit records the owner's unified-path intent, the missing
  Test and Set legs, the older A/B seam, and the post-synthesis correction that
  A is a complete JSON-driven path (`docs/design/execution-map.md`).
- `Start-ProviderSetup` is the current setup boundary: it takes one
  `[PSCustomObject]$InputObject`, declares `SupportsShouldProcess`, validates
  required properties, normalizes fields through a property-driven `Switch`,
  calls `Mount-RegistryHive`, and soft-returns a rich setup object
  (`recovered/canonical/Start-ProviderSetup.ps1:1-15`,
  `:42-59`, `:67-88`, `:94-109`).
- The canonical `Get-TargetResource` is the current read leg: it takes the rich
  setup object, opens the hive and key, prunes value reads based on which value
  fields were supplied, and soft-returns a hashtable with `KeyExists`,
  `ValueExists`, `ValueData`, and `ValueKind`
  (`recovered/canonical/Get-TargetResource.ps1:1-15`, `:40-55`,
  `:61-119`, `:121-133`).
- `Mount-RegistryHive` is the current provider setup side effect. It tests for a
  provider drive, conditionally calls `New-PSDrive -Scope:('Script')` under
  `ShouldProcess`, then re-tests the mount (`recovered/canonical/Mount-RegistryHive.ps1:35-58`).
- `ThrowError` is the recovered structured error sink
  (`recovered/canonical/ThrowError.ps1:1-58`).
- `Get-TypedObject` is useful but not implementation-ready: the owner note says
  it needs rework, it calls the absent `ArrayToString`, and it has unfinished or
  OCR-damaged typed branches (`recovered/canonical/Get-TypedObject.ps1:1-2`,
  `:30-39`, `:88-172`).
- The DSC audit says to adapt direct Get/Set/Test dispatch and the DSC resource
  contract, but to replace MOF, `Configuration`, LCM, and DSC job/pull mechanics
  (`docs/dsc-audit/AUDIT.md:9`, `:10`, `:11`, `:24`, `:26`, `:27`).
- ADR 0003 proposes operations `Get`, `Test`, and `Set`, direct dispatch, and
  evidence-friendly returns (`docs/adr/0003-resource-contract.md:36-50`).
- ADR 0004 records the no-MOF declaration-document boundary that dispatch must
  consume directly instead of relying on DSC compilation
  (`docs/adr/0004-declaration-document-format.md`).
- ADR 0005 defines observed, comparison, planned-change, changed/no-change, and
  error evidence shapes for Get/Test/Plan/Apply (`docs/adr/0005-evidence-reporting-model.md:24-49`).
- ADR 0006 separates read-only `Get`/`Test`/`Plan` from mutating apply behavior,
  requires `ShouldProcess`, and keeps Registry setup/mutation owner-gated until
  test isolation is approved (`docs/adr/0006-mutation-shouldprocess-safety.md:16-18`,
  `:24-35`, `:38-45`).

## Scoring Dimensions

Each route is evaluated on the required dimensions:

- (a) fit to the owner's single-path and run-only-necessary-steps intent.
- (b) reuse of `Start-ProviderSetup`, mount-once behavior, and canonical
  `Get-TargetResource`.
- (c) composition of Test compare behavior and Set mutation under
  `ShouldProcess`.
- (d) DSC-name compatibility.
- (e) testability with Pester mocks.
- (f) evidence/result shape fit with ADR 0005.
- (g) fit to the owner's coding style.
- (h) pros, cons, and risks.

## R1: One Mode-Driven Body

Shape: expose one public body, for example a single operation parameter such as
`-Operation Get|Test|Plan|Set`, and branch inside that one body after shared
setup.

| Dimension | Evaluation |
| --- | --- |
| (a) single-path fit | Strongest literal fit. A single body can normalize once, mount once, then branch at the action point. |
| (b) setup/Get reuse | Strong reuse if the existing A `Start-ProviderSetup` is called once and the current A `Get-TargetResource` read logic is folded into the body. Risk: folding Get into the body makes the recovered read leg less distinct. |
| (c) Test/Set composition | Technically clean: Test and Set can share the same current-state read and compare. Risk: mutation and read-only logic live in one large public function, so ADR 0006 guardrails must be very explicit. |
| (d) DSC compatibility | Weak. It does not naturally expose `Get-TargetResource`, `Test-TargetResource`, and `Set-TargetResource` names that DSC-style tooling and the audit identify as the familiar contract. A compatibility layer would be needed anyway. |
| (e) Pester-mock testability | Good for branch coverage, but the monolithic body encourages broad mocks and larger test fixtures. |
| (f) evidence shape | Good if the body returns ADR 0005 operation-specific objects. The danger is a single result type that tries to cover every mode and becomes vague. |
| (g) owner style | Partly strong: one path, Begin/Process/End, soft-return, one error sink. Partly weak: one very large body would be harder to keep in the owner's small-leaf style. |
| (h) pros/cons/risks | Pro: most direct expression of "one path." Cons: weaker DSC-name compatibility, higher function complexity, easier to blur read-only and mutation boundaries. |

Verdict: viable but not best. It captures the owner's unification instinct, but
it sacrifices the DSC-compatible operation names that the audit says are worth
adapting and would likely grow into a public mega-function.

## R2: Shared Setup Plus Thin Method Shims

Shape: implement three public functions, `Get-TargetResource`,
`Test-TargetResource`, and `Set-TargetResource`. Each one calls
`Start-ProviderSetup` and then performs only its own action.

| Dimension | Evaluation |
| --- | --- |
| (a) single-path fit | Moderate. The shared setup path is unified, but the public entrypoints are still three separate paths. This looks like DSC with a shared helper rather than the owner's single dispatch idea. |
| (b) setup/Get reuse | Strong for reuse, because all methods can consume the same setup object. Mount-once is weaker if a runner invokes Test and then Set as separate method calls; setup may run twice, though the mount helper is idempotent. |
| (c) Test/Set composition | Clear and conventional. Test can call the read leg and compare; Set can call the read/compare logic before mutation. Risk: if Set calls Test, and Test calls Get, setup can be repeated unless the setup object is passed explicitly. |
| (d) DSC compatibility | Strongest. It preserves the names in the DSC resource contract audit and maps cleanly to `Invoke-DscResource` style dispatch. |
| (e) Pester-mock testability | Strong. Each public method can be tested with mocks around setup, read, compare, and mutate boundaries. |
| (f) evidence shape | Good, but each method must be disciplined to emit the same ADR 0005 envelope or the evidence model will fragment. |
| (g) owner style | Good at the function level: thin Begin/Process/End wrappers and soft-returns are natural. Weaker at the system level because there is no single owner-visible dispatcher. |
| (h) pros/cons/risks | Pro: familiar and testable. Con: weaker "run once" guarantee; risk of reintroducing DSC's three independent method bodies. |

Verdict: safe and familiar, but not the objectively best expression of this
repo's recovered design. It preserves DSC naming well, but it underuses the
owner's unified-path intent.

## R3: Internal Dispatcher Plus Thin Compatibility Shims

Shape: add one internal operation dispatcher as the real single path, then keep
the DSC-compatible public names as thin wrappers. Working name:
`Invoke-RegistryResourceOperation`. The owner may instead choose the recovered
header sketch name `Get-TargetResourceInternal`; that name is currently
documented but absent, so it should not be silently assumed.

Recommended flow:

1. Public shim receives the resource input and desired operation:
   `Get-TargetResource`, `Test-TargetResource`, or `Set-TargetResource`.
2. The shim calls the internal dispatcher with `-Operation Get|Test|Plan|Set`
   and the input object. A TargetState runner exposes external `Apply` as the
   only mode allowed to dispatch resource `Set`.
3. The dispatcher calls `Start-ProviderSetup` once for the resource invocation,
   producing the canonical setup object.
4. The dispatcher calls the current-state read leg once. The current canonical
   `Get-TargetResource` body is the best recovered seed for this read leg.
5. The action point branches:
   - `Get`: return observed state with ADR 0005 `Observed` status.
   - `Test`: compare normalized desired properties to observed state, return
     `InDesiredState` plus `Compliant` or `NonCompliant` evidence.
   - `Plan`: return the same comparison plus proposed action, with no mutation.
   - `Set`: only when the TargetState runner is in Apply mode; run the planned
     mutation under `ShouldProcess`, then return apply evidence.
6. All failures use `ThrowError` where structured errors are available; recovered
   bare throw paths remain explicit gaps for later implementation.

| Dimension | Evaluation |
| --- | --- |
| (a) single-path fit | Strong. The internal dispatcher is the single path and can branch only at the operation action point. Public shims do not fragment the actual execution path. |
| (b) setup/Get reuse | Strongest practical fit. `Start-ProviderSetup` runs once per resource operation, the current-state read runs once, and Test/Plan/Set consume the same setup/current/desired objects. |
| (c) Test/Set composition | Strong. Test is read plus compare; Plan is compare plus proposed action; Set is Plan plus `ShouldProcess`-guarded mutation. This directly reconciles ADR 0005 and ADR 0006. |
| (d) DSC compatibility | Strong. The public names remain available for DSC-familiar resource semantics, while TargetState owns the internal dispatcher and evidence contract. |
| (e) Pester-mock testability | Strong. Tests can mock `Start-ProviderSetup`, current-state read, comparer, and mutator separately. Registry mutation stays mocked until the owner approves isolation. |
| (f) evidence shape | Strongest. The dispatcher can enforce one result envelope across Get/Test/Plan/Set and prevent each shim from inventing its own output shape. |
| (g) owner style | Strong. The pattern keeps Begin/Process/End wrappers, soft-return, one setup call, and a single structured error path without forcing one enormous public body. |
| (h) pros/cons/risks | Pros: preserves single path and DSC-compatible names; clean read-only/mutation split; best evidence consistency. Cons: adds one internal abstraction and requires owner to name it. Risk: the dispatcher must not become a broad engine before the Registry proof. |

Verdict: best route. It is the only route that preserves the owner's single
execution path and the DSC-compatible operation surface at the same time.

## Recommendation

Adopt R3: an internal operation dispatcher plus thin compatibility shims.

The recommended design is not "three independent DSC methods." It is one
TargetState-owned Registry operation path, with public `Get-TargetResource`,
`Test-TargetResource`, and `Set-TargetResource` wrappers for familiarity and
future compatibility. This fits the audit's "adapt conceptually" verdict for
Get/Test/Set and direct dispatch while still replacing DSC's MOF, LCM, and job
mechanics.

The dispatcher should be operation-aware but small. It owns the sequence:

`normalize/setup once -> read current once -> compare/plan -> optionally mutate`.

It must not implement a broad engine. For Phase 6, it should remain Registry
specific and consume the canonical setup/current-state helpers. `Get-TypedObject`
and the missing helper names remain implementation gaps; the dispatcher design
does not invent them.

Mutation remains gated. The design can describe `Set`, but implementation must
not perform live Registry mutation until ADR 0006's owner gate and Pester-mock
strategy are satisfied.

## Owner Decisions Still Needed

- Name the internal dispatcher: new explicit name such as
  `Invoke-RegistryResourceOperation`, or the recovered header sketch
  `Get-TargetResourceInternal`.
- Decide whether the public `Get-TargetResource` output should keep the A
  `KeyExists`/`ValueExists` shape, adopt the archived B `Ensure`/`Key` shape, or
  wrap either one in the ADR 0005 evidence envelope.
- Confirm that `Set-TargetResource` is a resource mutation leg dispatched only
  by TargetState Apply mode, not a standalone live mutation path.
- Confirm how much of `Start-ProviderSetup` may run in read-only modes before
  registry test isolation is approved, because the recovered setup currently
  calls `Mount-RegistryHive`.
- Confirm whether `Get-TypedObject` is completed as the typed desired-value
  comparer input, or whether a fresh typed conversion helper replaces it.
