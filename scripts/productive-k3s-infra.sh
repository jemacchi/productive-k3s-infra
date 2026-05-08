#!/usr/bin/env bash
set -euo pipefail

REQUESTED_PRODUCTIVE_K3S_VERSION="${PRODUCTIVE_K3S_VERSION-}"
REQUESTED_PRODUCTIVE_K3S_SOURCE="${PRODUCTIVE_K3S_SOURCE-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RELEASE_ENV_FILE="${SCRIPT_DIR}/release.env"
if [[ -f "${RELEASE_ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${RELEASE_ENV_FILE}"
  set +a
fi
REPO_DIR="${PRODUCTIVE_K3S_INFRA_REPO_DIR:-$(cd "${SCRIPT_DIR}/.." && pwd)}"
MAKE_BIN="${PRODUCTIVE_K3S_INFRA_MAKE_BIN:-make}"
TOFU_BIN="${PRODUCTIVE_K3S_INFRA_TOFU_BIN:-}"
VERSION="${PRODUCTIVE_K3S_INFRA_VERSION:-${PK3S_INFRA_RELEASE_TAG:-dev}}"
PROFILES_DIR="${REPO_DIR}/profiles"

PROFILE_PATH=""
GLOBAL_DEBUG=0
GLOBAL_YES=0
GLOBAL_DRY_RUN=0
GLOBAL_JSON=0

usage() {
  cat <<'EOF'
Usage:
  ./productive-k3s-infra.sh <command> --profile <file> [flags]
  ./productive-k3s-infra.sh <scenario> [command] [make-args...]

Profile-driven commands:
  help
  version
  bundle info --json
  doctor
  list-profiles
  validate --profile <file>
  plan --profile <file>
  apply --profile <file>
  destroy --profile <file>
  status --profile <file>

Legacy compatibility:
  multipass [command]
  onprem | onprem-basic [command]
  aws-single-node [command]

Supported global flags:
  --profile <file>
  --debug
  --yes
  --dry-run
  --json
EOF
}

log() {
  local level="$1"
  shift
  printf '[pk3s-infra] %-5s %s\n' "${level}" "$*"
}

die() {
  local code="$1"
  shift
  log "ERROR" "$*" >&2
  exit "${code}"
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die 5 "missing dependency: $1"
}

enforce_release_bound_productive_k3s_version() {
  local bound_version="${PK3S_CORE_SEMVER:-}"
  if [[ -z "${bound_version}" ]]; then
    return 0
  fi

  if [[ -n "${REQUESTED_PRODUCTIVE_K3S_VERSION:-}" && "${REQUESTED_PRODUCTIVE_K3S_VERSION}" != "${bound_version}" ]]; then
    die 4 "release ${VERSION} is bound to productive-k3s ${bound_version}; refusing requested PRODUCTIVE_K3S_VERSION=${REQUESTED_PRODUCTIVE_K3S_VERSION}"
  fi

  export PRODUCTIVE_K3S_VERSION="${bound_version}"
  if [[ -n "${REQUESTED_PRODUCTIVE_K3S_SOURCE:-}" && "${REQUESTED_PRODUCTIVE_K3S_SOURCE}" != "remote" ]]; then
    die 4 "release ${VERSION} requires PRODUCTIVE_K3S_SOURCE=remote; refusing requested PRODUCTIVE_K3S_SOURCE=${REQUESTED_PRODUCTIVE_K3S_SOURCE}"
  fi
  export PRODUCTIVE_K3S_SOURCE="remote"
}

resolve_tofu_bin() {
  if [[ -n "${TOFU_BIN}" ]]; then
    printf '%s\n' "${TOFU_BIN}"
    return 0
  fi
  if command -v tofu >/dev/null 2>&1; then
    printf 'tofu\n'
    return 0
  fi
  if command -v terraform >/dev/null 2>&1; then
    printf 'terraform\n'
    return 0
  fi
  return 1
}

render_bundle_info_json() {
  local bundle_version="${PK3S_INFRA_RELEASE_TAG:-${VERSION:-}}"
  [[ -n "${bundle_version}" ]] || {
    printf 'could not resolve bundle version\n' >&2
    exit 1
  }

  cat <<EOF
{
  "schema_version": "1",
  "bundle_name": "productive-k3s-infra",
  "bundle_type": "productive-k3s-infra",
  "bundle_version": "${bundle_version}",
  "cli_entrypoint": "productive-k3s-infra.sh",
  "platform": "any",
  "api_compatibility": {
    "contract": "productive-k3s-cli-bundle-info/v1"
  }
}
EOF
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "${value}"
}

resolve_scenario() {
  case "$1" in
    multipass)
      printf 'multipass\n'
      ;;
    onprem|onprem-basic|on-prem)
      printf 'onprem-basic\n'
      ;;
    aws-single-node)
      printf 'aws-single-node\n'
      ;;
    *)
      return 1
      ;;
  esac
}

profile_env_var_name() {
  case "$1" in
    onprem-basic)
      printf 'ONPREM_ENV_FILE\n'
      ;;
    aws-single-node)
      printf 'AWS_ENV_FILE\n'
      ;;
    *)
      printf '\n'
      ;;
  esac
}

command_to_target() {
  local command="$1"
  local scenario="$2"
  case "$command" in
    validate)
      printf 'validate\n'
      ;;
    apply)
      printf 'up\n'
      ;;
    plan)
      printf 'up\n'
      ;;
    destroy)
      case "$scenario" in
        multipass|aws-single-node)
          printf 'down\n'
          ;;
        onprem-basic)
          return 1
          ;;
      esac
      ;;
    status)
      printf 'status\n'
      ;;
    *)
      return 1
      ;;
  esac
}

source_profile() {
  local profile="$1"
  [[ -f "${profile}" ]] || die 3 "profile not found: ${profile}"
  set -a
  # shellcheck disable=SC1090
  source "${profile}"
  set +a
}

require_env() {
  local name="$1"
  local value="${!name:-}"
  [[ -n "$(trim "${value}")" ]] || die 4 "profile is missing required variable: ${name}"
}

validate_profile() {
  require_env PK3S_INFRA_PROFILE_NAME
  require_env PK3S_INFRA_ENGINE

  if [[ -z "$(trim "${PK3S_INFRA_SCENARIO:-}")" ]]; then
    die 4 "profile is missing required variable: PK3S_INFRA_SCENARIO"
  fi

  require_env PK3S_INFRA_SCENARIO

  PK3S_INFRA_SCENARIO="$(resolve_scenario "${PK3S_INFRA_SCENARIO}")" || die 4 "unsupported PK3S_INFRA_SCENARIO: ${PK3S_INFRA_SCENARIO}"
  export PK3S_INFRA_SCENARIO

  case "${PK3S_INFRA_ENGINE}" in
    opentofu|ansible|shell) ;;
    *)
      die 4 "unsupported PK3S_INFRA_ENGINE: ${PK3S_INFRA_ENGINE}"
      ;;
  esac

  case "${PK3S_INFRA_SCENARIO}" in
    multipass)
      if [[ "${PK3S_INFRA_ENGINE}" != "opentofu" ]]; then
        die 4 "multipass profiles must use PK3S_INFRA_ENGINE=opentofu"
      fi
      require_env TF_VAR_cluster_name
      require_env TF_VAR_image
      require_env TF_VAR_base_domain
      require_env TF_VAR_remote_dir
      require_env TF_VAR_server_cpus
      require_env TF_VAR_server_memory
      require_env TF_VAR_server_disk
      require_env TF_VAR_agent_cpus
      require_env TF_VAR_agent_memory
      require_env TF_VAR_agent_disk
      ;;
    onprem-basic)
      if [[ "${PK3S_INFRA_ENGINE}" != "ansible" && "${PK3S_INFRA_ENGINE}" != "shell" ]]; then
        die 4 "onprem-basic profiles must use PK3S_INFRA_ENGINE=ansible or shell"
      fi
      require_env ONPREM_SERVER_IP
      require_env ONPREM_SSH_USER
      if [[ -z "$(trim "${ONPREM_SSH_KEY_PATH:-${ONPREM_SSH_PRIVATE_KEY_PATH:-}}")" ]]; then
        die 4 "profile is missing required variable: ONPREM_SSH_KEY_PATH"
      fi
      ;;
    aws-single-node)
      if [[ "${PK3S_INFRA_ENGINE}" != "opentofu" ]]; then
        die 4 "aws-single-node profiles must use PK3S_INFRA_ENGINE=opentofu"
      fi
      require_env AWS_REGION
      require_env AWS_CLUSTER_NAME
      require_env AWS_INSTANCE_TYPE
      require_env AWS_SSH_USER
      require_env AWS_SSH_KEY_PATH
      require_env AWS_ROOT_VOLUME_SIZE_GB
      ;;
  esac
}

run_opentofu_plan() {
  local scenario_dir="$1"
  local opentofu_dir="${scenario_dir}/opentofu"
  local resolved_tofu

  [[ -d "${opentofu_dir}" ]] || die 1 "opentofu directory not found: ${opentofu_dir}"
  resolved_tofu="$(resolve_tofu_bin)" || die 5 "missing dependency: tofu or terraform"
  log "INFO" "Running OpenTofu plan in ${opentofu_dir}"
  "${resolved_tofu}" -chdir="${opentofu_dir}" init -backend=false
  exec "${resolved_tofu}" -chdir="${opentofu_dir}" plan
}

run_profile_doctor() {
  local profile="$1"
  enforce_release_bound_productive_k3s_version
  source_profile "${profile}"
  enforce_release_bound_productive_k3s_version
  validate_profile
  log "OK" "Profile file is readable: ${profile}"
  log "OK" "Profile scenario: ${PK3S_INFRA_SCENARIO}"
  log "OK" "Profile engine: ${PK3S_INFRA_ENGINE}"
  case "${PK3S_INFRA_ENGINE}" in
    opentofu)
      resolve_tofu_bin >/dev/null || die 5 "missing dependency: tofu or terraform"
      log "OK" "OpenTofu-compatible binary is available"
      ;;
    ansible|shell)
      need_cmd ssh
      log "OK" "ssh is available for remote-oriented profile validation"
      ;;
  esac
}

profile_command_dispatch() {
  local command="$1"
  local profile="$2"
  local target env_file_var scenario_dir

  enforce_release_bound_productive_k3s_version
  source_profile "${profile}"
  enforce_release_bound_productive_k3s_version
  validate_profile

  target="$(command_to_target "${command}" "${PK3S_INFRA_SCENARIO}")" || die 2 "unsupported command '${command}' for scenario '${PK3S_INFRA_SCENARIO}'"
  scenario_dir="${REPO_DIR}/scenarios/${PK3S_INFRA_SCENARIO}"
  [[ -d "${scenario_dir}" ]] || die 1 "scenario directory not found: ${scenario_dir}"

  log "INFO" "Loading profile: ${profile}"
  log "INFO" "Scenario: ${PK3S_INFRA_SCENARIO}"
  log "INFO" "Engine: ${PK3S_INFRA_ENGINE}"
  log "OK" "Profile validation passed"

  if [[ "${command}" == "apply" && "${GLOBAL_DRY_RUN}" -eq 1 ]]; then
    log "INFO" "Dry-run requested; switching apply to plan"
    command="plan"
  fi

  if [[ "${command}" == "plan" ]]; then
    case "${PK3S_INFRA_ENGINE}" in
      opentofu)
        run_opentofu_plan "${scenario_dir}"
        ;;
      ansible|shell)
        log "INFO" "Plan mode delegates to 'make -n' for the current remote backend contract"
        env_file_var="$(profile_env_var_name "${PK3S_INFRA_SCENARIO}")"
        if [[ -n "${env_file_var}" ]]; then
          exec env "${env_file_var}=${profile}" "${MAKE_BIN}" -n -C "${scenario_dir}" "${target}"
        fi
        exec "${MAKE_BIN}" -n -C "${scenario_dir}" "${target}"
        ;;
    esac
  fi

  if [[ "${command}" == "destroy" && "${PK3S_INFRA_SCENARIO}" == "onprem-basic" && "${GLOBAL_YES}" -ne 1 ]]; then
    die 2 "destroy is not supported for onprem-basic in the stage-1 profile contract"
  fi

  env_file_var="$(profile_env_var_name "${PK3S_INFRA_SCENARIO}")"
  if [[ -n "${env_file_var}" ]]; then
    exec env "${env_file_var}=${profile}" "${MAKE_BIN}" -C "${scenario_dir}" "${target}"
  fi
  exec "${MAKE_BIN}" -C "${scenario_dir}" "${target}"
}

legacy_dispatch() {
  local scenario command
  enforce_release_bound_productive_k3s_version
  scenario="$(resolve_scenario "$1")" || die 2 "unsupported scenario: $1"
  shift

  command="${1:-up}"
  if (($# > 0)); then
    shift
  fi

  local scenario_dir="${REPO_DIR}/scenarios/${scenario}"
  [[ -d "${scenario_dir}" ]] || die 1 "scenario directory not found: ${scenario_dir}"

  exec "${MAKE_BIN}" -C "${scenario_dir}" "${command}" "$@"
}

run_doctor() {
  need_cmd bash
  need_cmd "${MAKE_BIN}"
  enforce_release_bound_productive_k3s_version
  log "OK" "bash is available"
  log "OK" "${MAKE_BIN} is available"
  if [[ -d "${PROFILES_DIR}" ]]; then
    log "OK" "profiles directory found: ${PROFILES_DIR}"
  else
    log "WARN" "profiles directory not found yet: ${PROFILES_DIR}"
  fi
  if [[ -n "${PROFILE_PATH}" ]]; then
    run_profile_doctor "${PROFILE_PATH}"
  fi
}

run_list_profiles() {
  if [[ ! -d "${PROFILES_DIR}" ]]; then
    die 3 "profiles directory not found: ${PROFILES_DIR}"
  fi

  find "${PROFILES_DIR}" -type f -name '*.env' | sort | while read -r profile; do
    printf '%s\n' "${profile#${REPO_DIR}/}"
  done
}

if (($# == 0)); then
  usage >&2
  exit 2
fi

PARSED_ARGS=()
while (($# > 0)); do
  case "$1" in
    --profile)
      [[ $# -ge 2 ]] || die 2 "--profile requires a value"
      PROFILE_PATH="$2"
      shift 2
      ;;
    --debug)
      GLOBAL_DEBUG=1
      shift
      ;;
    --yes)
      GLOBAL_YES=1
      shift
      ;;
    --dry-run)
      GLOBAL_DRY_RUN=1
      shift
      ;;
    --json)
      GLOBAL_JSON=1
      shift
      ;;
    *)
      PARSED_ARGS+=("$1")
      shift
      ;;
  esac
done
set -- "${PARSED_ARGS[@]}"

if [[ "${GLOBAL_DEBUG}" -eq 1 ]]; then
  set -x
fi

COMMAND="${1:-help}"
case "${COMMAND}" in
  -h|--help|help)
    usage
    ;;
  version)
    if [[ "${GLOBAL_JSON}" -eq 1 ]]; then
      render_bundle_info_json
      exit 0
    fi
    printf '%s\n' "${VERSION}"
    ;;
  bundle)
    [[ "${2:-}" == "info" ]] || die 2 "unsupported bundle command: ${2:-}"
    [[ "${GLOBAL_JSON}" -eq 1 ]] || die 2 "bundle info requires --json"
    render_bundle_info_json
    ;;
  doctor)
    run_doctor
    ;;
  list-profiles)
    run_list_profiles
    ;;
  validate|plan|apply|destroy|status)
    [[ -n "${PROFILE_PATH}" ]] || die 3 "the '${COMMAND}' command requires --profile <file>"
    profile_command_dispatch "${COMMAND}" "${PROFILE_PATH}"
    ;;
  multipass|onprem|onprem-basic|on-prem|aws-single-node)
    legacy_dispatch "$@"
    ;;
  *)
    die 2 "unsupported command: ${COMMAND}"
    ;;
esac
