# Transactions and Consistency

Status: NOT_INITIALIZED

Document verified transaction ownership, isolation expectations, commit and
rollback behavior, side-effect ordering, distributed consistency, and
compensation patterns.

For each transaction boundary record:

- owner and entry point
- participating storage
- operations inside and outside the transaction
- retry and partial-failure behavior
- verification evidence

Never infer atomicity from function names alone.
