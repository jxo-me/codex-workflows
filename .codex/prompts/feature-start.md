# FEATURE START

Feature ID:

{{FEATURE_ID}}

Read first:

AGENTS.md
ARCHITECTURE.md
docs/architecture/
docs/domain/
docs/standards/

Feature sources:

docs/features/{{FEATURE_ID}}/00-source/

Current phase:

REQUIREMENT ANALYSIS

Do not modify production code.

Analyze:

business objective
actors
preconditions
main flow
alternative flows
exception flows
business rules
state transitions
data requirements
API requirements
event requirements
permission
audit
compatibility
non-functional requirements

Explicitly identify:

AMBIGUOUS
MISSING
CONFLICTING
ASSUMPTION
NEEDS_CONFIRMATION

Do not infer backend rules merely from UI behavior.

Produce:

docs/features/{{FEATURE_ID}}/01-requirement.md

Include acceptance criteria using:

Given
When
Then

Stop after requirement analysis.