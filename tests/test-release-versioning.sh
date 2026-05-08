#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HELPER="${ROOT_DIR}/scripts/release-versioning.sh"

assert_eq() {
  local actual="$1"
  local expected="$2"
  local label="$3"
  if [[ "${actual}" != "${expected}" ]]; then
    printf '[FAIL] %s: expected %s, got %s\n' "${label}" "${expected}" "${actual}" >&2
    exit 1
  fi
}

eval "$("${HELPER}" env 1.2.3-4.5.6)"
assert_eq "${PK3S_INFRA_RELEASE_TAG}" "1.2.3-4.5.6" "release tag"
assert_eq "${PK3S_INFRA_SEMVER}" "1.2.3" "infra semver"
assert_eq "${PK3S_CORE_SEMVER}" "4.5.6" "core semver"
assert_eq "${PK3S_INFRA_IS_RELEASE}" "true" "release marker"

eval "$("${HELPER}" env HEAD)"
assert_eq "${PK3S_INFRA_RELEASE_TAG}" "HEAD" "dev ref tag"
assert_eq "${PK3S_INFRA_SEMVER}" "HEAD" "dev ref semver"
assert_eq "${PK3S_CORE_SEMVER}" "" "dev ref core semver"
assert_eq "${PK3S_INFRA_IS_RELEASE}" "false" "dev ref release marker"

if "${HELPER}" validate 1.2.3 >/dev/null 2>&1; then
  printf '[FAIL] expected non-composite tag validation to fail\n' >&2
  exit 1
fi

"${HELPER}" validate 1.2.3-4.5.6 >/dev/null

printf '[PASS] release versioning helper parses and validates composite tags\n'
