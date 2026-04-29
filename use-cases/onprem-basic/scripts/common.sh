#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USE_CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
GENERATED_DIR="${USE_CASE_DIR}/generated"
LOG_DIR="${GENERATED_DIR}/logs"
PRODUCTIVE_K3S_REPO="${PRODUCTIVE_K3S_REPO:-$(cd "${USE_CASE_DIR}/../../../productive-k3s" && pwd)}"
PRODUCTIVE_K3S_SOURCE="${PRODUCTIVE_K3S_SOURCE:-local}"
PRODUCTIVE_K3S_VERSION="${PRODUCTIVE_K3S_VERSION:-}"
PRODUCTIVE_K3S_RELEASE_REPO="${PRODUCTIVE_K3S_RELEASE_REPO:-jemacchi/productive-k3s}"
ONPREM_CLUSTER_NAME="${ONPREM_CLUSTER_NAME:-productive-k3s-onprem}"
ONPREM_BASE_DOMAIN="${ONPREM_BASE_DOMAIN:-k3s.lab.internal}"
ONPREM_RANCHER_HOST="${ONPREM_RANCHER_HOST:-rancher.${ONPREM_BASE_DOMAIN}}"
ONPREM_REGISTRY_HOST="${ONPREM_REGISTRY_HOST:-registry.${ONPREM_BASE_DOMAIN}}"
ONPREM_SERVER_IP="${ONPREM_SERVER_IP:-}"
ONPREM_AGENT_IPS="${ONPREM_AGENT_IPS:-}"
ONPREM_SSH_USER="${ONPREM_SSH_USER:-ubuntu}"
ONPREM_SSH_PORT="${ONPREM_SSH_PORT:-22}"
ONPREM_SSH_KEY_PATH="${ONPREM_SSH_KEY_PATH:-}"
ONPREM_SSH_EXTRA_OPTS="${ONPREM_SSH_EXTRA_OPTS:-}"
ONPREM_REMOTE_DIR="${ONPREM_REMOTE_DIR:-}"
CLUSTER_JSON="${GENERATED_DIR}/cluster.json"
HOSTS_YML="${GENERATED_DIR}/hosts.yml"
NODES_ENV="${GENERATED_DIR}/nodes.env"
SERVER_TOKEN_FILE="${GENERATED_DIR}/server-token.txt"
SERVER_URL_FILE="${GENERATED_DIR}/server-url.txt"

SUPPORTED_PLATFORMS=(
  "ubuntu:24.04"
  "ubuntu:22.04"
  "debian:13"
  "debian:12"
)

log() {
  printf '[INFO] %s\n' "$*"
}

warn() {
  printf '[WARN] %s\n' "$*" >&2
}

err() {
  printf '[ERROR] %s\n' "$*" >&2
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    err "required command not found: $1"
    exit 1
  }
}

ensure_base_requirements() {
  need_cmd jq
  need_cmd tar
  need_cmd curl
  need_cmd sha256sum
  need_cmd ssh
  need_cmd scp
  need_cmd python3
}

ensure_logs_dir() {
  mkdir -p "${LOG_DIR}"
}

validate_productive_k3s_source() {
  case "${PRODUCTIVE_K3S_SOURCE}" in
    local|remote) ;;
    *)
      err "PRODUCTIVE_K3S_SOURCE must be 'local' or 'remote', got '${PRODUCTIVE_K3S_SOURCE}'"
      exit 1
      ;;
  esac
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "${value}"
}

parse_agent_ips() {
  local raw
  raw="$(trim "${ONPREM_AGENT_IPS}")"
  AGENT_IPS_ARRAY=()
  if [[ -n "${raw}" ]]; then
    read -r -a AGENT_IPS_ARRAY <<< "${raw}"
  fi
}

require_node_inputs() {
  ONPREM_SERVER_IP="$(trim "${ONPREM_SERVER_IP}")"
  [[ -n "${ONPREM_SERVER_IP}" ]] || {
    err "ONPREM_SERVER_IP is required"
    exit 1
  }
  parse_agent_ips
  local seen="${ONPREM_SERVER_IP}"
  for agent_ip in "${AGENT_IPS_ARRAY[@]}"; do
    [[ -n "${agent_ip}" ]] || continue
    if [[ " ${seen} " == *" ${agent_ip} "* ]]; then
      err "duplicate IP detected in ONPREM_AGENT_IPS: ${agent_ip}"
      exit 1
    fi
    seen+=" ${agent_ip}"
  done
}

ssh_base_args() {
  local args=(
    -o BatchMode=yes
    -o StrictHostKeyChecking=accept-new
    -o ConnectTimeout=10
    -p "${ONPREM_SSH_PORT}"
  )
  if [[ -n "${ONPREM_SSH_KEY_PATH}" ]]; then
    args+=(-i "${ONPREM_SSH_KEY_PATH}")
  fi
  if [[ -n "${ONPREM_SSH_EXTRA_OPTS}" ]]; then
    local extra=()
    read -r -a extra <<< "${ONPREM_SSH_EXTRA_OPTS}"
    args+=("${extra[@]}")
  fi
  printf '%s\0' "${args[@]}"
}

ssh_args_array() {
  local -n __out_ref="$1"
  __out_ref=()
  while IFS= read -r -d '' arg; do
    __out_ref+=("${arg}")
  done < <(ssh_base_args)
}

ssh_target() {
  local ip="$1"
  printf '%s@%s' "${ONPREM_SSH_USER}" "${ip}"
}

remote_exec() {
  local ip="$1"
  local script="$2"
  local ssh_args=()
  ssh_args_array ssh_args
  ssh "${ssh_args[@]}" "$(ssh_target "${ip}")" "bash -lc $(printf '%q' "${script}")"
}

remote_exec_tty() {
  local ip="$1"
  local script="$2"
  local ssh_args=()
  ssh_args_array ssh_args
  ssh -tt "${ssh_args[@]}" "$(ssh_target "${ip}")" "bash -lc $(printf '%q' "${script}")"
}

scp_to() {
  local source="$1"
  local ip="$2"
  local destination="$3"
  local scp_args=(
    -o BatchMode=yes
    -o StrictHostKeyChecking=accept-new
    -o ConnectTimeout=10
    -P "${ONPREM_SSH_PORT}"
  )
  if [[ -n "${ONPREM_SSH_KEY_PATH}" ]]; then
    scp_args+=(-i "${ONPREM_SSH_KEY_PATH}")
  fi
  if [[ -n "${ONPREM_SSH_EXTRA_OPTS}" ]]; then
    local extra=()
    read -r -a extra <<< "${ONPREM_SSH_EXTRA_OPTS}"
    scp_args+=("${extra[@]}")
  fi
  scp "${scp_args[@]}" "${source}" "$(ssh_target "${ip}"):${destination}"
}

is_supported_platform() {
  local platform="$1"
  local candidate
  for candidate in "${SUPPORTED_PLATFORMS[@]}"; do
    [[ "${candidate}" == "${platform}" ]] && return 0
  done
  return 1
}

remote_platform() {
  local ip="$1"
  remote_exec "${ip}" 'source /etc/os-release && printf "%s:%s\n" "${ID}" "${VERSION_ID}"'
}

remote_home_dir() {
  local ip="$1"
  remote_exec "${ip}" 'printf "%s" "$HOME"'
}

productive_k3s_release_api_url() {
  local version="$1"
  if [[ -n "${version}" ]]; then
    printf 'https://api.github.com/repos/%s/releases/tags/%s\n' "${PRODUCTIVE_K3S_RELEASE_REPO}" "${version}"
  else
    printf 'https://api.github.com/repos/%s/releases/latest\n' "${PRODUCTIVE_K3S_RELEASE_REPO}"
  fi
}

resolve_productive_k3s_release_tag() {
  validate_productive_k3s_source
  if [[ "${PRODUCTIVE_K3S_SOURCE}" != "remote" ]]; then
    printf 'local\n'
    return
  fi
  if [[ -n "${PRODUCTIVE_K3S_VERSION}" ]]; then
    printf '%s\n' "${PRODUCTIVE_K3S_VERSION}"
    return
  fi
  curl -fsSL "$(productive_k3s_release_api_url "")" | jq -r '.tag_name'
}

download_productive_k3s_release_bundle() {
  local destination="$1"
  local version="$2"
  local release_json archive_name sha_name archive_url sha_url expected_sha

  release_json="$(curl -fsSL "$(productive_k3s_release_api_url "${version}")")"
  archive_name="productive-k3s-${version}.tar.gz"
  sha_name="${archive_name}.sha256"
  archive_url="$(printf '%s' "${release_json}" | jq -r --arg name "${archive_name}" '.assets[] | select(.name == $name) | .browser_download_url')"
  sha_url="$(printf '%s' "${release_json}" | jq -r --arg name "${sha_name}" '.assets[] | select(.name == $name) | .browser_download_url')"

  [[ -n "${archive_url}" && "${archive_url}" != "null" ]] || {
    err "could not find asset '${archive_name}' in release '${version}' from ${PRODUCTIVE_K3S_RELEASE_REPO}"
    exit 1
  }
  [[ -n "${sha_url}" && "${sha_url}" != "null" ]] || {
    err "could not find asset '${sha_name}' in release '${version}' from ${PRODUCTIVE_K3S_RELEASE_REPO}"
    exit 1
  }

  log "Downloading productive-k3s release ${version} from ${PRODUCTIVE_K3S_RELEASE_REPO}"
  curl -fsSL "${archive_url}" -o "${destination}"
  curl -fsSL "${sha_url}" -o "${destination}.sha256"
  expected_sha="$(cut -d' ' -f1 < "${destination}.sha256")"
  printf '%s  %s\n' "${expected_sha}" "${destination}" | sha256sum -c -
}

load_cluster_metadata() {
  [[ -f "${CLUSTER_JSON}" ]] || {
    err "missing ${CLUSTER_JSON}; run 'make preflight' first"
    exit 1
  }
  SERVER_NAME="$(jq -r '.server.name' "${CLUSTER_JSON}")"
  SERVER_IP="$(jq -r '.server.ipv4' "${CLUSTER_JSON}")"
  SERVER_URL="$(jq -r '.server_url' "${CLUSTER_JSON}")"
  BASE_DOMAIN="$(jq -r '.base_domain' "${CLUSTER_JSON}")"
  RANCHER_HOST="$(jq -r '.rancher_host' "${CLUSTER_JSON}")"
  REGISTRY_HOST="$(jq -r '.registry_host' "${CLUSTER_JSON}")"
  REMOTE_DIR="$(jq -r '.remote_dir' "${CLUSTER_JSON}")"
  PRODUCTIVE_K3S_SOURCE_RESOLVED="$(jq -r '.productive_k3s.source' "${CLUSTER_JSON}")"
  PRODUCTIVE_K3S_VERSION_RESOLVED="$(jq -r '.productive_k3s.version' "${CLUSTER_JSON}")"
  PRODUCTIVE_K3S_RELEASE_REPO_RESOLVED="$(jq -r '.productive_k3s.release_repo' "${CLUSTER_JSON}")"
  SSH_USER_RESOLVED="$(jq -r '.ssh.user' "${CLUSTER_JSON}")"
  SSH_PORT_RESOLVED="$(jq -r '.ssh.port' "${CLUSTER_JSON}")"
  ONPREM_SSH_USER="${SSH_USER_RESOLVED}"
  ONPREM_SSH_PORT="${SSH_PORT_RESOLVED}"
  mapfile -t AGENT_NAMES < <(jq -r '.agents[].name' "${CLUSTER_JSON}")
  mapfile -t AGENT_IPS < <(jq -r '.agents[].ipv4' "${CLUSTER_JSON}")
  mapfile -t ALL_NODE_NAMES < <(jq -r '.nodes[].name' "${CLUSTER_JSON}")
  mapfile -t ALL_NODE_IPS < <(jq -r '.nodes[].ipv4' "${CLUSTER_JSON}")
}

write_hosts_entry_on_node() {
  local node_ip="$1"
  local server_ip="$2"
  local rancher_host="$3"
  local registry_host="$4"
  local escaped_line
  escaped_line="${server_ip} ${rancher_host} ${registry_host}"
  remote_exec "${node_ip}" "
    set -euo pipefail
    if grep -qE '[[:space:]]${rancher_host}([[:space:]]|\$)' /etc/hosts 2>/dev/null; then
      sudo sed -i '/[[:space:]]${rancher_host}\([[:space:]]\|\$\)/d' /etc/hosts
    fi
    if grep -qE '[[:space:]]${registry_host}([[:space:]]|\$)' /etc/hosts 2>/dev/null; then
      sudo sed -i '/[[:space:]]${registry_host}\([[:space:]]\|\$\)/d' /etc/hosts
    fi
    printf '%s\n' '${escaped_line}' | sudo tee -a /etc/hosts >/dev/null
  "
}
