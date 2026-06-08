Phase/Task status: COMPLETE

## Adversarial review verdict

Goal: execute Phase 6 on branch `recovery/phase-6-registry-readonly` by building the first read-only Registry proof: parse a JSON `TargetDocument`, validate Registry resources, run `Get`, `Test`, and `Plan`, and emit ADR 0005-shaped evidence objects. This cycle must not implement `Set`/`Apply`, call registry mutation cmdlets, implement `Mount-RegistryHive` or `Start-ProviderSetup`, or run tests against the live registry.

Verdict: PROCEED and COMPLETE. The task is aligned with the mission and with the owner decisions recorded after Phase 5: JSON for the first proof, Pester mocks for Registry tests, and Apply mode deferred.

Branch check: PROCEED on `recovery/phase-6-registry-readonly`, not `main`.

Input check: PROCEED. ADRs `docs/adr/0003-resource-contract.md` through `docs/adr/0006-mutation-shouldprocess-safety.md` exist, and the 10 stabilized recovered helpers exist under `src/`:

```text
Convert-ByteArrayToHexString.ps1
ConvertFrom-Array.ps1
Get-NormalizedRegistryKey.ps1
Get-RegistryKeyHive.ps1
Get-RegistryKeyNameStr.ps1
Get-RegistryKeyPath.ps1
Get-RegistryKeyPathStr.ps1
Get-RegistryValueKindStr.ps1
Get-RegistryValueNameStr.ps1
ThrowError.ps1
```

PDF integrity check: PROCEED. The current hashes match the PLAN Section 7 / archived baseline and the PDFs were not used for implementation:

```text
06042026.pdf     B6BD5239D642D09368E255E21064B1F48C63D075DD43F8374098300DB9ED155F
06042026_001.pdf D6BE73056B47FB9EEA9126A9EA5BC232BCF733A5562306AC2A601FA57FFC051E
```

READ-ONLY scope check: PROCEED. The implementation added read operations only. Tests mock registry access cmdlets. No deferred side-effect functions were implemented.

New functions added:

- `Import-TargetStateDocument`: loads and validates JSON `TargetDocument` input through built-in `ConvertFrom-Json`.
- `ConvertTo-TargetStateRegistryResource`: validates and normalizes Registry resource instances.
- `Join-TargetStateRegistryPath`: design-fresh helper for Registry provider paths used by read operations.
- `ConvertTo-TargetStateRegistryValueData`: design-fresh helper for typed Registry value data comparison/evidence formatting.
- `New-TargetStateEvidence`: builds ADR 0005-shaped evidence objects with mutation flags set to false.
- `Get-TargetStateRegistryResource`: reads observed Registry state for one normalized resource.
- `Compare-TargetStateRegistryResource`: compares desired and observed state and produces differences/proposed read-only actions.
- `Test-TargetStateRegistryResource`: returns compliance evidence with `InDesiredState`.
- `New-TargetStateRegistryPlan`: returns planned create/update/delete/no-op evidence without mutation.

Missing helpers were designed fresh with tests defining intended behavior. I did not alias the absent recovered helper names `Get-NormalizedRegistryKeyString`, `ArrayToString`, or `Get-RegistryKeyType`.

Chosen output location: `docs/adr/0004-declaration-document-format.md`, `docs/adr/0006-mutation-shouldprocess-safety.md`, `.gitignore`, `examples/registry-proof.json`, new `src/*.ps1`, new `tests/*.Tests.ps1`, `_handoff/REPORT.md`, and `_handoff/REPORT-ARCHIVE.md`.

## What changed

- Archived the prior Phase 5 report to the top of `_handoff/REPORT-ARCHIVE.md` under `## Archived 2026-06-08 - Phase 6 read-only`.
- Updated ADR 0004 to record JSON-first for the Registry proof while keeping `Status: Draft`.
- Updated ADR 0006 to record Pester mocks as the first Registry test-isolation strategy while keeping `Status: Draft`.
- Added `!/examples/` to `.gitignore` and added `examples/registry-proof.json`.
- Added the nine read-only Registry proof functions listed above under flat `src/`.
- Added one Pester test file for each new function. Registry access in Get/Test/Plan tests is mocked.

## What was intentionally not changed

- No `PLAN.md`, `TASK.md`, or `CLAUDE-RESTART-PROMPT.md` content was edited by Codex; pre-existing Claude/owner handoff edits were preserved for durability.
- No existing recovered `src/*.ps1` function behavior was changed.
- No ADR was marked `Accepted`.
- No `Set`/`Apply` operation, module manifest, broad engine, discovery layer, durable evidence export, `.mof`, `Mount-RegistryHive`, or `Start-ProviderSetup` was implemented.
- No PDFs were opened, parsed, OCR'd, moved, renamed, modified, staged, or tracked.
- No live registry or Windows system state was touched by tests or demo.

## Verification output

Source parse check:

```text
PARSE OK: Compare-TargetStateRegistryResource.ps1
PARSE OK: Convert-ByteArrayToHexString.ps1
PARSE OK: ConvertFrom-Array.ps1
PARSE OK: ConvertTo-TargetStateRegistryResource.ps1
PARSE OK: ConvertTo-TargetStateRegistryValueData.ps1
PARSE OK: Get-NormalizedRegistryKey.ps1
PARSE OK: Get-RegistryKeyHive.ps1
PARSE OK: Get-RegistryKeyNameStr.ps1
PARSE OK: Get-RegistryKeyPath.ps1
PARSE OK: Get-RegistryKeyPathStr.ps1
PARSE OK: Get-RegistryValueKindStr.ps1
PARSE OK: Get-RegistryValueNameStr.ps1
PARSE OK: Get-TargetStateRegistryResource.ps1
PARSE OK: Import-TargetStateDocument.ps1
PARSE OK: Join-TargetStateRegistryPath.ps1
PARSE OK: New-TargetStateEvidence.ps1
PARSE OK: New-TargetStateRegistryPlan.ps1
PARSE OK: Test-TargetStateRegistryResource.ps1
PARSE OK: ThrowError.ps1
```

Pester:

```text
Result       : Passed
PassedCount  : 38
FailedCount  : 0
SkippedCount : 0
NotRunCount  : 0
TotalCount   : 38
```

Mocked registry access evidence:

```text
tests\Get-TargetStateRegistryResource.Tests.ps1:33:        Mock -CommandName Test-Path -MockWith { $true }
tests\Get-TargetStateRegistryResource.Tests.ps1:34:        Mock -CommandName Get-Item -MockWith { $script:mockRegistryKey }
tests\Get-TargetStateRegistryResource.Tests.ps1:35:        Mock -CommandName Get-ItemProperty -MockWith { [pscustomobject]@{ Enabled = 1 } }
tests\Get-TargetStateRegistryResource.Tests.ps1:48:        Mock -CommandName Test-Path -MockWith { $false }
tests\Get-TargetStateRegistryResource.Tests.ps1:49:        Mock -CommandName Get-Item -MockWith { throw 'Get-Item should not be called' }
tests\Get-TargetStateRegistryResource.Tests.ps1:50:        Mock -CommandName Get-ItemProperty -MockWith { throw 'Get-ItemProperty should not be called' }
tests\New-TargetStateRegistryPlan.Tests.ps1:33:        Mock -CommandName Test-Path -MockWith { $true }
tests\New-TargetStateRegistryPlan.Tests.ps1:34:        Mock -CommandName Get-Item -MockWith { $script:mockRegistryKey }
tests\New-TargetStateRegistryPlan.Tests.ps1:35:        Mock -CommandName Get-ItemProperty -MockWith { [pscustomobject]@{ Enabled = 1 } }
tests\New-TargetStateRegistryPlan.Tests.ps1:45:        Mock -CommandName Test-Path -MockWith { $true }
tests\New-TargetStateRegistryPlan.Tests.ps1:46:        Mock -CommandName Get-Item -MockWith { $script:mockRegistryKey }
tests\New-TargetStateRegistryPlan.Tests.ps1:47:        Mock -CommandName Get-ItemProperty -MockWith { [pscustomobject]@{ Enabled = 0 } }
tests\Test-TargetStateRegistryResource.Tests.ps1:33:        Mock -CommandName Test-Path -MockWith { $true }
tests\Test-TargetStateRegistryResource.Tests.ps1:34:        Mock -CommandName Get-Item -MockWith { $script:mockRegistryKey }
tests\Test-TargetStateRegistryResource.Tests.ps1:35:        Mock -CommandName Get-ItemProperty -MockWith { [pscustomobject]@{ Enabled = 1 } }
tests\Test-TargetStateRegistryResource.Tests.ps1:46:        Mock -CommandName Test-Path -MockWith { $true }
tests\Test-TargetStateRegistryResource.Tests.ps1:47:        Mock -CommandName Get-Item -MockWith { $script:mockRegistryKey }
tests\Test-TargetStateRegistryResource.Tests.ps1:48:        Mock -CommandName Get-ItemProperty -MockWith { [pscustomobject]@{ Enabled = 0 } }
```

Read-only demo against mocked state:

```text
Operation Status        InDesiredState PlannedAction ObservedValue DifferenceCount
--------- ------        -------------- ------------- ------------- ---------------
Get       Observed                                   0                           0
Test      NonCompliant  False                        0                           1
Plan      PlannedChange False          update        0                           1

Plan differences:

Property  Desired Actual Action
--------  ------- ------ ------
ValueData 1       0      update
```

No read-path mutation text in `src/`:

```text
NO OUTPUT from: Select-String -Path src\*.ps1 -Pattern '\b(Set|Apply)\b|Set-Item(Property)?|New-Item(Property)?|Remove-Item(Property)?|Clear-Item(Property)?|Rename-Item(Property)?'
```

Sensitive-content scan over new `src/`, `tests/`, and `examples` files:

```text
NO OUTPUT from: Select-String -Path src\*.ps1,tests\*.ps1,examples\*.json -Pattern 'S-1-5-[0-9-]+','C:\\Users\\[^\\\s]+','\\\\[A-Za-z0-9._-]+\\[A-Za-z0-9$._-]+','BEGIN .*PRIVATE KEY','(?i)(password|pwd|secret|apikey)\s*=','(?i)[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}','(?i)([0-9A-F]{2}[:-]){5}[0-9A-F]{2}','\b(?:\d{1,3}\.){3}\d{1,3}\b','[A-Za-z0-9+/]{200,}={0,2}' -AllMatches
```

Every ADR still Draft:

```text
NO OUTPUT from: Get-ChildItem docs\adr\*.md | Where-Object { (Get-Content $_ -Raw) -notmatch '(?m)^Status:\s*Draft\s*$' } | ForEach-Object { Write-Error "ADR not Draft: $($_.Name)" }
```

PDF hash check:

```text
Hash                                                             Path
----                                                             ----
B6BD5239D642D09368E255E21064B1F48C63D075DD43F8374098300DB9ED155F C:\Users\HellBomb\Documents\GitHub\nwarila-platform...
D6BE73056B47FB9EEA9126A9EA5BC232BCF733A5562306AC2A601FA57FFC051E C:\Users\HellBomb\Documents\GitHub\nwarila-platform...
```

Ignore checks:

```text
.gitignore:27:	examples/
.gitignore:24:/06042026.pdf	06042026.pdf
.gitignore:25:/06042026_001.pdf	06042026_001.pdf
.gitignore:26:/_recovery/	_recovery/
```

Tracked PDF / `_recovery/` check:

```text
NO OUTPUT from: git ls-files -- 06042026.pdf 06042026_001.pdf _recovery/
```

Branch:

```text
recovery/phase-6-registry-readonly
```

Git status before final staging:

```text
## recovery/phase-6-registry-readonly
 M .gitignore
 M _handoff/CLAUDE-RESTART-PROMPT.md
 M _handoff/PLAN.md
 M _handoff/REPORT-ARCHIVE.md
 M _handoff/REPORT.md
 M _handoff/TASK.md
 M docs/adr/0004-declaration-document-format.md
 M docs/adr/0006-mutation-shouldprocess-safety.md
?? examples/
?? src/Compare-TargetStateRegistryResource.ps1
?? src/ConvertTo-TargetStateRegistryResource.ps1
?? src/ConvertTo-TargetStateRegistryValueData.ps1
?? src/Get-TargetStateRegistryResource.ps1
?? src/Import-TargetStateDocument.ps1
?? src/Join-TargetStateRegistryPath.ps1
?? src/New-TargetStateEvidence.ps1
?? src/New-TargetStateRegistryPlan.ps1
?? src/Test-TargetStateRegistryResource.ps1
?? tests/Compare-TargetStateRegistryResource.Tests.ps1
?? tests/ConvertTo-TargetStateRegistryResource.Tests.ps1
?? tests/ConvertTo-TargetStateRegistryValueData.Tests.ps1
?? tests/Get-TargetStateRegistryResource.Tests.ps1
?? tests/Import-TargetStateDocument.Tests.ps1
?? tests/Join-TargetStateRegistryPath.Tests.ps1
?? tests/New-TargetStateEvidence.Tests.ps1
?? tests/New-TargetStateRegistryPlan.Tests.ps1
?? tests/Test-TargetStateRegistryResource.Tests.ps1
```

Diff whitespace hygiene:

```text
warning: in the working copy of '.gitignore', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of '_handoff/REPORT-ARCHIVE.md', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of '_handoff/REPORT.md', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of '_handoff/TASK.md', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'docs/adr/0004-declaration-document-format.md', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'docs/adr/0006-mutation-shouldprocess-safety.md', LF will be replaced by CRLF the next time Git touches it
```

## Deviations from `TASK.md` and why

- `REPORT.md` cannot embed the final commit's `git log --show-signature -1` output without changing the commit being verified. I will run the post-commit signature check and include the output in the PR/final execution note.
- `git diff --check` emitted Git line-ending normalization warnings for handoff/ADR text files. It exited successfully and did not report whitespace errors.
- The `git check-ignore -v examples/` output reports the allowlist resolution for `examples/` without rendering the leading `!`; line-number inspection shows line 21 is `!/examples/`.

## Open objections that must be resolved before advancing

- Claude should audit whether the Phase 6 proof is appropriately narrow before any future apply-mode or engine work begins.

## Owner decisions needed

- Owner merge to `main` after Claude audit.
- Future apply-mode and side-effecting registry tests remain owner-gated.

Phase 6 (read-only) status: COMPLETE
