# Recovery Gaps

Phase 3 stabilized only parseable, in-memory parsing and normalization helpers. The following recovered functions remain deferred because promoting them would require registry access, orchestration, or inventing behavior beyond the page images.

## Deferred Functions

| Function | Source decision | Reason |
| --- | --- | --- |
| Get-RegistryKeyHiveObj | keep_A A:0002-0004 | Calls provider setup / hive mounting flow; not pure and not safe for in-memory tests. |
| Get-RegistryKeyPath | keep_B B:0006-0007 | Pure-looking, but the recovered regex text is ambiguous and paired with a key-name extraction path that references a missing normalized-key helper. Deferred rather than normalizing by guesswork. |
| Get-RegistryKeyName | keep_B B:0007-0008 | Calls `Get-NormalizedRegistryKeyString`, which is not one of the recovered functions; introducing an alias or changing the callee would invent behavior. |
| Get-RegistryResourceObject | keep_B B:0009-0010 | Resource-object orchestration; depends on multiple parsed fields and broader resource semantics. |
| Get-RegistryValueData | keep_A A:0013-0015 | TASK explicitly names value-data/registry behavior for deferral; the recovered branches also intersect with typed conversion gaps. |
| Get-TargetResource | keep_B B:0013-0015 | Resource read/orchestration function, not an isolated pure parser. |
| Get-TypedObject | keep_B B:0010-0013 | In-memory-looking but incomplete: rendered pages reference missing helper names / exception hash variables (`ArrayToString`, typed exception hashes) and the author note says the type logic needs rework. Deferred to avoid inventing missing branches. |
| Mount-RegistryHive | keep_A A:0009-0011 | Registry provider / PSDrive side effects; excluded by Phase 3 pure-only rule. |
| Start-ProviderSetup | keep_A A:0001-0002 | Provider setup orchestration with ShouldProcess semantics; excluded by Phase 3 pure-only rule. |

## Notes

- No PDF or `_recovery/` artifact should be tracked.
- Deferred functions should be revisited only after the owner chooses whether to preserve the original quirks exactly or design corrected behavior under a new change.
