#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

ensure_base_requirements
ensure_logs_dir
load_cluster_metadata

python3 "${SCRIPT_DIR}/run_bootstrap_session.py" \
  --instance "${SERVER_NAME}" \
  --mode server \
  --remote-dir "${REMOTE_DIR}" \
  --log-file "${LOG_DIR}/bootstrap-server.log"

multipass exec "${SERVER_NAME}" -- sudo cat /var/lib/rancher/k3s/server/node-token | tr -d '\r' > "${SERVER_TOKEN_FILE}"
[[ -s "${SERVER_TOKEN_FILE}" ]] || {
  err "failed to capture a non-empty k3s server token"
  exit 1
}
printf '%s\n' "${SERVER_URL}" > "${SERVER_URL_FILE}"

log "Server bootstrap completed"
