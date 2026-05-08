#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/release-versioning.sh validate <tag>
  ./scripts/release-versioning.sh env <tag>

Composite release tags must look like:
  X.Y.Z-A.B.C
EOF
}

is_composite_release_tag() {
  local tag="$1"
  [[ "${tag}" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)-([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]
}

emit_env() {
  local tag="$1"
  if is_composite_release_tag "${tag}"; then
    printf 'PK3S_INFRA_RELEASE_TAG=%q\n' "${tag}"
    printf 'PK3S_INFRA_SEMVER=%q\n' "${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
    printf 'PK3S_CORE_SEMVER=%q\n' "${BASH_REMATCH[4]}.${BASH_REMATCH[5]}.${BASH_REMATCH[6]}"
    printf 'PK3S_INFRA_IS_RELEASE=%q\n' "true"
    return 0
  fi

  printf 'PK3S_INFRA_RELEASE_TAG=%q\n' "${tag}"
  printf 'PK3S_INFRA_SEMVER=%q\n' "${tag}"
  printf 'PK3S_CORE_SEMVER=%q\n' ""
  printf 'PK3S_INFRA_IS_RELEASE=%q\n' "false"
}

COMMAND="${1:-}"
TAG="${2:-}"

if [[ -z "${COMMAND}" || -z "${TAG}" || $# -ne 2 ]]; then
  usage >&2
  exit 1
fi

case "${COMMAND}" in
  validate)
    if ! is_composite_release_tag "${TAG}"; then
      printf 'invalid composite release tag: %s\n' "${TAG}" >&2
      exit 1
    fi
    ;;
  env)
    emit_env "${TAG}"
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
