# Changelog

All notable workflow changes are recorded here. Versions follow Semantic
Versioning; dates use ISO 8601.

## [Unreleased]

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
