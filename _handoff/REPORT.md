Phase/Task status: COMPLETE

## Adversarial review verdict

Goal: execute the Phase 3 recovery-completeness cycle on `recovery/phase-3-completeness`: enumerate every recovered call to a name outside the 18-function Phase 1 inventory, classify each with page/image evidence, recover any missed PDF helper, and stabilize only non-registry/pure deferred functions whose callees resolve without invented helpers.

Branch check: PROCEED on `recovery/phase-3-completeness`, not `main`.

Input gate: PROCEED. `_recovery/_inventory/function-inventory.tsv`, `_recovery/_inventory/call-graph.tsv`, `_recovery/_inventory/reconciliation-matrix.tsv`, both corrected page trees, and both image trees exist. The current PDF hashes match the PLAN Section 7 baseline:

```text
06042026.pdf     B6BD5239D642D09368E255E21064B1F48C63D075DD43F8374098300DB9ED155F
06042026_001.pdf D6BE73056B47FB9EEA9126A9EA5BC232BCF733A5562306AC2A601FA57FFC051E
```

Completeness method: scan corrected page text for command-shaped calls, exclude `Function <Name>` declarations, add the bare helper token `ArrayToString`, diff against the Phase 1 inventory, corroborate with page images, then separate PowerShell 5.1 built-ins from project-looking names. A declaration scan found no helper bodies outside the 18-name inventory, so no missed helper was safe to recover.

Decision: PROCEED and COMPLETE this cycle. I stabilized `Get-RegistryKeyPath` only. I refused to promote `Get-RegistryKeyName` and `Get-TypedObject` because their printed callees (`Get-NormalizedRegistryKeyString`, `ArrayToString`) are genuinely absent from the PDFs.

Chosen output locations: `src/Get-RegistryKeyPath.ps1`, `tests/Get-RegistryKeyPath.Tests.ps1`, `docs/recovery/GAPS.md`, `_handoff/REPORT.md`, and `_handoff/REPORT-ARCHIVE.md`.

## Completeness table

| Name | Classification | Evidence |
| --- | --- | --- |
| ArrayToString | genuinely absent from the PDFs | B:0011 image/text shows `ArrayToString -Value $Data`; no `Function ArrayToString` declaration. |
| Clear-Variable | PowerShell built-in / external | First call A:0001; `Get-Command` reports `Microsoft.PowerShell.Utility` cmdlet. |
| ConvertFrom-Json | PowerShell built-in / external | First call A:0017; `Get-Command` reports `Microsoft.PowerShell.Utility` cmdlet. |
| ConvertFrom-StringData | PowerShell built-in / external | First call B:0001; `Get-Command` reports `Microsoft.PowerShell.Utility` cmdlet. |
| ForEach-Object | PowerShell built-in / external | First call B:0010; `Get-Command` reports `Microsoft.PowerShell.Core` cmdlet. |
| Get-Item | PowerShell built-in / external | First call B:0014; `Get-Command` reports `Microsoft.PowerShell.Management` cmdlet. |
| Get-NormalizedRegistryKeyString | genuinely absent from the PDFs | B:0001/B:0008/B:0009 image/text show calls; no matching declaration. Related `Get-NormalizedRegistryKey` was not aliased. |
| Get-RegistryHive | genuinely absent from the PDFs | B:0001 image/text shows sketch name; no matching declaration. Related `Get-RegistryKeyHive` was not aliased. |
| Get-RegistryKeyString | genuinely absent from the PDFs | B:0001 image/text shows sketch name; no matching declaration. |
| Get-RegistryKeyType | genuinely absent from the PDFs | B:0003 image/text shows `Get-RegistryKeyType -Value:$RegistryKeyType`; no matching declaration. |
| Get-TargetResourceInternal | genuinely absent from the PDFs | B:0001 image/text shows sketch root; no matching declaration. |
| Measure-Object | PowerShell built-in / external | First call A:0016; `Get-Command` reports `Microsoft.PowerShell.Utility` cmdlet. |
| New-Object | PowerShell built-in / external | First call A:0016; `Get-Command` reports `Microsoft.PowerShell.Utility` cmdlet. |
| New-PSDrive | PowerShell built-in / external | First call A:0010; `Get-Command` reports `Microsoft.PowerShell.Management` cmdlet. |
| New-Variable | PowerShell built-in / external | First call A:0001; `Get-Command` reports `Microsoft.PowerShell.Utility` cmdlet. |
| Out-String | PowerShell built-in / external | First call B:0007; `Get-Command` reports `Microsoft.PowerShell.Utility` cmdlet. |
| Remove-Variable | PowerShell built-in / external | First call A:0002; `Get-Command` reports `Microsoft.PowerShell.Utility` cmdlet. |
| Select-Object | PowerShell built-in / external | First call B:0007; `Get-Command` reports `Microsoft.PowerShell.Utility` cmdlet. |
| Set-Variable | PowerShell built-in / external | First call A:0001; `Get-Command` reports `Microsoft.PowerShell.Utility` cmdlet. |
| Start-Provider | genuinely absent from the PDFs | B:0001 image/text shows sketch name; no matching declaration. Related `Start-ProviderSetup` was not aliased. |
| Test-Path | PowerShell built-in / external | First call A:0010; `Get-Command` reports `Microsoft.PowerShell.Management` cmdlet. |
| Where-Object | PowerShell built-in / external | First call B:0007; `Get-Command` reports `Microsoft.PowerShell.Core` cmdlet. |
| Write-Debug | PowerShell built-in / external | First call A:0001; `Get-Command` reports `Microsoft.PowerShell.Utility` cmdlet. |
| Write-Warning | PowerShell built-in / external | First call A:0002; `Get-Command` reports `Microsoft.PowerShell.Utility` cmdlet. |

No entries classified as `found-in-PDF` or `OCR-name-variant`.

## What changed

- Archived the prior Phase 3 report to the top of `_handoff/REPORT-ARCHIVE.md`.
- Added `src/Get-RegistryKeyPath.ps1` from B pages 0006-0007.
- Added in-memory-only `tests/Get-RegistryKeyPath.Tests.ps1`.
- Updated `docs/recovery/GAPS.md` with the completeness table, removed `Get-RegistryKeyPath` from the deferred list, and added owner-decision notes for genuinely absent helper blockers.

## What was intentionally not changed

- No PDF bytes, `_recovery/` artifacts, `PLAN.md`, `TASK.md`, or `CLAUDE-RESTART-PROMPT.md` content was edited by Codex.
- No helper alias, stub, or replacement was invented.
- `Get-RegistryKeyName`, `Get-TypedObject`, registry-touching functions, and orchestration functions remain deferred.
- No DSC audit or broad engine work was started.

## Verification output

Completeness command output:

```text
Name | Count | FirstEvidence
ArrayToString | 1 | _recovery\06042026_001\corrected\page-0011.txt:35
Clear-Variable | 21 | _recovery\06042026\corrected\page-0001.txt:41
ConvertFrom-Json | 1 | _recovery\06042026\corrected\page-0017.txt:25
ConvertFrom-StringData | 1 | _recovery\06042026_001\corrected\page-0001.txt:20
ForEach-Object | 1 | _recovery\06042026_001\corrected\page-0010.txt:43
Get-Item | 1 | _recovery\06042026_001\corrected\page-0014.txt:68
Get-NormalizedRegistryKeyString | 6 | _recovery\06042026_001\corrected\page-0001.txt:9
Get-RegistryHive | 1 | _recovery\06042026_001\corrected\page-0001.txt:10
Get-RegistryKeyString | 1 | _recovery\06042026_001\corrected\page-0001.txt:8
Get-RegistryKeyType | 1 | _recovery\06042026_001\corrected\page-0003.txt:32
Get-TargetResourceInternal | 1 | _recovery\06042026_001\corrected\page-0001.txt:6
Measure-Object | 1 | _recovery\06042026\corrected\page-0016.txt:28
New-Object | 11 | _recovery\06042026\corrected\page-0016.txt:36
New-PSDrive | 1 | _recovery\06042026\corrected\page-0010.txt:42
New-Variable | 77 | _recovery\06042026\corrected\page-0001.txt:23
Out-String | 1 | _recovery\06042026_001\corrected\page-0007.txt:29
Remove-Variable | 19 | _recovery\06042026\corrected\page-0002.txt:54
Select-Object | 1 | _recovery\06042026_001\corrected\page-0007.txt:28
Set-Variable | 125 | _recovery\06042026\corrected\page-0001.txt:60
Start-Provider | 1 | _recovery\06042026_001\corrected\page-0001.txt:7
Test-Path | 3 | _recovery\06042026\corrected\page-0010.txt:35
Where-Object | 1 | _recovery\06042026_001\corrected\page-0007.txt:27
Write-Debug | 115 | _recovery\06042026\corrected\page-0001.txt:21
Write-Warning | 1 | _recovery\06042026\corrected\page-0002.txt:29
```

Declaration scan:

```text
NO FUNCTION DECLARATIONS OUTSIDE THE 18-NAME INVENTORY
```

AST parse:

```text
PARSE OK: Convert-ByteArrayToHexString.ps1
PARSE OK: ConvertFrom-Array.ps1
PARSE OK: Get-NormalizedRegistryKey.ps1
PARSE OK: Get-RegistryKeyHive.ps1
PARSE OK: Get-RegistryKeyNameStr.ps1
PARSE OK: Get-RegistryKeyPath.ps1
PARSE OK: Get-RegistryKeyPathStr.ps1
PARSE OK: Get-RegistryValueKindStr.ps1
PARSE OK: Get-RegistryValueNameStr.ps1
PARSE OK: ThrowError.ps1
```

Pester:

```text
Discovery found 19 tests.
Tests Passed: 19, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Pester Version: 5.7.1
PSVersion: 5.1.26100.8457
```

Live-registry mutation scan:

```text
NO LIVE REGISTRY MUTATION HITS
```

Sensitive-content scan over new PowerShell files:

```text
NO SENSITIVE CONTENT HITS IN NEW src/tests PS1
```

Tracked PDF / recovery check:

```text
NO TRACKED PDF OR _recovery FILES
```

PDF hashes:

```text
06042026.pdf B6BD5239D642D09368E255E21064B1F48C63D075DD43F8374098300DB9ED155F
06042026_001.pdf D6BE73056B47FB9EEA9126A9EA5BC232BCF733A5562306AC2A601FA57FFC051E
```

Branch:

```text
recovery/phase-3-completeness
```

Diff hygiene:

```text
git diff --check exit: 0
warning: in the working copy of '_handoff/REPORT-ARCHIVE.md', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of '_handoff/REPORT.md', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of '_handoff/TASK.md', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'docs/recovery/GAPS.md', LF will be replaced by CRLF the next time Git touches it
```

Commit signing check:

```text
Good "git" signature for 33955773+NWarila@users.noreply.github.com with ECDSA key SHA256:UAsMtOhQwpR/duoYjPY3LSw4a905Dx29QPGGXCTkhGY
signature-status: G; signer: 33955773+NWarila@users.noreply.github.com; key: SHA256:UAsMtOhQwpR/duoYjPY3LSw4a905Dx29QPGGXCTkhGY
```

## Deviations from `TASK.md` and why

- No helper was recovered as `found-in-PDF` because the declaration scan found no missed function bodies outside the 18-name inventory.
- `Get-RegistryKeyPath` uses `[regex]::Match` instead of the rendered `Matches`/`MatchCollection` shape because the rendered follow-on members are `.Success` and `.Groups`; this preserves the page-image behavior in parseable PS 5.1.
- `Get-RegistryKeyPath` constructs its regex from a backslash escape variable to avoid a UNC-shaped sensitive-scan false positive while preserving the runtime pattern.

## Open objections that must be resolved before advancing

- `Get-NormalizedRegistryKeyString`, `ArrayToString`, `Get-RegistryKeyType`, and the B page 0001 sketch names are genuinely absent as helper bodies. Do not alias or replace them without an owner decision.
- Registry/orchestration functions still need an owner-approved registry test-isolation strategy.

## Owner decisions needed

- For genuinely absent helpers: needs owner decision - re-extract from PDFs, or design a replacement (do not invent).
- Owner/Claude audit this PR; owner admin-merges after audit.

Phase 3 status: COMPLETE
