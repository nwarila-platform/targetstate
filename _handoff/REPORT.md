Phase 6 build 4 status: COMPLETE

## Adversarial review verdict

Goal: execute Phase 6 build 4 on branch `recovery/phase6-build-4`: create the runnable `src/Mount-RegistryHive.ps1` from the faithful canonical source, applying only the owner-approved make-it-run fixes and completions; add Pester mocks proving no live registry mount occurs; append the Mount-RegistryHive make-it-run log; verify parse, mocked tests, fidelity, hygiene, signing; open a PR to `main`; and stop for owner review.

Decision: PROCEED and COMPLETE for the scoped implementation. The task is narrow, owner-approved, testable offline with mocks, and aligned with ADR 0006's no-live-registry guardrail. I changed only `Mount-RegistryHive`-scoped runnable source/tests/build documentation plus the required handoff report/archive files. A new WhatIf/internal-variable-cmdlet ambiguity was discovered, documented in `docs/build/flagged-decisions.md`, and not fixed.

Branch check: `recovery/phase6-build-4`, not `main`.

Chosen output locations: `_handoff/REPORT.md`, `_handoff/REPORT-ARCHIVE.md`, `src/Mount-RegistryHive.ps1`, `tests/Mount-RegistryHive.Tests.ps1`, `docs/build/make-it-run-log.md`, and `docs/build/flagged-decisions.md`.

Applied changes vs approved set:

| Approved item | Applied handling |
| --- | --- |
| `[System.Boolean]::Empty` | Replaced with `$False` for the two Boolean initializers. |
| `[CmdletBinding(,,` OCR artifact | Removed the doubled comma; also removed the leading first-argument separator in `[Parameter(...)]` under the already-approved metadata separator cleanup pattern. |
| Stray `;` and garbled `# ---- J` comment | Removed obsolete commented ThrowError draft including the stray semicolon; corrected the command separator comment to `# ----------------------------------`. |
| `System.I0.IOException` | Corrected to `System.IO.IOException` inside the restored structured `ThrowError`. |
| `[System.Nullable]$Null` soft return | Replaced with `$Null`. |
| Brace fix | Closed the failure `If` immediately after `ThrowError`; success-path result/debug now run outside the failure branch. |
| Cleanup list | End cleanup now lists `Result`, `RegistryKeyStr`, `ShouldMountRegistry`, `RegistryIsMounted`. |
| Structured `ThrowError` | Replaced bare throw with `RegistryHiveMountFailed`, `InvalidOperation`, `System.IO.IOException`, `$RegistryHive`, and literal message `Unable to mount registry`. Literal message is used because the module `$LocalizedData` table remains a pending module-assembly item. |
| `ShouldProcess` | Wrapped `New-PSDrive` with `ShouldProcess($RegistryHive.Name, 'Mount registry hive')`; removed malformed null arguments. |

Mocking confirmation: `tests/Mount-RegistryHive.Tests.ps1` mocks both `Test-Path` and `New-PSDrive`; assertions prove `New-PSDrive` call counts are 0 for already-mounted and `-WhatIf`, and 1 for mount-attempt paths. No real registry mount is invoked by tests.

## What changed

- Added `src/Mount-RegistryHive.ps1`, preserving the owner's Begin/Process/End structure, `New-Variable -Private` pattern, colon-parameter syntax, comments, soft return, and spacing as closely as the approved make-it-run changes allow.
- Added `tests/Mount-RegistryHive.Tests.ps1` with four mocked Pester cases: already mounted, unmounted then mounted, mount failure with structured error, and `-WhatIf` no-mount behavior.
- Appended a Phase 6 Build 4 section to `docs/build/make-it-run-log.md` mapping each canonical token to the runnable token/class/evidence.
- Added a new `docs/build/flagged-decisions.md` section for the discovered `-WhatIf` propagation to internal variable cmdlets.
- Archived the prior Build 3 `REPORT.md` to the top of `REPORT-ARCHIVE.md`.
- Preserved pre-existing Claude/owner edits to `PLAN.md`, `TASK.md`, and `CLAUDE-RESTART-PROMPT.md` as-is.

## What was intentionally not changed

- `recovered/**` was not modified; `recovered/canonical/Mount-RegistryHive.ps1` remains the faithful record.
- No other `src/` functions or tests were changed.
- No PDFs, `_recovery/`, live registry/system state, ADR statuses, module manifest, dispatcher/Test/Set implementation, or `.mof` files were changed.
- I did not assemble a `$LocalizedData` table or invent a new localized message key; the restored `ThrowError` uses a literal message as TASK allowed.
- I did not change the internal variable-cmdlet behavior under `-WhatIf`; it is flagged for owner review.

## Verification output

Parse:

```text
PowerShellVersion=5.1.26100.8457
Mount-RegistryHive: ParseErrors=0
```

Scoped Pester for `Mount-RegistryHive`:

```text
What if: Performing the operation "New variable" on target "Name: Result Value: ".
What if: Performing the operation "New variable" on target "Name: RegistryKeyStr Value: ".
What if: Performing the operation "New variable" on target "Name: ShouldMountRegistry Value: False".
What if: Performing the operation "New variable" on target "Name: RegistryIsMounted Value: False".
What if: Performing the operation "Set variable" on target "Name: ShouldMountRegistry Value: True".
What if: Performing the operation "Set variable" on target "Name: RegistryIsMounted Value: True".
What if: Performing the operation "Set variable" on target "Name: Result Value: ".
PesterVersion=5.7.1
Total=4 Passed=4 Failed=0 Skipped=0 Inconclusive=0 NotRun=0
```

Full Pester suite:

```text
What if: Performing the operation "New variable" on target "Name: Result Value: ".
What if: Performing the operation "New variable" on target "Name: RegistryKeyStr Value: ".
What if: Performing the operation "New variable" on target "Name: ShouldMountRegistry Value: False".
What if: Performing the operation "New variable" on target "Name: RegistryIsMounted Value: False".
What if: Performing the operation "Set variable" on target "Name: ShouldMountRegistry Value: True".
What if: Performing the operation "Set variable" on target "Name: RegistryIsMounted Value: True".
What if: Performing the operation "Set variable" on target "Name: Result Value: ".
PesterVersion=5.7.1
Total=29 Passed=29 Failed=0 Skipped=0 Inconclusive=0 NotRun=0
```

PowerShell 7 availability:

```text
pwsh: NOT FOUND
```

PowerShell 7 compatibility analysis: `pwsh` is not installed in this environment. The runnable function uses PowerShell/.NET constructs available in both Windows PowerShell 5.1 and PowerShell 7: advanced functions, `ShouldProcess`, `Test-Path`, `New-PSDrive`, `Try/Catch`, hashtable property access, `New-Variable`/`Set-Variable`/`Remove-Variable`, and the existing `ThrowError` helper.

Fidelity diff, canonical to runnable:

```diff
diff --git "a/recovered\\canonical\\Mount-RegistryHive.ps1" "b/src\\Mount-RegistryHive.ps1"
index 7bd8c67..d8a67a8 100644
--- "a/recovered\\canonical\\Mount-RegistryHive.ps1"
+++ "b/src\\Mount-RegistryHive.ps1"
@@ -1,14 +1,14 @@
 Function Mount-RegistryHive {
   [CmdletBinding(
-    ,,  ConfirmImpact            =  'Low'
+       ConfirmImpact            =  'Low'
     ,  DefaultParameterSetName =  'Default'
     ,  PositionalBinding       = $True
 
-  ,  SupportsShouldProcess   = $True
-)]
+    ,  SupportsShouldProcess   = $True
+  )]
 Param(
   [Parameter(
-    , Mandatory          = $True
+    Mandatory          = $True
     ,  ParameterSetName  =  'Default'
     ,  Position           = 0
     , ValueFromPipeline = $True
@@ -22,8 +22,8 @@ Begin {
   # Initalize Variables
   New-Variable -Name: 'Result'               -Force -Option:('Private') -Value:( $Null  )
   New-Variable -Name:'RegistryKeyStr'       -Force -Option:('Private') -Value:(  [System.String]::Empty   )
-  New-Variable -Name:'ShouldMountRegistry'  -Force -Option:('Private') -Value:(  [System.Boolean]::Empty )
-  New-Variable -Name: 'RegistryIsMounted'    -Force -Option:('Private') -Value:(  [System.Boolean]::Empty )
+  New-Variable -Name:'ShouldMountRegistry'  -Force -Option:('Private') -Value:(  $False )
+  New-Variable -Name: 'RegistryIsMounted'    -Force -Option:('Private') -Value:(  $False )
   Write-Debug -Message:'Exiting Block:  Begin'
 } Process {
   Write-Debug -Message:'Entering Block:  Process'
@@ -39,9 +39,9 @@ Begin {
     )
   )
   If ($ShouldMountRegistry) {
-    If ($PSCmdlet.ShouldProcess(''),  $null,  $null) {
+    If ($PSCmdlet.ShouldProcess($RegistryHive.Name,  'Mount registry hive')) {
       Try {
-        # ---------------------------------- J
+        # ----------------------------------
         New-PSDrive `
           -Name:($RegistryHive.Abbreviation) `
           -PSProvider:('Registry') `
@@ -58,16 +58,16 @@ Begin {
   ))
   # If registry is not correctly mounted,  then we need to throw an error.
   If ($RegistryIsMounted -eq $False) {
-      Throw "Unable to mount registry"
-      # ThrowError                                  `
-      #     -ErrorId: 'InvalidRegistryKeyName ' `
-      #     -ErrorCategory: 'InvalidArgument' `
-      #     -ExceptionName: 'System.I0.IOException' `
-      #     -ExceptionObject:$RegistryKey `
-  ;   #     -ExceptionMessage: $LocalizedData. InvalidRegistryKeyNameSpecified
+      ThrowError                                  `
+          -ErrorId: 'RegistryHiveMountFailed' `
+          -ErrorCategory: 'InvalidOperation' `
+          -ExceptionName: 'System.IO.IOException' `
+          -ExceptionObject:$RegistryHive `
+          -ExceptionMessage: 'Unable to mount registry'
+  }
   # It's always desirable to explicitly set the Result object with its desired class as close
   #   to the soft return to ensure the output is predictable and easily traceable.
-  Set-Variable -Name:'Result'  -Value:([System.Nullable]$Null)
+  Set-Variable -Name:'Result'  -Value:($Null)
 
     # Do a  'soft'  return by outputting the result to the pipe without using the return function
     #   which would immediately end the function,  this enables us to have the very last
@@ -81,7 +81,7 @@ Begin {
     #   technically required as they will automatically be disposed of when leaving a function,
     #   but I consider this best practice as it forces me to be mindful of all used variables.
     Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
-             'RegistryKey',  'REGISTRY_NAME',  'Result',  'RegistryKeyStr',  'ShouldMountDrive'
+             'Result',  'RegistryKeyStr',  'ShouldMountRegistry',  'RegistryIsMounted'
          ))
     Write-Debug -Message:'Exiting Block:  End'
   }
```

Recovered canonical status:

```text
(no output)
```

ADR Draft check:

```text
(no output)
```

Live registry mutation scan:

```text
(no output)
```

Sensitive scan:

```text
Sensitive scan clean for added tracked diff lines and untracked files.
```

Branch:

```text
recovery/phase6-build-4
```

Current status before commit:

```text
## recovery/phase6-build-4
 M _handoff/CLAUDE-RESTART-PROMPT.md
 M _handoff/PLAN.md
 M _handoff/REPORT-ARCHIVE.md
 M _handoff/REPORT.md
 M _handoff/TASK.md
 M docs/build/flagged-decisions.md
 M docs/build/make-it-run-log.md
?? src/Mount-RegistryHive.ps1
?? tests/Mount-RegistryHive.Tests.ps1
```

Commit-signing preflight:

```text
true
ssh
```

Final signed-commit verification:

```text
Pending final `git log --show-signature -1` after the final commit exists. Recording the final commit signature inside the same committed report is self-referential; I will run it after commit and include the output in the PR body and final handback.
```

## Deviations from `TASK.md` and why

- `pwsh` is not installed, so PowerShell 7 verification is compatibility analysis rather than execution.
- A new ambiguity was found: `-WhatIf` propagates to internal `New-Variable`/`Set-Variable` calls. I flagged it in `docs/build/flagged-decisions.md` and did not change behavior.
- Final `git log --show-signature -1` cannot be embedded in the same final commit it verifies without an endless amend cycle; it will be captured after commit in the PR body and handback.

## Open objections that must be resolved before advancing

- None that block the Build 4 implementation. The WhatIf/internal-variable behavior should be reviewed before relying on `-WhatIf` as a clean bookkeeping-preserving path in later registry mutation work.

## Owner decisions needed

- Decide how to handle `Mount-RegistryHive -WhatIf` propagation to internal variable cmdlets: accept current behavior for now, add explicit `-WhatIf:$False` to internal variable cmdlets, or approve a broader style change away from variable cmdlets for internal state.
- Review the restored structured `ThrowError` shape and the literal mount-failure message before module-localized messages are assembled.
- Review PR diffs before merge. Codex must not merge.

Phase 6 build 4 status: COMPLETE