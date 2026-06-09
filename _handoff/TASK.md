# TASK - Phase 6 build (1): make-it-run CALIBRATION on Get-RegistryValueKindStr (+ idiom proposal)
_Read `_handoff/PLAN.md` first (Mission, Section 4 Locked Rules incl. RECOVERY FIDELITY, Sections 0.2, 2). This is the FIRST build step and a deliberate CALIBRATION: make ONE function run, and surface the systematic `[Type]::Empty` idiom decision for the owner - before touching any other function._

## Context
Owner decisions now locked: execution dispatch = R3 (internal dispatcher + thin Get/Test/Set
shims); observed-state shape = B's `{Ensure,Key,ValueName,ValueKind,ValueData}`; make-it-run =
Codex applies MINIMAL, style-preserving fixes that the owner reviews per change. The owner's
canonical code (`recovered/canonical/`) is faithful but does NOT parse (OCR artifacts + a
systematic `[Type]::Empty` initializer idiom + WIP stubs). The canonical tree is the immutable
FAITHFUL RECORD; the runnable module is built in `src/`. This step makes ONE pure function run
and proposes the idiom mapping; it does NOT scale to other functions yet.

## Goal
Stand up a minimal `src/` module entry and make `recovered/canonical/Get-RegistryValueKindStr.ps1`
PARSE + RUN on Windows PowerShell 5.1 in `src/Get-RegistryValueKindStr.ps1`, changing ONLY what is
required to run, with the owner's structure/logic/comments/style fully preserved. Document every
change. Surface the systematic `[Type]::Empty` idiom as a PROPOSED owner-decision mapping. Prove
it runs with Pester. recovered/canonical/ stays byte-unchanged.

## A0. Make-it-run rules (the contract for THIS and every later build step)
- PRESERVE EXACTLY, do not touch: Begin/Process/End blocks + their Write-Debug bookends;
  `New-Variable -Force -Option:'Private'` declarations; colon-parameter syntax (`-Name:`/`-Value:`/
  `-Message:`); every comment (including typos like "Initalize"); the soft-return; `$True`/`$False`;
  `Clear-Variable`/`Remove-Variable` hygiene; the owner's logic, ordering, naming, and spacing.
- Do NOT refactor, restructure, rename, collapse blocks, idiomize, modernize, swap APIs
  (keep `[Enum]::TryParse`), "fix" logic bugs, or change behavior. Make-it-run != improve.
- Classify EVERY change as exactly one of:
  (i) OCR-artifact correction - a token that is clearly an OCR misread of the owner's real code
      (e.g. `Position = Q` -> `0`; `-Name:(a(` -> `-Name:(@(`; doubled quotes `''X'` -> `'X'`;
      brace/bracket swaps `}]`->`)]`, `(Microsoft...]`->`[Microsoft...]`; stray leading commas in
      `[CmdletBinding(`/`[Parameter(` lists). Restore the owner's real token. Cite the page image
      `_recovery/06042026/images/` (or `_recovery/06042026_001/images/`) line where it confirms the
      intended glyph; if you cannot view the image, say so and rely on the OCR `corrected/` text +
      immediate context, and mark the evidence as text-only.
  (ii) idiom mapping - the systematic `[Type]::Empty` initializer (see A1).
  (iii) minimal parse fix - smallest possible change to parse, no image evidence, no logic change.
- If a parse blocker cannot be resolved without a LOGIC or STYLE decision, STOP and flag it for the
  owner in REPORT.md. NEVER guess at the owner's intent.

## A1. The `[Type]::Empty` idiom (the key calibration decision)
The owner initializes variables with `New-Variable ... -Value:([SomeType]::Empty)`. Only
`[System.String]::Empty` is a real .NET member; the others (`[System.Boolean]::Empty`,
`[Microsoft.Win32.RegistryValueKind]::Empty`, `[PSCustomObject]::Empty`, `[Hashtable]::Empty`,
`[System.Int32]::Empty`, etc.) are not and will not run. This is the owner's idiom, NOT a simple
OCR fix.
- Produce `docs/build/owner-idiom-decisions.md`: a PROPOSED mapping table from each `[Type]::Empty`
  to a running default that best preserves the evident intent (a placeholder default the code then
  overwrites). Propose, with rationale, e.g.: `[System.String]::Empty` -> keep (already valid);
  `[System.Boolean]::Empty` -> `$false`; `[Microsoft.Win32.RegistryValueKind]::Empty` -> a single
  chosen default (e.g. `[Microsoft.Win32.RegistryValueKind]::Unknown` or `0`/`None` - propose ONE
  and explain); `[Hashtable]::Empty` -> `@{}`; `[PSCustomObject]::Empty` -> `$null` or `[PSCustomObject]@{}`.
  Mark these PROPOSED - owner must approve before they are applied anywhere else.
- For THIS function only, APPLY your proposed mapping so it runs, and clearly list (in the make-it-run
  log) each applied `::Empty` substitution so the owner can confirm or correct it. Do NOT apply the
  mapping to any other canonical function this step.

## A. Adversarial Review Gate
Archive the current `_handoff/REPORT.md` to the TOP of `_handoff/REPORT-ARCHIVE.md`
(`## Archived <UTC date> - Phase 6 build 1`, append-only), then write a new `REPORT.md` whose
verdict: restates the goal; confirms branch `recovery/phase6-build-1` (not `main`); confirms ONLY
`Get-RegistryValueKindStr` is touched (no other canonical function altered); states that
recovered/canonical/ is unchanged; lists each change with its classification.

## B. Expected Changes (branch `recovery/phase6-build-1`)
- `src/Get-RegistryValueKindStr.ps1` - the canonical function, made to parse + run, minimal
  style-preserving changes only.
- `tests/Get-RegistryValueKindStr.Tests.ps1` - Pester 5.x tests. This function is a pure
  string->`[Microsoft.Win32.RegistryValueKind]` normalizer (NO registry access, so NO mocks needed):
  cover empty/whitespace -> the chosen None/default; a valid kind string -> parsed kind; an invalid
  kind and `Unknown` -> `ThrowError`. (ThrowError must be loadable for the throw cases - dot-source
  `recovered/canonical/ThrowError.ps1` or a minimal shim in the test; do NOT modify ThrowError this step.)
- `docs/build/make-it-run-log.md` - the per-change ledger for this function: canonical token ->
  running token, classification (i/ii/iii), and image/line evidence or "text-only".
- `docs/build/owner-idiom-decisions.md` - the proposed `[Type]::Empty` mapping table (A1) for owner approval.
- `.gitignore` - if `src/` and/or `tests/` are not already allow-listed, add `!/src/` and `!/tests/`
  (deny-by-default policy, ADR 0002). Verify with `git check-ignore`.
- Do NOT create the full module manifest yet (defer `.psd1`/`.psm1` until more functions land).

## C. Guardrails
- ONLY `Get-RegistryValueKindStr` is made-to-run this step. Do NOT touch any other canonical
  function, do NOT build dispatcher/Test/Set, do NOT apply the idiom mapping elsewhere.
- recovered/canonical/ and recovered/archive/ stay BYTE-UNCHANGED (faithful record).
- No live registry access anywhere (this function needs none); no live mutation; ADRs stay Draft.
- Sensitive-content scan (PLAN 1.9) over newly committed files before committing.
- Branch `recovery/phase6-build-1`, never `main`; preserve signing; stage explicit paths. PDFs +
  `_recovery/` stay ignored. Do NOT edit `PLAN.md`/`TASK.md`/`CLAUDE-RESTART-PROMPT.md` content; commit as-is.

## D. Verification (run each; paste output verbatim into REPORT.md)
- Parse: `[System.Management.Automation.Language.Parser]::ParseFile('src/Get-RegistryValueKindStr.ps1',[ref]$null,[ref]$errs)`
  reports 0 errors.
- Pester: the test file passes (all cases green) on PS 5.1 / Pester 5.x.
- Fidelity diff: `git diff --no-index recovered/canonical/Get-RegistryValueKindStr.ps1 src/Get-RegistryValueKindStr.ps1`
  pasted in full, so every change is visible and matches the classified log (nothing unexplained).
- recovered/canonical/ + recovered/archive/ unchanged: `git status` shows no modifications there.
- All ADRs still Draft; `git check-ignore -v src tests` resolves as tracked; sensitive scan clean.
- `git branch --show-current` (not `main`); `git log --show-signature -1` good.

## E. Definition of Done (ALL hold; else REPORT `Phase 6 build 1 status: BLOCKED | NEEDS-OWNER`)
- `src/Get-RegistryValueKindStr.ps1` parses (0 errors) and its Pester tests pass.
- Every change is minimal, style-preserving, and classified in `docs/build/make-it-run-log.md`;
  the full canonical->src diff is in REPORT.md with no unexplained change.
- `docs/build/owner-idiom-decisions.md` proposes the `[Type]::Empty` mapping for owner approval.
- recovered/canonical/ + archive/ byte-unchanged; ADRs Draft; sensitive scan clean.
- `REPORT.md` has the verdict, the classified change list, the Section D output, and a final line
  `Phase 6 build 1 status: COMPLETE | BLOCKED | NEEDS-OWNER`.

## F. End State (how this cycle hands back)
- Commit on `recovery/phase6-build-1` with a signed message (e.g.
  `feat(registry): make-it-run Get-RegistryValueKindStr (calibration) + [Type]::Empty idiom proposal`).
  Never commit to `main`; never bypass signing.
- Push and open a PR to `main` titled `Phase 6 build 1: make-it-run calibration (Get-RegistryValueKindStr)`;
  in the PR body paste the canonical->src diff + the proposed idiom mapping so the owner reviews both.
- Finish `REPORT.md` per Section E, then STOP. Do NOT merge - the owner reviews the make-it-run
  fidelity and APPROVES the idiom mapping before the build scales to the other functions.
