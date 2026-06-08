# TASK - Phase 5: TargetState Contract Design (Draft ADRs)
_Read `_handoff/PLAN.md` first - especially Section 1 (Mission), Section 5 (Draft Decisions / design drivers), Section 6 "Phase 5", the Locked Rules (Section 4), and Sections 0.2, 2. This is the first DESIGN phase: it writes Draft ADRs (proposals), not source._

## Gate status
Phase 4b is merged (PR #8 / `c0cb730`). The design inputs are on `main`:
`docs/dsc-audit/CHECKLIST.md` and `docs/dsc-audit/BACKLOG.md` (items P5-ADR-001..004,
P5-SCOPE-005, P5-DESIGN-006..008), `docs/dsc-audit/AUDIT.md` (verdicts), the 10 stabilized
functions in `src/`, and `docs/recovery/GAPS.md`. Work on a NEW branch
`recovery/phase-5-contract-adrs`.

## Goal
Draft the four TargetState contract ADRs as a coherent PROPOSAL set, all `Status: Draft`,
grounded in the DSC audit verdicts, the recovered functions, and the mission (a
GitOps-friendly DSC replacement driven by human-readable YAML-style declaration documents
instead of generated MOF). These ADRs PROPOSE the contract; they LOCK NOTHING until the
owner accepts them (Locked Rule). Write NO source, tests, module, or `.mof`.

## A0. Owner Decisions
- Every ADR is `Status: Draft`. Do NOT mark any ADR `Accepted` - the owner decides that.
- These ADRs are PROPOSALS for owner review. Where a genuine design choice exists, propose
  the option you judge best AND list the alternatives under an explicit "Open questions for
  owner" section in that ADR, rather than silently deciding.

## A. Adversarial Review Gate
Archive the current Phase 4b `_handoff/REPORT.md` to the TOP of
`_handoff/REPORT-ARCHIVE.md` (`## Archived <UTC date> - Phase 5`, append-only), then write
a new `REPORT.md` beginning with a verdict that:
1. Restates the goal; confirms branch is `recovery/phase-5-contract-adrs` (not `main`).
2. Confirms the inputs exist on `main` (CHECKLIST, BACKLOG, AUDIT, `src/`, GAPS).
3. Confirms DRAFT-ONLY: every new ADR is `Status: Draft`; no source/tests/module/`.mof`;
   nothing locked. Each ADR decision traces to an AUDIT verdict, a BACKLOG item, a recovered
   function, and/or the mission.

## B. Expected Changes (branch `recovery/phase-5-contract-adrs`)
Create four ADRs under `docs/adr/`, each with `Status: Draft`, `Date`, and sections
`Context` / `Decision` / `Consequences` / `Open questions for owner` / `Owner gate`. Each
must cite the BACKLOG item and the AUDIT surface(s) it derives from.
- `docs/adr/0003-resource-contract.md` (BACKLOG P5-ADR-001): the TargetState resource
  contract - Get/Test/Set operations, `Ensure` (Present/Absent), typed properties, resource
  discovery/module loading, direct resource dispatch (adapting `Invoke-DscResource`'s
  Get/Set/Test shape), and evidence-friendly return objects. Show how the 10 recovered
  normalization functions fit the contract. Record the DSC-compatibility boundary
  (BACKLOG P5-SCOPE-005): which DSC surfaces TargetState intentionally does NOT provide.
- `docs/adr/0004-declaration-document-format.md` (BACKLOG P5-ADR-002): the human-readable
  declaration-document format - YAML (or a clearly-justified similar format), explicitly NO
  MOF and NO DSC `Configuration` keyword. Include a SMALL illustrative example declaring a
  Registry resource instance (hive/path/value name/value kind/value data/Ensure). Mark the
  example Draft/illustrative.
- `docs/adr/0005-evidence-reporting-model.md` (BACKLOG P5-ADR-003): the evidence/reporting
  model - structured results for Get/Test/plan/apply, per-resource status, and
  compliance-review-friendly output (files and/or command output, NOT an LCM/pull store).
- `docs/adr/0006-mutation-shouldprocess-safety.md` (BACKLOG P5-ADR-004): mutation safety -
  plan vs apply separation, owner-gated live mutation, `ShouldProcess`/`-WhatIf` semantics
  where PS 5.1 supports them, and the registry test-isolation requirement (GAP D07/D08).

## C. Guardrails
- DRAFT ADRs ONLY. Every new ADR is `Status: Draft`; do NOT mark any ADR `Accepted`. Do
  NOT write source, tests, a module manifest, or `.mof`. These are design proposals.
- Ground every decision in committed evidence: cite the AUDIT surface(s), the BACKLOG item,
  the recovered function(s), and/or the mission. Do not contradict the Locked Rules
  (PS 5.1 first; YAML not MOF; GitOps; owner-gated live mutation; STIG is a use case, not
  the goal; isolated/mocked registry tests until a strategy is approved).
- Surface real design forks as "Open questions for owner" in the relevant ADR; do not bury
  a consequential choice as if settled.
- Branch `recovery/phase-5-contract-adrs`, never `main`; preserve signing; stage explicit
  paths only (`docs/adr/0003..0006`, `_handoff/*.md`). PDFs + `_recovery/` stay ignored.
  Do NOT edit `PLAN.md`/`TASK.md`/`CLAUDE-RESTART-PROMPT.md` content, but commit them as-is
  for durability. ASCII; offline is fine (no new research - the audit is the source).

## D. Verification (run each; paste output verbatim into REPORT.md)
- All four ADRs exist: `Test-Path docs\adr\0003-resource-contract.md,docs\adr\0004-declaration-document-format.md,docs\adr\0005-evidence-reporting-model.md,docs\adr\0006-mutation-shouldprocess-safety.md`.
- Every ADR (including the existing 0000-0002) is Draft - this prints nothing:
  `Get-ChildItem docs\adr\*.md | Where-Object { (Get-Content $_ -Raw) -notmatch "(?m)^Status:\s*Draft\s*$" } | ForEach-Object { Write-Error "ADR not Draft: $($_.Name)" }`
- Traceability: each new ADR names its BACKLOG item id and >= 1 AUDIT surface.
- No source/module/.mof created:
  `Get-ChildItem -Recurse -Include *.psm1,*.psd1,*.mof -Path . -ErrorAction SilentlyContinue` (returns nothing new), and no new `.ps1` under `src/`.
- `git branch --show-current` (not `main`); `git log --show-signature -1` good.

## E. Definition of Done (ALL hold; else REPORT `Phase 5 status: BLOCKED | NEEDS-OWNER`)
- The four ADRs (0003-0006) exist, each `Status: Draft`, with Context/Decision/Consequences/
  Open-questions/Owner-gate, internally consistent and not contradicting each other or the
  Locked Rules; each cites its BACKLOG item + AUDIT surface(s).
- 0004 includes an illustrative YAML Registry declaration example (marked Draft).
- No ADR is `Accepted`; no source/tests/module/`.mof` written.
- `REPORT.md` has the verdict, the Section D output, a short summary of each ADR's proposed
  decision + its open questions, and a final line `Phase 5 status: COMPLETE | BLOCKED | NEEDS-OWNER`
  (COMPLETE = the four Draft ADRs are written and ready for owner review).

## F. End State (how this cycle hands back)
- Commit on `recovery/phase-5-contract-adrs` with a signed message (e.g.
  `docs(adr): draft TargetState contract ADRs 0003-0006`). Commit `docs/adr/0003..0006`,
  `_handoff/REPORT*.md`, and the Claude-updated planner docs. Never commit to `main`; never
  bypass signing.
- Push the branch and open a PR to `main` titled `Phase 5: draft TargetState contract ADRs`;
  in the PR body, list each ADR's proposed decision + open questions so the owner can review.
- Finish `REPORT.md` per Section E, then STOP. Do NOT merge - the owner admin-merges after
  Claude's audit. These ADRs stay Draft; owner acceptance is a separate decision.
