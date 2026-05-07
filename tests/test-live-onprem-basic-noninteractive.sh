#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_SCRIPT="${ROOT_DIR}/tests/live-onprem-basic.sh"
TMP_DIR="$(mktemp -d)"
FAKEBIN="${TMP_DIR}/fakebin"
HOME_DIR="${TMP_DIR}/home"
LOG_FILE="${TMP_DIR}/make.log"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

mkdir -p "${FAKEBIN}" "${HOME_DIR}/.ssh"
printf 'fake-private-key\n' > "${HOME_DIR}/.ssh/id_ed25519"
printf 'ssh-ed25519 AAAATEST fake@test\n' > "${HOME_DIR}/.ssh/id_ed25519.pub"
chmod 600 "${HOME_DIR}/.ssh/id_ed25519"

cat > "${FAKEBIN}/multipass" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in
  launch|delete|purge)
    exit 0
    ;;
  info)
    printf '{"info":{"%s":{"ipv4":["10.0.0.10"]}}}\n' "${4:-vm}"
    ;;
  *)
    echo "unexpected multipass invocation: $*" >&2
    exit 1
    ;;
esac
EOF

cat > "${FAKEBIN}/jq" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cat >/dev/null
printf '10.0.0.10\n'
EOF

cat > "${FAKEBIN}/ssh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
exit 0
EOF

cat > "${FAKEBIN}/make" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "${TEST_MAKE_LOG}"
exit 0
EOF

chmod +x "${FAKEBIN}/multipass" "${FAKEBIN}/jq" "${FAKEBIN}/ssh" "${FAKEBIN}/make"

PATH="${FAKEBIN}:${PATH}" \
HOME="${HOME_DIR}" \
TEST_MAKE_LOG="${LOG_FILE}" \
bash "${TARGET_SCRIPT}"

grep -F 'TELEMETRY_ENABLED=false' "${LOG_FILE}" >/dev/null || {
  printf '[FAIL] live-onprem-basic.sh did not force TELEMETRY_ENABLED=false\n' >&2
  printf 'Captured make invocations:\n' >&2
  cat "${LOG_FILE}" >&2
  exit 1
}

printf '[PASS] live-onprem-basic.sh forces TELEMETRY_ENABLED=false for automation\n'
