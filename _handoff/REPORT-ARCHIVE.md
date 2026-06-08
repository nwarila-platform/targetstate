## Archived 2026-06-08T20:01:14Z - Phase 3 (pure)

Phase/Task status: COMPLETE

## Adversarial review verdict

Goal: execute Phase 2 only: reconcile the Phase 1 function inventory across
`06042026.pdf` (A) and `06042026_001.pdf` (B), decide the mature source of truth
per normalized `function_key`, and write decision artifacts under local-only
`_recovery/_inventory/`. This cycle did not port, rewrite, correct OCR, execute
recovered logic, create source files, or touch live Windows state.

Branch check: PROCEED on `recovery/phase-2-detangling`, not `main`.

Input gate: PROCEED. Phase 1 inputs exist:
`_recovery/_inventory/function-inventory.tsv`,
`_recovery/_inventory/call-graph.tsv`,
`_recovery/06042026/corrected/`, `_recovery/06042026_001/corrected/`,
`_recovery/06042026/images/`, and `_recovery/06042026_001/images/`.
The inventory reports 20 occurrences, 10 per PDF. Corrected text counts are
17 pages for A and 16 pages for B. Rendered image counts are 17 pages for A and
16 pages for B.

PDF hash gate: PROCEED. The current SHA-256 hashes match the Phase 1 manifest:
`06042026.pdf` =
`B6BD5239D642D09368E255E21064B1F48C63D075DD43F8374098300DB9ED155F`;
`06042026_001.pdf` =
`D6BE73056B47FB9EEA9126A9EA5BC232BCF733A5562306AC2A601FA57FFC051E`.

Plan challenge: TASK.md references a `PLAN 2.9 command set`, but PLAN.md Phase 2
currently defines only 2.1 through 2.8. I did not treat this as a blocking
misalignment because TASK.md lists the required verification checks and PLAN 2.7
defines acceptance criteria. Verification below uses the explicit TASK D checks.

Normalization and tie-break source: `function_key` was formed by lowercasing,
stripping whitespace, and collapsing the OCR-confusable classes `l/1/I` and
`O/0` for the key only. Displayed names were not corrected. Tie-breaking used
Phase 1 corrected text and already-rendered page images only.

Decision: PROCEED and COMPLETE Phase 2. Chosen output locations:
`_recovery/_inventory/reconciliation-matrix.tsv`,
`_recovery/_inventory/decisions.tsv`,
`_recovery/_inventory/UNCERTAIN.md`, and this report.

## What changed

- Archived the previous `REPORT.md` verbatim to the top of
  `_handoff/REPORT-ARCHIVE.md` under
  `## Archived 2026-06-08T19:28:31Z - Phase 2`.
- Wrote the Phase 2 adversarial verdict before producing decisions.
- Created local-only `_recovery/_inventory/reconciliation-matrix.tsv` with
  18 normalized `function_key` rows.
- Created local-only `_recovery/_inventory/decisions.tsv` with 18 current
  decision rows.
- Updated local-only `_recovery/_inventory/UNCERTAIN.md` with Phase 2 defer and
  OCR-name-mismatch review notes.
- Preserved the Claude-updated `PLAN.md`, `TASK.md`, and
  `CLAUDE-RESTART-PROMPT.md` content as-is for the PR.

Decision summary:

```text
keep_A  9
keep_B  9
merge   0
discard 0
defer   0
```

Cross-PDF duplicate functions found:

```text
Start-ProviderSetup -> keep_A (R4 maturity_score)
Get-TargetResource  -> keep_B (R4 maturity_score)
```

OCR-name-mismatch suspects reviewed but not collapsed:

```text
Get-RegistryKeyHiveObj vs Get-RegistryKeyHive
Get-RegistryKeyPathStr vs Get-RegistryKeyPath
Get-RegistryKeyNameStr vs Get-RegistryKeyName
```

Rendered page images confirmed these suffix/name differences are visible source
text, not OCR-confusable variants of the same function key.

Deferred functions pending Phase 3 OCR correction:

```text
None
```

## What was intentionally not changed

- No recovered logic was rewritten, ported, stabilized, or executed.
- No OCR text was corrected.
- No source PDFs were opened, parsed, modified, staged, or committed.
- No `_recovery/` artifact was staged or committed; all Phase 2 decision
  artifacts remain local-only under the ignored `_recovery/` tree.
- No PowerShell source/module/test files, `src/`, or `tests/` were created.
- No live Windows registry or system state was touched.
- `PLAN.md`, `TASK.md`, and `CLAUDE-RESTART-PROMPT.md` content was not edited by
  Codex.

## Verification output

`Compare-Object` of unique normalized inventory keys vs matrix keys:

```text
```

Invalid or missing matrix decisions, rules, or rationales:

```text
```

Low-confidence `merge`/`discard` rows:

```text
```

Decision histogram:

```text
Name   Count
----   -----
keep_A     9
keep_B     9
```

Unlogged `defer` rows:

```text
```

PDF hashes vs Phase 1 manifest:

```text
Path            : 06042026.pdf
CurrentHash     : B6BD5239D642D09368E255E21064B1F48C63D075DD43F8374098300DB9ED155F
ManifestHash    : B6BD5239D642D09368E255E21064B1F48C63D075DD43F8374098300DB9ED155F
MatchesManifest : True

Path            : 06042026_001.pdf
CurrentHash     : D6BE73056B47FB9EEA9126A9EA5BC232BCF733A5562306AC2A601FA57FFC051E
ManifestHash    : D6BE73056B47FB9EEA9126A9EA5BC232BCF733A5562306AC2A601FA57FFC051E
MatchesManifest : True
```

Row counts:

```text
InventoryDistinctKeys : 18
MatrixRows            : 18
MatrixDistinctKeys    : 18
CurrentDecisionRows   : 18
```

`git check-ignore -v _recovery/`

```text
.gitignore:23:/_recovery/	_recovery/
```

`git ls-files -- 06042026.pdf 06042026_001.pdf _recovery/`

```text
```

`Get-ChildItem -Recurse -Include *.ps1,*.psm1,*.psd1 -Path . -ErrorAction SilentlyContinue | Select-Object FullName`

```text
```

`git branch --show-current`

```text
recovery/phase-2-detangling
```

`git log --show-signature -1` before the Phase 2 commit:

```text
commit ed7c5359eefb5cb7121e6a63c2b35f09adb8fc55
gpg: Signature made Mon Jun  8 19:19:58 2026 CUT
gpg:                using RSA key B5690EEEBB952194
gpg: Can't check signature: No public key
Author: Smarter  Harder <33955773+NWarila@users.noreply.github.com>
Date:   Mon Jun 8 19:19:58 2026 +0000

    Governance: deny-by-default tracking policy (ADR 0002) (#3)
```

This output refers to the prior owner squash merge, not the Phase 2 commit. The
final Phase 2 commit is created after this report is finalized, so its signature
cannot be embedded here without an infinite self-reference. I will rerun
`git log --show-signature -1` after the Phase 2 commit and include that output
in the PR body and final response.

`git status -sb` before staging:

```text
## recovery/phase-2-detangling
 M _handoff/CLAUDE-RESTART-PROMPT.md
 M _handoff/PLAN.md
 M _handoff/REPORT-ARCHIVE.md
 M _handoff/REPORT.md
 M _handoff/TASK.md
```

No PDFs or `_recovery/` paths appear in status because they are ignored and
local-only by policy.

## Deviations from `TASK.md` and why

- TASK.md references `PLAN 2.9`, but PLAN.md has no Phase 2 subsection after 2.8.
  I used the explicit TASK D command list and PLAN 2.7 acceptance criteria.
- The final signed Phase 2 commit cannot be proven inside the committed report
  without self-reference. The post-commit signature check will be included in the
  PR body and final response.

## Open objections that must be resolved before advancing

- None blocking. Claude should fix or remove the TASK.md reference to `PLAN 2.9`
  in future planner text because PLAN currently stops Phase 2 at 2.8.

## Owner decisions needed

- D2 remains on its default: `_recovery/` reconciliation artifacts stay
  local-only and are summarized here. Owner review is needed before any future
  commit of those local-only artifacts.
- Owner admin-merge remains required after Claude audit; Codex must not merge
  this PR.

Phase 2 status: COMPLETE

## Archived 2026-06-08T19:28:31Z - Phase 2

Phase/Task status: COMPLETE

## Adversarial review verdict

Goal: execute only the owner-initiated governance interlude for ADR 0002:
replace `.gitignore` with a deny-by-default tracking policy, add
`docs/adr/0002-deny-by-default-tracking.md` as `Status: Draft`, keep the source
PDFs and `_recovery/` ignored and untracked, and stop after opening a PR to
`main`. This cycle did not extract PDFs, start Phase 2, write engine/source
files, audit DSC, or touch live Windows state.

Branch check: PROCEED on `recovery/governance-deny-by-default`, not `main`.

Mechanism challenge: a bare `**` at the top of `.gitignore` is not the right
mechanism for this repo's allowlist. It ignores recursively and makes
re-inclusion brittle because Git cannot re-include a path when a parent
directory remains excluded. The maintainable policy is the TASK.md form:
ignore repo-root entries with `/*`, then explicitly re-include the currently
tracked top-level files/directories, with directory allowlist entries ending in
`/`. This preserves tracked-path ergonomics while denying accidental new
top-level files by default.

Decision: PROCEED with the exact TASK.md `.gitignore` allowlist. ADR 0002 remains
Draft pending owner approval. The source PDFs and `_recovery/` remain
hard-denied and must never receive a `!` allowlist entry.

Chosen output locations: `.gitignore`, `docs/adr/0002-deny-by-default-tracking.md`,
and `_handoff/REPORT.md` / `_handoff/REPORT-ARCHIVE.md`.

## What changed

- Archived the Phase 1 `REPORT.md` verbatim to the top of
  `_handoff/REPORT-ARCHIVE.md` under
  `## Archived 2026-06-08T18:55:25Z - Governance ADR 0002`.
- Replaced `.gitignore` with the exact deny-by-default `/*` allowlist from
  `TASK.md`.
- Added Draft ADR 0002 at `docs/adr/0002-deny-by-default-tracking.md`.
- Committed the Claude-updated `_handoff/PLAN.md`, `_handoff/TASK.md`, and
  `_handoff/CLAUDE-RESTART-PROMPT.md` as-is for durability, per `TASK.md`.

Implementation commit:

```text
a9d396690d6a52435f002f0522364706eab954f5 chore(governance): deny-by-default tracking policy (ADR 0002)
```

## What was intentionally not changed

- No PDFs, `_recovery/` content, extraction output, DSC audit artifacts, engine
  files, source files, `src/`, or `tests/` were added.
- No live Windows registry or system state was touched.
- No ADR was marked Accepted.
- `docs/governance.md` was not changed; the TASK.md governance pointer was
  optional, and ADR 0002 is already discoverable in `docs/adr/`.
- `PLAN.md`, `TASK.md`, and `CLAUDE-RESTART-PROMPT.md` content was not edited by
  Codex.

## Verification output

`git check-ignore -v 06042026.pdf 06042026_001.pdf _recovery/`

```text
.gitignore:21:/06042026.pdf	06042026.pdf
.gitignore:22:/06042026_001.pdf	06042026_001.pdf
.gitignore:23:/_recovery/	_recovery/
```

`git check-ignore -v README.md _handoff\PLAN.md docs\governance.md .gitattributes`

```text
```

Exit code: `1` (expected: tracked files are not ignored).

`git check-ignore -v probe.tmp`

```text
.gitignore:27:*.tmp	probe.tmp
```

Additional adversarial proof for a new unlisted top-level file that does not
match the `*.tmp` noise rule:

`git check-ignore -v probe.unlisted`

```text
.gitignore:10:/*	probe.unlisted
```

Both temporary probe files were deleted after their checks.

`git check-ignore -v docs\adr\0002-deny-by-default-tracking.md`

```text
```

Exit code: `1` (expected: ADR 0002 is under allowlisted `docs/` and is not
ignored).

`git status --short`

```text
 M _handoff/REPORT.md
```

Note: this is the expected self-reference state before committing this final
report update. It shows no PDFs and no `_recovery/` paths.

`git ls-files`

```text
.gitattributes
.github/CODEOWNERS
.gitignore
README.md
_handoff/CLAUDE-RESTART-PROMPT.md
_handoff/PLAN.md
_handoff/REPORT-ARCHIVE.md
_handoff/REPORT.md
_handoff/TASK.md
docs/adr/0000-adr-process.md
docs/adr/0001-targetstate-charter.md
docs/adr/0002-deny-by-default-tracking.md
docs/governance.md
```

`git ls-files -- 06042026.pdf 06042026_001.pdf _recovery/`

```text
```

`Get-ChildItem docs\adr\*.md | Where-Object { (Get-Content $_ -Raw) -notmatch "(?m)^Status:\s*Draft\s*$" } | ForEach-Object { Write-Error "ADR not Draft: $($_.Name)" }`

```text
```

`.gitignore` first three bytes:

```text
23-20-3D
```

ADR 0002 first three bytes:

```text
23-20-41
```

These are not UTF-8 BOM bytes.

`git branch --show-current`

```text
recovery/governance-deny-by-default
```

`git log --show-signature -1`

```text
commit a9d396690d6a52435f002f0522364706eab954f5
Good "git" signature for 33955773+NWarila@users.noreply.github.com with ECDSA key SHA256:UAsMtOhQwpR/duoYjPY3LSw4a905Dx29QPGGXCTkhGY
Author: NWarila <33955773+NWarila@users.noreply.github.com>
Date:   Mon Jun 8 19:01:29 2026 +0000

    chore(governance): deny-by-default tracking policy (ADR 0002)
```

The final report commit necessarily occurs after this embedded output. Codex
will re-run `git log --show-signature -1` after committing this report and include
that final signature output in the PR body and final response.

## Deviations from `TASK.md` and why

- The required `probe.tmp` verification printed a rule, but the matching rule was
  `*.tmp`, not `/*`. That satisfies the literal TASK.md check but is weak evidence
  for deny-by-default. I added `probe.unlisted` as an extra proof that a new
  unlisted top-level file is ignored by the root `/*` rule.
- The final signed report commit cannot be proven inside the same committed
  report without an infinite self-reference. The implementation commit signature
  is pasted above; the final report commit signature will be provided in the PR
  body and final response.

## Open objections that must be resolved before advancing

None blocking. Claude should note that future verification should avoid
`probe.tmp` if the intent is specifically to test `/*`; use a name that does not
match any noise rule.

## Owner decisions needed

ADR 0002 remains Draft until owner approval. Owner admin-merge remains required
after Claude audit; Codex must not merge this PR.

Governance status: COMPLETE

## Archived 2026-06-08T18:55:25Z - Governance ADR 0002

Phase/Task status: COMPLETE

## Adversarial review verdict

Goal: execute Phase 1 only by deterministically extracting recoverable text/code
from `06042026.pdf` and `06042026_001.pdf` into local-only `_recovery/`
evidence with provenance. This phase does not rewrite logic, port code, detangle
functions, stabilize source, create engine/source files, audit DSC, or touch live
Windows state.

Gate 0 -> 1: GREEN per `_handoff/TASK.md` and `PLAN.md` Section 7. I also
re-checked the hard safety facts before extraction:

- `git check-ignore -v 06042026.pdf 06042026_001.pdf _recovery/` prints rules
  for both PDFs and `_recovery/`.
- `git ls-files -- 06042026.pdf 06042026_001.pdf _recovery/` is empty.
- `git status --short` showed only Claude-updated handoff files; no PDFs or
  `_recovery/` paths were staged.

PDF integrity at phase start:

| File | SHA-256 | Bytes | Baseline match |
|------|---------|-------|----------------|
| `06042026.pdf` | `B6BD5239D642D09368E255E21064B1F48C63D075DD43F8374098300DB9ED155F` | `19780374` | yes, matches `...155F` |
| `06042026_001.pdf` | `D6BE73056B47FB9EEA9126A9EA5BC232BCF733A5562306AC2A601FA57FFC051E` | `2780237` | yes, matches `...051E` |

Toolchain re-probe:

| Tool | Result |
|------|--------|
| `pdftotext.exe` | present at `C:\Program Files\Git\mingw64\bin\pdftotext.exe`; reports `pdftotext version 4.00` |
| `tesseract.exe` | present at `C:\Program Files\Tesseract-OCR\tesseract.exe`; reports `tesseract v5.5.0.20241111` |
| `python` | present; `Python 3.14.3` |
| `pdfplumber` | present; `0.11.9` |
| `pypdf` | missing, as expected |
| `fitz` / PyMuPDF | missing, as expected |
| `pdftoppm.exe` | missing, as expected |
| `pdfimages.exe` | missing, as expected |
| `magick.exe` | missing, as expected |
| Windows PowerShell | present; `5.1.26100.8457` |
| Pester | present; `5.7.1` |
| `pwsh.exe` | missing, as expected |

Text-layer detection:

| File | Pages | Pages with >=20 stripped text chars | Text layer ratio | Sample PowerShell-ish tokens | Selected mode |
|------|-------|--------------------------------------|------------------|-------------------------------|---------------|
| `06042026.pdf` | `17` | `0` | `0.0000` | none (`function=0`, `param=0`, braces `0/0`) | `ocr` |
| `06042026_001.pdf` | `16` | `0` | `0.0000` | none (`function=0`, `param=0`, braces `0/0`) | `ocr` |

OCR path selected: `pdfplumber` render at 300 DPI to `_recovery/<stem>/images/`,
then Tesseract English OCR with `--psm 6 --oem 1`, writing raw text plus TSV
confidence sidecars. Renderer capability was verified read-only on page 1 of
each PDF: `06042026.pdf` rendered `2539x3282`; `06042026_001.pdf` rendered
`2540x3280`.

Decision: PROCEED

Challenge result: the text-layer ratio is zero for both PDFs, so a text or
hybrid path would produce empty evidence and would violate the goal to recover
all available text/code. The required present-only OCR toolchain is available;
no install or network call is needed. The output location is `_recovery/`,
local-only and uncommitted this cycle per D2.

Evidence handling commitment honored: all output is evidence. `raw/` contains
generated extractor output only. `corrected/` contains the OCR text plus
greppable OCR hazard markers where applicable. No recovered logic was rewritten,
ported, executed, detangled, or stabilized in Phase 1.

## What changed

- Archived the prior Phase 0 `REPORT.md` verbatim to the top of
  `_handoff/REPORT-ARCHIVE.md` under a Phase 1 archive heading.
- Replaced `_handoff/REPORT.md` with the Phase 1 verdict, extraction summary,
  verification output, deviations, and owner-decision carry-forward.
- Generated the local-only, git-ignored `_recovery/` evidence tree:
  - `_recovery/README.md`
  - `_recovery/manifest.json`
  - `_recovery/06042026/pages.index.tsv`
  - `_recovery/06042026/raw/page-0001.txt` through `page-0017.txt`
  - `_recovery/06042026/corrected/page-0001.txt` through `page-0017.txt`
  - `_recovery/06042026/images/page-0001.png` through `page-0017.png`
  - `_recovery/06042026/ocr/page-0001.tsv` through `page-0017.tsv`
  - `_recovery/06042026_001/pages.index.tsv`
  - `_recovery/06042026_001/raw/page-0001.txt` through `page-0016.txt`
  - `_recovery/06042026_001/corrected/page-0001.txt` through `page-0016.txt`
  - `_recovery/06042026_001/images/page-0001.png` through `page-0016.png`
  - `_recovery/06042026_001/ocr/page-0001.tsv` through `page-0016.tsv`
  - `_recovery/_inventory/function-inventory.tsv`
  - `_recovery/_inventory/call-graph.tsv`
  - `_recovery/_inventory/UNCERTAIN.md`

Extraction summary:

| Metric | `06042026.pdf` | `06042026_001.pdf` | Total |
|--------|----------------|--------------------|-------|
| Pages | `17` | `16` | `33` |
| PDF-level mode | `ocr` | `ocr` | `ocr` |
| Page statuses | `17 needs_correction` | `16 needs_correction` | `33 needs_correction` |
| Raw text files | `17` | `16` | `33` |
| Corrected files | `17` | `16` | `33` |
| Raster images | `17` | `16` | `33` |
| OCR TSV sidecars | `17` | `16` | `33` |

Inventory summary:

- Function occurrences: `20`
- Unique function names: `18`
- Call-graph edges: `22`
- `UNCERTAIN.md` render/empty-OCR blockers: `0`
- Outstanding OCR hazard flags in corrected pages: `OCR:SPLAT=16`,
  `OCR:L1I=10`, `OCR:BRACE=6`

## What was intentionally not changed

- No `_recovery/` content was staged or committed.
- No source, engine, module, registry, DSC audit, ADR, governance, README, PDF,
  `PLAN.md`, `TASK.md`, or `CLAUDE-RESTART-PROMPT.md` content was edited by
  Codex.
- The already-modified Claude planner files were left as-is for the required
  durability commit.
- No tooling was installed.
- No network, cloud OCR, upload, or external service was used.
- No live Windows system state was touched.
- No recovered code was executed, parsed as production, detangled, stabilized, or
  ported.

## Verification output

PLAN 1.11(a) source PDFs untouched:

```text
Hash                                                             Path
----                                                             ----
B6BD5239D642D09368E255E21064B1F48C63D075DD43F8374098300DB9ED155F C:\Users\HellBomb\Documents\GitHub\nwarila-platform...
D6BE73056B47FB9EEA9126A9EA5BC232BCF733A5562306AC2A601FA57FFC051E C:\Users\HellBomb\Documents\GitHub\nwarila-platform...
```

PLAN 1.11(b) page coverage:

```text
06042026: index_rows=17 raw_pages=17
06042026_001: index_rows=16 raw_pages=16
```

PLAN 1.11(c) status histogram:

```text
Count Name
----- ----
   33 needs_correction
```

PLAN 1.11(d) outstanding OCR flags:

```text
Count Name
----- ----
    6 OCR:BRACE
   10 OCR:L1I
   16 OCR:SPLAT
```

PLAN 1.11(e) function names found:

```text
Convert-ByteArrayToHexString
ConvertFrom-Array
Get-NormalizedRegistryKey
Get-RegistryKeyHive
Get-RegistryKeyHiveObj
Get-RegistryKeyName
Get-RegistryKeyNameStr
Get-RegistryKeyPath
Get-RegistryKeyPathStr
Get-RegistryResourceObject
Get-RegistryValueData
Get-RegistryValueKindStr
Get-RegistryValueNameStr
Get-TargetResource
Get-TypedObject
Mount-RegistryHive
Start-ProviderSetup
ThrowError
```

PLAN 1.11(f) inventory page-reference integrity:

```text
```

PLAN 1.11(g) hygiene:

```text
## recovery/phase-1-extraction
 M _handoff/CLAUDE-RESTART-PROMPT.md
 M _handoff/PLAN.md
 M _handoff/REPORT-ARCHIVE.md
 M _handoff/REPORT.md
 M _handoff/TASK.md
```

PDF integrity vs manifest:

```text
06042026.pdf: pre=B6BD5239D642D09368E255E21064B1F48C63D075DD43F8374098300DB9ED155F post=B6BD5239D642D09368E255E21064B1F48C63D075DD43F8374098300DB9ED155F current=B6BD5239D642D09368E255E21064B1F48C63D075DD43F8374098300DB9ED155F unchanged=True
06042026_001.pdf: pre=D6BE73056B47FB9EEA9126A9EA5BC232BCF733A5562306AC2A601FA57FFC051E post=D6BE73056B47FB9EEA9126A9EA5BC232BCF733A5562306AC2A601FA57FFC051E current=D6BE73056B47FB9EEA9126A9EA5BC232BCF733A5562306AC2A601FA57FFC051E unchanged=True
```

Page/corrected coverage:

```text
06042026: missing_raw=0 missing_corrected_nonclean=0 blank_status=0
06042026_001: missing_raw=0 missing_corrected_nonclean=0 blank_status=0
```

Clean-page sentinel check:

```text
06042026: clean_pages=0 clean_sentinel_hits=0
06042026_001: clean_pages=0 clean_sentinel_hits=0
```

`git check-ignore -v _recovery/`:

```text
.gitignore:8:/_recovery/	_recovery/
```

`git ls-files | Select-String -Pattern '(^_recovery/|\.pdf$)'`:

```text
```

`Get-ChildItem -Recurse -Include *.psm1,*.ps1,*.psd1 -Path . -ErrorAction SilentlyContinue | Select-Object FullName`:

```text
```

`git branch --show-current`:

```text
recovery/phase-1-extraction
```

Local-only artifact count:

```text
06042026: raw=17 corrected=17 images=17 ocr_tsv=17
06042026_001: raw=16 corrected=16 images=16 ocr_tsv=16
```

Inventory files:

```text
Name                   Length
----                   ------
call-graph.tsv           1505
function-inventory.tsv   6438
UNCERTAIN.md              281
```

`git status --ignored --short _recovery`:

```text
!! _recovery/
```

Commit-signature verification note:

```text
commit.gpgsign=true was verified before committing. The final signed-commit
`git log --show-signature -1` output must be run after this report is committed,
because embedding the latest commit's signature in the committed report is
self-referential. Codex will run it after commit and include the output in the PR
body and final response.
```

## Deviations from `TASK.md` and why

- The `PLAN.md` 1.3 example tree mentions `raw/page-0001.ocr.txt` for OCR/hybrid
  pages, but PLAN 1.11(b) counts `raw/page-*.txt` and PLAN 1.11(f) checks
  `raw/page-$page_start.txt`. Writing both `.txt` and `.ocr.txt` would double the
  page count, while writing only `.ocr.txt` would break inventory integrity. I
  wrote one canonical `raw/page-XXXX.txt` per page and kept Tesseract confidence
  sidecars in `ocr/page-XXXX.tsv`.
- All pages are marked `needs_correction` rather than `clean`. This is
  intentional: both PDFs required OCR, no human image-by-image correction pass was
  performed, and Phase 1 evidence should not overstate OCR certainty.
- The sandbox could not spawn normal PowerShell commands (`windows sandbox: spawn
  setup refresh`), so every local command was re-run with approved escalation.
  No network, install, or write outside the permitted paths was performed.
- The final `git log --show-signature -1` output cannot be embedded in the same
  commit it verifies. I will run it after committing and include it in the PR
  body/final response.

## Open objections that must be resolved before advancing

- Claude should clarify the `raw/page-XXXX.ocr.txt` example versus the PLAN 1.11
  verification commands before asking for a byte-for-byte rerun of Phase 1.
- Phase 2 must treat every page as OCR-needing-correction evidence, not as
  stabilized source. The OCR inventory is a starting index only; function names
  and call edges still require adversarial detangling/review.

## Owner decisions needed

- D2 remains on the default: keep the entire `_recovery/` tree local-only and
  uncommitted this cycle.
- D3 remains on the default: use repo-root `_recovery/`.
- D4 remains on the default: present-only tooling; no installs were needed.
- Owner/Claude must review this report before Gate 1 -> 2 is GREEN; Codex must
  not begin Phase 2 from this cycle.

Phase 1 status: COMPLETE

## Archived 2026-06-08T18:09:45Z - Phase 1

Phase/Task status: NEEDS-OWNER

## Adversarial review verdict

Goal: execute Phase 0 only for TargetState by establishing a safe repo governance
baseline on a working branch before any recovered code, PDF extraction, DSC audit,
or engine/source work can begin.

Decision: PROCEED

Output location: branch `recovery/phase-0-governance`, with artifacts committed
under the repo root and `_handoff/`.

Challenge result: the governance-first approach is correct because Phase 1
extraction would be unsafe without narrow PDF ignores, a recovery-output ignore,
branch discipline, and a written rule ledger. The `.gitignore` design is correct
because it ignores only the two named PDFs and `/_recovery/`, with no blanket
`*.pdf`. The ADR layout is appropriately minimal and is not attributed to
`NWarila/powershell-template`, which the plan says has no ADR convention yet.

Objection: TASK.md asks `git check-ignore -v ... _recovery` to print a rule, but
PLAN.md also requires the exact `.gitignore` line `/_recovery/` and forbids
creating `_recovery/` in Phase 0. With the directory absent, Git proves that rule
with `_recovery/`, not bare `_recovery`. I did not hide this with a local exclude
or by creating the forbidden directory.

I did not open, parse, extract, OCR, or otherwise inspect PDF contents. I hashed
the two PDF files and recorded byte sizes only. I did not write any `.ps1`,
`.psm1`, `.psd1`, `src/`, `tests/`, engine, resource, registry, or DSC audit
artifact.

Owner decisions recorded/applied:

- D1 PDF disposition: answered; PDFs are local-only + SHA-256 manifest policy.
- D5 README positioning: answered; README reframed to GitOps/YAML-not-MOF.
- D2 generated-artifact commit policy: default remains all `_recovery/` output
  local-only until decided.
- D3 recovery directory name: default remains repo-root `_recovery/`.
- D4 OCR/PDF tooling: default remains present-only; no tooling installed.
- D6 Phase 4 in-box discovery: still future/default, not touched in Phase 0.

## What Changed

- Added exact root `.gitignore` from PLAN.md Phase 0.
- Added exact root `.gitattributes` from PLAN.md Phase 0.
- Added Draft ADR process scaffold at `docs/adr/0000-adr-process.md`.
- Added Draft TargetState charter ADR at `docs/adr/0001-targetstate-charter.md`.
- Added governance rule ledger at `docs/governance.md`.
- Reframed `README.md` around the GitOps-friendly Microsoft PowerShell DSC
  replacement mission and YAML-style declaration documents instead of generated
  MOF.
- Archived the seed report to `_handoff/REPORT-ARCHIVE.md`.
- Committed previously untracked `_handoff/*.md` for durability as required by
  PLAN.md Section 0.1. I did not edit `PLAN.md`, `TASK.md`, or
  `CLAUDE-RESTART-PROMPT.md`.

PDF baselines recorded without opening or parsing contents:

| File | SHA-256 | Bytes |
|------|---------|-------|
| `06042026.pdf` | `B6BD5239D642D09368E255E21064B1F48C63D075DD43F8374098300DB9ED155F` | `19780374` |
| `06042026_001.pdf` | `D6BE73056B47FB9EEA9126A9EA5BC232BCF733A5562306AC2A601FA57FFC051E` | `2780237` |

## What Was Intentionally Not Changed

- No PDF extraction, OCR, parsing, or content inspection.
- No source, engine, resource, module, registry, DSC audit, `src/`, `tests/`, or
  `_recovery/` artifacts.
- No edits to `_handoff/PLAN.md`, `_handoff/TASK.md`, or
  `_handoff/CLAUDE-RESTART-PROMPT.md`.
- No live Windows registry or system state touched.
- No tooling installed.
- No PDFs, large binaries, or `_recovery/` files staged or committed.
- No ADR marked Accepted.

## Verification Output

Captured after signed commit `70aaca206798fcbc39e9aaadd5721e673ce65cf3`.
This report update itself must be committed afterward, which creates a new signed
handoff commit; I will re-run `git log --show-signature -1` after that final
commit and report it to the owner.

`git branch --show-current`

```text
recovery/phase-0-governance
```

`git log --show-signature -1`

```text
commit 70aaca206798fcbc39e9aaadd5721e673ce65cf3
Good "git" signature for 33955773+NWarila@users.noreply.github.com with ECDSA key SHA256:UAsMtOhQwpR/duoYjPY3LSw4a905Dx29QPGGXCTkhGY
Author: NWarila <33955773+NWarila@users.noreply.github.com>
Date:   Mon Jun 8 17:37:01 2026 +0000

    Phase 0: repo governance baseline
```

`git status --short --branch`

```text
## recovery/phase-0-governance
```

`git check-ignore -v 06042026.pdf 06042026_001.pdf _recovery`

```text
.gitignore:4:/06042026.pdf	06042026.pdf
.gitignore:5:/06042026_001.pdf	06042026_001.pdf
```

Additional proof for the exact directory rule required in `.gitignore`:

`git check-ignore -v _recovery/`

```text
.gitignore:8:/_recovery/	_recovery/
```

`git ls-files -- 06042026.pdf 06042026_001.pdf _recovery/`

```text
```

`git ls-files`

```text
.gitattributes
.github/CODEOWNERS
.gitignore
README.md
_handoff/CLAUDE-RESTART-PROMPT.md
_handoff/PLAN.md
_handoff/REPORT-ARCHIVE.md
_handoff/REPORT.md
_handoff/TASK.md
docs/adr/0000-adr-process.md
docs/adr/0001-targetstate-charter.md
docs/governance.md
```

`Get-ChildItem docs\adr\*.md | Where-Object { (Get-Content $_ -Raw) -notmatch "(?m)^Status:\s*Draft\s*$" } | ForEach-Object { Write-Error "ADR not Draft: $($_.Name)" }`

```text
```

`Test-Path docs\adr\0000-adr-process.md,docs\adr\0001-targetstate-charter.md,docs\governance.md,.gitignore,.gitattributes`

```text
True
True
True
True
True
```

`Get-ChildItem -Recurse -Include *.psm1,*.ps1,*.psd1 -Path . -ErrorAction SilentlyContinue`

```text
```

`Get-FileHash 06042026.pdf,06042026_001.pdf -Algorithm SHA256`

```text

Algorithm       Hash                                                                   Path                            
---------       ----                                                                   ----                            
SHA256          B6BD5239D642D09368E255E21064B1F48C63D075DD43F8374098300DB9ED155F       C:\Users\HellBomb\Documents\G...
SHA256          D6BE73056B47FB9EEA9126A9EA5BC232BCF733A5562306AC2A601FA57FFC051E       C:\Users\HellBomb\Documents\G...


```

Full hash-to-file mapping captured for clarity:

```text
C:\Users\HellBomb\Documents\GitHub\nwarila-platform\targetstate\06042026.pdf B6BD5239D642D09368E255E21064B1F48C63D075DD43F8374098300DB9ED155F
C:\Users\HellBomb\Documents\GitHub\nwarila-platform\targetstate\06042026_001.pdf D6BE73056B47FB9EEA9126A9EA5BC232BCF733A5562306AC2A601FA57FFC051E
```

`(Get-Item 06042026.pdf).Length`

```text
19780374
```

`(Get-Item 06042026_001.pdf).Length`

```text
2780237
```

## Deviations From TASK.md And Why

- The exact required command `git check-ignore -v 06042026.pdf
  06042026_001.pdf _recovery` did not print an `_recovery` rule. The exact PLAN
  `.gitignore` content uses `/_recovery/`, and Phase 0 forbids creating the
  `_recovery/` directory. I used `git check-ignore -v _recovery/` as the accurate
  proof of the committed directory ignore rule and marked the phase
  `NEEDS-OWNER`.
- `_handoff/PLAN.md`, `_handoff/TASK.md`, and
  `_handoff/CLAUDE-RESTART-PROMPT.md` were committed unchanged. This follows
  PLAN.md Section 0.1 durability guidance for `_handoff/*.md`; I did not edit
  Claude-owned files.
- The final report update is necessarily committed after the displayed
  `git log --show-signature -1` output is captured. I will verify the resulting
  final signed commit before push and report that output back.

## Open Objections Before Advancing

- Gate 0 -> 1 should not be treated as GREEN until Claude or the owner resolves
  the `_recovery` verification mismatch by accepting the `_recovery/` check,
  changing the verification command, allowing a committed ignore rule for bare
  `_recovery`, or allowing the directory to exist. I recommend changing the check
  to `_recovery/` because it matches the exact committed rule and keeps Phase 0
  from creating recovery output.
- The phrase "local-only + SHA-256 manifest" should remain policy-only in Phase 0.
  The actual `_recovery/manifest.json` file belongs to Phase 1 after Gate 0 -> 1.

## Owner Decisions Needed

- Decide whether the `_recovery/` ignore proof satisfies Gate 0 -> 1, or revise
  the check/rule before Phase 1.
- Carry forward D2: generated-artifact commit policy for later `_recovery/`
  output remains unresolved beyond the current default.
- Carry forward D3: repo-root `_recovery/` remains the default directory name
  unless the owner renames it.
- Carry forward D4: future OCR/PDF tooling remains present-only unless the owner
  approves installs.
- Carry forward D6: Phase 4 in-box DSC discovery remains undecided.

Phase 0 status: NEEDS-OWNER

## Archived 2026-06-08T17:31:04Z - Phase 0

# REPORT - Seed / Current State

> Note to next Codex: this file is Codex-owned and is replaced each cycle. Before
> overwriting it, FIRST append the current contents verbatim to the top of
> `_handoff/REPORT-ARCHIVE.md` under `## Archived <UTC date> - <phase id>`
> (append-only), per PLAN.md Section 0.2. Durable state lives in PLAN.md Section 7;
> nothing unresolved here may be silently dropped.

Phase 0 status: READY TO START (no Codex cycle has run yet). Owner answered the
blocking decisions on 2026-06-08: sequencing = Phase 0 first; D1 = PDFs local-only
+ SHA-256 manifest; D5 = reframe README to the GitOps/YAML-not-MOF mission. D2/D3/D4
ride on their documented defaults (all Phase 1 concerns).

## Current state
- `_handoff` is adopted inside `nwarila-platform/targetstate` as a deliberate
  repo-local proof-of-concept.
- The ACTIVE TASK is the one in `TASK.md`: Phase 0 - Repo Governance Baseline. It
  was re-sequenced from "PDF extraction" because Phase 1 is hard-blocked behind
  Gate 0 -> 1 (no `.gitignore`/`.gitattributes`, no ADR/governance scaffold, no
  working branch, PDF disposition unresolved). PDF extraction is the NEXT task,
  fully specified in PLAN.md Section 6 Phase 1.
- No engine, source, ADR content, extraction, or DSC audit has been performed.
- All ADRs are required to start as `Draft`.
- Repo currently tracks only `.github/CODEOWNERS` and `README.md`; `_handoff/*.md`
  and both PDFs (19,780,374 and 2,780,237 bytes) are untracked.
- Mission clarified by owner (2026-06-08): TargetState is a GitOps-friendly
  replacement for Microsoft PowerShell DSC, driving config from human-readable
  YAML-style declaration docs instead of generated MOF; STIG compliance is a major
  use case, not the explicit goal. See PLAN.md Section 1.
- `README.md` currently headlines "STIG-aligned system hardening"; Phase 0 step 7
  reframes it to the mission above (owner decision D5).

## Outstanding owner decisions
See PLAN.md Section 9. Resolved 2026-06-08: D1 (PDFs local-only + manifest),
D5 (README reframe), sequencing (Phase 0 first). Still on documented defaults
(Phase 1 concerns, not blocking Phase 0): D2 (generated-artifact commit policy),
D3 (`_recovery/` dir name), D4 (tooling install vs present-only), D6 (Phase 4
in-box discovery). Record which defaults were applied when each phase reaches them.

## Carried forward - plan history (2026-06-08)
- Owner directed that no extraction or implementation work happen yet.
- PLAN.md prioritizes recovery of the two root PDFs before any new engine work.
- Microsoft DSC audit is planned as a later phase (Phase 4, audit-only) after
  recovered code is detangled and stabilized; the checklist is a separate Phase 4b.
- Claude adversarial-review pass on 2026-06-08 added phase gates, the `_recovery/`
  tree and schemas, branch/PII/large-binary/offline/no-install Locked Rules, the
  Write Authority Matrix, the REPORT lifecycle, the Step Advancement Protocol, a
  Glossary, and a structured State Ledger; and re-sequenced the next task to
  Phase 0 governance.
