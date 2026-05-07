#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

CLI="${REPO_DIR}/scripts/productive-k3s-infra.sh"

assert_contains() {
  local haystack="$1"
  local needle="$2"
  if [[ "$haystack" != *"$needle"* ]]; then
    echo "[FAIL] Expected output to contain: $needle" >&2
    echo "[FAIL] Actual output: $haystack" >&2
    exit 1
  fi
}

STUB_MAKE="${TMP_DIR}/make-stub.sh"
cat > "$STUB_MAKE" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" > "${PRODUCTIVE_K3S_INFRA_TEST_OUTPUT}"
EOF
chmod +x "$STUB_MAKE"

HELP_OUTPUT="$(bash "$CLI" --help)"
assert_contains "$HELP_OUTPUT" "Usage:"
assert_contains "$HELP_OUTPUT" "multipass"
assert_contains "$HELP_OUTPUT" "onprem | onprem-basic"

OUTPUT_FILE="${TMP_DIR}/multipass.out"
PRODUCTIVE_K3S_INFRA_MAKE_BIN="$STUB_MAKE" \
PRODUCTIVE_K3S_INFRA_TEST_OUTPUT="$OUTPUT_FILE" \
bash "$CLI" multipass validate TELEMETRY_ENABLED=false
assert_contains "$(cat "$OUTPUT_FILE")" "-C ${REPO_DIR}/use-cases/multipass validate TELEMETRY_ENABLED=false"

OUTPUT_FILE="${TMP_DIR}/onprem.out"
PRODUCTIVE_K3S_INFRA_MAKE_BIN="$STUB_MAKE" \
PRODUCTIVE_K3S_INFRA_TEST_OUTPUT="$OUTPUT_FILE" \
bash "$CLI" onprem preflight
assert_contains "$(cat "$OUTPUT_FILE")" "-C ${REPO_DIR}/use-cases/onprem-basic preflight"

OUTPUT_FILE="${TMP_DIR}/aws.out"
PRODUCTIVE_K3S_INFRA_MAKE_BIN="$STUB_MAKE" \
PRODUCTIVE_K3S_INFRA_TEST_OUTPUT="$OUTPUT_FILE" \
bash "$CLI" aws-single-node
assert_contains "$(cat "$OUTPUT_FILE")" "-C ${REPO_DIR}/use-cases/aws-single-node up"

ROOT_MULTIPASS="$(make -C "$REPO_DIR" -n multipass)"
assert_contains "$ROOT_MULTIPASS" "${REPO_DIR}/scripts/productive-k3s-infra.sh multipass up"

ROOT_ONPREM="$(make -C "$REPO_DIR" -n onprem)"
assert_contains "$ROOT_ONPREM" "${REPO_DIR}/scripts/productive-k3s-infra.sh onprem up"

if bash "$CLI" invalid-case >/dev/null 2>&1; then
  echo "[FAIL] Invalid use case unexpectedly succeeded" >&2
  exit 1
fi

printf '[PASS] productive-k3s-infra CLI dispatch is wired correctly\n'
