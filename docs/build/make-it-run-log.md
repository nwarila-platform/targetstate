# Make-It-Run Log - Get-RegistryValueKindStr

Source: `recovered/canonical/Get-RegistryValueKindStr.ps1`

Runnable copy: `src/Get-RegistryValueKindStr.ps1`

Classification key:
- `i` = OCR-artifact correction.
- `ii` = idiom mapping.
- `iii` = minimal parse fix.

| Canonical location | Canonical token | Running token | Class | Evidence |
| --- | --- | --- | --- | --- |
| lines 22, 23 | `[System.Boolean]::Empty` | `$False` | ii | Owner idiom proposal in `docs/build/owner-idiom-decisions.md`; page image `_recovery/06042026/images/page-0008.png` confirms the printed `::Empty` idiom. |
| lines 24-25 | line-wrapped `-` + `Value:` | single logical `-Value:` token | iii | Page image `_recovery/06042026/images/page-0008.png` confirms the printed token wraps across lines. A backtick continuation parsed but did not bind at runtime, so the smallest reliable PowerShell fix is restoring the split parameter name to one `-Value:` token. |
| line 25 | `[Microsoft.Win32.RegistryValueKind]::Empty` | `[Microsoft.Win32.RegistryValueKind]::None` | ii | Owner idiom proposal in `docs/build/owner-idiom-decisions.md`; `None` is already used by this function for empty input on lines 44-46. |
| lines 26-27 | line-wrapped `-` + `Value:` | single logical `-Value:` token | iii | Page image `_recovery/06042026/images/page-0008.png` confirms the printed token wraps across lines. A backtick continuation parsed but did not bind at runtime, so the smallest reliable PowerShell fix is restoring the split parameter name to one `-Value:` token. |
| line 27 | `[Microsoft.Win32.RegistryValueKind]::Empty` | `[Microsoft.Win32.RegistryValueKind]::None` | ii | Owner idiom proposal in `docs/build/owner-idiom-decisions.md`; initializer is overwritten before use in the Process block. |
| lines 28-29 | line-wrapped `-` + `Value:` | single logical `-Value:` token | iii | Page image `_recovery/06042026/images/page-0008.png` confirms the printed token wraps across lines. A backtick continuation parsed but did not bind at runtime, so the smallest reliable PowerShell fix is restoring the split parameter name to one `-Value:` token. |
| line 29 | `[Microsoft.Win32.RegistryValueKind]::Empty` | `[Microsoft.Win32.RegistryValueKind]::None` | ii | Owner idiom proposal in `docs/build/owner-idiom-decisions.md`; initializer is overwritten before soft return. |
| before canonical line 49 | no immediate reinitialization after `Clear-Variable` | `Set-Variable -Name: 'NormalizedValueKind' -Value:([Microsoft.Win32.RegistryValueKind]::None)` before `TryParse` | iii | Windows PowerShell 5.1 needs the by-ref target to already carry the enum type before the enum-type generic `TryParse` can bind. The value is overwritten by successful parse or the function throws on invalid parse. |
| lines 51-55 | `[Enum]::TryParse([Microsoft.Win32.RegistryValueKind], $ValueKind, [Ref ]$NormalizedValueKind)` | `[Microsoft.Win32.RegistryValueKind]::TryParse($ValueKind, [Ref ]$NormalizedValueKind)` | iii | Windows PowerShell 5.1 could not bind the printed non-generic `[Enum]::TryParse` form, and PS 5.1 cannot call generic static methods with type-argument syntax. Calling `TryParse` on the enum type is the smallest runnable form found; it keeps `TryParse` and preserves case-sensitive behavior. |

No class `i` OCR-artifact correction was applied in this calibration. The page
images show the relevant tokens as printed; the runnable-source changes are the
proposed owner idiom mapping plus minimal PS 5.1 fixes for wrapped parameter
names and the callable `TryParse` form.
