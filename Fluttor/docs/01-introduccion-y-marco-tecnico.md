# 1. Introducción y marco técnico

## 1.1 Descripción del producto

**Fluttor** es un juego para **iOS** inspirado en la mecánica de scroll lateral con obstáculos: el jugador controla un personaje que debe esquivar tuberías y obtener puntos. El proyecto sirve como base para experimentación en interfaz, física 2D, audio y persistencia local.

## 1.2 Stack tecnológico

| Capa | Tecnología |
| ---- | ---------- |
| Motor 2D | SpriteKit |
| Lenguaje | Swift |
| Plataforma | iOS (UIKit para ventana principal, `GameViewController`) |
| Física | `SKPhysicsWorld` / `SKPhysicsBody` |
| Persistencia | `UserDefaults` (puntuaciones y metadatos) |
| Audio | `AVFoundation` (vía `AudioManager`) |

## 1.3 Estructura del repositorio (nivel alto)

```
GameBird/
├── README.md                 → Punta a esta documentación
└── Fluttor/
    ├── docs/                 → Documentación canónica (esta serie)
    ├── Fluttor.xcodeproj     → Proyecto Xcode
    ├── FluttorGame/          → Escena, vista, sonidos, tests de app
    ├── Components/           → Entidades y gestores reutilizables
    ├── Models/               → Tipos de dominio y configuración
    ├── Utilities/            → Constantes y ayudas
    ├── Components.docc/      → Documentación DocC (Components)
    └── FluttorGameTests/     → Tests unitarios / Swift Testing
```

## 1.4 Requisitos de desarrollo

- **macOS** con **Xcode** compatible con la versión de Swift del proyecto.
- Cuenta de desarrollador Apple solo si se despliega en dispositivo físico o TestFlight.

## 1.5 Nota sobre el nombre del módulo

En el código aparecen comentarios y a veces el nombre de módulo **`WordCraftGame`** (origen histórico del target). La documentación de producto y la interfaz refieren el nombre **Fluttor**.

## 1.6 Bloque reproducibilidad (rellenar al cerrar versión de tesis)

| Campo | Valor |
| ----- | ----- |
| Fecha | |
| Commit Git (`git rev-parse HEAD`) | |
| Xcode (`xcodebuild -version`) | |
| SDK / destino de compilación | |
| Dispositivo o simulador en pruebas | |
