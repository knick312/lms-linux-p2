#!/usr/bin/env bash
set -euo pipefail

# install-ko-android.sh
# Usage: ./install-ko-android.sh path/to/lms_guardian.ko
# Pushes the .ko to a connected Android device and attempts insmod (device must be rooted).

KO_PATH="$1"
TMP_REMOTE=/data/local/tmp/$(basename "$KO_PATH")

if [[ -z "$KO_PATH" || ! -f "$KO_PATH" ]]; then
  echo "Usage: $0 path/to/lms_guardian.ko"
  exit 1
fi

if ! command -v adb >/dev/null 2>&1; then
  echo "adb not found in PATH"
  exit 1
fi

echo "Rebooting adb as root (if supported)..."
adb root || true

echo "Pushing module to device: $TMP_REMOTE"
adb push "$KO_PATH" "$TMP_REMOTE"

echo "Attempting to insert module on device (requires root)."
adb shell "su -c 'insmod $TMP_REMOTE'" || {
  echo "insmod failed. Check device kernel module support, or run 'adb shell' and install manually as root."
  exit 1
}

echo "Module insertion attempted. Check dmesg on device: adb shell dmesg | tail -n 100"
