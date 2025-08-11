# 🎵 Estructura de Audio - WordCraftGame

## 📁 Organización de Archivos

```
WordCraftGame/
├── die.wav      (194KB) - Sonido de muerte del pájaro
├── hit.wav      (96KB)  - Sonido de impacto con tubería
├── point.wav    (177KB) - Sonido de puntuación
├── swoosh.wav   (354KB) - Sonido de movimiento
└── wing.wav     (29KB)  - Sonido de aleteo del pájaro
```

## 🎮 Uso en el Código

### 1. Importar el AudioManager
```swift
import AVFoundation
```

### 2. Reproducir sonidos
```swift
// Sonido de aleteo (cuando el pájaro salta)
AudioManager.shared.playWingSound()

// Sonido de impacto (cuando choca con tubería)
AudioManager.shared.playHitSound()

// Sonido de muerte (cuando toca el suelo)
AudioManager.shared.playDieSound()

// Sonido de puntuación (cuando pasa tubería)
AudioManager.shared.playPointSound()

// Sonido de movimiento (efectos generales)
AudioManager.shared.playSwooshSound()
```

### 3. Control de audio
```swift
// Activar/desactivar sonido
AudioManager.shared.toggleSound()

// Verificar si el sonido está activo
let isOn = AudioManager.shared.isSoundOn()

// Detener todos los sonidos
AudioManager.shared.stopAllSounds()
```

## 📋 Estándares iOS

✅ **Ubicación correcta**: `WordCraftGame/Sounds/`
✅ **Formato recomendado**: `.wav` para mejor compatibilidad
✅ **Gestión centralizada**: `AudioManager` singleton
✅ **Configuración automática**: Sesión de audio configurada
✅ **Caché inteligente**: Los sonidos se cargan una vez y se reutilizan

## 🔧 Configuración

Los archivos de audio están ubicados en el directorio principal de WordCraftGame y se incluyen automáticamente en el bundle de la aplicación. No se requiere configuración adicional en Xcode.

## 📝 Notas

- Los archivos `.ogg` fueron removidos para mantener consistencia
- Todos los sonidos están optimizados para el juego
- El `AudioManager` maneja automáticamente la configuración de la sesión de audio
- Los sonidos se reproducen de forma asíncrona sin bloquear el juego
