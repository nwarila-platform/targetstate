# TASK - Phase 6 build (3): apply the owner-APPROVED flagged bug-fixes (5 functions)
_Read `_handoff/PLAN.md` first (Mission, Section 4 Locked Rules, the both-runtime + flag-API constraints in the Change Log). Read `docs/build/flagged-decisions.md` (the approved fixes) and `docs/build/make-it-run-log.md`. This step CHANGES BEHAVIOR - but only the specific fixes the owner approved._

## Context
Build 2 made 8 leaf functions parse + run and FLAGGED 5 real latent bugs in the owner's recovered
code (documented in `docs/build/flagged-decisions.md`), left unapplied with their tests skipped. The
owner reviewed them and APPROVED applying Codex's proposed both-compatible fixes (2026-06-09). This
step applies EXACTLY those approved fixes - the first deliberate behavior change to the owner's logic -
in the owner's style, un-skips the corresponding tests, and proves the fixes work. `recovered/canonical/`
keeps the original (buggy) code as the immutable faithful RECORD; fixes live in `src/`.

## A0. The approved fixes - apply ONLY these (verbatim to the proposals in flagged-decisions.md)
1. `src/Get-RegistryKeyHiveObj.ps1` - in each of the 6 hive `Switch` comparison arrays, remove the
   leading unary comma: `@(,  'HKCR', ...)` -> `@('HKCR', ...)` (so abbreviated aliases like `HKLM`
   match). ALSO fix the OCR artifact in the HKCR row: `'HKEY_CLASSES ROOT'` -> `'HKEY_CLASSES_ROOT'`
   (missing underscore; verify against `_recovery/06042026/images/` if viewable). Leave every other
   row's full names as-is (they are already correct).
2. `src/Get-RegistryKeyPathStr.ps1` - the non-printable check tests `$KeyName`; change it to the
   actual parameter `$KeyPath`. AND fix the regex (see #3).
3. Non-printable regex in `src/Get-RegistryKeyPathStr.ps1`, `src/Get-RegistryKeyNameStr.ps1`,
   `src/Get-RegistryValueNameStr.ps1`: replace the 3-token sequence `'\P{Cc}\p{Cn}\p{cs}'` (and the
   stray lowercase `\p{cs}`) with the character class `'[\p{Cc}\p{Cn}\p{Cs}]'` so it means "contains
   any control / unassigned / surrogate character" as the comment intends.
4. `src/Get-NormalizedRegistryKey.ps1` - double-backslash detection: replace the collection test
   `-contains ('\\')` with `-match ('\\{2,}')`. Trailing-backslash: replace `TrimEnd('/')` (forward
   slash) with `TrimEnd('\')` so a trailing registry backslash is actually trimmed.

Do NOT make any other behavior change. If you find a NEW bug while here, FLAG it in
`docs/build/flagged-decisions.md` (do not fix it). Preserve the owner's style exactly (Begin/Process/End,
`New-Variable -Private`, colon-syntax, comments incl. typos, soft-return, spacing) - change only the
tokens named above.

## A. Adversarial Review Gate
Archive `_handoff/REPORT.md` to the TOP of `_handoff/REPORT-ARCHIVE.md`
(`## Archived <UTC date> - Phase 6 build 3`, append-only), then write a new `REPORT.md` whose verdict:
restates the goal; confirms branch `recovery/phase6-build-3` (not `main`); confirms ONLY the 5 named
functions changed and ONLY with the approved fixes; lists each fix with before/after token.

## B. Expected Changes (branch `recovery/phase6-build-3`)
- `src/Get-RegistryKeyHiveObj.ps1`, `src/Get-RegistryKeyPathStr.ps1`, `src/Get-RegistryKeyNameStr.ps1`,
  `src/Get-RegistryValueNameStr.ps1`, `src/Get-NormalizedRegistryKey.ps1` - the approved fixes applied.
- The matching `tests/*.Tests.ps1` - UN-SKIP the previously skipped cases (abbreviated hive aliases;
  non-printable path/name/value validation; double + trailing backslash normalization) and make them
  PASS. Add an assertion for the HKCR full-name now matching.
- `docs/build/flagged-decisions.md` - mark each item RESOLVED (owner-approved, applied 2026-06-09),
  keeping the description for the record.
- `docs/build/make-it-run-log.md` - append a "Build 3 - applied fixes" note per function (before/after).

## C. Guardrails
- Apply ONLY the 5 approved fixes above. No other behavior/API/logic change; no touching other
  functions (`Get-RegistryValueKindStr`, `ThrowError`, `ConvertFrom-Array`, `Convert-ByteArrayToHexString`,
  excluded canonical functions). No new make-it-run of un-started functions.
- BOTH-RUNTIME (5.1 + 7): `-match`, `TrimEnd`, char-class regex, and array literals are all valid in both.
- `recovered/canonical/**` stays BYTE-UNCHANGED (the faithful record keeps the original bug).
- Preserve the owner's exact style; change only the specific tokens. No refactor/rename/reformat.
- Sensitive-content scan over changed files. ASCII. Offline. Branch `recovery/phase6-build-3`, never
  `main`; preserve signing; stage explicit paths. Do NOT edit `PLAN.md`/`TASK.md`/`CLAUDE-RESTART-PROMPT.md`
  content; commit as-is. ADRs stay Draft.

## D. Verification (run each; paste output verbatim into REPORT.md)
- Parse: the 5 changed `src/*.ps1` report 0 parse errors.
- Pester: all tests for the 5 functions PASS with NO skips remaining for the fixed paths (paste the
  summary: Passed/Failed/Skipped). The whole `tests/` suite still passes. If `pwsh` is available run on
  7 too; else assert both-runtime by API analysis.
- For EACH of the 5: paste `git diff` of the function showing the minimal token change(s) only.
- `recovered/canonical/**` unchanged (`git status` clean there); ADRs Draft; sensitive scan clean.
- `git branch --show-current` (not `main`); `git log --show-signature -1` good.

## E. Definition of Done (ALL hold; else REPORT `Phase 6 build 3 status: BLOCKED | NEEDS-OWNER`)
- The 5 approved fixes are applied (and ONLY those), the previously skipped tests now pass, and the
  full suite is green with 0 failures and 0 remaining skips for these paths.
- Each change is minimal + style-preserving; per-function diffs in REPORT show only the approved tokens.
- `recovered/canonical/**` byte-unchanged; `flagged-decisions.md` items marked RESOLVED; ADRs Draft.
- `REPORT.md` has the verdict, per-fix before/after, Section D output, and a final line
  `Phase 6 build 3 status: COMPLETE | BLOCKED | NEEDS-OWNER`.

## F. End State (how this cycle hands back)
- Commit on `recovery/phase6-build-3` with a signed message (e.g.
  `fix(registry): apply owner-approved flagged fixes (hive aliases, validators, key normalization)`).
  Never commit to `main`; never bypass signing.
- Push and open a PR to `main` titled `Phase 6 build 3: apply approved flagged fixes`; in the PR body
  list each fix (before -> after) so the owner can confirm.
- Finish `REPORT.md` per Section E, then STOP. Do NOT merge. Next after this: complete the larger
  functions one at a time - `Mount-RegistryHive`, then `Get-TypedObject`, then finalize
  `Start-ProviderSetup` to the contract, then build the R3 read leg -> dispatcher -> Test/Plan/Set.
