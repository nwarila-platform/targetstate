# TargetState - MASTER PLAN
_Maintained by Claude as planner/reviewer. Seeded by Codex on 2026-06-08. Revised by Claude (adversarial review pass) on 2026-06-08._

## 0. How to Use These Files
This `_handoff/` directory is intentionally inside `nwarila-platform/targetstate`.
That is a deliberate proof-of-concept exception to the older portfolio rule that
kept handoff files outside repos.

Files:
- `PLAN.md` - long-lived context, decisions, rules, backlog, and state ledger. Claude-owned.
- `TASK.md` - the single current task for Codex. Claude-owned.
- `REPORT.md` - the most recent Codex cycle only. Codex-owned (see lifecycle below).
- `REPORT-ARCHIVE.md` - append-only history of prior `REPORT.md` cycles. Codex-owned.
- `CLAUDE-RESTART-PROMPT.md` - bootstraps a fresh Claude planner/reviewer. Claude-owned.

Loop:
- Claude reads the repo, writes or revises `TASK.md`, and reviews Codex output.
- Codex reads `PLAN.md` and `TASK.md`, challenges the plan, implements the best
  path, verifies it, and writes `REPORT.md`.
- The owner gates goal changes, destructive changes, live machine changes, branch
  merges, and any commit of new tracked files.

### 0.1 Persistence and Commit Discipline
The `_handoff/` directory is the durable memory of this project. As of this
writing it is UNTRACKED in git (the repo tracks only `README.md` and
`.github/CODEOWNERS`). Going forward, `_handoff/*.md` MUST be committed so loop
state survives a fresh clone, branch switch, `git clean`, or machine wipe.
- Claude does not run git mutations. Committing is left to Codex or the owner.
- All handoff/governance commits land on a working branch, never directly on
  `main` (see Locked Rules, branch discipline). `handoff:`-prefixed bookkeeping
  commits of `_handoff/*.md` are not themselves owner-gated, but the merge of
  their branch to `main` is.
- The two root PDFs are NOT yet committed. Whether to commit them is an open
  owner decision (Section 9) and a hard precondition for Phase 1 (Gate 0 -> 1).
  Until resolved, DO NOT `git add` the PDFs.

### 0.2 REPORT.md Lifecycle
- `REPORT.md` holds the MOST RECENT Codex cycle only. Codex overwrites it each
  cycle, but ONLY after archiving the prior contents.
- Archive-before-overwrite: before Codex writes a new `REPORT.md`, it MUST append
  the existing `REPORT.md` verbatim to the TOP of `_handoff/REPORT-ARCHIVE.md`
  under a heading `## Archived <UTC date> - <phase/task id>`. `REPORT-ARCHIVE.md`
  is append-only; nothing in it is edited or deleted.
- Required `REPORT.md` sections, in order: (1) `Phase/Task status: COMPLETE |
  BLOCKED | NEEDS-OWNER`; (2) Adversarial review verdict (restate goal, PROCEED
  or REFUSE, chosen output location); (3) What changed; (4) What was intentionally
  not changed; (5) Verification output (verbatim, per Section 8); (6) Deviations
  from `TASK.md` and why; (7) Open objections that must be resolved before
  advancing; (8) Owner decisions needed (carry forward any still-unresolved item).
- Claude consumes `REPORT.md` by reading it, resolving or escalating every item
  in (7) and (8), recording each resolution in Section 10 (Change Log), then
  revising `TASK.md`. Claude does NOT edit `REPORT.md`; the next Codex cycle's
  archive-then-overwrite handles it. Durable planner state must never live only
  in `REPORT.md`; promote it into PLAN.md Section 7 first.

Owner bootstrap line for Codex:
> Read `_handoff/PLAN.md` in full (especially Sections 0, 2, 4) then `_handoff/TASK.md` in full; the TASK title names the single active phase, the only phase you may execute now. Do NOT modify or delete `06042026.pdf` or `06042026_001.pdf`, do NOT open/OCR/parse the PDFs unless the active phase is PDF extraction, and do NOT touch live Windows registry/system state. Work on a branch, never on `main`; preserve commit signing. BEFORE changing any file, write your adversarial-review verdict to `_handoff/REPORT.md` (archive the old one first, per Section 0.2): restate the goal, confirm or refuse, and propose any artifact output location. Execute the active phase only after the verdict. You may write ONLY `_handoff/REPORT.md`, `_handoff/REPORT-ARCHIVE.md`, and the active phase's permitted artifacts; do NOT edit `PLAN.md` or `TASK.md` (raise objections in `REPORT.md`). Work in `C:\Users\HellBomb\Documents\GitHub\nwarila-platform\targetstate`.

## 1. Mission
Build `TargetState`: a GitOps-friendly replacement for Microsoft's PowerShell
Desired State Configuration. The explicit goal is to declare, test, and enforce
explicit Windows system state from human-readable, version-controllable
declaration documents (YAML or a similar format) and reusable resource modules -
eliminating the generated-MOF compile/runtime requirement that makes Microsoft
DSC a poor fit for GitOps. There is no MOF compilation step: configuration is
plain declarative text that lives in git, diffs cleanly, and is the user-facing
artifact (explicitly not `Target.mof`).

The first proof resource is Registry: key hive, path, name, value name, value
kind, value data, existence, and desired state.

Windows STIG compliance is a primary use case and a strong validation target -
TargetState should make STIG hardening expressible as reusable, evidence-backed
resources rather than a pile of one-off hardening scripts - but STIG is a use
case, not the explicit point of the project. Do not let it narrow the design into
a hardening-only tool.

This repo is also the proof-of-concept consumer for `NWarila/powershell-template`
and for public repo governance under `nwarila-platform/targetstate`.

## 2. Roles and Protocol
- Claude is the planner and reviewer. Claude does not implement source changes.
- Codex is the plan skeptic and implementer. Codex is not a typist: it must
  restate the goal, challenge the approach, identify risks, and choose the
  objectively best implementation path.
- Both agents may refuse objectively wrong, unsafe, untestable, or misaligned
  work. Evidence beats momentum.
- Every material claim should be grounded in repo content, command output,
  official documentation, tests, or primary-source behavior.
- Merges to `main` and commits of new tracked files are owner-gated unless the
  owner explicitly approves an admin merge.

### 2.1 Write Authority Matrix
Each `_handoff` file has exactly one writing role; the other agent may READ it
only. The owner may override any cell.

| File | May WRITE | READ-only | Mode |
|------|-----------|-----------|------|
| `PLAN.md` | Claude (and owner) | Codex | Revise in place; record edits in Section 10 |
| `TASK.md` | Claude (and owner) | Codex | Overwrite to one active task |
| `REPORT.md` | Codex (and owner) | Claude | Overwrite per Section 0.2 lifecycle |
| `REPORT-ARCHIVE.md` | Codex (and owner) | Claude | Append-only |
| `CLAUDE-RESTART-PROMPT.md` | Claude (and owner) | Codex | Revise in place |
| source / ADRs / governance / PDFs | Codex (owner-gated merge) | Claude | Per Section 4 and the active Phase in Section 6 |

Hard rules:
- Codex MUST NOT edit `PLAN.md`, `TASK.md`, or `CLAUDE-RESTART-PROMPT.md`. If
  Codex disagrees, it records the objection in `REPORT.md` and proceeds no
  further on the disputed step until Claude or the owner revises the plan.
- Claude MUST NOT edit `REPORT.md` or `REPORT-ARCHIVE.md`.
- Neither agent edits the other's authored file to "fix" it; disagreement is
  resolved through `REPORT.md` plus a Claude/owner plan revision, not by
  cross-writing.

## 3. Product Shape
TargetState should become a small, reviewable engine with resource modules:
- A target document model that can represent desired state without compiling MOF.
- A resource contract similar in spirit to DSC resources.
- Resource discovery/loading.
- Get/Test/Set style operations.
- A plan/diff mode before mutation.
- Evidence output suitable for compliance review.
- Guarded mutation with `ShouldProcess` semantics where PowerShell supports it.
- Pester coverage for resources and engine behavior.

Initial resource family:
- `Registry`

Likely future resource families:
- Local security policy
- Audit policy
- Services
- Files and directories
- Windows features/capabilities
- User rights assignment
- Firewall rules
- Scheduled tasks
- STIG control bundles that compose lower-level resources

## 4. Locked Rules
- All ADRs start as `Draft`. No ADR becomes `Accepted` without owner approval.
- Do not implement a broad engine before the resource contract is reviewed.
- Target Windows PowerShell 5.1 first.
- Do not touch the live Windows system state as part of tests unless the owner
  explicitly approves it.
- Registry tests must use isolated test hives/paths or mocks until a live-change
  test strategy is approved.
- Do not promise STIG compliance until controls are mapped, testable, and backed
  by evidence.
- Prefer PowerShell-native patterns and Pester tests.
- Keep changes small and reviewable.
- Branch discipline: never commit directly to `main`. All work lands on a working
  branch (e.g. `recovery/phase-0-governance`, `recovery/phase-1-extraction`) and
  reaches `main` only by an owner-gated merge/PR. Verify with
  `git branch --show-current` (must NOT be `main`) before any commit.
- Preserve commit signing. `commit.gpgsign` is enabled with an SSH signing key.
  Do not bypass signing (`--no-gpg-sign`, `-c commit.gpgsign=false`) to make
  progress. Verify a good signature with `git log --show-signature -1`.
- RECOVERY FIDELITY (added 2026-06-08 after a refactoring mistake). When recovering
  the owner's source from the PDFs, transcribe it VERBATIM in the owner's exact style:
  preserve `Begin`/`Process`/`End` block structure, `New-Variable -Force -Option:'Private'`
  declarations, colon-parameter syntax (`-Name:`/`-Value:`/`-Message:`), every comment
  (typos and all), variable names, casing, ordering, spacing, and logic. Correct ONLY
  literal OCR glyph errors, verified against the page IMAGES (the sole authority). NEVER
  refactor, adapt, idiomize, restructure, "modernize", or "fix" recovered code - e.g. do
  NOT swap `TryParse` for `Parse`, do NOT collapse blocks, do NOT remove "redundant" code.
  Making recovered code parse/run on PS 5.1 is the OWNER's decision, never the recovery's.
  Flag illegible glyphs explicitly; never invent or guess logic.
- THIS IS A PUBLIC REPOSITORY. Every commit pushed is immediately and permanently
  world-readable and cannot be reliably removed from history. Treat every
  proposed commit as a public publication.
- No secrets, private keys, credentials, host-specific compliance evidence, or
  generated machine state in git. This explicitly includes personally- or
  machine-identifying data incidentally recovered from the scanned PDFs
  (hostnames, usernames, UNC or `C:\Users\<name>` paths, IP/MAC addresses,
  emails, serial/license keys, ticket numbers, SIDs). None of it may be committed
  to this public repo without explicit owner review.
- No file larger than 1 MB, and no PDF, is committed without explicit owner
  approval recorded in the Change Log. Generated recovery/extraction output lives
  under `/_recovery/` and is not committed under the default policy.
- No unapproved tooling installs. Do not install/download/invoke any new software
  (`choco`/`winget`/`pip`/`npm`/`scoop`/`Install-Module`, OCR/PDF tools, etc.)
  without explicit owner approval. Inventory what is already present and report
  it; if only unavailable tooling can do the job, stop and ask.
- Extraction and OCR run locally/offline. Do not upload/POST/transmit PDF bytes,
  rendered images, or extracted text to any external or cloud service without
  explicit owner approval.

## 5. Draft Decisions
These are working assumptions. They are not final architecture.

- Name: `TargetState`
- Public repo: `nwarila-platform/targetstate`
- Companion template/proving ground: `NWarila/powershell-template`.
- Account/org split follows the established portfolio pattern: reusable template
  work lives under `NWarila`; managed public platform repos live under
  `nwarila-platform`.
- Runtime target: Windows PowerShell 5.1 first.
- First resource: Registry.
- Design driver: GitOps-friendly. Configuration is declarative, diffable, and
  lives in version control; there are NO opaque generated MOF artifacts.
  Eliminating Microsoft DSC's MOF compile/runtime requirement is a primary
  motivation, not a side effect.
- Declaration language: human-readable, version-controllable declaration
  documents - YAML or a similar format - explicitly NOT `Target.mof` and NOT a
  MOF-compile step. Default working assumption is YAML; exact extension and schema
  remain open (Section 9).
- Engine verbs: Get, Test, Set, Invoke/Apply, and Export Evidence.
- ADR status policy: every ADR is `Draft` until owner-approved.
- Canonical generated-evidence directory: `_recovery/` at repo root (default
  local-only). DSC audit evidence: `docs/dsc-audit/`. Both are working defaults the
  owner may rename (Section 9).

## 6. Work Plan
Canonical numbering: the Phase numbers below (Phase 0 through Phase 7, with
Phase 4b) are the ONLY authoritative step identifiers. `TASK.md`, `REPORT.md`,
and `CLAUDE-RESTART-PROMPT.md` MUST reference these exact Phase numbers and MUST
NOT introduce a separate "Step N" counter. Function inventory is part of Phase 1,
not a distinct phase. Each phase boundary has an explicit Gate (see the Gate
template at the end of Section 6); Codex may not begin Phase N+1 until the
Gate N -> N+1 is recorded GREEN in `REPORT.md`.

The first real work is not new development. It is recovery and reconciliation of
existing work captured in the two root PDFs:
- `06042026.pdf` (19,780,374 bytes)
- `06042026_001.pdf` (2,780,237 bytes)

Those PDFs contain overlapping and split development history. Some functions are
more mature in one file; other functions are more mature in the other. The
project must detangle that work function-by-function before building anything
new.

### Phase 0 - Repo Governance Baseline
Purpose: make the repo safe to work in before recovered code is added. This is
the ONLY phase permitted to create/commit files outside `_recovery/` and
`_handoff/` (specifically: `.gitignore`, `.gitattributes`, `docs/adr/**`,
`docs/governance.md`). These contain NO recovered content, so they are exempt
from the local-only default that governs `_recovery/`.

Steps:
1. Create and switch to branch `recovery/phase-0-governance`. All Phase 0 commits
   land here, never on `main`. Verify `git branch --show-current` is not `main`.
2. Adopt relevant conventions from `NWarila/powershell-template`. NOTE: as of
   this writing that template is itself a bare skeleton (only `.github/CODEOWNERS`,
   `LICENSE`, an aspirational `README`) with no module layout or ADR convention
   to copy. Until the template defines conventions, TargetState establishes its
   own minimal ADR/governance layout here (steps 4-5) and records it as the POC
   convention; do not invent conventions and attribute them to the template.
3. Record all repo rules in `docs/governance.md` (single rule ledger): ADRs start
   `Draft`; PowerShell 5.1 first; Claude plans/reviews; Codex challenges/
   implements; owner gates merges and live machine changes; branch discipline;
   public-repo/no-secrets/no-PII; large-binary policy.
4. Add the Draft ADR scaffold:
   - `docs/adr/0000-adr-process.md` - defines the ADR template and the rule that
     every ADR carries `Status: Draft` until owner-approved. Filename pattern
     `docs/adr/NNNN-kebab-title.md` (zero-padded 4-digit sequence).
   - `docs/adr/0001-targetstate-charter.md` - `Status: Draft`. Records the
     Claude/Codex/owner role split and cites (does not duplicate) `docs/governance.md`.
5. Commit `.gitignore` and `.gitattributes` at repo root (contents below). This
   makes it structurally impossible to accidentally commit the source PDFs or any
   generated recovery output.
6. PDF / artifact disposition (DECIDED DEFAULT - do not deviate without owner
   approval recorded in the Change Log). The two source PDFs and all `_recovery/`
   output are LOCAL-ONLY: git-ignored, never committed, never placed under
   git-lfs in this phase. Provenance is preserved by `_recovery/manifest.json`
   (per-PDF SHA-256 + byte size; see Phase 1.8), not by committing the binaries.
   Enabling git-lfs or committing either PDF is a separate owner-gated task. This
   resolves the prior open "PDFs committed vs local" question for the default
   case; the owner may still choose otherwise (Section 9).
7. Reframe `README.md` to the owner-confirmed positioning (decision D5, resolved).
   The tracked `README.md` currently headlines "DSC-style Windows compliance
   resources and STIG-aligned system hardening," which both makes a premature STIG
   claim and mis-states the goal. Rewrite it so the headline is the actual
   mission: a GitOps-friendly replacement for Microsoft PowerShell DSC that drives
   Windows configuration from human-readable YAML-style declaration documents
   instead of generated MOF. Present STIG compliance as a downstream use
   case/validation target, NOT a current capability claim. Keep it short and
   factual (no "compliant" claims). Editing `README.md` is the ONLY non-handoff/
   non-governance file change permitted in Phase 0, and only for this reframing.
8. No engine/source/`src/`/`tests/` directory is created in this phase.

Exact `.gitignore` to commit at repo root:
```
# Source recovery PDFs - local-only by default (Open Owner Decision: PDF disposition,
# Section 9). Do not un-ignore without owner sign-off in the Change Log. To commit a
# curated copy later, force-add explicitly: git add -f <name>.
/06042026.pdf
/06042026_001.pdf

# Generated recovery/extraction evidence (Phase 1/2). Local-only by default.
/_recovery/

# DSC audit working area (Phase 4) - commit policy decided at Phase 4.
# (left tracked by default for audit evidence; see Phase 4.6)

# Tooling / OS noise
*.log
*.tmp
TestResults/
coverage.xml
Thumbs.db
Desktop.ini
.DS_Store
.vs/
```

Exact `.gitattributes` to commit at repo root (repo is Windows-authored;
`core.autocrlf` is not relied upon; no LFS filter while PDFs are local-only):
```
*.md   text
*.ps1  text
*.psm1 text
*.psd1 text
*.json text
*.tsv  text
*.csv  text
.gitignore     text
.gitattributes text

# Binaries: never diff or line-ending-mangle. No LFS filter while PDFs are local-only.
*.pdf  binary
*.png  binary
*.jpg  binary
*.jpeg binary
*.tif  binary
*.tiff binary
```

Expected artifacts (exact paths, repo root = `targetstate`):
- Branch `recovery/phase-0-governance` with signed commits.
- `/.gitignore` and `/.gitattributes` (contents above).
- `docs/adr/0000-adr-process.md` and `docs/adr/0001-targetstate-charter.md`
  (both `Status: Draft`).
- `docs/governance.md` (rule ledger + recorded PDF disposition default).
- `README.md` reconciled or an owner question recorded (Section 9).
- No `src/` or `tests/` directory.

Acceptance criteria (checkable, Windows PowerShell 5.1; each must pass):
1. On branch, not `main`: `git branch --show-current` returns a non-`main` name.
2. Last commit is signed: `git log --show-signature -1` shows a good signature.
3. Every ADR declares Draft - this prints nothing:
   `Get-ChildItem docs\adr\*.md | Where-Object { (Get-Content $_ -Raw) -notmatch "(?m)^Status:\s*Draft\s*$" } | ForEach-Object { Write-Error "ADR not Draft: $($_.Name)" }`
4. PDFs are ignored: `git check-ignore -v 06042026.pdf 06042026_001.pdf` prints a
   matching rule for each (exit 0).
5. `_recovery/` is ignored: `git check-ignore -v _recovery/` prints a matching rule
   (trailing slash required; `/_recovery/` is directory-only, so a bare `_recovery`
   will not match while the directory is absent).
6. Nothing oversized/binary tracked: `git ls-files` lists no `.pdf` and nothing
   under `_recovery/`; both PDFs and `_recovery/` are absent from `git status --short`
   staged output.
7. No engine/source files exist:
   `Get-ChildItem -Recurse -Include *.psm1,*.ps1,*.psd1 -Path . -ErrorAction SilentlyContinue` returns nothing.
8. Required governance files exist: `Test-Path docs\adr\0000-adr-process.md`,
   `Test-Path docs\adr\0001-targetstate-charter.md`, `Test-Path docs\governance.md`,
   `Test-Path .gitignore`, `Test-Path .gitattributes` each return `True`.

### Gate 0 -> 1 (MUST be GREEN before any Phase 1 work)
Phase 1 (PDF extraction) MUST NOT begin until every item holds. While any is
unmet this gate is RED and no Phase 1 artifact may be written.
- [ ] `.gitignore` and `.gitattributes` exist and ignore both named PDFs and
      `/_recovery/`. Verify (record output verbatim in `REPORT.md`):
      (a) `git check-ignore -v 06042026.pdf 06042026_001.pdf _recovery/` each prints
      a matching rule and exits 0 (note the trailing slash on `_recovery/`: the rule
      `/_recovery/` is directory-only, so a bare `_recovery` will not match while the
      directory is absent);
      (b) `git ls-files -- 06042026.pdf 06042026_001.pdf _recovery/` returns EMPTY
      (if any appear tracked, STOP and ask the owner before `git rm --cached`);
      (c) `git status --short` shows no PDF or `_recovery/` path staged.
- [ ] PDF disposition recorded (Section 9 + `docs/governance.md`); default
      LOCAL-ONLY until the owner rules otherwise.
- [ ] Draft ADR scaffold and `docs/governance.md` exist (Phase 0 acceptance 3, 8).
- [ ] `README.md` STIG wording reconciled or recorded as an owner question.
- [ ] The owner has merged `recovery/phase-0-governance` to `main`, OR explicitly
      approved proceeding to Phase 1 from the branch.
Sign-off: Codex records the four verification outputs in `REPORT.md`; Claude
confirms GREEN inside the Phase 1 `TASK.md`; the owner approves the disposition
and merge.

### Phase 1 - PDF Text and Code Extraction
Purpose: extract all recoverable text/code from both PDFs with full provenance,
in a way that is deterministic, re-runnable, and survives OCR damage. This phase
PRODUCES EVIDENCE ONLY. No logic is rewritten, ported, or executed here.

Scope fence (Phase 1): once Gate 0 -> 1 is GREEN, Codex writes ONLY under
`_recovery/` and to `_handoff/REPORT.md`/`REPORT-ARCHIVE.md`. It does NOT modify
governance files, `README.md`, source, or anything else.

#### 1.0 Environment preconditions (re-verify before extracting; do not assume)
The plan was authored against this verified local environment. Codex MUST re-run
the detection in 1.2 and record actual results; treat a mismatch as a blocker to
surface in `REPORT.md`. Do NOT install anything (Locked Rules).

Verified-present at authoring time:
- `pdftotext.exe` (Poppler 4.00) at `C:\Program Files\Git\mingw64\bin\pdftotext.exe` - text-layer extraction.
- `tesseract.exe` (Tesseract 5.5.0) at `C:\Program Files\Tesseract-OCR\tesseract.exe` - OCR engine.
- `python.exe` (Python 3.14); package `pdfplumber` importable; `pypdf`/`fitz`(PyMuPDF) NOT.
- Windows PowerShell 5.1 (5.1.26100.x). Pester 5.7.1. `pwsh` (PowerShell 7) NOT installed.

Verified-MISSING (this drives the OCR branch design):
- `pdftoppm`, `pdfimages`, ImageMagick `magick` are ALL absent. Poppler here is
  text-only and CANNOT rasterize. The OCR fallback MUST rasterize via Python +
  `pdfplumber` (`page.to_image(resolution=300)`), NOT Poppler; Tesseract consumes
  the PNGs. If a future machine has `pdftoppm`, that is an acceptable equivalent
  renderer; record which was used in the `render_method` provenance field.

Tooling decision tree (probe, do not install; record name+version):
- Text layer present + `pdftotext` present -> extract text per page.
- No text layer OR `pdftotext` absent: if a rasterizer (`pdfplumber`/`pdftoppm`)
  AND `tesseract` are present -> render + OCR; if no rasterizer or no OCR engine
  is present -> mark that PDF `BLOCKED-NEEDS-OCR-TOOL`, do partial text-layer
  extraction where possible, and ask the owner to approve an install. Never
  silently skip a PDF, and never fabricate OCR output.

#### 1.1 Hard rules (tightened)
- Do not manually rewrite logic during extraction. Transcription/OCR correction
  of damaged glyphs is allowed and tracked; logic changes are not.
- Preserve original PDFs byte-for-byte. Record and re-verify their SHA-256 before
  and after the phase (1.10). The two source PDFs are NEVER moved, renamed, or
  committed by this phase.
- Every recovered artifact carries provenance: source pdf, page range, extraction
  method, render method (if OCR), OCR confidence, and correction notes, anchored
  to the immutable PDF SHA-256 in `manifest.json` (so a re-OCR or PDF swap is
  detectable from the inventory alone).
- Treat all extracted text as evidence, not production code. Parser checks here
  are diagnostics only.

#### 1.2 Text-layer detection step and per-PDF decision branch
For EACH PDF independently, run detection and record the result in the per-PDF
index (1.5). The branch is decided per PDF (the two PDFs may differ) and refined
per page.
1. Get total page count and per-page extractable-character counts (e.g. via
   `pdfplumber`). Write per-page char counts to `pages.index.tsv`.
2. `text_layer_ratio` = (pages whose stripped text length >= 20 chars) / (total).
3. Record `extraction_mode`:
   - `text` if ratio >= 0.90 AND sampled pages show balanced PowerShell-ish
     tokens (`function`, `param`, `{`/`}` pairs). Primary extractor:
     `pdftotext -layout -f N -l N <pdf> <out>` (one page at a time; do NOT split a
     whole-file dump by guessed page breaks).
   - `ocr` if ratio <= 0.10. Rasterize at 300 DPI, then Tesseract
     (`--psm 6 --oem 1`, English; treat the first pages as a calibration sample
     and record the chosen `--psm` in provenance).
   - `hybrid` otherwise, OR if any page in a `text`-mode PDF has < 20 chars: use
     text where present, OCR only the deficient pages, mark those pages `ocr` at
     page granularity. The PDF-level mode is just the dominant label.
4. If detection fails on a page (corrupt/exception), mark `extraction_status =
   render_failed` and continue; do not abort the run.
Thresholds (0.90 / 0.10 / 20-char floor / 300 DPI / `--psm 6`) are heuristic
defaults recorded in `manifest.json` so a re-tune after the first run is
auditable; Codex may challenge them in the adversarial review.

#### 1.3 Recovery directory tree (EXACT)
All recovery output lives under a single, git-ignored root (default local-only):
```
_recovery/                             <- generated, git-ignored (1.9)
  README.md                            <- explains the tree + how to regenerate
  manifest.json                        <- run metadata, tool versions, source SHA-256+size, decisions
  06042026/                            <- one dir per source PDF, named by PDF stem
    pages.index.tsv                    <- per-page index (1.5 schema)
    raw/                               <- unedited extractor output
      page-0001.txt                    <- ONE canonical raw file per page (text-layer OR OCR output)
      ...
    images/                            <- rasterized PNGs for OCR
      page-0001.png
    ocr/                               <- per-page Tesseract sidecars (TSV, per-word confidence)
      page-0001.tsv
    corrected/                         <- human/agent-corrected text, page-level (the ONLY place edits happen)
      page-0001.txt
  06042026_001/                        <- identical structure for the second PDF
  _inventory/                          <- cross-PDF analysis artifacts
    function-inventory.tsv             <- 1.6 schema
    reconciliation-matrix.tsv          <- 2.2 schema
    call-graph.tsv                     <- edges caller -> callee, with provenance
    decisions.tsv                      <- 2.3 schema (one row per reconciled function)
    UNCERTAIN.md                       <- running list of unresolved OCR/conflict items
```
Rationale: `raw/` is never hand-edited (reproducible); `corrected/` is the only
place edits happen, and a diff of `raw` vs `corrected` IS the correction audit
trail; `images/`/`raw/`/`ocr/` are heavy/regenerable; the small high-value
`corrected/`, `*.index.tsv`, `_inventory/`, `manifest.json`, `README.md` are the
only candidates for commit (1.9).

#### 1.4 Deterministic page -> file naming (stable re-runs)
- Page numbers 1-based, zero-padded to 4 digits: `page-0007.txt`. Width fixed at 4
  regardless of count. If a PDF exceeds 9999 pages, abort and surface a blocker
  rather than silently changing width.
- PDF subdir name = filename stem verbatim (`06042026`, `06042026_001`).
- OCR sidecar uses `.ocr.txt`; Tesseract TSV uses `.tsv`; raster uses `.png`.
- Naming is a pure function of (pdf stem, page number). No timestamps/GUIDs in
  filenames (timestamps live only in `manifest.json`). Re-running overwrites the
  same paths byte-stably given identical tool versions/flags; `corrected/` is
  preserved across re-runs and never auto-overwritten.

#### 1.5 `pages.index.tsv` (EXACT columns; tab-separated, ASCII)
| Column | Meaning |
| --- | --- |
| `page` | 1-based page number, zero-padded 4 |
| `pdf` | source filename (e.g. `06042026.pdf`) |
| `extraction_mode` | `text` \| `ocr` \| `hybrid` for THIS page |
| `render_method` | `none` \| `pdfplumber-300dpi` \| `pdftoppm-300dpi` |
| `extract_tool` | e.g. `pdftotext-4.00 -layout`, `tesseract-5.5.0 --psm 6` |
| `raw_chars` | char count of the raw text-layer extract (0 if none) |
| `ocr_mean_conf` | mean Tesseract word confidence 0-100, or `NA` |
| `ocr_low_conf_words` | count of words confidence < 60, or `NA` |
| `extraction_status` | `clean` \| `needs_correction` \| `reviewed` \| `uncertain` \| `render_failed` |
| `contains_code` | `yes` \| `no` \| `unknown` |
| `corrected` | `yes` \| `no` (does a `corrected/page-XXXX.txt` exist) |
| `notes` | short ASCII free text, or empty |

#### 1.6 `_inventory/function-inventory.tsv` (EXACT columns; one row per occurrence)
A function on a given page of a given PDF is one row; the same function in both
PDFs = two rows. Tab-separated, ASCII.
| Column | Meaning |
| --- | --- |
| `function_id` | stable slug `{pdf_stem}:{first_page}:{normalized_name}` |
| `function_name` | as transcribed (post-correction) |
| `name_confidence` | `high` \| `medium` \| `low` (OCR ambiguity in the NAME) |
| `pdf` | source filename |
| `page_start` | 4-digit first page of the function body |
| `page_end` | 4-digit last page of the function body |
| `cmdletbinding` | `yes` \| `no` \| `unknown` |
| `param_count` | integer, or `unknown` |
| `param_names` | comma-joined param names (post-correction), or `unknown` |
| `parameter_sets` | count, or `unknown` |
| `pipeline_support` | `yes` \| `no` \| `unknown` |
| `shouldprocess` | `yes` \| `no` \| `unknown` |
| `outputs_object` | short return-shape description, or `unknown` |
| `calls` | comma-joined callee function names (feeds `call-graph.tsv`) |
| `parse_status` | `parses` \| `parse_error` \| `not_attempted` (diagnostic) |
| `extraction_status` | worst page status across the function span |
| `maturity_notes` | brief evidence for Phase 2 scoring |
| `source_pages` | comma-joined page list backing this row |

`call-graph.tsv` edges: `caller` and `callee` MUST both be functions declared in
the inventory (intra-project only; do NOT emit edges for built-in cmdlets/
operators). Columns: `caller, callee, source_pdf, page, confidence`.

#### 1.7 OCR-error handling protocol
Never silently "fix" code; make every PowerShell-syntax-breaking OCR hazard
visible and greppable.
- Wrap uncertain content in ASCII sentinels: `<?orig?>` (OCR produced this,
  unverified) and `<?orig|guess?>` (correction applied; left = raw, right =
  chosen). A page with any sentinel is never `clean` (at most `needs_correction`
  until a reviewer re-tags it `reviewed`).
- Flag syntax-breaking damage with fixed greppable tags `# <<OCR:TAG>>`, counted
  per page in `notes`:
  - `OCR:L1I` (l/1/I), `OCR:O0` (O/0), `OCR:BACKTICK` (lost/spurious backtick),
    `OCR:QUOTE` (smart quotes -> normalize to straight in `corrected/` AND tag),
    `OCR:DASH` (en/em dash where ASCII `-` needed), `OCR:BRACE` (unbalanced
    `{}`/`()`/`[]`), `OCR:SPLAT` (`@` ambiguity), `OCR:WS` (significant whitespace).
- Resolution: the raster image is the tie-breaker source of truth, not memory.
  If it resolves the item, correct it and record `<?raw|fix?>`; if not, leave the
  sentinel, set status `uncertain`, and add a REQUIRED row to `UNCERTAIN.md`.
  Never delete a flag to make a parser check pass; a documented `parse_error` is
  an acceptable Phase 1 outcome handed to Phase 3.

#### 1.8 Expected artifacts (Phase 1 exit set)
- `_recovery/manifest.json`: run timestamp, tool names+versions+flags, per-PDF
  SHA-256 (pre and post) + byte size + page count, per-PDF `extraction_mode`,
  counts by `extraction_status`.
- `_recovery/<stem>/pages.index.tsv` (1.5) for both PDFs, fully populated.
- `_recovery/<stem>/raw/` and, where applicable, `ocr/`, `images/`.
- `_recovery/<stem>/corrected/` for every page not `clean`.
- `_recovery/_inventory/function-inventory.tsv` (1.6), `call-graph.tsv`,
  `UNCERTAIN.md` (may be empty but MUST exist).
- Extraction summary written into `_handoff/REPORT.md`.

#### 1.9 Committed vs generated (default local-only)
DEFAULT (until the owner approves committing recovery metadata - Section 9): the
entire `_recovery/` tree and both PDFs are git-ignored and NOT committed. The
branch's only committed change is `REPORT.md`/`REPORT-ARCHIVE.md` plus any
governance carried from Phase 0.

RECOMMENDED policy IF the owner approves committing recovery metadata: commit only
the small high-value evidence and keep heavy regenerable output ignored:
- Commit: `_recovery/README.md`, `_recovery/manifest.json`,
  `_recovery/<stem>/pages.index.tsv`, `_recovery/<stem>/corrected/**`,
  `_recovery/_inventory/**`.
- Keep ignored: `_recovery/<stem>/raw/**`, `images/**`, `ocr/**`, and any `*.pdf`.
Do not enable git-lfs or commit either source PDF without a separate owner-gated
task.

Before committing ANY `_recovery` content (only if the owner approves), run a
deterministic sensitive-content scan and record results in `REPORT.md`. Minimum
patterns to flag (PowerShell 5.1 `Select-String`, native): SIDs (`S-1-5-...`),
`C:\Users\<name>` paths, UNC `\\host\share`, machine/host names, `BEGIN ...
PRIVATE KEY`/PGP blocks, `password=`/`pwd=`/`secret=`/`apikey=`, base64 blobs
> 200 chars, IP/MAC/emails. On ANY hit: do NOT commit, list file+line in
`REPORT.md`, mark `NEEDS-OWNER`.

#### 1.10 Acceptance criteria (Phase 1 DONE only when ALL hold)
1. Source integrity: SHA-256 of both PDFs unchanged from the phase-start value in
   `manifest.json`.
2. Coverage: for both PDFs, `pages.index.tsv` has exactly one row per PDF page
   (`extracted_pages == source_pages`); zero pages with empty `extraction_status`.
   A page may be empty but may NOT be MISSING.
3. No page silently lost: every page is `clean`/`needs_correction`/`reviewed`/
   `uncertain`/`render_failed`; every `render_failed` has a `UNCERTAIN.md` row.
4. Every non-`clean` page has a corresponding `corrected/page-XXXX.txt`.
5. `function-inventory.tsv` is non-empty, or `REPORT.md` states zero functions
   with evidence.
6. Every inventory row's `source_pages` reference pages that exist in the index.
7. No `<?...?>` sentinel on a page whose status is `clean`.
8. No source/engine/port code created; `_recovery/` contains only evidence.
9. Git hygiene: nothing under `_recovery/` and no `*.pdf` is staged.

#### 1.11 Repeatable verification commands (Windows PowerShell 5.1; read-only)
Run from repo root.
```powershell
# (a) Source PDFs untouched vs manifest-recorded hashes
Get-FileHash .\06042026.pdf,.\06042026_001.pdf -Algorithm SHA256 | Format-Table Hash,Path -AutoSize

# (b) Page coverage: index rows vs raw page files, per PDF
foreach ($s in '06042026','06042026_001') {
  $idx = (Get-Content ".\_recovery\$s\pages.index.tsv" | Measure-Object -Line).Lines - 1
  $raw = (Get-ChildItem ".\_recovery\$s\raw\page-*.txt" -ErrorAction SilentlyContinue).Count
  "{0}: index_rows={1} raw_pages={2}" -f $s,$idx,$raw
}

# (c) Status histogram (must show no blank status)
Get-ChildItem .\_recovery\*\pages.index.tsv | ForEach-Object { Import-Csv $_ -Delimiter "`t" } |
  Group-Object extraction_status | Select-Object Count,Name

# (d) Outstanding OCR flags
Select-String -Path .\_recovery\*\corrected\*.txt -Pattern '<<OCR:' |
  Group-Object { ($_.Line -replace '.*<<(OCR:[A-Z0-9]+)>>.*','$1') } | Select-Object Count,Name

# (e) Function names found (sorted, de-duped)
Import-Csv .\_recovery\_inventory\function-inventory.tsv -Delimiter "`t" |
  Select-Object -ExpandProperty function_name | Sort-Object -Unique

# (f) Inventory integrity: referenced source pages exist (should print nothing)
Import-Csv .\_recovery\_inventory\function-inventory.tsv -Delimiter "`t" |
  Where-Object { -not (Test-Path ".\_recovery\$($_.pdf -replace '\.pdf$','')\raw\page-$($_.page_start).txt") } |
  Select-Object function_id,pdf,page_start

# (g) Hygiene
git status --short --branch
```

#### 1.12 Failure handling
- Renderer/exception on a page: tag `render_failed`, log to `UNCERTAIN.md`,
  CONTINUE. One bad page never aborts the run.
- Detection disagreement (ratio says `text` but pages blank): downgrade affected
  pages to `ocr`/`hybrid` and re-extract only those.
- Missing tool at run time: STOP before partial OCR, record the probe output in
  `REPORT.md` as a BLOCKER, propose the present substitute for owner/Claude
  review. Never install; never fabricate OCR.
- Source hash mismatch at any point: HARD STOP; do not proceed against a changed
  source; restore from a known-good copy and flag the owner.

### Gate 1 -> 2
Do not start Phase 2 until: every Phase 1 1.10 criterion holds and is evidenced in
`REPORT.md`; Claude has reviewed and either authored the Phase 2 `TASK.md` or
marked the gate RED; the owner has approved entering detangling. `TASK.md` states
which gate is GREEN.

### Phase 2 - Function-by-Function Detangling
Purpose: decide, per function, which version (or merge) is the mature source of
truth, with a written, evidence-backed decision recorded BEFORE any porting. This
phase still writes NO engine/source/port code; it produces decision artifacts.

#### 2.1 Inputs and unit of work
- Inputs: `_recovery/_inventory/function-inventory.tsv`, the `corrected/` page
  text, `call-graph.tsv`, and page raster images for tie-breaking.
- Unit of work: a `function_key` = the normalized (case-insensitive, OCR-confusable-
  collapsed) function name. All inventory rows sharing a `function_key` across both
  PDFs reconcile together as one matrix row.
- Normalization: lowercase; collapse known OCR confusables (`l/1/I`, `O/0`) when
  forming the KEY only (never in the displayed name); strip whitespace. If two
  plausibly-distinct functions collapse to one key, split them and note in
  `UNCERTAIN.md`.

#### 2.2 `_inventory/reconciliation-matrix.tsv` (EXACT columns; one row per function_key)
Tab-separated, ASCII. Columns capture both PDFs side-by-side so comparison is
mechanical. A = `06042026.pdf`, B = `06042026_001.pdf`.
`function_key, display_name, in_A, A_pages, A_param_count, A_cmdletbinding,
A_shouldprocess, A_pipeline, A_parse_status, A_ocr_flags, A_maturity_score, in_B,
B_pages, B_param_count, B_cmdletbinding, B_shouldprocess, B_pipeline,
B_parse_status, B_ocr_flags, B_maturity_score, signature_match, behavior_delta,
decision, decision_rule, rationale, confidence, target_name`
- `signature_match` in {`identical`, `compatible`, `divergent`, `single_source`}.
- `decision` in {`keep_A`, `keep_B`, `merge`, `discard`, `defer`} (exactly one).
- `rationale` non-empty for every `merge`/`discard`/`defer`.

#### 2.3 `_inventory/decisions.tsv` (append-only audit copy)
`function_key, decision, decision_rule, chosen_source (A|B|merge|none),
chosen_pages, rationale, confidence, decided_on, decided_by (codex|owner)`. Rows
are never edited in place; a superseding decision adds a new row and prefixes the
prior row's `rationale` with `SUPERSEDED:`.

#### 2.4 Maturity scoring (0-6, deterministic; from corrected text only)
+1 each: (1) parses after OCR correction; (2) most complete validation;
(3) clearest explicit return object; (4) fewest hidden side effects; (5) fits the
future TargetState resource contract (Get/Test/Set-shaped, evidence-friendly;
score 0 if unclear); (6) testable under Windows PowerShell 5.1 (no 7-only syntax).
Ties fall through to 2.5.

#### 2.5 Conflict-resolution rules (ordered; first match wins; record `decision_rule`)
- R1 single_source: in only one PDF -> keep it.
- R2 identical: identical post-correction -> keep the version with FEWER `OCR:*`
  flags; tie -> keep A (deterministic).
- R3 parses-beats-broken: exactly one parses -> keep it, UNLESS the parse error is
  solely an unresolved OCR flag in an otherwise more-mature version -> `defer`.
- R4 maturity score: higher score wins; capture the loser's superior sub-feature
  in `behavior_delta` (may trigger R5).
- R5 deliberate merge: both contribute non-overlapping superior behavior AND both
  parse -> `merge`, naming which parts come from which PDF/pages. Merge is a PLAN;
  Phase 3 performs it.
- R6 obsolete: strictly dominated version -> `discard` it.
- R7 unclear provenance: cannot reliably attribute/compare -> `defer`, log to
  `UNCERTAIN.md`, surface to owner. Never coin-flip a `keep`.
- Any `merge`/`discard` REQUIRES `confidence >= medium`; else downgrade to `defer`.

#### 2.6 Expected artifacts (Phase 2 exit set)
- `reconciliation-matrix.tsv` (2.2), one row per `function_key`.
- `decisions.tsv` (2.3), one current row per `function_key`.
- Final selected list = matrix rows where `decision` in {keep_A, keep_B, merge}.
- Discarded/deferred list = rows where `decision` in {discard, defer}.
- `UNCERTAIN.md` updated with every `defer` and low-confidence call.
- Phase 2 summary appended to `_handoff/REPORT.md`.

#### 2.7 Acceptance criteria (Phase 2 DONE only when ALL hold)
1. Every distinct `function_key` from the inventory appears exactly once in the
   matrix (no orphans, no dupes; `Compare-Object` over the two unique key sets
   returns nothing).
2. Every matrix row has non-empty `decision`, `decision_rule`, `rationale`.
3. Every `decision` is one of the five allowed tokens.
4. No `merge`/`discard` row has `confidence = low`.
5. Every `defer` row has a matching `UNCERTAIN.md` entry.
6. Current (non-`SUPERSEDED:`) `decisions.tsv` row count == distinct `function_key`
   count.
7. Zero engine/source/port code created.
8. Source PDFs still hash-identical to the Phase 1 manifest.

#### 2.8 Failure handling
- Cannot attribute a function: `defer`, log, do not guess a `keep`.
- Two functions collapsed to one key: split, disambiguate `display_name`, note.
- A required comparison field `unknown` for both versions: cap at `defer`.
- Disagreement with a decision: add a superseding row; never rewrite history.
- Any code-editing impulse in Phase 2 is out of scope and must be refused.

### Gate 2 -> 3
Do not start Phase 3 until Phase 2 2.7 holds and is evidenced, Claude has authored
the Phase 3 `TASK.md` (or marked RED), and the owner approves entering
stabilization.

### Phase 3 - Recovered Code Stabilization
Purpose: turn selected recovered functions into parseable, testable PowerShell.

Steps:
1. Stabilize recovered code into a FLAT `src/` directory (owner decision,
   2026-06-08): one `src/<FunctionName>.ps1` per recovered function. No module
   manifest (`.psd1`/`.psm1`) yet - deferred to a later phase. Do not reuse
   `_recovery/` (evidence, not source). `src/` and `tests/` must be allowlisted in
   `.gitignore` per the deny-by-default policy (ADR 0002: add `!/src/`, `!/tests/`).
2. Add functions one at a time from the reconciliation matrix (final selected
   list).
3. Correct OCR damage without changing intended behavior; log each correction.
4. After each function, run the Windows PowerShell 5.1 AST parser. Use
   `powershell.exe` (5.1); do NOT use `pwsh` (PS7 absent). Acceptance: zero parse
   errors.
   ```powershell
   $tokens = $null; $errors = $null
   [System.Management.Automation.Language.Parser]::ParseFile(
     "src\<FunctionName>.ps1", [ref]$tokens, [ref]$errors) | Out-Null
   if ($errors.Count -gt 0) { $errors | ForEach-Object { Write-Error $_.Message }; throw "PARSE FAILED" }
   else { "PARSE OK: <FunctionName>" }
   ```
   If a function still will not parse after one OCR-correction pass, mark it
   `defer` in the reconciliation matrix (do not create a second artifact) and move
   on. Do NOT invent logic to force a parse.
5. Add minimal Pester tests for pure parsing/normalization functions first.
6. Keep live registry mutation out of tests until a safe strategy is approved.
   This read-only scan must return nothing (enforces the live-system Locked Rules):
   ```powershell
   Select-String -Path tests\*.ps1 -Pattern 'Set-Item(Property)?|New-Item(Property)?|Remove-Item(Property)?' |
     Where-Object { $_.Line -match 'HK(LM|CU|CR|U|CC)|HKEY_|Registry::' }
   ```
7. Keep `_recovery/_inventory/PROVENANCE` (or a leading comment block in each
   `.ps1`) mapping each function to its source PDF / page(s) / extraction quality.
   The authoritative provenance record is the Phase 1 inventory + `manifest.json`;
   inline comments are convenience only.

Expected artifacts:
- Stabilized source: `src/<FunctionName>.ps1` (one per function; flat, no manifest).
- Test harness: `tests/<FunctionName>.Tests.ps1` for pure functions.
- Known gaps list at a NAMED committed path (record the exact path in `REPORT.md`;
  recommended `docs/recovery/GAPS.md`). Phase 4's gate depends on this path.
- Source commit policy (owner decision, 2026-06-08): the stabilized `src/`/`tests/`
  ARE committed, but ONLY after a clean sensitive-content scan (PLAN 1.9 patterns)
  over the new `.ps1`; on any hit, do not commit and flag the owner. `src/`/`tests/`
  are allowlisted in `.gitignore` per ADR 0002.

Acceptance (Windows PowerShell 5.1):
1. Every `.ps1` under `src/` parses with zero errors.
2. Pester green if Pester is available; if not, say so plainly in `REPORT.md`
   (do not fabricate results).
3. The Step 6 live-mutation scan returns nothing.
4. No broad engine yet.

### Gate 3 -> 4
Phase 4 is OUT OF SCOPE and the DSC audit MUST NOT begin until: Phase 3 acceptance
holds AND is owner-accepted (recorded in Sections 7 and 10 - Codex self-reporting
"done" is not acceptance); the Phase 2 matrix has no Registry-relevant function
still `defer` for unclear provenance; the Phase 3 Known-gaps file exists at a
named committed path; and the owner approves leaving recovery for the audit.
Until Claude records GREEN in the Phase 4 `TASK.md`, the cmdlet/keyword list below
is reference only.

### Phase 4 - Microsoft DSC Surface Audit (methodology only)
Purpose: produce a complete, citation-backed AUDIT of the Microsoft-published DSC
surface, one structured record per surface, so a SEPARATE downstream step
(Phase 4b) can build the port/adapt/replace/skip/defer checklist. This phase
produces evidence; it does NOT produce the checklist and does NOT design or
implement TargetState. Done entirely from primary sources at execution time; no
DSC behavior may be asserted from memory.

#### 4.0 Entry gate (HARD) - see Gate 3 -> 4 above
In addition, a network-connected environment is required (live retrieval from
Microsoft Learn and Microsoft GitHub). If offline, refuse and record "Phase 4
blocked: no source access". Gate verification (paste into `REPORT.md`):
`git status --short --branch`; `git ls-files <Phase-3-gaps-path>` (must list it);
`git log --oneline -n 5` (showing the Phase 3 acceptance commit).

#### 4.1 Official primary sources (consult at execution time; do not pre-trust)
Allowed source classes, priority order:
1. Microsoft Learn (`https://learn.microsoft.com/...`): Windows PowerShell 5.1
   `PSDesiredStateConfiguration` reference; DSC-for-Windows-PowerShell conceptual
   docs (LCM, pull/push, configurations, resources, MOF); per-cmdlet pages for
   each 4.4 surface; resource-authoring conventions; cross-platform DSC v3 docs
   (context only, tagged not-the-5.1-target).
2. Microsoft/PowerShell GitHub repos (verify Microsoft/PowerShell ownership;
   record resolved repo URL + commit/tag viewed): the DSC source repo(s), the
   `PSDesiredStateConfiguration` module repo, official Microsoft-owned samples.
3. In-box discovery as corroboration ONLY (subject to owner approval, Section 9):
   `Get-Command -Module PSDesiredStateConfiguration`, `Get-Help <cmdlet> -Full`,
   `Get-DscResource`. Reads module metadata, not live registry/system state; every
   authoritative claim must still cite a Learn or GitHub URL.
Disallowed as authority: blogs, Stack Overflow, third-party tutorials, LLM memory,
non-Microsoft forks.
Citation capture (every source touched): `source-url` (exact resolved URL +
anchor), `source-class` (Learn|MS-GitHub|in-box), `retrieved-date` (UTC ISO-8601),
`version` (documented product/module version, or repo commit SHA/tag; if unstated,
`version: unstated` + SHA/tag/last-updated). Accumulate in `docs/dsc-audit/SOURCES.md`.

#### 4.2 Per-surface audit record schema (EXACT columns; one record per surface)
`surface | source-url | retrieved-date | PS5.1-behavior | TargetState-relevance |
verdict | rationale | registry-proof-impact`. `PS5.1-behavior` is factual from the
source (no design opinions). `registry-proof-impact` ties to the Phase 3 gap list
(4.5) or states "no recovered-Registry impact". Keep these exact column names so
Phase 4b can parse them.

#### 4.3 Verdict rule (one record, one verdict; closed set)
`port directly` | `adapt conceptually` | `replace with TargetState-native` |
`explicitly skip` | `defer until after Registry proof`. No surface lacks a verdict
("unknown" is not a verdict; use `defer` and state the missing evidence). A
surface may not carry two verdicts; if it splits, split it into two named
sub-surfaces. A `port`/`replace` verdict is NOT a license to implement now.

#### 4.4 Surfaces in scope (MINIMUM; verify existence at execution; add any discovered)
Cmdlets/keywords: `Configuration` keyword, `Get-DscResource`, `Invoke-DscResource`,
`Start-DscConfiguration`, `Test-DscConfiguration`, `Get-DscConfiguration`,
`Get-DscConfigurationStatus`, `Publish-DscConfiguration`, `Stop-DscConfiguration`,
`Restore-DscConfiguration`, `Update-DscConfiguration`, `New-DscChecksum`,
`Get-DscLocalConfigurationManager`, `Set-DscLocalConfigurationManager`.
Concepts: DSC resource contract conventions (Get/Test/Set, `Ensure`, schema MOF,
class-based vs MOF-based); resource discovery/module loading; LCM responsibilities;
MOF compilation vs runtime boundary; reporting/status behavior; checksums/pull
server/publishing; cross-platform DSC v3 direction (context-only record). If a
listed surface does not exist in 5.1, its record says so and `verdict =
explicitly skip` with that rationale.

#### 4.5 Cross-reference to recovered/stabilized Registry functions (gap list)
Read the Phase 3 final selected list and Known-gaps file (path confirmed by the
4.0 gate). For every gap item, record which DSC surface(s) are relevant in
`docs/dsc-audit/REGISTRY-CROSSREF.md` (`gap-id, gap-description, related-surface(s),
does-DSC-address-it (yes|partial|no), note`). Every surface record's
`registry-proof-impact` must name the gap id(s) it touches or state none. Cross-
reference only: do not modify recovered functions, the gaps file, or port anything.

#### 4.6 Artifacts committed by this phase (audit evidence only)
- `docs/dsc-audit/AUDIT.md` (per-surface records, 4.2/4.3/4.4).
- `docs/dsc-audit/SOURCES.md` (citation ledger, 4.1).
- `docs/dsc-audit/REGISTRY-CROSSREF.md` (gap cross-reference, 4.5).
- `_handoff/REPORT.md` (adversarial review, 4.0 gate output, coverage table).
Explicitly NOT committed here: any checklist/backlog (Phase 4b), any TargetState
source, any ADR change, any `.mof`.

#### 4.7 Acceptance criteria ("audit complete enough to build the checklist")
1. Every 4.4 surface (plus discovered) has exactly one record with all eight 4.2
   columns populated (no blanks; `defer` where a real decision cannot yet be made).
2. Every behavioral claim carries >= 1 Learn/MS-GitHub `source-url` in `SOURCES.md`
   with `retrieved-date` and `version`.
3. Every `verdict` is exactly one closed-set value.
4. The 4.5 cross-reference covers 100% of Phase 3 gap items; every record has a
   non-empty `registry-proof-impact`.
5. The cross-platform DSC v3 record is present and tagged context-only.
6. The 4.0 gate verification output is pasted in `REPORT.md`.
7. A coverage table in `REPORT.md` lists per surface: record-present, cited,
   verdict-assigned. Any "n" blocks acceptance.
Acceptance is owner-gated; meeting 1-7 means "ready for owner review", not "accepted".

### Phase 4b - Port/Adapt/Skip Checklist (SEPARATE downstream step; do not start in Phase 4)
Building the port/adapt/replace/skip/defer checklist and splitting the
implementation backlog into reviewable steps is NOT part of Phase 4. It may only
begin after the owner accepts the Phase 4 audit. Phase 4b consumes the per-surface
verdicts (evidence) to produce the actionable checklist and backlog. Expected
artifacts: `docs/dsc-audit/CHECKLIST.md` (one line per surface: verdict + the concrete
next action) and an updated implementation backlog split into separate steps. No
source/ADR change here. (If the owner prefers strict phase-number stability, Phase
4b may instead open Phase 5; record the choice in Section 9 / Change Log.)

### Gate 4b -> 5 / Gate 5 -> 6 / Gate 6 -> 7
Use the generic Gate template below at each remaining boundary. Boundary-specific
notes:
- Gate 5 -> 6: the owner must approve the DIRECTION of the contract ADRs before
  Phase 6; those ADRs remain `Status: Draft` (owner approval of direction does not
  mark them Accepted).
- Inside Phase 6, before "Add apply mode": apply mode is a live-machine change and
  requires explicit owner approval before execution; the apply-mode safety checks
  and test-isolation strategy must be owner-approved.

### Phase 5 - TargetState Contract Design
Purpose: design the TargetState contract after recovered code and the DSC audit
are known.
Steps:
1. Draft ADR for resource contract.
2. Draft ADR for declaration document format.
3. Draft ADR for evidence/reporting model.
4. Draft ADR for mutation safety and `ShouldProcess` behavior.
5. Decide how much DSC compatibility is required versus intentionally avoided
   (driven by the Phase 4b checklist).
Output: Draft ADRs only until owner approval; implementation-ready contract for
the Registry proof.

### Phase 6 - Registry Proof Implementation
Purpose: implement the first real TargetState resource using recovered functions.
Steps:
1. Build Registry resource from reconciled recovered code.
2. Add tests for path parsing, hive normalization, value kind normalization, and
   evidence object shape.
3. Add safe registry tests only after test isolation is owner-approved.
4. Add a simple target document input for Registry.
5. Add test/plan mode.
6. Add apply mode behind explicit, owner-approved safety checks (live-machine gate).
Output: minimal but real Registry resource; tests; evidence output; known gaps.

### Phase 7 - Engine and STIG Roadmap
Purpose: grow from Registry proof to the framework needed for Windows STIG work.
Steps:
1. Implement resource loading.
2. Implement target document validation.
3. Implement dependency-free plan/apply flow.
4. Implement evidence export.
5. Start mapping Windows STIG controls to required resource modules.
6. Add missing resource families as separate, reviewed steps.

### Gate template (instantiate at EVERY boundary 0->1 ... 6->7)
Do NOT start Phase N+1 until all are checked:
- [ ] Every item in Phase N's acceptance/Output block exists and is listed with
      its repo-relative path in `REPORT.md`.
- [ ] Codex wrote a Phase N completion summary in `REPORT.md` (what changed, what
      was intentionally not changed, verification output, deviations) per Section 8.
- [ ] Claude reviewed `REPORT.md` and either authored the Phase N+1 `TASK.md` or
      marked this gate RED with required fixes. Codex must not advance on RED.
- [ ] Owner sign-off recorded where the boundary crosses a gated concern: any ADR
      acceptance, any live-machine step, any commit of new tracked files (PDFs
      included), any merge to `main`.
RED action: stop, mark `BLOCKED`/`NEEDS-OWNER` in `REPORT.md`, do not proceed.
`TASK.md` must state which gate is currently GREEN.

## 7. Current State Ledger
Active phase: Test/Set Execution-Dispatch Design (determine the objectively-best way to fold Get/Test/Set into the owner's single execution path; analysis + Draft ADR 0007). Then the per-function build (Phase 6, paused). Last updated: 2026-06-09.

Repo facts:
- Repo created by `nwarila-platform/github-terraform-runner` as public
  `nwarila-platform/targetstate`.
- Local checkout: `C:\Users\HellBomb\Documents\GitHub\nwarila-platform\targetstate`
- Tracked on `main` after Phase 0 merge (PR #1 / squash `a02aaa0`):
  `.github/CODEOWNERS`, `README.md`, `.gitignore`, `.gitattributes`,
  `docs/adr/0000-adr-process.md`, `docs/adr/0001-targetstate-charter.md`,
  `docs/governance.md`, `_handoff/*.md`.
- Untracked, local-only by policy (D1): `06042026.pdf` (19,780,374 bytes,
  SHA-256 `B6BD5239...155F`) and `06042026_001.pdf` (2,780,237 bytes, SHA-256
  `D6BE7305...051E`); both git-ignored. Full hashes are in the archived Phase 0
  REPORT.
- `NWarila/powershell-template` is currently a bare skeleton with no conventions
  to adopt.
- `README.md` was REFRAMED in Phase 0 (PR #1) to the GitOps-friendly
  DSC-replacement / YAML-not-MOF positioning; STIG is a downstream use case.
- Owner decisions resolved 2026-06-08: sequencing = Phase 0 first; D1 = PDFs
  local-only + SHA-256 manifest; D5 = README reframed. D2/D3/D4/D6 remain on their
  documented defaults.
- Gate 0 -> 1 is GREEN (Phase 0 merged; PDFs + `_recovery/` ignored and untracked;
  ADRs Draft; governance recorded; commits signed).
- The PDFs are scanned/code-printout source material for the first Registry
  resource/provider design (DSC-like vocabulary: provider setup, target resource,
  Registry normalization, `Ensure`, `ValueKind`, `ValueData`).
- No engine code exists yet.

Phase status (names match Section 6):

| Phase | Name | Status | Evidence | Date |
|-------|------|--------|----------|------|
| 0 | Repo Governance Baseline | COMPLETE - merged PR #1 (squash `a02aaa0`); Gate 0->1 GREEN | 2026-06-08 |
| 1 | PDF Text and Code Extraction | COMPLETE - merged PR #2 (squash `d87f1f6`); 33 pages OCR'd, 18 functions inventoried, evidence local-only | 2026-06-08 |
| - | Governance: Deny-by-default tracking (ADR 0002 Draft) | COMPLETE - merged PR #3 (squash `ed7c535`) | - | 2026-06-08 |
| 2 | Function-by-Function Detangling | COMPLETE - merged PR #4 (squash `337455d`); 18 reconciled (9 keep_A, 9 keep_B, 0 defer) | 2026-06-08 |
| 3 | Recovered Code Stabilization | COMPLETE (as recovery baseline) - 10/18 functions stabilized + merged (PRs #5 `650b6bb`, #6 `69325cd`); 8 deferred in `docs/recovery/GAPS.md` (2 blocked on genuinely-absent helpers, 6 registry/orchestration). Owner accepted + pivoted to Phase 4 | 2026-06-08 |
| 4 | Microsoft DSC Surface Audit | COMPLETE - merged PR #7 (squash `bafe8c2`); 24 surfaces audited from primary sources (citations Claude-verified), cross-ref covers 32 GAPS | 2026-06-08 |
| 4b | Port/Adapt/Skip Checklist | COMPLETE - merged PR #8 (squash `c0cb730`); CHECKLIST (24 surfaces) + BACKLOG (20 items, traceable) | 2026-06-08 |
| 5 | TargetState Contract Design | COMPLETE - merged PR #9 (squash `3ac0c3a`); 4 Draft contract ADRs 0003-0006 | 2026-06-08 |
| - | CORRECTIVE: Faithful Source Reconstruction | COMPLETE - merged PR #11 (squash `b43115c`); all 18 functions recovered verbatim into `recovered/06042026.ps1` (A) + `06042026_001.ps1` (B); owner's style preserved (audit-validated faithful) | 2026-06-09 |
| - | Execution-map audit | COMPLETE - exhaustive multi-agent audit of the recovered code -> `docs/design/execution-map.md` (inventory, missing functions, unified single-path map, MS-DSC comparison, ordered forward plan) | 2026-06-09 |
| - | CORRECTIVE: Canonical Selection | COMPLETE - merged PR #12 (squash `729c80a`); 14 canonical + 6 archived (verbatim); owner CONFIRMED File A's contract as the spine; refactored `src/`/`tests/` removed | 2026-06-09 |
| - | Test/Set Execution-Dispatch Design | ACTIVE - assigned in current TASK.md. Determine the objectively-best way to fold Get/Test/Set into the single path (analysis + Draft ADR 0007); owner decides the route. | - | 2026-06-09 |
| 6 | Registry Proof Implementation | PAUSED - resumes after the Test/Set dispatch design, building one function at a time on the owner's faithful canonical code (`recovered/canonical/`). JSON + Pester-mocks decisions on hold for it. | - | 2026-06-09 |
| 7 | Engine and STIG Roadmap | NOT STARTED | - | - |

Rule: whenever a phase's status changes, update this table AND add a Section 10
entry in the same edit. Statuses: NOT STARTED, ACTIVE, PARTIAL, BLOCKED, COMPLETE.

## 8. Verification Expectations
For every implementation step, Codex should report:
- What was changed.
- What was intentionally not changed.
- What command/test/lint output supports the result (pasted verbatim).
- Any plan deviation and why.
- Any owner decision needed.

Initial local checks vary while the repo is empty. Do not invent tooling results.
If Pester, PowerShell 7, PDF/OCR tooling, or module tooling is unavailable, say so
plainly and do not proceed with a step that depends on it.

## 9. Open Owner Decisions
Blocking (gate the move from Phase 0 to Phase 1; default applied if owner silent):
- D1 PDF disposition: RESOLVED 2026-06-08 - LOCAL-ONLY + SHA-256 manifest (owner).
  Keep a separate backup of both PDFs; this checkout may be the only copy.
- D2 Generated-artifact commit policy: commit recovery metadata (manifests,
  inventory, corrected text), keep heavy raw/OCR local-only, or keep all of
  `_recovery/` local-only? Default: ALL local-only until decided.
- D3 Recovery directory name `_recovery/` at repo root - confirm or rename.
- D4 Tooling: may Codex install OCR/PDF tooling, or present-only? Default:
  PRESENT-ONLY (report what exists; stop and ask if a PDF needs OCR and no OCR
  toolchain is present). Note: `tesseract` 5.5 and `pdfplumber` (a rasterizer)
  are already present, so present-only is expected to suffice for Phase 1.
- D5 README positioning: RESOLVED 2026-06-08 - reframe README so the headline is
  the GitOps-friendly DSC-replacement / YAML-not-MOF mission; STIG is a downstream
  use case, not a current claim (Phase 0 step 7).
- D6 May Phase 4 use read-only in-box `Get-DscResource`/`Get-Help` discovery as
  corroboration? RESOLVED 2026-06-08 - YES, allowed as read-only CORROBORATION only
  (reads module metadata, not live registry/system state; does not invoke/apply any
  DSC resource). Every AUTHORITATIVE behavioral claim must still cite a Learn or
  Microsoft-GitHub source.

- Declaration document format: RESOLVED 2026-06-08 - JSON for the first proof (PS 5.1
  parses it natively via `ConvertFrom-Json`; YAML was only a suggestion). ADR 0004 to be
  revised to JSON when Phase 6 resumes.
- Registry test-isolation: RESOLVED 2026-06-08 - Pester MOCKS (no real registry) for the
  first registry tests. ADR 0006 to record it when Phase 6 resumes.

Long-horizon (do NOT block current work):
- Module skeleton: RESOLVED 2026-06-08 - flat `src/<FunctionName>.ps1` scripts, no
  `.psd1`/`.psm1` manifest yet (deferred to a later phase). Stabilized `src/`/`tests/`
  ARE committed after a clean PII scan; `src/`/`tests/` allowlisted in `.gitignore`
  per ADR 0002.
- Phase numbering: keep Phase 4b as a sub-phase, or renumber 5-7.
- Phase 3 Known-gaps committed path (recommended `docs/recovery/GAPS.md`).

## 10. Change Log
- 2026-06-08: Seeded repo-local `_handoff` for TargetState POC. Locked the
  Claude/Codex role split for this repo: Claude plans/reviews; Codex challenges
  and implements. Recorded that all ADRs start as Draft.
- 2026-06-08: Owner clarified `NWarila/powershell-template` is the companion
  template repo; TargetState targets Windows PowerShell 5.1 first; the project is
  moving away from `Target.mof` files; repo ownership follows the established
  split account/org pattern.
- 2026-06-08: Owner clarified the two root PDFs are existing TargetState
  development work and must be extracted, detangled, and reconciled before new
  implementation. Added the phased recovery plan.
- 2026-06-08: Claude adversarial-review pass. Closed safety/sequencing gaps:
  added Gates at every phase boundary; pinned the canonical `_recovery/` tree and
  exact TSV schemas; expanded Phase 1/2 into a deterministic, OCR-survivable,
  PS 5.1 workflow; expanded Phase 4 into an audit-only, citation-backed
  methodology and split the checklist into Phase 4b; added branch discipline,
  `.gitignore`/`.gitattributes`, large-binary/PII/public-repo/no-install/offline
  Locked Rules; added the Write Authority Matrix, REPORT lifecycle + archive, Step
  Advancement Protocol, Glossary, and a structured State Ledger. RE-SEQUENCED the
  next Codex task from Phase 1 extraction to Phase 0 governance (Phase 1 is hard-
  blocked behind Gate 0 -> 1 and bundling the two collides scope fences). Recorded
  default decisions D1-D6 (owner-overridable) and flagged the tracked README STIG
  claim for reconciliation.
- 2026-06-08: Owner confirmed sequencing (Phase 0 governance first), D1 (PDFs
  local-only + SHA-256 manifest), and clarified the MISSION: TargetState is a
  GitOps-friendly replacement for Microsoft PowerShell DSC, driving Windows config
  from human-readable YAML-style declaration documents instead of generated MOF
  (the MOF compile/runtime burden is the primary thing being eliminated). STIG
  compliance is a major use case and validation target, not the explicit goal.
  Updated Section 1 (Mission), Section 5 (GitOps/YAML design drivers), the
  README-reframe step (Phase 0 step 7 / D5), and the declaration-language open
  decision accordingly.
- 2026-06-08: Phase 0 (governance baseline) executed by Codex on branch
  `recovery/phase-0-governance` and AUDITED by Claude: scope clean (only
  `.gitignore`/`.gitattributes`/`docs/adr/0000-0001`/`docs/governance.md`/README
  reframe/handoff); both PDFs byte-identical to baseline; ADRs Draft; no engine
  files; commits signed. Codex correctly flagged that the Gate 0 -> 1 verification
  used a bare `_recovery` where the rule `/_recovery/` is directory-only - resolved
  by accepting the trailing-slash `_recovery/` proof and correcting the command
  wording in Gate 0 -> 1 and Phase 0 acceptance #5. Gate 0 -> 1 declared GREEN.
  Owner-authorized admin squash-merge to `main` (PR #1 -> commit `a02aaa0`); no CI
  workflows exist, nothing to watch. Advanced ledger to Phase 1 ACTIVE.
- 2026-06-08: Phase 1 (PDF extraction) executed by Codex on
  `recovery/phase-1-extraction` and AUDITED by Claude: both PDFs are zero-text-layer
  scans, OCR'd via pdfplumber 300 DPI + Tesseract (33 pages = 17 + 16; full page
  coverage, all honestly `needs_correction`); PDFs byte-identical pre/post; 18
  Registry-provider functions inventoried (`Get-TargetResource`, `Get-RegistryKeyHive`,
  `Mount-RegistryHive`, ...) with 22 call edges; OCR hazards tagged; `_recovery/`
  kept local-only (nothing committed); no engine/source. Codex flagged a real PLAN
  1.3 imprecision (`raw/*.ocr.txt` vs the 1.11 `raw/*.txt` checks) - fixed to one
  canonical `raw/page-XXXX.txt` per page. Owner-authorized admin squash-merge to
  `main` (PR #2 -> `d87f1f6`). Downstream notes: OCR'd backtick continuations render
  as `degree`/`tilde` and were not all tagged `OCR:BACKTICK` (Phase 3 correction).
- 2026-06-08: Owner initiated a DENY-BY-DEFAULT tracking policy (added `**` to
  `.gitignore`) and asked for it to be recorded as an ADR. Inserted a governance
  interlude before Phase 2: Draft ADR 0002 + a correctly-allowlisted `.gitignore`
  (the bare `**` ignores new files but does not allowlist tracked paths). PDFs and
  `_recovery/` must remain ignored under the new policy.
- 2026-06-08: Governance ADR 0002 (deny-by-default tracking) executed by Codex on
  `recovery/governance-deny-by-default` and AUDITED by Claude with functional
  `git check-ignore` probes: PDFs + `_recovery/` still ignored; all currently-tracked
  files still trackable; a new unlisted top-level file is denied by `/*`; new files
  under allowlisted `docs/`/`_handoff/` are trackable; ADR 0002 `Status: Draft`;
  commits signed. Codex noted the `probe.tmp` check matched the `*.tmp` noise rule,
  not `/*`, and added `probe.unlisted` as stronger proof. Owner-authorized admin
  squash-merge to `main` (PR #3 -> `ed7c535`). ADR 0002 remains Draft pending owner
  acceptance. Advanced ledger to Phase 2 ACTIVE.
- 2026-06-08: Phase 2 (detangling) executed by Codex on `recovery/phase-2-detangling`
  and AUDITED by Claude: all 18 `function_key`s reconciled exactly once (9 keep_A, 9
  keep_B, 0 merge/discard/defer); the 2 genuine cross-PDF duplicates resolved by
  maturity (R4) - `Start-ProviderSetup` -> keep_A, `Get-TargetResource` -> keep_B (B
  is the more DSC-contract-shaped version); Codex verified via page images that the
  `...Obj`/`...Str` suffix pairs are genuinely distinct functions, not OCR variants;
  PDFs byte-identical; matrix/decisions local-only. Owner-authorized admin squash-merge
  to `main` (PR #4 -> `337455d`). NOTE: the merged Phase 2 TASK.md referenced a
  `PLAN 2.9` that does not exist (Phase 2 stops at 2.8) - Codex used the TASK D checks;
  avoid that dangling ref in future TASKs.
- 2026-06-08: Owner decisions for Phase 3 - (a) the stabilized recovered source is
  COMMITTED after a clean PII scan (not local-only); (b) FLAT `src/<Fn>.ps1` layout,
  no module manifest yet (resolves the Section 9 module-skeleton question). Scoped the
  first Phase 3 cycle to PURE parsing/normalization functions (stabilize + Pester-test
  + commit); registry-touching/orchestration functions are deferred to a follow-up
  cycle because their tests need an owner-approved registry test-isolation strategy
  (Locked Rule). Advanced ledger to Phase 3 ACTIVE.
- 2026-06-08: Phase 3 (pure) executed by Codex on `recovery/phase-3-stabilization` and
  AUDITED by Claude with INDEPENDENT re-runs: 9 pure functions stabilized into flat
  `src/<Fn>.ps1`, all parse clean under PS 5.1 (0 errors), 16/16 Pester pass, no
  registry access in tests, PII scan clean, PDFs byte-identical. Codex conservatively
  demoted 3 initially-pure-looking functions to deferred after page-image review
  (missing-callee/incomplete-branch risk), transparently flagged a faithful
  `Enum.Parse` PS-5.1 adaptation in `Get-RegistryValueKindStr`, and cleaned a
  UNC-shaped PII false-positive in a test fixture. Owner-authorized admin squash-merge
  to `main` (PR #5 -> `650b6bb`); first committed source. GAPS.md lists 9 deferred
  functions (6 registry/orchestration; 3 referencing helpers not in the recovered set).
- 2026-06-08: Owner chose to CONTINUE recovery (vs pivot to the Phase 4 DSC audit).
  Next cycle = a recovery-completeness investigation (classify every function the
  recovered code calls but the 18-function inventory lacks: inventory gap / OCR-name
  variant / built-in / genuinely absent) + stabilize the resolved non-registry
  functions. Do NOT invent missing helpers. Registry/orchestration functions remain
  deferred pending an owner-approved test-isolation strategy (a later cycle).
- 2026-06-08: Phase 3 completeness cycle executed by Codex on
  `recovery/phase-3-completeness` and AUDITED by Claude (independent parse/Pester/scans):
  stabilized `Get-RegistryKeyPath` (10/18 now done); classified every called-but-not-
  inventoried name - 17 are PS built-ins, ~6 are project helpers GENUINELY ABSENT from
  the PDFs (`Get-NormalizedRegistryKeyString` x6, `ArrayToString`, `Get-RegistryKeyType`,
  plus B:0001 sketch names). A declaration scan found no missed function bodies, so the
  two PDFs are FULLY MINED; the source itself is incomplete. Codex did not invent/alias
  helpers. Owner-authorized admin squash-merge to `main` (PR #6 -> `69325cd`).
- 2026-06-08: Owner ACCEPTED Phase 3 as the recovery baseline (10 stabilized functions
  + GAPS) and PIVOTED to Phase 4. Gate 3 -> 4 GREEN: Phase 3 owner-accepted; GAPS file
  exists (`docs/recovery/GAPS.md`); Phase 2 matrix has 0 unresolved defers. Phase 4 is
  AUDIT-ONLY and needs network (Microsoft Learn + GitHub); audit evidence lives under
  `docs/dsc-audit/` (already allowlisted - no `.gitignore` change). D6 resolved: read-
  only in-box discovery allowed as corroboration only. The 8 deferred functions + the
  missing helpers are now design work for Phase 5/6, informed by the audit. Advanced
  ledger to Phase 4 ACTIVE.
- 2026-06-08: Phase 4 (DSC surface audit) executed by Codex on
  `recovery/phase-4-dsc-audit` with live network, and AUDITED by Claude - including
  INDEPENDENT WebFetch of two cited Microsoft Learn pages (Invoke-DscResource,
  DSC v3 overview), both confirming Codex's summaries verbatim (citations are real,
  not hallucinated). 24 surface records (21 planned + 3 discovered in-box surfaces),
  each with a primary-source citation, retrieved-date, version, and one closed-set
  verdict; verdicts are mission-aligned (Configuration/MOF/LCM -> replace; Get/Test/Set
  contract + Invoke-DscResource -> adapt; pull/checksum/debug -> skip; DSC v3 ->
  defer/context-only). `REGISTRY-CROSSREF.md` maps all 32 GAPS items. No checklist/
  design/source/.mof produced (audit-only respected). Owner-authorized admin squash-
  merge to `main` (PR #7 -> `bafe8c2`), which constitutes owner acceptance of the audit.
- 2026-06-08: Advanced to Phase 4b (synthesis): turn the audit verdicts + the 10
  stabilized functions + the GAPS into `docs/dsc-audit/CHECKLIST.md` (one action per
  surface) and an implementation `BACKLOG.md` mapped to Phase 5 (contract ADRs) and
  Phase 6 (Registry build). Phase 4b designs nothing and writes no ADR/source.
- 2026-06-08: Phase 4b executed by Codex on `recovery/phase-4b-checklist` and AUDITED by
  Claude: `CHECKLIST.md` covers all 24 audited surfaces with a concrete action + target
  phase each; `BACKLOG.md` has 20 traceable items (4 contract ADRs, 3 missing-helper
  design items, the 10 reusable stabilized functions, the 8 deferred functions gated on
  the contract + registry test-isolation, test/plan/apply modes), each citing real AUDIT
  surfaces + GAP ids. Synthesis-only respected (no design locked, no ADR/source/.mof).
  Owner-authorized admin squash-merge to `main` (PR #8 -> `c0cb730`).
- 2026-06-08: Advanced to Phase 5 - the first DESIGN phase. Codex drafts the four
  contract ADRs (0003 resource contract, 0004 declaration-document format (YAML, no MOF),
  0005 evidence/reporting model, 0006 mutation/ShouldProcess safety) as a coherent
  PROPOSAL set, all `Status: Draft`, grounded in the audit verdicts + the 10 recovered
  functions + the mission. They lock nothing until owner-accepted (Locked Rule). The
  missing-helper designs (P5-DESIGN-006-008) and Phase 6 build follow.
- 2026-06-08: Phase 5 merged (PR #9 -> `3ac0c3a`); 4 Draft contract ADRs. Owner reviewed
  and decided: declaration format = JSON (PS 5.1 native; YAML was only a suggestion);
  registry tests = Pester mocks. (Recorded in Section 9; ADRs 0004/0006 to be revised when
  Phase 6 resumes.)
- 2026-06-08: COURSE CORRECTION (owner-initiated). The owner reviewed the committed `src/`
  and found the Phase 3 "stabilization" had REFACTORED their code, not faithfully recovered
  it - it collapsed `Begin`/`Process`/`End` blocks, removed `New-Variable -Private`
  declarations, dropped colon-parameter syntax, stripped comments, and swapped APIs (e.g.
  `Get-RegistryValueKindStr` rewritten to `[Enum]::Parse`). Claude confirmed by diffing the
  committed function against the owner's OCR/page image. This is a process error: Phase 3
  was scoped as "stabilization," which licensed rewriting. Added a RECOVERY FIDELITY Locked
  Rule (Section 4). NEXT: a faithful source-reconstruction cycle - verbatim transcription of
  BOTH PDFs from the page images, OCR-glyph fixes ONLY, the owner's exact style preserved,
  fidelity over runnability, into a committed `recovered/` tree (pure `.ps1` + separate
  provenance sidecars). The refactored `src/`/`tests/` are left in place for diff comparison
  and removed once the owner confirms fidelity. Phase 6 PAUSED; the read-only proof PR #10
  was closed (built on the refactored base).
- 2026-06-09: Faithful Source Reconstruction executed by Codex and AUDITED by Claude: all 18
  functions recovered verbatim (owner's Begin/Process/End + New-Variable -Private + colon-syntax
  + comments + `TryParse` preserved; spot-checked vs the page images). Owner-authorized admin
  squash-merge to `main` (PR #11 -> `b43115c`). The recovered code is now the source of truth.
- 2026-06-09: EXECUTION-MAP AUDIT - Claude ran an exhaustive multi-agent audit (index -> per-
  function deep-read -> execution-flow reconstruction -> synthesis + completeness critic) of the
  recovered code; deliverable committed as `docs/design/execution-map.md`. Key findings: the
  owner's unified single path (one entrypoint `Get-TargetResource` -> one setup call
  `Start-ProviderSetup` -> prune by `$PSCmdlet.ParameterSetName`, mount-once, single `ThrowError`
  sink) is real and clean; the two PDFs are TWO ENTANGLED development versions (A has a complete
  JSON-driven path; B has more-developed normalizers + the design header-map but broken wiring);
  the Phase 2 per-function reconciliation produced incompatible interface seams (A's
  `Start-ProviderSetup` rich-object vs B's `Get-TargetResource` string expectation). Missing
  functions are mostly rename-drift (`Get-NormalizedRegistryKeyString` = `Get-NormalizedRegistryKey`,
  `ArrayToString` = `ConvertFrom-Array`, `Get-RegistryKeyType` = value-kind sibling); the genuinely
  new builds are `Test-TargetResource` + `Set-TargetResource` (+ maybe a `Get-TargetResourceInternal`
  dispatcher).
- 2026-06-09: Owner decisions on the path forward: (a) resolve the entanglement by PER-FUNCTION
  MATURITY COMPARISON - choose the most-mature version per function as canonical, ARCHIVE the
  non-chosen alternate (do not delete); (b) the Test/Set unification design (one mode-driven body
  vs shared-setup + thin shims) gets its OWN dedicated step/window to determine the objectively
  best route. Next: the canonical-selection cycle (in current TASK); then the Test/Set design step;
  then the per-function build. The rejected refactored `src/`/`tests/` are removed in the canonical
  cycle (fidelity now confirmed by the audit).
- 2026-06-09: CANONICAL SELECTION executed by Codex, audited + admin-merged by Claude (PR #12 ->
  `729c80a`). 14 canonical + 6 archived bodies (verbatim - byte-identical extracts confirmed; no
  refactoring); refactored `src/`/`tests/` removed. Codex resolved the entanglement by choosing
  File A's contract as the coherent spine (rich-object `Start-ProviderSetup` + A's `Get-TargetResource`
  + separated-field normalizers + the A JSON driver), filling in B where single-source or more
  mature (`Get-TypedObject` value-data coercer). Owner CONFIRMED the A-spine baseline; the deeper
  contract (separated-field vs full-key, A vs B `Get-TargetResource` output shape, hive descriptor
  vs string) is deferred to the Test/Set design step and finalized there (archives preserved =
  reversible). Selection ledger: `docs/design/canonical-selection.md`.
- 2026-06-09: Next = Test/Set Execution-Dispatch Design (current TASK): determine the objectively
  best way to fold Get/Test/Set into the owner's single path (one mode-driven body vs shared-setup +
  thin shims vs another route), as an analysis + Draft ADR 0007, for owner decision. Note: ADRs 0005
  (evidence) + 0006 (mutation/ShouldProcess) already frame a Get/Test/Plan/Apply operation-mode model
  with a read-only/Apply split - prior art the design must reconcile with. Then the per-function build.

## 11. Step Advancement Protocol
1. Exactly ONE phase is active in `TASK.md` at a time. The H1 reads
   `# TASK - Phase N: <objective>` (a directive, never a status). "Phase N" follows
   Section 6. Planning-only edits to handoff files are not phases (logged in
   Section 10).
2. Codex executes the active TASK, archives + overwrites `REPORT.md` (Section 0.2),
   and `REPORT.md` states `Phase N status: COMPLETE | BLOCKED | NEEDS-OWNER`.
3. Step advancement is performed ONLY by Claude (or the owner). Codex MUST NOT edit
   `TASK.md`, change the H1, or advance the phase number.
4. To advance, Claude: (a) reads `REPORT.md`; (b) confirms every Definition-of-Done
   item and the relevant Gate are met; (c) overwrites `TASK.md` for Phase N+1;
   (d) appends a Change Log entry; (e) updates the Section 7 ledger.
5. If `REPORT.md` status is BLOCKED or NEEDS-OWNER, Claude does NOT advance: it
   escalates the named owner decision and leaves the phase active.

## 12. Glossary
Term meanings are fixed here; do not redefine them elsewhere.
- Provenance: ALL FOUR of source PDF filename, page number(s), extraction method
  (text-layer or OCR), and manual-correction notes, anchored to the immutable PDF
  SHA-256 in `manifest.json`. A function missing any field is NOT provenanced.
- Detangle: the Phase 2 procedure exactly (compare signature AND behavior, then
  record one decision: keep_A / keep_B / merge / discard / defer). Never "pick
  whichever parses".
- Maturity / mature source of truth: the version scoring best on 2.4. Ties are
  deferred, not guessed.
- Reconciliation matrix: the 2.2 table; exactly one row per `function_key`.
- Phase 4 disposition buckets (assign exactly one per surface): port directly
  (reuse largely as-is); adapt conceptually (same idea, TargetState's own
  implementation; some mechanism survives); replace with TargetState-native (only
  the requirement survives); explicitly skip (record why); defer until after
  Registry proof (record missing evidence). Boundary adapt-vs-replace: if any
  original mechanism/algorithm survives it is adapt; if only the requirement
  survives it is replace.
- Evidence: machine-verifiable output (command/test/parser results, or official-
  source links) sufficient for a reviewer to confirm a claim without re-running
  discovery.
