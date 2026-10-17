# 7. Audio

## 7.1 Archivos

Ubicación típica: **`Fluttor/FluttorGame/Sounds/`** (nombres habituales: `wing`, `hit`, `die`, `point`, `swoosh` en formato WAV). Inventario y tamaños: **`Fluttor/FluttorGame/Sounds/README.md`**.

## 7.2 `AudioManager`

Singleton **`AudioManager.shared`** (`Fluttor/Components/Managers/AudioManager.swift`). Métodos de alto nivel incluyen:

- `playWingSound()`, `playHitSound()`, `playDieSound()`, `playPointSound()`, `playSwooshSound()`
- `playCoinSound()`, `playFruitSound()`
- Control de silencio / volumen según implementación actual (`toggleSound`, `setSoundEnabled`, `isSoundOn`, `stopAllSounds`, etc.)

Constantes de nombres de archivo pueden agruparse en **`SoundConstants.swift`**.

## 7.3 Integración en la escena

Puntos de uso representativos:

- Salto del pájaro: toque en pantalla durante partida (`GameScene+Input.swift`).
- Colisiones y game over: contactos y efectos (`GameScene+Physics.swift`, `GameScene+GameOver.swift`).
- Botones de bienvenida y transiciones: swoosh.

El mapa detallado “archivo → método → momento” está en **`Fluttor/FluttorGame/Sounds/INTEGRATION_SUMMARY.md`**.

## 7.4 Motor de audio de baja latencia

`AudioManager` usa **`AVAudioEngine`** con un grupo de **8 `AVAudioPlayerNode`** (voces) en un formato estándar (44 100 Hz, estéreo, float32):

- Los archivos se decodifican y convierten **una sola vez** a `AVAudioPCMBuffer` (`AVAudioConverter`) en `preloadSounds()`.
- Cada reproducción programa el buffer en una voz libre con `scheduleBuffer(..., options: .interrupts)`, sin crear objetos nuevos durante el juego.
- Toda la gestión corre en una cola propia `game.audio` (`.userInteractive`), fuera del hilo principal.
- Se solicita una duración de buffer de E/S pequeña a `AVAudioSession` (`preferredIOBufferDuration`) para reducir la latencia.
- Observadores recuperan el motor al cambiar la configuración de audio, al reiniciarse los servicios de medios, al volver la app a primer plano y al terminar una interrupción.
- Si el motor no está disponible, se recurre a `AVAudioPlayer` como alternativa.

La API pública no cambió respecto a la versión basada en `AVAudioPlayer`.

## 7.5 Optimización de audio (histórico)

Estrategias del diseño anterior basado en `AVAudioPlayer` (precarga, límites de concurrencia, sesión AVAudio); el motor actual se describe en §7.4: **`Fluttor/FluttorGame/Sounds/AUDIO_OPTIMIZATION.md`**. Los valores numéricos exactos (**`maxConcurrentSounds`**, volúmenes) deben verificarse siempre en el código fuente por si divergen entre documentos históricos.

## 7.6 Depuración

**`Fluttor/FluttorGame/SoundTest.swift`**: comprobaciones en desarrollo.
