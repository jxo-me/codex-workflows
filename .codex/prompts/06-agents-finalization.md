# AGENTS FINALIZATION

Read:

AGENTS.md
ARCHITECTURE.md
docs/architecture/
docs/domain/
docs/standards/
docs/generated/documentation-verification.md
.codex/workspace-status.md

Use only verified Workspace knowledge. Finalize the root `AGENTS.md` as a
concise operational map containing priorities, repository boundaries, required
commands, change restrictions, evidence sources, and links to detailed docs.
Create nested AGENTS.md files only when a repository or subtree requires more
specific instructions.

Do not copy detailed architecture or domain knowledge into AGENTS.md. Do not
modify production code. Check every documented path and command.

Update `.codex/workspace-status.md`:

- mark `AGENTS.md finalized` complete only when its instructions are verified;
- set Workspace Status to READY only when no material gaps remain;
- otherwise use READY_WITH_GAPS or NOT_READY and list every gap;
- update `Last verified` with the actual verification date.

Report changed documentation and the final readiness decision.
