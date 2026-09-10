#!/usr/bin/env bash
set -uo pipefail

usage() {
  cat <<'EOF'
Usage:
  verify-workspace.sh [--allow-no-go-modules] [--quick] [WORKSPACE_ROOT]

Options:
  --allow-no-go-modules  Report success when no go.mod files are found.
  --quick                Skip the race detector.
  -h, --help             Show this help text.
EOF
}

ALLOW_NO_MODULES=0
QUICK=0
ROOT_INPUT=""

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --allow-no-go-modules)
      ALLOW_NO_MODULES=1
      ;;
    --quick)
      QUICK=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "ERROR: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [[ -n "${ROOT_INPUT}" ]]; then
        echo "ERROR: only one WORKSPACE_ROOT may be provided." >&2
        usage >&2
        exit 2
      fi
      ROOT_INPUT="$1"
      ;;
  esac
  shift
done

ROOT_INPUT="${ROOT_INPUT:-$(pwd)}"
if [[ ! -d "${ROOT_INPUT}" ]]; then
  echo "ERROR: workspace root does not exist: ${ROOT_INPUT}" >&2
  exit 2
fi
ROOT="$(cd -- "${ROOT_INPUT}" && pwd -P)"

mapfile -d '' GO_MODULE_FILES < <(
  find "${ROOT}" \
    -type f \
    -name go.mod \
    -not -path '*/vendor/*' \
    -not -path '*/.git/*' \
    -print0 | sort -z
)

echo "Workspace Verification"
echo "  root: ${ROOT}"
echo "  Go modules: ${#GO_MODULE_FILES[@]}"

if [[ "${#GO_MODULE_FILES[@]}" -eq 0 ]]; then
  if [[ "${ALLOW_NO_MODULES}" -eq 1 ]]; then
    echo "Result: SKIPPED (no Go modules found; explicitly allowed)"
    exit 0
  fi
  echo "Result: FAILED (no Go modules found)" >&2
  echo "Use --allow-no-go-modules only when this is expected." >&2
  exit 5
fi

if ! command -v go >/dev/null 2>&1; then
  echo "Result: FAILED (go executable not found)" >&2
  exit 6
fi

FAILED=0
SKIPPED=0
CHECKS_RUN=0

run_check() {
  local label="$1"
  shift
  CHECKS_RUN=$((CHECKS_RUN + 1))
  echo "  RUN  ${label}"
  if "$@"; then
    echo "  PASS ${label}"
  else
    echo "  FAIL ${label}" >&2
    FAILED=1
  fi
}

for gomod in "${GO_MODULE_FILES[@]}"; do
  module_dir="$(dirname -- "${gomod}")"
  echo
  echo "Module: ${module_dir}"

  pushd "${module_dir}" >/dev/null || {
    echo "  FAIL unable to enter module directory" >&2
    FAILED=1
    continue
  }

  run_check "go test ./..." go test ./...

  if [[ "${QUICK}" -eq 1 ]]; then
    echo "  SKIP go test -race ./... (--quick)"
    SKIPPED=$((SKIPPED + 1))
  else
    run_check "go test -race ./..." go test -race ./...
  fi

  run_check "go vet ./..." go vet ./...

  if command -v golangci-lint >/dev/null 2>&1; then
    run_check "golangci-lint run" golangci-lint run
  else
    echo "  SKIP golangci-lint run (executable not found)"
    SKIPPED=$((SKIPPED + 1))
  fi

  popd >/dev/null || exit 7
done

echo
echo "Summary: modules=${#GO_MODULE_FILES[@]} checks=${CHECKS_RUN} skipped=${SKIPPED}"
if [[ "${FAILED}" -ne 0 ]]; then
  echo "Result: FAILED" >&2
  exit 1
fi

if [[ "${SKIPPED}" -gt 0 ]]; then
  echo "Result: PASSED_WITH_SKIPS"
else
  echo "Result: PASSED"
fi
