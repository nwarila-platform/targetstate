# TASK - Phase 2: Function-by-Function Detangling
_Read `_handoff/PLAN.md` first - especially Section 6 "Phase 2" (subsections 2.1-2.8: matrix schema, maturity scoring, conflict-resolution rules, verification), plus Sections 0.2, 2, 4. This is the operational layer; PLAN Phase 2 is the detail._

## Gate status
Gate 1 -> 2 is GREEN: Phase 1 merged (PR #2 / `d87f1f6`); the deny-by-default
governance interlude (ADR 0002) merged (PR #3 / `ed7c535`). Work on a NEW branch
`recovery/phase-2-detangling`. Phase 1 evidence is LOCAL-ONLY in `_recovery/` on
this machine - it is the input to this phase.

## Goal
For each function in the Phase 1 inventory, decide the mature source of truth across
the two PDFs and record an evidence-backed decision BEFORE any porting. Produce the
reconciliation matrix + decisions ledger. This phase writes NO engine/source/port
code, rewrites no logic, corrects no OCR, and executes nothing. Decision artifacts
only. (OCR correction is Phase 3; the Microsoft DSC audit is Phase 4.)

## Context from Phase 1 (verify, do not assume)
- Inventory: 18 unique function names, 20 occurrences (10 per PDF) - so ~2 names
  appear in BOTH PDFs (the genuine cross-PDF reconciliations) and ~16 are
  single-source. WATCH for OCR-induced name mismatches: a function present in both
  PDFs may have been OCR'd to slightly different names and not auto-deduped; apply
  the 2.1 normalization AND manual review of the page images to catch these.
- All 33 pages are `needs_correction` with OCR hazards (smart quotes, `degree`-for-
  backtick, spacing). Where OCR genuinely blocks a signature/behavior comparison,
  DEFER (rules 2.5 R3/R7); do not guess and do not "fix" the OCR here.

## A0. Owner Decisions (record status in REPORT.md; apply defaults)
- D2 commit policy: DEFAULT = the reconciliation matrix and decisions stay LOCAL-ONLY
  under `_recovery/` (git-ignored), summarized in REPORT.md. (Option to surface, do
  not act without approval: since the matrix is a hand-curated decision record - not
  raw OCR - the owner may want it committed for PR review after a clean PLAN 1.9
  sensitive-content scan. Default remains local-only.)

## A. Adversarial Review Gate
Archive the current Phase-1-governance `_handoff/REPORT.md` to the TOP of
`_handoff/REPORT-ARCHIVE.md` (`## Archived <UTC date> - Phase 2`, append-only), then
write a new `REPORT.md` beginning with a verdict that:
1. Restates the goal; confirms you are on `recovery/phase-2-detangling` (not `main`).
2. Confirms the `_recovery/` Phase 1 inputs exist (function-inventory.tsv,
   `corrected/` pages, call-graph.tsv, page images) and records both PDFs' SHA-256,
   confirming they still match the PLAN Section 7 baseline.
3. Confirms decisions-only: no logic rewrite, no porting, no OCR correction, nothing
   executed.
4. Challenges the approach; states how you will normalize names (2.1) and which
   tie-break source you use (page images, not memory).
If misaligned or inputs are missing, `Decision: REFUSE`/`BLOCKED` and stop.

## B. Expected Changes (write ONLY under `_recovery/` and `_handoff/REPORT*.md`)
- `_recovery/_inventory/reconciliation-matrix.tsv` - PLAN 2.2 schema, EXACTLY one
  row per `function_key`; `decision` in {keep_A, keep_B, merge, discard, defer};
  `rationale` non-empty for every merge/discard/defer; maturity scored per 2.4;
  conflict-resolution rule recorded per 2.5.
- `_recovery/_inventory/decisions.tsv` - PLAN 2.3, append-only, one current row per
  `function_key`.
- Update `_recovery/_inventory/UNCERTAIN.md` with every `defer` and low-confidence call.
- REPORT.md summary: decision histogram (counts per decision), the cross-PDF
  duplicate functions found (and any OCR-name-mismatch pairs you merged into one
  key), and the list of functions whose final decision is `defer` pending Phase 3
  OCR correction.

## C. Guardrails
- DECISIONS ONLY. Do NOT rewrite logic, port, stabilize, or execute recovered code;
  do NOT correct OCR (that is Phase 3). Any code-editing impulse is out of scope -
  refuse it (PLAN 2.8).
- Where OCR blocks a confident comparison, DEFER (2.5 R7) and log it; never coin-flip
  a keep. Any `merge`/`discard` REQUIRES confidence >= medium, else downgrade to `defer`.
- Preserve the PDFs byte-for-byte: hash before and after; do not open them except to
  view the already-rendered `_recovery/.../images/*.png` for tie-breaking (the PDFs
  themselves stay untouched).
- Offline; no tooling installs; no live system changes.
- Branch `recovery/phase-2-detangling`, never `main`; preserve commit signing.
- `_recovery/` stays git-ignored/local-only (deny-by-default policy); confirm nothing
  under `_recovery/` is staged. Never `git add -A`/`.`/`*`.
- Keep hand-authored handoff files ASCII; the matrix/decisions TSVs are UTF-8 without
  BOM and must NOT strip non-ASCII quoted from evidence.
- Do NOT edit `PLAN.md`, `TASK.md`, or `CLAUDE-RESTART-PROMPT.md` content, but DO
  commit them as-is for durability (Claude updated them this cycle).

## D. Verification (run each; paste output verbatim into REPORT.md)
- PLAN 2.9 command set (a)-(f): every inventory `function_key` reconciled exactly
  once (`Compare-Object` of unique inventory keys vs matrix keys prints nothing);
  every `decision` populated and from the allowed five; no low-confidence
  `merge`/`discard`; decision histogram; every `defer` logged in `UNCERTAIN.md`;
  both PDFs hash-identical to the Phase 1 baseline.
- Hygiene: `git check-ignore -v _recovery/` prints a rule; `git ls-files` shows no
  `.pdf` and nothing under `_recovery/`; no `.ps1`/`.psm1`/`.psd1` created.
- `git branch --show-current` (not `main`); `git log --show-signature -1` (good).

## E. Definition of Done (ALL hold; else REPORT `Phase 2 status: BLOCKED | NEEDS-OWNER`)
Meet every PLAN 2.7 criterion:
- Every distinct `function_key` appears exactly once in the matrix (no orphans/dupes).
- Every matrix row has non-empty `decision`, `decision_rule`, `rationale`; every
  `decision` is one of the five tokens; no `merge`/`discard` at `confidence=low`.
- Every `defer` has a matching `UNCERTAIN.md` entry; `decisions.tsv` current-row
  count == distinct `function_key` count.
- Zero engine/source/port code; no OCR correction performed; PDFs hash-identical.
- REPORT.md has the verdict, the full Section D output, the decision summary, and a
  final line `Phase 2 status: COMPLETE | BLOCKED | NEEDS-OWNER`.

## F. End State (how this cycle hands back)
- Commit on `recovery/phase-2-detangling` with a signed message (e.g.
  `recovery(phase-2): function reconciliation decisions + report`). Because
  `_recovery/` is local-only, the committed change is `_handoff/REPORT.md`,
  `_handoff/REPORT-ARCHIVE.md`, and the Claude-updated planner docs. Never commit to
  `main`; never bypass signing; never stage `_recovery/` or the PDFs.
- Push the branch and open a PR to `main` titled
  `Phase 2: function-by-function detangling decisions`. The PR body pastes the
  Section D output and the decision summary, and LISTS (does not commit) the
  local-only `_recovery/_inventory/` artifacts produced.
- Finish `REPORT.md` per Section E, then STOP. Do NOT merge - the owner admin-merges
  after Claude's audit. If `BLOCKED`/`NEEDS-OWNER`, still push + open the PR and name
  the blocker.
