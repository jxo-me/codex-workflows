Act as Principal Backend Architect.

Using actual repository evidence, reconstruct the system architecture.

Do not modify production code.

Analyze:

HTTP
gRPC
RPC
MySQL
PostgreSQL
Redis
ClickHouse
Kafka
NATS
RabbitMQ
Cron
Background workers
Configuration
Service discovery
Observability
Deployment

Trace actual interactions.

Generate or update:

ARCHITECTURE.md

docs/architecture/system-map.md
docs/architecture/service-dependencies.md
docs/architecture/data-flow.md
docs/architecture/event-flow.md
docs/architecture/database-map.md
docs/architecture/runtime-map.md

Identify:

service boundaries
data ownership
request flow
event flow
transaction boundaries
consistency boundaries
failure boundaries
shared infrastructure

Pay special attention to:

shared databases
distributed transactions
implicit coupling
cross-repository dependencies
retry semantics
timeout semantics
idempotency
message ordering
duplicate delivery
eventual consistency

Every important claim must reference code evidence.

Never manufacture missing architecture.