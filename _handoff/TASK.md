# TASK - Phase 6 build (4): complete + make-it-run Mount-RegistryHive (mock tests; owner-approved fixes)
_Read `_handoff/PLAN.md` first (Mission, Section 4 Locked Rules, the both-runtime + flag-API constraints, ADR 0006 mutation/ShouldProcess + Pester-mocks). Read `recovered/canonical/Mount-RegistryHive.ps1` and the build-1..3 `src/` functions for the established pattern + `src/ThrowError.ps1` for the error-sink signature._

## Context
First registry-touching function, so it introduces the Pester MOCK pattern (ADR 0006: no live
registry side-effects in tests). `Mount-RegistryHive` is incomplete WIP and does NOT parse as-is
(brace imbalance). The owner reviewed it and pre-approved the completions below; apply exactly those
plus the approved make-it-run patterns. `recovered/canonical/` stays the immutable faithful record.

## A0. Apply these OWNER-APPROVED changes (and the approved make-it-run patterns) - nothing more
Make-it-run (apply freely): `[System.Boolean]::Empty` -> `$False` (approved idiom); OCR fixes -
the doubled `,,` in `[CmdletBinding(`; the stray `;` (line 67) and the `# ---- J` garbled comment
(line 44); `System.I0.IOException` -> `System.IO.IOException`; `[System.Nullable]$Null` -> `$Null`
(the soft-return value; this is a side-effect function that returns nothing meaningful - if you
judge a different minimal form is needed, document it).
Owner-approved completions:
1. BRACE FIX: close the `If ($RegistryIsMounted -eq $False)` block immediately AFTER its throw, so
   the `Set-Variable Result` + soft-return `$Result` + `Write-Debug 'Exiting Block: Process'` run on
   the SUCCESS path (currently they are trapped inside the failure branch), and add the missing
   Function-closing brace so Begin/Process/End nest correctly.
2. CLEANUP LIST: fix the `End` `Remove-Variable` list to the variables this function actually
   declares - `Result`, `RegistryKeyStr`, `ShouldMountRegistry`, `RegistryIsMounted` (drop the
   nonexistent `RegistryKey`, `REGISTRY_NAME`, `ShouldMountDrive`).
3. STRUCTURED ThrowError (owner chose this over the bare Throw): replace `Throw "Unable to mount
   registry"` with a structured `ThrowError` call matching the `src/ThrowError.ps1` parameters and the
   owner's single-error-sink pattern - a mount-failure `-ErrorId` (e.g. `RegistryHiveMountFailed`),
   `-ErrorCategory` (e.g. `InvalidOperation`), `-ExceptionName:'System.IO.IOException'`,
   `-ExceptionObject:$RegistryHive`, and `-ExceptionMessage:` a `$LocalizedData.<key>` consistent with
   the pattern. If the `$LocalizedData` table / a suitable key is not yet present in the module, use a
   clear literal message and NOTE in REPORT that the localized key + data table are a pending
   module-assembly item (the throw-path test asserts ErrorId/exception type, not message text).
   Keep the commented original lines? No - remove them; this is the approved replacement.
4. SHOULDPROCESS (owner chose standard target+action): `If ($PSCmdlet.ShouldProcess($RegistryHive.Name,
   'Mount registry hive')) { ... }` around the `New-PSDrive`. Drop the malformed `(''),  $null,  $null`.

If you encounter ANY other ambiguity/behavior decision beyond the above, FLAG it in
`docs/build/flagged-decisions.md` with a proposal and do NOT guess.

## A. Adversarial Review Gate
Archive `_handoff/REPORT.md` to the TOP of `_handoff/REPORT-ARCHIVE.md`
(`## Archived <UTC date> - Phase 6 build 4`, append-only), then write a new `REPORT.md` whose verdict:
restates the goal; confirms branch `recovery/phase6-build-4` (not `main`); confirms ONLY
`Mount-RegistryHive` is added to `src/`; lists each applied change vs the approved set; confirms tests
mock all registry access (no live mount).

## B. Expected Changes (branch `recovery/phase6-build-4`)
- `src/Mount-RegistryHive.ps1` - the canonical function made to parse + run on 5.1 + 7 with the
  owner-approved completions above and the owner's structure/style/comments/spacing preserved.
- `tests/Mount-RegistryHive.Tests.ps1` - Pester 5.x using MOCKS for `Test-Path` and `New-PSDrive`
  (and any other registry/provider call); NO live registry, NO real `New-PSDrive`. Cover:
  (a) already-mounted: `Test-Path` -> $True, asserts `New-PSDrive` is NOT called, no throw;
  (b) unmounted-then-mounted: first `Test-Path` -> $False, `New-PSDrive` mocked, re-`Test-Path` -> $True, no throw;
  (c) mount-failure: `Test-Path` stays $False, asserts the structured `ThrowError` (ErrorId/exception type);
  (d) `-WhatIf`: `ShouldProcess` false path - `New-PSDrive` NOT called.
  Dot-source `src/ThrowError.ps1` for the throw assertions.
- `docs/build/make-it-run-log.md` - append a `Mount-RegistryHive` section (token -> token, class).
- `docs/build/flagged-decisions.md` - only if a NEW decision arises.

## C. Guardrails
- ONLY `Mount-RegistryHive`. Do NOT touch other `src/` functions, the excluded canonical functions,
  or `recovered/**` (byte-unchanged faithful record).
- BOTH-RUNTIME (5.1 + 7): `New-PSDrive`, `Test-Path`, `ShouldProcess`, `ThrowError`, char ops all exist
  in both; flag anything that does not.
- Preserve the owner's exact style (Begin/Process/End + Write-Debug bookends, `New-Variable -Private`,
  colon-syntax, comments incl. typos, soft-return, vertical spacing). Change only what the approved set
  + make-it-run requires. No refactor/rename/reformat.
- NO live registry/system mutation anywhere (function or tests). ADRs stay Draft. Sensitive-content scan.
  ASCII. Offline. Branch `recovery/phase6-build-4`, never `main`; preserve signing; explicit paths.
  Do NOT edit `PLAN.md`/`TASK.md`/`CLAUDE-RESTART-PROMPT.md` content; commit as-is.

## D. Verification (run each; paste output verbatim into REPORT.md)
- Parse: `src/Mount-RegistryHive.ps1` -> 0 parse errors.
- Pester: the test file passes (all 4 cases) on PS 5.1 / Pester 5.x; mocks confirm NO live registry
  access (e.g. assert `New-PSDrive` mock call counts). If `pwsh` available, run on 7 too; else assert
  both-runtime by API analysis.
- Fidelity: `git diff --no-index recovered/canonical/Mount-RegistryHive.ps1 src/Mount-RegistryHive.ps1`
  in full; every change maps to the approved set / make-it-run log; nothing unexplained.
- `recovered/**` unchanged; ADRs Draft; sensitive scan clean.
- `git branch --show-current` (not `main`); `git log --show-signature -1` good.

## E. Definition of Done (ALL hold; else REPORT `Phase 6 build 4 status: BLOCKED | NEEDS-OWNER`)
- `src/Mount-RegistryHive.ps1` parses (0 errors) and its mocked Pester tests pass (no live registry).
- Only the owner-approved changes + make-it-run patterns were applied; full diff in REPORT, nothing
  unexplained; any new decision is flagged, not guessed.
- `recovered/**` byte-unchanged; ADRs Draft; sensitive scan clean.
- `REPORT.md` has the verdict, the change list vs approved set, the Section D output, and a final line
  `Phase 6 build 4 status: COMPLETE | BLOCKED | NEEDS-OWNER`.

## F. End State (how this cycle hands back)
- Commit on `recovery/phase6-build-4` with a signed message (e.g.
  `feat(registry): complete + make-it-run Mount-RegistryHive (mock tests)`). Never commit to `main`;
  never bypass signing.
- Push and open a PR to `main` titled `Phase 6 build 4: Mount-RegistryHive`; in the PR body show the
  canonical->src diff + note the restored ThrowError draft for owner confirmation.
- Finish `REPORT.md` per Section E, then STOP. Do NOT merge. Next after this: `Get-TypedObject` (the
  owner-flagged "needs a rework" value-data coercer), then finalize `Start-ProviderSetup`, then the R3
  read leg -> dispatcher -> Test/Plan/Set.
