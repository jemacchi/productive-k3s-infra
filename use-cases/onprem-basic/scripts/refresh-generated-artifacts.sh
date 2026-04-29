#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

ensure_base_requirements
validate_productive_k3s_source

mkdir -p "${GENERATED_DIR}"

if [[ -z "${ONPREM_SERVER_IP}" && -f "${CLUSTER_JSON}" ]]; then
  ONPREM_SERVER_IP="$(jq -r '.server.ipv4 // empty' "${CLUSTER_JSON}")"
  ONPREM_AGENT_IPS="$(jq -r '.agents[].ipv4' "${CLUSTER_JSON}" | tr '\n' ' ')"
  ONPREM_CLUSTER_NAME="${ONPREM_CLUSTER_NAME:-$(jq -r '.cluster_name // empty' "${CLUSTER_JSON}")}"
  ONPREM_BASE_DOMAIN="${ONPREM_BASE_DOMAIN:-$(jq -r '.base_domain // empty' "${CLUSTER_JSON}")}"
  ONPREM_RANCHER_HOST="${ONPREM_RANCHER_HOST:-$(jq -r '.rancher_host // empty' "${CLUSTER_JSON}")}"
  ONPREM_REGISTRY_HOST="${ONPREM_REGISTRY_HOST:-$(jq -r '.registry_host // empty' "${CLUSTER_JSON}")}"
  if [[ -z "${PRODUCTIVE_K3S_VERSION}" ]]; then
    PRODUCTIVE_K3S_VERSION="$(jq -r '.productive_k3s.version // empty' "${CLUSTER_JSON}")"
  fi
  PRODUCTIVE_K3S_SOURCE="${PRODUCTIVE_K3S_SOURCE:-$(jq -r '.productive_k3s.source // empty' "${CLUSTER_JSON}")}"
  PRODUCTIVE_K3S_RELEASE_REPO="${PRODUCTIVE_K3S_RELEASE_REPO:-$(jq -r '.productive_k3s.release_repo // empty' "${CLUSTER_JSON}")}"
fi

require_node_inputs

resolved_source="${PRODUCTIVE_K3S_SOURCE}"
resolved_version="${PRODUCTIVE_K3S_VERSION}"
if [[ "${resolved_source}" == "remote" && -z "${resolved_version}" ]]; then
  resolved_version="$(resolve_productive_k3s_release_tag)"
fi

if [[ -z "${ONPREM_REMOTE_DIR}" ]]; then
  remote_home="$(remote_home_dir "${ONPREM_SERVER_IP}")"
  ONPREM_REMOTE_DIR="${remote_home}/productive-k3s"
fi

all_node_ips=("${ONPREM_SERVER_IP}" "${AGENT_IPS_ARRAY[@]}")
all_node_names=("server")
for i in "${!AGENT_IPS_ARRAY[@]}"; do
  all_node_names+=("agent-$((i + 1))")
done

tmp_json="$(mktemp)"
{
  printf '{\n'
  printf '  "cluster_name": %s,\n' "$(jq -Rn --arg v "${ONPREM_CLUSTER_NAME}" '$v')"
  printf '  "base_domain": %s,\n' "$(jq -Rn --arg v "${ONPREM_BASE_DOMAIN}" '$v')"
  printf '  "remote_dir": %s,\n' "$(jq -Rn --arg v "${ONPREM_REMOTE_DIR}" '$v')"
  printf '  "ssh": {\n'
  printf '    "user": %s,\n' "$(jq -Rn --arg v "${ONPREM_SSH_USER}" '$v')"
  printf '    "port": %s,\n' "$(jq -n --argjson v "${ONPREM_SSH_PORT}" '$v')"
  printf '    "key_path": %s\n' "$(jq -Rn --arg v "${ONPREM_SSH_KEY_PATH}" '$v')"
  printf '  },\n'
  printf '  "productive_k3s": {\n'
  printf '    "source": %s,\n' "$(jq -Rn --arg v "${resolved_source}" '$v')"
  printf '    "version": %s,\n' "$(jq -Rn --arg v "${resolved_version}" '$v')"
  printf '    "release_repo": %s\n' "$(jq -Rn --arg v "${PRODUCTIVE_K3S_RELEASE_REPO}" '$v')"
  printf '  },\n'
  printf '  "server_url": %s,\n' "$(jq -Rn --arg v "https://${ONPREM_SERVER_IP}:6443" '$v')"
  printf '  "rancher_host": %s,\n' "$(jq -Rn --arg v "${ONPREM_RANCHER_HOST}" '$v')"
  printf '  "registry_host": %s,\n' "$(jq -Rn --arg v "${ONPREM_REGISTRY_HOST}" '$v')"
  printf '  "server": {\n'
  printf '    "name": "server",\n'
  printf '    "ipv4": %s\n' "$(jq -Rn --arg v "${ONPREM_SERVER_IP}" '$v')"
  printf '  },\n'
  printf '  "agents": [\n'
  for i in "${!AGENT_IPS_ARRAY[@]}"; do
    agent_ip="${AGENT_IPS_ARRAY[$i]}"
    printf '    {"name": %s, "ipv4": %s}' \
      "$(jq -Rn --arg v "agent-$((i + 1))" '$v')" \
      "$(jq -Rn --arg v "${agent_ip}" '$v')"
    if (( i + 1 < ${#AGENT_IPS_ARRAY[@]} )); then
      printf ','
    fi
    printf '\n'
  done
  printf '  ],\n'
  printf '  "nodes": [\n'
  for i in "${!all_node_ips[@]}"; do
    node_ip="${all_node_ips[$i]}"
    node_name="${all_node_names[$i]}"
    role="agent"
    [[ "${node_name}" == "server" ]] && role="server"
    platform="$(remote_platform "${node_ip}")"
    support="unsupported"
    if is_supported_platform "${platform}"; then
      support="supported"
    fi
    printf '    {"name": %s, "role": %s, "ipv4": %s, "platform": %s, "support": %s}' \
      "$(jq -Rn --arg v "${node_name}" '$v')" \
      "$(jq -Rn --arg v "${role}" '$v')" \
      "$(jq -Rn --arg v "${node_ip}" '$v')" \
      "$(jq -Rn --arg v "${platform}" '$v')" \
      "$(jq -Rn --arg v "${support}" '$v')"
    if (( i + 1 < ${#all_node_ips[@]} )); then
      printf ','
    fi
    printf '\n'
  done
  printf '  ]\n'
  printf '}\n'
} > "${tmp_json}"
mv "${tmp_json}" "${CLUSTER_JSON}"

{
  printf 'all:\n'
  printf '  vars:\n'
  printf '    ansible_user: %s\n' "${ONPREM_SSH_USER}"
  printf '    ansible_port: %s\n' "${ONPREM_SSH_PORT}"
  printf '    productive_k3s_remote_dir: %s\n' "${ONPREM_REMOTE_DIR}"
  printf '    productive_k3s_server_url: %s\n' "https://${ONPREM_SERVER_IP}:6443"
  printf '    productive_k3s_base_domain: %s\n' "${ONPREM_BASE_DOMAIN}"
  printf '    productive_k3s_rancher_host: %s\n' "${ONPREM_RANCHER_HOST}"
  printf '    productive_k3s_registry_host: %s\n' "${ONPREM_REGISTRY_HOST}"
  printf '  children:\n'
  printf '    servers:\n'
  printf '      hosts:\n'
  printf '        server:\n'
  printf '          ansible_host: %s\n' "${ONPREM_SERVER_IP}"
  printf '    agents:\n'
  printf '      hosts:\n'
  for i in "${!AGENT_IPS_ARRAY[@]}"; do
    printf '        agent-%s:\n' "$((i + 1))"
    printf '          ansible_host: %s\n' "${AGENT_IPS_ARRAY[$i]}"
  done
} > "${HOSTS_YML}"

{
  printf 'CLUSTER_NAME=%q\n' "${ONPREM_CLUSTER_NAME}"
  printf 'BASE_DOMAIN=%q\n' "${ONPREM_BASE_DOMAIN}"
  printf 'REMOTE_DIR=%q\n' "${ONPREM_REMOTE_DIR}"
  printf 'PRODUCTIVE_K3S_SOURCE=%q\n' "${resolved_source}"
  printf 'PRODUCTIVE_K3S_VERSION=%q\n' "${resolved_version}"
  printf 'PRODUCTIVE_K3S_RELEASE_REPO=%q\n' "${PRODUCTIVE_K3S_RELEASE_REPO}"
  printf 'SSH_USER=%q\n' "${ONPREM_SSH_USER}"
  printf 'SSH_PORT=%q\n' "${ONPREM_SSH_PORT}"
  printf 'SERVER_NAME=%q\n' "server"
  printf 'SERVER_IP=%q\n' "${ONPREM_SERVER_IP}"
  printf 'SERVER_URL=%q\n' "https://${ONPREM_SERVER_IP}:6443"
  printf 'RANCHER_HOST=%q\n' "${ONPREM_RANCHER_HOST}"
  printf 'REGISTRY_HOST=%q\n' "${ONPREM_REGISTRY_HOST}"
  printf 'AGENT_IPS=%q\n' "${AGENT_IPS_ARRAY[*]}"
} > "${NODES_ENV}"

if [[ -f "${SERVER_TOKEN_FILE}" ]]; then
  printf '%s\n' "https://${ONPREM_SERVER_IP}:6443" > "${SERVER_URL_FILE}"
fi

log "Generated ${CLUSTER_JSON} and ${HOSTS_YML}"
