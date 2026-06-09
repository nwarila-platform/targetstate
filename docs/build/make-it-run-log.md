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

## Phase 6 Build 2 - ThrowError

Source: `recovered/canonical/ThrowError.ps1`

Runnable copy: `src/ThrowError.ps1`

| Canonical token | Running token | Class | Evidence |
| --- | --- | --- | --- |
| leading `,` before first `CmdletBinding` argument | no leading separator | i | Page image `_recovery/06042026_001/images/page-0001.png` / provenance show separator cleanup in metadata; first attribute argument cannot begin with `,` in runnable PowerShell. |
| `;  PositionalBinding = $True` | `,  PositionalBinding = $True` | i | Same metadata separator OCR class as above; semicolon breaks the attribute argument list. |
| leading `;` / leading `,` before first `Parameter` argument | no leading separator | i | Page image/provenance for B page 0001 show parameter metadata separator cleanup; first attribute argument cannot begin with a separator. |

## Phase 6 Build 2 - Get-RegistryKeyHiveObj

Source: `recovered/canonical/Get-RegistryKeyHiveObj.ps1`

Runnable copy: `src/Get-RegistryKeyHiveObj.ps1`

| Canonical token | Running token | Class | Evidence |
| --- | --- | --- | --- |
| `[Hashtable]::Empty` | `@{}` | ii | Approved owner idiom table in `docs/build/owner-idiom-decisions.md`. |
| `[Hashtable]a{` | `[Hashtable]@{` | i | Page image `_recovery/06042026/images/page-0003.png` / provenance record `a{` -> `@{` hashtable correction. |
| `-ErrorCategory: 'InvalidArgument '` | `-ErrorCategory: 'InvalidArgument'` | i | Page image `_recovery/06042026/images/page-0004.png` shows no trailing space in the enum token. |
| blank line inside the backtick-continued `ThrowError` call | no blank line | i | Page image `_recovery/06042026/images/page-0004.png` shows one continuous `ThrowError` call. |
| `$LocalizedData. InvalidRegistryHiveSpecified` | `$LocalizedData.InvalidRegistryHiveSpecified` | i | Page image `_recovery/06042026/images/page-0004.png` shows contiguous property access. |

## Phase 6 Build 2 - Get-RegistryKeyPathStr

Source: `recovered/canonical/Get-RegistryKeyPathStr.ps1`

Runnable copy: `src/Get-RegistryKeyPathStr.ps1`

| Canonical token | Running token | Class | Evidence |
| --- | --- | --- | --- |
| `[System.Boolean]::Empty` initializers | `$False` | ii | Approved owner idiom table in `docs/build/owner-idiom-decisions.md`. |
| `Clear-Variable ... -Name:(@( ... )` | `Clear-Variable ... -Name:(@( ... ))` | i | Page image `_recovery/06042026/images/page-0004.png` shows the closing `))`. |
| `$NormalizedKeypath[@]` | `$NormalizedKeypath[0]` | i | Page image `_recovery/06042026/images/page-0005.png` shows index `[0]`; `@` is an OCR zero/at-sign confusion. |
| `\p{cs}` | `\p{Cs}` | i | Page image `_recovery/06042026/images/page-0005.png` shows Unicode category `Cs`; lowercase `cs` does not compile in .NET regex. |

## Phase 6 Build 2 - Get-RegistryKeyNameStr

Source: `recovered/canonical/Get-RegistryKeyNameStr.ps1`

Runnable copy: `src/Get-RegistryKeyNameStr.ps1`

| Canonical token | Running token | Class | Evidence |
| --- | --- | --- | --- |
| `[System.Boolean]::Empty` initializers | `$False` | ii | Approved owner idiom table in `docs/build/owner-idiom-decisions.md`. |
| `'System.ArgumentException''` | `'System.ArgumentException'` | i | Page image `_recovery/06042026/images/page-0006.png` shows one trailing apostrophe. |
| `$kKeyName` | `$KeyName` | i | Page image `_recovery/06042026/images/page-0006.png` shows `$KeyName`. |
| `:   -ExceptionMessage` | `-ExceptionMessage` | i | Page image `_recovery/06042026/images/page-0006.png` shows the parameter line without the leading colon artifact. |
| missing close brace after the second `ThrowError` block | `}` inserted | i | Page image `_recovery/06042026/images/page-0006.png` shows the `If` block closes before the result assignment. |

## Phase 6 Build 2 - Get-RegistryValueNameStr

Source: `recovered/canonical/Get-RegistryValueNameStr.ps1`

Runnable copy: `src/Get-RegistryValueNameStr.ps1`

| Canonical token | Running token | Class | Evidence |
| --- | --- | --- | --- |
| `,,  Position = 0` | `,  Position = 0` | i | Provenance for A page 0007 records comma/guillemet metadata cleanup; doubled comma breaks the attribute argument list. |
| `[System.Boolean]::Empty` | `$False` | ii | Approved owner idiom table in `docs/build/owner-idiom-decisions.md`. |
| `-ExceptionObject :$ValueName` | `-ExceptionObject:$ValueName` | i | Matches the colon-parameter form used throughout the recovered source; the space splits the parameter binding. |
| `\p{cs}` | `\p{Cs}` | i | Same Unicode-category casing correction as `Get-RegistryKeyPathStr`; lowercase `cs` does not compile in .NET regex. |

## Phase 6 Build 2 - Get-NormalizedRegistryKey

Source: `recovered/canonical/Get-NormalizedRegistryKey.ps1`

Runnable copy: `src/Get-NormalizedRegistryKey.ps1`

| Canonical token | Running token | Class | Evidence |
| --- | --- | --- | --- |
| `Param( ; \`` | `Param(` | i | Page image `_recovery/06042026_001/images/page-0004.png` shows a plain `Param(` opener. |
| `''Result` | `'Result'` | i | Standard doubled-apostrophe OCR artifact; the canonical token keeps the string open and breaks runtime parsing. |
| `''HasDoubleSlashes` | `'HasDoubleSlashes'` | i | Same doubled-apostrophe OCR artifact. |
| stranded prose lines `the`, `tracing.`, `about`, `specific` | comment-prefixed prose lines | iii | Page images `_recovery/06042026_001/images/page-0004.png` and page 0005 show print-wrapped prose; without `#`, PowerShell executes them as commands. No logic token changed. |

## Phase 6 Build 2 - ConvertFrom-Array

Source: `recovered/canonical/ConvertFrom-Array.ps1`

Runnable copy: `src/ConvertFrom-Array.ps1`

| Canonical token | Running token | Class | Evidence |
| --- | --- | --- | --- |
| `[System.Int32]::Empty` | `0` | ii | Approved owner idiom table in `docs/build/owner-idiom-decisions.md`. |
| `ae = $StringBuilder.Append(...)` | `$NULL = $StringBuilder.Append(...)` | i | Page image `_recovery/06042026/images/page-0016.png` shows `$Null =`. |
| `'{0},  '` | `'{0}, '` | i | Page image `_recovery/06042026/images/page-0016.png` and the adjacent comment show a two-character `, ` delimiter. |
| `} End` | `} End {` | i | Page image `_recovery/06042026/images/page-0016.png` shows the `End` block opener. |
| leading `;` before `$NULL = $StringBuilder.Remove(...)` | no leading `;` | iii | Smallest parser-safe block form after restoring `End {`; no behavior token changed. |

## Phase 6 Build 2 - Convert-ByteArrayToHexString

Source: `recovered/canonical/Convert-ByteArrayToHexString.ps1`

Runnable copy: `src/Convert-ByteArrayToHexString.ps1`

| Canonical token | Running token | Class | Evidence |
| --- | --- | --- | --- |
| `g$Result += [String]::Format(...)` | `$Result += [String]::Format(...)` | i | Page image `_recovery/06042026_001/images/page-0010.png` shows `$Result +=`; `g` is an OCR glyph artifact. |

## Phase 6 Build 3 - Applied Owner-Approved Flagged Fixes

Source record: `recovered/canonical/` remains unchanged.

Runnable copies: scoped `src/` functions only.

| Function | Before | After | Class | Evidence |
| --- | --- | --- | --- | --- |
| `Get-RegistryKeyHiveObj` | six switch comparison arrays shaped `@(,  'HKCR', ...)` | six arrays shaped `@('HKCR', ...)` | owner-approved behavior fix | `docs/build/flagged-decisions.md`; owner approved applying the flagged fix on 2026-06-09. |
| `Get-RegistryKeyHiveObj` | `'HKEY_CLASSES ROOT'` | `'HKEY_CLASSES_ROOT'` | owner-approved OCR artifact fix | `docs/build/flagged-decisions.md`; TASK Build 3 A0 names the HKCR missing underscore correction. |
| `Get-RegistryKeyPathStr` | `$KeyName -match  '\P{Cc}\p{Cn}\p{Cs}'` | `$KeyPath -match  '[\p{Cc}\p{Cn}\p{Cs}]'` | owner-approved behavior fix | `docs/build/flagged-decisions.md`; the approved fix tests the actual parameter and uses a character class. |
| `Get-RegistryKeyNameStr` | `$KeyName -match  '\P{Cc}\p{Cn}\p{Cs}'` | `$KeyName -match  '[\p{Cc}\p{Cn}\p{Cs}]'` | owner-approved behavior fix | `docs/build/flagged-decisions.md`; the approved fix uses a character class. |
| `Get-RegistryValueNameStr` | `$ValueName -match  '\P{Cc}\p{Cn}\p{Cs}'` | `$ValueName -match  '[\p{Cc}\p{Cn}\p{Cs}]'` | owner-approved behavior fix | `docs/build/flagged-decisions.md`; the approved fix uses a character class. |
| `Get-NormalizedRegistryKey` | `$RegistryKeyStr -contains ('\\')` | `$RegistryKeyStr -match ('\\{2,}')` | owner-approved behavior fix | `docs/build/flagged-decisions.md`; the approved fix uses regex matching for doubled backslashes. |
| `Get-NormalizedRegistryKey` | `$RegistryKeyStr.TrimEnd('/')` | `$RegistryKeyStr.TrimEnd('\')` | owner-approved behavior fix | `docs/build/flagged-decisions.md`; the approved fix trims trailing registry backslashes. |
