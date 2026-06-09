Phase 6 build 1 status: COMPLETE

## Adversarial review verdict

Goal: execute Phase 6 build 1 on branch `recovery/phase6-build-1`: copy only
`recovered/canonical/Get-RegistryValueKindStr.ps1` into `src/`, make that one
function parse and run on Windows PowerShell 5.1 with minimal style-preserving
changes, add focused Pester tests, document every change, propose the
systematic `[Type]::Empty` mapping, push a PR to `main`, and stop for owner
review.

Decision: PROCEED and COMPLETE for this calibration. The narrow one-function
scope is correct: `Get-RegistryValueKindStr` is pure, needs no live registry
access, and is enough to expose the owner idiom decision before the build scales.
`recovered/canonical/` remains the faithful record; `src/` is the runnable copy.

Branch check: PROCEED on `recovery/phase6-build-1`, not `main`.

Chosen output locations: `src/Get-RegistryValueKindStr.ps1`,
`tests/Get-RegistryValueKindStr.Tests.ps1`,
`docs/build/make-it-run-log.md`,
`docs/build/owner-idiom-decisions.md`, `_handoff/REPORT.md`, and
`_handoff/REPORT-ARCHIVE.md`. `.gitignore` already allowlisted `src/` and
`tests/`, so it was not changed.

Classified changes applied to the runnable copy:

| Canonical token | Running token | Class |
| --- | --- | --- |
| `[System.Boolean]::Empty` for `ValueKindIsNullorEmpty` and `IsValidValueKind` | `$False` | ii - idiom mapping |
| line-wrapped `-` + `Value:` on three `New-Variable` initializers | single logical `-Value:` token | iii - minimal PS 5.1 run fix |
| `[Microsoft.Win32.RegistryValueKind]::Empty` for `NormalizedValueKind`, `ValueKindIsUnknown`, and `Result` | `[Microsoft.Win32.RegistryValueKind]::None` | ii - idiom mapping |
| no immediate typed value after `Clear-Variable` before `TryParse` | reinitialize `NormalizedValueKind` to enum `None` before `TryParse` | iii - minimal PS 5.1 run fix |
| `[Enum]::TryParse([Microsoft.Win32.RegistryValueKind], $ValueKind, [Ref ]$NormalizedValueKind)` | `[Microsoft.Win32.RegistryValueKind]::TryParse($ValueKind, [Ref ]$NormalizedValueKind)` | iii - minimal PS 5.1 run fix |

No class `i` OCR-artifact correction was applied.

## What changed

- Archived the prior `REPORT.md` to the top of `_handoff/REPORT-ARCHIVE.md`.
- Added runnable `src/Get-RegistryValueKindStr.ps1`.
- Added Pester 5 tests in `tests/Get-RegistryValueKindStr.Tests.ps1`.
- Added `docs/build/make-it-run-log.md` with every canonical-to-runnable token
  change classified.
- Added `docs/build/owner-idiom-decisions.md` with the proposed `[Type]::Empty`
  mapping for owner approval.

## What was intentionally not changed

- No other canonical function was copied, parsed for make-it-run changes, or
  tested.
- `recovered/canonical/` and `recovered/archive/` were not modified.
- No PDFs, `_recovery/`, registry state, live system state, dispatcher/Test/Set
  implementation, module manifest, `.mof`, or ADR status were changed.
- `PLAN.md`, `TASK.md`, and `CLAUDE-RESTART-PROMPT.md` content was not edited by
  Codex; their pre-existing local changes were preserved as-is.

## Verification output

Parse:

```text
ParseErrors=0
```

Pester:

```text
PesterVersion=5.7.1
Total=5 Passed=5 Failed=0 Skipped=0 Inconclusive=0 NotRun=0
Passed: returns None for an empty value kind
Passed: returns None for a whitespace value kind
Passed: returns the parsed registry value kind for a valid value kind string
Passed: throws for an invalid value kind string
Passed: throws for Unknown even though the enum parser accepts it
```

Fidelity diff:

```diff
diff --git "a/recovered\\canonical\\Get-RegistryValueKindStr.ps1" "b/src\\Get-RegistryValueKindStr.ps1"
index 563307f..365b7ed 100644
--- "a/recovered\\canonical\\Get-RegistryValueKindStr.ps1"
+++ "b/src\\Get-RegistryValueKindStr.ps1"
@@ -19,14 +19,11 @@ Function Get-RegistryValueKindStr {
   Begin {
     Write-Debug -Message:'Entering Block:  Begin'
     # Initalize DYNAMIC Variables
-    New-Variable -Force -Option:'Private'  -Name:'ValueKindIsNullorEmpty'  -Value:([System.Boolean]::Empty)
-    New-Variable -Force -Option:'Private'  -Name: 'IsValidValueKind'        -Value:([System.Boolean]::Empty)
-    New-Variable -Force -Option:'Private'  -Name: 'NormalizedValueKind'     -
-Value:([Microsoft.Win32.RegistryValueKind]::Empty)
-    New-Variable -Force -Option:'Private'  -Name: 'ValueKindIsUnknown'      -
-Value:([Microsoft.Win32.RegistryValueKind]::Empty)
-    New-Variable -Force -Option:'Private'  -Name: 'Result'                  -
-Value:([Microsoft.Win32.RegistryValueKind]::Empty)
+    New-Variable -Force -Option:'Private'  -Name:'ValueKindIsNullorEmpty'  -Value:($False)
+    New-Variable -Force -Option:'Private'  -Name: 'IsValidValueKind'        -Value:($False)
+    New-Variable -Force -Option:'Private'  -Name: 'NormalizedValueKind'     -Value:([Microsoft.Win32.RegistryValueKind]::None)
+    New-Variable -Force -Option:'Private'  -Name: 'ValueKindIsUnknown'      -Value:([Microsoft.Win32.RegistryValueKind]::None)
+    New-Variable -Force -Option:'Private'  -Name: 'Result'                  -Value:([Microsoft.Win32.RegistryValueKind]::None)
     Write-Debug -Message:'Exiting Block:  Begin'
   } Process {
     Write-Debug -Message:'Entering Block:  Process'
@@ -46,10 +43,12 @@ Value:([Microsoft.Win32.RegistryValueKind]::Empty)
       )
     } Else {
       # Validate the Registry Hive value against a list of valid and support registry hives.
+      Set-Variable -Name: 'NormalizedValueKind'  -Value:(
+        [Microsoft.Win32.RegistryValueKind]::None
+      )
       Set-Variable -Name:'IsValidValueKind'  -Value: (
         [System.Boolean] (
-          [Enum]::TryParse(
-             [Microsoft.Win32.RegistryValueKind],
+          [Microsoft.Win32.RegistryValueKind]::TryParse(
             $ValueKind,
             [Ref ]$NormalizedValueKind
           )
warning: in the working copy of 'src\Get-RegistryValueKindStr.ps1', LF will be replaced by CRLF the next time Git touches it
```

`recovered/canonical/` and `recovered/archive/` unchanged:

```text
```

All ADRs still Draft:

```text
```

`git check-ignore -v src tests`:

```text
.gitignore:19:!/src/	src
.gitignore:20:!/tests/	tests
exit=0
```

Sensitive scan over added diff lines:

```text
Sensitive scan clean for added diff lines.
warning: in the working copy of '_handoff/REPORT-ARCHIVE.md', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of '_handoff/REPORT.md', LF will be replaced by CRLF the next time Git touches it
```

`git diff --check`:

```text
warning: in the working copy of '_handoff/REPORT-ARCHIVE.md', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of '_handoff/REPORT.md', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of '_handoff/TASK.md', LF will be replaced by CRLF the next time Git touches it
```

`git status --short --branch`:

```text
## recovery/phase6-build-1
 M _handoff/CLAUDE-RESTART-PROMPT.md
 M _handoff/PLAN.md
 M _handoff/REPORT-ARCHIVE.md
 M _handoff/REPORT.md
 M _handoff/TASK.md
?? docs/build/
?? src/
?? tests/
```

Final signed-commit verification:

```text
Pending final `git log --show-signature -1` after the commit exists. Recording
the final commit signature inside the same committed report is self-referential;
the output will be run after commit and included in the PR body and handback.
```

## Deviations from `TASK.md` and why

- I used Pester `-PassThru -Output None` and printed a public-safe summary from
  the actual Pester result object. Normal Pester console output includes the
  local user-profile path, which would violate the public-repo sensitive-path
  rule.
- The printed `[Enum]::TryParse` form does not bind under Windows PowerShell 5.1
  in this environment, and PS 5.1 cannot call generic static methods with
  type-argument syntax. I kept `TryParse` but used the enum-type static
  `TryParse` form and reinitialized `NormalizedValueKind` after `Clear-Variable`
  so the by-ref target has the enum type. This is documented as a minimal
  PS 5.1 run fix for owner review.
- Final `git log --show-signature -1` output cannot be embedded in the same
  commit it verifies without an endless amend cycle; it will be captured after
  commit and included in the PR body/final response.

## Open objections that must be resolved before advancing

- Owner should confirm or revise the proposed `[Type]::Empty` idiom mapping
  before it is applied to any other function.
- Owner should confirm that the PS 5.1 `TryParse` binding fix is acceptable:
  enum-type static `TryParse` plus typed reinitialization after `Clear-Variable`.

## Owner decisions needed

- Review the PR and decide whether the make-it-run diff preserves the owner's
  style closely enough for the next function.
- Approve, reject, or revise the `[Type]::Empty` mapping in
  `docs/build/owner-idiom-decisions.md`.
- Do not merge until owner review is complete; Codex must not merge.

Phase 6 build 1 status: COMPLETE
