# TASK - Phase 6: Read-only Registry Proof (JSON -> Get/Test/Plan)
_Read `_handoff/PLAN.md` first - Section 1 (Mission), Section 4 (Locked Rules), Section 6 "Phase 6", and Sections 0.2, 2. Read the contract ADRs `docs/adr/0003-0006`. This is the first real resource implementation, scoped READ-ONLY._

## Gate status
Phase 5 contract ADRs are merged (PR #9 / `3ac0c3a`), all Draft. Owner decisions:
declaration format = JSON (PS 5.1 `ConvertFrom-Json`, no dependency); registry tests =
Pester MOCKS (no real registry). The 10 stabilized functions are in `src/`. Work on a
NEW branch `recovery/phase-6-registry-readonly`.

## Goal
Build the first real TargetState resource: a READ-ONLY Registry proof. Parse a JSON
declaration document into resource instances, then implement the `Get`, `Test`, and
`Plan` operations (per ADR 0003) producing structured evidence objects (per ADR 0005),
reusing the 10 recovered functions and designing any missing helpers fresh - all tested
with Pester MOCKS so no real registry is touched. Do NOT implement `Set`/`Apply` or any
live registry mutation, and do NOT implement the deferred side-effect functions
(`Mount-RegistryHive`, `Start-ProviderSetup`) - those stay owner-gated for a later cycle.

## A0. Owner Decisions (recorded; apply)
- Declaration format: JSON (first proof). Parse with built-in `ConvertFrom-Json`; do NOT
  add a YAML/JSON parser dependency.
- Registry test-isolation: Pester MOCKS only - NO test reads or writes a real registry
  hive. Mock the registry-access cmdlets.
- Scope: READ-ONLY (`Get`/`Test`/`Plan`). `Set`/`Apply` and live mutation are DEFERRED and
  remain owner-gated (ADR 0006). ADRs stay `Status: Draft`.

## A. Adversarial Review Gate
Archive the current Phase 5 `_handoff/REPORT.md` to the TOP of
`_handoff/REPORT-ARCHIVE.md` (`## Archived <UTC date> - Phase 6 read-only`, append-only),
then write a new `REPORT.md` beginning with a verdict that:
1. Restates the goal; confirms branch is `recovery/phase-6-registry-readonly` (not `main`).
2. Confirms inputs: ADRs 0003-0006 + the 10 `src/` functions exist; both PDFs hash-match
   the PLAN Section 7 baseline (they are not used here, just integrity-checked).
3. Confirms READ-ONLY scope: no `Set`/`Apply`, no live registry mutation, no real registry
   access in tests (all mocked), no deferred side-effect functions implemented.
4. Lists the new functions you will add and the missing helpers you will design fresh.

## B. Expected Changes (branch `recovery/phase-6-registry-readonly`)
- Revise the two Draft ADRs to record the owner decisions (keep `Status: Draft`):
  - `docs/adr/0004-declaration-document-format.md` -> JSON-first (replace the YAML decision
    with JSON; convert the illustrative example to JSON; note YAML was the initial
    suggestion and may return later). Update its traceability/consequences accordingly.
  - `docs/adr/0006-mutation-shouldprocess-safety.md` -> record that the first registry
    tests use Pester MOCKS (resolving its test-isolation open question).
- New `src/<Name>.ps1` for the read-only Registry proof (flat `src/`, one function per file,
  each with a provenance/design comment block; design fresh helpers, do NOT alias absent
  recovered names):
  - A JSON declaration loader/validator: parse a `TargetDocument` JSON (apiVersion/kind/
    metadata/resources per ADR 0004) via `ConvertFrom-Json` into validated resource
    instances; reject malformed/unknown shapes with `ThrowError`.
  - The Registry resource read operations: `Get` (read current registry state for a declared
    value), `Test` (desired-vs-actual comparison returning an `InDesiredState` boolean), and
    `Plan` (proposed create/update/delete/no-op actions; MUST NOT mutate). Use the recovered
    normalizers (`Get-RegistryKeyHive`, `Get-NormalizedRegistryKey`, `Get-RegistryKeyPath`,
    `Get-RegistryValueKindStr`, `Get-RegistryValueNameStr`, `Convert-ByteArrayToHexString`,
    etc.) for key/value addressing and formatting.
  - Any missing helper the read path needs (e.g. value-kind/type handling), designed FRESH
    with tests defining intended behavior (ADR 0003; do not invent a recovered alias).
  - An evidence-object builder producing the ADR 0005 result shape (run/resource identity,
    desired input, observed state, difference list, status enum, mutation flag=false here,
    messages/errors).
- `tests/<Name>.Tests.ps1` for every new function, using Pester MOCKS for ALL registry
  access (mock `Get-ItemProperty`/`Get-Item`/`Get-ChildItem`/`Test-Path` on registry paths,
  etc.). No test touches a real hive.
- A sample JSON declaration under `examples/` (e.g. `examples/registry-proof.json`) used by
  a read-only demo. (`examples/` is a new top-level dir -> add `!/examples/` to `.gitignore`
  per ADR 0002.)

## C. Guardrails
- READ-ONLY. Implement `Get`/`Test`/`Plan` ONLY. Do NOT implement `Set`/`Apply`, call any
  registry-mutation cmdlet, or implement `Mount-RegistryHive`/`Start-ProviderSetup`.
- NO real registry in tests: every registry access in tests is mocked. NO test may read or
  write a live hive. (Real registry READS are allowed only in the actual `Get` runtime code,
  never executed against a real hive by the test suite.)
- Missing helpers designed FRESH with tests; never alias an absent recovered name. Do not
  change the behavior of the 10 existing `src/` functions (reuse them as-is).
- JSON via built-in `ConvertFrom-Json`; NO parser dependency, NO tooling install.
- ADRs 0004/0006 revisions stay `Status: Draft`; do NOT mark any ADR `Accepted`.
- Sensitive-content scan (PLAN 1.9) over new `src/`+`tests/`+`examples/` before committing;
  on any hit, do NOT commit, mark NEEDS-OWNER. Keep both PDFs byte-identical (integrity check
  only; they are not used here). Offline; no installs.
- Branch `recovery/phase-6-registry-readonly`, never `main`; preserve signing; stage explicit
  paths only. `_recovery/` + PDFs stay ignored. Do NOT edit `PLAN.md`/`TASK.md`/
  `CLAUDE-RESTART-PROMPT.md` content, but commit them as-is for durability. ASCII; no-BOM UTF-8.

## D. Verification (run each; paste output verbatim into REPORT.md)
- Every `src/*.ps1` (existing + new) parses with ZERO errors (PS 5.1 AST loop).
- Pester over `tests/` is green; report counts. Confirm registry access in tests is mocked
  (e.g. show the `Mock` statements / that no test hits a real hive).
- Read-only demo: load `examples/registry-proof.json`, run `Get`/`Test`/`Plan` against a
  MOCKED registry state, and paste the resulting evidence objects. No mutation occurs.
- A scan shows NO `Set`/`Apply`/registry-mutation cmdlet in `src/` read-path code and none
  implemented this cycle.
- Sensitive-content scan over new files is clean. ADRs 0004/0006 still `Status: Draft`
  (the all-ADR Draft scan prints nothing). PDFs hash-identical to baseline.
- `git branch --show-current` (not `main`); `git log --show-signature -1` good;
  `git check-ignore -v examples/` resolves (allowlisted), PDFs + `_recovery/` still ignored.

## E. Definition of Done (ALL hold; else REPORT `Phase 6 (read-only) status: BLOCKED | NEEDS-OWNER`)
- A JSON `TargetDocument` parses + validates into Registry resource instances.
- `Get`/`Test`/`Plan` are implemented (no `Set`/`Apply`), each returning an ADR 0005 evidence
  object; the read-only demo runs end-to-end against mocked registry state.
- Every new `src/*.ps1` parses clean; every new function has Pester tests that PASS using
  mocks; no real registry is touched by tests. Missing helpers were designed fresh + tested.
- ADRs 0004 (JSON) and 0006 (mocks) revised and still `Status: Draft`; no ADR Accepted; no
  `Set`/`Apply`/mutation; deferred side-effect functions untouched.
- Sensitive-content scan clean; new `src/`/`tests/`/`examples/` committed + allowlisted; PDFs
  untouched. `REPORT.md` has the verdict, Section D output (incl. the demo), and a final line
  `Phase 6 (read-only) status: COMPLETE | BLOCKED | NEEDS-OWNER`.

## F. End State (how this cycle hands back)
- Commit on `recovery/phase-6-registry-readonly` with a signed message (e.g.
  `feat(registry): read-only Registry proof - JSON declaration + Get/Test/Plan`). Commit the
  new `src/`/`tests/`/`examples/`, the `.gitignore` `!/examples/` allowlist, the ADR 0004/0006
  revisions, `_handoff/REPORT*.md`, and the Claude-updated planner docs - ONLY if the PII scan
  is clean. Never commit to `main`; never bypass signing.
- Push the branch and open a PR to `main` titled `Phase 6: read-only Registry proof`; paste
  the Section D demo + test output in the PR body.
- Finish `REPORT.md` per Section E, then STOP. Do NOT merge - the owner admin-merges after
  Claude's audit. Apply mode is a SEPARATE later cycle and stays owner-gated.
