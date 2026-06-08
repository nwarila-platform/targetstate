# TASK - Phase 3: Recovered Code Stabilization (pure functions first)
_Read `_handoff/PLAN.md` first - especially Section 6 "Phase 3" (steps + AST parser command + acceptance), the Locked Rules (Section 4), and Sections 0.2, 2. This is the operational layer._

## Gate status
Gate 2 -> 3 is GREEN: Phase 2 merged (PR #4 / `337455d`). The reconciliation matrix
and corrected OCR text are LOCAL-ONLY in `_recovery/` on this machine - the inputs to
this phase. Work on a NEW branch `recovery/phase-3-stabilization`.

## Goal
Turn the PURE parsing/normalization recovered functions into parseable, OCR-corrected
PowerShell under a FLAT `src/`, add Pester tests, then COMMIT them after a clean
sensitive-content scan. This is the FIRST committed source. Registry-touching and
orchestration functions are DEFERRED to a follow-up Phase 3 cycle (their tests need an
owner-approved registry test-isolation strategy - a Locked Rule). Do NOT change
behavior, do NOT invent logic, do NOT audit DSC.

## Scope (this cycle = PURE functions only)
- Classify each of the 18 reconciled functions by reading its recovered code in
  `_recovery/.../corrected/`: a function is PURE if it transforms inputs to outputs
  with NO registry/system/filesystem access and does not orchestrate I/O functions.
- Stabilize ONLY the pure ones (likely the `*Str`/`*NameStr`/`*KindStr` normalizers,
  `Get-RegistryKeyHive`/`...HiveObj`, `Get-NormalizedRegistryKey`,
  `Convert-ByteArrayToHexString`, `ConvertFrom-Array`, `Get-TypedObject`,
  `ThrowError`) - but CLASSIFY from the actual code, do not assume from the name.
- DEFER (do not stabilize now) any function that reads/writes the registry, mounts
  hives, or orchestrates (e.g. `Mount-RegistryHive`, `Get-RegistryValueData`,
  `Get-RegistryResourceObject`, `Start-ProviderSetup`, `Get-TargetResource`). List
  them in the gaps file for the follow-up cycle. If unsure whether a function is
  pure, DEFER it.

## A0. Owner Decisions (recorded; apply)
- Source commit: ANSWERED - stabilized `src/`/`tests/` ARE committed, but ONLY after a
  clean sensitive-content scan (PLAN 1.9 patterns) over the new `.ps1`; on any hit, do
  NOT commit and flag the owner.
- Layout: ANSWERED - FLAT `src/<FunctionName>.ps1`, no `.psd1`/`.psm1` yet.
- Registry test-isolation strategy: NOT approved -> registry/orchestration functions
  are deferred this cycle.

## A. Adversarial Review Gate
Archive the current Phase 2 `_handoff/REPORT.md` to the TOP of
`_handoff/REPORT-ARCHIVE.md` (`## Archived <UTC date> - Phase 3 (pure)`, append-only),
then write a new `REPORT.md` beginning with a verdict that:
1. Restates the goal; confirms you are on `recovery/phase-3-stabilization` (not `main`).
2. Confirms `_recovery/_inventory/reconciliation-matrix.tsv` and the `corrected/` pages
   exist; records both PDFs' SHA-256 and confirms they match the PLAN Section 7 baseline.
3. Lists the PURE functions you will stabilize this cycle AND the DEFERRED functions,
   with the one-line reason each was classified pure vs deferred.
4. Confirms: OCR correction uses the rendered page IMAGES as ground truth (not memory,
   not "what PowerShell would expect"); no behavior change; no invented logic.
If misaligned or inputs missing, `Decision: REFUSE`/`BLOCKED` and stop.

## B. Expected Changes (branch `recovery/phase-3-stabilization`)
- `.gitignore`: add allowlist entries `!/src/` and `!/tests/` (per ADR 0002), keeping
  the PDFs and `_recovery/` hard-denied. (`docs/` is already allowlisted.)
- `src/<FunctionName>.ps1` per PURE function: the OCR-corrected, parseable function.
  Each file opens with a provenance comment block: source PDF + page(s), the Phase 2
  decision (keep_A/keep_B), extraction quality, and an explicit list of every OCR
  correction made (raw glyph -> fix, e.g. `degree-sign -> backtick (line-continuation,
  confirmed on page image)`).
- `tests/<FunctionName>.Tests.ps1` per pure function: minimal Pester tests asserting
  input -> output behavior using in-memory inputs ONLY. No registry/system access.
- `docs/recovery/GAPS.md` (committed): known gaps + the DEFERRED function list (name,
  why deferred, what unblocks it) for the follow-up Phase 3 cycle.

## C. Guardrails
- Correct OCR damage WITHOUT changing intended behavior. The rendered page IMAGE is the
  ground truth. Log EVERY correction in the file's provenance block. Do NOT silently
  alter a token.
- Do NOT invent logic to force a parse. If a function will not parse after one OCR-
  correction pass, DEFER it (gaps list) - never fudge it.
- PURE functions only; classify conservatively (unsure -> defer).
- Tests use in-memory inputs only; NO live registry/system access (Locked Rule). The
  PLAN Phase 3 step-6 mutation scan over `tests/*.ps1` must return nothing.
- PII/sensitive-content scan (PLAN 1.9 patterns: SIDs, `C:\Users\<name>`, UNC,
  hostnames, keys, emails, etc.) over the new `src/`+`tests/` `.ps1` BEFORE committing.
  On ANY hit: do NOT commit, list file+line in REPORT, mark NEEDS-OWNER.
- Preserve the PDFs byte-for-byte (hash before/after). Offline; no installs.
- Branch `recovery/phase-3-stabilization`, never `main`; preserve signing; never
  `git add -A`/`.`/`*` (stage explicit paths; `src/`/`tests/`/`docs/recovery/GAPS.md`/
  `.gitignore`/`_handoff/*.md`).
- `_recovery/` and the PDFs stay ignored/untracked. Do NOT edit `PLAN.md`/`TASK.md`/
  `CLAUDE-RESTART-PROMPT.md` content, but commit them as-is for durability.
- If Pester (5.7.1 was present) is unavailable at run time, say so plainly; do not
  fabricate test results.

## D. Verification (run each; paste output verbatim into REPORT.md)
- Every `src/*.ps1` parses with ZERO errors (PLAN Phase 3 step 4 AST command, looped
  over each file; uses `powershell.exe` 5.1, not `pwsh`).
- Pester run over `tests/` is green (or state Pester unavailable).
- Live-registry-mutation scan over `tests/*.ps1` returns nothing (PLAN Phase 3 step 6).
- Sensitive-content scan output over `src/`+`tests/` (must be clean to commit).
- Allowlist works: `git check-ignore -v src` and a sample `git check-ignore -v src/<Fn>.ps1`
  print NOTHING (trackable); `git check-ignore -v 06042026.pdf _recovery/` still print rules.
- `git ls-files` shows the new `src/`/`tests/` files and no `.pdf`/`_recovery/`.
- Both PDFs hash-identical to the Phase 1 baseline.
- `git branch --show-current` (not `main`); `git log --show-signature -1` (good).

## E. Definition of Done (ALL hold; else REPORT `Phase 3 (pure) status: BLOCKED | NEEDS-OWNER`)
- Every PURE function has a parseable `src/<Fn>.ps1` (zero AST errors) with a provenance
  + OCR-correction block; any function that would not parse is DEFERRED in GAPS.md, not
  forced.
- Every pure function has a `tests/<Fn>.Tests.ps1` with in-memory-only assertions;
  Pester green (or Pester-unavailable stated). No registry mutation in tests.
- `docs/recovery/GAPS.md` lists the deferred registry/orchestration functions + why.
- Sensitive-content scan is CLEAN; `src/`/`tests/` committed and allowlisted. (If the
  scan hit anything, nothing under `src/`/`tests/` is committed and the report says
  NEEDS-OWNER.)
- Both PDFs hash-identical; `_recovery/` and PDFs still untracked.
- `REPORT.md` has the verdict, the pure/deferred classification, the full Section D
  output, and a final line `Phase 3 (pure) status: COMPLETE | BLOCKED | NEEDS-OWNER`
  (COMPLETE = all pure functions stabilized/tested/committed; registry functions remain
  for a follow-up Phase 3 cycle).

## F. End State (how this cycle hands back)
- Commit on `recovery/phase-3-stabilization` with a signed message (e.g.
  `feat(recovery): stabilize pure registry-normalization functions`). Commit `src/`,
  `tests/`, `docs/recovery/GAPS.md`, the `.gitignore` allowlist change, `_handoff/REPORT*.md`,
  and the Claude-updated planner docs - ONLY if the PII scan is clean. Never commit to
  `main`; never bypass signing; never stage `_recovery/` or the PDFs.
- Push the branch and open a PR to `main` titled
  `Phase 3: stabilize pure recovered functions`. Paste the Section D output in the PR body.
- Finish `REPORT.md` per Section E, then STOP. Do NOT merge - the owner admin-merges
  after Claude's audit. If `BLOCKED`/`NEEDS-OWNER` (e.g. PII hit), still push + open the
  PR with the report (no `src/` commit) and name the blocker.
