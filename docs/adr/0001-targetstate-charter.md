# ADR 0001: TargetState Charter

Status: Draft

Date: 2026-06-08

## Context

TargetState is being recovered and governed before new implementation begins.
The project needs a shared charter that keeps the mission broader than STIG
hardening while preserving STIG as an important downstream validation target.

## Decision

TargetState is a GitOps-friendly replacement for Microsoft PowerShell Desired
State Configuration for Windows configuration work. Its user-facing configuration
artifact is intended to be human-readable, YAML-style declaration text that lives
in git and avoids generated MOF as the primary workflow artifact.

The role split is:

- Claude plans and reviews.
- Codex challenges the plan and implements approved scoped tasks.
- The owner gates merges, live machine changes, ADR acceptance, and public
  publication decisions.

The canonical rule ledger is `docs/governance.md`. This ADR cites that ledger
instead of duplicating every operational rule.

## Consequences

STIG work remains a downstream use case and validation target, not a current
capability claim. Engine and resource work stays blocked until the relevant
phase and Draft ADRs exist.
