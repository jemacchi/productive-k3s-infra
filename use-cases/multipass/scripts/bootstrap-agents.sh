#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

ensure_base_requirements
ensure_logs_dir
load_cluster_metadata

if [[ ! -f "${SERVER_TOKEN_FILE}" ]]; then
  err "missing ${SERVER_TOKEN_FILE}; run bootstrap-server first"
  exit 1
fi

cluster_token="$(tr -d '\r\n' < "${SERVER_TOKEN_FILE}")"

for agent in "${AGENT_NAMES[@]}"; do
  python3 "${SCRIPT_DIR}/run_bootstrap_session.py" \
    --instance "${agent}" \
    --mode agent \
    --remote-dir "${REMOTE_DIR}" \
    --server-url "${SERVER_URL}" \
    --cluster-token "${cluster_token}" \
    --log-file "${LOG_DIR}/bootstrap-${agent}.log"
done

mp_exec "${SERVER_NAME}" "sudo k3s kubectl wait --for=condition=Ready node --all --timeout=10m"
log "Agent bootstrap completed"
