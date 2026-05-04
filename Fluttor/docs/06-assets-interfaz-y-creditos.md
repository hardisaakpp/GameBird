# 6. Assets, interfaz y créditos

## 6.1 Catálogo principal

Los recursos gráficos viven en **`Fluttor/FluttorGame/Assets.xcassets`**, organizados por *imagesets* (bird, tuberías, fondos día/noche, UI, números, etc.). Convención en código: **`SKSpriteNode(imageNamed: "NombreImageset")`** sin sufijo `.png` en la cadena.

### Elementos frecuentes

| Imageset (ejemplos) | Uso |
| ------------------- | --- |
| `FluttoRTittle` | Título en pantalla de bienvenida |
| `Play` / `playBasic` | Botones de modo en bienvenida |
| `Background-day` / `Background-Night` | Fondos |
| `pipe-green1` / `pipe-green2`, `pipe-red*` | Obstáculos |
| `UI-Message`, `UI-GameOver`, `Restart` | Interfaz y fin de partida |
| `Numbers` (u organización similar) | Dígitos para marcador |

Listado ampliado y recomendaciones: véase el documento original de inventario en **`Fluttor/ASSETS_ORGANIZATION.md`** (stub que apunta aquí) para tablas completas por carpeta.

## 6.2 Título con imagen

El título de texto fue sustituido por **`FluttoRTittle`** como `SKSpriteNode` escalado en `GameScene+Welcome.swift`. Detalle histórico de dimensiones y migración: **`Fluttor/TITLE_IMAGE_IMPLEMENTATION.md`**.

## 6.3 Créditos en pantalla de bienvenida

Implementados como etiquetas en la parte inferior (`GameScene+Welcome.swift`):

- «Desarrollado por Isaac Ortiz»
- «Fluttor v1.0 • SpriteKit • Swift • iOS»

Mayor detalle de tipografías y posiciones: **`Fluttor/CREDITS_IMPLEMENTATION.md`**.

## 6.4 README colocalizados en Assets

Algunos *imagesets* incluyen `README.md` específico (p. ej. luna, sol, moneda). Sirven como nota técnica junto al arte; el índice general sigue siendo `docs/README.md`.
