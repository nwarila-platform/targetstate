# DSC Port/Adapt/Skip Checklist

Phase 4b synthesis artifact. This checklist is derived from `docs/dsc-audit/AUDIT.md` and does not create TargetState design decisions, ADR content, source, tests, or `.mof` files.

| surface | verdict | concrete-next-action | target-phase |
| --- | --- | --- | --- |
| Configuration keyword | replace with TargetState-native | Draft the declaration-document format ADR for TargetState-native YAML-style documents and explicitly exclude the DSC `Configuration` keyword and MOF compilation boundary. | Phase 5 |
| Get-DscResource | adapt conceptually | Include TargetState resource discovery, schema or syntax metadata, and module loading expectations in the resource contract ADR. | Phase 5 |
| Invoke-DscResource | adapt conceptually | Draft the resource operation contract for direct Get, Test, and Set dispatch with TargetState-owned evidence output. | Phase 5 |
| Start-DscConfiguration | replace with TargetState-native | Draft the mutation and ShouldProcess safety ADR for plan and apply execution from declaration documents, with apply mode remaining owner-gated. | Phase 5 |
| Test-DscConfiguration | adapt conceptually | Include desired-vs-actual test semantics and detailed resource results in the resource contract and evidence ADRs. | Phase 5 |
| Get-DscConfiguration | adapt conceptually | Include resource-level current-state Get results in the resource contract ADR, without relying on an LCM configuration store. | Phase 5 |
| Get-DscConfigurationStatus | adapt conceptually | Draft the evidence and reporting model ADR for structured run summaries and per-resource status. | Phase 5 |
| Publish-DscConfiguration | explicitly skip | no action (out of scope) | none |
| Stop-DscConfiguration | explicitly skip | no action (out of scope) | none |
| Restore-DscConfiguration | explicitly skip | no action (out of scope) | none |
| Update-DscConfiguration | explicitly skip | no action (out of scope) | none |
| New-DscChecksum | explicitly skip | no action (out of scope) | none |
| Get-DscLocalConfigurationManager | explicitly skip | no action (out of scope) | none |
| Set-DscLocalConfigurationManager | explicitly skip | no action (out of scope) | none |
| Enable-DscDebug | explicitly skip | no action (out of scope) | none |
| Disable-DscDebug | explicitly skip | no action (out of scope) | none |
| Remove-DscConfigurationDocument | explicitly skip | no action (out of scope) | none |
| DSC resource contract conventions | adapt conceptually | Draft the TargetState resource contract ADR around Get, Test, Set, idempotence, `Ensure`, typed properties, and explicit evidence output while avoiding mandatory MOF schema. | Phase 5 |
| Resource discovery/module loading | adapt conceptually | Include TargetState module packaging, resource discovery, and schema exposure in the resource contract ADR. | Phase 5 |
| LCM responsibilities | replace with TargetState-native | Draft TargetState runner responsibilities in the mutation and ShouldProcess safety ADR, replacing the DSC LCM service model. | Phase 5 |
| MOF compilation vs runtime boundary | replace with TargetState-native | Draft declaration-document parsing and validation responsibilities so TargetState consumes human-readable documents directly, without generated MOF. | Phase 5 |
| Reporting/status behavior | adapt conceptually | Draft explicit evidence files or command output for current, test, and apply results in the evidence and reporting ADR. | Phase 5 |
| Checksums/pull server/publishing | explicitly skip | no action (out of scope) | none |
| Cross-platform DSC v3 direction context-only | defer until after Registry proof | Revisit only after the Phase 6 Registry proof validates the local TargetState contract, then decide whether DSC v3 context changes the roadmap. | Post-Phase 6 |
