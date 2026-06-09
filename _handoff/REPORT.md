Phase 6 build 3 status: COMPLETE

## Adversarial review verdict

Goal: execute Phase 6 build 3 on branch `recovery/phase6-build-3`: apply exactly the five owner-approved behavior fixes from `docs/build/flagged-decisions.md` to the runnable `src/` copies, un-skip the matching tests, mark the decisions resolved, append make-it-run log entries, verify parse/Pester/hygiene, open a PR to `main`, and stop for owner review.

Decision: PROCEED and COMPLETE for the implementation cycle. The task is narrow, owner-approved, testable offline, and does not require PDF extraction, live registry/system mutation, new tooling, ADR status changes, or changes to `recovered/canonical/`. I changed only the named tokens and tests tied to those tokens.

Branch check: `recovery/phase6-build-3`, not `main`.

Chosen output locations: `_handoff/REPORT.md`, `_handoff/REPORT-ARCHIVE.md`, `src/Get-RegistryKeyHiveObj.ps1`, `src/Get-RegistryKeyPathStr.ps1`, `src/Get-RegistryKeyNameStr.ps1`, `src/Get-RegistryValueNameStr.ps1`, `src/Get-NormalizedRegistryKey.ps1`, the matching `tests/*.Tests.ps1`, `docs/build/flagged-decisions.md`, and `docs/build/make-it-run-log.md`.

Approved before/after tokens:

| Function | Before | After |
| --- | --- | --- |
| `Get-RegistryKeyHiveObj` | `@(,  'HKCR', ...)` and five sibling leading-comma arrays | `@('HKCR', ...)` and sibling arrays without unary comma |
| `Get-RegistryKeyHiveObj` | `'HKEY_CLASSES ROOT'` | `'HKEY_CLASSES_ROOT'` |
| `Get-RegistryKeyPathStr` | `$KeyName -match '\P{Cc}\p{Cn}\p{Cs}'` | `$KeyPath -match '[\p{Cc}\p{Cn}\p{Cs}]'` |
| `Get-RegistryKeyNameStr` | `$KeyName -match '\P{Cc}\p{Cn}\p{Cs}'` | `$KeyName -match '[\p{Cc}\p{Cn}\p{Cs}]'` |
| `Get-RegistryValueNameStr` | `$ValueName -match '\P{Cc}\p{Cn}\p{Cs}'` | `$ValueName -match '[\p{Cc}\p{Cn}\p{Cs}]'` |
| `Get-NormalizedRegistryKey` | `$RegistryKeyStr -contains ('\\')` | `$RegistryKeyStr -match ('\\{2,}')` |
| `Get-NormalizedRegistryKey` | `$RegistryKeyStr.TrimEnd('/')` | `$RegistryKeyStr.TrimEnd('\')` |

## What changed

- Applied the five owner-approved fixes in the runnable `src/` copies only.
- Un-skipped the previously skipped tests for abbreviated hives, non-printable validation, doubled backslashes, and trailing backslash normalization.
- Added the requested HKCR full-name assertion.
- Marked the flagged decisions RESOLVED and appended Build 3 entries to the make-it-run log.
- Archived the prior `REPORT.md` to the top of `REPORT-ARCHIVE.md`.
- Preserved pre-existing Claude-owned edits to `PLAN.md`, `TASK.md`, and `CLAUDE-RESTART-PROMPT.md` as-is.

## What was intentionally not changed

- `recovered/canonical/**` was not modified; it keeps the original faithful bugs for the record.
- No other source functions were changed, including `Get-RegistryValueKindStr`, `ThrowError`, `ConvertFrom-Array`, `Convert-ByteArrayToHexString`, `Mount-RegistryHive`, `Get-TypedObject`, `Start-ProviderSetup`, and `Get-TargetResource`.
- No PDFs, `_recovery/`, live registry/system state, ADR statuses, module manifest, dispatcher/Test/Set implementation, or `.mof` files were changed.
- I did not edit planner-owned handoff content; their pre-existing local updates were carried forward.

## Verification output

Parse:

```text
PowerShellVersion=5.1.26100.8457
Get-RegistryKeyHiveObj: ParseErrors=0
Get-RegistryKeyPathStr: ParseErrors=0
Get-RegistryKeyNameStr: ParseErrors=0
Get-RegistryValueNameStr: ParseErrors=0
Get-NormalizedRegistryKey: ParseErrors=0
```

Scoped Pester for the five changed functions:

```text
PesterVersion=5.7.1
Total=15 Passed=15 Failed=0 Skipped=0 Inconclusive=0 NotRun=0
Passed: collapses doubled backslashes
Passed: removes a trailing backslash
Passed: returns a registry key without normalization needs unchanged
Passed: returns the hive descriptor for a full hive name
Passed: returns the hive descriptor for an abbreviated hive alias
Passed: returns the hive descriptor for the HKCR full hive name
Passed: throws for an invalid hive
Passed: returns a printable key name unchanged
Passed: throws for non-printable characters
Passed: throws when the key name contains a backslash
Passed: normalizes doubled, leading, and trailing backslashes
Passed: throws for non-printable characters
Passed: returns a printable value name unchanged
Passed: returns an empty default value name unchanged
Passed: throws for non-printable characters
```

Full Pester suite:

```text
PesterVersion=5.7.1
Total=25 Passed=25 Failed=0 Skipped=0 Inconclusive=0 NotRun=0
Passed: converts a single byte value
Passed: converts bytes to lowercase two-character hex values
Passed: joins multiple elements with comma-space delimiters
Passed: returns a single element without a delimiter
Passed: collapses doubled backslashes
Passed: removes a trailing backslash
Passed: returns a registry key without normalization needs unchanged
Passed: returns the hive descriptor for a full hive name
Passed: returns the hive descriptor for an abbreviated hive alias
Passed: returns the hive descriptor for the HKCR full hive name
Passed: throws for an invalid hive
Passed: returns a printable key name unchanged
Passed: throws for non-printable characters
Passed: throws when the key name contains a backslash
Passed: normalizes doubled, leading, and trailing backslashes
Passed: throws for non-printable characters
Passed: returns None for a whitespace value kind
Passed: returns None for an empty value kind
Passed: returns the parsed registry value kind for a valid value kind string
Passed: throws for an invalid value kind string
Passed: throws for Unknown even though the enum parser accepts it
Passed: returns a printable value name unchanged
Passed: returns an empty default value name unchanged
Passed: throws for non-printable characters
Passed: throws a terminating error record with the supplied message and id
```

PowerShell 7 availability:

```text
pwsh: NOT FOUND
```

PowerShell 7 compatibility analysis: `pwsh` is not installed in this environment. The applied changes use only PowerShell/.NET constructs available in both Windows PowerShell 5.1 and PowerShell 7: array literals, `-match`, .NET regex Unicode category character classes, and `String.TrimEnd` with a single backslash character.

Remaining skipped-test search:

```text
No -Skip markers found under tests.
```

Per-function source diffs:

### Get-RegistryKeyHiveObj
```diff
diff --git a/src/Get-RegistryKeyHiveObj.ps1 b/src/Get-RegistryKeyHiveObj.ps1
index 7f161b9..b2f55c2 100644
--- a/src/Get-RegistryKeyHiveObj.ps1
+++ b/src/Get-RegistryKeyHiveObj.ps1
@@ -30,42 +30,42 @@ Begin {
     'Result',  'RegistryHive'
   ))
   Switch ($KeyHive) {
-    { $PSItem -in @(,  'HKCR',  'HKEY_CLASSES ROOT',  'ClassesRoot',  '-2147483648') } {
+    { $PSItem -in @('HKCR',  'HKEY_CLASSES_ROOT',  'ClassesRoot',  '-2147483648') } {
       Set-Variable -Name: 'RegistryHive'  -Value:([Hashtable]@{
         Name          =  'HKEY_CLASSES_ROOT'
         ShortName    =  'ClassesRoot'
         Abbreviation =  'HKCR'
       })
     }
-    { $PSItem -in @(,  'HKCU',  'HKEY_CURRENT_USER',  'CurrentUser',  '-2147483647') } {
+    { $PSItem -in @('HKCU',  'HKEY_CURRENT_USER',  'CurrentUser',  '-2147483647') } {
       Set-Variable -Name:'RegistryHive'  -Value:([Hashtable]@{
         Name          =  'HKEY_CURRENT_USER'
         ShortName    =  'CurrentUser'
         Abbreviation =  'HKCU'
       })
     }
-    { $PSItem -in @(,  'HKLM',  'HKEY_LOCAL_MACHINE',  'LocalMachine',  '-2147483646') } {
+    { $PSItem -in @('HKLM',  'HKEY_LOCAL_MACHINE',  'LocalMachine',  '-2147483646') } {
       Set-Variable -Name:'RegistryHive'  -Value:([Hashtable]@{
         Name          =  'HKEY_LOCAL_MACHINE'
         ShortName    =  'LocalMachine'
         Abbreviation =  'HKLM'
       })
     }
-    { $PSItem -in @(,  'HKU',  'HKEY_USERS',  'Users',  '-2147483645')  } {
+    { $PSItem -in @('HKU',  'HKEY_USERS',  'Users',  '-2147483645')  } {
       Set-Variable -Name: 'RegistryHive'  -Value:([Hashtable]@{
         Name          =  'HKEY_USERS'
         ShortName    =  'Users'
         Abbreviation =  'HKU'
       })
     }
-    { $PSItem -in @(,  'HKPD',  'HKEY_PERFORMANCE_DATA',  'PerformanceData',  '-2147483644') } {
+    { $PSItem -in @('HKPD',  'HKEY_PERFORMANCE_DATA',  'PerformanceData',  '-2147483644') } {
       Set-Variable -Name: 'RegistryHive'  -Value:([Hashtable]@{
         Name          =  'HKEY_PERFORMANCE_DATA'
         ShortName    =  'PerformanceData'
         Abbreviation =  'HKPD'
       })
     }
-    { $PSItem -in @(,  'HKCC',  'HKEY_CURRENT_CONFIG',  'CurrentConfig',  '-2147483643') } {
+    { $PSItem -in @('HKCC',  'HKEY_CURRENT_CONFIG',  'CurrentConfig',  '-2147483643') } {
       Set-Variable -Name:'RegistryHive'  -Value:([Hashtable]@{
         Name          =  'HKEY_CURRENT_CONFIG'
         ShortName    =  'CurrentConfig'
```

### Get-RegistryKeyPathStr
```diff
diff --git a/src/Get-RegistryKeyPathStr.ps1 b/src/Get-RegistryKeyPathStr.ps1
index be00b4c..d2b6f4d 100644
--- a/src/Get-RegistryKeyPathStr.ps1
+++ b/src/Get-RegistryKeyPathStr.ps1
@@ -35,7 +35,7 @@ Function Get-RegistryKeyPathStr {
     # Key names cannot any non-printable characters.

   Set-Variable -Name:'KeyPathHasNonPrintChars'  -Value:([System.Boolean](
-    $KeyName -match  '\P{Cc}\p{Cn}\p{Cs}'
+    $KeyPath -match  '[\p{Cc}\p{Cn}\p{Cs}]'
   ))
   If ($KeyPathHasNonPrintChars -eq $True) {
     ThrowError `
```

### Get-RegistryKeyNameStr
```diff
diff --git a/src/Get-RegistryKeyNameStr.ps1 b/src/Get-RegistryKeyNameStr.ps1
index ce8cb6e..7cd58bd 100644
--- a/src/Get-RegistryKeyNameStr.ps1
+++ b/src/Get-RegistryKeyNameStr.ps1
@@ -43,7 +43,7 @@ Function Get-RegistryKeyNameStr {
     }
     # Key names cannot any non-printable characters.
     Set-Variable -Name:'KeyNameHasNonPrintChars'  -Value:([System.Boolean] (
-      $KeyName -match  '\P{Cc}\p{Cn}\p{Cs}'
+      $KeyName -match  '[\p{Cc}\p{Cn}\p{Cs}]'
     ))
     If ($KeyNameHasNonPrintChars -eq $True) {
       ThrowError `
```

### Get-RegistryValueNameStr
```diff
diff --git a/src/Get-RegistryValueNameStr.ps1 b/src/Get-RegistryValueNameStr.ps1
index 1350bf5..6214fd7 100644
--- a/src/Get-RegistryValueNameStr.ps1
+++ b/src/Get-RegistryValueNameStr.ps1
@@ -31,7 +31,7 @@ Function Get-RegistryValueNameStr {
     ))
     # Key names cannot any non-printable characters.
     Set-Variable -Name:'IsNonPrintable'  -Value:([System.Boolean](
-      $ValueName -match  '\P{Cc}\p{Cn}\p{Cs}'
+      $ValueName -match  '[\p{Cc}\p{Cn}\p{Cs}]'
     ))
     If ($IsNonPrintable -eq $True) {
       # mn wwe ce wen oa cp nmr tem cin on cam cam wo um: mm came am Me ah sO OSs i ee oe  ee ee
```

### Get-NormalizedRegistryKey
```diff
diff --git a/src/Get-NormalizedRegistryKey.ps1 b/src/Get-NormalizedRegistryKey.ps1
index 383c2d5..dd1185a 100644
--- a/src/Get-NormalizedRegistryKey.ps1
+++ b/src/Get-NormalizedRegistryKey.ps1
@@ -42,7 +42,7 @@ $True )]
         ))
         # Test of string uses double backslashes in the key path.
         Set-Variable -Name: 'HasDoubleSLashes'  -Value:([System.Boolean](
-            $RegistryKeyStr -contains ('\\')
+            $RegistryKeyStr -match ('\\{2,}')
         ))
         # If the string has any instances of double backslashes  '\',  replace all instances of two or more
         #     backslashes with a single backslash. This gives us the ability to reliably extract specific
@@ -69,7 +69,7 @@ $True )]
             # about
             #     changing the registry key string format in the source file(s) to match the desired format.
             Set-Variable -Name: 'RegistryKeyStr'  -Value:([System.String](
-                 $RegistryKeyStr.TrimEnd('/')
+                 $RegistryKeyStr.TrimEnd('\')
              ))
         }
         # Explicitly set the Result Object before returning it so it can be easily and predictably analized
```

Scoped test diff:

```diff
diff --git a/tests/Get-NormalizedRegistryKey.Tests.ps1 b/tests/Get-NormalizedRegistryKey.Tests.ps1
index 4858fad..931105f 100644
--- a/tests/Get-NormalizedRegistryKey.Tests.ps1
+++ b/tests/Get-NormalizedRegistryKey.Tests.ps1
@@ -8,12 +8,12 @@ Describe 'Get-NormalizedRegistryKey' {
       Should -Be 'HKEY_LOCAL_MACHINE\Software'
   }

-  It 'collapses doubled backslashes' -Skip {
+  It 'collapses doubled backslashes' {
     Get-NormalizedRegistryKey -RegistryKey 'HKEY_LOCAL_MACHINE\\Software' |
       Should -Be 'HKEY_LOCAL_MACHINE\Software'
   }

-  It 'removes a trailing backslash' -Skip {
+  It 'removes a trailing backslash' {
     Get-NormalizedRegistryKey -RegistryKey 'HKEY_LOCAL_MACHINE\Software\' |
       Should -Be 'HKEY_LOCAL_MACHINE\Software'
   }
diff --git a/tests/Get-RegistryKeyHiveObj.Tests.ps1 b/tests/Get-RegistryKeyHiveObj.Tests.ps1
index 3171f74..7a7d7c7 100644
--- a/tests/Get-RegistryKeyHiveObj.Tests.ps1
+++ b/tests/Get-RegistryKeyHiveObj.Tests.ps1
@@ -16,12 +16,20 @@ Describe 'Get-RegistryKeyHiveObj' {
     $result.Abbreviation | Should -Be 'HKLM'
   }

+  It 'returns the hive descriptor for the HKCR full hive name' {
+    $result = Get-RegistryKeyHiveObj -KeyHive 'HKEY_CLASSES_ROOT'
+
+    $result.Name | Should -Be 'HKEY_CLASSES_ROOT'
+    $result.ShortName | Should -Be 'ClassesRoot'
+    $result.Abbreviation | Should -Be 'HKCR'
+  }
+
   It 'throws for an invalid hive' {
     { Get-RegistryKeyHiveObj -KeyHive 'NOPE' } |
       Should -Throw -ExpectedMessage 'Invalid registry hive specified.'
   }

-  It 'returns the hive descriptor for an abbreviated hive alias' -Skip {
+  It 'returns the hive descriptor for an abbreviated hive alias' {
     $result = Get-RegistryKeyHiveObj -KeyHive 'HKLM'

     $result.Name | Should -Be 'HKEY_LOCAL_MACHINE'
diff --git a/tests/Get-RegistryKeyNameStr.Tests.ps1 b/tests/Get-RegistryKeyNameStr.Tests.ps1
index f74b6f1..1f47686 100644
--- a/tests/Get-RegistryKeyNameStr.Tests.ps1
+++ b/tests/Get-RegistryKeyNameStr.Tests.ps1
@@ -17,7 +17,7 @@ Describe 'Get-RegistryKeyNameStr' {
       Should -Throw -ExpectedMessage 'Invalid registry key name specified.'
   }

-  It 'throws for non-printable characters' -Skip {
+  It 'throws for non-printable characters' {
     { Get-RegistryKeyNameStr -KeyName "Bad`0Name" } |
       Should -Throw -ExpectedMessage 'Invalid registry key name specified.'
   }
diff --git a/tests/Get-RegistryKeyPathStr.Tests.ps1 b/tests/Get-RegistryKeyPathStr.Tests.ps1
index 79e3db9..3851231 100644
--- a/tests/Get-RegistryKeyPathStr.Tests.ps1
+++ b/tests/Get-RegistryKeyPathStr.Tests.ps1
@@ -12,7 +12,7 @@ Describe 'Get-RegistryKeyPathStr' {
     Get-RegistryKeyPathStr -KeyPath '\Software\\Vendor\' | Should -Be 'Software\Vendor'
   }

-  It 'throws for non-printable characters' -Skip {
+  It 'throws for non-printable characters' {
     { Get-RegistryKeyPathStr -KeyPath "Software`0Vendor" } |
       Should -Throw -ExpectedMessage 'Invalid registry key name specified.'
   }
diff --git a/tests/Get-RegistryValueNameStr.Tests.ps1 b/tests/Get-RegistryValueNameStr.Tests.ps1
index 33d85b3..b86965c 100644
--- a/tests/Get-RegistryValueNameStr.Tests.ps1
+++ b/tests/Get-RegistryValueNameStr.Tests.ps1
@@ -16,7 +16,7 @@ Describe 'Get-RegistryValueNameStr' {
     Get-RegistryValueNameStr -ValueName 'Setting' | Should -Be 'Setting'
   }

-  It 'throws for non-printable characters' -Skip {
+  It 'throws for non-printable characters' {
     { Get-RegistryValueNameStr -ValueName "Bad`0Name" } |
       Should -Throw -ExpectedMessage 'Invalid registry key name specified.'
   }
```

Build-doc diff:

```diff
diff --git a/docs/build/flagged-decisions.md b/docs/build/flagged-decisions.md
index a160a71..d675799 100644
--- a/docs/build/flagged-decisions.md
+++ b/docs/build/flagged-decisions.md
@@ -14,8 +14,9 @@ the default error path while later aliases such as `HKEY_LOCAL_MACHINE` work.
 Proposed both-compatible fix: remove the leading comma in each comparison array,
 for example `@('HKLM', 'HKEY_LOCAL_MACHINE', 'LocalMachine', '-2147483646')`.

-Status: not applied. The runnable copy passes full-name and invalid-hive tests;
-the abbreviated-alias test is skipped pending owner approval.
+Status: RESOLVED - owner-approved, applied 2026-06-09. The runnable copy now
+matches abbreviated aliases, and the HKCR full-name OCR artifact is corrected in
+`src/`; `recovered/canonical/` remains unchanged.

 ## Registry Name/Path/Value Non-Printable Validation

@@ -34,8 +35,9 @@ Printed/canonical behavior:
 Proposed both-compatible fix: test the actual input variable and use a character
 class such as `[\p{Cc}\p{Cn}\p{Cs}]`.

-Status: not applied. Normal printable values and the backslash key-name throw path
-are tested; non-printable throw tests are skipped pending owner approval.
+Status: RESOLVED - owner-approved, applied 2026-06-09. The runnable copies now
+test the actual path/name/value input and use a Unicode-category character class
+for non-printable validation; `recovered/canonical/` remains unchanged.

 ## Get-NormalizedRegistryKey - Double and Trailing Backslash Normalization

@@ -49,5 +51,6 @@ Printed/canonical behavior:
 Proposed both-compatible fix: use `-match ('\\{2,}')` for doubled backslashes and
 `TrimEnd('\')` for the trailing-backslash branch.

-Status: not applied. The no-normalization-needed path is tested; doubled and
-trailing backslash tests are skipped pending owner approval.
+Status: RESOLVED - owner-approved, applied 2026-06-09. The runnable copy now uses
+regex matching for doubled backslashes and trims trailing registry backslashes;
+`recovered/canonical/` remains unchanged.
diff --git a/docs/build/make-it-run-log.md b/docs/build/make-it-run-log.md
index e7d8ac0..f404bfa 100644
--- a/docs/build/make-it-run-log.md
+++ b/docs/build/make-it-run-log.md
@@ -128,3 +128,19 @@ Runnable copy: `src/Convert-ByteArrayToHexString.ps1`
 | Canonical token | Running token | Class | Evidence |
 | --- | --- | --- | --- |
 | `g$Result += [String]::Format(...)` | `$Result += [String]::Format(...)` | i | Page image `_recovery/06042026_001/images/page-0010.png` shows `$Result +=`; `g` is an OCR glyph artifact. |
+
+## Phase 6 Build 3 - Applied Owner-Approved Flagged Fixes
+
+Source record: `recovered/canonical/` remains unchanged.
+
+Runnable copies: scoped `src/` functions only.
+
+| Function | Before | After | Class | Evidence |
+| --- | --- | --- | --- | --- |
+| `Get-RegistryKeyHiveObj` | six switch comparison arrays shaped `@(,  'HKCR', ...)` | six arrays shaped `@('HKCR', ...)` | owner-approved behavior fix | `docs/build/flagged-decisions.md`; owner approved applying the flagged fix on 2026-06-09. |
+| `Get-RegistryKeyHiveObj` | `'HKEY_CLASSES ROOT'` | `'HKEY_CLASSES_ROOT'` | owner-approved OCR artifact fix | `docs/build/flagged-decisions.md`; TASK Build 3 A0 names the HKCR missing underscore correction. |
+| `Get-RegistryKeyPathStr` | `$KeyName -match  '\P{Cc}\p{Cn}\p{Cs}'` | `$KeyPath -match  '[\p{Cc}\p{Cn}\p{Cs}]'` | owner-approved behavior fix | `docs/build/flagged-decisions.md`; the approved fix tests the actual parameter and uses a character class. |
+| `Get-RegistryKeyNameStr` | `$KeyName -match  '\P{Cc}\p{Cn}\p{Cs}'` | `$KeyName -match  '[\p{Cc}\p{Cn}\p{Cs}]'` | owner-approved behavior fix | `docs/build/flagged-decisions.md`; the approved fix uses a character class. |
+| `Get-RegistryValueNameStr` | `$ValueName -match  '\P{Cc}\p{Cn}\p{Cs}'` | `$ValueName -match  '[\p{Cc}\p{Cn}\p{Cs}]'` | owner-approved behavior fix | `docs/build/flagged-decisions.md`; the approved fix uses a character class. |
+| `Get-NormalizedRegistryKey` | `$RegistryKeyStr -contains ('\\')` | `$RegistryKeyStr -match ('\\{2,}')` | owner-approved behavior fix | `docs/build/flagged-decisions.md`; the approved fix uses regex matching for doubled backslashes. |
+| `Get-NormalizedRegistryKey` | `$RegistryKeyStr.TrimEnd('/')` | `$RegistryKeyStr.TrimEnd('\')` | owner-approved behavior fix | `docs/build/flagged-decisions.md`; the approved fix trims trailing registry backslashes. |
```

Recovered canonical status:

```text
recovered/canonical status clean.
```

ADR Draft check:

```text
ADR Draft check clean.
```

Sensitive scan:

```text
git : warning: in the working copy of '_handoff/REPORT.md', LF will be replaced by CRLF the next time Git touches it
At line:95 char:12
+   $added = git -c core.autocrlf=false diff --unified=0 | Where-Object ...
+            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (warning: in the... Git touches it:String) [], RemoteException
    + FullyQualifiedErrorId : NativeCommandError

warning: in the working copy of '_handoff/TASK.md', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'docs/build/flagged-decisions.md', LF will be replaced by CRLF the next time Git
touches it
warning: in the working copy of 'docs/build/make-it-run-log.md', LF will be replaced by CRLF the next time Git touches
it
warning: in the working copy of 'src/Get-NormalizedRegistryKey.ps1', LF will be replaced by CRLF the next time Git
touches it
warning: in the working copy of 'src/Get-RegistryKeyHiveObj.ps1', LF will be replaced by CRLF the next time Git
touches it
warning: in the working copy of 'src/Get-RegistryKeyNameStr.ps1', LF will be replaced by CRLF the next time Git
touches it
warning: in the working copy of 'src/Get-RegistryKeyPathStr.ps1', LF will be replaced by CRLF the next time Git
touches it
warning: in the working copy of 'src/Get-RegistryValueNameStr.ps1', LF will be replaced by CRLF the next time Git
touches it
warning: in the working copy of 'tests/Get-NormalizedRegistryKey.Tests.ps1', LF will be replaced by CRLF the next time
Git touches it
warning: in the working copy of 'tests/Get-RegistryKeyHiveObj.Tests.ps1', LF will be replaced by CRLF the next time
Git touches it
warning: in the working copy of 'tests/Get-RegistryKeyNameStr.Tests.ps1', LF will be replaced by CRLF the next time
Git touches it
warning: in the working copy of 'tests/Get-RegistryKeyPathStr.Tests.ps1', LF will be replaced by CRLF the next time
Git touches it
warning: in the working copy of 'tests/Get-RegistryValueNameStr.Tests.ps1', LF will be replaced by CRLF the next time
Git touches it
Sensitive scan clean for added diff lines.
```

Branch:

```text
recovery/phase6-build-3
```

Current status before commit:

```text
## recovery/phase6-build-3
 M _handoff/CLAUDE-RESTART-PROMPT.md
 M _handoff/PLAN.md
 M _handoff/REPORT-ARCHIVE.md
 M _handoff/REPORT.md
 M _handoff/TASK.md
 M docs/build/flagged-decisions.md
 M docs/build/make-it-run-log.md
 M src/Get-NormalizedRegistryKey.ps1
 M src/Get-RegistryKeyHiveObj.ps1
 M src/Get-RegistryKeyNameStr.ps1
 M src/Get-RegistryKeyPathStr.ps1
 M src/Get-RegistryValueNameStr.ps1
 M tests/Get-NormalizedRegistryKey.Tests.ps1
 M tests/Get-RegistryKeyHiveObj.Tests.ps1
 M tests/Get-RegistryKeyNameStr.Tests.ps1
 M tests/Get-RegistryKeyPathStr.Tests.ps1
 M tests/Get-RegistryValueNameStr.Tests.ps1
```

Commit-signing preflight:

```text
commit.gpgsign=true
gpg.format=ssh
```

Final signed-commit verification:

```text
Pending final `git log --show-signature -1` after the final commit exists. Recording the final commit signature inside the same committed report is self-referential; I will run it after commit and include the output in the PR body and final handback.
```

## Deviations from `TASK.md` and why

- `pwsh` is not installed, so PowerShell 7 verification is compatibility analysis rather than execution.
- Final `git log --show-signature -1` cannot be embedded in the same final commit it verifies without an endless amend cycle; it will be captured after commit in the PR body and handback.

## Open objections that must be resolved before advancing

- None. The approved fixes are applied and the previously skipped paths now pass.

## Owner decisions needed

- Review PR diffs before merge. Codex must not merge.

Phase 6 build 3 status: COMPLETE