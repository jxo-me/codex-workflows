Analyze the business domains represented by this workspace.

Do not modify production code.

Identify:

entities
aggregates
state machines
business invariants
business workflows
ownership boundaries
cross-domain interactions

Look primarily at:

domain models
services
database schemas
events
tests

Do not derive business rules only from API names.

Create:

docs/domain/index.md

and create one document per meaningful domain:

docs/domain/<domain>.md

Each domain document should include:

Purpose
Entities
State
Business Rules
Invariants
Commands
Events
Data Ownership
Dependencies
Failure Cases
Relevant Code

Every business rule must reference evidence where possible.

Mark uncertain business semantics:

NEEDS_PRODUCT_CONFIRMATION