Phase/Task status: COMPLETE

## Adversarial review verdict

Goal: execute only the owner-initiated governance interlude for ADR 0002:
replace `.gitignore` with a deny-by-default tracking policy, add
`docs/adr/0002-deny-by-default-tracking.md` as `Status: Draft`, keep the source
PDFs and `_recovery/` ignored and untracked, and stop after opening a PR to
`main`. This cycle did not extract PDFs, start Phase 2, write engine/source
files, audit DSC, or touch live Windows state.

Branch check: PROCEED on `recovery/governance-deny-by-default`, not `main`.

Mechanism challenge: a bare `**` at the top of `.gitignore` is not the right
mechanism for this repo's allowlist. It ignores recursively and makes
re-inclusion brittle because Git cannot re-include a path when a parent
directory remains excluded. The maintainable policy is the TASK.md form:
ignore repo-root entries with `/*`, then explicitly re-include the currently
tracked top-level files/directories, with directory allowlist entries ending in
`/`. This preserves tracked-path ergonomics while denying accidental new
top-level files by default.

Decision: PROCEED with the exact TASK.md `.gitignore` allowlist. ADR 0002 remains
Draft pending owner approval. The source PDFs and `_recovery/` remain
hard-denied and must never receive a `!` allowlist entry.

Chosen output locations: `.gitignore`, `docs/adr/0002-deny-by-default-tracking.md`,
and `_handoff/REPORT.md` / `_handoff/REPORT-ARCHIVE.md`.

## What changed

- Archived the Phase 1 `REPORT.md` verbatim to the top of
  `_handoff/REPORT-ARCHIVE.md` under
  `## Archived 2026-06-08T18:55:25Z - Governance ADR 0002`.
- Replaced `.gitignore` with the exact deny-by-default `/*` allowlist from
  `TASK.md`.
- Added Draft ADR 0002 at `docs/adr/0002-deny-by-default-tracking.md`.
- Committed the Claude-updated `_handoff/PLAN.md`, `_handoff/TASK.md`, and
  `_handoff/CLAUDE-RESTART-PROMPT.md` as-is for durability, per `TASK.md`.

Implementation commit:

```text
a9d396690d6a52435f002f0522364706eab954f5 chore(governance): deny-by-default tracking policy (ADR 0002)
```

## What was intentionally not changed

- No PDFs, `_recovery/` content, extraction output, DSC audit artifacts, engine
  files, source files, `src/`, or `tests/` were added.
- No live Windows registry or system state was touched.
- No ADR was marked Accepted.
- `docs/governance.md` was not changed; the TASK.md governance pointer was
  optional, and ADR 0002 is already discoverable in `docs/adr/`.
- `PLAN.md`, `TASK.md`, and `CLAUDE-RESTART-PROMPT.md` content was not edited by
  Codex.

## Verification output

`git check-ignore -v 06042026.pdf 06042026_001.pdf _recovery/`

```text
.gitignore:21:/06042026.pdf	06042026.pdf
.gitignore:22:/06042026_001.pdf	06042026_001.pdf
.gitignore:23:/_recovery/	_recovery/
```

`git check-ignore -v README.md _handoff\PLAN.md docs\governance.md .gitattributes`

```text
```

Exit code: `1` (expected: tracked files are not ignored).

`git check-ignore -v probe.tmp`

```text
.gitignore:27:*.tmp	probe.tmp
```

Additional adversarial proof for a new unlisted top-level file that does not
match the `*.tmp` noise rule:

`git check-ignore -v probe.unlisted`

```text
.gitignore:10:/*	probe.unlisted
```

Both temporary probe files were deleted after their checks.

`git check-ignore -v docs\adr\0002-deny-by-default-tracking.md`

```text
```

Exit code: `1` (expected: ADR 0002 is under allowlisted `docs/` and is not
ignored).

`git status --short`

```text
 M _handoff/REPORT.md
```

Note: this is the expected self-reference state before committing this final
report update. It shows no PDFs and no `_recovery/` paths.

`git ls-files`

```text
.gitattributes
.github/CODEOWNERS
.gitignore
README.md
_handoff/CLAUDE-RESTART-PROMPT.md
_handoff/PLAN.md
_handoff/REPORT-ARCHIVE.md
_handoff/REPORT.md
_handoff/TASK.md
docs/adr/0000-adr-process.md
docs/adr/0001-targetstate-charter.md
docs/adr/0002-deny-by-default-tracking.md
docs/governance.md
```

`git ls-files -- 06042026.pdf 06042026_001.pdf _recovery/`

```text
```

`Get-ChildItem docs\adr\*.md | Where-Object { (Get-Content $_ -Raw) -notmatch "(?m)^Status:\s*Draft\s*$" } | ForEach-Object { Write-Error "ADR not Draft: $($_.Name)" }`

```text
```

`.gitignore` first three bytes:

```text
23-20-3D
```

ADR 0002 first three bytes:

```text
23-20-41
```

These are not UTF-8 BOM bytes.

`git branch --show-current`

```text
recovery/governance-deny-by-default
```

`git log --show-signature -1`

```text
commit a9d396690d6a52435f002f0522364706eab954f5
Good "git" signature for 33955773+NWarila@users.noreply.github.com with ECDSA key SHA256:UAsMtOhQwpR/duoYjPY3LSw4a905Dx29QPGGXCTkhGY
Author: NWarila <33955773+NWarila@users.noreply.github.com>
Date:   Mon Jun 8 19:01:29 2026 +0000

    chore(governance): deny-by-default tracking policy (ADR 0002)
```

The final report commit necessarily occurs after this embedded output. Codex
will re-run `git log --show-signature -1` after committing this report and include
that final signature output in the PR body and final response.

## Deviations from `TASK.md` and why

- The required `probe.tmp` verification printed a rule, but the matching rule was
  `*.tmp`, not `/*`. That satisfies the literal TASK.md check but is weak evidence
  for deny-by-default. I added `probe.unlisted` as an extra proof that a new
  unlisted top-level file is ignored by the root `/*` rule.
- The final signed report commit cannot be proven inside the same committed
  report without an infinite self-reference. The implementation commit signature
  is pasted above; the final report commit signature will be provided in the PR
  body and final response.

## Open objections that must be resolved before advancing

None blocking. Claude should note that future verification should avoid
`probe.tmp` if the intent is specifically to test `/*`; use a name that does not
match any noise rule.

## Owner decisions needed

ADR 0002 remains Draft until owner approval. Owner admin-merge remains required
after Claude audit; Codex must not merge this PR.

Governance status: COMPLETE
