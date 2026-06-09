# TargetState — Unified Execution Map (Faithful Reverse-Engineering of the Owner's Registry Provider)

> Scope: This document maps **what the owner actually built** across the two recovered printout files. It cites exact line ranges. Where code is incomplete or references an undefined function, it is recorded as a **gap** — never invented or "improved." The recovered files are faithful transcriptions and do **not** parse/run as-is.
>
> Source files:
> - **A** = `recovered/06042026.ps1`
> - **B** = `recovered/06042026_001.ps1`
> - Canonical-selection matrix = `_recovery/_inventory/reconciliation-matrix.tsv`
> - DSC surface audit = `docs/dsc-audit/AUDIT.md`

---

## 1. What exists — full recovered inventory

Every recovered function, its canonical version per the Phase 2 reconciliation matrix, role, signature summary, and one-line purpose.

| # | Function | Canon | File:Lines | Role | Signature summary | Purpose (1 line) |
|---|----------|-------|-----------|------|-------------------|------------------|
| 1 | `ThrowError` | **keep_B** | B:44-101 | error-helper | `-ExceptionName -ExceptionMessage -ExceptionObject -ErrorId -ErrorCategory` → throws | Single terminating-error sink: news an exception, wraps it in an `ErrorRecord`, throws it. |
| 2 | `Start-ProviderSetup` | **keep_A** | A:1-121 | orchestrator | `-InputObject:[PSCustomObject]` → `[PSCustomObject]{RegistryKeyHive/Path/Name, RegistryValueName/Kind/Data}` | Entry-stage normalizer: validates required props, normalizes only supplied props via a property-driven Switch, mounts hive, emits canonical resource object. |
| 3 | `Get-RegistryKeyHiveObj` | **keep_A** | A:122-227 | normalizer | `-KeyHive:[String]` → `[Hashtable]{Name,ShortName,Abbreviation}` | Resolves any hive alias (abbrev/full/.NET short/numeric) to a canonical hive descriptor hashtable; throws on unknown. |
| 4 | `Get-RegistryKeyPathStr` | **keep_A** | A:228-325 | normalizer | `-KeyPath:[String]` → `[String]` | Validates path (no non-printables), collapses double backslashes, strips leading/trailing slash. |
| 5 | `Get-RegistryKeyNameStr` | **keep_A** | A:326-402 | normalizer | `-KeyName:[String]` → `[String]` | Validate-and-passthrough leaf name: rejects backslash + non-printables, returns input verbatim. |
| 6 | `Get-RegistryValueNameStr` | **keep_A** | A:403-469 | normalizer | `-ValueName:[String]` → `[String]` | Rejects non-printables; empty allowed; passes value name through unchanged. |
| 7 | `Get-RegistryValueKindStr` | **keep_A** | A:470-568 | normalizer | `-ValueKind:[String]` → `[Microsoft.Win32.RegistryValueKind]` | Null/empty → `None`; else `[Enum]::TryParse`; rejects `Unknown` as invalid. |
| 8 | `Mount-RegistryHive` | **keep_A** | A:569-656 | leaf (side-effect) | `-RegistryHive:[Hashtable]` → `$null` (failure path only) | Idempotent test→New-PSDrive(-Scope Script)→re-test→throw; mounts hive once for the whole run. |
| 9 | `Get-RegistryValueData` | **keep_A** | A:803-939 | converter | `-Type -Data -Hex -Result:[PSReference]` → typed value (soft-return) | A-draft value-data type coercion; DWord-nonempty/QWord/Binary branches are empty stubs. |
| 10 | `ConvertFrom-Array` | **keep_A** | A:940-1025 | converter | `-Value:[String[]]` → `[String]` | Joins an array into one `", "`-delimited string via presized StringBuilder (for comparison/error display). |
| 11 | `Get-NormalizedRegistryKey` | **keep_B** | B:185-279 | normalizer | `-RegistryKey:[String]` → `[String]` | Collapses `\\+`→`\`, strips trailing slash, gated behind precheck booleans (to later *suggest* source fixes). |
| 12 | `Get-RegistryKeyHive` | **keep_B** | B:280-357 | normalizer | `-RegistryKey:[String]` → `[String]` (e.g. `HKEY_LOCAL_MACHINE`) | Splits hive token, `Switch -Regex` maps full+short aliases to canonical long-form; throws on no match. |
| 13 | `Get-RegistryKeyPath` | **keep_B** | B:358-419 | normalizer | `-RegistryKey:[String]` → `[String]` (empty on no match) | Single named-group regex extracts the middle path segment; **no throw** path (orchestrator decides). |
| 14 | `Get-RegistryKeyName` | **keep_B** | B:420-483 | converter | `-RegistryKey:[String]` → `[String]` | Normalizes, then returns the substring after the last backslash; **throws** `InvalidRegistryKey` when no backslash. |
| 15 | `Get-RegistryResourceObject` | **keep_B** | B:485-552 | orchestrator | `-RegistryKey:[String]` → `[String]` `Hive\Path\Name` | Decomposes a key into hive/path/name and recomposes a canonical composite path. **Orphaned** in the recovered call graph. |
| 16 | `Convert-ByteArrayToHexString` | **keep_B** | B:553-592 | converter | `-ByteArray:[Object]` → `[String]` | Renders a byte array as a lowercase 2-digit hex string (`{0:x2}`). Marked `# !TODO`. |
| 17 | `Get-TypedObject` | **keep_B** | B:593-779 | converter | `-Type -Data -Hex(switch)` → `[Object]` typed value | B-draft value-data type coercion (String/MultiString/DWord/QWord/Binary, `-Hex`). Owner-flagged unfinished. |
| 18 | `Get-TargetResource` | **keep_B** | B:780-918 | **entrypoint** | `-RegistryKey [-ValueName]` (2 param sets) → `[Hashtable]{Ensure,Key,ValueName,ValueKind,ValueData}` | The realized public GET entrypoint: front-loads setup into one `Start-ProviderSetup` call, then reads only what's needed. |

**Project-wide style fingerprints** (deliberate, kept verbatim): `Begin/Process/End` blocks with `Write-Debug 'Entering/Exiting Block'` bookends; `New-Variable -Force -Option:'Private'` up-front declarations; `Clear-Variable` on Process entry and `Remove-Variable` on End ("forces me to be mindful of all used variables"); colon-parameter syntax (`-Name:`/`-Value:`/`-Message:`); **soft return** via a bare typed expression so `Write-Debug` is the last executing statement (intentional breakpoint); heavy first-person comments; `[Type]::Empty` initializer idiom (`[Boolean]::Empty`, `[Hashtable]::Empty`, etc. — not real .NET members, transcribed faithfully).

---

## 2. Every missing function (called-but-undefined)

| Function | Called by | Inferred signature | Inferred purpose | Classification |
|----------|-----------|--------------------|------------------|----------------|
| `Get-TargetResourceInternal` | Header map only (B:3) | unknown public wrapper above `Start-Provider`/`Get-TargetResource` | The header call-chain (B:1-14) names it as the *documented* top entrypoint; not defined in either file. | **sketch-name** (documentation-only; intent unclear) |
| `Get-NormalizedRegistryKeyString` | `Get-RegistryKeyName` (B:458), `Get-RegistryResourceObject` (B:517); also header (B:6,8,10,12) | `-RegistryKey:[String]` → `[String]` (normalized key) | Same role as the **defined** `Get-NormalizedRegistryKey` (B:185); invoked name carries an extra `String` suffix the definition lacks. | **ocr-variant / naming-drift** (likely a late rename of the definition; comment + 2 call sites never updated) |
| `ArrayToString` | `Get-TypedObject` (B:629, inside `ARRAY_NOT_EXPECTED_EXCEPTION_HASH`) | `-Value:[String[]]` → `[String]` (flattened display string) | Flattens value-data array into one string for an error message. Functional twin of the **defined** `ConvertFrom-Array` (A:940), which `Get-RegistryValueData` (A:868, the A-draft sibling) uses for the identical purpose. | **ocr-variant / rename-or-twin** (cannot be proven same as `ConvertFrom-Array`; not remapped) |

Additional **undefined references inside the unfinished `Get-TypedObject`** (B:593-779), recorded as gaps but not full "functions" (they read like module-scope static hashtables, not calls): `$VALUE_DATA_NOT_IN_HEX_FORMAT_HASH_EXCEPTION` (B:707,762), `$INVALID_INT_VALUE_HASH_EXCEPTION` (B:711). `$LocalizedData`/`$localizedData` is the module-scope localized-string `data` table (defined in B:15-43), not a function — an external data dependency, not a gap.

**Also missing as whole legs of the contract:** `Test-TargetResource` and `Set-TargetResource` (the other two DSC methods the unified path is meant to collapse) are **not present** in either file. Only the GET leg + shared setup are recovered.

---

## 3. Full logic / execution map — the owner's UNIFIED single execution path

### 3.1 The two entrypoints (documented vs implemented)
- **Documented** (header map, B:1-14): `Get-TargetResourceInternal` → `Start-Provider` → `Get-RegistryKeyString` → {`Get-NormalizedRegistryKeyString`, `Get-RegistryHive`, `Get-RegistryKeyPath`, `Get-RegistryKeyName`} → `Mount-RegistryHive`. **Note:** the header's names drift from the actual definitions (`Start-Provider`→`Start-ProviderSetup`; `Get-RegistryHive`→`Get-RegistryKeyHive`; `Get-RegistryKeyString` appears to be the role filled by `Get-RegistryResourceObject`).
- **Implemented**: `Get-TargetResource` (B:780-918) is the realized public entrypoint. It calls `Start-ProviderSetup` directly.

### 3.2 The single unified path (as actually wired, within file B)
The owner's "one path, run only the steps necessary" is realized by **front-loading all setup into one call** and then **pruning via `$PSCmdlet.ParameterSetName`**:

1. **ENTRY** — caller invokes `Get-TargetResource -RegistryKey [-ValueName]` (B:780-799). PowerShell binds the param set: `Default` (key only) or `HasValue` (key + value).
2. **Begin** (B:800-817) — declare all working vars typed/`$Null` via `New-Variable -Force -Option:'Private'` (`Result` hashtable, `RegistryEnsure`, `RegistryKeyStr`, `RegistryKeyExists`, `RegistryKeyObj`, `RegistryKeyValueNames`, `RegistryKeyValueExists`, `RegistryValueName`, `RegistryValueKind=Unknown`, `RegistryValueData`).
3. **Process entry** (B:818-828) — `Clear-Variable` the full set; **seed `RegistryEnsure='Absent'`** (the "set default, override only if necessary" idiom).
4. **NORMALIZE + MOUNT (one call)** (B:832-834) — `RegistryKeyStr = [String](Start-ProviderSetup -RegistryKey:($RegistryKey))`. This single call **is** the entire setup stage. *(Within B, `Start-ProviderSetup` B:102-183 runs: `Get-NormalizedRegistryKey` 139 → `Get-RegistryKeyHive` 142 → `Mount-RegistryHive` 145 → `Get-RegistryKeyPath` 147 → `Get-RegistryKeyName` 150.)*
5. **EXIST CHECK** (B:836-838) — `RegistryKeyExists = Test-Path 'Registry::{RegistryKeyStr}'`.
6. **PRUNED BRANCH** (B:842-891) — runs **only if the key exists**:
   - `Default` set → set `Ensure='Present'` and **STOP** (skip all value work). *(B:843-845)*
   - `HasValue` set → proceed to value inspection. *(B:846)* — **this is the "only necessary steps" fork.**
7. **VALUE INSPECTION** (`HasValue` only, B:846-866) — `RegistryValueName=$ValueName`; `RegistryKeyObj=Get-Item`; `RegistryKeyValueNames=$RegistryKeyObj.GetValueNames()` (explicitly chosen over `.Properties` so the empty-string `(Default)` value matches — comment B:856-859); `RegistryKeyValueExists = ValueName -in names`.
8. **VALUE-PRESENT** (B:867-889) — set `Ensure='Present'`; **display-normalize** empty value name to `$localizedData.DefaultValueDisplayName` `(Default)` (B:874-878); read `RegistryValueKind=GetValueKind()`; read `RegistryValueData=GetValue(name,$null,DoNotExpandEnvironmentNames)`.
9. **ASSEMBLE** (B:894-902) — `Result=[Hashtable]@{Ensure;Key;ValueName;ValueKind;ValueData}`, every member cast `[System.String]`.
10. **SOFT-RETURN** (B:905-906) — emit `([Hashtable]$Result)` bare; `Write-Debug 'Exiting Block: Process'` is the last executed statement.
11. **End** (B:907-918) — `Remove-Variable` the full set; final `Write-Debug`. *(B:918 is OCR-garbled; the closing brace is not legibly captured.)*

### 3.3 The normalization pipeline (ordered, run once)
The owner solves normalization as a chain of single-responsibility leaves, each composed exactly once into the single path:

1. **KEY-STRING** normalize (first, once) — `Get-NormalizedRegistryKey` (B:185-279): `\\+`→`\`, strip trailing slash, gated behind `HasDoubleSlashes`/`HasTrailingSlash` prechecks so the module can later *suggest* a source fix instead of silently rewriting.
2. **HIVE** decompose+canonicalize — `Get-RegistryKeyHive` (B:280-357): split on first `\`, `Switch -Regex` map aliases to canonical long-form; throws `InvalidRegistryHive`.
3. **MOUNT** (side-effect precondition, after hive known) — `Mount-RegistryHive` (A:569-656): `Test-Path` → `New-PSDrive -Scope:'Script'` → re-test → throw. **Mounts once and persists for the whole run.**
4. **PATH** extract — `Get-RegistryKeyPath` (B:358-419): named-group regex; **empty on no match, no throw**.
5. **NAME** extract — `Get-RegistryKeyName` (B:420-483): substring after last `\`; **throws** if no backslash.
6. **VALUE-NAME** validate — `Get-RegistryValueNameStr` (A:403-469): reject non-printables; empty allowed.
7. **VALUE-KIND** normalize — `Get-RegistryValueKindStr` (A:470-568): empty→`None`; `TryParse`; reject `Unknown`.
8. **VALUE-DATA** type-coerce (last, leaf) — `Get-TypedObject` (B:593-779) and/or `Get-RegistryValueData` (A:803-939), supported by `ConvertFrom-Array` (A:940-1025) and `Convert-ByteArrayToHexString` (B:553-592) for canonical scalar forms.
9. **DISPLAY** normalize (inside `Get-TargetResource`, not a leaf) — empty value name → `$localizedData.DefaultValueDisplayName` (B:874-878).

### 3.4 Every execution-path flow (including error/throw)
- **Happy path (Default set):** ENTRY → setup (1 call) → key exists → `Ensure='Present'` → assemble → soft-return. Value-inspection block entirely skipped.
- **Happy path (HasValue set, value present):** ENTRY → setup → key exists → enumerate value names → value found → `Ensure='Present'`, read kind+data → assemble → soft-return.
- **Absent path:** key does **not** exist (or, in `HasValue`, value not in names) → `RegistryEnsure` stays `'Absent'` → assemble → soft-return.
- **Throw paths (all route to `ThrowError` B:44-101, fed by `$LocalizedData`):**
  - Missing required prop → `ThrowError 'ParameterRequired'` (A:46-52, in `Start-ProviderSetup`; note message passes literal `'Something'` — placeholder/bug).
  - Unknown hive → `ThrowError 'InvalidRegistryHiveSpecified'` (A:199-203 in `Get-RegistryKeyHiveObj`; B `Get-RegistryKeyHive` Default arm B:342 via splat `@REGISTRY_HIVE_EXCEPTION_HASH`).
  - Non-printable path/name/value-name → `ThrowError 'InvalidRegistryKeyName'` (A:265-279 path, A:361-379 name, A:438-446 value-name).
  - Invalid value kind / `Unknown` → `ThrowError 'InvalidRegistryValueTypeSpecified'` (A:536).
  - No backslash in key → `ThrowError 'InvalidRegistryKey'` via `@REGISTRY_KEY_EXCEPTION_HASH` (B:466-468 in `Get-RegistryKeyName`).
  - Array supplied for non-MultiString type → `ThrowError "ArrayNotExpectedForType$Type"` (A:875-890; B:686 — **but the B guard can never fire**, it requires `$DataIsNull` true inside the data-present `Else`).
  - Mount failure → **bare** `Throw "Unable to mount registry"` (A:629); the structured `ThrowError` is **commented out** (A:630-635).

### 3.5 Recovered gaps (faithful — never invented)
- **Undefined documented entrypoint:** `Get-TargetResourceInternal` (header B:3) defined in neither file.
- **CANONICAL-SELECTION SEAM (biggest gap):** Phase 2 chose **keep_B** for `Get-TargetResource` but **keep_A** for `Start-ProviderSetup`. B's `Get-TargetResource` calls `Start-ProviderSetup -RegistryKey:string` and stores the result **as a normalized key string** (B:832-834). But canonical (A) `Start-ProviderSetup` takes `[PSCustomObject]$InputObject` and emits a rich `{RegistryKeyHive/Path/Name + RegistryValueName/Kind/Data}` object — **not** a string. The two canonical versions **do not interoperate.** Even B's own `Start-ProviderSetup` return object (B:162-170) is all `[System.String]::Empty` placeholders, and its caller casts that PSCustomObject to `[String]` (B:832).
- **Naming drift:** `Get-NormalizedRegistryKeyString` (B:458,517 + header) vs defined `Get-NormalizedRegistryKey` (B:185). `ArrayToString` (B:629) vs defined `ConvertFrom-Array` (A:940).
- **Unwired `HasValue` prune scaffolds:** `Start-ProviderSetup` B:152-159 and `Get-RegistryResourceObject` B:531-532 branch on `ParameterSetName -eq 'HasValue'`, but **neither declares a `HasValue` set** (only `Default`) → dead/unreachable. The prune only actually works in `Get-TargetResource` (B), which declares both sets (B:787-793).
- **Orphaned composer:** `Get-RegistryResourceObject` (B:485-552) fills the header's `Get-RegistryKeyString` role (compose `Hive\Path\Name`) but is **called by nobody** in the recovered graph.
- **Incomplete value-data converters:** `Get-RegistryValueData` (A) DWord-nonempty/QWord/Binary branches are empty stubs (A:907-918); `Get-TypedObject` is owner-flagged unfinished (`<# I am not happy with this function, needs a rework #>`) and its array guard can never fire; value-data normalization is **commented out** in A `Start-ProviderSetup` (A:85-88).
- **Mount error path degraded:** structured `ThrowError` commented out (A:630-635); Process closing brace mis-nested so soft-return and End read inside the failure branch.
- **TEST and SET legs absent** entirely.
- **Pervasive transcription artifacts** (`::Empty` pseudo-members, leading-comma attribute lists, doubled quotes, brace/bracket swaps, OCR garble e.g. B:918) — files do not parse as-is. Faithful, not corrected.

---

## 4. vs Microsoft DSC

Per the DSC audit (`docs/dsc-audit/AUDIT.md`):
- DSC's "DSC resource contract conventions" row (line 24) states MOF-based resources implement **three separate functions** `Get-TargetResource`/`Set-TargetResource`/`Test-TargetResource` (class-based: `Get()`/`Set()`/`Test()`), each a self-contained entry the LCM invokes independently. `Invoke-DscResource` (line 9) runs Get, Set, **or** Test as three distinct dispatches. The LCM (line 26) and MOF-compile boundary (line 27) are always present.

The owner's single path replaces the three orderings in four concrete, code-grounded ways:
1. **ONE entrypoint + ONE setup call** instead of three independent methods. All normalization/decomposition/mounting is front-loaded once in `Start-ProviderSetup`; the resulting canonical state object `{Ensure,Key,ValueName,ValueKind,ValueData}` is the shape Test/Set would consume — eliminating DSC's per-method re-derivation.
2. **RUN-ONLY-NECESSARY via `ParameterSetName`** (`Default` skips all value reads; `HasValue` adds them, B:842-891) replaces DSC running a fixed full method body regardless of whether a value was requested.
3. **MOUNT-ONCE:** `Mount-RegistryHive` uses `New-PSDrive -Scope:'Script'` (A:607,616) so the hive persists for the whole run, versus three method invocations each re-establishing context.
4. **NO MOF/LCM boundary** — matching the audit's "replace with TargetState-native" verdicts (lines 7,10,27). The owner reads/normalizes the key string directly: no compile step, no LCM engine.

What the audit implies is **not yet delivered**: DSC's three methods are genuinely separate **and complete**, whereas the owner's unified path currently realizes only the **Get leg + shared setup**. Test/Set are intended to fold into the same path but are **not recovered**; `Ensure` Present/Absent (audit line 24 convention) is implemented on the Get side only.

---

## 5. Clean path forward — ordered single-function build plan

Each item is **one new function or one function to complete**, so the owner can implement one at a time. Order respects dependencies. **Resolve the two design forks (§ owner questions) before starting D1/D2**, because they decide the contract every later item plugs into.

> Legend: **D**=design-decision, **R**=exists-recovered (recovered, may need a parse-clean pass), **C**=complete-incomplete, **N**=build-new-missing.

1. **(D1) Decide the `Start-ProviderSetup` contract.** Pick A's `InputObject→rich object` vs B's `RegistryKey-string→string`. Every downstream item depends on this. *(See owner question 1.)*
2. **(D2) Decide the hive return shape.** A's `{Name,ShortName,Abbreviation}` hashtable (`Get-RegistryKeyHiveObj`) vs B's canonical long-form string (`Get-RegistryKeyHive`). **`Mount-RegistryHive` (A) requires `.Abbreviation`/`.Name`, which only A's hashtable provides** — so D2 and the mount wiring are coupled. *(See owner question 6.)*
3. **(R) Reconcile the normalizer name** `Get-NormalizedRegistryKey` ↔ `Get-NormalizedRegistryKeyString`. Single canonical name; update the 2 call sites (B:458,517) and header. Depends on: nothing.
4. **(R) Reconcile** `ConvertFrom-Array` ↔ `ArrayToString` to one canonical array-flatten helper. Depends on: nothing.
5. **(C) Complete `Mount-RegistryHive`** (A:569-656): restore the structured `ThrowError` (uncomment A:630-635), fix the mis-nested Process brace, align the `Remove-Variable` list with declared vars. Depends on: D2, ThrowError (recovered).
6. **(C) Complete `Get-TypedObject`** (B:593-779) — the owner-flagged "needs a rework" value-data coercion: finish DWord-nonempty, QWord, Binary (+`-Hex`) branches; wire `ArrayToString`/`ConvertFrom-Array`; fix the array-not-expected guard that can never fire; supply the missing exception-hash statics. Depends on: items 4, `Convert-ByteArrayToHexString` (recovered), ThrowError. *(Alternatively complete A's `Get-RegistryValueData` stubs A:907-918 — pick one converter to be canonical, per owner question 7.)*
7. **(R) Finalize `Start-ProviderSetup`** to the D1 contract so its caller's cast matches its return (today B:832 casts a PSCustomObject to `[String]`). Wire it to call the canonical normalizer (item 3), hive normalizer (D2), `Mount-RegistryHive` (item 5), path/name leaves. Depends on: D1, D2, items 3,5.
8. **(N) `Test-TargetResource`** — new function: consume the `Get-TargetResource` state object + already-normalized `RegistryKeyStr` + already-mounted hive; compare desired-vs-actual; return boolean/evidence. Depends on: `Get-TargetResource` (recovered), item 6 (typed compare values), item 7.
9. **(N) `Set-TargetResource`** — new function: consume the same state object; apply (create key / set value / remove) under `ShouldProcess`; emit the localized SET/REMOVE/UNCHANGED messages already present in `$LocalizedData` (B:24-34). Depends on: item 8, item 7, item 6.
10. **(D3 / N) `Get-TargetResourceInternal`** — decide whether the header's internal wrapper is real; if so, build the thin public dispatcher that routes Get/Test/Set into the single shared setup (the owner's intended unification point). Depends on: items 7,8,9. *(See owner questions 2 and 4.)*
11. **(D / R) Decide `Get-RegistryResourceObject`'s role** (currently orphaned, B:485-552): is it the header's `Get-RegistryKeyString` stage that `Start-ProviderSetup` should call instead of inlining decomposition? Either wire it into item 7 or retire it. Depends on: item 7. *(See owner question 5.)*

---

## Owner questions (genuine forks — do not auto-resolve)

1. **Which `Start-ProviderSetup` contract is the true target** — A's `InputObject`-in / rich-PSCustomObject-out (Phase 2 canonical), or B's `RegistryKey`-string-in / setup-out that B's canonical `Get-TargetResource` actually calls? The two canonical selections are mutually incompatible.
2. **Is `Get-TargetResourceInternal` (header B:1-14) a real intended public wrapper** above `Get-TargetResource`, or stale documentation? If real, what does it add?
3. **Is `Get-NormalizedRegistryKeyString` the same as the defined `Get-NormalizedRegistryKey`** (rename in progress) or a distinct normalizer? Same question for `ArrayToString` vs `ConvertFrom-Array`.
4. **Where do Test and Set fold into the single path** — one body switching on a mode parameter (Get/Test/Set), or one shared setup feeding three thin method shims?
5. **What is the intended role of `Get-RegistryResourceObject`** (composes `Hive\Path\Name`)? Is it the header's `Get-RegistryKeyString` stage that `Start-ProviderSetup` was meant to call instead of inlining decomposition?
6. **Should the hive be A's rich `{Name,ShortName,Abbreviation}` hashtable or B's canonical long-form string?** `Mount-RegistryHive` (A) expects the hashtable — another A/B seam.
7. **What is the intended completion of value-data type coercion** (DWord/QWord/Binary, `-Hex`) the owner explicitly marked unfinished in `Get-TypedObject` and left as empty stubs in `Get-RegistryValueData`?

---

## 6. Post-synthesis corrections (completeness review)

A second-pass critic review of this map against the source found the following; fold these into the readings above.

1. **A also has its own `Get-TargetResource`** (A:658-801), omitted from the §1 inventory. It is the A-side consumer of A's rich object: `Param([PSCustomObject]$InputObject)`, opens the hive via `[Microsoft.Win32.RegistryKey]::OpenBaseKey(... $InputObject.RegistryKeyHive.ShortName ...)`, `OpenSubKey(...)`, returns `[Hashtable]@{KeyExists;ValueExists;ValueData;ValueKind}`. (Matrix row 15: `divergent`, `keep_B`; the canonical pick discarded it, but it is the A-side contract the seam is about.)
2. **A is a complete, wired end-to-end path with a JSON driver** (A:1027-1042): `$InputObject (JSON) | ConvertFrom-Json -> Start-ProviderSetup -InputObject -> Get-TargetResource -InputObject:$Configuration`. This proves A's two divergent functions interoperate, and that the project already used JSON input. §3 traced only B's path.
3. **`Get-RegistryKeyType` is a missing called-but-undefined function** (called at B:157 in B's `Start-ProviderSetup` `HasValue` branch); add it to §2. Inferred role: value-kind/type normalizer, sibling of `Get-RegistryValueKindStr`.
4. **True definition count = 20 function bodies** (10 in A + 10 in B); 18 distinct names after the 2 dual-located names (`Start-ProviderSetup`, `Get-TargetResource`) are reconciled. A's `Start-ProviderSetup` and A's `Get-TargetResource` are the non-canonical halves the Phase 2 pick set aside.
5. **B's `Start-ProviderSetup` chain is broken at the variable/param level** (not the clean order §3.2/§3.3 implied): result stored to `RegistryKeyString` (B:138) but the mount passes uninitialized `$RegistryKeyStr` (B:145); it calls `Get-RegistryKeyHive`/`Path`/`Name` with `-Value:` (B:142,147,150) while those declare `-RegistryKey` (B:291,365,431); and `Mount-RegistryHive -RegistryKey:` vs the function's `-RegistryHive:[Hashtable]`. Within-B seams that reinforce the entanglement finding.
6. **A's `Get-RegistryValueData` array guard is also broken** (A:875 tests undefined `$IsDataNull`; A defines `$IsDataNullOrEmpty` A:871), mirroring the B:686 defect §3.4/§3.5 flagged only on B.
7. **`Get-RegistryKeyString` (header) is ambiguous** between the decomposition `Start-ProviderSetup` already inlines (B:139-150) and the orphaned `Get-RegistryResourceObject` composer (B:485-552); present both rather than asserting the latter.

These corrections reinforce the central finding: A and B are two coherent halves that do not cross-wire. The canonical set must be chosen per-function with each interface seam resolved as that function is finalized.
