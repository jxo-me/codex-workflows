# Codex Workflow Template Architecture

Status: DEVELOPMENT

This repository is the versioned source for a workflow installer. It is not an
initialized target workspace.

## Boundaries

- `scripts/codex-workflow-init.sh` installs versioned assets into another workspace.
- `skeleton/` contains stateful files whose installed content differs from this
  source repository.
- `.codex/prompts/`, `.codex/templates/`, `.agents/skills/`, `docs/`, and
  `scripts/` contain managed installation assets.
- `.codex/workflow-install.manifest` exists only in an installed workspace and
  records the release version, active checksums, and retired assets used for
  safe upgrades.

## Safety Model

The installer rejects installation into this source checkout. Existing target
files are preserved unless they match the previous installation manifest during
an explicit upgrade, or the operator explicitly uses `--force`.

Manifest format 2 retains audit records for assets removed from a newer release
without deleting the target files. Format 1 remains readable as an upgrade
source, but all successful installations write format 2.

Detailed architecture documentation under `docs/architecture/` is installed as
an evidence-driven placeholder and must be completed in the target workspace.
