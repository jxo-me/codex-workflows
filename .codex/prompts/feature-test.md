# FEATURE TEST

Feature ID:

{{FEATURE_ID}}

Read the requirement, approved design, implementation plan, current diff, and
repository verification rules. Create or update:

docs/features/{{FEATURE_ID}}/06-test-plan.md

Map every acceptance criterion and material risk to a test scenario and layer.
Include success, validation, authorization, compatibility, idempotency,
concurrency, retry, partial-failure, rollback, and observability checks when
applicable.

Run only safe, in-scope verification commands. Record the exact command,
result, and evidence. Never mark an unexecuted check as passed. Use PASS, FAIL,
SKIPPED, BLOCKED, and NEEDS_VERIFICATION. Do not modify production code while
acting as the test phase.
