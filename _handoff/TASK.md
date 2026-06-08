# TASK - Governance: Deny-by-default tracking policy (ADR 0002)
_Read `_handoff/PLAN.md` first (Sections 0.2, 2, 4, and Section 10 Change Log). This is an owner-initiated governance interlude between Phase 1 (COMPLETE, merged `d87f1f6`) and Phase 2._

## Why this task
The owner added `**` to the top of `.gitignore` (currently an uncommitted
working-tree change) and asked for it to be recorded as an ADR. The intent is a
DENY-BY-DEFAULT tracking policy: nothing is tracked unless explicitly allowlisted,
so an accidental `git add` cannot leak the scanned PDFs, `_recovery/` OCR evidence
(which may contain PII), or any large binary into this PUBLIC repo. A bare `**`
ignores *new* files but does not allowlist the paths we DO track, so this task
formalizes the policy correctly.

## Goal
1. Record `docs/adr/0002-deny-by-default-tracking.md` (`Status: Draft`).
2. Replace `.gitignore` with a correct deny-by-default allowlist (below) that keeps
   currently-tracked paths trackable, ignores new unlisted files by default, and
   HARD-DENIES the PDFs and `_recovery/` (never allowlisted).
Do NOT extract PDFs, write engine/source, audit DSC, or start Phase 2.

## A. Adversarial Review Gate
Archive the current Phase 1 `_handoff/REPORT.md` to the top of
`_handoff/REPORT-ARCHIVE.md` (`## Archived <UTC date> - Governance ADR 0002`,
append-only), then write a new `REPORT.md` beginning with a verdict that:
1. Restates the goal and confirms you are on a new branch (not `main`).
2. Challenges the policy and the MECHANISM: bare `**` is recursive and fights
   re-inclusion (git cannot re-include a path whose parent dir is excluded); the
   `/*` (top-level ignore) + allowlist form below is the maintainable equivalent.
   Recommend the chosen form; note that ADR 0002 stays Draft pending owner approval.
3. Confirms the PDFs and `_recovery/` will remain ignored under the new file.
If you believe a different mechanism is objectively better, propose it in REPORT.md
with evidence; do not silently deviate.

## B. Expected Changes (branch `recovery/governance-deny-by-default`)
1. Replace `/.gitignore` ENTIRELY with exactly this (ASCII, no BOM):
```
# ============================================================================
# Deny-by-default tracking policy (ADR 0002, Draft).
# Ignore everything at the repo root; explicitly allowlist tracked paths below.
# Rationale: this PUBLIC repo handles scanned PII and large binaries (the source
# PDFs and the _recovery/ OCR evidence). Deny-by-default means an accidental
# `git add` cannot leak anything that was not deliberately allowlisted.
# To track a NEW top-level directory later (e.g. src/, tests/), add a matching
# `!/<dir>/` line below. NEVER add a `!` allowlist entry for the PDFs or _recovery/.
# ============================================================================
/*

# --- Allowlist: tracked top-level entries (directories need a trailing slash) ---
!/.github/
!/.gitattributes
!/.gitignore
!/README.md
!/_handoff/
!/docs/

# --- Hard-deny (defense-in-depth; also excluded by /*, must never be allowlisted) ---
/06042026.pdf
/06042026_001.pdf
/_recovery/

# --- Noise: ignored even inside allowlisted directories ---
*.log
*.tmp
TestResults/
coverage.xml
Thumbs.db
Desktop.ini
.DS_Store
.vs/
```
2. Create `docs/adr/0002-deny-by-default-tracking.md` with `Status: Draft` and
   sections: Context (public repo + scanned PII + large binaries; allow-by-default
   risk), Decision (deny-by-default via `/*` + explicit allowlist; PDFs and
   `_recovery/` are never allowlisted; to track a new top-level dir add `!/<dir>/`),
   Consequences (new files are ignored unless allowlisted - a deliberate friction;
   contributors add an allowlist line or use `git add -f` for one-offs), Owner gate
   (Draft until the owner accepts; supersedes the Phase 0 allow-by-default
   `.gitignore`).
3. Optionally add one line to `docs/governance.md` pointing at ADR 0002 as the
   tracking policy. Do not change any other governance content.

## C. Guardrails
- Branch `recovery/governance-deny-by-default`, never `main`; preserve signing.
- Stage only explicit paths; never `git add -A`/`.`/`*`.
- The PDFs and `_recovery/` MUST remain ignored and untracked. If either becomes
  staged/tracked, STOP and report.
- ADR 0002 is `Status: Draft`. Do not mark it Accepted.
- ASCII, no BOM (PowerShell 5.1: use `Set-Content -Encoding utf8` or
  `[IO.File]::WriteAllText(...,[Text.UTF8Encoding]::new($false))`).
- Do NOT open/OCR the PDFs, write `.ps1`/`.psm1`/`.psd1` or `src/`/`tests/`, audit
  DSC, or touch live system state.
- Do NOT edit `PLAN.md`, `TASK.md`, or `CLAUDE-RESTART-PROMPT.md` content, but DO
  commit them as-is for durability (Claude updated them this cycle).

## D. Verification (run each; paste output verbatim into REPORT.md)
- PDFs + `_recovery/` STILL ignored: `git check-ignore -v 06042026.pdf 06042026_001.pdf _recovery/` (a rule for each).
- Currently-tracked files STILL trackable (not ignored): `git check-ignore -v README.md _handoff/PLAN.md docs/governance.md .gitattributes` prints NOTHING (exit 1 = not ignored).
- New unlisted top-level file is ignored by default: create `probe.tmp`, run
  `git check-ignore -v probe.tmp` (must print a rule), then delete `probe.tmp`.
- New file in an allowlisted dir IS trackable: `git check-ignore -v docs/adr/0002-deny-by-default-tracking.md` prints NOTHING (trackable).
- Tracked set intact: `git status --short` and `git ls-files` show no PDFs, nothing
  under `_recovery/`, and the new ADR addable by explicit path.
- ADR is Draft: `Get-ChildItem docs\adr\*.md | Where-Object { (Get-Content $_ -Raw) -notmatch "(?m)^Status:\s*Draft\s*$" } | ForEach-Object { Write-Error "ADR not Draft: $($_.Name)" }` prints nothing.
- `git branch --show-current` (not `main`) and `git log --show-signature -1` (good signature).

## E. Definition of Done (ALL hold; else REPORT `Governance status: BLOCKED | NEEDS-OWNER`)
- `.gitignore` replaced with the deny-by-default allowlist above; both PDFs and
  `_recovery/` still ignored and untracked; all currently-tracked files still
  trackable; a new unlisted top-level file is ignored; a new file under `docs/` is
  trackable.
- `docs/adr/0002-deny-by-default-tracking.md` exists with `Status: Draft`.
- No engine/source/PDF-extraction/DSC; no live-system change.
- `_handoff/REPORT.md` has the verdict, the full Section D output, and a final line
  `Governance status: COMPLETE | BLOCKED | NEEDS-OWNER`.

## F. End State (how this cycle hands back)
- Commit on `recovery/governance-deny-by-default` with a signed message
  (e.g. `chore(governance): deny-by-default tracking policy (ADR 0002)`). Never
  commit to `main`; never bypass signing.
- Push the branch and open a PR to `main` titled
  `Governance: deny-by-default tracking policy (ADR 0002)`; paste the Section D
  output in the PR body.
- Finish `REPORT.md` per Section E, then STOP. Do NOT merge - the owner admin-merges
  after Claude's audit.
