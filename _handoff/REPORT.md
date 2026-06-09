Test/Set design status: COMPLETE

## Adversarial review verdict

Goal: execute the Test/Set execution-dispatch design task on branch
`recovery/test-set-design`: produce an objective options analysis for unifying
Get/Test/Set into the owner's single execution path, draft ADR 0007 as
`Status: Draft`, commit the analysis/ADR/handoff updates, push the branch, open
a PR to `main`, and stop for owner review.

Decision: PROCEED. This is a design-analysis task only. It does not require
opening, parsing, OCR'ing, or modifying the PDFs; it does not require live
registry/system access; and it does not authorize source, tests, module
manifest, or `.mof` creation. The ADR remains Draft until the owner approves the
route.

Branch check: PROCEED on `recovery/test-set-design`, not `main`.

Candidate routes evaluated:
- R1: one mode-driven body with a single operation/dispatch path.
- R2: shared setup plus thin `Get-/Test-/Set-TargetResource` method shims.
- R3: internal dispatcher plus thin compatibility shims.

Scoring dimensions used:
- Fit to the owner's single-path and run-only-necessary-steps constraint.
- Reuse of `Start-ProviderSetup`, mount-once behavior, and canonical
  `Get-TargetResource`.
- Composition of Test compare behavior and Set/Apply mutation under
  `ShouldProcess`.
- DSC-name compatibility.
- Pester-mock testability.
- Evidence/result shape alignment with ADR 0005.
- Fit to the owner's recovered coding style.
- Pros, cons, and risks.

Chosen output locations: `docs/design/test-set-unification.md`,
`docs/adr/0007-test-set-execution-dispatch.md`, `_handoff/REPORT.md`, and
`_handoff/REPORT-ARCHIVE.md`. Existing planner files are preserved as-is for
durability; Codex did not edit `PLAN.md`, `TASK.md`, or
`CLAUDE-RESTART-PROMPT.md` content.

Recommendation summary:
- R1 is viable but not best. It best satisfies a literal one-body reading, but
  weakens DSC-name compatibility and risks a public mega-function.
- R2 is safe and familiar. It preserves DSC names, but it weakens the single
  execution path and can repeat setup/read work.
- R3 is recommended. It keeps one internal Registry operation path while
  preserving thin public `Get-TargetResource`, `Test-TargetResource`, and
  `Set-TargetResource` wrappers for compatibility and reviewability.

## What changed

- Archived the prior `REPORT.md` to the top of `_handoff/REPORT-ARCHIVE.md` under
  `## Archived 2026-06-09T...Z - Test/Set design`.
- Added `docs/design/test-set-unification.md` with R1/R2/R3 evaluation against
  all required dimensions and an R3 recommendation.
- Added `docs/adr/0007-test-set-execution-dispatch.md` with `Status: Draft`,
  the recommended dispatcher-plus-shims design, consequences, owner questions,
  and owner gate.
- Preserved pre-existing Claude/planner handoff edits as-is.

## What was intentionally not changed

- No source, tests, module manifest, `.mof`, PDF, or `_recovery/` content was
  created or modified.
- No live Windows registry or system state was touched.
- No ADR was marked Accepted.
- `PLAN.md`, `TASK.md`, and `CLAUDE-RESTART-PROMPT.md` content was not edited by
  Codex.
- Phase 6 implementation was not started.

## Verification output

Analysis coverage:

```text
R1=True
R2=True
R3=True
dimension_a=True
dimension_b=True
dimension_c=True
dimension_d=True
dimension_e=True
dimension_f=True
dimension_g=True
dimension_h=True
recommendation=True
```

ADR 0007 exists:

```text
0007-test-set-execution-dispatch.md
```

ADR 0007 status:

```text
docs\adr\0007-test-set-execution-dispatch.md:3:Status: Draft
```

ADR 0007 citations requested by TASK.md:

```text
docs\adr\0007-test-set-execution-dispatch.md:3:Status: Draft
docs\adr\0007-test-set-execution-dispatch.md:17:mechanics. ADR 0003 proposes TargetState `Get`, `Test`, and `Set` operations
docs\adr\0007-test-set-execution-dispatch.md:18:with direct dispatch. ADR 0005 proposes structured operation evidence for
docs\adr\0007-test-set-execution-dispatch.md:19:Get/Test/Plan/Apply. ADR 0006 requires a hard boundary between read-only
docs\adr\0007-test-set-execution-dispatch.md:23:`docs/design/execution-map.md` records the recovered unified-path intent, the
docs\adr\0007-test-set-execution-dispatch.md:25:complete JSON-driven path. `docs/design/test-set-unification.md` compares three
docs\adr\0007-test-set-execution-dispatch.md:32:This ADR cites ADR 0003 for the resource contract, ADR 0004 for the no-MOF
docs\adr\0007-test-set-execution-dispatch.md:33:declaration-document boundary, ADR 0005 for evidence shape, and ADR 0006 for
docs\adr\0007-test-set-execution-dispatch.md:65:   `InDesiredState` boolean plus ADR 0005 evidence.
docs\adr\0007-test-set-execution-dispatch.md:79:ADR 0005 evidence envelope and ADR 0006 read-only/apply split.
docs\adr\0007-test-set-execution-dispatch.md:92:- `Start-ProviderSetup` currently calls `Mount-RegistryHive`, and ADR 0006 says
docs\adr\0007-test-set-execution-dispatch.md:97:  or wraps either inside the ADR 0005 envelope.
docs\adr\0007-test-set-execution-dispatch.md:106:  archived B `Ensure`/`Key` payload, or an ADR 0005 wrapper containing one of
```

All ADRs still Draft:

```text
```

No source/module/.mof inventory under `src,recovered/canonical` using relative
paths. The command listed only pre-existing canonical recovered source; no new
source appeared:

```text
.\recovered\canonical\Convert-ByteArrayToHexString.ps1
.\recovered\canonical\ConvertFrom-Array.ps1
.\recovered\canonical\Get-NormalizedRegistryKey.ps1
.\recovered\canonical\Get-RegistryKeyHiveObj.ps1
.\recovered\canonical\Get-RegistryKeyNameStr.ps1
.\recovered\canonical\Get-RegistryKeyPathStr.ps1
.\recovered\canonical\Get-RegistryResourceObject.ps1
.\recovered\canonical\Get-RegistryValueKindStr.ps1
.\recovered\canonical\Get-RegistryValueNameStr.ps1
.\recovered\canonical\Get-TargetResource.ps1
.\recovered\canonical\Get-TypedObject.ps1
.\recovered\canonical\Mount-RegistryHive.ps1
.\recovered\canonical\Start-ProviderSetup.ps1
.\recovered\canonical\ThrowError.ps1
```

`git status --short src recovered\canonical`:

```text
```

Branch:

```text
recovery/test-set-design
```

Trackable new artifacts:

```text
docs/adr/0007-test-set-execution-dispatch.md
docs/design/test-set-unification.md
```

Sensitive-content scan over the new public design/ADR files and this report:

```text
```

`git diff --check`:

```text
warning: in the working copy of '_handoff/REPORT.md', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of '_handoff/TASK.md', LF will be replaced by CRLF the next time Git touches it
```

Commit-signing preflight:

```text
commit.gpgsign=true
gpg.format=ssh
```

Final `git log --show-signature -1` output is intentionally not embedded here:
the final signed commit necessarily includes this report, so recording the final
commit's own signature inside the same committed report is self-referential. It
will be run immediately after commit and included in the PR body and handback.

## Deviations from `TASK.md` and why

- I did not embed the final post-commit signature output in this committed
  report because doing so would require an endless amend/re-sign cycle. I will
  run `git log --show-signature -1` after the final commit and report it in the
  PR body and final response.
- The no-source inventory command lists existing files under `recovered/canonical`
  because that directory is the committed source-of-truth input. The paired
  `git status --short src recovered\canonical` check is empty, proving this task
  created no new source and left `recovered/canonical` unchanged.
- ADR 0004 currently still says YAML, while the later owner decision in
  `PLAN.md` says JSON for the first proof. This task stayed format-neutral and
  cited ADR 0004 only for the no-MOF declaration boundary; the JSON update is
  already deferred in the plan to the Phase 6 resume.

## Open objections that must be resolved before advancing

- Owner should approve, reject, or revise the R3 recommendation.
- Owner should choose the internal dispatcher name:
  `Invoke-RegistryResourceOperation`, `Get-TargetResourceInternal`, or another
  name.
- Owner should decide whether `Get-TargetResource` output keeps A's
  `KeyExists`/`ValueExists` payload, adopts B's archived `Ensure`/`Key` payload,
  or wraps either shape inside the ADR 0005 evidence envelope.
- Owner should decide whether read-only Get/Test/Plan may perform the
  session-local PSDrive setup in `Mount-RegistryHive`, or whether provider
  mounting must be mocked/split until registry isolation is approved.
- Owner should decide whether `Set-TargetResource` is directly callable by
  advanced users or only through TargetState Apply mode.
- Owner should decide whether typed desired-value comparison completes
  `Get-TypedObject` or uses a fresh conversion helper.

## Owner decisions needed

- Review PR and decide the dispatch route.
- Keep ADR 0007 Draft unless the owner explicitly approves an Accepted status
  transition.
- Do not merge until owner review is complete; Codex must not merge.
- After owner approval, Claude/owner can advance to the per-function build /
  Phase 6 resume task.

Test/Set design status: COMPLETE
