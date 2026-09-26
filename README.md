# ⚡ ryzen-dylib-fix

[![macOS](https://img.shields.io/badge/macOS-Monterey%20%7C%20Ventura%20%7C%20Sonoma%20%7C%20Sequoia-blue.svg?style=for-the-badge&logo=apple)](https://www.apple.com/macos)
[![Architecture](https://img.shields.io/badge/Architecture-x86__64-orange.svg?style=for-the-badge)](https://github.com/miyatimusica/ryzen-dylib-fix)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
[![GitHub release](https://img.shields.io/badge/Release-v2.0--PRO-brightgreen.svg?style=for-the-badge)](https://github.com/miyatimusica/ryzen-dylib-fix/releases)

> **Parche Universal Runtime Dylib para Ryzentosh (AMD Ryzen + NootEDred.kext)**  
> *Soluciona los cierres inesperados en Native Instruments Kontakt 7/8, Komplete Kontrol y DAWs causados por excepciones de telemetría de GPU (`NSInvalidArgumentException` / `-[__NSCFData _fastCStringContents:]`).*

---

## 📌 Descripción General

**`ryzen-dylib-fix`** es una solución automatizada y no destructiva diseñada para sistemas **AMD Ryzen Hackintosh (Ryzentosh)** que utilizan **NootEDred.kext** (iGPU Vega). 

Inyecta de forma global una librería dinámica ligera (`ryzen_fix.dylib`) mediante `DYLD_INSERT_LIBRARIES` para corregir los errores de tipos de datos entre IOKit y CoreFoundation en programas de producción musical. Esto garantiza estabilidad total en macOS Monterey, Ventura, Sonoma y Sequoia, sin modificar los binarios originales ni romper las firmas de código de las aplicaciones.

---

## 🛑 El Problema

Al iniciar ciertas aplicaciones de audio profesional en un Ryzentosh, los módulos de telemetría y analítica gráfica de Native Instruments (`BusinessAnalytics`) o las consultas internas de IOKit intentan inspeccionar la tarjeta de video.

Debido a la forma en que `NootEDred.kext` expone las propiedades de la iGPU Vega al espacio de usuario:
1. IOKit entrega los valores del hardware como un objeto binario (`__NSCFData` / `NSData`).
2. El programa de audio espera recibir una cadena de texto (`NSString`) e invoca métodos de texto como `_fastCStringContents:` o `UTF8String`.
3. El entorno de ejecución de Objective-C lanza una excepción por selector no reconocido, provocando el cierre inmediato de la aplicación:

```text
-[__NSCFData _fastCStringContents:]: unrecognized selector sent to instance 0x...
zsh: segmentation fault  /Applications/Native Instruments/Kontakt 7/Kontakt 7.app

## 💡 La Solución

En lugar de parchear binarios (lo que destruye las firmas digitales y requiere repetir el proceso en cada actualización), **ryzen-dylib-fix** utiliza inyección de librerías dinámicas en tiempo de ejecución:

* 🧩 **Categoría de Runtime:** Añade una categoría en Objective-C a `NSData` en memoria con impacto nulo en el rendimiento.
* 🛡️ **Intercepción Segura:** Intercepta los llamados fallidos (`_fastCStringContents:`, `UTF8String`, etc.) y responde con un texto válido: `"AMD Radeon Graphics"`.
* 🔄 **Persistencia en el Sistema:** Configura un `LaunchAgent` a nivel de usuario con `DYLD_INSERT_LIBRARIES` para que las aplicaciones, plugins (VST3/AU/AAX) y hosts independientes funcionen sin problemas tras cada reinicio.

---

## ⚡ Instalación Rápida (Comando de 1 Línea)

Abre la Terminal de tu macOS y ejecuta el siguiente comando:

```bash
curl -fsSL https://raw.githubusercontent.com/miyatimusica/ryzen-dylib-fix/main/install.sh | zsh
```

---

## 🛠️ Instalación Manual

Si prefieres realizar el proceso paso a paso:

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/miyatimusica/ryzen-dylib-fix.git
   cd ryzen-dylib-fix
   ```

2. **Otorgar permisos de ejecución:**
   ```bash
   chmod +x install.sh
   ```

3. **Ejecutar el instalador:**
   ```bash
   ./install.sh
   ```

---

## 🔍 Verificación

Para confirmar que la librería global está inyectada y activa en tu sesión actual, ejecuta:

```bash
launchctl getenv DYLD_INSERT_LIBRARIES
```

**Resultado esperado:**
```text
/Library/Application Support/Ryzentosh/ryzen_fix.dylib
```

---

## 🎹 Compatibilidad Confirmada

### Software Probado

| Software / Plugin | Tipo | Estado |
| :--- | :--- | :---: |
| Native Instruments Kontakt 8 | Standalone / VST3 / AU | ✅ Funcional |
| Native Instruments Kontakt 7 | Standalone / VST3 / AU | ✅ Funcional |
| Komplete Kontrol | Standalone / VST3 / AU | ✅ Funcional |
| Maschine 2 | Standalone / VST3 / AU | ✅ Funcional |
| Steinberg Cubase 10 / 11 / 12 / 13 | Host DAW | ✅ Funcional |
| Image-Line FL Studio | Host DAW | ✅ Funcional |
| Ableton Live 11 / 12 | Host DAW | ✅ Funcional |

### Hardware y Entorno Probados

* **Procesadores:** AMD Ryzen 3 3200U, Ryzen 5 3500U, Ryzen 7 3700U, APUs Series Ryzen 4000/5000/6000/7000.
* **Driver de iGPU:** `NootEDred.kext` (Gráficos Vega).
* **Versiones de macOS:** macOS 12 Monterey, macOS 13 Ventura, macOS 14 Sonoma, macOS 15 Sequoia.

---

## 🗑️ Desinstalación

Si deseas remover el parche por completo y restaurar la configuración por defecto de tu sistema:

```bash
# 1. Desactivar y eliminar el LaunchAgent
launchctl unload -w "$HOME/Library/LaunchAgents/com.ryzentosh.globalfix.plist" 2>/dev/null
rm -f "$HOME/Library/LaunchAgents/com.ryzentosh.globalfix.plist"

# 2. Desactivar la variable de entorno en la sesión activa
launchctl unsetenv DYLD_INSERT_LIBRARIES

# 3. Eliminar la librería compilada
sudo rm -rf "/Library/Application Support/Ryzentosh"
```

---

## 🤝 Contribuciones y Soporte

¡Las contribuciones, reportes de errores y sugerencias son bienvenidos!

Si este proyecto te ayudó a ejecutar el software de Native Instruments en tu Ryzentosh, ¡considera darle una ⭐️ **Estrella (Star)** al repositorio en GitHub!

---

## 📄 Licencia

Distribuido bajo la Licencia MIT. Consulta el archivo `LICENSE` para más detalles.

*Desarrollado con ❤️ para la comunidad de Ryzentosh y Hackintosh.*
