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
