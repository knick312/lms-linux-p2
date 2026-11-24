Parche LMS Guardian - instrucciones (español)

Objetivo:
  Añadir "lms_guardian" al árbol del kernel como módulo integrado (built-in) o como módulo compilable.

Contenido:
  - lms_guardian.c  (código fuente del guardian)
  - apply-lms-guardian.sh  (script que aplica el parche al kernel tree)

Pasos recomendados para integrarlo y generar una imagen kernel:

1) Copia el árbol del kernel del dispositivo a un host de compilación Linux (Ubuntu/Debian recommended).
2) Copia este directorio "packaging/patches" al host.
3) Ejecuta como root en el árbol del kernel:
     sudo packaging/patches/apply-lms-guardian.sh /ruta/al/linux-source
   El script copiará lms_guardian.c y añadirá las líneas necesarias a init/Kconfig e init/Makefile.

4) Ajusta la configuración del kernel para asegurar que CONFIG_LMS_GUARDIAN= y (o) built-in:
     cd /ruta/al/linux-source
     make menuconfig
     # Busca "LMS_GUARDIAN" en el menú de init o usa scripts/config para cambiarlo
     scripts/config --set-val CONFIG_LMS_GUARDIAN y

5) Compilar la imagen del kernel adecuada para tu dispositivo:
     make -j$(nproc)
   Para Android AOSP/Device trees sigue las instrucciones del fabricante o del repositorio AOSP para generar boot.img.

6) Flashear/instalar la imagen en el dispositivo:
   - En dispositivos con fastboot: fastboot flash boot boot.img
   - En sistemas empotrados: copia Image/zImage al partición de arranque según la plataforma.

Verificación:
   - Reinicia el dispositivo y revisa: adb shell dmesg | grep -i lms
   - Busca mensajes de arranque: "LMS KERNEL ACTIVANDO GUARDIAN"

Notas importantes:
 - Para garantizar compatibilidad absoluta, compila contra el defconfig y los headers del dispositivo objetivo.
 - Si no puedes compilar la imagen, usa el método de módulo cargable (DKMS/insmod) como paso intermedio para pruebas en entornos Linux x86_64.
 - Integrar un guardián en el kernel es irreversible hasta que flashees una imagen distinta; haz pruebas en un dispositivo de desarrollo.

Licencia:
 - Código bajo GPLv3 (según el encabezado del módulo) — ideal para integración en proyectos Linux open source.
