---
name: impact-analysis
description: Analyze the engineering impact and operational risk of a proposed feature before implementation. Use when requirements and current-system evidence exist; do not use for repository discovery or coding.
---

# Impact Analysis

Determine what a proposed change affects and how each impact can be verified.

## Required Inputs

- verified requirement document
- current-system analysis
- workspace architecture documentation

If a required input is absent or materially incomplete, label the gap and avoid
claiming a complete impact analysis.

## Workflow

1. Identify affected repositories and owners.
2. Analyze API, domain, persistence, cache, and messaging changes.
3. Analyze configuration, security, permission, and observability changes.
4. Analyze compatibility, deployment ordering, rollback, and data recovery.
5. Trace failure modes across transaction and consistency boundaries.
6. Map each material risk to mitigation and verification evidence.

Always examine:

- schema migration and historical data
- API and event backward compatibility
- idempotency, duplicate delivery, and ordering
- concurrency and race conditions
- timeout, retry, and partial failure
- distributed consistency and compensation
- feature flags, rollout, and rollback

## Output

Update docs/features/<FEATURE-ID>/03-impact-analysis.md, unless the task names
another destination. Include a risk matrix with probability, impact,
mitigation, owner, and verification.

Every implementation claim must cite repository/path:symbol or the narrowest
available file-and-line evidence.

## Constraints

- Do not modify production code.
- Do not silently broaden read or write scope.
- Never mark an impact as NONE unless evidence establishes that conclusion.
- Use UNKNOWN, UNCERTAIN, and NEEDS_VERIFICATION for unresolved areas.
