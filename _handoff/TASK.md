# TASK - Phase 4: Microsoft DSC Surface Audit (audit-only)
_Read `_handoff/PLAN.md` first - especially Section 6 "Phase 4" (subsections 4.0-4.8: entry gate, sources, per-surface record schema, verdict set, surfaces-in-scope, cross-reference, acceptance), plus Sections 0.2, 2, 4. This is the operational layer; PLAN Phase 4 is the detail._

## Gate status
Gate 3 -> 4 is GREEN: Phase 3 accepted as the recovery baseline (10/18 functions
stabilized + merged through PR #6 / `69325cd`); `docs/recovery/GAPS.md` exists; the
Phase 2 matrix has 0 unresolved defers; the owner pivoted to Phase 4. Work on a NEW
branch `recovery/phase-4-dsc-audit`.

## Goal
Produce a complete, citation-backed AUDIT of the Microsoft-published PowerShell Desired
State Configuration surface - one structured record per surface (the ~21 surfaces in
PLAN 4.4: 14 cmdlets/keywords + 7 concepts) - entirely from PRIMARY SOURCES at execution
time. This phase produces EVIDENCE only. It does NOT build the port/adapt/skip checklist
(that is the separate Phase 4b), does NOT design or implement TargetState, and changes
no ADR and no source.

## Hard preconditions
- NETWORK REQUIRED. Phase 4 retrieves live from Microsoft Learn and Microsoft/PowerShell
  GitHub. If you cannot reach those, STOP and mark BLOCKED (no network). Do NOT assert
  any DSC behavior from memory.
- Every behavioral claim MUST cite a Microsoft Learn or Microsoft-GitHub URL with a
  retrieved-date (UTC ISO-8601) and the documented version (or repo commit/tag; if a
  page states no version, record `version: unstated` + last-updated/SHA).

## A0. Owner Decisions (recorded; apply)
- D6 in-box discovery: ANSWERED - read-only `Get-Command`/`Get-Help`/`Get-DscResource`
  allowed as CORROBORATION only (reads module metadata, not live registry/system state;
  do NOT invoke or apply any DSC resource). Authoritative claims still cite Learn/GitHub.
- Output location: `docs/dsc-audit/` (already allowlisted; no `.gitignore` change).

## A. Adversarial Review Gate
Archive the current Phase 3 `_handoff/REPORT.md` to the TOP of
`_handoff/REPORT-ARCHIVE.md` (`## Archived <UTC date> - Phase 4`, append-only), then
write a new `REPORT.md` beginning with a verdict that:
1. Restates the goal; confirms branch is `recovery/phase-4-dsc-audit` (not `main`).
2. Confirms NETWORK access by naming the Microsoft Learn + Microsoft-GitHub URLs you can
   actually reach. If you cannot reach them, `Decision: BLOCKED (no network)` and stop.
3. Confirms the Phase 3 inputs the cross-reference needs: `docs/recovery/GAPS.md` exists.
4. Confirms AUDIT-ONLY: no checklist (Phase 4b), no design, no implementation, no ADR
   change, no `.mof`. Confirms DSC facts come from primary sources, not memory.

## B. Expected Changes (under `docs/dsc-audit/`)
- `docs/dsc-audit/AUDIT.md` - one record per surface in PLAN 4.4, using the EXACT 4.2
  columns: `surface | source-url | retrieved-date | PS5.1-behavior | TargetState-
  relevance | verdict | rationale | registry-proof-impact`. Each surface gets exactly
  ONE verdict from the closed set in PLAN 4.3 (port directly | adapt conceptually |
  replace with TargetState-native | explicitly skip | defer until after Registry proof).
  If a listed surface does not exist in PS 5.1, say so in `PS5.1-behavior` and use
  `explicitly skip`. Cross-platform DSC v3 = a context-only record, tagged not-the-target.
- `docs/dsc-audit/SOURCES.md` - the citation ledger: every `source-url` + `source-class`
  (Learn | MS-GitHub | in-box) + `retrieved-date` + `version`, per PLAN 4.1.
- `docs/dsc-audit/REGISTRY-CROSSREF.md` - the PLAN 4.5 gap cross-reference: for every
  item in `docs/recovery/GAPS.md`, the related DSC surface(s) and
  does-DSC-address-it (yes | partial | no), and every AUDIT record's
  `registry-proof-impact` names the gap id(s) it touches or states none.

## C. Guardrails
- AUDIT ONLY. Do NOT produce the port/adapt/skip checklist or the implementation backlog
  (Phase 4b). Do NOT design or implement TargetState, write source, or write any `.mof`.
  Do NOT change any ADR's status or content.
- No DSC facts from memory. Verify each Learn/GitHub URL resolves at run time and record
  the resolved URL actually used. Verify Microsoft/PowerShell org ownership before
  trusting a GitHub repo. Disallowed as authority: blogs, Stack Overflow, third-party
  tutorials, LLM memory, non-Microsoft forks (may be read for orientation, never cited).
- In-box discovery is read-only corroboration ONLY: summarize what `Get-Command`/
  `Get-Help`/`Get-DscResource` report; do NOT invoke/apply a resource, start/set the LCM,
  or touch the live registry/system. Do not paste raw machine-specific output that could
  carry host data - summarize it.
- Branch `recovery/phase-4-dsc-audit`, never `main`; preserve signing; stage explicit
  paths only (`docs/dsc-audit/`, `_handoff/*.md`). PDFs + `_recovery/` stay ignored
  (untouched). Do NOT edit `PLAN.md`/`TASK.md`/`CLAUDE-RESTART-PROMPT.md` content, but
  commit them as-is for durability.

## D. Verification (run each; paste output verbatim into REPORT.md)
- Network proof: the Learn + MS-GitHub URLs fetched (status/title), proving live retrieval.
- Coverage table: every PLAN 4.4 surface has a record (y), is cited (y), has a verdict (y);
  any "n" blocks acceptance.
- Citation integrity: every behavioral claim's `source-url` appears in `SOURCES.md` with a
  `retrieved-date` and `version`.
- Cross-reference covers 100% of `docs/recovery/GAPS.md` items.
- Hygiene: `git ls-files` shows `docs/dsc-audit/**` and no `.pdf`/`_recovery/`;
  `git branch --show-current` (not `main`); `git log --show-signature -1` good.

## E. Definition of Done (ALL hold; else REPORT `Phase 4 status: BLOCKED | NEEDS-OWNER`)
Meet every PLAN 4.7 criterion:
- Every PLAN 4.4 surface (plus any discovered) has exactly one record with all 8 columns
  populated (no blanks; `defer until after Registry proof` where a real decision cannot
  yet be made), and exactly one closed-set verdict.
- Every behavioral claim carries >= 1 Learn/MS-GitHub `source-url` in `SOURCES.md` with
  retrieved-date + version. The cross-platform DSC v3 record is present + tagged context-only.
- The cross-reference covers 100% of the GAPS items; every record has a non-empty
  `registry-proof-impact`.
- No checklist/backlog/source/ADR change/.mof was produced.
- `REPORT.md` has the verdict, the network/gate proof, the coverage table, the full
  Section D output, and a final line `Phase 4 status: COMPLETE | BLOCKED | NEEDS-OWNER`
  (COMPLETE = audit complete enough to build the checklist; the checklist itself is the
  separate Phase 4b).

## F. End State (how this cycle hands back)
- Commit on `recovery/phase-4-dsc-audit` with a signed message (e.g.
  `docs(dsc-audit): microsoft DSC surface audit evidence`). Commit `docs/dsc-audit/**`,
  `_handoff/REPORT*.md`, and the Claude-updated planner docs. Never commit to `main`;
  never bypass signing.
- Push the branch and open a PR to `main` titled `Phase 4: Microsoft DSC surface audit`;
  paste the Section D coverage table + network proof in the PR body.
- Finish `REPORT.md` per Section E, then STOP. Do NOT merge - the owner admin-merges after
  Claude's audit. If `BLOCKED` (no network) or `NEEDS-OWNER`, still push + open the PR with
  the report and name the blocker.
