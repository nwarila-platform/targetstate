# Canonical Selection by Maturity

This ledger records the corrective canonical-selection pass over the faithful
recovery. Source A is `recovered/06042026.ps1`; source B is
`recovered/06042026_001.ps1`.

Selection rule: choose one whole recovered version for each equivalent role and
archive the non-chosen version verbatim. No function text is edited, spliced,
renamed internally, completed, or parse-fixed in this pass.

## Scope Note

`TASK.md` section D asks for every function named in `docs/design/execution-map.md`
section 1 to have a canonical file. That conflicts with the A0 method, which says
equivalent A/B roles must choose one whole version and archive the other. This
ledger follows A0: every recovered function body is accounted for as either
canonical or archived, and non-chosen equivalents are not also placed in
`recovered/canonical/`.

## Selection Ledger

| Role / function | A source | B source | Choice | Canonical path | Archived path | Rationale | Owner-confirmable seam |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Error helper: `ThrowError` | none | B:44-101 | B | `recovered/canonical/ThrowError.ps1` | none | Single-source structured `ErrorRecord` throw helper; A calls the concept but has no body. | None. |
| Setup orchestrator: `Start-ProviderSetup` | A:1-121 | B:102-183 | A | `recovered/canonical/Start-ProviderSetup.ps1` | `recovered/archive/Start-ProviderSetup.from-B.ps1` | A returns a populated rich setup object and is wired by the A JSON driver; B has placeholder result fields and broken variable/parameter wiring noted in the execution-map corrections. | A's rich-object contract does not match B's public Get string contract. |
| Public/read entry: `Get-TargetResource` | A:658-801 | B:780-918 | A | `recovered/canonical/Get-TargetResource.ps1` | `recovered/archive/Get-TargetResource.from-B.ps1` | A interoperates with A `Start-ProviderSetup` and the A JSON driver; B has the better resource-shaped output, but depends on the broken B setup/string seam. | Owner may still prefer B's `Ensure/Key/ValueName/ValueKind/ValueData` evidence shape for the later build. |
| Hive normalizer | A `Get-RegistryKeyHiveObj`:122-227 | B `Get-RegistryKeyHive`:280-357 | A | `recovered/canonical/Get-RegistryKeyHiveObj.ps1` | `recovered/archive/Get-RegistryKeyHive.from-B.ps1` | A returns the `{Name,ShortName,Abbreviation}` descriptor that A `Mount-RegistryHive` consumes; B's long-form string shape is incompatible with that mount helper. | Decide rich hive descriptor versus canonical long-form string before implementation resumes. |
| Key-path helper | A `Get-RegistryKeyPathStr`:228-325 | B `Get-RegistryKeyPath`:358-419 | A | `recovered/canonical/Get-RegistryKeyPathStr.ps1` | `recovered/archive/Get-RegistryKeyPath.from-B.ps1` | A validates the already-separated path field used by the selected A setup contract; B extracts a path from the alternate full-key contract. | If owner restores B's full-key input contract, B's extractor may be the better implementation seed. |
| Key-name helper | A `Get-RegistryKeyNameStr`:326-402 | B `Get-RegistryKeyName`:420-483 | A | `recovered/canonical/Get-RegistryKeyNameStr.ps1` | `recovered/archive/Get-RegistryKeyName.from-B.ps1` | A validates the already-separated name field used by the selected A setup contract; B extracts a name from the alternate full-key contract and calls missing `Get-NormalizedRegistryKeyString`. | Same input-shape decision as the path helper. |
| Value-name helper: `Get-RegistryValueNameStr` | A:403-469 | none | A | `recovered/canonical/Get-RegistryValueNameStr.ps1` | none | Single-source value-name validator, including empty default-value support. | None. |
| Value-kind helper: `Get-RegistryValueKindStr` | A:470-568 | no recovered body for `Get-RegistryKeyType` | A | `recovered/canonical/Get-RegistryValueKindStr.ps1` | none | Single recovered value-kind normalizer; B references `Get-RegistryKeyType`, but no function body exists to compare or archive. | Later design must decide whether the B reference is a rename drift or a distinct intended helper. |
| Hive mount: `Mount-RegistryHive` | A:569-656 | none | A | `recovered/canonical/Mount-RegistryHive.ps1` | none | Single recovered mount helper and the only side-effect implementation. | It currently expects A's rich hive descriptor. |
| Value-data coercer | A `Get-RegistryValueData`:803-939 | B `Get-TypedObject`:593-779 | B | `recovered/canonical/Get-TypedObject.ps1` | `recovered/archive/Get-RegistryValueData.from-A.ps1` | B has broader typed and `-Hex` branch coverage despite being owner-flagged unfinished; A has more empty DWord/QWord/Binary stubs. | B still needs missing exception-hash statics and a corrected array guard in a later owner-gated build step. |
| Array/string display helper: `ConvertFrom-Array` | A:940-1025 | missing `ArrayToString` call only | A | `recovered/canonical/ConvertFrom-Array.ps1` | none | Single recovered array-flatten helper; B's `ArrayToString` is a missing reference, not an archiveable body. | Decide whether later code should keep this name or satisfy the B call name. |
| Binary display helper: `Convert-ByteArrayToHexString` | none | B:553-592 | B | `recovered/canonical/Convert-ByteArrayToHexString.ps1` | none | Single recovered byte-array-to-hex helper. | None. |
| Full-key pre-normalizer: `Get-NormalizedRegistryKey` | none | B:185-279 | B | `recovered/canonical/Get-NormalizedRegistryKey.ps1` | none | Single recovered full-key pre-normalizer; useful evidence for the alternate full-key path even though A's separated-field path is selected. | Later design must reconcile this with B's missing `Get-NormalizedRegistryKeyString` calls. |
| Full-key composer: `Get-RegistryResourceObject` | none | B:485-552 | B | `recovered/canonical/Get-RegistryResourceObject.ps1` | none | Single recovered composer for `Hive\Path\Name`; retained because it may be the header's intended `Get-RegistryKeyString` stage. | Decide whether this orphaned function is wired into setup or retired. |

## Body Accounting

All 20 recovered function bodies are accounted for:

| Source body | Disposition |
| --- | --- |
| A:1-121 `Start-ProviderSetup` | canonical |
| A:122-227 `Get-RegistryKeyHiveObj` | canonical |
| A:228-325 `Get-RegistryKeyPathStr` | canonical |
| A:326-402 `Get-RegistryKeyNameStr` | canonical |
| A:403-469 `Get-RegistryValueNameStr` | canonical |
| A:470-568 `Get-RegistryValueKindStr` | canonical |
| A:569-656 `Mount-RegistryHive` | canonical |
| A:658-801 `Get-TargetResource` | canonical |
| A:803-939 `Get-RegistryValueData` | archive |
| A:940-1025 `ConvertFrom-Array` | canonical |
| B:44-101 `ThrowError` | canonical |
| B:102-183 `Start-ProviderSetup` | archive |
| B:185-279 `Get-NormalizedRegistryKey` | canonical |
| B:280-357 `Get-RegistryKeyHive` | archive |
| B:358-419 `Get-RegistryKeyPath` | archive |
| B:420-483 `Get-RegistryKeyName` | archive |
| B:485-552 `Get-RegistryResourceObject` | canonical |
| B:553-592 `Convert-ByteArrayToHexString` | canonical |
| B:593-779 `Get-TypedObject` | canonical |
| B:780-918 `Get-TargetResource` | archive |
