# 🏆 Sistema de Puntuación - WordCraftGame

## 📋 Descripción

El sistema de puntuación implementa el almacenamiento persistente del mejor puntaje alcanzado usando `UserDefaults` de iOS. Esto permite que los jugadores mantengan sus récords entre sesiones del juego.

## 🏗️ Arquitectura

### **ScoreManager.swift**
- **Ubicación**: `Components/Managers/ScoreManager.swift`
- **Patrón**: Singleton para acceso global
- **Almacenamiento**: UserDefaults para persistencia local

### **Características Principales**
- ✅ Almacena el mejor puntaje (High Score)
- ✅ Cuenta total de juegos jugados
- ✅ Suma acumulada de todos los puntajes
- ✅ Cálculo automático del promedio
- ✅ Persistencia automática entre sesiones

## 🎮 Integración en el Juego

### **1. Registro Automático**
```swift
// Se ejecuta automáticamente cuando termina el juego
ScoreManager.shared.recordGameResult(score: score)
```

### **2. Visualización del High Score**
- Se muestra en la pantalla de Game Over
- Aparece arriba del puntaje actual
- Incluye etiqueta "BEST" para claridad

### **3. Ubicación en la UI**
- **Puntaje Actual**: Sobre el tablero "score.png"
- **Mejor Puntaje**: Arriba del puntaje actual con etiqueta "BEST"

## 🔧 Uso del ScoreManager

### **Acceso al Singleton**
```swift
let scoreManager = ScoreManager.shared
```

### **Propiedades Principales**
```swift
// Mejor puntaje alcanzado
let bestScore = scoreManager.highScore

// Total de juegos jugados
let totalGames = scoreManager.totalGamesPlayed

// Suma acumulada de puntajes
let totalScore = scoreManager.totalScore
```

### **Métodos Principales**
```swift
// Registrar resultado de un juego
scoreManager.recordGameResult(score: 25)

// Verificar si es nuevo récord
let isNewRecord = scoreManager.updateHighScore(30)

// Obtener estadísticas completas
let stats = scoreManager.getScoreStats()

// Resetear todos los puntajes
scoreManager.resetAllScores()
```

## 📊 Estadísticas Disponibles

### **Información Mostrada**
- 🏆 **Mejor Puntaje**: El puntaje más alto alcanzado
- 🎮 **Juegos Jugados**: Total de partidas completadas
- 📈 **Puntaje Total**: Suma acumulada de todos los puntajes
- 📊 **Promedio**: Puntaje promedio por juego

### **Ejemplo de Salida**
```
📊 Estadísticas del Juego:
🏆 Mejor Puntaje: 30
🎮 Juegos Jugados: 8
📈 Puntaje Total: 133
📊 Promedio: 16.6
```

## 💾 Almacenamiento Técnico

### **UserDefaults Keys**
- `"HighScore"`: Mejor puntaje
- `"TotalGamesPlayed"`: Total de juegos
- `"TotalScore"`: Suma acumulada

### **Persistencia**
- Los datos se guardan automáticamente
- Persisten entre sesiones de la app
- Se mantienen al cerrar y abrir el juego
- Se mantienen al reiniciar el dispositivo

## 🧪 Pruebas

### **Archivo de Pruebas**
- **Ubicación**: `WordCraftGame/ScoreTest.swift`
- **Función**: Verificar funcionamiento del sistema

### **Ejecutar Pruebas**
```swift
// En el código del juego
ScoreTest.testScoreManager()

// Resetear puntajes (opcional)
ScoreTest.resetScores()
```

## 🚀 Ventajas del Sistema

### **Para el Jugador**
- ✅ Mantiene sus récords entre sesiones
- ✅ Motivación para superar su mejor puntaje
- ✅ Seguimiento de progreso a largo plazo

### **Para el Desarrollador**
- ✅ Implementación simple y robusta
- ✅ No requiere backend ni base de datos
- ✅ Funciona offline
- ✅ Fácil de mantener y extender

## 🔮 Futuras Mejoras

### **Funcionalidades Adicionales**
- 📅 Historial de puntajes por fecha
- 🏅 Logros y medallas
- 📱 Sincronización con iCloud
- 🎯 Diferentes categorías de puntuación

### **Integración con Game Center**
- Tablas de puntuación globales
- Comparación con amigos
- Logros del sistema

## 📝 Notas de Implementación

### **Archivos Modificados**
1. `Components/Managers/ScoreManager.swift` - Nuevo gestor de puntuación
2. `WordCraftGame/GameScene.swift` - Propiedades del high score
3. `WordCraftGame/Scenes/GameScene+GameOver.swift` - Visualización del high score
4. `WordCraftGame/Scenes/GameScene+Physics.swift` - Registro automático de puntuación

### **Dependencias**
- `Foundation` para UserDefaults
- `GameConfig.ZPosition.UI` para capas visuales
- `ScoreManager.shared` para acceso global

## ✅ Estado del Sistema

- **Status**: ✅ Implementado y funcional
- **Pruebas**: ✅ Incluidas
- **Documentación**: ✅ Completa
- **Integración**: ✅ Completamente integrado en el juego

---

**Desarrollado por**: Isaac Ortiz  
**Fecha**: 7 de Agosto, 2025  
**Versión**: 1.0
