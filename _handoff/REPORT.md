## Adversarial review verdict
Goal: execute Phase 0 only for TargetState by establishing a safe repo governance
baseline on a working branch before any recovered code, PDF extraction, DSC audit,
or engine/source work can begin.

Decision: PROCEED

Branch: `recovery/phase-0-governance`. All Phase 0 commits will land on this
branch, not on `main`.

Initial repo state:

```text
git branch --show-current
recovery/phase-0-governance

git ls-files
.github/CODEOWNERS
README.md

git status --short --branch
## recovery/phase-0-governance
?? 06042026.pdf
?? 06042026_001.pdf
?? _handoff/
```

The goal is aligned with the plan: Phase 1 PDF extraction is unsafe until the
named PDFs and generated recovery output are structurally ignored, and until the
project has a written governance ledger and Draft ADR process. The `.gitignore`
approach is appropriately narrow because it ignores only the two source PDFs and
`/_recovery/`, avoiding an overbroad `*.pdf` rule. The ADR layout is minimal and
reviewable; it should not be treated as inherited from `NWarila/powershell-template`
because the plan says that template currently has no ADR convention to copy.

Challenge/objection: Phase 0 says the PDF disposition is "local-only + SHA-256
manifest", but TASK.md forbids creating `_recovery/` and Phase 1 owns
`_recovery/manifest.json`. I will record the disposition and PDF baselines in
`docs/governance.md` and `REPORT.md` now, but I will not create `_recovery/` or a
manifest file in Phase 0.

I will not open, parse, extract, OCR, or otherwise inspect PDF contents. I will
hash the two PDF files and record byte sizes only. I will not write any
`.ps1`, `.psm1`, `.psd1`, `src/`, `tests/`, engine, resource, registry, or DSC
audit artifact.
