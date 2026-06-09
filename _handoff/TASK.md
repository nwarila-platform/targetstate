# TASK - CORRECTIVE: Faithful Source Reconstruction (verbatim; owner's style preserved)
_Read `_handoff/PLAN.md` first - especially the RECOVERY FIDELITY Locked Rule (Section 4) and Sections 0.2, 2. This corrects a process error: the Phase 3 "stabilization" REFACTORED the owner's code instead of recovering it faithfully._

## Why this task
The owner reviewed the committed `src/` functions and found they are a REFACTORED rewrite,
not their actual code. Example (`Get-RegistryValueKindStr`): the owner's source uses
`Begin`/`Process`/`End` blocks, `New-Variable -Force -Option:'Private'` declarations,
colon-parameter syntax (`-Name:`/`-Value:`/`-Message:`), detailed comments, and a
soft-return pattern - ALL of which the committed version deleted, plus it swapped the
owner's enum handling for `[Enum]::Parse`. The owner has a very specific coding style and
does NOT want it changed. This task rebuilds their real source faithfully from the PDFs.

## Gate / inputs
Work on a NEW branch `recovery/faithful-source-rebuild` (off `main`). PRIMARY WORKING
SOURCE = the per-page OCR text in local `_recovery/06042026/corrected/` (17 pages) and
`_recovery/06042026_001/corrected/` (16 pages), cross-checked against the `.../raw/` OCR.
IMPORTANT: that OCR already preserves the owner's structure (`Begin`/`Process`/`End`,
`New-Variable -Private`, colon-syntax, comments) - the refactoring damage is NOT in the OCR,
it was introduced later in `src/`. So your job is to STITCH the corrected pages per PDF in
order and clean up remaining OCR glyph errors WITHOUT refactoring. Use the rendered page
images (`_recovery/.../images/*.png`) as the TIE-BREAKER for ambiguous glyphs where you can
read them; otherwise resolve by context and FLAG anything uncertain.

## Goal
Best-effort FAITHFUL reconstruction of ALL recoverable source from BOTH PDFs - every
function, plus any module-level code, `$LocalizedData`/string tables, and comments - exactly
as printed, preserving the owner's style VERBATIM. Correct ONLY literal OCR glyph errors,
verified against the page images. FIDELITY OVER FUNCTIONALITY: do NOT make it parse or run.

## A0. The fidelity contract (read twice)
- PRESERVE EXACTLY, never change: `Begin`/`Process`/`End` blocks; `New-Variable -Force
  -Option:'Private'` declarations and `[Type]::Empty` inits; colon-parameter syntax
  (`-Name:`, `-Value:`, `-Message:`); ALL comments verbatim (including typos like
  "Initalize"); soft-return patterns (`Set-Variable` + pipe output); variable names;
  the owner's casing even if "wrong" (if the image shows `IsNullOrwhiteSpace`, keep it);
  ordering; indentation/spacing/brace style; `$True`/`$False` capitalization; everything.
- CORRECT ONLY where OCR misread the IMAGE: `Q`/`O` -> `0` where the image shows a zero,
  smart quotes -> straight where the image shows straight, `(a(` -> `@(`, `[Microsoft .Win32]`
  -> `[Microsoft.Win32]` spacing, `l`/`1`/`I` confusions, lost/!spurious backticks, stray
  spaces in `::`/member access - each verified against the image.
- Do NOT: refactor, restructure, rename, reorder, "modernize", idiomize, adapt for PS 5.1,
  swap APIs (if the owner wrote `[Enum]::TryParse`, it STAYS `TryParse`), fix the owner's
  bugs, remove "redundant"/"dead" code, add code, add tests, or insert your own comments.
- If a glyph/line is genuinely illegible in the image, transcribe your best read and mark it
  inline `<#OCR-UNREADABLE: <what-you-see> #>` AND list it in the provenance sidecar. NEVER
  invent or guess logic to fill a gap.
- Authority order for resolving a character: (1) the page image if readable, (2) the
  corrected/raw OCR text, (3) flag as uncertain. NEVER "what PowerShell expects" and NEVER
  your judgment of better code. You are transcribing, not authoring.

## A. Adversarial Review Gate
Archive the current `_handoff/REPORT.md` to the TOP of `_handoff/REPORT-ARCHIVE.md`
(`## Archived <UTC date> - Faithful reconstruction`, append-only), then write a new
`REPORT.md` beginning with a verdict that:
1. Restates the goal; confirms branch `recovery/faithful-source-rebuild` (not `main`).
2. Confirms the page images exist (counts) and that you will transcribe from the IMAGES.
3. Restates the fidelity contract IN YOUR OWN WORDS and lists what you will NOT change, so
   it is clear you understand this is verbatim transcription, not stabilization.

## B. Expected Changes (branch `recovery/faithful-source-rebuild`)
- `recovered/06042026.ps1` and `recovered/06042026_001.ps1`: the COMPLETE verbatim
  reconstruction of each PDF's code, page by page IN ORDER - every function, module-level
  code, `$LocalizedData`, and comments - transcribed from the page images, OCR-glyph fixes
  ONLY. These files contain ONLY the owner's code: NO provenance headers, NO your-comments,
  nothing of ours.
- `recovered/06042026.provenance.md` and `recovered/06042026_001.provenance.md`: per-page
  logs of (a) every OCR glyph correction you made (`raw -> fixed`, with a one-line image
  justification) and (b) every `<#OCR-UNREADABLE#>` token. This sidecar is where ALL of our
  notes live, keeping the `.ps1` pure.
- Allowlist `!/recovered/` in `.gitignore` (per ADR 0002) so the directory is tracked.
- Do NOT modify `src/` or `tests/` this cycle - the refactored versions stay for the owner to
  diff against; they are removed in a follow-up once the owner confirms fidelity.

## C. Guardrails
- FIDELITY ONLY (the A0 contract). No refactor/adapt/run-fixing. The image is the authority.
- Do NOT require or attempt to make the output parse or run. A faithful `.ps1` that does not
  parse is the CORRECT outcome here; do not "fix" it.
- `.ps1` files are PURE owner code; all our notes go in the `*.provenance.md` sidecars.
- Sensitive-content scan (PLAN 1.9: hostnames, `C:\Users\<name>`, UNC, SIDs, keys, emails)
  over `recovered/` BEFORE committing - scanned printouts can carry host/PII in margins;
  on any hit, do NOT commit, list it, mark NEEDS-OWNER.
- Both PDFs stay byte-identical (integrity check). Offline; no installs.
- Branch `recovery/faithful-source-rebuild`, never `main`; preserve signing; stage explicit
  paths (`recovered/`, `.gitignore`, `_handoff/*.md`). PDFs + `_recovery/` stay ignored.
  Do NOT edit `PLAN.md`/`TASK.md`/`CLAUDE-RESTART-PROMPT.md` content, but commit them as-is
  for durability. Files are the owner's encoding; keep their exact bytes (do not ASCII-fold
  characters that are genuinely in their source).

## D. Verification (run each; paste output verbatim into REPORT.md)
- Coverage: list every function name present in each `recovered/*.ps1` and confirm all 18
  inventoried functions are accounted for (note any additional module-level code found).
- FIDELITY SPOT-CHECK: pick `Get-RegistryValueKindStr` (and one more function), and in the
  REPORT paste its reconstructed text next to the corresponding `_recovery/.../corrected/`
  OCR page(s), showing the `Begin`/`Process`/`End` blocks, `New-Variable -Private`
  declarations, colon syntax, and comments are ALL present (i.e. NOT refactored, unlike the
  committed `src/` version).
- A short statement confirming: no block collapsed, no declaration removed, no comment
  stripped, no API swapped, no logic changed; only listed OCR glyph fixes were applied.
- Unreadable tokens are flagged inline + listed in the provenance sidecar.
- Sensitive-content scan output (clean). Both PDF SHA-256 unchanged. `git check-ignore -v
  recovered/` resolves (allowlisted); PDFs + `_recovery/` still ignored.
- `git branch --show-current` (not `main`); `git log --show-signature -1` good.
- (There is intentionally NO parse/Pester requirement this cycle.)

## E. Definition of Done (ALL hold; else REPORT `Faithful recovery status: BLOCKED | NEEDS-OWNER`)
- Both PDFs faithfully reconstructed into `recovered/*.ps1` - complete, in order, verbatim,
  OCR-glyph fixes only; all 18 functions + any module-level code present.
- The owner's style is preserved (Begin/Process/End, `New-Variable -Private`, colon syntax,
  comments, soft-returns) - demonstrated by the Section D spot-check.
- `.ps1` files are pure owner code; `*.provenance.md` sidecars hold all corrections +
  unreadable-token lists; nothing invented.
- `recovered/` allowlisted + committed; sensitive-content scan clean; `src/`/`tests/`
  untouched; PDFs byte-identical.
- `REPORT.md` has the verdict, the fidelity-contract restatement, the Section D output
  (incl. the spot-check), and a final line `Faithful recovery status: COMPLETE | BLOCKED | NEEDS-OWNER`.

## F. End State (how this cycle hands back)
- Commit on `recovery/faithful-source-rebuild` with a signed message (e.g.
  `recover: faithful verbatim reconstruction of owner source from PDFs`). Commit
  `recovered/**`, the `.gitignore` `!/recovered/` allowlist, `_handoff/REPORT*.md`, and the
  Claude-updated planner docs - ONLY if the PII scan is clean. Never commit to `main`; never
  bypass signing.
- Push the branch and open a PR to `main` titled `Faithful source reconstruction (verbatim)`;
  in the PR body paste the coverage list + the fidelity spot-check so the owner can confirm
  it matches their code.
- Finish `REPORT.md` per Section E, then STOP. Do NOT merge - the owner reviews fidelity and
  admin-merges. Only after the owner confirms the reconstruction is faithful do we remove the
  refactored `src/`/`tests/` and resume building.
