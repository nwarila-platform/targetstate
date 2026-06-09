# Owner Idiom Decisions - Proposed

Status: PROPOSED for owner review. Do not apply these mappings beyond
`src/Get-RegistryValueKindStr.ps1` until the owner approves or revises them.

The faithful recovered code uses `New-Variable ... -Value:([Type]::Empty)` as an
initializer idiom. Only `[System.String]::Empty` is a real .NET member in the
observed set. The make-it-run copy needs concrete defaults that preserve the
evident "placeholder, overwritten later" intent without changing surrounding
logic.

| Faithful idiom | Proposed running default | Rationale |
| --- | --- | --- |
| `[System.String]::Empty` | `[System.String]::Empty` | Already valid and expresses an empty string. |
| `[System.Boolean]::Empty` | `$False` | Boolean placeholder with the least surprising falsey default; matches the owner's `$True`/`$False` casing. |
| `[Microsoft.Win32.RegistryValueKind]::Empty` | `[Microsoft.Win32.RegistryValueKind]::None` | Valid enum member already used by `Get-RegistryValueKindStr` for empty input; neutral for an initializer that is overwritten before meaningful use. |
| `[System.Int32]::Empty` | `0` | Numeric placeholder; common zero value and PS 5.1 native. |
| `[Hashtable]::Empty` | `@{}` | Empty mutable hashtable value; no nonexistent static member. |
| `[PSCustomObject]::Empty` | `$Null` | Placeholder object absence; avoids inventing properties before the code populates the object. |
| array-type `::Empty` idioms | `@()` | Empty array placeholder where the variable is used as a collection. |

Applied in this calibration:
- `[System.Boolean]::Empty` -> `$False` for `ValueKindIsNullorEmpty`.
- `[System.Boolean]::Empty` -> `$False` for `IsValidValueKind`.
- `[Microsoft.Win32.RegistryValueKind]::Empty` -> `[Microsoft.Win32.RegistryValueKind]::None` for `NormalizedValueKind`.
- `[Microsoft.Win32.RegistryValueKind]::Empty` -> `[Microsoft.Win32.RegistryValueKind]::None` for `ValueKindIsUnknown`.
- `[Microsoft.Win32.RegistryValueKind]::Empty` -> `[Microsoft.Win32.RegistryValueKind]::None` for `Result`.
