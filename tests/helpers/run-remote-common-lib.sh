#!/usr/bin/env bash
# shellcheck disable=SC1090
set -euo pipefail

SCRIPT_PATH="$1"
COMMAND="$2"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORKSPACE_DIR="$(cd "${REPO_DIR}/.." && pwd)"

export PRODUCTIVE_K3S_REPO="${PRODUCTIVE_K3S_REPO:-${WORKSPACE_DIR}/productive-k3s-core}"

. "${SCRIPT_PATH}"
eval "${COMMAND}"
