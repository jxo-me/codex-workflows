---
name: code-review
description: Perform an evidence-based, adversarial review of a code change for correctness, security, compatibility, consistency, and operational risk. Use when asked to review a diff or implementation; do not implement fixes unless explicitly requested.
---

# Code Review

Review the change independently of the implementation approach chosen by its
author. Prioritize defects that can change behavior or production safety.

## Inputs

- requirement and acceptance criteria
- approved solution and implementation plan, when available
- current diff and affected call chains
- test and verification evidence

## Review

1. Map changed behavior to requirements and identify missing coverage.
2. Trace affected request, event, transaction, and failure paths.
3. Check API, database, cache, and event compatibility.
4. Check authorization, sensitive data handling, and injection boundaries.
5. Check idempotency, concurrency, retry, timeout, ordering, and partial failure.
6. Check observability, deployment ordering, rollback, and recovery.
7. Treat tests as evidence to inspect, not proof that the implementation is correct.

Do not spend review attention on style unless it obscures correctness or
maintainability.

## Findings

Report findings first, ordered by severity:

- P0: security compromise, data loss/corruption, or critical outage
- P1: incorrect behavior, consistency failure, or compatibility break
- P2: material reliability, performance, observability, or maintainability risk
- P3: low-risk improvement

Each finding must include severity, evidence, impact, triggering scenario, and
the smallest safe correction. Use precise file and symbol references.

After findings, list open questions and verification gaps. If no findings are
proven, say so and state remaining test or evidence gaps.

## Constraints

- A review request is read-only unless the user also requests fixes.
- Do not infer a defect from naming alone.
- Do not claim a check passed unless it actually ran successfully.
