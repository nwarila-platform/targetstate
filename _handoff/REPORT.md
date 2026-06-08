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
