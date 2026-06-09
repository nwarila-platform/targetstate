# Flagged Decisions - Phase 6 Build 2

These items are not covered by the approved OCR / `[Type]::Empty` / enum-parse
patterns. They are intentionally NOT applied in `src/` and need owner review
before Codex changes the behavior.

## Get-RegistryKeyHiveObj - Abbreviated Hive Aliases

Printed/canonical behavior: each `Switch` comparison uses arrays shaped like
`@(, 'HKLM', 'HKEY_LOCAL_MACHINE', 'LocalMachine', '-2147483646')`. The leading
unary comma nests the first alias, so abbreviated aliases such as `HKLM` fall to
the default error path while later aliases such as `HKEY_LOCAL_MACHINE` work.

Proposed both-compatible fix: remove the leading comma in each comparison array,
for example `@('HKLM', 'HKEY_LOCAL_MACHINE', 'LocalMachine', '-2147483646')`.

Status: RESOLVED - owner-approved, applied 2026-06-09. The runnable copy now
matches abbreviated aliases, and the HKCR full-name OCR artifact is corrected in
`src/`; `recovered/canonical/` remains unchanged.

## Registry Name/Path/Value Non-Printable Validation

Affected functions:
- `Get-RegistryKeyPathStr`
- `Get-RegistryKeyNameStr`
- `Get-RegistryValueNameStr`

Printed/canonical behavior:
- `Get-RegistryKeyPathStr` tests `$KeyName` even though the parameter is
  `$KeyPath`, so the path non-printable check does not inspect the supplied path.
- The validators use the regex `\P{Cc}\p{Cn}\p{Cs}`. That does not mean
  "contains any control/unassigned/surrogate character"; it is a three-token
  sequence and does not reliably implement the comment's validation rule.

Proposed both-compatible fix: test the actual input variable and use a character
class such as `[\p{Cc}\p{Cn}\p{Cs}]`.

Status: RESOLVED - owner-approved, applied 2026-06-09. The runnable copies now
test the actual path/name/value input and use a Unicode-category character class
for non-printable validation; `recovered/canonical/` remains unchanged.

## Get-NormalizedRegistryKey - Double and Trailing Backslash Normalization

Printed/canonical behavior:
- Double-backslash detection uses `$RegistryKeyStr -contains ('\\')`, which is
  collection containment, not substring/regex matching, so doubled backslashes are
  not detected in ordinary strings.
- Trailing-backslash detection uses `.EndsWith('\')`, but the branch trims
  `'/'`, so a trailing registry backslash remains.

Proposed both-compatible fix: use `-match ('\\{2,}')` for doubled backslashes and
`TrimEnd('\')` for the trailing-backslash branch.

Status: RESOLVED - owner-approved, applied 2026-06-09. The runnable copy now uses
regex matching for doubled backslashes and trims trailing registry backslashes;
`recovered/canonical/` remains unchanged.
