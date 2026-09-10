# Feature Engineering Retrospective

Feature ID:

Feature Name:

Release Version:

Owner:

Completion Date:

Production Status:

---

# 1. Purpose

This retrospective captures reusable engineering knowledge discovered during the feature lifecycle.

The goal is to improve:

* future feature delivery
* Codex workspace understanding
* architecture documentation
* domain documentation
* engineering standards
* automated verification
* reusable skills
* operational readiness

This document should not become a generic project diary.

Only record information that improves future engineering decisions.

---

# 2. Feature Outcome

Business outcome:

Technical outcome:

Release status:

* SUCCESS
* SUCCESS_WITH_ISSUES
* ROLLED_BACK
* PARTIAL
* CANCELLED

Summary:

---

# 3. Planned vs Actual Scope

## Planned

Repositories:

Components:

Estimated architectural impact:

## Actual

Repositories modified:

Components modified:

Unexpected affected areas:

Explain scope differences:

---

# 4. Requirement Quality Review

Were requirements sufficiently clear?

* YES
* PARTIAL
* NO

What was ambiguous?

What was missing?

What assumptions were initially wrong?

What business rule was discovered only during implementation?

Should any of this become long-lived domain documentation?

---

# 5. System Understanding Gaps

What important system behavior was not documented before this feature?

Examples:

* hidden cross-service dependency
* undocumented database ownership
* undocumented MQ consumer
* retry behavior
* timeout behavior
* legacy compatibility constraint
* hidden configuration
* production-only behavior

For each gap:

| Gap | Impact | Evidence | Should Be Documented In |
| --- | ------ | -------- | ----------------------- |
|     |        |          |                         |

Possible destinations:

* `ARCHITECTURE.md`
* `docs/architecture/`
* `docs/domain/`
* `docs/standards/`
* repository-level `AGENTS.md`
* runbook

---

# 6. Architecture Lessons

Did the current architecture help or hinder implementation?

Identify:

* useful existing patterns
* problematic coupling
* missing abstractions
* unnecessary abstractions
* dependency direction problems
* transaction complexity
* consistency problems
* observability gaps

Do not propose refactoring solely because the code is old.

Record only changes justified by repeated or material engineering cost.

---

# 7. Domain Knowledge Learned

Document business/domain knowledge learned during implementation.

Examples:

* invariants
* state-transition restrictions
* ownership boundaries
* data semantics
* settlement rules
* wallet rules
* retry semantics
* historical compatibility rules

For each item:

| Knowledge | Source | Long-Lived? | Destination |
| --------- | ------ | ----------- | ----------- |
|           |        | YES/NO      |             |

If long-lived, update the appropriate domain documentation.

---

# 8. Implementation Lessons

What implementation approach worked well?

What implementation assumption failed?

What existing code pattern was worth reusing?

What pattern should not be repeated?

Were there unnecessary changes?

Was the implementation plan granular enough?

---

# 9. Testing Lessons

Which test caught the most important issue?

Which bug escaped early testing?

Were any test layers missing?

Examples:

* unit coverage insufficient
* integration environment mismatch
* concurrency test missing
* race detector finding
* migration test missing
* compatibility test missing
* duplicate-message test missing

Recommended future improvements:

---

# 10. Production Lessons

Did production behavior differ from local/staging expectations?

Review:

* latency
* throughput
* resource consumption
* DB behavior
* cache behavior
* MQ behavior
* retry behavior
* observability
* alert quality

Unexpected production behavior:

---

# 11. Incident / Defect Review

Defects discovered:

| ID | Severity | Stage Found | Root Cause | Preventable |
| -- | -------- | ----------- | ---------- | ----------- |
|    |          |             |            | YES/NO      |

Stages may include:

* Requirement
* Design
* Implementation
* Unit Test
* Integration Test
* Review
* Staging
* Production

---

# 12. Root Cause Classification

For important defects classify root cause.

Possible categories:

* REQUIREMENT_GAP
* ARCHITECTURE_KNOWLEDGE_GAP
* DOMAIN_KNOWLEDGE_GAP
* IMPLEMENTATION_ERROR
* TEST_GAP
* REVIEW_GAP
* TOOLING_GAP
* OBSERVABILITY_GAP
* DEPLOYMENT_GAP
* DOCUMENTATION_GAP

Root cause:

---

# 13. Codex Effectiveness Review

Evaluate Codex performance for this feature.

## What Codex Did Well

Examples:

* repository discovery
* similar implementation discovery
* call-chain tracing
* code generation
* unit test generation
* review
* documentation

## Where Codex Was Wrong

Record concrete cases:

* unsupported architectural assumption
* incorrect business assumption
* incomplete call chain
* unnecessary abstraction
* incorrect test assumption
* cross-repository misunderstanding

## Why Was It Wrong?

Possible causes:

* missing AGENTS rule
* missing architecture documentation
* missing domain documentation
* weak prompt
* insufficient repository evidence
* ambiguous product requirement
* stale documentation

---

# 14. AGENTS.md Feedback

Did Codex need a rule that should have already been in `AGENTS.md`?

* YES
* NO

Candidate additions:

Only add rules that are:

* long-lived
* broadly applicable
* high-value
* easy to violate
* important to correctness

Do not add feature-specific details.

Proposed change:

---

# 15. Repository-Level AGENTS Feedback

Should any repository receive or update its own `AGENTS.md`?

Repository:

Rule:

Reason:

Examples of valid repository-level rules:

* state changes must use a state machine
* wallet balances must not be updated directly
* consumer must be idempotent
* specific generated code must not be edited
* transaction entry point is fixed

---

# 16. Architecture Documentation Feedback

Documents requiring update:

* [ ] `ARCHITECTURE.md`
* [ ] `system-map.md`
* [ ] `repository-map.md`
* [ ] `service-dependencies.md`
* [ ] `data-flow.md`
* [ ] `event-flow.md`
* [ ] `database-map.md`
* [ ] `runtime-map.md`

Required changes:

---

# 17. Domain Documentation Feedback

Domain documents requiring update:

Reason:

New invariant discovered:

New state transition discovered:

New ownership rule discovered:

---

# 18. Engineering Standards Feedback

Should any engineering convention be formalized?

Potential destinations:

* `go-style.md`
* `architecture-rules.md`
* `error-handling.md`
* `transaction.md`
* `idempotency.md`
* `logging-observability.md`
* `testing.md`
* `delivery.md`

Candidate rule:

Evidence:

Is this pattern repeated enough to become a standard?

* YES
* NO
* NEED_MORE_EVIDENCE

---

# 19. Skill Feedback

Evaluate existing Codex skills used during this feature.

Skills:

* requirement-analysis
* repository-analysis
* impact-analysis
* architecture-design
* go-implementation
* go-testing
* code-review
* delivery-review

For each relevant skill:

| Skill | Worked Well | Gap | Proposed Improvement |
| ----- | ----------- | --- | -------------------- |
|       |             |     |                      |

Do not modify a shared skill based on one unusual edge case unless it generalizes.

---

# 20. Prompt Feedback

Which prompts required manual correction?

What instruction was repeatedly added manually?

Could that instruction move to:

* AGENTS.md
* docs/
* Skill
* template
* nowhere

Repeated prompt additions are candidates for workflow improvement.

---

# 21. Automation Opportunities

Identify repetitive manual work that could become automation.

Examples:

* repository discovery
* dependency map generation
* test execution
* API diff
* migration validation
* protobuf compatibility
* SQL linting
* coverage reporting
* dependency vulnerability checks
* PR generation

Candidate automation:

Value:

Complexity:

Priority:

---

# 22. Delivery Process Feedback

What delayed delivery?

Possible causes:

* requirement clarification
* cross-repo dependency
* test environment
* manual deployment
* unclear ownership
* data migration
* missing tooling
* review bottleneck

Recommended improvement:

---

# 23. Technical Debt Created

Did this feature intentionally introduce technical debt?

* YES
* NO

If YES:

Debt:

Reason:

Risk:

Follow-up:

Owner:

Do not label unfinished required functionality as technical debt.

---

# 24. Technical Debt Discovered

Existing technical debt discovered during the feature:

| Item | Impact | Urgency | Follow-up |
| ---- | ------ | ------- | --------- |
|      |        |         |           |

Avoid unrelated cleanup during feature delivery.

Capture it here instead.

---

# 25. Reusable Knowledge Capture

Classify reusable knowledge.

## Architecture Knowledge

## Domain Knowledge

## Coding Convention

## Testing Pattern

## Operational Knowledge

## Known Pitfall

## Delivery Pattern

For every reusable item specify its destination.

---

# 26. Workspace Updates

After retrospective, verify whether the following need updates:

* [ ] root `AGENTS.md`
* [ ] repository `AGENTS.md`
* [ ] `ARCHITECTURE.md`
* [ ] `docs/architecture/`
* [ ] `docs/domain/`
* [ ] `docs/standards/`
* [ ] `docs/runbooks/`
* [ ] `.agents/skills/`
* [ ] `.codex/templates/`
* [ ] scripts / automation

Changes actually made:

---

# 27. Keep / Change / Stop

## Keep

Practices that worked and should continue.

## Change

Practices that should be improved.

## Stop

Practices that created risk, waste, or confusion.

---

# 28. Final Knowledge Capture Decision

Knowledge promoted to long-lived workspace documentation:

Knowledge retained only in feature history:

Workflow changes:

Skill changes:

Automation changes:

---

# 29. Feature Lifecycle Status

* [ ] Feature delivered
* [ ] Production verified
* [ ] Known risks recorded
* [ ] Documentation updated
* [ ] Retrospective completed
* [ ] Reusable knowledge captured
* [ ] Follow-up work created where necessary

Final Status:

CLOSED / CLOSED_WITH_FOLLOW_UP / REOPENED
