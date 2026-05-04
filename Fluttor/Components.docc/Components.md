# ``Components``

Módulo de componentes de juego para **Fluttor**: entidades SpriteKit (tubos, suelo, fondo, coleccionables), gestores (`PipeManager`, `AudioManager`, `ScoreManager`) y utilidades compartidas con el target principal del juego.

## Overview

Los tipos en `Fluttor/Components` encapsulan la creación y actualización de elementos de escena (por ejemplo pares de tubos, scroll del suelo y fondo) y coordinan comportamiento con los modelos en `Fluttor/Models` y la configuración en `Fluttor/Models/GameConfing.swift` y constantes relacionadas.

Para la documentación del proyecto (arquitectura, escenas, puntuación, citación académica), véase **`Fluttor/docs/README.md`**.

## Topics

### Gestión de escena

- ``PipeComponent``
- ``GroundComponent``
- ``BackgroundComponent``
