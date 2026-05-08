#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

ensure_base_requirements
load_cluster_metadata

for node in "${ALL_NODE_NAMES[@]}"; do
  write_hosts_entry_on_node "${node}" "${SERVER_IP}" "${RANCHER_HOST}" "${REGISTRY_HOST}"
done

log "Host aliases synchronized across all VMs"
