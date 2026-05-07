#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${PRODUCTIVE_K3S_INFRA_REPO_DIR:-$(cd "${SCRIPT_DIR}/.." && pwd)}"
MAKE_BIN="${PRODUCTIVE_K3S_INFRA_MAKE_BIN:-make}"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/productive-k3s-infra.sh <use-case> [command] [make-args...]

Use cases:
  multipass
  onprem | onprem-basic
  aws-single-node

Examples:
  ./scripts/productive-k3s-infra.sh multipass up
  ./scripts/productive-k3s-infra.sh onprem preflight
  ./scripts/productive-k3s-infra.sh aws-single-node validate

Notes:
  - If [command] is omitted, the CLI defaults to 'up'.
  - Remaining arguments are passed through to the underlying make invocation.
EOF
}

die() {
  echo "$*" >&2
  exit 1
}

resolve_use_case() {
  case "$1" in
    multipass)
      printf 'multipass\n'
      ;;
    onprem|onprem-basic)
      printf 'onprem-basic\n'
      ;;
    aws-single-node)
      printf 'aws-single-node\n'
      ;;
    *)
      return 1
      ;;
  esac
}

if (($# == 0)); then
  usage >&2
  exit 1
fi

case "$1" in
  -h|--help|help)
    usage
    exit 0
    ;;
esac

USE_CASE="$(resolve_use_case "$1")" || die "Unsupported use case: $1"
shift

COMMAND="${1:-up}"
if (($# > 0)); then
  shift
fi

USE_CASE_DIR="${REPO_DIR}/use-cases/${USE_CASE}"
[[ -d "$USE_CASE_DIR" ]] || die "Use case directory not found: ${USE_CASE_DIR}"

exec "$MAKE_BIN" -C "$USE_CASE_DIR" "$COMMAND" "$@"
