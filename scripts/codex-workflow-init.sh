#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(pwd)}"

echo "Initializing Codex engineering workflow in:"
echo "  ${ROOT}"

mkdir -p \
  "${ROOT}/docs/architecture" \
  "${ROOT}/docs/domain" \
  "${ROOT}/docs/standards" \
  "${ROOT}/docs/adr" \
  "${ROOT}/docs/features" \
  "${ROOT}/docs/runbooks" \
  "${ROOT}/docs/generated" \
  "${ROOT}/.codex/prompts" \
  "${ROOT}/.codex/templates/feature" \
  "${ROOT}/.codex/skills/requirement-analysis" \
  "${ROOT}/.codex/skills/repository-analysis" \
  "${ROOT}/.codex/skills/impact-analysis" \
  "${ROOT}/.codex/skills/architecture-design" \
  "${ROOT}/.codex/skills/go-implementation" \
  "${ROOT}/.codex/skills/go-testing" \
  "${ROOT}/.codex/skills/code-review" \
  "${ROOT}/.codex/skills/delivery-review" \
  "${ROOT}/scripts"

touch "${ROOT}/docs/generated/.gitkeep"

cat > "${ROOT}/AGENTS.md" <<'EOF'
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
EOF

cat > "${ROOT}/ARCHITECTURE.md" <<'EOF'
# Architecture Overview

Status: NOT_INITIALIZED

This file is the high-level architecture entry point.

Detailed architecture lives under:

- docs/architecture/system-map.md
- docs/architecture/repository-map.md
- docs/architecture/service-dependencies.md
- docs/architecture/data-flow.md
- docs/architecture/event-flow.md
- docs/architecture/database-map.md
- docs/architecture/runtime-map.md

This document must be generated from actual repository evidence.
EOF

cat > "${ROOT}/README-AI-WORKFLOW.md" <<'EOF'
# AI Engineering Workflow

## Workspace Bootstrap

Run Codex prompts in this order:

1. .codex/prompts/00-bootstrap.md
2. .codex/prompts/01-repository-analysis.md
3. .codex/prompts/02-architecture-analysis.md
4. .codex/prompts/03-domain-analysis.md
5. .codex/prompts/04-standards-analysis.md
6. .codex/prompts/05-verification.md

## Feature Workflow

Create a feature workspace:

./scripts/feature-init.sh FEATURE-ID

Then execute:

1. requirement analysis
2. current-system analysis
3. impact analysis
4. solution design
5. implementation plan
6. implementation
7. testing
8. adversarial review
9. requirement coverage review
10. delivery review
11. retrospective / knowledge capture
EOF

for file in \
 system-map \
 repository-map \
 service-dependencies \
 data-flow \
 event-flow \
 database-map \
 runtime-map
do
cat > "${ROOT}/docs/architecture/${file}.md" <<EOF
# ${file}

Status: NOT_INITIALIZED

Generated from repository evidence.

Do not fill this document using assumptions.
EOF
done

cat > "${ROOT}/docs/domain/index.md" <<'EOF'
# Domain Knowledge

Status: NOT_INITIALIZED

Document important business domains discovered from the codebase.

Each domain should eventually have its own document.
EOF

cat > "${ROOT}/docs/adr/README.md" <<'EOF'
# Architecture Decision Records

Use ADRs for decisions that materially affect:

- architecture
- persistence
- API contracts
- event contracts
- consistency models
- major dependencies
EOF

cat > "${ROOT}/docs/adr/template.md" <<'EOF'
# ADR-XXXX: Title

## Status

Proposed

## Context

## Decision

## Alternatives

## Consequences

## Risks

## Validation
EOF

cat > "${ROOT}/docs/features/README.md" <<'EOF'
# Feature Engineering Records

Each feature uses:

FEATURE-ID/
├── 00-source/
├── 01-requirement.md
├── 02-current-system.md
├── 03-impact-analysis.md
├── 04-solution-design.md
├── 05-implementation-plan.md
├── 06-test-plan.md
├── 07-delivery-checklist.md
└── 08-retrospective.md
EOF

cat > "${ROOT}/docs/runbooks/README.md" <<'EOF'
# Operational Runbooks

Document operational procedures only after they are verified against the deployed system.
EOF

echo "Codex workflow skeleton created successfully."