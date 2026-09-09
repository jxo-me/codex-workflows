#!/usr/bin/env bash
set -uo pipefail

ROOT="${1:-$(pwd)}"

FAILED=0

echo "======================================"
echo "Workspace Verification"
echo "======================================"

while IFS= read -r gomod; do
  dir="$(dirname "${gomod}")"

  echo
  echo "--------------------------------------"
  echo "Go module:"
  echo "${dir}"
  echo "--------------------------------------"

  (
    cd "${dir}"

    echo "[1] go test ./..."
    go test ./... || exit 11

    echo "[2] go vet ./..."
    go vet ./... || exit 12

    if command -v golangci-lint >/dev/null 2>&1; then
      echo "[3] golangci-lint run"
      golangci-lint run || exit 13
    else
      echo "[3] golangci-lint: SKIPPED"
    fi
  )

  rc=$?

  if [[ "${rc}" -ne 0 ]]; then
    echo "FAILED: ${dir}"
    FAILED=1
  fi

done < <(
  find "${ROOT}" \
    -type f \
    -name go.mod \
    -not -path '*/vendor/*' \
    -not -path '*/.git/*'
)

exit "${FAILED}"