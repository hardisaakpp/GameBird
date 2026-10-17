# 4. Flujo de juego y escenas

## 4.1 Secuencia principal

1. **Carga de `GameScene`** (`GameScene+Lifecycle.swift`): se muestra la **pantalla de bienvenida**.
2. **Bienvenida** (`GameScene+Welcome.swift`): imagen de título (`FluttoRTittle`), campo de nombre (`TextInputComponent`), subtítulo «¡Aventura Aérea!», dos modos — normal (`Play`) y básico (`playBasic`), créditos al pie.
3. El jugador elige modo. **INTERMEDIO** entra directo; **BÁSICO** abre antes la elección *DINÁMICO / ENTRENAMIENTO* (§4.6). `hideWelcomeScreen(gameMode:)` aplica física del modo (`applyGameModePhysics()`), persiste el nombre en `Player`, y en cadena **`startInitialPause()`** muestra el mensaje / instrucciones iniciales.
4. **Toque** en la fase de instrucciones → `resumeGame()` (`GameScene+Input.swift`).
5. **Partida**: tubos, puntuación, colisiones (`GameScene+Physics.swift`, `GameScene+Update.swift`).
6. **Game over** (`GameScene+GameOver.swift`): overlay, puntuación final, botón **REINICIAR**, botón circular con **casita** (vuelve a la selección de nivel) y, debajo, puntaje, nombre del jugador y top 5.
7. **Reiniciar** (`GameScene+Restart.swift`): reinicia la partida conservando el modo vigente. La **casita** llama a `showLevelSelectScreen()` (`GameScene+Pause.swift`) y vuelve a la bienvenida.

## 4.2 Estados booleanos clave (conceptual)

- `isWelcomeScreenActive`: bienvenida visible.
- `isInitialPauseActive`: mensaje de inicio antes de jugar.
- `isPausedGame`: pausa general (incluye pausa inicial).
- `isGameOver`: fin de partida.
- `isModeUpgradeOfferActive`, `hasOfferedModeUpgrade`, `isTrainingMode`: oferta de cambio BÁSICO → INTERMEDIO (§4.6).

La fuente de verdad exacta son las propiedades en `GameScene.swift`.

## 4.3 Entrada del usuario en bienvenida

- **Campo de nombre**: toque abre alerta de texto vía `GameViewController` (`GameViewController+TextInput.swift`), actualización con `updatePlayerName(_:)`.
- **Modo normal**: `AudioManager.shared.playSwooshSound()` y `hideWelcomeScreen(gameMode:)`.
- **Modo básico**: abre la elección DINÁMICO / ENTRENAMIENTO (`showBasicVariantChoice()`, `GameScene+BasicVariant.swift`).

## 4.4 Modos de juego

`GameMode` (definido en el proyecto junto a la configuración de física) altera gravedad, impulsos y comportamiento de tuberías (`PipeManager.setGameMode`). Detalle en código: `GameConfing.swift` / física en `applyGameModePhysics()`.

## 4.5 Pausa

- `pauseGame()` congela físicas (`physicsWorld.speed = 0`), suelo, fondo, tubos y el pájaro (`isPaused`, de modo que el poder magnético solo cuenta tiempo jugado). Se activa con el botón de pausa o automáticamente al perder el foco la app (`GameViewController`).
- Al volver del escritorio SpriteKit puede reanudar la vista y descongelar nodos; por eso `enforcePauseIfNeeded()` reaplica la pausa en cada fotograma mientras `isPausedGame` sea verdadero (`GameScene+Update.swift`) y al recibir `didBecomeActive`.
- `PipeManager` guarda el tiempo restante hasta el siguiente tubo al pausar y lo respeta en `resume()`, de modo que pausar repetidamente no desplaza el ritmo. El primer tubo tras la pausa inicial se programa con `startGeneratingPipes(afterDelay:)`, una acción de la escena cancelable.
- El menú de pausa ofrece REANUDAR, reiniciar (vuelve a las instrucciones) y la **casita** (vuelve a la selección de nivel).

## 4.6 Variante de BÁSICO y paso a INTERMEDIO

- Tras tocar BÁSICO se muestra una pantalla con **DINÁMICO** y **ENTRENAMIENTO** (`GameScene+BasicVariant.swift`, `UIComponent.createBasicVariantOverlay`), con botón circular de regreso en la esquina superior izquierda.
- En **DINÁMICO**, al llegar a `modeUpgradeScoreThreshold` (20 puntos) el juego se pausa **una vez por partida** y ofrece *PASAR A INTERMEDIO* o *SEGUIR EN BÁSICO* (`GameScene+ModeUpgrade.swift`). Tras elegir hay una cuenta regresiva de 3 s.
- Si se elige INTERMEDIO se conserva el puntaje, `currentGameMode` pasa a `.normal`, se aplica su física, se limpian los tubos ya generados (`PipeManager.prepareForModeSwitch()`) y la partida se registra como INTERMEDIO.
- En **ENTRENAMIENTO** (`isTrainingMode`) nunca se ofrece el cambio. Las partidas se registran como BÁSICO.
- Si se cambia a INTERMEDIO, REINICIAR conserva ese modo; para volver a BÁSICO hay que pasar por la casita.

## 4.7 Referencias de implementación

| Tema | Archivo principal |
| ---- | ----------------- |
| Bienvenida | `Fluttor/FluttorGame/Scenes/GameScene+Welcome.swift` |
| Toques | `Fluttor/FluttorGame/Scenes/GameScene+Input.swift` |
| Ciclo de vida | `Fluttor/FluttorGame/Scenes/GameScene+Lifecycle.swift` |
| Pausa | `Fluttor/FluttorGame/Scenes/GameScene+Pause.swift` |
| Variante de BÁSICO | `Fluttor/FluttorGame/Scenes/GameScene+BasicVariant.swift` |
| Oferta de INTERMEDIO | `Fluttor/FluttorGame/Scenes/GameScene+ModeUpgrade.swift` |
