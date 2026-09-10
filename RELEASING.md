# Release Process

[English](RELEASING.md) | [简体中文](RELEASING.zh-CN.md)

Releases are prepared from a clean review branch and published only after all
required evidence is available.

## Version Policy

- `VERSION` contains one stable Semantic Version (`MAJOR.MINOR.PATCH`).
- `CHANGELOG.md` contains a dated entry for that exact version.
- `.codex/workspace-status.md` contains the same version and remains
  `DEVELOPMENT` until the first stable production declaration is approved.
- Breaking installer, manifest, prompt, template, or managed-file contract
  changes require a major version increment.
- Backward-compatible capabilities require a minor increment; fixes require a
  patch increment.

## Release Gates

Run from the repository root:

```bash
bash scripts/verify-release.sh
WORKFLOW_REQUIRE_GOLANGCI_LINT=1 bash tests/workflow-smoke.sh
shellcheck scripts/*.sh tests/*.sh
actionlint .github/workflows/ci.yml
```

All checks must pass. A missing required tool is a failed release gate, not a
skip. Hosted GitHub Actions must also pass before tagging.

## Publish

1. Confirm `VERSION`, `CHANGELOG.md`, and `.codex/workspace-status.md` agree.
2. Confirm the changelog describes compatibility and migration behavior.
3. Run every release gate and attach or link its evidence to the change review.
4. Merge the reviewed change.
5. Create an annotated `vVERSION` tag at the reviewed commit.
6. Publish release notes from the matching changelog entry.
7. Test a fresh install and an upgrade from the previous supported version.

## Rollback

Do not move or reuse an existing release tag. Fix the issue in a newer patch
release. Target Workspaces retain locally modified and retired files, so review
their manifests before applying a corrective upgrade.
