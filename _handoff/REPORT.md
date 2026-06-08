Phase/Task status: COMPLETE

## Adversarial review verdict

Goal: execute Phase 5 on branch `recovery/phase-5-contract-adrs` by drafting four coherent TargetState contract ADR proposals:
`docs/adr/0003-resource-contract.md`, `docs/adr/0004-declaration-document-format.md`,
`docs/adr/0005-evidence-reporting-model.md`, and `docs/adr/0006-mutation-shouldprocess-safety.md`.
The ADRs remain `Status: Draft`, cite committed Phase 4/4b evidence, and prepare the Registry proof without implementing source, tests, module manifests, or `.mof` artifacts.

Branch check: PROCEED on `recovery/phase-5-contract-adrs`, not `main`.

Input check: PROCEED. The required committed inputs are present:

```text
docs/dsc-audit/CHECKLIST.md: True
docs/dsc-audit/BACKLOG.md: True
docs/dsc-audit/AUDIT.md: True
src/: True
docs/recovery/GAPS.md: True
```

DRAFT-ONLY check: PROCEED. All four new ADRs are proposals with `Status: Draft`; nothing is accepted or locked. Each ADR decision traces to at least one BACKLOG item and at least one AUDIT surface. No source/tests/module/`.mof` files were created.

Adversarial challenge: the plan was directionally sound, but the risk was over-specifying an engine before owner approval. The ADRs contain proposed directions and keep consequential forks in `Open questions for owner` instead of treating the contract as accepted.

Chosen output location: `docs/adr/0003-resource-contract.md`, `docs/adr/0004-declaration-document-format.md`, `docs/adr/0005-evidence-reporting-model.md`, `docs/adr/0006-mutation-shouldprocess-safety.md`, `_handoff/REPORT.md`, and `_handoff/REPORT-ARCHIVE.md`.

## What changed

- Archived the prior Phase 4b report to the top of `_handoff/REPORT-ARCHIVE.md` under `## Archived 2026-06-08 - Phase 5`.
- Added `docs/adr/0003-resource-contract.md`: proposes the TargetState resource contract around resource identity, metadata, Get/Test/Set operations, direct dispatch, `Ensure`, typed properties, evidence-friendly returns, recovered helper fit, fresh missing-helper design boundaries, and the DSC compatibility boundary.
- Added `docs/adr/0004-declaration-document-format.md`: proposes YAML as the first TargetState declaration format, explicitly excludes DSC `Configuration`/`Node` blocks and generated MOF, and includes a small Draft illustrative Registry declaration.
- Added `docs/adr/0005-evidence-reporting-model.md`: proposes structured operation evidence for Get/Test/Plan/Apply with per-resource status, differences, observed state, mutation flags, messages, and errors, without an LCM or pull reporting store.
- Added `docs/adr/0006-mutation-shouldprocess-safety.md`: proposes strict read-only vs apply separation, owner-gated mutation, PS 5.1 `ShouldProcess` semantics, and a required Registry test-isolation strategy before side-effecting tests.

## What was intentionally not changed

- No ADR was marked `Accepted`.
- No source, tests, module manifest, or `.mof` files were created or modified.
- No PDFs, `_recovery/` content, live registry state, or live Windows system state were touched.
- No `PLAN.md`, `TASK.md`, or `CLAUDE-RESTART-PROMPT.md` content was edited by Codex; the pre-existing Claude/owner handoff edits were preserved for durability.
- No new network research was performed; the committed audit/backlog/checklist/gaps/source artifacts were the design evidence.

## Verification output

ADR existence:

```text
True
True
True
True
```

Every ADR is Draft:

```text
NO OUTPUT from: Get-ChildItem docs\adr\*.md | Where-Object { (Get-Content $_ -Raw) -notmatch "(?m)^Status:\s*Draft\s*$" } | ForEach-Object { Write-Error "ADR not Draft: $($_.Name)" }
```

Traceability:

```text
PASS 0003-resource-contract.md
PASS 0004-declaration-document-format.md
PASS 0005-evidence-reporting-model.md
PASS 0006-mutation-shouldprocess-safety.md
```

Required sections and dates:

```text
PASS docs\adr\0003-resource-contract.md
PASS docs\adr\0004-declaration-document-format.md
PASS docs\adr\0005-evidence-reporting-model.md
PASS docs\adr\0006-mutation-shouldprocess-safety.md
```

No source/module/.mof created:

```text
NO OUTPUT from: Get-ChildItem -Recurse -Include *.psm1,*.psd1,*.mof -Path . -ErrorAction SilentlyContinue
```

No new `.ps1` under `src/`:

```text
NO OUTPUT from: git status --short src
```

Branch:

```text
recovery/phase-5-contract-adrs
```

Diff whitespace hygiene:

```text
warning: in the working copy of '_handoff/REPORT.md', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of '_handoff/TASK.md', LF will be replaced by CRLF the next time Git touches it
```

Git status before final staging:

```text
## recovery/phase-5-contract-adrs
 M _handoff/CLAUDE-RESTART-PROMPT.md
 M _handoff/PLAN.md
 M _handoff/REPORT-ARCHIVE.md
 M _handoff/REPORT.md
 M _handoff/TASK.md
?? docs/adr/0003-resource-contract.md
?? docs/adr/0004-declaration-document-format.md
?? docs/adr/0005-evidence-reporting-model.md
?? docs/adr/0006-mutation-shouldprocess-safety.md
```

Commit signing verification is run after the commit exists; the post-commit output is included in the PR/final execution note.

## Deviations from `TASK.md` and why

- `REPORT.md` cannot embed the final commit's `git log --show-signature -1` output without changing the commit being verified. I will run the post-commit signature check and include the output in the PR/final execution note.
- `git diff --check` emitted Git line-ending normalization warnings for handoff text files. It exited successfully and did not report whitespace errors.

## Open objections that must be resolved before advancing

- Claude should audit whether the ADRs remain proposal-shaped and internally consistent before the owner accepts the contract direction for Phase 6.

## Owner decisions needed

- Owner review of the four Draft ADR proposals and their open questions.
- Owner approval of the Phase 5 -> Phase 6 contract direction before implementation.
- Owner merge to `main` after Claude audit.

Phase 5 status: COMPLETE
