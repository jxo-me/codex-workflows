#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  codex-workflow-init.sh [--dry-run] [--upgrade | --force] [WORKSPACE_ROOT]

Options:
  --dry-run  Validate and report the installation without writing files.
  --upgrade  Upgrade files that still match the previous install manifest.
  --force    Replace conflicting regular files without a manifest safety check.
  -h, --help Show this help text.

By default, existing files with different content are treated as conflicts and
nothing is installed. Run this script from a complete codex-workflow checkout.
The source checkout cannot also be the target workspace.
EOF
}

DRY_RUN=0
FORCE=0
UPGRADE=0
TARGET_INPUT=""

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --upgrade) UPGRADE=1 ;;
    --force) FORCE=1 ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "ERROR: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [[ -n "${TARGET_INPUT}" ]]; then
        echo "ERROR: only one WORKSPACE_ROOT may be provided." >&2
        usage >&2
        exit 2
      fi
      TARGET_INPUT="$1"
      ;;
  esac
  shift
done

if [[ "$#" -gt 0 ]]; then
  if [[ -n "${TARGET_INPUT}" || "$#" -gt 1 ]]; then
    echo "ERROR: only one WORKSPACE_ROOT may be provided." >&2
    usage >&2
    exit 2
  fi
  TARGET_INPUT="$1"
fi

if [[ "${UPGRADE}" -eq 1 && "${FORCE}" -eq 1 ]]; then
  echo "ERROR: --upgrade and --force are mutually exclusive." >&2
  exit 2
fi

TARGET_INPUT="${TARGET_INPUT:-$(pwd)}"

for command_name in realpath sha256sum; do
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "ERROR: ${command_name} is required." >&2
    exit 2
  fi
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SOURCE_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
TARGET_ROOT="$(realpath -m -- "${TARGET_INPUT}")"

if [[ "${TARGET_ROOT}" == "/" ]]; then
  echo "ERROR: refusing to install into the filesystem root." >&2
  exit 2
fi

if [[ "${TARGET_ROOT}" == "${SOURCE_ROOT}" ]]; then
  echo "ERROR: the workflow source checkout cannot be its own target workspace." >&2
  exit 2
fi

required_source_paths=(
  "VERSION"
  "AGENTS.md"
  "README-AI-WORKFLOW.md"
  "skeleton/ARCHITECTURE.md"
  "skeleton/workspace-status.md"
  ".codex/prompts"
  ".codex/templates"
  ".agents/skills"
  "docs/architecture"
  "docs/domain"
  "docs/standards"
  "docs/adr"
  "docs/features/README.md"
  "docs/runbooks"
  "scripts/feature-init.sh"
  "scripts/verify-workspace.sh"
)

for relative_path in "${required_source_paths[@]}"; do
  if [[ ! -e "${SOURCE_ROOT}/${relative_path}" ]]; then
    echo "ERROR: installer asset is missing: ${SOURCE_ROOT}/${relative_path}" >&2
    echo "Run this script from a complete codex-workflow checkout." >&2
    exit 3
  fi
done

WORKFLOW_VERSION="$(tr -d '[:space:]' <"${SOURCE_ROOT}/VERSION")"
SEMVER_PATTERN='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'
if [[ ! "${WORKFLOW_VERSION}" =~ ${SEMVER_PATTERN} ]]; then
  echo "ERROR: VERSION is not a supported semantic version: ${WORKFLOW_VERSION}" >&2
  exit 3
fi

version_is_greater() {
  local candidate="$1"
  local baseline="$2"
  local -a candidate_parts baseline_parts
  local index

  IFS='.' read -r -a candidate_parts <<<"${candidate}"
  IFS='.' read -r -a baseline_parts <<<"${baseline}"
  for index in 0 1 2; do
    if ((10#${candidate_parts[$index]} > 10#${baseline_parts[$index]})); then
      return 0
    fi
    if ((10#${candidate_parts[$index]} < 10#${baseline_parts[$index]})); then
      return 1
    fi
  done
  return 1
}

manifest_path_is_safe() {
  local relative_path="$1"
  [[ -n "${relative_path}" &&
    "${relative_path}" != "." &&
    "${relative_path}" != /* &&
    "${relative_path}" != ./* &&
    "${relative_path}" != ".." &&
    "${relative_path}" != ../* &&
    "${relative_path}" != */./* &&
    "${relative_path}" != */. &&
    "${relative_path}" != */../* &&
    "${relative_path}" != */.. &&
    "${relative_path}" != *//* ]]
}

asset_sources=()
asset_targets=()
declare -A current_asset_targets=()

add_asset() {
  asset_sources+=("$1")
  asset_targets+=("$2")
  current_asset_targets["$2"]=1
}

add_asset "AGENTS.md" "AGENTS.md"
add_asset "README-AI-WORKFLOW.md" "README-AI-WORKFLOW.md"
add_asset "skeleton/ARCHITECTURE.md" "ARCHITECTURE.md"
add_asset "skeleton/workspace-status.md" ".codex/workspace-status.md"
add_asset "docs/features/README.md" "docs/features/README.md"
add_asset "docs/generated/.gitkeep" "docs/generated/.gitkeep"
add_asset "scripts/codex-workflow-init.sh" "scripts/codex-workflow-init.sh"
add_asset "scripts/feature-init.sh" "scripts/feature-init.sh"
add_asset "scripts/verify-workspace.sh" "scripts/verify-workspace.sh"

asset_directories=(
  ".codex/prompts"
  ".codex/templates"
  ".agents/skills"
  "docs/architecture"
  "docs/domain"
  "docs/standards"
  "docs/adr"
  "docs/runbooks"
)

for relative_dir in "${asset_directories[@]}"; do
  while IFS= read -r -d '' source_file; do
    relative_path="${source_file#"${SOURCE_ROOT}/"}"
    add_asset "${relative_path}" "${relative_path}"
  done < <(find "${SOURCE_ROOT}/${relative_dir}" -type f -print0 | sort -z)
done

MANIFEST_RELATIVE_PATH=".codex/workflow-install.manifest"
MANIFEST_PATH="${TARGET_ROOT}/${MANIFEST_RELATIVE_PATH}"
MANIFEST_RESOLVED_PATH="$(realpath -m -- "${MANIFEST_PATH}")"
declare -A previous_checksums=()
PREVIOUS_VERSION="UNKNOWN"
MANIFEST_FORMAT=""
MANIFEST_VERSION_RECORDS=0
MANIFEST_CHECKSUM_RECORDS=0
MANIFEST_RETIRED_RECORDS=0

if [[ "${MANIFEST_RESOLVED_PATH}" != "${TARGET_ROOT}/"* ]]; then
  echo "ERROR: install manifest resolves outside the target workspace: ${MANIFEST_PATH}" >&2
  exit 4
fi

if [[ -L "${MANIFEST_PATH}" || ( -e "${MANIFEST_PATH}" && ! -f "${MANIFEST_PATH}" ) ]]; then
  echo "ERROR: install manifest target is not a regular file: ${MANIFEST_PATH}" >&2
  exit 4
fi

if [[ "${UPGRADE}" -eq 1 && ! -f "${MANIFEST_PATH}" ]]; then
  echo "ERROR: --upgrade requires a previous install manifest: ${MANIFEST_PATH}" >&2
  exit 5
fi

if [[ -f "${MANIFEST_PATH}" ]]; then
  while IFS=$'\t' read -r record first second; do
    case "${record}" in
      format)
        if [[ -n "${MANIFEST_FORMAT}" || ( "${first}" != "1" && "${first}" != "2" ) ]]; then
          echo "ERROR: unsupported install manifest format: ${first}" >&2
          exit 5
        fi
        MANIFEST_FORMAT="${first}"
        ;;
      version)
        MANIFEST_VERSION_RECORDS=$((MANIFEST_VERSION_RECORDS + 1))
        PREVIOUS_VERSION="${first}"
        ;;
      sha256|retired)
        if [[ "${first}" =~ ^[[:xdigit:]]{64}$ ]] &&
          manifest_path_is_safe "${second}" &&
          [[ -z "${previous_checksums[${second}]+present}" ]]; then
          previous_checksums["${second}"]="${first,,}"
          MANIFEST_CHECKSUM_RECORDS=$((MANIFEST_CHECKSUM_RECORDS + 1))
          if [[ "${record}" == "retired" ]]; then
            MANIFEST_RETIRED_RECORDS=$((MANIFEST_RETIRED_RECORDS + 1))
          fi
        else
          echo "ERROR: invalid or duplicate checksum record in install manifest." >&2
          exit 5
        fi
        ;;
      "") ;;
      *)
        echo "ERROR: invalid record in install manifest: ${record}" >&2
        exit 5
        ;;
    esac
  done <"${MANIFEST_PATH}"

  if [[ -z "${MANIFEST_FORMAT}" || "${MANIFEST_VERSION_RECORDS}" -ne 1 ||
    "${MANIFEST_CHECKSUM_RECORDS}" -eq 0 || ! "${PREVIOUS_VERSION}" =~ ${SEMVER_PATTERN} ]]; then
    echo "ERROR: install manifest is incomplete or has an invalid version." >&2
    exit 5
  fi
  if [[ "${MANIFEST_FORMAT}" == "1" && "${MANIFEST_RETIRED_RECORDS}" -ne 0 ]]; then
    echo "ERROR: install manifest format 1 cannot contain retired records." >&2
    exit 5
  fi
fi

if [[ "${UPGRADE}" -eq 1 ]] && ! version_is_greater "${WORKFLOW_VERSION}" "${PREVIOUS_VERSION}"; then
  echo "ERROR: upgrade version must be greater than ${PREVIOUS_VERSION}: ${WORKFLOW_VERSION}" >&2
  exit 5
fi

conflicts=()
blocking_conflicts=()
retired_paths=()
upgradable=0

for index in "${!asset_targets[@]}"; do
  source_relative_path="${asset_sources[$index]}"
  target_relative_path="${asset_targets[$index]}"
  source_path="${SOURCE_ROOT}/${source_relative_path}"
  target_path="${TARGET_ROOT}/${target_relative_path}"
  resolved_target_path="$(realpath -m -- "${target_path}")"

  if [[ ! -f "${source_path}" ]]; then
    echo "ERROR: installer asset is not a regular file: ${source_path}" >&2
    exit 3
  fi

  if [[ "${resolved_target_path}" != "${TARGET_ROOT}/"* ]]; then
    blocking_conflicts+=("${target_relative_path} (resolves outside target workspace)")
  elif [[ -L "${target_path}" ]]; then
    blocking_conflicts+=("${target_relative_path} (target is a symbolic link)")
  elif [[ -e "${target_path}" && ! -f "${target_path}" ]]; then
    blocking_conflicts+=("${target_relative_path} (target is not a regular file)")
  elif [[ -f "${target_path}" ]] && ! cmp -s -- "${source_path}" "${target_path}"; then
    if [[ "${FORCE}" -eq 1 ]]; then
      continue
    fi

    if [[ "${UPGRADE}" -eq 1 && -n "${previous_checksums[${target_relative_path}]:-}" ]]; then
      current_checksum="$(sha256sum -- "${target_path}")"
      current_checksum="${current_checksum%% *}"
      if [[ "${current_checksum}" == "${previous_checksums[${target_relative_path}]}" ]]; then
        upgradable=$((upgradable + 1))
        continue
      fi
    fi

    conflicts+=("${target_relative_path}")
  fi
done

for previous_path in "${!previous_checksums[@]}"; do
  if [[ -z "${current_asset_targets[${previous_path}]:-}" &&
    ( -e "${TARGET_ROOT}/${previous_path}" || -L "${TARGET_ROOT}/${previous_path}" ) ]]; then
    retired_paths+=("${previous_path}")
  fi
done

if [[ "${#retired_paths[@]}" -gt 0 ]]; then
  mapfile -d '' -t retired_paths < <(printf '%s\0' "${retired_paths[@]}" | sort -z)
fi

if [[ "${#blocking_conflicts[@]}" -gt 0 ]]; then
  echo "ERROR: installation cannot replace non-file targets:" >&2
  for relative_path in "${blocking_conflicts[@]}"; do
    echo "  ${relative_path}" >&2
  done
  echo "No files were changed." >&2
  exit 4
fi

if [[ "${#conflicts[@]}" -gt 0 ]]; then
  echo "ERROR: installation would replace unmanaged or locally modified files:" >&2
  for relative_path in "${conflicts[@]}"; do
    echo "  ${relative_path}" >&2
  done
  if [[ "${UPGRADE}" -eq 1 ]]; then
    echo "No files were changed. Preserve or reconcile local changes before upgrading." >&2
  else
    echo "No files were changed. Review the conflicts, use --upgrade, or explicitly use --force." >&2
  fi
  exit 4
fi

echo "Codex workflow installation"
echo "  version: ${WORKFLOW_VERSION}"
echo "  source:  ${SOURCE_ROOT}"
echo "  target:  ${TARGET_ROOT}"
if [[ "${UPGRADE}" -eq 1 ]]; then
  echo "  upgrade: ${PREVIOUS_VERSION} -> ${WORKFLOW_VERSION} (${upgradable} changed assets)"
fi
if [[ "${#retired_paths[@]}" -gt 0 ]]; then
  echo "  retired: ${#retired_paths[@]} preserved assets (not present in this release)"
fi

if [[ "${DRY_RUN}" -eq 1 ]]; then
  echo "  mode:    dry-run"
  echo "Validated ${#asset_targets[@]} workflow assets. No files were changed."
  exit 0
fi

mkdir -p -- "${TARGET_ROOT}/.codex"

installed=0
unchanged=0
for index in "${!asset_targets[@]}"; do
  source_relative_path="${asset_sources[$index]}"
  target_relative_path="${asset_targets[$index]}"
  source_path="${SOURCE_ROOT}/${source_relative_path}"
  target_path="${TARGET_ROOT}/${target_relative_path}"

  if [[ -f "${target_path}" ]] && cmp -s -- "${source_path}" "${target_path}"; then
    unchanged=$((unchanged + 1))
    continue
  fi

  mkdir -p -- "$(dirname -- "${target_path}")"
  cp -- "${source_path}" "${target_path}"
  case "${target_relative_path}" in
    scripts/*.sh) chmod 0755 -- "${target_path}" ;;
    *) chmod 0644 -- "${target_path}" ;;
  esac
  installed=$((installed + 1))
done

manifest_temp="$(mktemp "${TARGET_ROOT}/.codex/.workflow-install.manifest.tmp.XXXXXX")"
cleanup_manifest() {
  if [[ -n "${manifest_temp:-}" && -f "${manifest_temp}" ]]; then
    rm -f -- "${manifest_temp}"
  fi
}
trap cleanup_manifest EXIT

{
  printf 'format\t2\n'
  printf 'version\t%s\n' "${WORKFLOW_VERSION}"
  for target_relative_path in "${asset_targets[@]}"; do
    target_checksum="$(sha256sum -- "${TARGET_ROOT}/${target_relative_path}")"
    target_checksum="${target_checksum%% *}"
    printf 'sha256\t%s\t%s\n' "${target_checksum}" "${target_relative_path}"
  done
  for retired_path in "${retired_paths[@]}"; do
    printf 'retired\t%s\t%s\n' "${previous_checksums[${retired_path}]}" "${retired_path}"
  done
} >"${manifest_temp}"
chmod 0644 -- "${manifest_temp}"
mv -- "${manifest_temp}" "${MANIFEST_PATH}"
manifest_temp=""
trap - EXIT

echo "Installation completed: ${installed} installed, ${unchanged} unchanged."
echo "Manifest: ${MANIFEST_PATH}"
echo "Next step: run .codex/prompts/00-bootstrap.md with Codex."
