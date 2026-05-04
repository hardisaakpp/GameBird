# 4. Flujo de juego y escenas

## 4.1 Secuencia principal

1. **Carga de `GameScene`** (`GameScene+Lifecycle.swift`): se muestra la **pantalla de bienvenida**.
2. **Bienvenida** (`GameScene+Welcome.swift`): imagen de título (`FluttoRTittle`), campo de nombre (`TextInputComponent`), subtítulo «¡Aventura Aérea!», dos modos — normal (`Play`) y básico (`playBasic`), créditos al pie.
3. El jugador elige modo → `hideWelcomeScreen(gameMode:)` aplica física del modo (`applyGameModePhysics()`), persiste el nombre en `Player`, y en cadena **`startInitialPause()`** muestra el mensaje / instrucciones iniciales.
4. **Toque** en la fase de instrucciones → `resumeGame()` (`GameScene+Input.swift`).
5. **Partida**: tubos, puntuación, colisiones (`GameScene+Physics.swift`, `GameScene+Update.swift`).
6. **Game over** (`GameScene+GameOver.swift`): overlay, puntuación final, reinicio.
7. **Reiniciar**: según implementación en `GameScene+Restart.swift` y pausa, puede volver al flujo que muestra de nuevo la bienvenida.

## 4.2 Estados booleanos clave (conceptual)

- `isWelcomeScreenActive`: bienvenida visible.
- `isInitialPauseActive`: mensaje de inicio antes de jugar.
- `isPausedGame`: pausa general (incluye pausa inicial).
- `isGameOver`: fin de partida.

La fuente de verdad exacta son las propiedades en `GameScene.swift`.

## 4.3 Entrada del usuario en bienvenida

- **Campo de nombre**: toque abre alerta de texto vía `GameViewController` (`GameViewController+TextInput.swift`), actualización con `updatePlayerName(_:)`.
- **Modo normal / básico**: `AudioManager.shared.playSwooshSound()` y `hideWelcomeScreen(gameMode:)`.

## 4.4 Modos de juego

`GameMode` (definido en el proyecto junto a la configuración de física) altera gravedad, impulsos y comportamiento de tuberías (`PipeManager.setGameMode`). Detalle en código: `GameConfing.swift` / física en `applyGameModePhysics()`.

## 4.5 Referencias de implementación

| Tema | Archivo principal |
| ---- | ----------------- |
| Bienvenida | `Fluttor/FluttorGame/Scenes/GameScene+Welcome.swift` |
| Toques | `Fluttor/FluttorGame/Scenes/GameScene+Input.swift` |
| Ciclo de vida | `Fluttor/FluttorGame/Scenes/GameScene+Lifecycle.swift` |
| Pausa | `Fluttor/FluttorGame/Scenes/GameScene+Pause.swift` |
