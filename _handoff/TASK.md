# TASK - Phase 6 build (5): complete + make-it-run Start-ProviderSetup (the setup keystone; mock tests)
_Read `_handoff/PLAN.md` first (Mission, Section 4 Locked Rules, the both-runtime + flag-API constraints AND the new PRE-APPROVED RECURRING-FIX classes in the Change Log). Read `recovered/canonical/Start-ProviderSetup.ps1`, the merged `src/` functions (the established pattern), and `src/Mount-RegistryHive.ps1` (a dependency, to mock)._

## Context
`Start-ProviderSetup` is the A-spine normalization keystone: it takes a declaration `[PSCustomObject]
$InputObject` (separated fields), validates required props, normalizes each supplied field via the
already-built `src/` normalizers, mounts the hive via `Mount-RegistryHive`, and soft-returns the
canonical setup object. It is the function the Get read leg + the R3 dispatcher will call. Its issues
are almost entirely the OWNER-PRE-APPROVED recurring bug-classes; apply those + the approved make-it-run
patterns, and flag only genuinely new decisions. `recovered/canonical/` stays the faithful record.

## A0. Apply these (pre-approved) - and flag anything genuinely NEW
Make-it-run (apply freely): leading commas in `[CmdletBinding(`/`[Parameter(`; `[PSCustomObject]::Empty`
-> `$Null` (approved idiom); the space in `[PSCustomObject ]@{` -> `[PSCustomObject]@{`; the stray
leading `;` before the final `Write-Debug` (line 120).
Pre-approved recurring-class fixes (apply + document in make-it-run log):
1. LEADING-COMMA ARRAY: `New-Variable ... ALL_REQUIRED_PROPERTIES -Value:([System.Array]( , 'KeyHive',
   'KeyName'))` -> remove the leading comma: `[System.Array]('KeyHive', 'KeyName')` (same nesting bug
   already fixed in the hive aliases).
2. CLEANUP LISTS: the `Clear-Variable` (lines 38-41) and `Remove-Variable` (lines 116-119) name a
   nonexistent `RegistryKey`; align both to the variables actually declared (`Result`, `KeyHive`,
   `KeyName`, `KeyPath`, `ValueName`, `ValueKind`, `ValueData`).
3. HARDCODED PLACEHOLDER: `-ExceptionMessage:($LocalizedData.ParameterRequired -f 'Something')` ->
   `-f $RequiredProperty` so the error names the actual missing property.
4. OCR-UNREADABLE COMMENT (line 45, `# ee oe ww coe ...`): it is illegible OCR; replace it with a
   single `# <#OCR-UNREADABLE#>` marker (do NOT invent the owner's words).
DEFER - do NOT change, just keep as-is and NOTE in REPORT:
- The commented-out `Get-RegistryValueData` call (lines 85-88): `ValueData` stays the raw passthrough
  (`$InputObject.ValueData`) until `Get-TypedObject` is reworked for Test/Plan. Leave the comment lines.
- The `-WhatIf` / SupportsShouldProcess internal-suppression issue (same as `Mount-RegistryHive`): do
  NOT fix it here; it is deferred to Apply-mode. Note it once in `docs/build/flagged-decisions.md`
  (or reference the existing Mount note) as also applying to `Start-ProviderSetup`.
If anything else needs a behavior/API/logic decision that is NOT one of the pre-approved classes, FLAG
it and do not guess.

## A. Adversarial Review Gate
Archive `_handoff/REPORT.md` to the TOP of `_handoff/REPORT-ARCHIVE.md`
(`## Archived <UTC date> - Phase 6 build 5`, append-only), then write a new `REPORT.md` whose verdict:
restates the goal; confirms branch `recovery/phase6-build-5` (not `main`); confirms ONLY
`Start-ProviderSetup` is added to `src/`; lists each change by class (make-it-run / pre-approved-recurring /
deferred-noted / new-flag).

## B. Expected Changes (branch `recovery/phase6-build-5`)
- `src/Start-ProviderSetup.ps1` - canonical made to parse + run on 5.1 + 7 with the above, the owner's
  structure/style/comments/vertical-spacing preserved.
- `tests/Start-ProviderSetup.Tests.ps1` - Pester 5.x. Dot-source the REAL pure dependencies from `src/`
  (`Get-RegistryKeyHiveObj`, `Get-RegistryKeyNameStr`, `Get-RegistryKeyPathStr`, `Get-RegistryValueNameStr`,
  `Get-RegistryValueKindStr`, `ThrowError`) and MOCK `Mount-RegistryHive` (no live registry). Cover:
  (a) a valid `[PSCustomObject]` declaration (e.g. KeyHive='HKLM', KeyName='Software\Example', ValueName,
      ValueKind='DWord', ValueData) -> returns the canonical setup object with the normalized fields, and
      `Mount-RegistryHive` invoked once (mock);
  (b) a missing required property (no KeyHive) -> structured `ThrowError 'ParameterRequired'` naming the
      missing property;
  (c) an unexpected property -> `Write-Warning` (mock or capture) and no throw.
- `docs/build/make-it-run-log.md` - append a `Start-ProviderSetup` section (token -> token, class).
- `docs/build/flagged-decisions.md` - the deferred WhatIf note (and any genuinely new flag).

## C. Guardrails
- ONLY `Start-ProviderSetup`. Do NOT touch other `src/` functions, the excluded canonical functions
  (`Get-TypedObject`, `Get-TargetResource`, `Get-RegistryResourceObject`), or `recovered/**`.
- BOTH-RUNTIME (5.1 + 7): flag any 5.1-only / 7-only construct (none expected here).
- Preserve the owner's exact style; change only make-it-run + the pre-approved classes. No refactor/rename.
- NO live registry/system access (mock `Mount-RegistryHive`). ADRs stay Draft. Sensitive-content scan.
  ASCII. Offline. Branch `recovery/phase6-build-5`, never `main`; preserve signing; explicit paths.
  Do NOT edit `PLAN.md`/`TASK.md`/`CLAUDE-RESTART-PROMPT.md` content; commit as-is.

## D. Verification (run each; paste output verbatim into REPORT.md)
- Parse: `src/Start-ProviderSetup.ps1` -> 0 parse errors.
- Pester: the test file passes (all cases) on PS 5.1 / Pester 5.x; mock asserts NO live `Mount-RegistryHive`
  side-effect (mocked). Whole `tests/` suite still green. If `pwsh` available, run on 7 too; else assert
  both-runtime by API analysis.
- Fidelity: `git diff --no-index recovered/canonical/Start-ProviderSetup.ps1 src/Start-ProviderSetup.ps1`
  in full; every change maps to a class in A0; nothing unexplained.
- `recovered/**` unchanged; ADRs Draft; sensitive scan clean.
- `git branch --show-current` (not `main`); `git log --show-signature -1` good.

## E. Definition of Done (ALL hold; else REPORT `Phase 6 build 5 status: BLOCKED | NEEDS-OWNER`)
- `src/Start-ProviderSetup.ps1` parses (0 errors) and its mocked Pester tests pass; full suite green.
- Only make-it-run + pre-approved-recurring fixes applied (deferred items left as-is + noted); full diff in
  REPORT, nothing unexplained; any new decision flagged not guessed.
- `recovered/**` byte-unchanged; ADRs Draft; sensitive scan clean.
- `REPORT.md` has the verdict, the change list by class, the Section D output, and a final line
  `Phase 6 build 5 status: COMPLETE | BLOCKED | NEEDS-OWNER`.

## F. End State (how this cycle hands back)
- Commit on `recovery/phase6-build-5` with a signed message (e.g.
  `feat(registry): complete + make-it-run Start-ProviderSetup (mock tests)`). Never `main`; never bypass signing.
- Push and open a PR to `main` titled `Phase 6 build 5: Start-ProviderSetup`; PR body shows the
  canonical->src diff grouped by change class.
- Finish `REPORT.md` per Section E, then STOP. Do NOT merge. Next after this: the JSON declaration importer
  + the Get read leg + the R3 internal dispatcher (a working Get path), then Get-TypedObject + Test/Plan, then Set.
