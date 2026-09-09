#!/usr/bin/env bash
set -euo pipefail

FEATURE_ID="${1:-}"

if [[ -z "${FEATURE_ID}" ]]; then
  echo "Usage:"
  echo "  $0 FEATURE-ID"
  exit 1
fi

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
DEST="${ROOT}/docs/features/${FEATURE_ID}"
TPL="${ROOT}/.codex/templates/feature"

if [[ -e "${DEST}" ]]; then
  echo "Feature already exists:"
  echo "  ${DEST}"
  exit 1
fi

mkdir -p "${DEST}/00-source"

for file in \
  01-requirement.md \
  02-current-system.md \
  03-impact-analysis.md \
  04-solution-design.md \
  05-implementation-plan.md \
  06-test-plan.md \
  07-delivery-checklist.md \
  08-retrospective.md
do
  cp "${TPL}/${file}" "${DEST}/${file}"
done

echo "Created feature workspace:"
echo "  ${DEST}"