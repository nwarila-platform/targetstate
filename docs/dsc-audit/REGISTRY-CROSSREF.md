# Registry Gap Cross-Reference

This file maps every item in `docs/recovery/GAPS.md` to the audited DSC surfaces. It is a cross-reference only and does not authorize porting, replacement helper design, or live registry tests.

## Called But Not Inventoried Names

| gap-id | gap-description | related-surface(s) | does-DSC-address-it | note |
| --- | --- | --- | --- | --- |
| C01 | ArrayToString is genuinely absent from the PDFs. | DSC resource contract conventions, Invoke-DscResource | partial | DSC direct method calls and resource contracts require typed property handling, but Microsoft DSC does not provide this recovered helper body. |
| C02 | Clear-Variable is a PowerShell built-in or external command. | none | no | Outside the DSC surface; no TargetState DSC decision needed. |
| C03 | ConvertFrom-Json is a PowerShell built-in or external command. | none | no | Outside the DSC surface; no TargetState DSC decision needed. |
| C04 | ConvertFrom-StringData is a PowerShell built-in or external command. | none | no | Outside the DSC surface; no TargetState DSC decision needed. |
| C05 | ForEach-Object is a PowerShell built-in or external command. | none | no | Outside the DSC surface; no TargetState DSC decision needed. |
| C06 | Get-Item is a PowerShell built-in or external command. | none | no | Outside the DSC surface; no TargetState DSC decision needed. |
| C07 | Get-NormalizedRegistryKeyString is genuinely absent from the PDFs. | DSC resource contract conventions, Invoke-DscResource, Resource discovery/module loading | partial | DSC has Registry resource conventions and direct resource invocation, but it does not supply the recovered helper name. |
| C08 | Get-RegistryHive is genuinely absent from the PDFs. | Resource discovery/module loading, Get-DscResource | partial | DSC can discover a Registry resource, but this execution-sketch helper body is absent. |
| C09 | Get-RegistryKeyString is genuinely absent from the PDFs. | Resource discovery/module loading, Get-DscResource | partial | DSC can expose Registry resource schema, but this recovered helper body is absent. |
| C10 | Get-RegistryKeyType is genuinely absent from the PDFs. | DSC resource contract conventions, Invoke-DscResource | partial | DSC schema/property validation is relevant, but no Microsoft DSC surface provides this helper body. |
| C11 | Get-TargetResourceInternal is genuinely absent from the PDFs. | DSC resource contract conventions, Invoke-DscResource | partial | DSC defines external Get/Test/Set conventions, not this internal helper. |
| C12 | Measure-Object is a PowerShell built-in or external command. | none | no | Outside the DSC surface; no TargetState DSC decision needed. |
| C13 | New-Object is a PowerShell built-in or external command. | none | no | Outside the DSC surface; no TargetState DSC decision needed. |
| C14 | New-PSDrive is a PowerShell built-in or external command. | none | no | Outside the DSC surface; no TargetState DSC decision needed. |
| C15 | New-Variable is a PowerShell built-in or external command. | none | no | Outside the DSC surface; no TargetState DSC decision needed. |
| C16 | Out-String is a PowerShell built-in or external command. | none | no | Outside the DSC surface; no TargetState DSC decision needed. |
| C17 | Remove-Variable is a PowerShell built-in or external command. | none | no | Outside the DSC surface; no TargetState DSC decision needed. |
| C18 | Select-Object is a PowerShell built-in or external command. | none | no | Outside the DSC surface; no TargetState DSC decision needed. |
| C19 | Set-Variable is a PowerShell built-in or external command. | none | no | Outside the DSC surface; no TargetState DSC decision needed. |
| C20 | Start-Provider is genuinely absent from the PDFs. | LCM responsibilities, Resource discovery/module loading | partial | DSC has engine/provider orchestration concepts, but this recovered sketch helper body is absent and must not be invented. |
| C21 | Test-Path is a PowerShell built-in or external command. | none | no | Outside the DSC surface; no TargetState DSC decision needed. |
| C22 | Where-Object is a PowerShell built-in or external command. | none | no | Outside the DSC surface; no TargetState DSC decision needed. |
| C23 | Write-Debug is a PowerShell built-in or external command. | none | no | Outside the DSC surface; no TargetState DSC decision needed. |
| C24 | Write-Warning is a PowerShell built-in or external command. | none | no | Outside the DSC surface; no TargetState DSC decision needed. |

## Deferred Functions

| gap-id | gap-description | related-surface(s) | does-DSC-address-it | note |
| --- | --- | --- | --- | --- |
| D01 | Get-RegistryKeyHiveObj calls provider setup or hive mounting flow. | LCM responsibilities, Get-DscLocalConfigurationManager, Set-DscLocalConfigurationManager | partial | DSC's LCM owns node orchestration, but TargetState must define its own safe runner before this function can move. |
| D02 | Get-RegistryKeyName calls absent Get-NormalizedRegistryKeyString. | DSC resource contract conventions, Invoke-DscResource | partial | DSC conventions inform key property normalization, but do not resolve the missing helper. |
| D03 | Get-RegistryResourceObject is resource-object orchestration. | Get-DscResource, Test-DscConfiguration, Get-DscConfigurationStatus, Reporting/status behavior | partial | DSC surfaces show schema/status patterns that can inform TargetState evidence, but no direct port is safe. |
| D04 | Get-RegistryValueData intersects value-data and typed conversion gaps. | DSC resource contract conventions, Invoke-DscResource | partial | DSC property schemas and direct Set/Test/Get calls inform typed value handling, but helper design remains TargetState work. |
| D05 | Get-TargetResource is resource read and evidence orchestration. | Get-DscConfiguration, Invoke-DscResource, Test-DscConfiguration, DSC resource contract conventions | partial | DSC defines the Get/Test/Set contract shape, but TargetState needs its own evidence return shape. |
| D06 | Get-TypedObject references absent ArrayToString and unresolved typed exception variables. | DSC resource contract conventions, Invoke-DscResource | partial | DSC property typing is relevant, but Microsoft DSC does not recover the missing helper or exception hash semantics. |
| D07 | Mount-RegistryHive has Registry provider or PSDrive side effects. | LCM responsibilities, Set-DscLocalConfigurationManager | partial | DSC has node orchestration, but safe registry test isolation is still owner-gated for TargetState. |
| D08 | Start-ProviderSetup is provider setup orchestration with ShouldProcess semantics. | LCM responsibilities, Resource discovery/module loading, Get-DscResource | partial | DSC concepts explain provider orchestration, but TargetState must design its own setup and ShouldProcess safety. |
