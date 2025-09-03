# Moon Asset

## Descripción
Este apartado contiene la imagen de la luna para el tema nocturno del juego Fluttor.

## Archivos requeridos
- `moon.png` - Imagen base de la luna (1x)
- `moon@2x.png` - Imagen de alta resolución (2x) - Opcional
- `moon@3x.png` - Imagen de ultra alta resolución (3x) - Opcional

## Especificaciones recomendadas
- **Formato**: PNG con transparencia
- **Tamaño base**: 512x512 píxeles
- **Tamaño @2x**: 1024x1024 píxeles
- **Tamaño @3x**: 1536x1536 píxeles
- **Fondo**: Transparente
- **Colores**: Tonos de gris/blanco para la luna

## Uso en el código
```swift
let moonTexture = SKTexture(imageNamed: "moon")
let moonNode = SKSpriteNode(texture: moonTexture)
```

## Notas
- La imagen debe tener transparencia para integrarse bien con el fondo nocturno
- Considera crear variaciones de la luna (diferentes fases) si es necesario
- Asegúrate de que la luna sea visible contra el fondo nocturno del juego
