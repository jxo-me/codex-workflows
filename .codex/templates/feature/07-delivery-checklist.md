# Feature Delivery Checklist

Feature ID:

Feature Name:

Release Version:

Owner:

Reviewer:

Target Environment:

Status: NOT_READY

Last Updated:

---

# 1. Delivery Principle

A feature is not ready for delivery merely because implementation is complete.

Delivery readiness requires evidence for:

* requirement coverage
* implementation correctness
* compatibility
* data safety
* operational readiness
* deployment safety
* rollback capability
* observability

Any unresolved critical risk must block delivery.

---

# 2. Requirement Gate

* [ ] Business goal is understood
* [ ] Requirement scope is finalized
* [ ] Acceptance criteria are documented
* [ ] Ambiguous requirements are resolved or explicitly accepted
* [ ] No undocumented implementation assumptions remain
* [ ] Requirement-to-implementation coverage review completed
* [ ] Requirement-to-test coverage review completed

Evidence:

---

# 3. Architecture Gate

* [ ] Implementation follows approved solution design
* [ ] Repository boundaries remain valid
* [ ] Domain ownership remains valid
* [ ] No unintended cross-service coupling introduced
* [ ] No architecture rule violated
* [ ] No unnecessary new abstraction introduced
* [ ] No unrelated refactoring included
* [ ] Major architectural decisions have ADR where necessary

Evidence:

---

# 4. Scope Gate

Approved Read Scope:

Approved Write Scope:

Actual Modified Repositories:

Actual Modified Files:

Verify:

* [ ] All changed repositories are within approved scope
* [ ] All changed files are related to the feature
* [ ] No accidental formatting/refactoring noise
* [ ] No generated artifacts accidentally committed
* [ ] No debug/test-only code left in production path

---

# 5. API Contract Gate

API change:

* NONE
* BACKWARD_COMPATIBLE
* BREAKING

Verify:

* [ ] Request contract reviewed
* [ ] Response contract reviewed
* [ ] Error contract reviewed
* [ ] Existing clients remain compatible
* [ ] New fields have safe defaults where necessary
* [ ] Deprecated behavior is documented
* [ ] Versioning strategy exists for breaking changes
* [ ] API documentation updated

Breaking changes must be explicitly approved.

Evidence:

---

# 6. Database Gate

Database change:

* NONE
* SCHEMA
* DATA
* BOTH

Verify:

* [ ] Schema change reviewed
* [ ] Migration reviewed
* [ ] Existing production data considered
* [ ] Migration tested against representative data
* [ ] Index impact reviewed
* [ ] Locking impact reviewed
* [ ] Transaction behavior reviewed
* [ ] Rollback implications understood
* [ ] Old/new application version compatibility verified where required

Migration command / artifact:

Evidence:

---

# 7. Event / MQ Contract Gate

Event change:

* NONE
* PRODUCER
* CONSUMER
* SCHEMA
* MULTIPLE

Verify:

* [ ] Topic/subject reviewed
* [ ] Event schema reviewed
* [ ] Producer compatibility verified
* [ ] Consumer compatibility verified
* [ ] Duplicate delivery behavior verified
* [ ] Retry behavior verified
* [ ] Message ordering behavior verified
* [ ] Poison-message behavior considered
* [ ] Consumer restart behavior verified
* [ ] Rolling deployment compatibility verified

Evidence:

---

# 8. Cache Gate

Cache impact:

* NONE
* READ
* WRITE
* INVALIDATION

Verify:

* [ ] Cache key semantics reviewed
* [ ] TTL reviewed
* [ ] Cache invalidation verified
* [ ] Cache miss behavior verified
* [ ] Stale cache behavior understood
* [ ] Cache outage behavior verified
* [ ] DB/cache consistency risks reviewed

Evidence:

---

# 9. Transaction and Consistency Gate

Verify:

* [ ] Transaction boundaries are explicit
* [ ] Partial failure scenarios reviewed
* [ ] Cross-service consistency behavior documented
* [ ] Compensation exists where required
* [ ] No silent data-loss path identified
* [ ] No unintended distributed transaction introduced

Evidence:

---

# 10. Idempotency Gate

Idempotency required:

* YES
* NO

If YES:

* [ ] Idempotency key defined
* [ ] Duplicate requests verified
* [ ] Duplicate events verified
* [ ] Concurrent duplicate execution verified
* [ ] Retry-after-timeout scenario verified
* [ ] Crash/restart behavior verified

Evidence:

---

# 11. Concurrency Gate

Concurrency risk:

* NONE
* LOW
* MEDIUM
* HIGH

Verify:

* [ ] Race-prone state identified
* [ ] Concurrent update behavior verified
* [ ] Locking strategy reviewed
* [ ] Lost-update risk reviewed
* [ ] Double-processing risk reviewed
* [ ] Goroutine lifecycle reviewed
* [ ] Channel/resource leak risk reviewed
* [ ] Race detector executed where practical

Evidence:

---

# 12. Error Handling Gate

* [ ] Business errors classified correctly
* [ ] Infrastructure errors classified correctly
* [ ] Error wrapping preserves root cause
* [ ] Public errors do not leak sensitive internals
* [ ] Retryable and non-retryable errors are distinguishable
* [ ] Timeout/cancellation handled correctly
* [ ] Panic is not used for normal business errors

Evidence:

---

# 13. Security Gate

Security impact:

* NONE
* LOW
* MEDIUM
* HIGH

Verify:

* [ ] Authentication reviewed
* [ ] Authorization reviewed
* [ ] Account/tenant boundary reviewed
* [ ] Sensitive data exposure reviewed
* [ ] Logging does not expose secrets
* [ ] Input validation reviewed
* [ ] Replay risk reviewed where relevant
* [ ] Audit trail reviewed where required

Security approval required:

* YES
* NO

---

# 14. Performance Gate

Performance impact:

* NONE
* LOW
* MEDIUM
* HIGH

Verify:

* [ ] Hot path impact reviewed
* [ ] SQL query plan/index considered
* [ ] N+1 queries checked
* [ ] Batch size reviewed
* [ ] Memory allocations considered
* [ ] Goroutine growth considered
* [ ] Connection-pool usage considered
* [ ] MQ throughput / lag considered
* [ ] Performance baseline compared where necessary

Evidence:

---

# 15. Observability Gate

Logs:

* [ ] Important state transitions logged
* [ ] Error logs contain actionable context
* [ ] No sensitive data logged

Metrics:

* [ ] Success metric exists where required
* [ ] Failure metric exists where required
* [ ] Latency metric exists where required
* [ ] Retry / duplicate metric exists where required

Tracing:

* [ ] Context propagation verified
* [ ] Trace propagation verified where applicable

Alerting:

* [ ] Alert requirements considered
* [ ] New critical failure modes are observable

---

# 16. Configuration Gate

* [ ] New configuration documented
* [ ] Default values safe
* [ ] Production values known
* [ ] Staging values known
* [ ] Required environment variables known
* [ ] Secret management reviewed
* [ ] Configuration backward compatibility verified

---

# 17. Feature Flag Gate

Feature flag required:

* YES
* NO

If YES:

Flag Name:

Default:

Verify:

* [ ] Default state is safe
* [ ] Enable procedure documented
* [ ] Disable procedure documented
* [ ] Flag removal plan exists
* [ ] Disabled path tested
* [ ] Enabled path tested

---

# 18. Test Gate

Required commands:

```bash
go test ./...
go test -race ./...
go vet ./...
golangci-lint run
```

Results:

| Verification        | Result       | Evidence |
| ------------------- | ------------ | -------- |
| Unit tests          | NOT_RUN      |          |
| Integration tests   | NOT_RUN      |          |
| Race detector       | NOT_RUN      |          |
| go vet              | NOT_RUN      |          |
| golangci-lint       | NOT_RUN      |          |
| Contract tests      | NOT_REQUIRED |          |
| Migration tests     | NOT_REQUIRED |          |
| Compatibility tests | NOT_RUN      |          |
| Regression tests    | NOT_RUN      |          |

Verify:

* [ ] Acceptance criteria covered
* [ ] Critical edge cases covered
* [ ] Failure paths covered
* [ ] Regression scenarios covered
* [ ] No ignored failing tests

---

# 19. Code Review Gate

Adversarial review status:

* NOT_STARTED
* COMPLETED

Verify:

* [ ] P0 findings resolved
* [ ] P1 findings resolved
* [ ] P2 findings reviewed
* [ ] Requirement coverage review completed
* [ ] Diff reviewed for unrelated changes
* [ ] AI-generated code independently inspected
* [ ] No unsupported assumptions remain

Open findings:

---

# 20. Dependency Gate

New dependency introduced:

* YES
* NO

If YES:

Dependency:

Reason:

Verify:

* [ ] Existing solution could not reasonably solve the problem
* [ ] Version pinned appropriately
* [ ] License acceptable
* [ ] Maintenance status reviewed
* [ ] Security implications reviewed
* [ ] Runtime impact reviewed

---

# 21. Deployment Plan

Deployment type:

* Rolling
* Blue/Green
* Canary
* Feature Flag
* Manual
* Other

Deployment order:

1.
2.
3.

Prerequisites:

Commands / Pipeline:

Expected duration constraints:

Dependencies:

---

# 22. Deployment Compatibility Matrix

| Component A | Version | Component B | Version | Compatible |
| ----------- | ------- | ----------- | ------- | ---------- |
|             |         |             |         |            |

Verify rolling deployment combinations where applicable.

---

# 23. Rollback Plan

Rollback trigger:

Rollback owner:

Rollback procedure:

1.
2.
3.

Verify:

* [ ] Application rollback possible
* [ ] Schema remains compatible after rollback
* [ ] Event schema remains compatible after rollback
* [ ] Feature flag can disable behavior where applicable
* [ ] New persistent data behavior understood
* [ ] Rollback has been tested or logically verified

Known rollback limitations:

---

# 24. Production Verification Plan

Immediately after deployment verify:

## Technical

* service health
* error rate
* latency
* CPU
* memory
* goroutines
* DB health
* cache health
* queue lag

## Business

* expected request volume
* expected success rate
* expected business events
* no duplicate side effects
* no abnormal state transitions

Verification queries / dashboards:

---

# 25. Production Failure Signals

Define explicit signals that require investigation or rollback.

| Signal                | Threshold | Action |
| --------------------- | --------- | ------ |
| Error rate            |           |        |
| Latency               |           |        |
| Queue lag             |           |        |
| Business failure rate |           |        |

---

# 26. Documentation Gate

Verify relevant documentation updated:

* [ ] `AGENTS.md`
* [ ] `ARCHITECTURE.md`
* [ ] `docs/architecture/`
* [ ] `docs/domain/`
* [ ] `docs/standards/`
* [ ] API documentation
* [ ] Runbook
* [ ] ADR
* [ ] Feature documentation

Do not update all documentation mechanically.

Only update documents whose long-lived knowledge changed.

---

# 27. Git / PR Gate

* [ ] Commits are logically scoped
* [ ] Commit messages are meaningful
* [ ] PR description explains business and technical change
* [ ] PR includes test evidence
* [ ] PR includes deployment plan
* [ ] PR includes rollback plan
* [ ] PR identifies known risks
* [ ] No secrets committed
* [ ] No temporary files committed

---

# 28. Known Risks

| ID       | Risk | Severity | Mitigation | Accepted By |
| -------- | ---- | -------- | ---------- | ----------- |
| RISK-001 |      |          |            |             |

Severity:

* P0
* P1
* P2
* P3

P0/P1 risks normally block delivery unless explicitly approved.

---

# 29. Remaining Gaps

List:

* unresolved uncertainty
* unavailable test environment
* unavailable production dependency
* unverified assumption
* deferred technical debt

Do not hide delivery gaps behind "follow-up" wording.

---

# 30. Delivery Decision

Final Status:

* NOT_READY
* READY_WITH_ACCEPTED_RISK
* READY

Reason:

Accepted Risks:

Approver:

Date:
