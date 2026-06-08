# TASK - Phase 0: Repo Governance Baseline
_Read `_handoff/PLAN.md` first (especially Sections 0, 2, 4, and Section 6 Phase 0 + Gate 0 -> 1). This repo is a proof-of-concept for `NWarila/powershell-template` and `nwarila-platform/targetstate`._

## Re-sequencing note (why this is Phase 0, not PDF extraction)
The prior handoff pointed the next cycle at PDF extraction. Adversarial review
found Phase 1 extraction is HARD-BLOCKED behind Gate 0 -> 1: there is no
`.gitignore`/`.gitattributes`, no ADR/governance scaffold, no working branch, and
the PDF commit decision is unresolved, so a literal extraction cycle could commit
a 19.8 MB binary or scanned PII to public history. This task does the governance
baseline that makes the repo safe to extract into. Phase 1 (PDF extraction) is the
NEXT task and is fully specified in PLAN.md Section 6 Phase 1; it starts only after
Gate 0 -> 1 is GREEN. The owner confirmed this sequencing on 2026-06-08.

## Goal
Establish the Phase 0 governance baseline on a working branch: branch discipline,
`.gitignore`/`.gitattributes`, a Draft ADR scaffold, a governance rule ledger, and
README STIG-claim reconciliation - then bring Gate 0 -> 1 to GREEN. Do NOT extract
the PDFs, do NOT audit DSC, do NOT write engine/source code.

## A0. Owner Decisions (record the status in REPORT.md; apply defaults for the rest)
- D1 PDF disposition: ANSWERED - local-only + SHA-256 manifest. PDFs stay
  git-ignored; record their hashes + sizes. (Owner: keep a separate backup; this
  checkout may be the only copy.)
- D5 README positioning: ANSWERED - reframe README to the GitOps-friendly
  DSC-replacement / YAML-not-MOF mission; STIG is a downstream use case, not a
  current claim (see Expected Changes + PLAN Phase 0 step 7).
- D2 Generated-artifact commit policy for later `_recovery/` output: default =
  all local-only until decided (a Phase 1 concern; record and move on).
- D3 Recovery dir = repo-root `_recovery/`: default = yes (a Phase 1 concern).
- D4 OCR/PDF tooling install vs present-only: default = present-only; `tesseract`
  and `pdfplumber` are already present (a Phase 1 concern).

## A. Adversarial Review Gate
REPORT.md is Codex-owned and is replaced each cycle. FIRST archive the current
`_handoff/REPORT.md` to the top of `_handoff/REPORT-ARCHIVE.md` under a heading
`## Archived <UTC date> - Phase 0` (append-only). THEN write the new `REPORT.md`
beginning with a verdict that:
1. Restates the goal.
2. Confirms repo state: `git branch --show-current`, `git ls-files`, and that both
   PDFs + `_handoff/` are untracked.
3. Challenges this governance approach and the proposed `.gitignore`/ADR layout.
4. Confirms no PDF will be opened/OCR'd and no engine/source will be written.
5. States the chosen branch name and that all commits land there, not on `main`.
If the task is misaligned, refuse and explain why (write only the verdict + a
`Decision: REFUSE: <reason>` line, then stop).

## B. Expected Changes (Phase 0 is the ONLY phase allowed to create files outside `_recovery/`/`_handoff/`)
On branch `recovery/phase-0-governance`:
- `/.gitignore` and `/.gitattributes` at repo root, with the EXACT contents given
  in PLAN.md Section 6 Phase 0 (ignore the two named PDFs and `/_recovery/`; do NOT
  use a blanket `*.pdf`; no LFS filter).
- `docs/adr/0000-adr-process.md` and `docs/adr/0001-targetstate-charter.md`, both
  containing the literal line `Status: Draft`.
- `docs/governance.md` recording the repo rules and the PDF-disposition default.
- `README.md`: reframe per PLAN Phase 0 step 7 (owner decision D5). Headline the
  GitOps-friendly DSC-replacement / YAML-not-MOF mission; present STIG as a
  downstream use case, not a current claim. Short and factual; no "compliant"
  claims. This is the ONLY non-handoff/non-governance edit permitted in Phase 0.
Do NOT create `src/`, `tests/`, `_recovery/`, or any engine/source/`.ps1` module.

## C. Guardrails
- THIS IS A PUBLIC REPOSITORY: every pushed commit is permanent and world-readable.
- Work on `recovery/phase-0-governance`, NEVER commit to `main`. Verify
  `git branch --show-current` is not `main` before any commit.
- Preserve commit signing (`commit.gpgsign` is on with an SSH key). Do not bypass
  it. Verify `git log --show-signature -1` shows a good signature.
- Never run `git add -A`, `git add .`, or `git add *`. Stage only explicit paths.
- The two source PDFs and `_recovery/` must remain untracked. If `git status` shows
  either staged, STOP and report in `REPORT.md`.
- All ADRs must contain `Status: Draft`. Do not mark any ADR Accepted.
- Do NOT open, OCR, parse, or extract `06042026.pdf` / `06042026_001.pdf`. You may
  record their SHA-256 and byte size only (`Get-FileHash`, `(Get-Item).Length`) -
  hashing reads bytes, not content.
- Do NOT touch live Windows registry or system settings. Do NOT install any tooling.
- Do NOT add claims that TargetState is STIG-compliant; the README reconciliation
  must remove, not strengthen, the existing forward STIG assertion.
- Do NOT create a broad framework or any resource contract before its ADR exists.
- Keep all files you author 7-bit ASCII. In Windows PowerShell 5.1 do NOT use
  `>`/`Out-File` defaults (UTF-16 + BOM); use `Set-Content -Encoding utf8` or
  `[IO.File]::WriteAllText($p,$t,[Text.UTF8Encoding]::new($false))` for no-BOM UTF-8.

## D. Verification (run each; paste output verbatim into REPORT.md)
- `git branch --show-current`  (must NOT be `main`)
- `git log --show-signature -1`  (good signature)
- `git status --short --branch`
- `git check-ignore -v 06042026.pdf 06042026_001.pdf _recovery`  (each prints a rule, exit 0)
- `git ls-files -- 06042026.pdf 06042026_001.pdf _recovery/`  (must be EMPTY)
- `git ls-files`  (no `.pdf`, nothing under `_recovery/`)
- ADRs are Draft (prints nothing):
  `Get-ChildItem docs\adr\*.md | Where-Object { (Get-Content $_ -Raw) -notmatch "(?m)^Status:\s*Draft\s*$" } | ForEach-Object { Write-Error "ADR not Draft: $($_.Name)" }`
- `Test-Path docs\adr\0000-adr-process.md,docs\adr\0001-targetstate-charter.md,docs\governance.md,.gitignore,.gitattributes`
- No engine/source files:
  `Get-ChildItem -Recurse -Include *.psm1,*.ps1,*.psd1 -Path . -ErrorAction SilentlyContinue`  (returns nothing)
- Record both PDF baselines: `Get-FileHash 06042026.pdf,06042026_001.pdf -Algorithm SHA256`
  and `(Get-Item 06042026.pdf).Length`, `(Get-Item 06042026_001.pdf).Length`.

## E. Definition of Done (ALL must hold; else REPORT `Phase 0 status: BLOCKED | NEEDS-OWNER`)
- On branch `recovery/phase-0-governance` (not `main`); last commit signed.
- `.gitignore` and `.gitattributes` exist with the PLAN-specified contents; both
  named PDFs and `_recovery/` are ignored and untracked (Section D outputs prove it).
- `docs/adr/0000-adr-process.md`, `docs/adr/0001-targetstate-charter.md` (both
  `Status: Draft`), and `docs/governance.md` exist.
- `README.md` reframed per D5 (GitOps/YAML-not-MOF headline; STIG as use case).
- No `src/`/`tests/`/`_recovery/` directory and no `.ps1`/`.psm1`/`.psd1` created.
- Both PDFs untouched: SHA-256 byte-identical to the values recorded at task start.
- `_handoff/REPORT.md` contains the A-gate verdict, the A0 owner-question answers/
  defaults, the full Section D output, and a final line
  `Phase 0 status: COMPLETE | BLOCKED | NEEDS-OWNER`. Gate 0 -> 1 is GREEN only when
  Phase 0 status is COMPLETE and the owner has merged the branch or approved
  proceeding from it.
- Codex did NOT edit `PLAN.md`, `TASK.md`, or `CLAUDE-RESTART-PROMPT.md`; any
  objections are recorded in `REPORT.md`.

## F. End State (how this cycle hands back)
- Commit the Phase 0 changes on `recovery/phase-0-governance` with a signed
  message (e.g. `chore(governance): phase 0 baseline`). Never commit to `main`;
  never bypass signing.
- Push the branch and open a PR to `main` titled `Phase 0: repo governance
  baseline`. The PR body summarizes what changed and pastes the Section D
  verification output.
- Finish `REPORT.md` per Section E, then STOP. Do NOT merge - the owner
  admin-merges after Claude's audit.
- If the result is `BLOCKED`/`NEEDS-OWNER`, still push the branch and open the PR
  (or state in `REPORT.md` why there is nothing to push) so there is something to
  review, and name the blocker.
