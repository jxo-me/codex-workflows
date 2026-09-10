---
name: repository-analysis
description: Analyze repository boundaries, responsibilities, entry points, dependencies, and call chains from code evidence. Use for workspace discovery, repository mapping, or feature current-system analysis; do not use to implement changes.
---

# Repository Analysis

Build an evidence-backed view of the repositories relevant to the request.

## Inputs

- workspace root and repository boundaries
- requested read scope
- existing architecture and feature documents, when present

## Workflow

1. Confirm the workspace root and every Git boundary in scope.
2. Identify languages, modules, build systems, entry points, and public interfaces.
3. Trace relevant synchronous and asynchronous call chains through actual symbols.
4. Identify persistence, cache, messaging, configuration, deployment, tests, and observability.
5. Find analogous implementations when analyzing a feature.
6. Record unsupported or conflicting conclusions explicitly.

Prefer evidence in this order:

1. implementation and schemas
2. tests
3. configuration and deployment
4. maintained documentation
5. naming

Do not infer responsibility from a repository or directory name alone.

## Output

Write to the destination requested by the task, normally:

- docs/architecture/repository-map.md for workspace analysis
- docs/features/<FEATURE-ID>/02-current-system.md for feature analysis

For important claims, cite repository/path:symbol or the narrowest available
file-and-line evidence. Include repository responsibility, entry points,
interfaces, call chains, data ownership, dependencies, tests, and known gaps.

## Constraints

- Do not modify production code during analysis.
- Do not expand write scope.
- Use UNKNOWN, UNCERTAIN, and NEEDS_VERIFICATION instead of inventing facts.
- Do not mark discovery complete when an in-scope repository was not inspected.
