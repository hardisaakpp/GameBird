# Documentación técnica — Fluttor

Documentación de referencia del proyecto **Fluttor** (SpriteKit / Swift / iOS). Pensada para desarrollo continuo y para **citación en trabajo de fin de titulación o investigación aplicada**.

**Normativa:** Para referencias bibliográficas y datos de versión (commit, Xcode, dispositivo), usa **[Guía de citación](GUIA-DE-CITACION.md)** y adapta el formato al que exija tu universidad (APA, ISO, Vancouver, etc.).

## Cómo usar este índice

| Orden | Documento | Contenido |
| ----- | --------- | --------- |
| 0 | [Guía de citación](GUIA-DE-CITACION.md) | Plantillas para bibliografía y trazabilidad de versión |
| 1 | [Introducción y marco técnico](01-introduccion-y-marco-tecnico.md) | Propósito del software, stack, requisitos |
| 2 | [Arquitectura del sistema](02-arquitectura-del-sistema.md) | Módulos, `GameScene`, componentes, modelos |
| 3 | [Configuración, herramientas y fuentes](03-configuracion-herramientas-y-fuentes.md) | Xcode, fuentes, pruebas de tipografía |
| 4 | [Flujo de juego y escenas](04-flujo-de-juego-y-escenas.md) | Bienvenida, pausa, partida, game over |
| 5 | [Persistencia y puntuación](05-persistencia-y-puntuacion.md) | `ScoreManager`, `UserDefaults`, historial por jugador |
| 6 | [Assets, interfaz y créditos](06-assets-interfaz-y-creditos.md) | Catálogo de recursos, título, textos legales/créditos |
| 7 | [Audio](07-audio.md) | Archivos, `AudioManager`, integración en escena |
| 8 | [Rendimiento](08-rendimiento.md) | Optimizaciones SpriteKit y audio |
| 9 | [Ambiente: día, noche, luna y sol](09-ambiente-dia-noche-luna-y-sol.md) | Ciclo visual, interacción, capas |
| 10 | [Anexos: historial y referencias cruzadas](10-anexos-historial-y-referencias.md) | Resúmenes de correcciones, DocC, rutas colocalizadas |

## Documentación colocalizada (no mover)

Algunos directorios conservan notas junto a los recursos; el índice maestro sigue siendo esta carpeta `docs/`.

| Ubicación | Uso |
| --------- | --- |
| `Fluttor/FluttorGame/Sounds/README.md` | Lista de archivos WAV y API de sonido |
| `Fluttor/FluttorGame/Assets.xcassets/*/README.md` | Notas por *imageset* (luna, sol, moneda, etc.) |
| `Fluttor/Components.docc/Components.md` | Catálogo DocC del módulo Components |

## Referencia rápida del código (Swift)

- **Escena principal**: `Fluttor/FluttorGame/GameScene.swift` y extensiones en `Fluttor/FluttorGame/Scenes/`
- **Componentes**: `Fluttor/Components/` (`Entities/`, `Managers/`, `UI/`)
- **Modelos**: `Fluttor/Models/`
- **Utilidades**: `Fluttor/Utilities/`
- **Proyecto Xcode**: `Fluttor/Fluttor.xcodeproj`

El nombre del **producto/target** en Xcode puede figurar como `WordCraftGame` por historial del proyecto; el nombre comercial en pantalla es **Fluttor**.
