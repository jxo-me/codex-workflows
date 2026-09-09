# Impact Analysis

## Purpose

Analyze the full engineering impact of a proposed feature before implementation.

## Required Inputs

- verified requirement document
- current-system analysis
- workspace architecture documentation

## Workflow

1. Identify affected repositories.
2. Identify affected APIs.
3. Identify domain changes.
4. Identify persistence changes.
5. Identify cache impact.
6. Identify asynchronous messaging impact.
7. Identify configuration impact.
8. Identify compatibility risks.
9. Identify security implications.
10. Identify observability changes.
11. Identify deployment implications.
12. Identify rollback strategy.

## Mandatory Risk Checks

Always examine:

- data migration
- historical data
- API backward compatibility
- event schema compatibility
- idempotency
- duplicate delivery
- ordering
- race conditions
- partial failures
- distributed consistency
- timeout
- retry
- feature flags

## Output

Produce:

03-impact-analysis.md

## Evidence Rule

Every concrete implementation claim must reference:

repository/path:symbol

## Final Check

Never mark impact as NONE unless verified from code.