#!/usr/bin/env bash
set -euo pipefail

# build-deb.sh
# Run this on an Ubuntu/Debian host to build the lms-guardian .deb package
# Usage: ./build-deb.sh

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUTDIR="$REPO_ROOT/out/artifacts"
PKGROOT="$REPO_ROOT/out/deb_build/lms-guardian-1.0"
DEBNAME="lms-guardian_1.0_all.deb"

rm -rf "$PKGROOT"
mkdir -p "$PKGROOT/DEBIAN"
mkdir -p "$PKGROOT/usr/share/lms"

# Copy the DKMS tarball into package
cp -v "$OUTDIR/lms_guardian-dkms-1.0.tar.gz" "$PKGROOT/usr/share/lms/"

# Control file
cat > "$PKGROOT/DEBIAN/control" <<'EOF'
Package: lms-guardian
Version: 1.0
Section: misc
Priority: optional
Architecture: all
Depends: dkms, make, gcc
Maintainer: LMS Team <devnull@example.com>
Description: Installer package for lms_guardian DKMS module
 Installs the DKMS source and registers it so the module is built for the running kernel.
EOF

# postinst: register with DKMS and build
cat > "$PKGROOT/DEBIAN/postinst" <<'EOF'
#!/bin/sh
set -e

PKG_NAME="lms_guardian"
PKG_VERSION="1.0"
SRC_DIR="/usr/share/lms"
TARBALL="$SRC_DIR/lms_guardian-dkms-1.0.tar.gz"

if [ -f "$TARBALL" ]; then
  TMPDIR=$(mktemp -d)
  tar -xzf "$TARBALL" -C "$TMPDIR"
  mkdir -p "/usr/src/${PKG_NAME}-${PKG_VERSION}"
  cp -v "$TMPDIR"/* "/usr/src/${PKG_NAME}-${PKG_VERSION}/"
  dkms remove -m "$PKG_NAME" -v "$PKG_VERSION" --all || true
  dkms add -m "$PKG_NAME" -v "$PKG_VERSION"
  dkms build -m "$PKG_NAME" -v "$PKG_VERSION"
  dkms install -m "$PKG_NAME" -v "$PKG_VERSION"
  rm -rf "$TMPDIR"
fi
exit 0
EOF
chmod 0755 "$PKGROOT/DEBIAN/postinst"

# Build the deb
mkdir -p "$REPO_ROOT/out/deb"
if command -v dpkg-deb >/dev/null 2>&1; then
  dpkg-deb --build "$PKGROOT" "$REPO_ROOT/out/deb/$DEBNAME"
  echo "Created $REPO_ROOT/out/deb/$DEBNAME"
else
  echo "dpkg-deb not found. The package skeleton is prepared at $PKGROOT. Run 'dpkg-deb --build $PKGROOT' on a Debian/Ubuntu machine to build the .deb."
fi
