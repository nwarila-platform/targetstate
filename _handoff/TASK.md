# TASK - Phase 3 (cont.): Recovery completeness + next pure tranche
_Read `_handoff/PLAN.md` first - Section 6 "Phase 3" (steps, AST parser command, acceptance), the Locked Rules (Section 4), and Sections 0.2, 2. Continues Phase 3 after PR #5 (`650b6bb`)._

## Gate status
The 9 pure functions are merged (PR #5 / `650b6bb`); `src/` and `tests/` are tracked
and allowlisted. The reconciliation matrix + corrected OCR pages + page images are
LOCAL-ONLY in `_recovery/`. Work on a NEW branch `recovery/phase-3-completeness`.

## Goal
1. RECOVERY-COMPLETENESS INVESTIGATION: the recovered code calls helpers that are NOT
   in the 18-function inventory (e.g. `Get-NormalizedRegistryKeyString`, `ArrayToString`).
   Classify every such referenced-but-not-inventoried name.
2. Recover any helper that is actually present in the PDFs but was missed by Phase 1.
3. Stabilize the next NON-REGISTRY tranche (the deferred pure-but-blocked functions, plus
   any newly recovered pure helper) whose dependencies now resolve - with tests.
Registry-touching / orchestration functions stay DEFERRED (their tests need an
owner-approved isolation strategy - a Locked Rule). Do NOT invent missing helpers, do
NOT change behavior, do NOT audit DSC.

## A0. Owner Decisions (recorded; apply)
- Direction: ANSWERED - continue recovery (not pivot to Phase 4).
- Source commit / flat `src/` / PII-scan-before-commit: unchanged from PR #5.
- Registry test-isolation strategy: NOT yet chosen -> registry/orchestration functions
  remain deferred this cycle (do not stabilize or test them).

## A. Adversarial Review Gate
Archive the current Phase 3 `_handoff/REPORT.md` to the TOP of
`_handoff/REPORT-ARCHIVE.md` (`## Archived <UTC date> - Phase 3 completeness`,
append-only), then write a new `REPORT.md` beginning with a verdict that:
1. Restates the goal; confirms branch is `recovery/phase-3-completeness` (not `main`).
2. Confirms `_recovery/` inputs (corrected pages, images, call-graph, matrix) exist;
   records both PDFs' SHA-256 and confirms they match the PLAN Section 7 baseline.
3. States the completeness method: how you enumerate every function CALL in the
   recovered `corrected/` pages and diff it against the 18-name inventory + PowerShell
   built-ins to find the gaps.
4. Confirms: image-as-ground-truth OCR correction, no behavior change, no invented helpers.

## B. Expected Changes (branch `recovery/phase-3-completeness`)
- Completeness table (in `REPORT.md` and reflected in `docs/recovery/GAPS.md`): for EACH
  function name the recovered code calls but the inventory lacks, one row classifying it:
  `found-in-PDF <pdf:page> (Phase 1 inventory gap)` | `OCR-name-variant of recovered <Fn>`
  | `PowerShell built-in / external` | `genuinely absent from the PDFs`. Cite the page/
  image evidence for each.
- For any helper classified `found-in-PDF`: recover its corrected text with provenance;
  if PURE, stabilize `src/<Fn>.ps1` + `tests/<Fn>.Tests.ps1`.
- Stabilize the deferred NON-REGISTRY functions whose dependencies now resolve
  (candidates: `Get-RegistryKeyName`, `Get-RegistryKeyPath`, `Get-TypedObject`) - only if
  their callees resolve to a recovered/built-in function WITHOUT inventing anything.
  Each gets `src/<Fn>.ps1` (OCR-corrected, provenance + corrections block) + an
  in-memory-only `tests/<Fn>.Tests.ps1`.
- Update `docs/recovery/GAPS.md`: move resolved functions OUT of the deferred list; for
  any still blocked (e.g. a helper `genuinely absent`), keep it deferred with an explicit
  note: "needs owner decision - re-extract from PDFs, or design a replacement (do not
  invent)".

## C. Guardrails
- Do NOT invent or stub a missing helper. If a referenced helper is `genuinely absent`,
  DEFER the dependent function and flag it for an owner decision - never fake it to parse.
- Correct OCR damage using the rendered page IMAGE as ground truth; log every correction
  in the file's provenance block; do not change intended behavior; do not force a parse.
- NON-REGISTRY / pure functions only this cycle (classify conservatively; unsure -> defer).
  No registry/system access in any new `src/` or `tests/` file.
- PII/sensitive-content scan (PLAN 1.9 patterns) over the new `src/`+`tests/` `.ps1` BEFORE
  committing; on any hit, do NOT commit, list file+line, mark NEEDS-OWNER.
- Preserve PDFs byte-for-byte (hash before/after). Offline; no installs.
- Branch `recovery/phase-3-completeness`, never `main`; preserve signing; stage explicit
  paths only (`src/`, `tests/`, `docs/recovery/GAPS.md`, `_handoff/*.md`). `_recovery/` +
  PDFs stay ignored. Do NOT edit `PLAN.md`/`TASK.md`/`CLAUDE-RESTART-PROMPT.md` content,
  but commit them as-is for durability.
- If Pester is unavailable at run time, say so plainly; do not fabricate test results.

## D. Verification (run each; paste output verbatim into REPORT.md)
- Completeness: a repeatable command listing every called-but-not-inventoried function
  name, and the classification table covering all of them.
- Every `src/*.ps1` (existing + new) parses with ZERO errors (PLAN Phase 3 step 4 AST
  loop; `powershell.exe` 5.1).
- Pester over `tests/` green (or Pester-unavailable stated); the PLAN Phase 3 step-6
  live-registry-mutation scan over `tests/*.ps1` returns nothing.
- Sensitive-content scan over new `src/`+`tests/` is clean.
- `git ls-files` shows the new files and no `.pdf`/`_recovery/`; PDFs hash-identical to
  the Phase 1 baseline; `git branch --show-current` (not `main`); `git log --show-signature -1` good.

## E. Definition of Done (ALL hold; else REPORT `Phase 3 status: BLOCKED | NEEDS-OWNER`)
- Every called-but-not-inventoried function name is classified with page/image evidence.
- Every helper `found-in-PDF` that is pure is recovered + stabilized + tested; every
  newly stabilized function parses clean and has in-memory-only tests (no registry).
- `docs/recovery/GAPS.md` updated: resolved functions removed from deferred; still-blocked
  ones carry an explicit owner-decision note; no helper was invented/stubbed.
- PII scan clean; new `src/`/`tests/` committed; PDFs untouched.
- `REPORT.md` has the verdict, the completeness table, the full Section D output, and a
  final line `Phase 3 status: COMPLETE | BLOCKED | NEEDS-OWNER` (COMPLETE = completeness
  investigation done + all resolvable non-registry functions stabilized; registry/
  orchestration + any genuinely-absent-helper functions remain documented in GAPS.md).

## F. End State (how this cycle hands back)
- Commit on `recovery/phase-3-completeness` with a signed message (e.g.
  `feat(recovery): recovery-completeness check + next pure functions`). Commit new
  `src/`/`tests/`, `docs/recovery/GAPS.md`, `_handoff/REPORT*.md`, and the Claude-updated
  planner docs - ONLY if the PII scan is clean. Never commit to `main`; never bypass
  signing; never stage `_recovery/` or the PDFs.
- Push the branch and open a PR to `main` titled
  `Phase 3 (cont.): recovery completeness + next functions`; paste the Section D output.
- Finish `REPORT.md` per Section E, then STOP. Do NOT merge - the owner admin-merges after
  Claude's audit. If `BLOCKED`/`NEEDS-OWNER`, still push + open the PR and name the blocker.
