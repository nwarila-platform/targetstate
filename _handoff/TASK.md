# TASK - Canonical Selection by Maturity (faithful; archive the non-chosen)
_Read `_handoff/PLAN.md` first - the RECOVERY FIDELITY Locked Rule (Section 4) and Sections 0.2, 2. Read `docs/design/execution-map.md` (the audit of what exists). This establishes the clean canonical function set from the faithful recovery._

## Context
The faithful recovery is merged (`recovered/06042026.ps1` = version A, `recovered/06042026_001.ps1` = version B; PR #11 / `b43115c`). The two files are two entangled development efforts of the same project. Owner decision: compare EVERY function against its equivalent, choose the MOST MATURE version as the "correct" canonical function, and ARCHIVE the non-chosen equivalent for later review (do not delete). The earlier `src/`/`tests/` were a REFACTORED rewrite the owner rejected and are removed this cycle (distinct from the faithful archive).

## Goal
Produce the clean canonical source set: one verbatim file per function (the most mature version), with the non-chosen alternates archived intact, and a documented selection rationale. Also commit the execution-map deliverable. FAITHFUL: this is selection + splitting + archiving only - NO refactoring, NO behavior changes, NO "fixing." Completion/cleanup of incomplete functions happens in later, owner-gated build steps.

## A0. Method (owner-decided)
- For each DISTINCT function (by name AND by role - e.g. the hive normalizers `Get-RegistryKeyHiveObj` (A) vs `Get-RegistryKeyHive` (B); the value-data coercers `Get-RegistryValueData` (A) vs `Get-TypedObject` (B); the array helpers `ConvertFrom-Array` (A) vs `Convert-ByteArrayToHexString`/`ArrayToString` (B); the dual-located `Start-ProviderSetup` and `Get-TargetResource`): identify the equivalent across A/B, COMPARE maturity, choose ONE as canonical, ARCHIVE the other(s).
- "Most mature" = most complete (fewest empty stubs / `# !TODO` / owner "needs a rework" notes), strongest validation + error handling, best fit to the unified-path design in `docs/design/execution-map.md`, and the version whose contract the realized entrypoint actually uses. Use the execution map's per-function findings + the reconciliation matrix (`_recovery/_inventory/reconciliation-matrix.tsv`) as inputs. Where the two versions are simply different (e.g. the hive-shape A-hashtable vs B-string seam), pick per the execution map's recommendation AND flag it as an owner-confirmable seam - do NOT merge halves of two versions into one Frankenstein function.
- Single-source functions (only one version exists) are canonical as-is.
- Pick ONE WHOLE version per function. NEVER splice two versions together.

## A. Adversarial Review Gate
Archive the current `_handoff/REPORT.md` to the TOP of `_handoff/REPORT-ARCHIVE.md`
(`## Archived <UTC date> - Canonical selection`, append-only), then write a new `REPORT.md`
beginning with a verdict that: restates the goal; confirms branch
`recovery/canonical-selection` (not `main`); confirms VERBATIM (the canonical + archive
files are exact extractions, unchanged); lists each function and which version (A/B) you
will choose canonical with a one-line maturity reason.

## B. Expected Changes (branch `recovery/canonical-selection`)
- `recovered/canonical/<FunctionName>.ps1` - one file per canonical function, containing the
  EXACT verbatim text of the chosen version extracted from its recovered file (byte-for-byte;
  do not alter a single character). Include any function-leading comment the owner wrote.
- `recovered/archive/<FunctionName>.from-A.ps1` and/or `.from-B.ps1` - the non-chosen
  alternate version(s), also verbatim, preserved for later review.
- `docs/design/canonical-selection.md` - the comparison ledger: a table/section per function
  with (versions present A/B, maturity assessment of each, CHOICE, rationale, archived path,
  and any interface seam to confirm with the owner). Cite line ranges.
- Commit `docs/design/execution-map.md` (already in the working tree; the Phase-audit
  deliverable) and the existing `recovered/*.provenance.md`.
- REMOVE the refactored rewrite: `git rm -r src tests` (these are the rejected non-faithful
  versions; the faithful `recovered/` tree is now the source of truth). Also remove
  `docs/recovery/GAPS.md` only if it is superseded by the execution map - otherwise leave it.

## C. Guardrails
- VERBATIM. The `recovered/canonical/` and `recovered/archive/` files are exact copies of the
  function text from the two recovered files. Do NOT refactor, glyph-fix, complete stubs,
  rename, or change anything. (Cleanup/completion is a later owner-gated step.)
- Pick ONE whole version per function; never splice. The non-chosen version is archived intact.
- The maturity choice is a documented RECOMMENDATION the owner will review; make it clearly,
  cite evidence, and flag genuine seams (e.g. hive shape) for owner confirmation rather than
  silently deciding architecture.
- Sensitive-content scan (PLAN 1.9) over all newly committed files before committing; on any
  hit, do NOT commit, mark NEEDS-OWNER.
- Both PDFs stay byte-identical; `_recovery/` stays ignored; offline; no installs.
- Branch `recovery/canonical-selection`, never `main`; preserve signing; stage explicit paths.
  Do NOT edit `PLAN.md`/`TASK.md`/`CLAUDE-RESTART-PROMPT.md` content, but commit them as-is.

## D. Verification (run each; paste output verbatim into REPORT.md)
- Coverage: every function named in `docs/design/execution-map.md` §1 (plus A's `Get-TargetResource`
  and A's `Start-ProviderSetup` noted in §6) has a `recovered/canonical/<Fn>.ps1`; every
  dual-located/equivalent function has its alternate under `recovered/archive/`.
- FIDELITY: pick 2 canonical files and show they are byte-identical extracts of the matching
  line range in `recovered/06042026.ps1`/`06042026_001.ps1` (e.g. via a diff of the extracted
  range). No character changed.
- `src/` and `tests/` are removed: `git ls-files src/ tests/` returns nothing.
- `docs/design/execution-map.md` and `docs/design/canonical-selection.md` are tracked.
- Sensitive-content scan clean; both PDF SHA-256 unchanged; `git check-ignore -v recovered/canonical recovered/archive` resolve as tracked (not ignored).
- `git branch --show-current` (not `main`); `git log --show-signature -1` good.

## E. Definition of Done (ALL hold; else REPORT `Canonical selection status: BLOCKED | NEEDS-OWNER`)
- A canonical, verbatim file exists for every function; every non-chosen equivalent is archived
  verbatim; nothing was spliced or altered.
- `docs/design/canonical-selection.md` documents each choice + rationale + any owner-confirmable
  seam; `docs/design/execution-map.md` is committed.
- The refactored `src/`/`tests/` are removed.
- Sensitive-content scan clean; PDFs untouched.
- `REPORT.md` has the verdict, the per-function selection table, the Section D output, and a
  final line `Canonical selection status: COMPLETE | BLOCKED | NEEDS-OWNER`.

## F. End State (how this cycle hands back)
- Commit on `recovery/canonical-selection` with a signed message (e.g.
  `recover: canonical function selection by maturity + archive alternates + execution map`).
  Never commit to `main`; never bypass signing.
- Push the branch and open a PR to `main` titled `Canonical selection + execution map`; in the
  PR body paste the per-function selection table so the owner can confirm each maturity choice.
- Finish `REPORT.md` per Section E, then STOP. Do NOT merge - the owner reviews the canonical
  choices and admin-merges. The dedicated Test/Set unification-design step and the per-function
  build come after.
