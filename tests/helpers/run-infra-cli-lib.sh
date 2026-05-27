#!/usr/bin/env bash
# shellcheck disable=SC1090
set -euo pipefail

SCRIPT_PATH="$1"
COMMAND="$2"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_LIB="$(mktemp)"

trap '/bin/rm -f "${TMP_LIB}"' EXIT

awk '
  /^if \(\(\$# == 0\)\); then$/ { exit }
  { print }
' "${SCRIPT_PATH}" >"${TMP_LIB}"

export PRODUCTIVE_K3S_INFRA_REPO_DIR="${PRODUCTIVE_K3S_INFRA_REPO_DIR:-${REPO_DIR}}"

. "${TMP_LIB}"
eval "${COMMAND}"
