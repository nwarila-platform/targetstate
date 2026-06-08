# Recovery Gaps

Phase 3 stabilized only parseable, in-memory parsing and normalization helpers. The completeness pass found no missed `Function <Name>` blocks outside the 18-name inventory. Project-looking names outside the inventory appear only as calls or B-side execution-sketch names, so no helper body was safe to recover from the PDFs this cycle.

## Called But Not Inventoried Names

| Name | Classification | Evidence |
| --- | --- | --- |
| ArrayToString | genuinely absent from the PDFs | B:0011 image/text shows `ArrayToString -Value $Data` inside `Get-TypedObject`; declaration scan found no `Function ArrayToString`. |
| Clear-Variable | PowerShell built-in / external | First call A:0001 image/text; `Get-Command Clear-Variable` -> `Microsoft.PowerShell.Utility` cmdlet. |
| ConvertFrom-Json | PowerShell built-in / external | First call A:0017 image/text; `Get-Command ConvertFrom-Json` -> `Microsoft.PowerShell.Utility` cmdlet. |
| ConvertFrom-StringData | PowerShell built-in / external | First call B:0001 image/text; `Get-Command ConvertFrom-StringData` -> `Microsoft.PowerShell.Utility` cmdlet. |
| ForEach-Object | PowerShell built-in / external | First call B:0010 image/text; `Get-Command ForEach-Object` -> `Microsoft.PowerShell.Core` cmdlet. |
| Get-Item | PowerShell built-in / external | First call B:0014 image/text; `Get-Command Get-Item` -> `Microsoft.PowerShell.Management` cmdlet. |
| Get-NormalizedRegistryKeyString | genuinely absent from the PDFs | B:0001/B:0008/B:0009 image/text show printed calls; declaration scan found no `Function Get-NormalizedRegistryKeyString`. Existing `Get-NormalizedRegistryKey` is related but not the printed name, so no alias was invented. |
| Get-RegistryHive | genuinely absent from the PDFs | B:0001 image/text shows execution-sketch name; declaration scan found no `Function Get-RegistryHive`. Existing `Get-RegistryKeyHive` is related but not the printed name, so no alias was invented. |
| Get-RegistryKeyString | genuinely absent from the PDFs | B:0001 image/text shows execution-sketch name; declaration scan found no `Function Get-RegistryKeyString`. |
| Get-RegistryKeyType | genuinely absent from the PDFs | B:0003 image/text shows `Get-RegistryKeyType -Value:$RegistryKeyType`; declaration scan found no `Function Get-RegistryKeyType`. |
| Get-TargetResourceInternal | genuinely absent from the PDFs | B:0001 image/text shows execution-sketch root; declaration scan found no `Function Get-TargetResourceInternal`. |
| Measure-Object | PowerShell built-in / external | First call A:0016 image/text; `Get-Command Measure-Object` -> `Microsoft.PowerShell.Utility` cmdlet. |
| New-Object | PowerShell built-in / external | First call A:0016 image/text; `Get-Command New-Object` -> `Microsoft.PowerShell.Utility` cmdlet. |
| New-PSDrive | PowerShell built-in / external | First call A:0010 image/text; `Get-Command New-PSDrive` -> `Microsoft.PowerShell.Management` cmdlet. |
| New-Variable | PowerShell built-in / external | First call A:0001 image/text; `Get-Command New-Variable` -> `Microsoft.PowerShell.Utility` cmdlet. |
| Out-String | PowerShell built-in / external | First call B:0007 image/text; `Get-Command Out-String` -> `Microsoft.PowerShell.Utility` cmdlet. |
| Remove-Variable | PowerShell built-in / external | First call A:0002 image/text; `Get-Command Remove-Variable` -> `Microsoft.PowerShell.Utility` cmdlet. |
| Select-Object | PowerShell built-in / external | First call B:0007 image/text; `Get-Command Select-Object` -> `Microsoft.PowerShell.Utility` cmdlet. |
| Set-Variable | PowerShell built-in / external | First call A:0001 image/text; `Get-Command Set-Variable` -> `Microsoft.PowerShell.Utility` cmdlet. |
| Start-Provider | genuinely absent from the PDFs | B:0001 image/text shows execution-sketch name; declaration scan found no `Function Start-Provider`. Existing `Start-ProviderSetup` is related but not the printed name, so no alias was invented. |
| Test-Path | PowerShell built-in / external | First call A:0010 image/text; `Get-Command Test-Path` -> `Microsoft.PowerShell.Management` cmdlet. |
| Where-Object | PowerShell built-in / external | First call B:0007 image/text; `Get-Command Where-Object` -> `Microsoft.PowerShell.Core` cmdlet. |
| Write-Debug | PowerShell built-in / external | First call A:0001 image/text; `Get-Command Write-Debug` -> `Microsoft.PowerShell.Utility` cmdlet. |
| Write-Warning | PowerShell built-in / external | First call A:0002 image/text; `Get-Command Write-Warning` -> `Microsoft.PowerShell.Utility` cmdlet. |

## Deferred Functions

| Function | Source decision | Reason |
| --- | --- | --- |
| Get-RegistryKeyHiveObj | keep_A A:0002-0004 | Calls provider setup / hive mounting flow; not pure and not safe for in-memory tests. |
| Get-RegistryKeyName | keep_B B:0007-0008 | Calls `Get-NormalizedRegistryKeyString`, which is genuinely absent from the PDFs. Needs owner decision - re-extract from PDFs, or design a replacement (do not invent). |
| Get-RegistryResourceObject | keep_B B:0009-0010 | Resource-object orchestration; depends on multiple parsed fields and broader resource semantics. |
| Get-RegistryValueData | keep_A A:0013-0015 | TASK explicitly names value-data/registry behavior for deferral; the recovered branches also intersect with typed conversion gaps. |
| Get-TargetResource | keep_B B:0013-0015 | Resource read/orchestration function, not an isolated pure parser. |
| Get-TypedObject | keep_B B:0010-0013 | In-memory-looking but incomplete: rendered pages reference `ArrayToString`, which is genuinely absent from the PDFs, plus unresolved typed exception hash variables; the author note says the type logic needs rework. Needs owner decision - re-extract from PDFs, or design a replacement (do not invent). |
| Mount-RegistryHive | keep_A A:0009-0011 | Registry provider / PSDrive side effects; excluded by Phase 3 pure-only rule. |
| Start-ProviderSetup | keep_A A:0001-0002 | Provider setup orchestration with ShouldProcess semantics; excluded by Phase 3 pure-only rule. |

## Notes

- No PDF or `_recovery/` artifact should be tracked.
- Deferred functions should be revisited only after the owner chooses whether to preserve the original quirks exactly or design corrected behavior under a new change.
