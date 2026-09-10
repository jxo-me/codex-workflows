# AI Engineering Workflow

[English](README-AI-WORKFLOW.md) | [简体中文](README-AI-WORKFLOW.zh-CN.md)

## Install the Workflow

Run the installer from a complete checkout of this repository:

```bash
bash scripts/codex-workflow-init.sh /path/to/workspace
```

The installer copies the shipped prompts, templates, skills, documentation,
and helper scripts. It refuses to replace files with different content unless
`--force` is explicitly supplied. Use `--dry-run` to validate an installation
without writing files. The template source checkout and installed Workspace
must be different directories.

Each installation writes `.codex/workflow-install.manifest` with the workflow
version and SHA-256 checksum of every managed asset. From a newer, complete
workflow checkout, preview and apply an upgrade with:

```bash
bash scripts/codex-workflow-init.sh --dry-run --upgrade /path/to/workspace
bash scripts/codex-workflow-init.sh --upgrade /path/to/workspace
```

An upgrade replaces only assets that still match the previous manifest.
Locally modified or unmanaged files remain conflicts and require explicit
reconciliation; `--force` is a separate operator override. When a newer
release no longer ships a previously managed asset, the target file is retained
and recorded as `retired`; removal remains an explicit operator decision.
The installer also rejects managed paths that resolve through symbolic links
outside the target Workspace.

## Workspace Bootstrap

Run Codex prompts in this order:

1. .codex/prompts/00-bootstrap.md
2. .codex/prompts/01-repository-analysis.md
3. .codex/prompts/02-architecture-analysis.md
4. .codex/prompts/03-domain-analysis.md
5. .codex/prompts/04-standards-analysis.md
6. .codex/prompts/05-verification.md

Repository-scoped reusable workflows live under:

    .agents/skills/

## Feature Workflow

Create a feature workspace:

```bash
./scripts/feature-init.sh FEATURE-ID
```

This uses the detailed `extended` template profile for backward compatibility.
Use the smaller profile for routine, bounded work:

```bash
./scripts/feature-init.sh --profile compact FEATURE-ID
```

Pass the Workspace root as the second argument only when invoking a script that
is not installed under that Workspace:

```bash
./scripts/feature-init.sh FEATURE-ID /path/to/workspace
```

Then execute:

1. .codex/prompts/feature-start.md
2. .codex/prompts/feature-current-system.md
3. .codex/prompts/feature-impact.md
4. .codex/prompts/feature-design.md
5. complete and approve 05-implementation-plan.md
6. .codex/prompts/feature-implement.md for one task at a time
7. complete and execute 06-test-plan.md
8. .codex/prompts/feature-review.md
9. .codex/prompts/feature-delivery.md
10. complete 08-retrospective.md and capture reusable knowledge

## Verification

Run all discovered Go modules through tests, the race detector, vet, and—when
installed—golangci-lint:

```bash
./scripts/verify-workspace.sh
```

No discovered Go modules is a failure by default. For a deliberately non-Go
Workspace, acknowledge that condition explicitly:

```bash
./scripts/verify-workspace.sh --allow-no-go-modules
```
