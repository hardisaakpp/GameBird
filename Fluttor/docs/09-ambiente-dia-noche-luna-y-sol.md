# 9. Ambiente: día, noche, luna y sol

## 9.1 Comportamiento esperado

El juego alterna **modo día / noche** según hora del sistema (intervalos documentados en la guía original) y sincroniza **textura de fondo**, **elementos atmosféricos** (luna y sol) y **ajustes visuales** en la UI de bienvenida (colores de subtítulos de modos).

Archivos de referencia típicos:

- `GameScene+DayNight.swift`
- `BackgroundConstants.swift`, `BackgroundComponent.swift`
- `MoonComponent.swift`, `SunComponent.swift`

## 9.2 Capas (Z-position)

La documentación detallada de orden de dibujo (tubos por delante de luna/sol, etc.) y los valores numéricos están en:

**`Fluttor/MOON_INTEGRATION_GUIDE.md`**

Ese archivo incluye también la interacción táctil (forzar día temporal al tocar la luna, etc.) y la corrección histórica de `zPosition` en tuberías.

## 9.3 Assets relacionados

Notas por *imageset*: `Fluttor/FluttorGame/Assets.xcassets/moon.imageset/README.md` y `sun.imageset/README.md`.
