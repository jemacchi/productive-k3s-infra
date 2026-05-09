#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/create-release-tag.sh <infra-version>

Example:
  ./scripts/create-release-tag.sh 0.9.1
EOF
}

err() {
  printf '%s\n' "$*" >&2
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${PRODUCTIVE_K3S_INFRA_REPO_DIR:-}"
if [[ -z "${REPO_ROOT}" ]]; then
  if REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    :
  else
    REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
  fi
fi

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/release-config.sh"

VERSION="${1:-${VERSION:-}}"
if [[ -z "${VERSION}" || $# -gt 1 ]]; then
  usage >&2
  exit 1
fi

if [[ ! "${VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  err "invalid infra version: ${VERSION}"
  err "expected X.Y.Z"
  exit 1
fi

if [[ "${PRODUCTIVE_K3S_SOURCE_DEFAULT}" != "remote" ]]; then
  err "default productive-k3s source must be remote to create an official release tag"
  exit 1
fi

if [[ ! "${PRODUCTIVE_K3S_CORE_VERSION_DEFAULT}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  err "invalid default productive-k3s-core version: ${PRODUCTIVE_K3S_CORE_VERSION_DEFAULT}"
  exit 1
fi

tag="${VERSION}-${PRODUCTIVE_K3S_CORE_VERSION_DEFAULT}"
if git -C "${REPO_ROOT}" rev-parse --verify "refs/tags/${tag}" >/dev/null 2>&1; then
  err "tag already exists locally: ${tag}"
  exit 1
fi

core_remote_url="${PRODUCTIVE_K3S_CORE_GIT_REMOTE_URL:-https://github.com/${PRODUCTIVE_K3S_RELEASE_REPO_DEFAULT}.git}"
remote_refs="$(git ls-remote --tags "${core_remote_url}" "refs/tags/${PRODUCTIVE_K3S_CORE_VERSION_DEFAULT}" "refs/tags/v${PRODUCTIVE_K3S_CORE_VERSION_DEFAULT}" || true)"
if [[ -z "${remote_refs}" ]]; then
  err "productive-k3s-core version ${PRODUCTIVE_K3S_CORE_VERSION_DEFAULT} was not found in ${core_remote_url}"
  exit 1
fi

git -C "${REPO_ROOT}" tag -a "${tag}" -m "Release ${tag}" HEAD
printf 'Created tag %s\n' "${tag}"
printf 'Next: git push origin %s\n' "${tag}"
