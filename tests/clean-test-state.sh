#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ARTIFACTS_DIR="${TEST_ARTIFACTS_DIR:-${REPO_DIR}/test-artifacts}"
RUNS_DIR="${ARTIFACTS_DIR}/infra-runs"
SCENARIO_FILTER="${TEST_SCENARIO:-}"

removed_any=0

remove_file() {
  local path="$1"
  if [[ -e "${path}" ]]; then
    rm -f "${path}"
    removed_any=1
  fi
}

if [[ -n "${SCENARIO_FILTER}" ]]; then
  if [[ -d "${RUNS_DIR}" ]]; then
    artifact_scenario=""
    while IFS= read -r -d '' artifact; do
      artifact_scenario="$(jq -r '.scenario // empty' "${artifact}" 2>/dev/null || true)"
      [[ "${artifact_scenario}" == "${SCENARIO_FILTER}" ]] || continue
      remove_file "${artifact}"
    done < <(find "${RUNS_DIR}" -maxdepth 1 -type f -name "*.json" -print0)
  fi
  if [[ -d "${RUNS_DIR}" ]] && [[ -z "$(find "${RUNS_DIR}" -maxdepth 1 -type f -name '*.json' -print -quit)" ]]; then
    rmdir "${RUNS_DIR}" 2>/dev/null || true
  fi
  if [[ -d "${ARTIFACTS_DIR}" ]] && [[ -z "$(find "${ARTIFACTS_DIR}" -mindepth 1 -print -quit)" ]]; then
    rmdir "${ARTIFACTS_DIR}" 2>/dev/null || true
  fi
  printf '[INFO] Cleared local test state for scenario %s from %s\n' "${SCENARIO_FILTER}" "${ARTIFACTS_DIR}"
else
  if [[ -d "${ARTIFACTS_DIR}" ]]; then
    rm -rf "${ARTIFACTS_DIR}"
    removed_any=1
  fi
  printf '[INFO] Cleared local test state from %s\n' "${ARTIFACTS_DIR}"
fi

if [[ "${removed_any}" -eq 0 ]]; then
  printf '[INFO] No local test state matched the requested cleanup scope\n'
fi
