# 🍓 Strawberry Asset

## Descripción
Asset de imagen para la fresa en el juego Fluttor. Este elemento puede ser usado como:
- **Recompensa alternativa** a las monedas
- **Power-up especial** con efectos únicos
- **Elemento decorativo** en el juego

## Archivos Requeridos

### Imágenes PNG
- `strawberry.png` - Imagen base (1x)
- `strawberry@2x.png` - Imagen de alta resolución (2x)
- `strawberry@3x.png` - Imagen de ultra alta resolución (3x)

## Especificaciones Recomendadas

### Dimensiones
- **Tamaño base**: 64x64 píxeles
- **Formato**: PNG con transparencia
- **Fondo**: Transparente
- **Estilo**: Pixel art o vectorial consistente con el juego

### Características Visuales
- **Color principal**: Rojo vibrante (#FF6B6B o similar)
- **Detalles**: Hojas verdes en la parte superior
- **Semillas**: Puntos blancos/amarillos en la superficie
- **Estilo**: Consistente con el arte del juego (pixel art)

### Optimización
- **Compresión**: PNG optimizado
- **Tamaño de archivo**: < 50KB por imagen
- **Transparencia**: Canal alpha para integración suave

## Uso en el Juego

### Implementación Sugerida
```swift
// Crear componente de fresa
let strawberry = SKSpriteNode(imageNamed: "strawberry")
strawberry.setScale(0.15) // Ajustar tamaño según necesidad
strawberry.zPosition = GameConfig.ZPosition.background + 6
```

### Valores Sugeridos
- **Puntos**: 2-3 puntos (más que una moneda)
- **Rareza**: Menos frecuente que las monedas
- **Efecto especial**: Posible bonus de velocidad o invencibilidad temporal

## Notas de Desarrollo
- Asegurar que la fresa sea visualmente distintiva de las monedas
- Considerar animaciones específicas (pulso, brillo, etc.)
- Implementar sonido único para la recolección
- Posible efecto visual especial al ser recolectada

## Estado
- ✅ Estructura de directorio creada
- ✅ Contents.json configurado
- ⏳ Imágenes PNG pendientes de agregar
- ⏳ Implementación en el juego pendiente
