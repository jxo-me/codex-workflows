Analyze existing engineering conventions.

Do not refactor code.

Determine the dominant conventions actually used by this codebase.

Analyze:

Go package structure
handler/service/repository layering
dependency injection
configuration
error handling
logging
context usage
transactions
database access
cache
MQ
idempotency
concurrency
testing
mocking
integration testing
metrics
tracing

Separate findings into:

CURRENT_STANDARD
LEGACY_PATTERN
INCONSISTENT_PATTERN
RISKY_PATTERN

Do not automatically classify newer patterns as better.

Generate:

docs/standards/go-style.md
docs/standards/architecture-rules.md
docs/standards/error-handling.md
docs/standards/transaction.md
docs/standards/idempotency.md
docs/standards/logging-observability.md
docs/standards/testing.md
docs/standards/delivery.md

Prefer describing existing successful patterns.

Do not rewrite application code.

Update `.codex/workspace-status.md`. Mark `Engineering standards analysis`
complete only when every listed standards document distinguishes established,
legacy, inconsistent, and risky patterns using repository evidence.
