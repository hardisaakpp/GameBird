# 5. Persistencia y puntuación

## 5.1 Rol del `ScoreManager`

Clase singleton **`ScoreManager.shared`** (`Fluttor/Components/Managers/ScoreManager.swift`). Centraliza:

- Estadísticas **globales** en `UserDefaults`.
- Historial de partidas **por jugador** (nombre + puntuación + modo + fecha), serializado en JSON.

## 5.2 Claves `UserDefaults` (globales)

| Clave | Contenido |
| ----- | --------- |
| `HighScore` | Mejor puntuación global |
| `TotalGamesPlayed` | Partidas registradas con `recordGameResult` |
| `TotalScore` | Suma de puntajes de esas partidas |

## 5.3 Historial por jugador

| Clave | Formato |
| ----- | ------- |
| `PlayerScores` | `Data` JSON: array de `PlayerScore` (`playerName`, `score`, `date`, `gameMode`) |

Se limita el crecimiento (p. ej. últimos 100 registros) para no expandir almacenamiento sin control.

## 5.4 Integración en gameplay

Al finalizar una partida relevante, la escena invoca (entre otros) en `GameScene+Physics.swift`:

- `ScoreManager.shared.recordGameResult(score:)`
- `ScoreManager.shared.recordPlayerScore(score:gameMode:)`

## 5.5 API destacada

Consultar el archivo fuente para la lista completa. Incluye, entre otros:

- `updateHighScore(_:)`, `getAverageScore()`, `getScoreStats()`
- `getCurrentPlayerHighScore()`, `getCurrentPlayerRecentScores()`, `getCurrentPlayerTop5Scores()`
- `getTop5Leaderboard()`, `getGlobalLeaderboard()`, `getCurrentPlayerStats()`
- `resetAllScores()` — reinicia estadísticas globales; **no** borra por sí solo el JSON de `PlayerScores` salvo que se amplíe ese método.

## 5.6 Presentación en pantalla

La visualización de puntaje final y tablas en **game over** está en **`GameScene+GameOver.swift`** (nodos y layout pueden cambiar con el tiempo).

## 5.7 Pruebas auxiliares

**`Fluttor/FluttorGame/ScoreTest.swift`**: rutinas de consola para validar el gestor en desarrollo.
