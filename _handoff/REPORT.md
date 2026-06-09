Canonical selection status: COMPLETE

## Adversarial review verdict

Goal: execute the corrective canonical-selection task on branch `recovery/canonical-selection`: split faithful recovered function bodies into `recovered/canonical/`, archive non-chosen alternates under `recovered/archive/`, commit the execution-map deliverable, remove rejected refactored `src/` and `tests/`, and open a PR to `main` for owner review. This is selection and archival only: no refactoring, no glyph fixes, no behavior completion, no live registry/system changes, and no PDF or `_recovery/` mutation.

Decision: PROCEED. The task is appropriate because the faithful recovered source is now the source of truth and the old refactored `src/`/`tests/` are explicitly rejected. The main risk is a wording conflict: TASK D says every execution-map function name should have a canonical file, while A0 says equivalent A/B roles must pick one whole version and archive the other. I followed A0 as the higher-signal owner-decided method: every recovered function body is accounted for as either canonical or archived, but non-chosen equivalents are not also placed in canonical.

Branch check: PROCEED on `recovery/canonical-selection`, not `main`.

Verbatim contract: PROCEED. `recovered/canonical/*.ps1` and `recovered/archive/*.ps1` are exact line-range extracts from `recovered/06042026.ps1` (A) or `recovered/06042026_001.ps1` (B). No character edits, no splicing, no rename inside function text, no completion.

Chosen output locations: `recovered/canonical/*.ps1`, `recovered/archive/*.ps1`, `docs/design/canonical-selection.md`, `docs/design/execution-map.md`, removal of tracked `src/` and `tests/`, `_handoff/REPORT.md`, and `_handoff/REPORT-ARCHIVE.md`.

Selection table:

| Function / role | Canonical choice | Archive choice | Maturity reason |
| --- | --- | --- | --- |
| `ThrowError` | B `ThrowError` | none | Single-source structured error sink used by both recovered halves. |
| `Start-ProviderSetup` | A `Start-ProviderSetup` | B `Start-ProviderSetup` | A emits a populated setup object and is wired to A's JSON path; B has placeholder result fields and broken variable/parameter wiring. |
| `Get-TargetResource` | A `Get-TargetResource` | B `Get-TargetResource` | A interoperates with A setup and JSON driver; B has the better public evidence shape but depends on the broken B setup/string seam, so it is archived for owner review. |
| Hive normalizer | A `Get-RegistryKeyHiveObj` | B `Get-RegistryKeyHive` | A returns the rich hive descriptor required by `Mount-RegistryHive`; B's long-form string is useful but incompatible with that mount contract. |
| Path helper | A `Get-RegistryKeyPathStr` | B `Get-RegistryKeyPath` | A validates the separated path used by the A setup object; B extracts from a full-key contract that is not the chosen setup path. |
| Key-name helper | A `Get-RegistryKeyNameStr` | B `Get-RegistryKeyName` | A validates the separated name used by the A setup object; B extracts from the alternate full-key contract. |
| `Get-RegistryValueNameStr` | A `Get-RegistryValueNameStr` | none | Single-source value-name validator; preserves empty default-value support. |
| Value-kind helper | A `Get-RegistryValueKindStr` | none | Single-source recovered value-kind normalizer; B's `Get-RegistryKeyType` is referenced but not recovered. |
| `Mount-RegistryHive` | A `Mount-RegistryHive` | none | Single-source mount helper and the only recovered implementation. |
| Value-data coercer | B `Get-TypedObject` | A `Get-RegistryValueData` | B covers more declared type/hex cases despite being unfinished; A has more empty numeric/binary stubs. |
| Array/string display helper | A `ConvertFrom-Array` | none | Single recovered array flattener; B's `ArrayToString` is a missing reference, not an archiveable body. |
| Binary display helper | B `Convert-ByteArrayToHexString` | none | Single recovered binary-to-hex helper. |
| Full-key pre-normalizer | B `Get-NormalizedRegistryKey` | none | Single-source helper; retained because no A body provides the same full-key pre-normalization role. |
| Full-key composer | B `Get-RegistryResourceObject` | none | Single-source orphaned composer; retained for later owner decision on whether it is the header's `Get-RegistryKeyString` stage. |

## What changed

- Archived the prior `REPORT.md` to the top of `_handoff/REPORT-ARCHIVE.md` under `## Archived 2026-06-09 - Canonical selection`.
- Created 14 verbatim canonical function files under `recovered/canonical/`.
- Created 6 verbatim archived alternate function files under `recovered/archive/`.
- Added `docs/design/canonical-selection.md` with per-function maturity choices, line-range citations, archived paths, and owner-confirmable seams.
- Added `docs/design/execution-map.md` to the staged commit and sanitized its source list from local absolute paths to repo-relative paths before the sensitive-content scan.
- Removed the rejected refactored rewrite under tracked `src/` and `tests/`.
- Staged the existing handoff planner files as-is, per TASK.md; Codex did not edit their content.

## What was intentionally not changed

- No function text inside `recovered/06042026.ps1`, `recovered/06042026_001.ps1`, `recovered/canonical/*.ps1`, or `recovered/archive/*.ps1` was refactored, completed, renamed internally, glyph-fixed, or spliced.
- No PDFs or `_recovery/` files were modified.
- No live Windows registry or system state was touched.
- `docs/recovery/GAPS.md` was left in place because it still records missing-name evidence not fully superseded by the execution map.
- No Test/Set unification design or Registry implementation work was started.

## Verification output

Coverage / accounting:

```text
expected_bodies=20
canonical_files=14
archive_files=6
missing_paths=NONE
B:280-357 Get-RegistryKeyHive -> recovered\archive\Get-RegistryKeyHive.from-B.ps1 (archive)
B:358-419 Get-RegistryKeyPath -> recovered\archive\Get-RegistryKeyPath.from-B.ps1 (archive)
B:185-279 Get-NormalizedRegistryKey -> recovered\canonical\Get-NormalizedRegistryKey.ps1 (canonical)
B:44-101 ThrowError -> recovered\canonical\ThrowError.ps1 (canonical)
B:102-183 Start-ProviderSetup -> recovered\archive\Start-ProviderSetup.from-B.ps1 (archive)
B:593-779 Get-TypedObject -> recovered\canonical\Get-TypedObject.ps1 (canonical)
B:780-918 Get-TargetResource -> recovered\archive\Get-TargetResource.from-B.ps1 (archive)
B:553-592 Convert-ByteArrayToHexString -> recovered\canonical\Convert-ByteArrayToHexString.ps1 (canonical)
B:420-483 Get-RegistryKeyName -> recovered\archive\Get-RegistryKeyName.from-B.ps1 (archive)
B:485-552 Get-RegistryResourceObject -> recovered\canonical\Get-RegistryResourceObject.ps1 (canonical)
A:326-402 Get-RegistryKeyNameStr -> recovered\canonical\Get-RegistryKeyNameStr.ps1 (canonical)
A:403-469 Get-RegistryValueNameStr -> recovered\canonical\Get-RegistryValueNameStr.ps1 (canonical)
A:228-325 Get-RegistryKeyPathStr -> recovered\canonical\Get-RegistryKeyPathStr.ps1 (canonical)
A:1-121 Start-ProviderSetup -> recovered\canonical\Start-ProviderSetup.ps1 (canonical)
A:122-227 Get-RegistryKeyHiveObj -> recovered\canonical\Get-RegistryKeyHiveObj.ps1 (canonical)
A:803-939 Get-RegistryValueData -> recovered\archive\Get-RegistryValueData.from-A.ps1 (archive)
A:940-1025 ConvertFrom-Array -> recovered\canonical\ConvertFrom-Array.ps1 (canonical)
A:658-801 Get-TargetResource -> recovered\canonical\Get-TargetResource.ps1 (canonical)
A:470-568 Get-RegistryValueKindStr -> recovered\canonical\Get-RegistryValueKindStr.ps1 (canonical)
A:569-656 Mount-RegistryHive -> recovered\canonical\Mount-RegistryHive.ps1 (canonical)
```

Byte-for-byte fidelity checks for all extracts:

```text
OK recovered\canonical\ThrowError.ps1 == recovered\06042026_001.ps1:44-101 bytes=1631
OK recovered\canonical\Start-ProviderSetup.ps1 == recovered\06042026.ps1:1-121 bytes=5431
OK recovered\canonical\Get-TargetResource.ps1 == recovered\06042026.ps1:658-801 bytes=6989
OK recovered\canonical\Get-RegistryKeyHiveObj.ps1 == recovered\06042026.ps1:122-227 bytes=4349
OK recovered\canonical\Get-RegistryKeyPathStr.ps1 == recovered\06042026.ps1:228-325 bytes=4294
OK recovered\canonical\Get-RegistryKeyNameStr.ps1 == recovered\06042026.ps1:326-402 bytes=3521
OK recovered\canonical\Get-RegistryValueNameStr.ps1 == recovered\06042026.ps1:403-469 bytes=2964
OK recovered\canonical\Get-RegistryValueKindStr.ps1 == recovered\06042026.ps1:470-568 bytes=4469
OK recovered\canonical\Mount-RegistryHive.ps1 == recovered\06042026.ps1:569-656 bytes=3857
OK recovered\canonical\Get-TypedObject.ps1 == recovered\06042026_001.ps1:593-779 bytes=9009
OK recovered\canonical\ConvertFrom-Array.ps1 == recovered\06042026.ps1:940-1025 bytes=3971
OK recovered\canonical\Convert-ByteArrayToHexString.ps1 == recovered\06042026_001.ps1:553-592 bytes=1918
OK recovered\canonical\Get-NormalizedRegistryKey.ps1 == recovered\06042026_001.ps1:185-279 bytes=5253
OK recovered\canonical\Get-RegistryResourceObject.ps1 == recovered\06042026_001.ps1:485-552 bytes=3779
OK recovered\archive\Start-ProviderSetup.from-B.ps1 == recovered\06042026_001.ps1:102-183 bytes=4078
OK recovered\archive\Get-TargetResource.from-B.ps1 == recovered\06042026_001.ps1:780-918 bytes=8211
OK recovered\archive\Get-RegistryKeyHive.from-B.ps1 == recovered\06042026_001.ps1:280-357 bytes=4454
OK recovered\archive\Get-RegistryKeyPath.from-B.ps1 == recovered\06042026_001.ps1:358-419 bytes=3561
OK recovered\archive\Get-RegistryKeyName.from-B.ps1 == recovered\06042026_001.ps1:420-483 bytes=3604
OK recovered\archive\Get-RegistryValueData.from-A.ps1 == recovered\06042026.ps1:803-939 bytes=4811
fail_count=0
```

Sample no-diff checks:

```text
diff Start-ProviderSetup canonical vs A:1-121
exit=0
diff Get-TypedObject canonical vs B:593-779
exit=0
```

`src/` and `tests/` removal:

```text
NO OUTPUT from: git ls-files src/ tests/
```

Design docs tracked after staging:

```text
docs/design/canonical-selection.md
docs/design/execution-map.md
```

Sensitive-content scan:

```text
NO HITS from sensitive-content scan over new design/canonical/archive files and added diff lines.
warning: in the working copy of '_handoff/REPORT-ARCHIVE.md', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of '_handoff/REPORT.md', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of '_handoff/TASK.md', LF will be replaced by CRLF the next time Git touches it
```

PDF hashes unchanged (leaf filenames only, to avoid publishing local absolute paths):

```text
B6BD5239D642D09368E255E21064B1F48C63D075DD43F8374098300DB9ED155F 06042026.pdf
D6BE73056B47FB9EEA9126A9EA5BC232BCF733A5562306AC2A601FA57FFC051E 06042026_001.pdf
```

`recovered/canonical` and `recovered/archive` are not ignored:

```text
exit=1
```

Branch:

```text
recovery/canonical-selection
```

Post-commit signature check:

```text
Pending final `git log --show-signature -1` after the commit exists; this cannot be made self-contained inside the same commit without amending and invalidating the recorded output. It will be run immediately after commit and reported in the handback.
```

## Deviations from `TASK.md` and why

- TASK D's literal coverage wording says every execution-map function name should have a canonical file. That conflicts with A0's owner-decided rule to pick one equivalent version and archive the other. I followed A0 and verified every recovered body is either canonical or archived.
- I sanitized local absolute paths in `docs/design/execution-map.md` to repo-relative paths before commit. This is a public-repo safety correction, not a design/content rewrite.
- The PDF hash verification is recorded with leaf filenames rather than the default absolute local paths to avoid adding a user-profile path to the public report.
- The final commit signature check is reported after commit in the handback because it cannot be embedded in the same commit's `REPORT.md` without a circular amend.

## Open objections that must be resolved before advancing

- Owner should confirm or reject the major A-path choice: A `Start-ProviderSetup` + A `Get-TargetResource` are the coherent JSON/rich-object path, while B has the more public TargetState-shaped `Ensure/Key/ValueName/ValueKind/ValueData` output.
- Owner should confirm the hive-shape seam: A rich `{Name,ShortName,Abbreviation}` descriptor versus B canonical long-form string.
- Owner should confirm the value-data choice: B `Get-TypedObject` is selected because it has broader type/hex branch coverage, but it is still unfinished and has missing exception-hash/array-guard gaps.
- Owner should confirm whether the B full-key helpers retained as canonical single-source evidence should survive the next design step or be retired in favor of the A separated-field contract.

## Owner decisions needed

- Review the PR and confirm the canonical selections or request a different A/B choice.
- Merge to `main` only by owner/admin action; Codex must not merge.
- After merge/owner acceptance, advance to the dedicated Test/Set unification-design step before any Registry implementation resumes.

Canonical selection status: COMPLETE