#!/usr/bin/env bash
set -euo pipefail

# install-dkms.sh
# Usage: sudo ./install-dkms.sh [version]
# Prepares /usr/src/lms_guardian-1.0 and registers/builds via DKMS

VERSION="${1:-1.0}"
PKG_NAME="lms_guardian"
SRC_DIR="/usr/src/${PKG_NAME}-${VERSION}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC_IN_REPO="${REPO_ROOT}/lms/usr/src/linux/init/lms_guardian.c"
DKMS_CONF_IN_REPO="${REPO_ROOT}/packaging/dkms/lms_guardian-1.0/dkms.conf"
MAKEFILE_IN_REPO="${REPO_ROOT}/packaging/dkms/lms_guardian-1.0/Makefile"

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root (sudo)"
  exit 1
fi

if ! command -v dkms >/dev/null 2>&1; then
  echo "dkms not found. Install dkms and kernel headers (e.g., apt install dkms linux-headers-$(uname -r))"
  exit 1
fi

rm -rf "$SRC_DIR"
mkdir -p "$SRC_DIR"
cp -v "$SRC_IN_REPO" "$SRC_DIR/lms_guardian.c"
cp -v "$DKMS_CONF_IN_REPO" "$SRC_DIR/dkms.conf"
cp -v "$MAKEFILE_IN_REPO" "$SRC_DIR/Makefile"

echo "Registering with DKMS: module=$PKG_NAME version=$VERSION"
 dkms remove -m "$PKG_NAME" -v "$VERSION" --all || true
 dkms add -m "$PKG_NAME" -v "$VERSION"
 dkms build -m "$PKG_NAME" -v "$VERSION"
 dkms install -m "$PKG_NAME" -v "$VERSION"

echo "DKMS install complete. Use 'dkms status' to verify."
