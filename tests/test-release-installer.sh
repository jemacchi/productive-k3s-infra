#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

TARBALL_URL="https://github.com/example/repo/releases/download/1.2.3-4.5.6/productive-k3s-infra-1.2.3-4.5.6.tar.gz"
CHECKSUM_URL="https://github.com/example/repo/releases/download/1.2.3-4.5.6/checksums.txt"
OUTPUT_PATH="${TMP_DIR}/productive-k3s-infra-cli.sh"

sed \
  -e "s|__PK3S_INFRA_VERSION__|1.2.3-4.5.6|g" \
  -e "s|__PK3S_INFRA_REPO__|example/repo|g" \
  -e "s|__PK3S_INFRA_TARBALL_URL__|${TARBALL_URL}|g" \
  -e "s|__PK3S_INFRA_CHECKSUM_URL__|${CHECKSUM_URL}|g" \
  -e "s|__PK3S_CORE_VERSION__|4.5.6|g" \
  "${ROOT_DIR}/scripts/install-release-template.sh" > "${OUTPUT_PATH}"

grep -F 'PK3S_CORE_VERSION="4.5.6"' "${OUTPUT_PATH}" >/dev/null || {
  printf '[FAIL] rendered installer is missing PK3S_CORE_VERSION\n' >&2
  exit 1
}

grep -F 'PRODUCTIVE_K3S_SOURCE=remote' "${OUTPUT_PATH}" >/dev/null || {
  printf '[FAIL] rendered installer does not force PRODUCTIVE_K3S_SOURCE=remote\n' >&2
  exit 1
}

grep -F 'PRODUCTIVE_K3S_VERSION="${PK3S_CORE_VERSION}"' "${OUTPUT_PATH}" >/dev/null || {
  printf '[FAIL] rendered installer does not export the bound productive-k3s version\n' >&2
  exit 1
}

grep -F 'productive-k3s-infra.sh' "${OUTPUT_PATH}" >/dev/null || {
  printf '[FAIL] rendered installer does not target the public root CLI\n' >&2
  exit 1
}

printf '[PASS] release installer template binds the productive-k3s core version\n'
