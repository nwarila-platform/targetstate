Phase 6 build 2 status: NEEDS-OWNER

## Adversarial review verdict

Goal: execute Phase 6 build 2 on branch `recovery/phase6-build-2`: make exactly the eight scoped pure leaf functions parse and run on Windows PowerShell 5.1, keep the runnable copies both-runtime compatible for PowerShell 5.1 + 7, preserve the owner's recovered structure/style/comments, add focused Pester tests, append classified make-it-run documentation, flag any non-approved API/logic/behavior change without applying it, open a PR to `main`, and stop for owner review.

Decision: PROCEED, but final status is NEEDS-OWNER. The parse/run work is complete for changes inside the approved boundary (OCR artifacts, approved `[Type]::Empty` mappings, and no new non-approved API swaps). Several behavior fixes that would make the helpers fully match their comments are real logic changes, not OCR fixes, so they are documented in `docs/build/flagged-decisions.md` and intentionally left unapplied.

Branch check: `recovery/phase6-build-2`, not `main`.

Scoped function status:

| Function | Status | Notes |
| --- | --- | --- |
| `ThrowError` | runs | Parser + Pester pass. |
| `Get-RegistryKeyHiveObj` | runs pending flag | Full hive names and invalid hive errors pass; abbreviated aliases such as `HKLM` are skipped pending owner decision on `@(, ...)`. |
| `Get-RegistryKeyPathStr` | runs pending flag | Normal path normalization passes; non-printable validation is skipped pending owner decision on `$KeyName`/regex behavior. |
| `Get-RegistryKeyNameStr` | runs pending flag | Normal output + backslash throw pass; non-printable validation is skipped pending owner decision on regex behavior. |
| `Get-RegistryValueNameStr` | runs pending flag | Empty + printable value names pass; non-printable validation is skipped pending owner decision on regex behavior. |
| `Get-NormalizedRegistryKey` | runs pending flag | No-normalization path passes; double/trailing slash normalization is skipped pending owner decision on `-contains`/`TrimEnd('/')`. |
| `ConvertFrom-Array` | runs | Parser + Pester pass. |
| `Convert-ByteArrayToHexString` | runs | Parser + Pester pass. |

## What changed

- Archived the prior `_handoff/REPORT.md` to the top of `_handoff/REPORT-ARCHIVE.md`.
- Added runnable copies for the eight scoped functions under `src/`.
- Added Pester tests for the eight scoped functions under `tests/`.
- Appended Phase 6 build 2 sections to `docs/build/make-it-run-log.md`.
- Added `docs/build/flagged-decisions.md` for non-applied owner decisions.
- Preserved the pre-existing local planner/owner updates to `_handoff/PLAN.md`, `_handoff/TASK.md`, `_handoff/CLAUDE-RESTART-PROMPT.md`, `docs/build/owner-idiom-decisions.md`, and `src/Get-RegistryValueKindStr.ps1` as-is.

## What was intentionally not changed

- `recovered/**` was not modified.
- No excluded functions were changed: `Start-ProviderSetup`, `Get-TargetResource`, `Mount-RegistryHive`, `Get-TypedObject`, `Get-RegistryResourceObject`, and no additional changes were made to `Get-RegistryValueKindStr` by Codex.
- No flagged API/logic/behavior changes were applied.
- No live registry/system state, PDFs, `_recovery/`, ADR statuses, dispatcher/Test/Set implementation, module manifest, or `.mof` files were changed.
- `PLAN.md`, `TASK.md`, and `CLAUDE-RESTART-PROMPT.md` content was not edited by Codex; their pre-existing local changes were carried forward.

## Verification output

Parse:

```text
PowerShellVersion=5.1.26100.8457
ThrowError: ParseErrors=0
Get-RegistryKeyHiveObj: ParseErrors=0
Get-RegistryKeyPathStr: ParseErrors=0
Get-RegistryKeyNameStr: ParseErrors=0
Get-RegistryValueNameStr: ParseErrors=0
Get-NormalizedRegistryKey: ParseErrors=0
ConvertFrom-Array: ParseErrors=0
Convert-ByteArrayToHexString: ParseErrors=0
```

Pester (Windows PowerShell 5.1 / Pester 5.x):

```text
PesterVersion=5.7.1
Total=24 Passed=18 Failed=0 Skipped=6 Inconclusive=0 NotRun=0
Passed: converts bytes to lowercase two-character hex values
Passed: converts a single byte value
Passed: returns a single element without a delimiter
Passed: joins multiple elements with comma-space delimiters
Passed: returns a registry key without normalization needs unchanged
Skipped: collapses doubled backslashes
Skipped: removes a trailing backslash
Passed: returns the hive descriptor for a full hive name
Passed: throws for an invalid hive
Skipped: returns the hive descriptor for an abbreviated hive alias
Passed: returns a printable key name unchanged
Passed: throws when the key name contains a backslash
Skipped: throws for non-printable characters
Passed: normalizes doubled, leading, and trailing backslashes
Skipped: throws for non-printable characters
Passed: returns None for an empty value kind
Passed: returns None for a whitespace value kind
Passed: returns the parsed registry value kind for a valid value kind string
Passed: throws for an invalid value kind string
Passed: throws for Unknown even though the enum parser accepts it
Passed: returns an empty default value name unchanged
Passed: returns a printable value name unchanged
Skipped: throws for non-printable characters
Passed: throws a terminating error record with the supplied message and id
```

PowerShell 7 availability:

```text
pwsh: NOT FOUND
```

PowerShell 7 compatibility analysis: `pwsh` is not installed in this environment. The runnable copies use APIs available in both Windows PowerShell 5.1/.NET Framework and PowerShell 7/.NET: `New-Object`, `System.Text.StringBuilder`, `System.Math`, `System.String` methods, .NET regex Unicode categories `Cc`/`Cn`/`Cs`, `System.Management.Automation.ErrorRecord`, `System.Management.Automation.ErrorCategory`, and `Microsoft.Win32.RegistryValueKind`. No 5.1-only or 7-only API change was introduced; non-approved behavior/API concerns are in `docs/build/flagged-decisions.md`.

Fidelity diffs:

### ThrowError
```diff
warning: in the working copy of 'src\ThrowError.ps1', LF will be replaced by CRLF the next time Git touches it
diff --git "a/recovered\\canonical\\ThrowError.ps1" "b/src\\ThrowError.ps1"
index 7f07beb..e785bc0 100644
--- "a/recovered\\canonical\\ThrowError.ps1"
+++ "b/src\\ThrowError.ps1"
@@ -1,12 +1,12 @@
 Function ThrowError {
   [CmdletBinding(
-    ,  DefaultParameterSetName =  'Default'
+       DefaultParameterSetName =  'Default'
     # , SupportsShouldProcess = $True
-    ;  PositionalBinding = $True
+    ,  PositionalBinding = $True
     , ConfirmImpact =  'Low'
   )] Param(
     [Parameter(
-      ; Mandatory          = $True
+        Mandatory          = $True
       ,  ParameterSetName  =  'Default'
       ,  Position           = 0
       , ValueFromPipeline = $true
@@ -15,7 +15,7 @@ Function ThrowError {
     [System.String]
     $ExceptionName,
     [Parameter(
-      , Mandatory          = $True
+        Mandatory          = $True
       ,  ParameterSetName  =  'Default'
       ,  Position           =1
 
@@ -25,7 +25,7 @@ Function ThrowError {
     [System.String]
     $ExceptionMessage,
     [Parameter (
-      , Mandatory         = $True
+        Mandatory         = $True
       ,  ParameterSetName  =  'Default'
       ,  Position           = 2
       , ValueFromPipeline = $true
@@ -33,7 +33,7 @@ Function ThrowError {
     [System.Object]
     $ExceptionObject,
     [Parameter(
-      , Mandatory         = $True
+        Mandatory         = $True
       ,  ParameterSetName  =  'Default'
       ,  Position           = 3
       , ValueFromPipeline = $true
@@ -42,7 +42,7 @@ Function ThrowError {
     [System.String]
     $ErrorId,
     [Parameter(
-      , Mandatory          = $True
+        Mandatory          = $True
       ,  ParameterSetName  =  'Default'
       ,  Position           = 4
       , ValueFromPipeline = $true
```

### Get-RegistryKeyHiveObj
```diff
warning: in the working copy of 'src\Get-RegistryKeyHiveObj.ps1', LF will be replaced by CRLF the next time Git touches it
diff --git "a/recovered\\canonical\\Get-RegistryKeyHiveObj.ps1" "b/src\\Get-RegistryKeyHiveObj.ps1"
index d6506fb..7f161b9 100644
--- "a/recovered\\canonical\\Get-RegistryKeyHiveObj.ps1"
+++ "b/src\\Get-RegistryKeyHiveObj.ps1"
@@ -20,7 +20,7 @@ Begin {
   Write-Debug -Message:'Entering Block:  Begin'
   # Initalize DYNAMIC Variables
   New-Variable -Force -Option:'Private'  -Name:'Result'        -Value:([System.String]::Empty)
-  New-Variable -Force -Option:'Private'  -Name:'RegistryHive'  -Value:([Hashtable]::Empty)
+  New-Variable -Force -Option:'Private'  -Name:'RegistryHive'  -Value:(@{})
   Write-Debug -Message:'Exiting Block:  Begin'
 } Process {
   Write-Debug -Message:'Entering Block:  Process'
@@ -66,7 +66,7 @@ Begin {
       })
     }
     { $PSItem -in @(,  'HKCC',  'HKEY_CURRENT_CONFIG',  'CurrentConfig',  '-2147483643') } {
-      Set-Variable -Name:'RegistryHive'  -Value:([Hashtable]a{
+      Set-Variable -Name:'RegistryHive'  -Value:([Hashtable]@{
         Name          =  'HKEY_CURRENT_CONFIG'
         ShortName    =  'CurrentConfig'
         Abbreviation =  'HKCC'
@@ -75,11 +75,10 @@ Begin {
     default {
       ThrowError `
         -ErrorId: 'InvalidRegistryHiveSpecified' `
-        -ErrorCategory: 'InvalidArgument ' `
-
-          -ExceptionName: 'System.ArgumentException' `
-          -ExceptionObject:$KeyHive `
-          -ExceptionMessage: $LocalizedData. InvalidRegistryHiveSpecified
+        -ErrorCategory: 'InvalidArgument' `
+        -ExceptionName: 'System.ArgumentException' `
+        -ExceptionObject:$KeyHive `
+        -ExceptionMessage: $LocalizedData.InvalidRegistryHiveSpecified
       }
     }
     # It's always desirable to explicitly set the Result object with its desired class as close
```

### Get-RegistryKeyPathStr
```diff
warning: in the working copy of 'src\Get-RegistryKeyPathStr.ps1', LF will be replaced by CRLF the next time Git touches it
diff --git "a/recovered\\canonical\\Get-RegistryKeyPathStr.ps1" "b/src\\Get-RegistryKeyPathStr.ps1"
index 7ee01b4..be00b4c 100644
--- "a/recovered\\canonical\\Get-RegistryKeyPathStr.ps1"
+++ "b/src\\Get-RegistryKeyPathStr.ps1"
@@ -19,10 +19,10 @@ Function Get-RegistryKeyPathStr {
       Write-Debug -Message:'Entering Block:  Begin'
       # Initalize DYNAMIC Variables
       New-Variable -Force -Option:'Private'  -Name:'Result'                   -Value:([System.String]::Empty)
-      New-Variable -Force -Option:'Private'  -Name:'KeyPathHasNonPrintChars'  -Value:([System.Boolean]::Empty)
-      New-Variable -Force -Option:'Private'  -Name:'KeyPathHasDoubleSlashes'  -Value:([System.Boolean]::Empty)
-      New-Variable -Force -Option:'Private'  -Name:'KeyPathHasLeadingSlash'   -Value:([System.Boolean]::Empty)
-      New-Variable -Force -Option:'Private'  -Name:'KeyPathHasTrailingSlash'  -Value:([System.Boolean]::Empty)
+      New-Variable -Force -Option:'Private'  -Name:'KeyPathHasNonPrintChars'  -Value:($False)
+      New-Variable -Force -Option:'Private'  -Name:'KeyPathHasDoubleSlashes'  -Value:($False)
+      New-Variable -Force -Option:'Private'  -Name:'KeyPathHasLeadingSlash'   -Value:($False)
+      New-Variable -Force -Option:'Private'  -Name:'KeyPathHasTrailingSlash'  -Value:($False)
       Write-Debug -Message:'Exiting Block:  Begin'
   } Process {
       Write-Debug -Message:'Entering Block:  Process'
@@ -31,11 +31,11 @@ Function Get-RegistryKeyPathStr {
     Clear-Variable -Force -ErrorAction:'SilentlyContinue'  -Name:(@(
       'Result',  'KeyPathHasNonPrintChars',  'KeyPathHasDoubleSlashes',
       'KeyPathHasLeadingSlash',  'KeyPathHasTrailingSlash'
-     )
+     ))
     # Key names cannot any non-printable characters.
 
   Set-Variable -Name:'KeyPathHasNonPrintChars'  -Value:([System.Boolean](
-    $KeyName -match  '\P{Cc}\p{Cn}\p{cs}'
+    $KeyName -match  '\P{Cc}\p{Cn}\p{Cs}'
   ))
   If ($KeyPathHasNonPrintChars -eq $True) {
     ThrowError `
@@ -57,7 +57,7 @@ Function Get-RegistryKeyPathStr {
     ))
   }
   Set-Variable -Name:'KeyPathHasLeadingSlash'  -Value:([System.Boolean] (
-    $NormalizedKeypath[@] -eq  '\'
+    $NormalizedKeypath[0] -eq  '\'
   ))
   If ($KeyPathHasLeadingSlash -eq $True) {
     Set-Variable -Name:'NormalizedKeypath'  -Value:([System.String](
```

### Get-RegistryKeyNameStr
```diff
warning: in the working copy of 'src\Get-RegistryKeyNameStr.ps1', LF will be replaced by CRLF the next time Git touches it
diff --git "a/recovered\\canonical\\Get-RegistryKeyNameStr.ps1" "b/src\\Get-RegistryKeyNameStr.ps1"
index 36f6e09..ce8cb6e 100644
--- "a/recovered\\canonical\\Get-RegistryKeyNameStr.ps1"
+++ "b/src\\Get-RegistryKeyNameStr.ps1"
@@ -19,8 +19,8 @@ Function Get-RegistryKeyNameStr {
     Write-Debug -Message:'Entering Block:  Begin'
     # Initalize DYNAMIC Variables
     New-Variable -Force -Option:'Private'  -Name:'Result'                   -Value:( [System.String]::Empty)
-    New-Variable -Force -Option:'Private'  -Name: 'KeyNameHasBackslash'      -Value:([System.Boolean]::Empty)
-    New-Variable -Force -Option:'Private'  -Name:'KeyNameHasNonPrintChars'  -Value:([System.Boolean]::Empty)
+    New-Variable -Force -Option:'Private'  -Name: 'KeyNameHasBackslash'      -Value:($False)
+    New-Variable -Force -Option:'Private'  -Name:'KeyNameHasNonPrintChars'  -Value:($False)
     Write-Debug -Message:'Exiting Block:  Begin'
   } Process {
     Write-Debug -Message:'Entering Block:  Process'
@@ -37,7 +37,7 @@ Function Get-RegistryKeyNameStr {
       ThrowError `
         -ErrorId: 'InvalidRegistryKeyName' `
         -ErrorCategory: 'InvalidArgument' `
-        -ExceptionName: 'System.ArgumentException'' `
+        -ExceptionName: 'System.ArgumentException' `
         -ExceptionObject: $KeyName `
         -ExceptionMessage: $LocalizedData.InvalidRegistryKeyNameSpecified
     }
@@ -50,8 +50,9 @@ Function Get-RegistryKeyNameStr {
         -ErrorId: 'InvalidRegistryKeyName' `
         -ErrorCategory: 'InvalidArgument' `
         -ExceptionName: 'System.ArgumentException' `
-        -ExceptionObject: $kKeyName `
-    :   -ExceptionMessage: $LocalizedData.InvalidRegistryKeyNameSpecified
+        -ExceptionObject: $KeyName `
+        -ExceptionMessage: $LocalizedData.InvalidRegistryKeyNameSpecified
+    }
     # It's always desirable to explicitly set the Result object with its desired class as close
     #   to the soft return to ensure the output is predictable and easily traceable.
     Set-Variable -Name:'Result'  -Value:( [System.String] (
```

### Get-RegistryValueNameStr
```diff
warning: in the working copy of 'src\Get-RegistryValueNameStr.ps1', LF will be replaced by CRLF the next time Git touches it
diff --git "a/recovered\\canonical\\Get-RegistryValueNameStr.ps1" "b/src\\Get-RegistryValueNameStr.ps1"
index 334d4a3..1350bf5 100644
--- "a/recovered\\canonical\\Get-RegistryValueNameStr.ps1"
+++ "b/src\\Get-RegistryValueNameStr.ps1"
@@ -8,7 +8,7 @@ Function Get-RegistryValueNameStr {
     [Parameter(
       , Mandatory          = $True
       ,  ParameterSetName  =  'Default'
-      ,,  Position           = 0
+      ,  Position           = 0
       , ValueFromPipeline = $True
     )]
     [AllowEmptyString()]
@@ -20,7 +20,7 @@ Function Get-RegistryValueNameStr {
     Write-Debug -Message:'Entering Block:  Begin'
     # Initalize DYNAMIC Variables
     New-Variable -Force -Option:'Private'  -Name:'Result'          -Value: ([System.String]::Empty)
-    New-Variable -Force -Option:'Private'  -Name:'IsNonPrintable'  -Value:([System.Boolean]::Empty)
+    New-Variable -Force -Option:'Private'  -Name:'IsNonPrintable'  -Value:($False)
     Write-Debug -Message:'Exiting Block:  Begin'
   } Process {
     Write-Debug -Message:'Entering Block:  Process'
@@ -31,7 +31,7 @@ Function Get-RegistryValueNameStr {
     ))
     # Key names cannot any non-printable characters.
     Set-Variable -Name:'IsNonPrintable'  -Value:([System.Boolean](
-      $ValueName -match  '\P{Cc}\p{Cn}\p{cs}'
+      $ValueName -match  '\P{Cc}\p{Cn}\p{Cs}'
     ))
     If ($IsNonPrintable -eq $True) {
       # mn wwe ce wen oa cp nmr tem cin on cam cam wo um: mm came am Me ah sO OSs i ee oe  ee ee
@@ -39,7 +39,7 @@ Function Get-RegistryValueNameStr {
         -ErrorId: 'InvalidRegistryKeyName ' `
         -ErrorCategory: 'InvalidArgument' `
         -ExceptionName: 'System.ArgumentException' `
-        -ExceptionObject :$ValueName `
+        -ExceptionObject:$ValueName `
         -ExceptionMessage: $LocalizedData.InvalidRegistryKeyNameSpecified
     }
     # It's always desirable to explicitly set the Result object with its desired class as close
```

### Get-NormalizedRegistryKey
```diff
warning: in the working copy of 'src\Get-NormalizedRegistryKey.ps1', LF will be replaced by CRLF the next time Git touches it
diff --git "a/recovered\\canonical\\Get-NormalizedRegistryKey.ps1" "b/src\\Get-NormalizedRegistryKey.ps1"
index 7bedf8e..383c2d5 100644
--- "a/recovered\\canonical\\Get-NormalizedRegistryKey.ps1"
+++ "b/src\\Get-NormalizedRegistryKey.ps1"
@@ -11,7 +11,7 @@ subsequent
         , ConfirmImpact          =  'None'
         ,  PositionalBinding     = $True
     )]
-    Param(                                                                                      ; `
+    Param(
         [Parameter( ParameterSetName =  'Default',  Position = 1, Mandatory = $True, ValueFromPipeline =
 $True )]
         [ValidateNotNullOrEmpty()]
@@ -31,12 +31,12 @@ $True )]
         # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale values are
         #     carried over between piped datasets.
         Clear-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
-             'RegistryKeyStr',  'HasDoubleSlashes',  'HasTrailingSlash',  ''Result'
+             'RegistryKeyStr',  'HasDoubleSlashes',  'HasTrailingSlash',  'Result'
         ))
         # Copy the value of RegistryKey to a new object that we can manipulate as we want without obscutating
-the
+        # the
         #     origional value of RegistryKey. This is to support debugging efforts and code execution
-tracing.
+        # tracing.
         Set-Variable -Name: 'RegistryKeyStr'  -Value:([System.String](
             $RegistryKey
         ))
@@ -49,7 +49,7 @@ tracing.
         #     parts of the regsitry key path by splitting on backslashes.
         If ($HasDoubleSlashes) {
             # This check is done seperately so as this module matures, we can offer to raise a suggestion
-about
+            # about
             #     changing the registry key string format in the source file(s) to match the desired format.
             Set-Variable -Name:'RegistryKeyStr'  -Value:([System.String](
                 $RegistryKeyStr -replace ('\\+','\')
@@ -61,12 +61,12 @@ about
         ))
         # If the string ends with a trailing slash, we want to remove it as we want to ensure the registry
         #     key string is as predictable as possible. This gives us the ability to reliably extract
-specific
+        # specific
         #     parts of the regsitry key path by splitting on backslashes.
 
         If ($HasTrailingSlash) {
             # This check is done seperately so as this module matures, we can offer to raise a suggestion
-about
+            # about
             #     changing the registry key string format in the source file(s) to match the desired format.
             Set-Variable -Name: 'RegistryKeyStr'  -Value:([System.String](
                  $RegistryKeyStr.TrimEnd('/')
@@ -88,7 +88,7 @@ about
         #     required as they will automatically be disposed of when leaving a function,  but I consider
         #     this best practice as it forces me to be mindful of all used variables.
         Remove-variable -Force -ErrorAction: 'SilentlyContinue'  -Name: (@(
-             'RegistryKey', 'RegistryKeyStr','Result',  ''HasDoubleSlashes',  'HasTrailingSlash'
+             'RegistryKey', 'RegistryKeyStr','Result',  'HasDoubleSlashes',  'HasTrailingSlash'
         ))
         Write-Debug -Message: 'Exiting Block:  End'
     }
```

### ConvertFrom-Array
```diff
warning: in the working copy of 'src\ConvertFrom-Array.ps1', LF will be replaced by CRLF the next time Git touches it
diff --git "a/recovered\\canonical\\ConvertFrom-Array.ps1" "b/src\\ConvertFrom-Array.ps1"
index 644b53f..bfa003c 100644
--- "a/recovered\\canonical\\ConvertFrom-Array.ps1"
+++ "b/src\\ConvertFrom-Array.ps1"
@@ -21,7 +21,7 @@ Begin {
   Write-Debug -Message:'Entering Block:  Begin'
   # Initalize DYNAMIC Variables
   New-Variable -Force -Option:'Private'  -Name: 'Result'         -Value:( [System.String]::Empty)
-  New-Variable -Force -Option:'Private'  -Name: 'ArrayLength'    -Value:([System.Int32]::Empty)
+  New-Variable -Force -Option:'Private'  -Name: 'ArrayLength'    -Value:(0)
   # StringBuilder must not have the option  'Private',  because the loop method we use
   #   creates a new scope,  and thus it would not be accessible if this was private.
   New-Variable -Force                    -Name: 'StringBuilder'  -Value:([System.Text.StringBuilder]$Null)
@@ -56,10 +56,11 @@ Begin {
   0..([System.Math]::Max($value.count-1,0))  |  & {
     Process {
       # System.Text.StringBuilder Append(string value)
-      ae = $StringBuilder.Append(  [System.String]('{0},  '  -f $Value[$PSItem])  )
-    } End
+      $NULL = $StringBuilder.Append(  [System.String]('{0}, '  -f $Value[$PSItem])  )
+    } End {
       # System.Text.StringBuilder Remove(int startIndex,  int length)
-    ; $NULL = $StringBuilder.Remove(  ($StringBuilder.Length-2), 2  )
+      $NULL = $StringBuilder.Remove(  ($StringBuilder.Length-2), 2  )
+    }
   }
   # It's always desirable to explicitly set the Result object with its desired class as close
   #   to the soft return to ensure the output is predictable and easily traceable.
```

### Convert-ByteArrayToHexString
```diff
warning: in the working copy of 'src\Convert-ByteArrayToHexString.ps1', LF will be replaced by CRLF the next time Git touches it
diff --git "a/recovered\\canonical\\Convert-ByteArrayToHexString.ps1" "b/src\\Convert-ByteArrayToHexString.ps1"
index 4fbd997..5956d38 100644
--- "a/recovered\\canonical\\Convert-ByteArrayToHexString.ps1"
+++ "b/src\\Convert-ByteArrayToHexString.ps1"
@@ -23,7 +23,7 @@ $True )]
         # !TODO
         $ByteArray  |
             ForEach-Object -Process:{
-                g$Result += [String]::Format("{0:x2}", $_)
+                $Result += [String]::Format("{0:x2}", $_)
             }
         # Do a  'soft'  return by sending the Result object to the caller and explicitly declare the returning
         #     the result with a explicit typing to ensure all returned data types are predictable.
```


Hygiene:

```text
recovered status:
ADR Draft check:
branch:
recovery/phase6-build-2
git status --short --branch:
## recovery/phase6-build-2
 M _handoff/CLAUDE-RESTART-PROMPT.md
 M _handoff/PLAN.md
 M _handoff/REPORT-ARCHIVE.md
 M _handoff/REPORT.md
 M _handoff/TASK.md
 M docs/build/make-it-run-log.md
 M docs/build/owner-idiom-decisions.md
 M src/Get-RegistryValueKindStr.ps1
?? docs/build/flagged-decisions.md
?? src/Convert-ByteArrayToHexString.ps1
?? src/ConvertFrom-Array.ps1
?? src/Get-NormalizedRegistryKey.ps1
?? src/Get-RegistryKeyHiveObj.ps1
?? src/Get-RegistryKeyNameStr.ps1
?? src/Get-RegistryKeyPathStr.ps1
?? src/Get-RegistryValueNameStr.ps1
?? src/ThrowError.ps1
?? tests/Convert-ByteArrayToHexString.Tests.ps1
?? tests/ConvertFrom-Array.Tests.ps1
?? tests/Get-NormalizedRegistryKey.Tests.ps1
?? tests/Get-RegistryKeyHiveObj.Tests.ps1
?? tests/Get-RegistryKeyNameStr.Tests.ps1
?? tests/Get-RegistryKeyPathStr.Tests.ps1
?? tests/Get-RegistryValueNameStr.Tests.ps1
?? tests/ThrowError.Tests.ps1
```

Sensitive scan:

```text
Sensitive scan clean for added diff lines.
```

Scoped `git diff --check` for Phase 6 build 2 files:

```text
warning: in the working copy of '_handoff/REPORT.md', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'docs/build/make-it-run-log.md', LF will be replaced by CRLF the next time Git touches it
```

Final signed-commit verification:

```text
Pending final `git log --show-signature -1` after the commit exists. Recording the final commit signature inside the same committed report is self-referential; it will be run after commit and included in the PR body and handback.
```

## Deviations from `TASK.md` and why

- Six Pester tests are intentionally skipped because their fixes would require non-approved behavior changes. Those changes are flagged in `docs/build/flagged-decisions.md` and not applied.
- `pwsh` is not installed, so PowerShell 7 verification is API analysis rather than execution.
- Full `git diff --check` also reports trailing whitespace in the pre-existing owner spacing update to excluded `src/Get-RegistryValueKindStr.ps1`; Codex left that file untouched. The scoped diff-check for Phase 6 build 2 files exits 0.
- Final `git log --show-signature -1` cannot be embedded in the same commit it verifies without an endless amend loop; it will be captured after commit in the PR body/final handback.

## Open objections that must be resolved before advancing

- Owner must decide whether to apply the flagged behavior fixes for abbreviated hive aliases, non-printable validation, and full-key backslash normalization.
- The skipped Pester cases should remain skipped until those owner decisions are made.

## Owner decisions needed

- Approve or reject the proposed `Get-RegistryKeyHiveObj` fix: remove leading unary commas from the switch comparison arrays.
- Approve or reject the proposed non-printable validation fix: inspect the actual input variable and use `[\p{Cc}\p{Cn}\p{Cs}]`-style Unicode-category character-class logic as written in `docs/build/flagged-decisions.md`.
- Approve or reject the proposed `Get-NormalizedRegistryKey` fixes: `-match ('\\{2,}')` for double backslashes and `TrimEnd('\')` for trailing registry backslashes.
- Review PR diffs before merge; Codex must not merge.

Phase 6 build 2 status: NEEDS-OWNER
