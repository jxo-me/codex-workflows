# Workspace Engineering Instructions

## Purpose

This workspace is maintained as a production engineering system.

Codex must prioritize:

1. correctness
2. backward compatibility
3. data consistency
4. operational safety
5. observability
6. maintainability
7. performance

## Working Rules

Before modifying production code:

1. inspect existing implementation
2. identify repository boundaries
3. identify similar implementations
4. trace the relevant call chain
5. analyze impact
6. create or update implementation plan
7. define verification strategy

Never invent architecture based only on filenames.

Prefer evidence from:

- source code
- tests
- configuration
- schemas
- migrations
- deployment files
- existing documentation

## Knowledge Sources

Read:

- ARCHITECTURE.md
- docs/architecture/
- docs/domain/
- docs/standards/

Feature work lives under:

- docs/features/

## Change Discipline

Do not:

- perform unrelated refactoring
- introduce new dependencies without justification
- change API/database/event contracts silently
- modify repositories outside explicitly permitted write scope

## Verification

Use repository-specific checks.

For Go projects, normally include:

- go test ./...
- go test -race ./...
- go vet ./...
- golangci-lint run

Only report a check as passed if it actually ran successfully.

## Uncertainty

Use these labels:

- UNKNOWN
- UNCERTAIN
- ASSUMPTION
- NEEDS_VERIFICATION
- BLOCKED
