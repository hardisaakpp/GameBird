# Sun Asset

## Descripción
Este apartado contiene la imagen del sol para el tema diurno del juego Fluttor.

## Archivos requeridos
- `sun.png` - Imagen base del sol (1x)
- `sun@2x.png` - Imagen de alta resolución (2x) - Opcional
- `sun@3x.png` - Imagen de ultra alta resolución (3x) - Opcional

## Especificaciones recomendadas
- **Formato**: PNG con transparencia
- **Tamaño base**: 512x512 píxeles
- **Tamaño @2x**: 1024x1024 píxeles
- **Tamaño @3x**: 1536x1536 píxeles
- **Fondo**: Transparente
- **Colores**: Tonos de amarillo/naranja para el sol

## Uso en el código
```swift
let sunTexture = SKTexture(imageNamed: "sun")
let sunNode = SKSpriteNode(texture: sunTexture)
```

## Notas
- La imagen debe tener transparencia para integrarse bien con el fondo diurno
- Considera crear variaciones del sol (diferentes intensidades) si es necesario
- Asegúrate de que el sol sea visible contra el fondo diurno del juego
- El sol puede ser interactivo como la luna para cambiar a modo noche
