You are bootstrapping this workspace for long-term AI-assisted engineering.

This is DISCOVERY ONLY.

Do not modify production source code.

You may update engineering documentation under:

AGENTS.md
ARCHITECTURE.md
docs/
.codex/

Tasks:

1. Identify workspace root.
2. Identify every Git repository under the workspace.
3. Identify repository boundaries.
4. Identify programming languages.
5. Identify Go modules.
6. Identify build systems.
7. Identify testing tools.
8. Identify linters.
9. Identify deployment/configuration systems.
10. Identify likely service entry points.

Do not infer service responsibilities yet.

Produce a bootstrap report containing:

- repositories
- repository paths
- languages
- Go modules
- executable entry points
- build commands
- test commands
- lint commands
- config/deployment locations

For every statement provide file-based evidence.

Mark unclear items:

UNKNOWN
UNCERTAIN
NEEDS_VERIFICATION

Update only:

docs/architecture/workspace-inventory.md
.codex/workspace-status.md

Do not edit other architecture files yet.

Mark `Repository discovery` complete only when every in-scope Git boundary has
been inspected. Otherwise leave it incomplete and record the blocking gaps.
