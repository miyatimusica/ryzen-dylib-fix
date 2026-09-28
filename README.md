<div align="center">

# ⚡ Ryzen-Dylib-Fix

**Parche Universal Runtime Dylib para Ryzentosh (AMD Ryzen + NootEDred)**

[![macOS](https://img.shields.io/badge/macOS-12%20%7C%2013%20%7C%2014%20%7C%2015-blue.svg?style=for-the-badge&logo=apple&logoColor=white)](https://www.apple.com/macos)
[![Architecture](https://img.shields.io/badge/Architecture-x86__64-orange.svg?style=for-the-badge&logo=cpu)](https://github.com/miyatimusica/ryzen-dylib-fix)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
[![GitHub release](https://img.shields.io/badge/Release-v2.0--PRO-brightgreen.svg?style=for-the-badge&logo=github)](https://github.com/miyatimusica/ryzen-dylib-fix/releases)

*Solución automatizada y no destructiva para prevenir cierres inesperados (`NSInvalidArgumentException`) en Native Instruments, DAWs y plugins sobre procesadores AMD Ryzen.*

---

</div>

## 📋 Tabla de Contenidos

- [Descripción General](#-descripción-general)
- [El Problema](#-el-problema)
- [La Solución](#-la-solución)
- [Instalación Rápida](#-instalación-rápida-1-línea)
- [Instalación Manual](#-instalación-manual)
- [Verificación](#-verificación)
- [Compatibilidad Confirmada](#-compatibilidad-confirmada)
- [Desinstalación](#-desinstalación)
- [Contribuciones y Soporte](#-contribuciones-y-soporte)
- [Licencia](#-licencia)

---

## 📌 Descripción General

**`ryzen-dylib-fix`** es una herramienta runtime diseñada específicamente para entornos **AMD Ryzen Hackintosh (Ryzentosh)** que utilizan **NootEDred.kext** (iGPU Vega).

A diferencia de los parches tradicionales de binario que alteran los ejecutables, esta solución inyecta una librería dinámica ligera (`ryzen_fix.dylib`) mediante la variable de entorno `DYLD_INSERT_LIBRARIES`. Esto corrige las inconsistencias de tipos de datos entre **IOKit** y **CoreFoundation**, garantizando estabilidad absoluta en macOS Monterey, Ventura, Sonoma y Sequoia **sin romper firmas de código (Code Signing) ni invalidar actualizaciones del software**.

---

## 🛑 El Problema

Al iniciar herramientas de producción musical en un Ryzentosh, los módulos de analítica y renderizado de gráficos (como `BusinessAnalytics` de Native Instruments) realizan consultas de hardware a IOKit para identificar la GPU del sistema.

Debido a la arquitectura del driver `NootEDred.kext`:
1. **IOKit** entrega la propiedad de la tarjeta gráfica como un objeto binario de memoria (`__NSCFData` / `NSData`).
2. El software de audio asume que obtendrá una cadena de texto (`NSString`) e invoca métodos de cadena como `_fastCStringContents:` o `UTF8String`.
3. El runtime de Objective-C detecta la falta del selector y genera una excepción fatal, provocando el cierre inmediato de la aplicación:

```text
-[__NSCFData _fastCStringContents:]: unrecognized selector sent to instance 0x6000021c4280
zsh: segmentation fault  /Applications/Native Instruments/Kontakt 7/Kontakt 7.app
```

---

## 💡 La Solución

En lugar de aplicar *patches* estáticos sobre los archivos binarios (lo que destruye sus firmas digitales y exige repetir el proceso tras cada actualización), **`ryzen-dylib-fix`** actúa directamente en memoria en tiempo de ejecución:

- 🧩 **Extensión de Runtime:** Extiende dinámicamente `NSData` en memoria mediante una categoría de Objective-C sin impacto medible en el rendimiento.
- 🛡️ **Intercepción Transparente:** Redirige los llamados fallidos (`_fastCStringContents:`, `UTF8String`, etc.) devolviendo un puntero de cadena válido: `"AMD Radeon Graphics"`.
- 🔄 **Persistencia en el Sistema:** Despliega un `LaunchAgent` a nivel de usuario con `DYLD_INSERT_LIBRARIES` para asegurar compatibilidad continua en aplicaciones Standalone, plugins (VST3 / AU / AAX) y DAWs tras cada reinicio.

---

## ⚡ Instalación Rápida (1 Línea)

Abre la **Terminal** de tu macOS y ejecuta el siguiente comando:

```bash
curl -fsSL https://raw.githubusercontent.com/miyatimusica/ryzen-dylib-fix/main/ryzen-dylib-fix.sh | zsh
```

---

## 🛠️ Instalación Manual

Si prefieres realizar el proceso paso a paso:

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/miyatimusica/ryzen-dylib-fix.git
   cd ryzen-dylib-fix
   ```

2. **Asignar permisos de ejecución:**
   ```bash
   chmod +x ryzen-dylib-fix.sh
   ```

3. **Ejecutar el instalador:**
   ```bash
   ./ryzen-dylib-fix.sh
   ```

---

## 🔍 Verificación

Para confirmar que la librería global se encuentra inyectada y activa en tu sesión actual, ejecuta:

```bash
launchctl getenv DYLD_INSERT_LIBRARIES
```

**Resultado esperado:**
```text
/Library/Application Support/Ryzentosh/ryzen_fix.dylib
```

---

## 🎹 Compatibilidad Confirmada

### Software / DAWs Probados

| Software / Plugin | Formato / Tipo | Estado |
| :--- | :--- | :---: |
| **Native Instruments Kontakt 8** | Standalone / VST3 / AU | ✅ Funcional |
| **Native Instruments Kontakt 7** | Standalone / VST3 / AU | ✅ Funcional |
| **Komplete Kontrol** | Standalone / VST3 / AU | ✅ Funcional |
| **Maschine 2** | Standalone / VST3 / AU | ✅ Funcional |
| **Steinberg Cubase** (v10 — v13) | Host DAW | ✅ Funcional |
| **Image-Line FL Studio** | Host DAW | ✅ Funcional |
| **Ableton Live** (v11 — v12) | Host DAW | ✅ Funcional |

### Entorno de Hardware y Sistema

- **Procesadores:** AMD Ryzen 3, 5 y 7 (Series 3000, 4000, 5000, 6000 y 7000 APU).
- **Driver iGPU:** `NootEDred.kext` (Gráficos integrados Vega).
- **Versiones de macOS:** 
  - macOS 12 Monterey
  - macOS 13 Ventura
  - macOS 14 Sonoma
  - macOS 15 Sequoia

---

## 🗑️ Desinstalación

Si deseas remover completamente el parche y restaurar los valores por defecto del sistema:

```bash
# 1. Desactivar y eliminar el LaunchAgent
launchctl unload -w "$HOME/Library/LaunchAgents/com.ryzentosh.globalfix.plist" 2>/dev/null
rm -f "$HOME/Library/LaunchAgents/com.ryzentosh.globalfix.plist"

# 2. Desactivar la variable de entorno de la sesión activa
launchctl unsetenv DYLD_INSERT_LIBRARIES

# 3. Eliminar los archivos compilados
sudo rm -rf "/Library/Application Support/Ryzentosh"
```

---

## 🤝 Contribuciones y Soporte

¡Las contribuciones, reportes de errores y sugerencias son altamente bienvenidos!

Si este proyecto te ha sido útil para ejecutar software de producción musical en tu Ryzentosh, considera darle una ⭐️ **Estrella (Star)** al repositorio en GitHub.

---

## 📄 Licencia

Distribuido bajo la Licencia **MIT**. Consulta el archivo [`LICENSE`](LICENSE) para más detalles.

---

<div align="center">

*Desarrollado con ❤️ para la comunidad de **Ryzentosh** y **Hackintosh**.*

</div>
