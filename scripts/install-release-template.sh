#!/usr/bin/env bash
set -euo pipefail

VERSION="__VERSION__"
OWNER="__OWNER__"
REPO="__REPO__"
ARCHIVE_NAME="__ARCHIVE_NAME__"
ARCHIVE_SHA256="__ARCHIVE_SHA256__"
RELEASE_BASE_URL="https://github.com/${OWNER}/${REPO}/releases/download/${VERSION}"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

for cmd in bash curl tar sha256sum mktemp; do
  need_cmd "$cmd"
done

WORK_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

ARCHIVE_PATH="${WORK_DIR}/${ARCHIVE_NAME}"
BUNDLE_DIR="${WORK_DIR}/productive-k3s-infra-${VERSION}"

echo "[INFO] Downloading productive-k3s-infra ${VERSION}"
curl -fsSL "${RELEASE_BASE_URL}/${ARCHIVE_NAME}" -o "$ARCHIVE_PATH"

echo "${ARCHIVE_SHA256}  ${ARCHIVE_PATH}" | sha256sum -c -

mkdir -p "$BUNDLE_DIR"
tar -xzf "$ARCHIVE_PATH" -C "$WORK_DIR"

if [[ ! -x "${BUNDLE_DIR}/scripts/productive-k3s-infra.sh" ]]; then
  echo "Public productive-k3s-infra CLI not found in extracted archive" >&2
  exit 1
fi

cd "$BUNDLE_DIR"
exec ./scripts/productive-k3s-infra.sh "$@"
