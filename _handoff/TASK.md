# TASK - Phase 4b: Port/Adapt/Skip Checklist + Implementation Backlog (synthesis)
_Read `_handoff/PLAN.md` first - especially Section 6 "Phase 4b" and "Phase 4" (the audit you are synthesizing), plus Sections 0.2, 2, 4. This is a synthesis cycle: it turns committed evidence into a plan. It writes NO source, NO ADR, and makes NO design decisions._

## Gate status
Phase 4 (DSC audit) is owner-accepted and merged (PR #7 / `bafe8c2`). Its evidence is
on `main`: `docs/dsc-audit/AUDIT.md` (24 surface records + verdicts),
`docs/dsc-audit/SOURCES.md`, `docs/dsc-audit/REGISTRY-CROSSREF.md` (32 GAPS items). The
10 stabilized functions are in `src/`; the gaps are in `docs/recovery/GAPS.md`. Work on
a NEW branch `recovery/phase-4b-checklist`.

## Goal
Synthesize the committed audit + recovered code + GAPS into two artifacts:
1. `docs/dsc-audit/CHECKLIST.md` - the port/adapt/replace/skip/defer checklist: one row
   per audited surface with the CONCRETE next action for TargetState.
2. `docs/dsc-audit/BACKLOG.md` - the implementation backlog, split into reviewable steps
   mapped to the upcoming phases (Phase 5 contract ADRs, Phase 6 Registry build).
This phase DESIGNS NOTHING and writes no ADR content, no source, no `.mof`. It only
organizes what the audit and recovery already established into an actionable plan.

## A0. Owner Decisions
- None new. This cycle consumes already-merged, already-accepted evidence. Do not
  introduce new DSC research (the audit is the source of DSC facts) and do not lock any
  design decision (those are Phase 5 Draft ADRs, owner-gated).

## A. Adversarial Review Gate
Archive the current Phase 4 `_handoff/REPORT.md` to the TOP of
`_handoff/REPORT-ARCHIVE.md` (`## Archived <UTC date> - Phase 4b`, append-only), then
write a new `REPORT.md` beginning with a verdict that:
1. Restates the goal; confirms branch is `recovery/phase-4b-checklist` (not `main`).
2. Confirms the inputs exist on `main`: `docs/dsc-audit/AUDIT.md`,
   `docs/dsc-audit/REGISTRY-CROSSREF.md`, `docs/recovery/GAPS.md`, and `src/`.
3. Confirms SYNTHESIS-ONLY: no design decisions, no ADR, no source, no `.mof`, no new
   DSC research. Every checklist action is traceable to an AUDIT.md verdict or a GAP.

## B. Expected Changes (branch `recovery/phase-4b-checklist`)
- `docs/dsc-audit/CHECKLIST.md`: one row per surface in `AUDIT.md` (all 24), columns:
  `surface | verdict | concrete-next-action | target-phase`. The action must be specific
  and derived from the audit verdict:
  - `adapt conceptually` / `replace with TargetState-native` -> name exactly what
    TargetState must DESIGN (e.g. "design the Get/Test/Set resource contract", "design
    the YAML declaration-document format") and the phase that owns it (usually Phase 5).
  - `port directly` -> name what is reused as-is.
  - `explicitly skip` -> action = "no action (out of scope)".
  - `defer until after Registry proof` -> name the condition that unblocks it.
- `docs/dsc-audit/BACKLOG.md`: the implementation backlog as a numbered list of
  reviewable steps. Each item: `id | description | depends-on | target-phase | source`
  (source = the AUDIT.md surface(s) and/or GAP id(s) it derives from). The backlog MUST:
  - include the four Phase 5 contract ADRs implied by the `adapt`/`replace` verdicts
    (resource contract, declaration-document format, evidence/reporting model, mutation/
    ShouldProcess safety);
  - include the missing helpers from GAPS as DESIGN items (`Get-NormalizedRegistryKeyString`,
    `ArrayToString`, `Get-RegistryKeyType`) - flagged "design fresh; original absent";
  - include the 6 deferred registry/orchestration functions as Phase 6 items gated on the
    registry test-isolation strategy;
  - note the 10 already-stabilized functions as reusable inputs.

## C. Guardrails
- SYNTHESIS ONLY. Do NOT design the contract, write ADR content, change any ADR status,
  write source/tests, or write `.mof`. Do NOT perform new DSC research - cite the audit
  rows, not the web. (If you find an audit gap, note it in REPORT for Claude; do not fix
  it by re-auditing.)
- Every checklist action and backlog item must trace to a committed `AUDIT.md` verdict
  and/or a `GAPS.md`/`REGISTRY-CROSSREF.md` id. Do not invent new surfaces or scope.
- Branch `recovery/phase-4b-checklist`, never `main`; preserve signing; stage explicit
  paths only (`docs/dsc-audit/CHECKLIST.md`, `docs/dsc-audit/BACKLOG.md`, `_handoff/*.md`).
  PDFs + `_recovery/` stay ignored/untouched. Do NOT edit `PLAN.md`/`TASK.md`/
  `CLAUDE-RESTART-PROMPT.md` content, but commit them as-is for durability. ASCII; offline is fine.

## D. Verification (run each; paste output verbatim into REPORT.md)
- Coverage: every surface in `AUDIT.md` has exactly one `CHECKLIST.md` row (count match);
  every `adapt`/`replace`/`port`/`defer` row has a non-empty concrete action.
- Traceability: every `BACKLOG.md` item's `source` names a real AUDIT surface or GAP id.
- The four Phase 5 contract ADRs and the three missing-helper design items are present in
  the backlog.
- Hygiene: `git ls-files docs/dsc-audit/` shows CHECKLIST.md + BACKLOG.md; no `.mof`, no
  source/ADR changes; `git branch --show-current` (not `main`); `git log --show-signature -1` good.

## E. Definition of Done (ALL hold; else REPORT `Phase 4b status: BLOCKED | NEEDS-OWNER`)
- `CHECKLIST.md` covers all 24 surfaces with a concrete action + target phase each.
- `BACKLOG.md` lists the work as reviewable steps mapped to Phase 5/6, including the four
  contract ADRs, the three missing-helper design items, the 6 deferred functions (gated
  on test-isolation), and the 10 reusable stabilized functions; every item is traceable.
- No design decision locked, no ADR/source/.mof written.
- `REPORT.md` has the verdict, the coverage/traceability output, and a final line
  `Phase 4b status: COMPLETE | BLOCKED | NEEDS-OWNER`.

## F. End State (how this cycle hands back)
- Commit on `recovery/phase-4b-checklist` with a signed message (e.g.
  `docs(dsc-audit): port/adapt/skip checklist + implementation backlog`). Commit
  `docs/dsc-audit/CHECKLIST.md`, `docs/dsc-audit/BACKLOG.md`, `_handoff/REPORT*.md`, and
  the Claude-updated planner docs. Never commit to `main`; never bypass signing.
- Push the branch and open a PR to `main` titled `Phase 4b: DSC port/adapt/skip checklist
  + backlog`; paste the Section D coverage output in the PR body.
- Finish `REPORT.md` per Section E, then STOP. Do NOT merge - the owner admin-merges after
  Claude's audit.
