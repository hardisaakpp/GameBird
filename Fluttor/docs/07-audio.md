# 7. Audio

## 7.1 Archivos

Ubicación típica: **`Fluttor/FluttorGame/Sounds/`** (nombres habituales: `wing`, `hit`, `die`, `point`, `swoosh` en formato WAV). Inventario y tamaños: **`Fluttor/FluttorGame/Sounds/README.md`**.

## 7.2 `AudioManager`

Singleton **`AudioManager.shared`** (`Fluttor/Components/Managers/AudioManager.swift`). Métodos de alto nivel incluyen:

- `playWingSound()`, `playHitSound()`, `playDieSound()`, `playPointSound()`, `playSwooshSound()`
- Control de silencio / volumen según implementación actual (`toggleSound`, `isSoundOn`, etc.)

Constantes de nombres de archivo pueden agruparse en **`SoundConstants.swift`**.

## 7.3 Integración en la escena

Puntos de uso representativos:

- Salto del pájaro: toque en pantalla durante partida (`GameScene+Input.swift`).
- Colisiones y game over: contactos y efectos (`GameScene+Physics.swift`, `GameScene+GameOver.swift`).
- Botones de bienvenida y transiciones: swoosh.

El mapa detallado “archivo → método → momento” está en **`Fluttor/FluttorGame/Sounds/INTEGRATION_SUMMARY.md`**.

## 7.4 Optimización de audio

Estrategias documentadas (precarga, límites de concurrencia, sesión AVAudio): **`Fluttor/FluttorGame/Sounds/AUDIO_OPTIMIZATION.md`**. Los valores numéricos exactos (**`maxConcurrentSounds`**, volúmenes) deben verificarse siempre en el código fuente por si divergen entre documentos históricos.

## 7.5 Depuración

**`Fluttor/FluttorGame/SoundTest.swift`**: comprobaciones en desarrollo.
