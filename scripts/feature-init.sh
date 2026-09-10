#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  feature-init.sh [--profile compact|extended] FEATURE-ID [WORKSPACE_ROOT]

FEATURE-ID may contain letters, numbers, dots, underscores, and hyphens. It
must start with a letter or number. WORKSPACE_ROOT defaults to the parent of
the directory containing this installed script. The default profile is
extended for backward compatibility; compact is intended for routine changes.
EOF
}

PROFILE="extended"
POSITIONAL=()

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --profile)
      if [[ "$#" -lt 2 ]]; then
        echo "ERROR: --profile requires compact or extended." >&2
        exit 2
      fi
      PROFILE="$2"
      shift
      ;;
    --profile=*)
      PROFILE="${1#*=}"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      while [[ "$#" -gt 0 ]]; do
        POSITIONAL+=("$1")
        shift
      done
      break
      ;;
    -*)
      echo "ERROR: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      POSITIONAL+=("$1")
      ;;
  esac
  shift
done

if [[ "${PROFILE}" != "compact" && "${PROFILE}" != "extended" ]]; then
  echo "ERROR: invalid profile: ${PROFILE}" >&2
  echo "Use compact or extended." >&2
  exit 2
fi

FEATURE_ID="${POSITIONAL[0]:-}"

if [[ -z "${FEATURE_ID}" ]]; then
  usage >&2
  exit 2
fi

if [[ "${#POSITIONAL[@]}" -gt 2 ]]; then
  echo "ERROR: too many arguments." >&2
  usage >&2
  exit 2
fi

if [[ ! "${FEATURE_ID}" =~ ^[[:alnum:]][[:alnum:]_.-]*$ ]]; then
  echo "ERROR: invalid FEATURE-ID: ${FEATURE_ID}" >&2
  echo "Use letters, numbers, dots, underscores, and hyphens only." >&2
  exit 2
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_INPUT="${POSITIONAL[1]:-${SCRIPT_DIR}/..}"

if [[ ! -d "${ROOT_INPUT}" ]]; then
  echo "ERROR: workspace root does not exist: ${ROOT_INPUT}" >&2
  exit 2
fi

ROOT="$(cd -- "${ROOT_INPUT}" && pwd -P)"
FEATURES_DIR="${ROOT}/docs/features"
DEST="${FEATURES_DIR}/${FEATURE_ID}"
if [[ "${PROFILE}" == "compact" ]]; then
  TPL="${ROOT}/.codex/templates/feature-compact"
else
  TPL="${ROOT}/.codex/templates/feature"
fi

template_files=(
  "01-requirement.md"
  "02-current-system.md"
  "03-impact-analysis.md"
  "04-solution-design.md"
  "05-implementation-plan.md"
  "06-test-plan.md"
  "07-delivery-checklist.md"
  "08-retrospective.md"
)

for file in "${template_files[@]}"; do
  if [[ ! -s "${TPL}/${file}" ]]; then
    echo "ERROR: required template is missing or empty: ${TPL}/${file}" >&2
    exit 3
  fi
done

if [[ -e "${DEST}" ]]; then
  echo "ERROR: feature already exists: ${DEST}" >&2
  exit 4
fi

mkdir -p -- "${FEATURES_DIR}"
STAGING="$(mktemp -d "${FEATURES_DIR}/.${FEATURE_ID}.tmp.XXXXXX")"

cleanup() {
  if [[ -n "${STAGING:-}" && -d "${STAGING}" ]]; then
    rm -rf -- "${STAGING}"
  fi
}
trap cleanup EXIT

mkdir -p -- "${STAGING}/00-source"
touch "${STAGING}/00-source/.gitkeep"

for file in "${template_files[@]}"; do
  cp -- "${TPL}/${file}" "${STAGING}/${file}"
done

for file in "${template_files[@]}"; do
  sed -i "s/^Feature:[[:space:]]*$/Feature: ${FEATURE_ID}/" \
    "${STAGING}/${file}"
done

mv -- "${STAGING}" "${DEST}"
STAGING=""
trap - EXIT

echo "Created feature workspace:"
echo "  ${DEST}"
echo "  profile: ${PROFILE}"
echo "Next step: place verified source material under ${DEST}/00-source/."
