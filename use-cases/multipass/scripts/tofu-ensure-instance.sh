#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

ACTION="${1:-}"
NAME="${2:-}"
IMAGE="${3:-}"
CPUS="${4:-}"
MEMORY="${5:-}"
DISK="${6:-}"
CLOUD_INIT_FILE="${7:-}"

[[ -n "${ACTION}" && -n "${NAME}" ]] || {
  err "usage: $0 <apply|destroy> <name> [image cpus memory disk cloud-init-file]"
  exit 2
}

ensure_base_requirements

case "${ACTION}" in
  apply)
    [[ -n "${IMAGE}" && -n "${CPUS}" && -n "${MEMORY}" && -n "${DISK}" && -n "${CLOUD_INIT_FILE}" ]] || {
      err "apply requires image, cpus, memory, disk, and cloud-init-file"
      exit 2
    }
    if multipass_instance_exists "${NAME}"; then
      state="$(multipass_state "${NAME}")"
      if [[ "${state}" != "Running" ]]; then
        log "Starting existing Multipass instance ${NAME}"
        multipass start "${NAME}"
      else
        log "Multipass instance ${NAME} already exists"
      fi
      exit 0
    fi
    log "Launching Multipass instance ${NAME}"
    multipass launch "${IMAGE}" \
      --name "${NAME}" \
      --cpus "${CPUS}" \
      --memory "${MEMORY}" \
      --disk "${DISK}" \
      --cloud-init "${CLOUD_INIT_FILE}"
    ;;
  destroy)
    if multipass_instance_exists "${NAME}"; then
      log "Deleting Multipass instance ${NAME}"
      multipass delete "${NAME}"
      multipass purge
    else
      log "Multipass instance ${NAME} already absent"
    fi
    ;;
  *)
    err "unknown action: ${ACTION}"
    exit 2
    ;;
esac
