#!/usr/bin/env bash
set -euo pipefail

# apply-lms-guardian.sh
# Usage: sudo ./apply-lms-guardian.sh /path/to/linux-source
# Copies lms_guardian.c into the kernel tree and appends Kconfig/Makefile entries if missing.

KDIR="$1"
if [[ -z "$KDIR" || ! -d "$KDIR" ]]; then
  echo "Usage: $0 /path/to/linux-source"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PATCH_SRC="$SCRIPT_DIR/lms_guardian.c"

if [[ ! -f "$PATCH_SRC" ]]; then
  echo "Missing $PATCH_SRC"
  exit 1
fi

echo "Applying LMS Guardian patch to kernel tree: $KDIR"

# Create init dir if missing
mkdir -p "$KDIR/init"

# Copy source
cp -v "$PATCH_SRC" "$KDIR/init/lms_guardian.c"

# Append Kconfig entry if not present
KCONFIG="$KDIR/init/Kconfig"
if ! grep -q "LMS_GUARDIAN" "$KCONFIG" 2>/dev/null; then
  cat >> "$KCONFIG" <<'EOF'

config LMS_GUARDIAN
	tristate "Linux Mobile Services - Guardian de Cumplimiento GPLv3"
	default y
	helP
	  Bloquea módulos privativos, blobs cerrados y Google GMS.
EOF
  echo "Appended Kconfig entry to $KCONFIG"
else
  echo "Kconfig already contains LMS_GUARDIAN"
fi

# Append Makefile line if missing
MAKEFILE="$KDIR/init/Makefile"
if ! grep -q "lms_guardian.o" "$MAKEFILE" 2>/dev/null; then
  echo 'obj-$(CONFIG_LMS_GUARDIAN) += lms_guardian.o' >> "$MAKEFILE"
  echo "Appended Makefile entry to $MAKEFILE"
else
  echo "Makefile already contains lms_guardian.o"
fi

# Instructions
cat <<'INSTR'

Parche aplicado. Para compilar el kernel con LMS integrado como built-in:

1) En el kernel tree:
   cd /path/to/linux-source
   make menuconfig        # opcional, revisar CONFIG_LMS_GUARDIAN (set to y for built-in)
   # o usar defconfig adecuado: make defconfig

2) Compilar y generar imagen:
   make -j$(nproc)

3) Flash/instalar la imagen en tu dispositivo (depende de la plataforma):
   - En dispositivos Android AOSP con fastboot:
       fastboot flash boot path/to/boot.img
   - En sistemas embebidos con dtb:
       dd if=arch/arm64/boot/Image of=/dev/block/bootdevice/by-name/boot

4) Reinicia y verifica logs:
   dmesg | grep -i lms

Nota: Para compatibilidad absoluta con un dispositivo concreto, compila usando el defconfig/config del dispositivo.

INSTR
