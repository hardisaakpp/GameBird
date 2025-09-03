# Coin Asset

## Descripción
Este apartado contiene la imagen de la moneda dorada que el pájaro puede recoger como recompensa en el juego Fluttor.

## Archivos requeridos
- `coin.png` - Imagen base de la moneda (1x)
- `coin@2x.png` - Imagen de alta resolución (2x) - Opcional
- `coin@3x.png` - Imagen de ultra alta resolución (3x) - Opcional

## Especificaciones recomendadas
- **Formato**: PNG con transparencia
- **Tamaño base**: 64x64 píxeles
- **Tamaño @2x**: 128x128 píxeles
- **Tamaño @3x**: 192x192 píxeles
- **Fondo**: Transparente
- **Colores**: Dorado brillante con efectos de brillo
- **Estilo**: Circular, con textura metálica

## Uso en el código
```swift
let coinTexture = SKTexture(imageNamed: "coin")
let coinNode = SKSpriteNode(texture: coinTexture)
```

## Mecánicas del juego
- **Valor**: 1 punto por moneda
- **Aparición**: Entre los tubos, en el centro del hueco
- **Frecuencia**: Cada 2-3 tubos aproximadamente
- **Colisión**: Se recoge al tocarla con el pájaro
- **Efecto**: Sonido de "coin" + animación de recolección

## Notas de diseño
- La moneda debe ser claramente visible contra el fondo
- Considera agregar un efecto de brillo o rotación para llamar la atención
- El tamaño debe ser apropiado para que sea fácil de recoger pero no demasiado grande
- Puede tener una ligera animación de flotación para hacerla más atractiva
