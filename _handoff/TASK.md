# TASK - Phase 6 build (2): make-it-run the remaining leaf functions (both 5.1+7; flag API changes)
_Read `_handoff/PLAN.md` first (Mission, Section 4 Locked Rules, the make-it-run boundary + both-runtime constraint in the Change Log, Sections 0.2, 2). Read `docs/build/owner-idiom-decisions.md` (APPROVED idiom table) and `docs/build/make-it-run-log.md` + `src/Get-RegistryValueKindStr.ps1` (the build-1 pattern to follow)._

## Context
Build 1 (calibration on `Get-RegistryValueKindStr`) is merged and the make-it-run approach is
proven. Owner decisions now in force:
- TARGET = BOTH PowerShell 5.1 AND 7 compatible (lowest-common-denominator APIs).
- BOUNDARY = APPLY FREELY the OCR-artifact corrections and the APPROVED `[Type]::Empty` idiom table;
  STOP AND FLAG any API / logic / behavior change for the owner BEFORE applying.
- APPROVED PATTERNS (apply freely, no re-flag): the `[Type]::Empty` idiom table; and the enum-parse
  pattern from build 1 - the owner's PS7-only 3-arg `[Enum]::TryParse([T], $s, [ref]$x)` becomes the
  both-compatible `[T]::TryParse($s, [ref]$x)` with the by-ref target pre-typed to `[T]` first.
- STYLE: adopt the owner's vertical blank-line spacing between logical blocks (as in
  `src/Get-RegistryValueKindStr.ps1`).
`recovered/canonical/` is the immutable faithful RECORD; the runnable module is built in `src/`.

## Goal
Make the remaining COMPLETE leaf functions (no logic-completion needed) parse + run on BOTH 5.1 and
7 in `src/`, applying OCR fixes + the approved idiom/enum-parse patterns freely, FLAGGING any other
API/logic/behavior change for the owner. Per-function documentation; Pester tests; canonical untouched.

## A0. Scope - exactly these 8 functions (the pure, complete leaves)
1. `ThrowError` (B) - the single structured-error sink.
2. `Get-RegistryKeyHiveObj` (A) - hive alias -> `{Name,ShortName,Abbreviation}` descriptor.
3. `Get-RegistryKeyPathStr` (A) - path validator/normalizer.
4. `Get-RegistryKeyNameStr` (A) - name validator.
5. `Get-RegistryValueNameStr` (A) - value-name validator.
6. `Get-NormalizedRegistryKey` (B) - full-key pre-normalizer.
7. `ConvertFrom-Array` (A) - array -> single string.
8. `Convert-ByteArrayToHexString` (B) - byte array -> hex string.
EXCLUDED this step (need logic completion or contract work, done later, one at a time):
`Start-ProviderSetup`, `Get-TargetResource`, `Mount-RegistryHive`, `Get-TypedObject`,
`Get-RegistryResourceObject`. Do NOT touch them or `Get-RegistryValueKindStr`.

## A. Adversarial Review Gate
Archive `_handoff/REPORT.md` to the TOP of `_handoff/REPORT-ARCHIVE.md`
(`## Archived <UTC date> - Phase 6 build 2`, append-only), then write a new `REPORT.md` whose
verdict: restates the goal; confirms branch `recovery/phase6-build-2` (not `main`); confirms ONLY
the 8 scoped functions are touched; lists, per function, the change classes applied and any FLAGGED
items deferred to the owner.

## B. Expected Changes (branch `recovery/phase6-build-2`)
- `src/<Function>.ps1` for each of the 8 - the canonical function made to parse + run on 5.1 and 7,
  with the owner's structure/logic/comments/style preserved and the owner's vertical-spacing style.
- `tests/<Function>.Tests.ps1` for each - Pester 5.x. These 8 are PURE (no live registry), so unit
  tests, no mocks: cover the normal output and the `ThrowError` paths. (Dot-source `src/ThrowError.ps1`
  for throw-path tests once it is made-to-run; do it first.)
- `docs/build/make-it-run-log.md` - APPEND a per-function section (canonical token -> running token,
  class i/ii/iii, evidence). Keep build-1's section intact.
- `docs/build/flagged-decisions.md` (NEW, if any flags) - any API/logic/behavior change NOT covered
  by an approved pattern: describe it, why it is needed for 5.1+7, the proposed both-compatible fix,
  and the affected function. Do NOT apply it; mark that function "runs pending owner approval of the
  flagged change" (still commit the rest of its make-it-run progress).
- Optional minimal loader `src/TargetState.psm1` that dot-sources `src/*.ps1` IF it helps test
  loading; do NOT author a `.psd1` manifest yet.

## C. Guardrails
- ONLY the 8 scoped functions. Do NOT complete stubs, build dispatcher/Test/Set, or alter the
  excluded functions, `Get-RegistryValueKindStr`, or `recovered/**` (byte-unchanged faithful record).
- BOTH-RUNTIME: use only APIs present in BOTH .NET Framework 4.x (PS 5.1) and .NET Core (PS 7).
  Any 5.1-only or 7-only construct is a FLAG item unless it is the already-approved enum-parse pattern.
- Apply freely: OCR-artifact corrections (image-verified against `_recovery/.../images/` where you can;
  else mark text-only) and the APPROVED idiom table. FLAG everything else that changes behavior/API/logic.
- Preserve EXACTLY (per build-1 rules): Begin/Process/End + Write-Debug bookends, `New-Variable -Private`,
  colon-parameter syntax, every comment incl. typos, soft-return, `$True`/`$False`, hygiene blocks,
  naming, ordering. No refactor/rename/idiomize/restructure.
- Sensitive-content scan (PLAN 1.9) over newly committed files. ASCII. Offline; no installs.
- Branch `recovery/phase6-build-2`, never `main`; preserve signing; stage explicit paths. PDFs +
  `_recovery/` ignored. Do NOT edit `PLAN.md`/`TASK.md`/`CLAUDE-RESTART-PROMPT.md` content; commit as-is.

## D. Verification (run each; paste output verbatim into REPORT.md)
- Parse: each `src/<Function>.ps1` -> `[Parser]::ParseFile(...)` reports 0 errors (list all 8).
- Pester: every test file passes on PS 5.1 / Pester 5.x. If `pwsh` (PS 7) is available, run there too
  and paste both; if not, state that 7-compatibility is established by API analysis (no 5.1-only or
  7-only APIs remain unflagged) and name any API you confirmed exists in both.
- Fidelity: for EACH function paste `git diff --no-index recovered/canonical/<F>.ps1 src/<F>.ps1`
  so every change is visible and matches the classified log; nothing unexplained.
- `recovered/**` unchanged (`git status` clean there); ALL ADRs still Draft; sensitive scan clean.
- Flagged items (if any) are in `docs/build/flagged-decisions.md` and NOT applied.
- `git branch --show-current` (not `main`); `git log --show-signature -1` good.

## E. Definition of Done (ALL hold; else REPORT `Phase 6 build 2 status: BLOCKED | NEEDS-OWNER`)
- Each of the 8 (minus any FLAGGED-and-deferred) parses (0 errors) and passes Pester; flagged ones are
  documented and left for owner approval (clearly listed).
- Every change is minimal, style-preserving, both-runtime, and classified; full per-function diffs in REPORT.
- `recovered/**` byte-unchanged; ADRs Draft; sensitive scan clean.
- `REPORT.md` has the verdict, per-function summary (+ flags), the Section D output, and a final line
  `Phase 6 build 2 status: COMPLETE | BLOCKED | NEEDS-OWNER`.

## F. End State (how this cycle hands back)
- Commit on `recovery/phase6-build-2` with a signed message (e.g.
  `feat(registry): make-it-run 8 leaf functions (5.1+7) + tests`). Never commit to `main`; never bypass signing.
- Push and open a PR to `main` titled `Phase 6 build 2: make-it-run leaf functions`; in the PR body
  list each function's status (runs / runs-pending-flag) and summarize any flagged decisions for the owner.
- Finish `REPORT.md` per Section E, then STOP. Do NOT merge - the owner reviews the batch diffs and
  rules on any flagged API/logic decision before merge. Next after this: complete `Mount-RegistryHive`
  + `Get-TypedObject`, finalize `Start-ProviderSetup`, then build the R3 read leg -> dispatcher -> Test/Plan/Set.
