#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SOURCE_ROOT="$(cd -- "${TEST_DIR}/.." && pwd -P)"
TMP_ROOT="$(mktemp -d /tmp/codex-workflow-test.XXXXXX)"
SOURCE_VERSION="$(tr -d '[:space:]' <"${SOURCE_ROOT}/VERSION")"
IFS='.' read -r SOURCE_MAJOR SOURCE_MINOR SOURCE_PATCH <<<"${SOURCE_VERSION}"
UPGRADE_VERSION_1="${SOURCE_MAJOR}.${SOURCE_MINOR}.$((10#${SOURCE_PATCH} + 1))"
UPGRADE_VERSION_2="${SOURCE_MAJOR}.${SOURCE_MINOR}.$((10#${SOURCE_PATCH} + 2))"
UPGRADE_VERSION_3="${SOURCE_MAJOR}.${SOURCE_MINOR}.$((10#${SOURCE_PATCH} + 3))"

cleanup() {
  if [[ -n "${TMP_ROOT:-}" && -d "${TMP_ROOT}" ]]; then
    rm -rf -- "${TMP_ROOT}"
  fi
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

expect_status() {
  local expected="$1"
  shift
  local actual

  set +e
  "$@"
  actual=$?
  set -e

  if [[ "${actual}" -ne "${expected}" ]]; then
    fail "expected exit ${expected}, got ${actual}: $*"
  fi
}

WORKSPACE="${TMP_ROOT}/workspace with spaces"

"${SOURCE_ROOT}/scripts/codex-workflow-init.sh" --dry-run "${WORKSPACE}"
[[ ! -e "${WORKSPACE}" ]] || fail "dry-run created the target"
expect_status 2 "${SOURCE_ROOT}/scripts/codex-workflow-init.sh" "${SOURCE_ROOT}"
expect_status 5 "${SOURCE_ROOT}/scripts/codex-workflow-init.sh" --upgrade "${TMP_ROOT}/never-installed"

SYMLINK_WORKSPACE="${TMP_ROOT}/symlink-workspace"
OUTSIDE_DIRECTORY="${TMP_ROOT}/outside-workspace"
mkdir -p -- "${SYMLINK_WORKSPACE}" "${OUTSIDE_DIRECTORY}"
ln -s -- "${OUTSIDE_DIRECTORY}" "${SYMLINK_WORKSPACE}/docs"
expect_status 4 "${SOURCE_ROOT}/scripts/codex-workflow-init.sh" "${SYMLINK_WORKSPACE}"
[[ -z "$(find "${OUTSIDE_DIRECTORY}" -mindepth 1 -print -quit)" ]] ||
  fail "installer followed a directory symlink outside the target"

"${SOURCE_ROOT}/scripts/codex-workflow-init.sh" "${WORKSPACE}"
"${SOURCE_ROOT}/scripts/codex-workflow-init.sh" "${WORKSPACE}"

required_assets=(
  ".agents/skills/repository-analysis/SKILL.md"
  ".agents/skills/impact-analysis/SKILL.md"
  ".agents/skills/code-review/SKILL.md"
  ".codex/prompts/feature-start.md"
  ".codex/prompts/feature-current-system.md"
  ".codex/prompts/feature-impact.md"
  ".codex/prompts/feature-design.md"
  ".codex/prompts/feature-implement.md"
  ".codex/prompts/feature-review.md"
  ".codex/prompts/feature-delivery.md"
  ".codex/prompts/feature-plan.md"
  ".codex/prompts/feature-test.md"
  ".codex/prompts/feature-retrospective.md"
  ".codex/prompts/06-agents-finalization.md"
  ".codex/templates/feature/01-requirement.md"
  ".codex/templates/feature/08-retrospective.md"
  ".codex/templates/feature-compact/01-requirement.md"
  ".codex/templates/feature-compact/08-retrospective.md"
  ".codex/workflow-install.manifest"
  "README-AI-WORKFLOW.zh-CN.md"
  "docs/standards/testing.md"
  "docs/architecture/workspace-inventory.md"
  "docs/guides/first-run.zh-CN.md"
  "docs/guides/workspace-bootstrap.zh-CN.md"
  "docs/guides/feature-development.zh-CN.md"
  "docs/guides/phase-gates.zh-CN.md"
  "docs/guides/troubleshooting.zh-CN.md"
  "scripts/feature-init.sh"
  "scripts/verify-workspace.sh"
)

for relative_path in "${required_assets[@]}"; do
  [[ -s "${WORKSPACE}/${relative_path}" ]] ||
    fail "missing installed asset: ${relative_path}"
done

grep -q 'docs/architecture/workspace-inventory.md' "${WORKSPACE}/.codex/prompts/00-bootstrap.md" ||
  fail "bootstrap prompt does not use the independent inventory artifact"
grep -q 'docs/generated/documentation-verification.md' "${WORKSPACE}/.codex/prompts/05-verification.md" ||
  fail "documentation verification prompt has no fixed report output"

cmp -s -- "${SOURCE_ROOT}/skeleton/ARCHITECTURE.md" "${WORKSPACE}/ARCHITECTURE.md" ||
  fail "target architecture did not come from the workspace skeleton"
grep -q '^NOT_READY$' "${WORKSPACE}/.codex/workspace-status.md" ||
  fail "installed workspace status is not NOT_READY"
grep -Fqx $'format\t2' "${WORKSPACE}/.codex/workflow-install.manifest" ||
  fail "install manifest format is not 2"
grep -Fqx $'version\t'"${SOURCE_VERSION}" "${WORKSPACE}/.codex/workflow-install.manifest" ||
  fail "install manifest version is missing"
expect_status 5 "${SOURCE_ROOT}/scripts/codex-workflow-init.sh" --upgrade "${WORKSPACE}"

cp -- "${SOURCE_ROOT}/README_1.md" "${WORKSPACE}/AGENTS.md"
expect_status 4 "${SOURCE_ROOT}/scripts/codex-workflow-init.sh" "${WORKSPACE}"
"${SOURCE_ROOT}/scripts/codex-workflow-init.sh" --force "${WORKSPACE}"
cmp -s -- "${SOURCE_ROOT}/AGENTS.md" "${WORKSPACE}/AGENTS.md" ||
  fail "force did not restore AGENTS.md"

"${WORKSPACE}/scripts/feature-init.sh" FEATURE-123
[[ -f "${WORKSPACE}/docs/features/FEATURE-123/00-source/.gitkeep" ]] ||
  fail "feature source placeholder is missing"
[[ "$(find "${WORKSPACE}/docs/features/FEATURE-123" -maxdepth 1 -type f -name '*.md' | wc -l)" -eq 8 ]] ||
  fail "feature document count is not eight"
grep -q '^Feature: FEATURE-123$' "${WORKSPACE}/docs/features/FEATURE-123/01-requirement.md" ||
  fail "feature identifier was not populated"

"${WORKSPACE}/scripts/feature-init.sh" --profile compact FEATURE-124
[[ "$(find "${WORKSPACE}/docs/features/FEATURE-124" -maxdepth 1 -type f -name '*.md' | wc -l)" -eq 8 ]] ||
  fail "compact feature document count is not eight"
for compact_document in "${WORKSPACE}/docs/features/FEATURE-124"/*.md; do
  grep -q '^Feature: FEATURE-124$' "${compact_document}" ||
    fail "compact feature identifier was not populated in ${compact_document}"
done
[[ "$(wc -l <"${WORKSPACE}/docs/features/FEATURE-124/06-test-plan.md")" -lt "$(wc -l <"${WORKSPACE}/docs/features/FEATURE-123/06-test-plan.md")" ]] ||
  fail "compact test plan is not smaller than the extended template"
expect_status 2 "${WORKSPACE}/scripts/feature-init.sh" --profile invalid FEATURE-125

expect_status 4 "${WORKSPACE}/scripts/feature-init.sh" FEATURE-123
expect_status 2 "${WORKSPACE}/scripts/feature-init.sh" ../escape
[[ ! -e "${WORKSPACE}/docs/escape" ]] || fail "invalid feature escaped its root"

MISSING_TEMPLATE_WORKSPACE="${TMP_ROOT}/missing-template"
"${SOURCE_ROOT}/scripts/codex-workflow-init.sh" "${MISSING_TEMPLATE_WORKSPACE}"
mv -- "${MISSING_TEMPLATE_WORKSPACE}/.codex/templates/feature/08-retrospective.md" "${MISSING_TEMPLATE_WORKSPACE}/.codex/templates/feature/08-retrospective.md.missing"
expect_status 3 "${MISSING_TEMPLATE_WORKSPACE}/scripts/feature-init.sh" ATOMIC-1
[[ ! -e "${MISSING_TEMPLATE_WORKSPACE}/docs/features/ATOMIC-1" ]] ||
  fail "failed feature initialization left a partial destination"

UPGRADE_SOURCE="${TMP_ROOT}/upgrade-source"
cp -R -- "${SOURCE_ROOT}" "${UPGRADE_SOURCE}"
sed -i $'s/^format\t2$/format\t1/' "${WORKSPACE}/.codex/workflow-install.manifest"
printf '0.0.0\n' >"${UPGRADE_SOURCE}/VERSION"
expect_status 5 "${UPGRADE_SOURCE}/scripts/codex-workflow-init.sh" --upgrade "${WORKSPACE}"
printf '%s\n' "${UPGRADE_VERSION_1}" >"${UPGRADE_SOURCE}/VERSION"
printf '\nUpgrade fixture %s.\n' "${UPGRADE_VERSION_1}" >>"${UPGRADE_SOURCE}/README-AI-WORKFLOW.md"
"${UPGRADE_SOURCE}/scripts/codex-workflow-init.sh" --upgrade "${WORKSPACE}"
cmp -s -- "${UPGRADE_SOURCE}/README-AI-WORKFLOW.md" "${WORKSPACE}/README-AI-WORKFLOW.md" ||
  fail "upgrade did not replace an unchanged managed asset"
grep -Fqx $'version\t'"${UPGRADE_VERSION_1}" "${WORKSPACE}/.codex/workflow-install.manifest" ||
  fail "upgrade did not refresh the manifest version"

RETIRED_ASSET="docs/standards/idempotency.md"
printf '%s\n' "${UPGRADE_VERSION_2}" >"${UPGRADE_SOURCE}/VERSION"
rm -f -- "${UPGRADE_SOURCE}/${RETIRED_ASSET}"
"${UPGRADE_SOURCE}/scripts/codex-workflow-init.sh" --upgrade "${WORKSPACE}"
[[ -f "${WORKSPACE}/${RETIRED_ASSET}" ]] ||
  fail "upgrade deleted a retired managed asset"
grep -Eq $'^retired\t[[:xdigit:]]{64}\t'"${RETIRED_ASSET}"'$' \
  "${WORKSPACE}/.codex/workflow-install.manifest" ||
  fail "retired asset was not retained in the install manifest"
"${UPGRADE_SOURCE}/scripts/codex-workflow-init.sh" "${WORKSPACE}"
grep -Eq $'^retired\t[[:xdigit:]]{64}\t'"${RETIRED_ASSET}"'$' \
  "${WORKSPACE}/.codex/workflow-install.manifest" ||
  fail "normal reinstall discarded retired asset audit history"

printf '\nLocal retired asset customization.\n' >>"${WORKSPACE}/${RETIRED_ASSET}"
cp -- "${WORKSPACE}/${RETIRED_ASSET}" "${TMP_ROOT}/locally-modified-retired-asset"
cp -- "${SOURCE_ROOT}/${RETIRED_ASSET}" "${UPGRADE_SOURCE}/${RETIRED_ASSET}"
printf '%s\n' "${UPGRADE_VERSION_3}" >"${UPGRADE_SOURCE}/VERSION"
expect_status 4 "${UPGRADE_SOURCE}/scripts/codex-workflow-init.sh" --upgrade "${WORKSPACE}"
cmp -s -- "${TMP_ROOT}/locally-modified-retired-asset" "${WORKSPACE}/${RETIRED_ASSET}" ||
  fail "reintroduced retired asset replaced a local customization"
rm -f -- "${UPGRADE_SOURCE}/${RETIRED_ASSET}"

printf '\nLocal target customization.\n' >>"${WORKSPACE}/README-AI-WORKFLOW.md"
cp -- "${WORKSPACE}/README-AI-WORKFLOW.md" "${TMP_ROOT}/locally-modified-readme"
printf '%s\n' "${UPGRADE_VERSION_3}" >"${UPGRADE_SOURCE}/VERSION"
printf '\nUpgrade fixture %s.\n' "${UPGRADE_VERSION_3}" >>"${UPGRADE_SOURCE}/README-AI-WORKFLOW.md"
expect_status 4 "${UPGRADE_SOURCE}/scripts/codex-workflow-init.sh" --upgrade "${WORKSPACE}"
cmp -s -- "${TMP_ROOT}/locally-modified-readme" "${WORKSPACE}/README-AI-WORKFLOW.md" ||
  fail "rejected upgrade changed a locally modified asset"

MALFORMED_MANIFEST_WORKSPACE="${TMP_ROOT}/malformed-manifest"
"${SOURCE_ROOT}/scripts/codex-workflow-init.sh" "${MALFORMED_MANIFEST_WORKSPACE}"
printf 'format\t2\nversion\t%s\n' "${SOURCE_VERSION}" >"${MALFORMED_MANIFEST_WORKSPACE}/.codex/workflow-install.manifest"
expect_status 5 "${UPGRADE_SOURCE}/scripts/codex-workflow-init.sh" --upgrade "${MALFORMED_MANIFEST_WORKSPACE}"

expect_status 5 "${WORKSPACE}/scripts/verify-workspace.sh" "${WORKSPACE}"
"${WORKSPACE}/scripts/verify-workspace.sh" --allow-no-go-modules "${WORKSPACE}"

if command -v go >/dev/null 2>&1; then
  GO_WORKSPACE="${TMP_ROOT}/go-workspace"
  mkdir -p -- "${GO_WORKSPACE}"

  cat >"${GO_WORKSPACE}/go.mod" <<'EOF'
module example.com/codex-workflow-smoke

go 1.22
EOF

  cat >"${GO_WORKSPACE}/smoke.go" <<'EOF'
package smoke

func Ready() bool {
	return true
}
EOF

  cat >"${GO_WORKSPACE}/smoke_test.go" <<'EOF'
package smoke

import "testing"

func TestReady(t *testing.T) {
	if !Ready() {
		t.Fatal("fixture is not ready")
	}
}
EOF

  REQUIRED_TOOL_PATH="${TMP_ROOT}/required-tool-path"
  mkdir -p -- "${REQUIRED_TOOL_PATH}"
  ln -s -- "$(command -v go)" "${REQUIRED_TOOL_PATH}/go"
  ln -s -- "$(command -v find)" "${REQUIRED_TOOL_PATH}/find"
  ln -s -- "$(command -v sort)" "${REQUIRED_TOOL_PATH}/sort"
  expect_status 8 env PATH="${REQUIRED_TOOL_PATH}" /bin/bash \
    "${WORKSPACE}/scripts/verify-workspace.sh" --require-golangci-lint "${GO_WORKSPACE}"

  VERIFY_OPTIONS=()
  if [[ "${WORKFLOW_REQUIRE_GOLANGCI_LINT:-0}" == "1" ]]; then
    VERIFY_OPTIONS+=("--require-golangci-lint")
  fi

  GOCACHE="${TMP_ROOT}/go-build-cache" \
    GOLANGCI_LINT_CACHE="${TMP_ROOT}/golangci-lint-cache" \
    "${WORKSPACE}/scripts/verify-workspace.sh" "${VERIFY_OPTIONS[@]}" "${GO_WORKSPACE}"
else
  echo "SKIP: Go verification fixture (go executable not found)"
fi

echo "PASS: workflow smoke test"
