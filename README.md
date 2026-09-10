# Codex Engineering Workflow

A repository template for installing an evidence-driven, staged engineering
workflow into an existing single- or multi-repository Workspace.

Status: DEVELOPMENT

The current implementation provides:

- safe, conflict-aware Workspace installation
- versioned, checksum-guarded Workspace upgrades
- repository-scoped Codex Skills
- staged Workspace discovery prompts
- Feature analysis, design, implementation, review, and delivery prompts
- compact and extended eight-document Feature profiles
- multi-module Go verification
- GitHub Actions smoke verification

## Requirements

- Linux
- Bash 4 or later
- GNU coreutils, findutils, and sed
- Go for verifying Go modules
- golangci-lint when linting is a required repository gate
- ShellCheck and actionlint for release verification

## Install

Preview the files that would be installed:

    bash scripts/codex-workflow-init.sh --dry-run /path/to/workspace

Install:

    bash scripts/codex-workflow-init.sh /path/to/workspace

Existing files with different content are rejected by default. Review every
reported conflict before considering an explicit --force installation.

An installation records its version and managed-file checksums in
`.codex/workflow-install.manifest`. To upgrade, check out the newer workflow
release and run its installer:

    bash scripts/codex-workflow-init.sh --dry-run --upgrade /path/to/workspace
    bash scripts/codex-workflow-init.sh --upgrade /path/to/workspace

`--upgrade` only replaces a managed file when its current checksum still
matches the previous manifest. Locally modified files remain conflicts. The
workflow source checkout is intentionally rejected as an installation target.
Assets removed by a newer release are preserved in the target and recorded as
`retired` in manifest format 2; the installer never deletes them implicitly.
Target paths that resolve through symbolic links outside the Workspace are
rejected before any installation file is written.

## Start a Feature

From an installed Workspace:

    ./scripts/feature-init.sh FEATURE-ID

The backward-compatible default uses the detailed `extended` templates. For a
routine change, select the shorter profile explicitly:

    ./scripts/feature-init.sh --profile compact FEATURE-ID

Place verified source material under docs/features/FEATURE-ID/00-source/, then
follow [README-AI-WORKFLOW.md](README-AI-WORKFLOW.md).

Launch Codex from the installed Workspace root so root AGENTS.md guidance and
repository-scoped Skills are in its discovery path.

## Verify

    ./scripts/verify-workspace.sh /path/to/workspace

This runs tests, the race detector, vet, and golangci-lint when it is installed
for every discovered Go module. A Workspace with no Go modules fails unless
--allow-no-go-modules is explicitly supplied.

Run the installer and Feature lifecycle regression suite:

    bash tests/workflow-smoke.sh

## Release

Validate version, changelog, repository state, and script syntax:

    bash scripts/verify-release.sh

The complete release gates and tagging procedure are documented in
[RELEASING.md](RELEASING.md). User-visible changes are recorded in
[CHANGELOG.md](CHANGELOG.md).

## Design Sources

- [README_1.md](README_1.md) describes the staged AI-assisted SDLC.
- [README_2.md](README_2.md) is the original bootstrap implementation proposal.

These source documents explain the design intent. This README,
[README-AI-WORKFLOW.md](README-AI-WORKFLOW.md), and executable behavior are the
operational source of truth.
