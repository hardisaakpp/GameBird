# 3. Configuración, herramientas y fuentes

## 3.1 Proyecto Xcode

- Abrir **`Fluttor/Fluttor.xcodeproj`** en Xcode.
- Seleccionar el esquema del juego principal (app) y el destino Simulador o dispositivo.
- El nombre del **target** de aplicación puede aparecer como `WordCraftGame` u homónimo histórico; la documentación de producto usa **Fluttor**.

## 3.2 Fuentes

El juego prioriza **fuentes del sistema iOS** para garantizar disponibilidad sin empaquetar tipografías personalizadas (p. ej. pixel fonts no incluidas por defecto). La paleta y fallbacks están centralizadas en **`FontConstants.swift`** (`Fluttor/Utilities/FontConstants.swift`).

Para inspeccionar qué fuentes resuelve el sistema en tiempo de ejecución existe **`FontTest.swift`** (`Fluttor/FluttorGame/FontTest.swift`).

### Documento histórico detallado

La guía extendida con tablas por tipo de control sigue disponible en el repositorio:

`Fluttor/FONT_INSTALLATION_GUIDE.md` (redirige a esta carpeta `docs/`; conservar para listados largos de familias).

## 3.3 Buenas prácticas

- Tras cambiar recursos en **Assets.xcassets**, hacer *Clean Build Folder* si Xcode cachea imágenes antiguas.
- Mantener nombres de *imageset* alineados con `imageNamed:` en código.
