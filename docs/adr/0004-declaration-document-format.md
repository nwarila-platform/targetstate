# ADR 0004: Declaration Document Format

Status: Draft

Date: 2026-06-08

## Context

Traceability: BACKLOG P5-ADR-002; AUDIT: Configuration keyword; AUDIT: MOF
compilation vs runtime boundary; AUDIT: Remove-DscConfigurationDocument; AUDIT:
Cross-platform DSC v3 direction context-only.

TargetState's mission is to replace the generated-MOF workflow with
human-readable declaration documents that live in git and review cleanly. The
Phase 4 audit says to replace DSC's `Configuration` keyword and MOF compilation
boundary with a TargetState-native document format. Cross-platform DSC v3 uses
JSON/YAML as useful context, but the current target remains Windows PowerShell
5.1 and the Registry proof.

## Decision

Use JSON as the first TargetState declaration document format for the Registry
proof. The owner chose JSON after Phase 5 because Windows PowerShell 5.1 parses
it natively through `ConvertFrom-Json`, which keeps the first proof dependency
free and avoids approving a parser install or vendored YAML implementation.
YAML was the initial suggestion and may return later as an additional front-end
format, but it is not the Phase 6 input format.

The JSON declaration document is the input artifact. It must not be compiled to
MOF, must not use DSC `Configuration` or `Node` blocks, and must not rely on the
DSC Local Configuration Manager to store or apply desired state.

For the Registry proof, use a small v1alpha1 document shape:

- `apiVersion`: TargetState document version.
- `kind`: document kind, initially `TargetDocument`.
- `metadata.name`: human-friendly document name.
- `resources`: ordered list of resource instances.
- `resources[].type`: resource type, initially `Registry`.
- `resources[].name`: stable instance name used in evidence.
- `resources[].properties`: resource-specific desired properties.

Illustrative JSON example:

```json
{
  "apiVersion": "targetstate.nwarila.dev/v1alpha1",
  "kind": "TargetDocument",
  "metadata": {
    "name": "registry-proof"
  },
  "resources": [
    {
      "type": "Registry",
      "name": "example-registry-value",
      "properties": {
        "hive": "HKEY_LOCAL_MACHINE",
        "path": "SOFTWARE\\TargetState\\Example",
        "valueName": "Enabled",
        "valueKind": "DWord",
        "valueData": 1,
        "ensure": "Present"
      }
    }
  ]
}
```

The Registry resource should normalize these document properties through the
contract proposed in ADR 0003 before any operation runs. The document format
should stay independent of DSC's MOF schema and independent of recovered helper
names that were found to be absent from the PDFs.

## Consequences

JSON keeps the first implementation inside the Windows PowerShell 5.1 standard
toolbox. Phase 6 can focus on schema validation, Registry normalization, read
operations, and evidence instead of parser selection.

The tradeoff is that JSON is less concise than YAML for human-edited GitOps
documents. That is acceptable for the first proof because dependency-free,
testable behavior is more important than final authoring ergonomics. A later ADR
revision may add YAML once parser policy is owner-approved.

The schema stays intentionally small: `TargetDocument` with ordered resources
and resource-specific `properties`. The first implementation should reject
unknown document kinds, resource types, and malformed Registry properties rather
than silently accepting broad engine semantics.

## Open questions for owner

- Should the long-term canonical extension be `.targetstate.json`, `.target.json`,
  or another name?
- Should YAML return later as a supported authoring format once parser policy is
  owner-approved?
- Should resource order be meaningful in v1alpha1, or should the first proof
  reject ordering/dependency semantics until the engine phase?
- Should `valueData` allow scalar, array, and byte forms in the first Registry
  proof, or should arrays and binary data wait until typed conversion tests exist?

## Owner gate

This ADR remains Draft. The owner approved JSON as the implementation input for
the Phase 6 Registry proof. That directional approval does not change this ADR
to `Accepted` unless the owner explicitly approves that status transition.
