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

Propose YAML as the first TargetState declaration document format. YAML best
matches the owner direction for human-readable, version-controllable declaration
documents and keeps the user-facing artifact close to what reviewers expect in a
GitOps workflow.

The declaration document should be the input artifact. It must not be compiled
to MOF, must not use DSC `Configuration` or `Node` blocks, and must not rely on
the DSC Local Configuration Manager to store or apply desired state.

For the Registry proof, propose a small v1alpha1 document shape:

- `apiVersion`: TargetState document version.
- `kind`: document kind, initially `TargetDocument`.
- `metadata.name`: human-friendly document name.
- `resources`: ordered list of resource instances.
- `resources[].type`: resource type, initially `Registry`.
- `resources[].name`: stable instance name used in evidence.
- `resources[].properties`: resource-specific desired properties.

Draft illustrative example only:

```yaml
apiVersion: targetstate.nwarila.dev/v1alpha1
kind: TargetDocument
metadata:
  name: registry-proof
resources:
  - type: Registry
    name: example-registry-value
    properties:
      hive: HKEY_LOCAL_MACHINE
      path: 'SOFTWARE\TargetState\Example'
      valueName: Enabled
      valueKind: DWord
      valueData: 1
      ensure: Present
```

The Registry resource should normalize these document properties through the
contract proposed in ADR 0003 before any operation runs. The document format
should stay independent of DSC's MOF schema and independent of recovered helper
names that were found to be absent from the PDFs.

## Consequences

YAML makes the declaration artifact easy to diff and review in git. It also
forces TargetState to define its own parser, validation, and error messages
instead of outsourcing meaning to DSC compilation.

Windows PowerShell 5.1 does not include a built-in YAML parser. The first proof
must therefore choose a parser strategy deliberately before implementation. A
restricted YAML subset, a committed parser dependency, or another approved
approach may be needed later. This ADR does not approve installing tooling or
vendoring a parser.

Using YAML also means examples can look more like future user documents than
PowerShell scripts. That is useful for the mission, but the first implementation
must keep the schema small enough to test without building a broad engine.

## Open questions for owner

- Should the canonical extension be `.targetstate.yaml`, `.targetstate.yml`, or
  another name?
- Should the first proof support only a restricted YAML subset to avoid adding a
  parser dependency under Windows PowerShell 5.1?
- Should resource order be meaningful in v1alpha1, or should the first proof
  reject ordering/dependency semantics until the engine phase?
- Should `valueData` allow scalar, array, and byte forms in the first Registry
  proof, or should arrays and binary data wait until typed conversion tests exist?

## Owner gate

This ADR remains Draft. Owner approval of the declaration-format direction is
required before Phase 6 treats YAML as the implementation input. Approval of
direction does not change this ADR to `Accepted` unless the owner explicitly
approves that status transition.
