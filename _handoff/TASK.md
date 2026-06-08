# TASK - Phase 1: PDF Text and Code Extraction
_Read `_handoff/PLAN.md` first - especially Section 6 "Phase 1" (subsections 1.0-1.12, which hold the authoritative tree, schemas, OCR rules, and verification commands), plus Sections 0.2, 2, 4. This task is the operational layer; PLAN Phase 1 is the detail._

## Gate status
Gate 0 -> 1 is GREEN (Phase 0 merged via PR #1 / `a02aaa0`; PDFs + `_recovery/`
ignored and untracked; ADRs Draft; governance recorded). You may begin Phase 1.
Work on a NEW branch `recovery/phase-1-extraction`.

## Goal
Deterministically extract ALL recoverable text/code from `06042026.pdf` and
`06042026_001.pdf` into the `_recovery/` tree with full provenance, surviving OCR
damage. This phase PRODUCES EVIDENCE ONLY. Do NOT rewrite logic, port, detangle,
reconcile, stabilize, or run any recovered code; do NOT write engine/source; do
NOT audit DSC. Detangling is Phase 2 and is gated.

## A0. Owner Decisions (record status in REPORT.md; apply defaults)
- D2 Generated-artifact commit policy: DEFAULT = keep the entire `_recovery/` tree
  LOCAL-ONLY (git-ignored, uncommitted) this cycle. Do not commit any extraction
  output. (Recommendation to surface for the owner, do not act on it without
  approval: later adopt PLAN 1.9's split - commit only the small metadata
  `manifest.json`/`pages.index.tsv`/`corrected/`/`_inventory/` AFTER a clean
  sensitive-content scan, keep `raw/`/`images/`/`ocr/` ignored. Until the owner
  approves, commit nothing under `_recovery/`.)
- D3 Recovery dir = repo-root `_recovery/`: default = yes.
- D4 OCR/PDF tooling: present-only, no installs. `tesseract` 5.5 and `pdfplumber`
  (rasterizer) were present at planning; re-probe and record actual versions.

## A. Adversarial Review Gate
REPORT.md is Codex-owned and replaced each cycle. FIRST archive the current
`_handoff/REPORT.md` (the Phase 0 report) to the TOP of
`_handoff/REPORT-ARCHIVE.md` under `## Archived <UTC date> - Phase 1` (append-only,
never overwrite the archive). THEN write a new `REPORT.md` beginning with a verdict
that:
1. Restates the goal and confirms Gate 0 -> 1 is GREEN.
2. Records each PDF's SHA-256 + byte size at phase start and confirms they match the
   PLAN Section 7 baseline (`...155F`, `...051E`). This is the integrity anchor.
3. Re-probes the toolchain (PLAN 1.0/1.2) and records actual tool names + versions;
   names the per-PDF extraction mode you will use (`text` / `ocr` / `hybrid`) and
   the least-lossy path, with the thresholds you will apply.
4. Confirms you will treat all output as evidence: no logic rewrite, no porting,
   OCR correction only via the 1.7 sentinel/flag protocol.
5. States the output location is `_recovery/` (local-only this cycle, per D2).
If misaligned or a required tool is missing, write `Decision: REFUSE: <reason>` (or
`BLOCKED`) and stop. Otherwise `Decision: PROCEED`.

## B. Expected Changes (write ONLY under `_recovery/` and to `_handoff/REPORT*.md`)
Build the EXACT tree in PLAN 1.3 using the deterministic naming in 1.4. Populate:
- `_recovery/manifest.json` (PLAN 1.8): tool versions+flags, per-PDF SHA-256
  (pre+post) + byte size + page count, per-PDF mode, status histogram, thresholds.
- `_recovery/<stem>/pages.index.tsv` (PLAN 1.5 columns) - one row per page, fully
  populated; one row per page, no page missing.
- `_recovery/<stem>/raw/` (and `ocr/`, `images/` where OCR/hybrid).
- `_recovery/<stem>/corrected/page-XXXX.txt` for every page NOT `clean`, with OCR
  hazards tagged per 1.7 (`OCR:L1I`, `OCR:BACKTICK`, `OCR:QUOTE`, ...).
- `_recovery/_inventory/function-inventory.tsv` (PLAN 1.6) and `call-graph.tsv`
  (intra-project edges only).
- `_recovery/_inventory/UNCERTAIN.md` (may be empty but MUST exist).
- `_recovery/README.md` explaining the tree + how to regenerate.
The extraction summary (page counts per PDF, status histogram, function count,
top OCR flags, hashes) goes in `REPORT.md` so the owner can review the cycle from
the PR without the local-only evidence.

## C. Guardrails
- This IS the phase that authorizes opening the PDFs - but ONLY via the approved
  extraction/OCR tools to produce `_recovery/` evidence. Do not read them into chat.
- Preserve the PDFs byte-for-byte: hash before and after; use read-only extraction;
  NEVER write to or re-save the source PDF path (rasterize to a temp/`images/`
  path). If either hash changes, HARD STOP and flag the owner.
- Offline only: no network calls, no cloud OCR, no upload of PDF bytes/images/text.
- No tooling installs (Locked Rules). If a needed tool is absent, STOP, mark
  BLOCKED, name it; do not install or substitute silently.
- Evidence, not code: do NOT rewrite logic, port, or "fix" code. OCR corrections
  happen only in `corrected/` with sentinels; `raw/` is never hand-edited.
- Encoding: keep hand-authored handoff/`_recovery/README.md` ASCII; write generated
  extraction text as UTF-8 without BOM and do NOT strip/transliterate non-ASCII from
  evidence (that is provenance loss). In PowerShell 5.1 do not use `>`/`Out-File`
  defaults; use `[IO.File]::WriteAllText(...,[Text.UTF8Encoding]::new($false))`.
- Branch `recovery/phase-1-extraction`, never `main`; preserve commit signing.
- Never `git add -A`/`.`/wildcards. The entire `_recovery/` tree stays UNTRACKED
  this cycle (D2 default); confirm `git status --short` shows nothing under
  `_recovery/` staged. Do not edit source, ADRs, governance, or `README.md`.
- Do NOT edit `PLAN.md`, `TASK.md`, or `CLAUDE-RESTART-PROMPT.md` content - but DO
  commit them as-is for durability (Claude updated them this cycle for the Phase 1
  advance); raise any objection in `REPORT.md`.
- If D2 is later flipped to commit metadata, run the PLAN 1.9 sensitive-content scan
  first and do not commit on any hit.

## D. Verification (run each; paste output verbatim into REPORT.md)
- The PLAN 1.11 read-only command set (a)-(g): PDF hashes vs manifest; page coverage
  (index rows == raw page files, per PDF); status histogram (no blank status);
  outstanding OCR flags; function names found; inventory page-reference integrity;
  `git status --short --branch`.
- PDF integrity: re-hash both PDFs and assert byte-identical to the phase-start
  baseline. Any mismatch = FAIL/BLOCKED.
- Hygiene: `git check-ignore -v _recovery/` prints a rule; `git ls-files` shows
  nothing under `_recovery/` and no `.pdf`.
- `git branch --show-current` (must be `recovery/phase-1-extraction`) and
  `git log --show-signature -1` (good signature).

## E. Definition of Done (ALL hold; else REPORT `Phase 1 status: BLOCKED | NEEDS-OWNER`)
Meet every PLAN 1.10 criterion:
- Source integrity: both PDFs hash-identical to the phase-start baseline.
- Coverage: per PDF, `pages.index.tsv` has exactly one row per page
  (extracted_pages == source_pages); zero blank `extraction_status`; no page MISSING
  (a page may be empty but not absent).
- Every non-`clean` page has a `corrected/page-XXXX.txt`; no `<?...?>` sentinel on a
  `clean` page.
- `function-inventory.tsv` populated (or REPORT states zero functions with evidence);
  every inventory `source_pages` references an existing page.
- No source/engine/port code; `_recovery/` holds only evidence; nothing under
  `_recovery/` is staged/committed.
- `REPORT.md` has the A verdict, the full Section D output, the extraction summary,
  and a final line `Phase 1 status: COMPLETE | BLOCKED | NEEDS-OWNER`.

## F. End State (how this cycle hands back)
- Commit on `recovery/phase-1-extraction` with a signed message (e.g.
  `recovery(phase-1): pdf extraction evidence + report`). Because `_recovery/` is
  local-only this cycle, the committed change is `_handoff/REPORT.md`,
  `_handoff/REPORT-ARCHIVE.md`, and the Claude-updated `PLAN.md`/`TASK.md`/
  `CLAUDE-RESTART-PROMPT.md`. Never commit to `main`; never bypass signing; never
  stage `_recovery/` or the PDFs.
- Push the branch and open a PR to `main` titled `Phase 1: PDF extraction evidence`.
  The PR body pastes the Section D verification output and the extraction summary,
  and LISTS (does not commit) the local-only `_recovery/` artifacts produced.
- Finish `REPORT.md` per Section E, then STOP. Do NOT merge - the owner admin-merges
  after Claude's audit. If `BLOCKED`/`NEEDS-OWNER`, still push the branch + open the
  PR with the report and name the blocker.
