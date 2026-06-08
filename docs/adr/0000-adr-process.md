# ADR 0000: ADR Process

Status: Draft

Date: 2026-06-08

## Context

TargetState needs a small decision record process before recovered code or engine
design is added. ADRs must be easy to review in git and must not imply owner
acceptance before review.

## Decision

ADRs live under `docs/adr/` and use the filename pattern
`NNNN-kebab-title.md`, where `NNNN` is a zero-padded four-digit sequence.

Every ADR starts with the literal status line:

```text
Status: Draft
```

No ADR may become `Accepted` without owner approval. Draft ADRs may describe a
proposed direction, but implementation that depends on the decision remains
gated by the active task and the governance rules in `docs/governance.md`.

Recommended sections for future ADRs:

- Context
- Decision
- Consequences
- Owner gate

## Consequences

The repo can record decisions before implementation while keeping review state
plain and auditable. The first accepted status transition remains owner-gated.
