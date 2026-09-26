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
