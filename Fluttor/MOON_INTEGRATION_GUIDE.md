# 🌙 Guía de Integración de la Luna

## Descripción
La luna se ha integrado exitosamente en el juego Fluttor como un elemento visual que aparece automáticamente durante las horas nocturnas.

## Características Implementadas

### 1. **Sistema Automático de Día/Noche**
- La luna aparece automáticamente entre las **18:30 y 05:50**
- Se oculta durante el día (06:00 a 18:29)
- Sincronización automática con el sistema de fondos día/noche

### 2. **Posicionamiento Inteligente**
- **Posición**: Esquina superior derecha (35% desde el borde derecho, 75% desde abajo)
- **Z-Position**: Detrás de las tuberías (`GameConfig.ZPosition.background + 5`)
- **Tamaño**: 120 píxeles de ancho (escalado automáticamente)

### 3. **Animaciones Suaves**
- **Flotación**: Movimiento vertical suave (8 píxeles arriba/abajo en 3 segundos)
- **Brillo**: Efecto de parpadeo sutil (alpha 0.8 a 1.0 en 2 segundos)
- **Resplandor**: Efecto de halo opcional (escalado 0.8 a 1.2)

### 4. **Integración con el Sistema Existente**
- Se actualiza automáticamente cuando cambia el tamaño de la escena
- Sincronizado con el sistema de día/noche del pájaro
- Compatible con todos los estados del juego (pausa, game over, etc.)

### 5. **Efecto Visual Atmosférico**
- **Detrás de las tuberías**: La luna aparece como elemento de fondo atmosférico
- **Profundidad visual**: Crea sensación de profundidad en el escenario
- **No interfiere**: Las tuberías pasan por delante sin obstruir la jugabilidad

### 6. **Interactividad Mágica** ✨
- **Toque para cambiar a día**: Al tocar la luna, se fuerza el modo día por 5 minutos
- **Cooldown**: 2 segundos entre toques para evitar spam
- **Feedback visual**: Efecto de pulso y brillo al tocar
- **Duración temporal**: El modo día forzado dura 5 minutos, luego vuelve al horario normal

## Jerarquía de Capas Visuales (Z-Position)

```
Z-Position = 9999  →  UI (botones, overlays)
Z-Position = 30    →  Pájaro
Z-Position = 20    →  Tuberías
Z-Position = 10    →  Suelo
Z-Position = 5     →  🌙 LUNA (detrás de tuberías, encima del fondo)
Z-Position = 0     →  Fondo
```

**Resultado**: La luna aparece como un elemento atmosférico de fondo, creando profundidad visual mientras las tuberías pasan por delante.

## ⚠️ Problema Encontrado y Corregido

**Problema**: Las tuberías no tenían Z-Position asignada, por lo que usaban el valor por defecto (0), igual que el fondo.

**Solución**: Se agregó `pipePair.zPosition = GameConfig.ZPosition.pipes` en `PipeComponent.swift` para asegurar que las tuberías estén en Z = 20.

**Antes**: Tuberías en Z = 0 (mismo que fondo) → Luna aparecía por delante
**Después**: Tuberías en Z = 20 → Luna correctamente detrás de las tuberías

## Archivos Modificados

### Nuevos Archivos:
- `Components/Entities/MoonComponent.swift` - Componente principal de la luna
- `FluttorGame/Assets.xcassets/moon.imageset/` - Asset de la imagen de la luna

### Archivos Modificados:
- `FluttorGame/GameScene.swift` - Agregada propiedad `moonComponent`
- `FluttorGame/Scenes/GameScene+Setup.swift` - Inicialización del componente
- `FluttorGame/Scenes/GameScene+DayNight.swift` - Sincronización día/noche + método `forceDayMode()`
- `FluttorGame/Scenes/GameScene+Lifecycle.swift` - Reposicionamiento automático
- `FluttorGame/Scenes/GameScene+Input.swift` - **NUEVO**: Detección de toque en la luna
- `Components/Entities/PipeComponent.swift` - **CORREGIDO**: Agregada Z-Position a las tuberías
- `Utilities/BackgroundConstants.swift` - **NUEVO**: Sistema de modo día forzado + import QuartzCore
- `Components/Entities/BackgroundComponent.swift` - **MODIFICADO**: Método `applyCurrentBackgroundTexture()` hecho público

## Uso en el Código

### Acceso Básico:
```swift
// Mostrar/ocultar manualmente
moonComponent.setVisible(true)
moonComponent.setVisible(false)

// Actualizar según hora actual
moonComponent.updateForDayNight()

// Reposicionar (automático en cambio de tamaño)
moonComponent.updatePosition()
```

### Efectos Especiales:
```swift
// Agregar efecto de resplandor
moonComponent.addGlowEffect()

// Remover efecto de resplandor
moonComponent.removeGlowEffect()

// Controlar interactividad
moonComponent.setInteractive(true)  // Habilitar toque
moonComponent.setInteractive(false) // Deshabilitar toque
```

### Modo Día Forzado:
```swift
// Forzar modo día por 5 minutos
BackgroundConstants.forceDayMode(duration: 300)

// Verificar si está en modo día forzado
let isForced = BackgroundConstants.isForcedDayMode()

// Cancelar modo día forzado
BackgroundConstants.cancelForcedDayMode()
```

## Configuración Personalizable

### En `MoonComponent.swift`:
```swift
// Tamaño de la luna
private let moonSize: CGFloat = 120

// Posicionamiento (porcentajes del frame)
private let moonOffsetX: CGFloat = 0.35 // 35% desde la derecha
private let moonOffsetY: CGFloat = 0.75 // 75% desde abajo

// Z-Position
private let moonZPosition: CGFloat = GameConfig.ZPosition.background + 5
```

## Próximos Pasos

1. **Reemplazar la imagen**: Coloca tu imagen de luna en `moon.imageset/moon.png`
2. **Ajustar tamaño**: Modifica `moonSize` si es necesario
3. **Personalizar posición**: Ajusta `moonOffsetX` y `moonOffsetY`
4. **Probar en diferentes dispositivos**: Verificar que se vea bien en todas las resoluciones

## Notas Técnicas

- La luna se crea pero no se agrega a la escena hasta que se llama `showMoon()`
- Las animaciones se detienen automáticamente cuando se oculta
- El componente es compatible con el sistema de pausa del juego
- No interfiere con la física ni la lógica del juego

## Troubleshooting

### La luna no aparece:
1. Verificar que la imagen `moon.png` existe en el asset
2. Comprobar que la hora actual está en rango nocturno (18:30-05:50)
3. Verificar que `moonComponent.updateForDayNight()` se llama

### La luna aparece en el lugar incorrecto:
1. Ajustar `moonOffsetX` y `moonOffsetY` en `MoonComponent.swift`
2. Verificar que `updatePosition()` se llama en `didChangeSize`

### Animaciones no funcionan:
1. Verificar que `startAnimations()` se llama en `showMoon()`
2. Comprobar que no hay conflictos con otras animaciones
