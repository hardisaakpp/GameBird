# 8. Rendimiento

## 8.1 Objetivo

Mantener **60 FPS** (o la tasa objetivo del dispositivo) reduciendo trabajo innecesario por frame: física de depuración, acciones repetidas, colisiones tras game over, y saturación de audio.

## 8.2 Áreas documentadas en el código base

El proyecto incluye un informe histórico detallado en:

**`Fluttor/FluttorGame/PERFORMANCE_OPTIMIZATIONS.md`**

Temas típicos allí descritos:

- Sustitución de rotaciones por `SKAction` por asignación directa de `zRotation` donde procede.
- Desactivar **`showsPhysics`** en producción.
- Salidas tempranas en contactos cuando `isGameOver` es verdadero.
- Límites y espaciado de reproducción de sonidos.
- Parámetros de damping / masa del pájaro.

## 8.3 Monitor opcional

**`PerformanceMonitor.swift`** puede usarse para observar tiempos en desarrollo (consultar implementación actual).

## 8.4 Audio y rendimiento

Optimizaciones específicas del subsistema de audio: **[7. Audio](07-audio.md)** y **`Sounds/AUDIO_OPTIMIZATION.md`**.

## 8.5 Principio para la tesis

Cualquier cifra (p. ej. número máximo de sonidos concurrentes) debe **citarse desde el código** o desde mediciones propias en el dispositivo de prueba, porque los documentos históricos pueden quedar desfasados respecto a la última refactorización.
