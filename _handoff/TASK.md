# TASK - Test/Set Execution-Dispatch Design (analysis + Draft ADR; objectively best route)
_Read `_handoff/PLAN.md` first (Sections 1 Mission, 4 Locked Rules, 0.2, 2). Read `docs/design/execution-map.md` (the owner's unified single-path) and the canonical functions in `recovered/canonical/`. This is a DESIGN-ANALYSIS step: it produces an analysis + a Draft ADR, NOT source._

## Context
The canonical A-spine function set is merged (PR #12 / `729c80a`): one entrypoint
(`Get-TargetResource`) + one shared setup (`Start-ProviderSetup`, rich-object contract) +
the separated-field normalizers, plus B's single-source/more-mature helpers. Only the GET
leg + shared setup exist; `Test-TargetResource` and `Set-TargetResource` are not yet built.
The owner reserved a full step to determine the OBJECTIVELY BEST way to fold Get/Test/Set
into the single execution path - one mode-driven body, shared-setup + thin shims, or another
route. This step decides the dispatch design; the build comes after.

## Goal
Produce a thorough, objective options analysis of how Get/Test/Set unify into the owner's
single execution path, a clear recommendation grounded in the recovered code + the DSC audit,
and a Draft ADR capturing the recommended dispatch design for owner approval. NO source,
tests, module, or `.mof`. The owner decides the route; this step informs and proposes.

## A0. Decision posture
- ADR is `Status: Draft`; do NOT mark Accepted (Locked Rule). The owner approves the route.
- Be genuinely OBJECTIVE: present each route's real trade-offs; the recommendation must be
  defensible from the recovered design + DSC contract, not assumed. Ground everything in the
  owner's actual unified-path intent (one entrypoint, shared setup, run only necessary steps,
  mount-once, soft-return, the owner's style) - do NOT default to a generic DSC 3-method
  pattern unless the analysis shows it is objectively best for THIS design.

## A. Adversarial Review Gate
Archive the current `_handoff/REPORT.md` to the TOP of `_handoff/REPORT-ARCHIVE.md`
(`## Archived <UTC date> - Test/Set design`, append-only), then write a new `REPORT.md`
beginning with a verdict that: restates the goal; confirms branch `recovery/test-set-design`
(not `main`); confirms ANALYSIS-ONLY (no source; ADR stays Draft); lists the candidate routes
you will evaluate and the dimensions you will score them on.

## B. Expected Changes (branch `recovery/test-set-design`)
- `docs/design/test-set-unification.md` - the options analysis. Evaluate AT LEAST these routes
  (add any the analysis surfaces):
  - **R1: One mode-driven body** - a single entrypoint takes an operation/mode (Get/Test/Set,
    or `-WhatIf`-style) and runs the shared setup once, then branches at the action point,
    running only the steps necessary for the requested mode.
  - **R2: Shared setup + thin method shims** - keep `Get-/Test-/Set-TargetResource` as 3 thin
    entrypoints that all call the one `Start-ProviderSetup` and consume the same canonical
    state object; only the action differs.
  - **R3: Any other route** the analysis finds defensible (e.g. a staged read->compare->apply
    pipeline, or a hybrid).
  For EACH route, evaluate on these dimensions (cite the recovered code + DSC audit):
  (a) fit to the owner's "single entrypoint / run only necessary steps" intent;
  (b) reuse of `Start-ProviderSetup` (shared setup, mount-once) and the canonical `Get-TargetResource`;
  (c) how Test (desired-vs-actual compare) and Set (apply under `ShouldProcess`, per ADR 0006) compose;
  (d) DSC-name compatibility - does it keep the `Get/Test/Set` names DSC tooling / `Invoke-DscResource` expect (per the DSC audit), or diverge, and does that matter for the mission?;
  (e) testability with Pester mocks (the registry-isolation decision);
  (f) evidence/result shape (ADR 0005);
  (g) fit to the owner's coding style (Begin/Process/End, soft-return, single ThrowError sink);
  (h) clear pros / cons / risks.
  End with a RECOMMENDATION of the objectively-best route + the rationale, and note what the
  owner must still decide.
- `docs/adr/0007-<kebab-title>.md` (`Status: Draft`) - the Test/Set execution-dispatch decision:
  the recommended dispatch/entrypoint design, how Get/Test/Set unify, where mutation is gated,
  and how it consumes the canonical setup + state object. Cite the analysis, `docs/design/execution-map.md`,
  and ADRs 0003-0006. Sections: Context / Decision / Consequences / Open questions for owner / Owner gate.

## C. Guardrails
- ANALYSIS + Draft ADR ONLY. No source, tests, module manifest, or `.mof`. ADR `Status: Draft`;
  do NOT mark any ADR Accepted.
- Ground every claim in the recovered canonical code (cite functions/line ranges) and the DSC
  audit (`docs/dsc-audit/`). Do not invent recovered behavior; where the recovered design is
  ambiguous, surface it as an open question, not an assumption.
- Branch `recovery/test-set-design`, never `main`; preserve signing; stage explicit paths
  (`docs/design/test-set-unification.md`, `docs/adr/0007-*`, `_handoff/*.md`). PDFs + `_recovery/`
  stay ignored. Do NOT edit `PLAN.md`/`TASK.md`/`CLAUDE-RESTART-PROMPT.md` content, but commit
  them as-is for durability. ASCII; offline is fine (no new web research - the DSC audit is the source).

## D. Verification (run each; paste output verbatim into REPORT.md)
- The analysis covers R1, R2, and any surfaced route, each scored on dimensions (a)-(h), with a
  clear recommendation.
- `docs/adr/0007-*.md` exists and is `Status: Draft`; ALL ADRs still Draft (the all-ADR Draft
  scan prints nothing).
- No source/module/.mof created (`Get-ChildItem -Recurse -Include *.ps1,*.psm1,*.psd1,*.mof -Path src,recovered/canonical` shows no NEW files; recovered/canonical unchanged).
- `git branch --show-current` (not `main`); `git log --show-signature -1` good.

## E. Definition of Done (ALL hold; else REPORT `Test/Set design status: BLOCKED | NEEDS-OWNER`)
- `docs/design/test-set-unification.md` objectively evaluates the routes on the listed
  dimensions and makes a defensible, code-grounded recommendation.
- `docs/adr/0007-*` exists, `Status: Draft`, capturing the recommended dispatch design with
  open questions for the owner; no ADR Accepted; no source/.mof.
- `REPORT.md` has the verdict, a short summary of each route's verdict + the recommendation,
  the Section D output, and a final line `Test/Set design status: COMPLETE | BLOCKED | NEEDS-OWNER`.

## F. End State (how this cycle hands back)
- Commit on `recovery/test-set-design` with a signed message (e.g.
  `docs(design): test/set execution-dispatch analysis + draft ADR 0007`). Commit the analysis
  + ADR + `_handoff/REPORT*.md` + the Claude-updated planner docs. Never commit to `main`;
  never bypass signing.
- Push the branch and open a PR to `main` titled `Test/Set execution-dispatch design (ADR 0007 Draft)`;
  in the PR body summarize each route's verdict + the recommendation so the owner can decide.
- Finish `REPORT.md` per Section E, then STOP. Do NOT merge - the owner reviews the recommendation
  and decides the route (ADR stays Draft until owner approval). The per-function build comes after.
