# 🍇 Grape Asset

## Descripción
Asset de imagen para la uva en el juego Fluttor. Esta fruta puede ser usada como:
- **Recompensa premium** con efectos especiales únicos
- **Power-up especial** con mecánicas avanzadas
- **Elemento de colección** raro y valioso

## Archivos Requeridos

### Imágenes PNG
- `grape.png` - Imagen base (1x)
- `grape@2x.png` - Imagen de alta resolución (2x)
- `grape@3x.png` - Imagen de ultra alta resolución (3x)

## Especificaciones Recomendadas

### Dimensiones
- **Tamaño base**: 64x64 píxeles
- **Formato**: PNG con transparencia
- **Fondo**: Transparente
- **Estilo**: Pixel art o vectorial consistente con el juego

### Características Visuales
- **Color principal**: Púrpura/violeta (#8B5CF6 o similar)
- **Detalles**: Forma ovalada con textura de uva
- **Estilo**: Consistente con el arte del juego (pixel art)
- **Brillo**: Efecto sutil de frescura

### Optimización
- **Compresión**: PNG optimizado
- **Tamaño de archivo**: < 50KB por imagen
- **Transparencia**: Canal alpha para integración suave

## Uso en el Juego

### Implementación Sugerida
```swift
// Crear componente de uva
let grape = SKSpriteNode(imageNamed: "grape")
grape.setScale(0.12) // Ligeramente más pequeña que las fresas
grape.zPosition = GameConfig.ZPosition.background + 7
```

### Valores Sugeridos
- **Puntos**: 3-5 puntos (más que una fresa)
- **Rareza**: Muy rara (10-15% probabilidad)
- **Efecto especial**: Posible bonus de velocidad o invencibilidad extendida
- **Velocidad**: Más rápida que las fresas (1.6x)

## Diferenciación del Sistema

### Comparación con Otras Recompensas
| **Recompensa** | **Valor** | **Probabilidad** | **Velocidad** | **Efecto** |
|----------------|-----------|------------------|---------------|------------|
| **Moneda** | +1 punto | 70% | Normal (1.0x) | Ninguno |
| **Fresa** | +2 puntos | 30% | Rápida (1.4x) | Crecimiento |
| **Uva** | +3 puntos | 15% | Muy rápida (1.6x) | Efecto especial |

## Notas de Desarrollo
- Asegurar que la uva sea visualmente distintiva de monedas y fresas
- Considerar animaciones específicas (pulso púrpura, brillo especial)
- Implementar sonido único para la recolección
- Posible efecto visual especial al ser recolectada (partículas púrpuras)

## Estado
- ✅ Estructura de directorio creada
- ✅ Contents.json configurado
- ⏳ Imágenes PNG pendientes de agregar
- ⏳ Implementación en el juego pendiente
