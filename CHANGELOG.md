# Changelog

[English](CHANGELOG.md) | [简体中文](CHANGELOG.zh-CN.md)

All notable workflow changes are recorded here. Versions follow Semantic
Versioning; dates use ISO 8601.

## [Unreleased]

## [0.4.0] - 2026-09-10

### Added

- Chinese first-run, Workspace bootstrap, phase-gate, Feature development, and
  troubleshooting guides.
- Dedicated prompts for AGENTS finalization, implementation planning, test
  execution, and retrospective knowledge capture.
- A separate Workspace discovery inventory artifact.

### Changed

- Bootstrap prompts now define phase outputs, completion criteria, and
  `.codex/workspace-status.md` transitions.

## [0.3.0] - 2026-09-10

### Added

- Release consistency verification and documented release gates.
- ShellCheck and actionlint CI gates.
- Auditable `retired` manifest records for managed assets removed by a newer
  workflow release.
- Target-path containment checks that reject symbolic-link escapes from the
  Workspace.

### Changed

- Upgrade manifests now use format 2 while remaining able to read format 1.
- Upgrades reject malformed manifests, duplicate records, unsafe paths,
  repeated versions, same-version installs, and downgrades.

## [0.2.0] - 2026-09-10

### Added

- Versioned, checksum-guarded workflow installation and upgrades.
- Separate source-repository and target-Workspace initialization states.
- Compact and extended Feature template profiles.
- GitHub Actions smoke verification.

## [0.1.0] - 2026-09-10

### Added

- Conflict-aware installer and atomic Feature initialization.
- Repository analysis, impact analysis, and code review Skills.
- Feature lifecycle prompts, standards skeletons, and multi-module Go checks.
