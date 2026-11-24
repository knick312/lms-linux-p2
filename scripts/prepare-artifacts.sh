#!/usr/bin/env bash
set -euo pipefail

# prepare-artifacts.sh
# After CI artifacts are downloaded locally, this script packages a DKMS-ready tarball for x86_64
# and prepares .tar.gz for arm64. Run in repo root with the artifacts directory as argument.

ARTIFACTS_DIR="${1:-./artifacts}"  # path where GH run downloaded files
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DKMS_SRC_DIR="${REPO_ROOT}/packaging/dkms/lms_guardian-1.0"
OUT_DIR="${REPO_ROOT}/out/artifacts"

mkdir -p "$OUT_DIR"

# Copy source into DKMS package dir
TMPPKG=$(mktemp -d)
cp -v "$REPO_ROOT/lms/usr/src/linux/init/lms_guardian.c" "$TMPPKG/"
cp -v "$DKMS_SRC_DIR/dkms.conf" "$TMPPKG/"
cp -v "$DKMS_SRC_DIR/Makefile" "$TMPPKG/"

# Create dkms tarball
tar -czf "$OUT_DIR/lms_guardian-dkms-1.0.tar.gz" -C "$TMPPKG" .
rm -rf "$TMPPKG"

echo "Created DKMS tarball: $OUT_DIR/lms_guardian-dkms-1.0.tar.gz"

# If artifacts contain out-arm64.tar.gz or out-x86.tar.gz, copy them
if [[ -d "$ARTIFACTS_DIR" ]]; then
  cp -v "$ARTIFACTS_DIR"/*out-arm64* "$OUT_DIR/" 2>/dev/null || true
  cp -v "$ARTIFACTS_DIR"/*out-x86* "$OUT_DIR/" 2>/dev/null || true
fi

echo "Prepared artifacts in $OUT_DIR. Use install-dkms.sh on a Debian/Ubuntu notebook to register via DKMS, and use install-ko-android.sh to push the arm64 .ko to Android devices."
