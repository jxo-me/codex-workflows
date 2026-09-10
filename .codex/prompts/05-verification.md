Act as an independent architecture reviewer.

Assume the generated workspace documentation may contain errors.

Review:

AGENTS.md
ARCHITECTURE.md
docs/architecture/
docs/domain/
docs/standards/

Validate important claims against the actual source code.

Find:

unsupported claims
incorrect service relationships
incorrect data ownership
missing repositories
missing event flows
missing database dependencies
contradictory documentation
stale documentation
overconfident assumptions

Classify every finding:

CONFIRMED_ERROR
LIKELY_ERROR
UNVERIFIED
DOCUMENTATION_GAP

Correct documentation only when code evidence supports the correction.

Do not modify production code.

Write the independent review report to:

docs/generated/documentation-verification.md

Finally produce a section:

Workspace Readiness

with:

READY
READY_WITH_GAPS
NOT_READY

and list remaining gaps.

Update `.codex/workspace-status.md`. Mark `Documentation verification`
complete only after every in-scope document has been checked. Do not mark the
Workspace READY in this phase; AGENTS.md finalization is still required.
