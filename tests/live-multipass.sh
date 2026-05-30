#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCENARIO_DIR="${ROOT_DIR}/scenarios/local/multipass"
TOFU_BIN="${TOFU_BIN:-$(command -v tofu || command -v terraform || true)}"
SCENARIO_CLEANUP_TIMEOUT_SECONDS="${SCENARIO_CLEANUP_TIMEOUT_SECONDS:-120}"
MULTIPASS_INSTANCE_REMOVAL_TIMEOUT_SECONDS="${MULTIPASS_INSTANCE_REMOVAL_TIMEOUT_SECONDS:-180}"
MULTIPASS_INSTANCE_REMOVAL_POLL_SECONDS="${MULTIPASS_INSTANCE_REMOVAL_POLL_SECONDS:-5}"

[[ -n "${TOFU_BIN}" ]] || {
  printf '[FAIL] tofu or terraform is required for multipass live tests\n' >&2
  exit 1
}

if [[ "${PRODUCTIVE_K3S_ENGINE:-native}" == "k3sup" && -z "${PRODUCTIVE_K3S_SOURCE:-}" ]]; then
  export PRODUCTIVE_K3S_SOURCE="local"
fi

warn() {
  printf '[WARN] %s\n' "$1" >&2
}

cleanup() {
  run_cleanup_make down TOFU_BIN="${TOFU_BIN}"
  wait_for_instance_removal productive-k3s-mp
  run_cleanup_make clean
}

run_cleanup_make() {
  local target="$1"
  shift || true

  if command -v timeout >/dev/null 2>&1; then
    if timeout --kill-after=5s "${SCENARIO_CLEANUP_TIMEOUT_SECONDS}s" make -C "${SCENARIO_DIR}" "${target}" "$@" >/dev/null 2>&1; then
      return 0
    fi
    printf '[WARN] scenario cleanup target %s timed out after %ss; continuing\n' "${target}" "${SCENARIO_CLEANUP_TIMEOUT_SECONDS}" >&2
    return 0
  fi

  make -C "${SCENARIO_DIR}" "${target}" "$@" >/dev/null 2>&1 || true
}

list_matching_instances() {
  local prefix="$1"

  multipass list --format json 2>/dev/null \
    | jq -r --arg prefix "${prefix}" '.list[]?.name | select(startswith($prefix))'
}

wait_for_instance_removal() {
  local prefix="$1"
  local deadline=$((SECONDS + MULTIPASS_INSTANCE_REMOVAL_TIMEOUT_SECONDS))
  local matches=""

  while (( SECONDS < deadline )); do
    matches="$(list_matching_instances "${prefix}" || true)"
    if [[ -z "${matches}" ]]; then
      return 0
    fi
    sleep "${MULTIPASS_INSTANCE_REMOVAL_POLL_SECONDS}"
  done

  matches="$(list_matching_instances "${prefix}" || true)"
  if [[ -n "${matches}" ]]; then
    warn "multipass instances with prefix ${prefix} still exist after ${MULTIPASS_INSTANCE_REMOVAL_TIMEOUT_SECONDS}s:"
    printf '%s\n' "${matches}" >&2
  fi
}

main() {
  trap cleanup EXIT

  cleanup
  make -C "${SCENARIO_DIR}" up TOFU_BIN="${TOFU_BIN}"
  make -C "${SCENARIO_DIR}" validate

  printf '[PASS] multipass live test completed\n'
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
