#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"

failures=0

check() {
  local description="$1"
  shift
  if "$@"; then
    echo "PASS: ${description}"
  else
    echo "FAIL: ${description}" >&2
    failures=$((failures + 1))
  fi
}

WORKFLOW_VERSION="$(tr -d '[:space:]' <"${ROOT}/VERSION")"
SEMVER_PATTERN='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'

version_is_valid() {
  [[ "${WORKFLOW_VERSION}" =~ ${SEMVER_PATTERN} ]]
}

changelog_has_version() {
  local escaped_version="${WORKFLOW_VERSION//./\\.}"
  grep -Eq "^## \\[${escaped_version}\\] - [0-9]{4}-[0-9]{2}-[0-9]{2}$" \
    "${ROOT}/CHANGELOG.md"
}

translated_changelog_has_version() {
  local escaped_version="${WORKFLOW_VERSION//./\\.}"
  grep -Eq "^## \\[${escaped_version}\\] - [0-9]{4}-[0-9]{2}-[0-9]{2}$" \
    "${ROOT}/CHANGELOG.zh-CN.md"
}

check "VERSION is stable Semantic Versioning" version_is_valid
check "CHANGELOG contains VERSION" changelog_has_version
check "Chinese CHANGELOG contains VERSION" translated_changelog_has_version
check "source status contains VERSION" grep -Fqx -- "- Version: ${WORKFLOW_VERSION}" "${ROOT}/.codex/workspace-status.md"
check "source architecture is DEVELOPMENT" grep -Fqx 'Status: DEVELOPMENT' "${ROOT}/ARCHITECTURE.md"
check "target architecture is NOT_INITIALIZED" grep -Fqx 'Status: NOT_INITIALIZED' "${ROOT}/skeleton/ARCHITECTURE.md"
check "target workspace status is NOT_READY" grep -Fqx 'NOT_READY' "${ROOT}/skeleton/workspace-status.md"
check "shell scripts parse" bash -n "${ROOT}"/scripts/*.sh "${ROOT}"/tests/*.sh
check "workflow smoke test exists" test -s "${ROOT}/tests/workflow-smoke.sh"

if [[ "${failures}" -ne 0 ]]; then
  echo "Release verification failed: ${failures} check(s)." >&2
  exit 1
fi

echo "Release metadata verification passed for ${WORKFLOW_VERSION}."
