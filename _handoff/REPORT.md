Phase/Task status: NEEDS-OWNER

## Adversarial review verdict

Goal: execute the corrective faithful source reconstruction on branch `recovery/faithful-source-rebuild` and publish a PR to `main` containing verbatim recovered owner source from both PDFs under `recovered/`, with all Codex notes in provenance sidecars and no `src/` or `tests/` changes.

Decision: PROCEED with publication for owner review, but do not mark COMPLETE. The sensitive-content gate is clean and the 18-function coverage requirement is met. However, OCR-risk patterns remain outside the image-backed fixes made in this continuation, so fidelity still needs owner review before the project advances.

Branch check: PROCEED on `recovery/faithful-source-rebuild`, not `main`.

Image input check: PROCEED. `_recovery/06042026/images/*.png` has 17 page images and `_recovery/06042026_001/images/*.png` has 16 page images. The page images were treated as authority for the corrections made in this pass.

Fidelity contract restated: this is transcription, not stabilization. Preserve Begin/Process/End blocks, `New-Variable -Force -Option:'Private'` declarations, colon-parameter syntax, comments including typos, owner casing, soft-return patterns, order, spacing, and printed APIs. Do not refactor, normalize to preferred PowerShell, run-fix, collapse blocks, rename variables, remove comments/declarations, swap APIs, add tests, touch live Windows state, edit `src/`/`tests/`, or modify PDFs/_recovery inputs.

Chosen output location: `recovered/06042026.ps1`, `recovered/06042026_001.ps1`, `recovered/06042026.provenance.md`, `recovered/06042026_001.provenance.md`, `.gitignore`, `_handoff/REPORT.md`, and `_handoff/REPORT-ARCHIVE.md`.

## What changed

- Archived the prior NEEDS-OWNER faithful-reconstruction report to the top of `_handoff/REPORT-ARCHIVE.md`.
- Preserved the existing best-effort `recovered/` reconstruction draft and provenance sidecars.
- Corrected the page-0006 `Get-RegistryKeyPath` regex in `recovered/06042026_001.ps1` from the rendered page image; this also removed the earlier sensitive-scan false positive.
- Corrected image-backed OCR misses in the `ThrowError` spot-check: `$ExceptionMessage`, `$ErrorId`, one doubled comma, and contiguous `System.Management.Automation` type names.
- Corrected image-backed OCR misses in the `Get-RegistryValueKindStr` spot-check: split `-Value:` glyphs, no-space `Value:(...)`, and `IsNullOrWhiteSpace` casing.
- Added `!/recovered/` to `.gitignore` so the recovered source tree is deliberately trackable.

## What was intentionally not changed

- No `src/` or `tests/` files were changed.
- No PDFs or `_recovery/` files were modified.
- No live registry or Windows system state was touched.
- No parse/Pester checks were run; this task explicitly prioritizes fidelity over runnability.
- `PLAN.md`, `TASK.md`, and `CLAUDE-RESTART-PROMPT.md` were not edited by Codex; pre-existing planner/handoff edits are preserved as-is for durability.

## Verification output

Coverage:

```text
06042026.ps1
  Start-ProviderSetup
  Get-RegistryKeyHiveObj
  Get-RegistryKeyPathStr
  Get-RegistryKeyNameStr
  Get-RegistryValueNameStr
  Get-RegistryValueKindStr
  Mount-RegistryHive
  Get-TargetResource
  Get-RegistryValueData
  ConvertFrom-Array
06042026_001.ps1
  ThrowError
  Start-ProviderSetup
  Get-NormalizedRegistryKey
  Get-RegistryKeyHive
  Get-RegistryKeyPath
  Get-RegistryKeyName
  Get-RegistryResourceObject
  Convert-ByteArrayToHexString
  Get-TypedObject
  Get-TargetResource
Inventoried functions: 18
Found unique functions: 18
Missing inventoried functions: NONE
Additional function names: NONE
```

Fidelity spot-check 1, reconstructed `Get-RegistryValueKindStr` excerpt:

```text
 488:   Begin {
 489:     Write-Debug -Message:'Entering Block:  Begin'
 490:     # Initalize DYNAMIC Variables
 491:     New-Variable -Force -Option:'Private'  -Name:'ValueKindIsNullorEmpty'  -Value:([System.Boolean]::Empty)
 492:     New-Variable -Force -Option:'Private'  -Name: 'IsValidValueKind'        -Value:([System.Boolean]::Empty)
 493:     New-Variable -Force -Option:'Private'  -Name: 'NormalizedValueKind'     -
 494: Value:([Microsoft.Win32.RegistryValueKind]::Empty)
 495:     New-Variable -Force -Option:'Private'  -Name: 'ValueKindIsUnknown'      -
 496: Value:([Microsoft.Win32.RegistryValueKind]::Empty)
 497:     New-Variable -Force -Option:'Private'  -Name: 'Result'                  -
 498: Value:([Microsoft.Win32.RegistryValueKind]::Empty)
 499:     Write-Debug -Message:'Exiting Block:  Begin'
 500:   } Process {
 501:     Write-Debug -Message:'Entering Block:  Process'
 502:     # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale
 503:     #    values are carried over between piped datasets.
 504:     Clear-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
 505:        'ValueKindIsNullorEmpty',  'IsValidValueKind',  'NormalizedValueKind',
 506:        'ValueKindIsUnknown',  'Result'
 507:     ))
 508:     Set-Variable -Name:'ValueKindIsNullorEmpty'  -Value:([System.Boolean] (
 509:       [System.String]::IsNullOrWhiteSpace($ValueKind)
 510:     ))
 511:     If ($ValueKindIsNullorEmpty -eq $True) {
 512:
 513:       Set-Variable -Name: 'NormalizedValueKind'  -Value:(
 514:         [Microsoft.Win32.RegistryValueKind]::None
 515:       )
 516:     } Else {
 517:       # Validate the Registry Hive value against a list of valid and support registry hives.
 518:       Set-Variable -Name:'IsValidValueKind'  -Value: (
 519:         [System.Boolean] (
 520:           [Enum]::TryParse(
 521:              [Microsoft.Win32.RegistryValueKind],
 522:             $ValueKind,
 523:             [Ref ]$NormalizedValueKind
 524:           )
```

Corresponding corrected OCR excerpts:

```text
page-0008: 73: Begin {
page-0008: 75: Write-Debug -Message:'Entering Block: Begin'
page-0008: 77: # Initalize DYNAMIC Variables
page-0008: 79: New-Variable -Force -Option: 'Private' -Name:'ValueKindIsNullorEmpty' -Value:([System.Boolean]::Empty)
page-0008: 81: New-Variable -Force -Option:'Private' -Name: 'IsValidValueKind' -Value:([System.Boolean]::Empty)
page-0008: 83: New-Variable -Force -Option:'Private' -Name: 'NormalizedValueKind' =
page-0008: 85: Value: ( [Microsoft .Win32.RegistryValueKind]: : Empty)
page-0008: 86: New-Variable -Force -Option:'Private' -Name: 'ValueKindIsUnknown' -
page-0008: 87: Value: ( [Microsoft .Win32.RegistryValueKind]::Empty)
page-0008: 88: New-Variable -Force -Option:'Private' -Name: 'Result' =
page-0008: 89: Value: ( [Microsoft .Win32.RegistryValueKind]::Empty)
page-0008: 91: } Process {
page-0008: 93: Write-Debug -Message:'Entering Block: Process'
page-0008: 95: # Clear all variables immediately upon entering the 'Process' loop to ensure no stale
page-0008: 97: # values are carried over between piped datasets.
page-0009: 11: [Enum]: :TryParse(
page-0009: 12: [Microsoft.Win32.RegistryValueKind],
page-0009: 13: $ValueKind,
page-0009: 14: [Ref ]$NormalizedValueKind
```

Fidelity spot-check 2, reconstructed `ThrowError` excerpt:

```text
  44: Function ThrowError {
  45:   [CmdletBinding(
  46:     ,  DefaultParameterSetName =  'Default'
  47:     # , SupportsShouldProcess = $True
  48:     ;  PositionalBinding = $True
  49:     , ConfirmImpact =  'Low'
  50:   )] Param(
  51:     [Parameter(
  52:       ; Mandatory          = $True
  53:       ,  ParameterSetName  =  'Default'
  54:       ,  Position           = 0
  55:       , ValueFromPipeline = $true
  56:     )]
  57:     [ValidateNotNullOrEmpty()]
  58:     [System.String]
  59:     $ExceptionName,
  60:     [Parameter(
  61:       , Mandatory          = $True
  62:       ,  ParameterSetName  =  'Default'
  63:       ,  Position           =1
  64:
  65:       , ValueFromPipeline = $true
  66:     )]
  67:     [ValidateNotNullOrEmpty()]
  68:     [System.String]
  69:     $ExceptionMessage,
  70:     [Parameter (
  71:       , Mandatory         = $True
  72:       ,  ParameterSetName  =  'Default'
  73:       ,  Position           = 2
  74:       , ValueFromPipeline = $true
  75:     )]
  76:     [System.Object]
  77:     $ExceptionObject,
  78:     [Parameter(
  79:       , Mandatory         = $True
  80:       ,  ParameterSetName  =  'Default'
  81:       ,  Position           = 3
  82:       , ValueFromPipeline = $true
  83:     )]
  84:     [ValidateNotNullOrEmpty( )]
  85:     [System.String]
  86:     $ErrorId,
  87:     [Parameter(
  88:       , Mandatory          = $True
  89:       ,  ParameterSetName  =  'Default'
  90:       ,  Position           = 4
  91:       , ValueFromPipeline = $true
  92:     )]
  93:     [ValidateNotNull()]
  94:     [System.Management.Automation.ErrorCategory]
  95:     $ErrorCategory
  96:   )
  97:   $exception = New-Object $ExceptionName $ExceptionMessage;
  98:   $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception,  $ErrorId,  $ErrorCategory,
  99: $ExceptionObject
 100:   throw $errorRecord
```

Corresponding corrected OCR excerpts:

```text
page-0001: 48: [CmdletBinding(
page-0001: 49: , DefaultParameterSetName = 'Default'
page-0001: 50: # , SupportsShouldProcess = $True
page-0001: 51: ; PositionalBinding = $True
page-0001: 52: , ConfirmImpact = 'Low'
page-0001: 53: )] Param(
page-0001: 54: [Parameter(
page-0001: 55: ; Mandatory = $True
page-0001: 56: , ParameterSetName = 'Default'
page-0001: 57: Position = @
page-0001: 58: , ValueFromPipeline = $true
page-0002:  6: [ValidateNotNullOrEmpty()]
page-0002:  7: [System.String]
page-0002:  8: SExceptionMessage,
page-0002: 25: $Errorid,
page-0002: 32: [ValidateNotNult()]
page-0002: 33: [System.Management .Automation.ErrorCategory ]
page-0002: 36: $exception = New-Object $ExceptionName $ExceptionMessage;
page-0002: 37: $errorRecord = New-Object System.Management. Automation. ErrorRecord $exception, $ErrorId, $ErrorCategory,
page-0002: 38: $ExceptionObject
page-0002: 39: throw $errorRecord
```

Fidelity statement:

```text
No block was intentionally collapsed, no declaration was intentionally removed, no comment was intentionally stripped, no API was intentionally swapped, and no logic was intentionally changed. Corrections made in this continuation were limited to image-backed OCR glyph fixes and are listed in the provenance sidecars. Remaining OCR-risk patterns are treated as owner-review objections, not silently certified.
```

Unreadable tokens:

```text
No <#OCR-UNREADABLE#> tokens are present in recovered/*.ps1. The sidecars currently list no unreadable tokens. Remaining uncertainty is reported as owner-review risk instead of inventing missing glyphs.
```

Sensitive-content scan:

```text
NO OUTPUT from targeted scan for user-profile paths, UNC shares, SIDs, emails, IP/MAC-like identifiers, and credential-like terms.
```

PDF SHA-256 unchanged:

```text
Algorithm : SHA256
Hash      : B6BD5239D642D09368E255E21064B1F48C63D075DD43F8374098300DB9ED155F
Path      : 06042026.pdf

Algorithm : SHA256
Hash      : D6BE73056B47FB9EEA9126A9EA5BC232BCF733A5562306AC2A601FA57FFC051E
Path      : 06042026_001.pdf
```

Ignore/trackability checks:

```text
.gitignore:27:	recovered/
recovered_exit=0
.gitignore:24:/06042026.pdf	06042026.pdf
.gitignore:25:/06042026_001.pdf	06042026_001.pdf
.gitignore:26:/_recovery/	_recovery/
protected_exit=0
```

```text
add 'recovered/06042026.provenance.md'
add 'recovered/06042026.ps1'
add 'recovered/06042026_001.provenance.md'
add 'recovered/06042026_001.ps1'
```

Branch check:

```text
recovery/faithful-source-rebuild
```

No `src/` or `tests/` diff:

```text
NO OUTPUT from: git diff -- src tests
```

Pre-commit status:

```text
## recovery/faithful-source-rebuild
 M .gitignore
 M _handoff/CLAUDE-RESTART-PROMPT.md
 M _handoff/PLAN.md
 M _handoff/REPORT-ARCHIVE.md
 M _handoff/REPORT.md
 M _handoff/TASK.md
?? recovered/
```

Signature verification will be run immediately after the signed commit and reported in the final handback.

## Deviations from `TASK.md` and why

- `REPORT.md` is marked `NEEDS-OWNER` rather than `COMPLETE` because OCR-risk patterns remain visible and owner fidelity review is required before advancing.
- The PR will be opened for owner review even though status is `NEEDS-OWNER`; this follows the user's explicit instruction for this step to open a PR to `main` and stop for owner review.
- `PLAN.md`, `TASK.md`, and `CLAUDE-RESTART-PROMPT.md` have pre-existing handoff changes; Codex did not edit their content, but will include them as-is per the task's durability instruction.

## Open objections that must be resolved before advancing

- Owner must confirm whether the `recovered/*.ps1` files are faithful enough to become the accepted source baseline.
- OCR-risk scan still flags suspicious glyph patterns such as doubled apostrophes and comma artifacts outside the spot-checked corrections. These are not sensitive-content hits, but they are fidelity-review risks.
- The `git check-ignore -v recovered/` output is awkward for the directory itself, but `git add --dry-run recovered` confirms all four recovered files are trackable.

## Owner decisions needed

- Review the PR and decide whether the recovered source is faithful, needs owner edits, or needs another slower page-image pass.
- Decide whether to advance from corrective faithful reconstruction after this PR, or keep the corrective task active for more transcription cleanup.

Faithful recovery status: NEEDS-OWNER
