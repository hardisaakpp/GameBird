import SpriteKit
class UIComponent {
    static func createRestartButton(in scene: SKScene) -> SKNode {
        let buttonContainer = SKNode()
        buttonContainer.zPosition = GameConfig.ZPosition.UI
        
        // Fondo del botón (mismo tamaño que los otros: 240x64, radio 18)
        let buttonBackground = SKShapeNode(
            rectOf: CGSize(width: 240, height: 64),
            cornerRadius: 18
        )
        buttonBackground.fillColor = .systemRed  // Rojo para Game Over - acción de reiniciar
        buttonBackground.strokeColor = .white
        buttonBackground.lineWidth = 3
        
        // Elementos de texto con fuente pixel art
        let textShadow = SKLabelNode(text: "REINICIAR")
        textShadow.fontName = FontConstants.GameUI.buttonFont
        textShadow.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.buttonFontSize, fontName: FontConstants.GameUI.buttonFont)
        textShadow.fontColor = .black
        textShadow.position = CGPoint(x: 2, y: -2)
        textShadow.alpha = 0.3
        
        let buttonLabel = SKLabelNode(text: "REINICIAR")
        buttonLabel.fontName = FontConstants.GameUI.buttonFont
        buttonLabel.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.buttonFontSize, fontName: FontConstants.GameUI.buttonFont)
        buttonLabel.fontColor = .white
        
        // Configuración común con tipo explícito
        [buttonBackground, textShadow, buttonLabel].forEach { node in
            let skNode = node as SKNode
            skNode.name = "restartButton"
            
            // Solo aplicar alignment a nodos de texto
            if let labelNode = skNode as? SKLabelNode {
                labelNode.verticalAlignmentMode = .center
            }
            
            buttonContainer.addChild(skNode)
        }
        
        // Posicionamiento y animación
        buttonContainer.position = CGPoint(
            x: scene.frame.midX,
            y: scene.frame.midY
        )
        buttonContainer.alpha = 0.0
        
        let hover = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.8),
            SKAction.scale(to: 0.95, duration: 0.8)
        ])
        buttonContainer.run(SKAction.repeatForever(hover))
        
        return buttonContainer
    }

    /// Botón circular azul con una casita para volver a la pantalla de inicio (selección de nivel).
    /// Todos los nodos llevan `name` para que `nodes(at:)` lo detecte al tocar cualquier parte.
    static func createLevelSelectButton(named name: String) -> SKNode {
        let container = SKNode()
        container.name = name
        container.zPosition = GameConfig.ZPosition.UI

        let radius: CGFloat = 34
        let shadow = SKShapeNode(circleOfRadius: radius)
        shadow.fillColor = UIColor.black.withAlphaComponent(0.3)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 2, y: -3)

        let background = SKShapeNode(circleOfRadius: radius)
        background.fillColor = .systemBlue
        background.strokeColor = .white
        background.lineWidth = 3

        // Casita: techo triangular + cuerpo
        let housePath = UIBezierPath()
        housePath.move(to: CGPoint(x: -24, y: 2))
        housePath.addLine(to: CGPoint(x: 0, y: 24))
        housePath.addLine(to: CGPoint(x: 24, y: 2))
        housePath.addLine(to: CGPoint(x: 16, y: 2))
        housePath.addLine(to: CGPoint(x: 16, y: -18))
        housePath.addLine(to: CGPoint(x: -16, y: -18))
        housePath.addLine(to: CGPoint(x: -16, y: 2))
        housePath.close()
        let house = SKShapeNode(path: housePath.cgPath)
        house.fillColor = .white
        house.strokeColor = .white
        house.lineWidth = 2
        house.lineJoin = .round

        // Puerta
        let door = SKShapeNode(rect: CGRect(x: -5, y: -18, width: 10, height: 16), cornerRadius: 2)
        door.fillColor = .systemBlue
        door.strokeColor = .clear

        let hitArea = SKSpriteNode(color: .clear, size: CGSize(width: 72, height: 72))

        [shadow, background, house, door, hitArea].forEach { node in
            node.name = name
            container.addChild(node)
        }
        return container
    }

    static func createPauseButton(in scene: SKScene) -> SKNode {
        let container = SKNode()
        container.name = "pauseButton"
        container.zPosition = GameConfig.ZPosition.UI

        // Aumentar objetivo táctil (área invisible)
        let hitArea = SKSpriteNode(color: .clear, size: CGSize(width: 56, height: 56))
        hitArea.name = "pauseButton"
        container.addChild(hitArea)

        // Fondo circular (más grande y con alto contraste)
        let radius: CGFloat = 32
        // Sombra suave para contraste
        let shadow = SKShapeNode(circleOfRadius: radius + 3)
        shadow.fillColor = UIColor.black.withAlphaComponent(0.35)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0, y: -2)
        shadow.name = "pauseButton"
        container.addChild(shadow)

        let circle = SKShapeNode(circleOfRadius: radius)
        circle.fillColor = .white
        circle.strokeColor = .black
        circle.lineWidth = 4
        circle.name = "pauseButton"
        container.addChild(circle)

        // Icono de pausa (dos barras)
        let barWidth: CGFloat = 8
        let barHeight: CGFloat = 24
        let leftBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 2)
        leftBar.fillColor = .black
        leftBar.strokeColor = .clear
        leftBar.position = CGPoint(x: -10, y: 0)
        leftBar.name = "pauseButton"
        container.addChild(leftBar)

        let rightBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 2)
        rightBar.fillColor = .black
        rightBar.strokeColor = .clear
        rightBar.position = CGPoint(x: 10, y: 0)
        rightBar.name = "pauseButton"
        container.addChild(rightBar)

        return container
    }

    static func createResumeOverlay(in scene: SKScene) -> SKNode {
        let overlay = SKNode()
        overlay.zPosition = GameConfig.ZPosition.UI + 1
        overlay.name = "resumeOverlay"

        // Capa semitransparente
        let dim = SKSpriteNode(color: .black.withAlphaComponent(0.65), size: scene.frame.size)
        dim.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        dim.name = "resumeOverlay"
        overlay.addChild(dim)

        // Título con fuente pixel art
        let title = SKLabelNode(text: "PAUSA")
        title.fontName = FontConstants.GameUI.titleFont
        title.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.titleFontSize, fontName: FontConstants.GameUI.titleFont)
        title.fontColor = .white
        title.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY + 40)
        title.verticalAlignmentMode = .center
        title.name = "resumeTitle"
        overlay.addChild(title)

        // Texto de indicación para inicio con fuente pixel art
        let hint = SKLabelNode(text: "Toca para comenzar")
        hint.fontName = FontConstants.GameUI.hintFont
        hint.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.hintFontSize, fontName: FontConstants.GameUI.hintFont)
        hint.fontColor = .white.withAlphaComponent(0.9)
        hint.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY - 48)
        hint.verticalAlignmentMode = .center
        hint.name = "resumeHint"
        overlay.addChild(hint)

        // Botón de reanudar - Ahora usando imagen Play.png
        let buttonContainer = SKNode()
        buttonContainer.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY - 10)
        buttonContainer.name = "resumeButton"

        // Usar la imagen Play.png en lugar del botón de texto
        let playButton = SKSpriteNode(imageNamed: "Play")
        playButton.name = "resumeButton"
        
        // Ajustar tamaño de la imagen para que sea apropiado
        let targetWidth: CGFloat = 120  // Ancho objetivo del botón
        let targetHeight: CGFloat = 120  // Alto objetivo del botón
        
        if playButton.size.width > 0 {
            let scaleX = targetWidth / playButton.size.width
            let scaleY = targetHeight / playButton.size.height
            let scale = min(scaleX, scaleY)  // Mantener proporción
            playButton.setScale(scale)
        }
        
        // Agregar efecto de sombra para mejor visibilidad
        let shadow = SKSpriteNode(imageNamed: "Play")
        shadow.name = "resumeButton"
        shadow.setScale(playButton.xScale)
        shadow.position = CGPoint(x: 2, y: -2)
        shadow.alpha = 0.3
        shadow.color = .black
        shadow.colorBlendFactor = 1.0
        
        buttonContainer.addChild(shadow)
        buttonContainer.addChild(playButton)
        
        // Agregar área táctil invisible para mantener la funcionalidad
        let touchArea = SKSpriteNode(color: .clear, size: CGSize(width: targetWidth, height: targetHeight))
        touchArea.name = "resumeButton"
        buttonContainer.addChild(touchArea)

        overlay.addChild(buttonContainer)

        // Botón de Inicio (mismo estilo) -> Renombrado de texto a REINICIAR
        let startButtonContainer = SKNode()
        startButtonContainer.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY - 126)
        startButtonContainer.name = "startButton"

        // Usar la imagen restart.png en lugar del botón de texto
        let restartButton = SKSpriteNode(imageNamed: "Restart")
        restartButton.name = "startButton"
        
        // Ajustar tamaño de la imagen para que sea apropiado
        let restartTargetWidth: CGFloat = 150  // Ancho objetivo del botón
        let restartTargetHeight: CGFloat = 150  // Alto objetivo del botón
        
        if restartButton.size.width > 0 {
            let scaleX = restartTargetWidth / restartButton.size.width
            let scaleY = restartTargetHeight / restartButton.size.height
            let scale = min(scaleX, scaleY)  // Mantener proporción
            restartButton.setScale(scale)
        }
        
        // Agregar efecto de sombra para mejor visibilidad
        let restartShadow = SKSpriteNode(imageNamed: "Restart")
        restartShadow.name = "startButton"
        restartShadow.setScale(restartButton.xScale)
        restartShadow.position = CGPoint(x: 2, y: -2)
        restartShadow.alpha = 0.3
        restartShadow.color = .black
        restartShadow.colorBlendFactor = 1.0
        
        startButtonContainer.addChild(restartShadow)
        startButtonContainer.addChild(restartButton)
        
        // Agregar área táctil invisible para mantener la funcionalidad
        let restartTouchArea = SKSpriteNode(color: .clear, size: CGSize(width: restartTargetWidth, height: restartTargetHeight))
        restartTouchArea.name = "startButton"
        startButtonContainer.addChild(restartTouchArea)

        overlay.addChild(startButtonContainer)

        // Botón casita: vuelve a la pantalla de selección de nivel (solo visible en pausa)
        let levelSelectButton = createLevelSelectButton(named: "pauseLevelSelectButton")
        levelSelectButton.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY - 234)
        overlay.addChild(levelSelectButton)

        // Mensaje de inicio (imagen de Assets: UI-Message)
        let startMessage = SKSpriteNode(imageNamed: "UI-Message")
        startMessage.name = "startMessage"
        startMessage.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        startMessage.zPosition = 2
        // Aumentar tamaño: ocupar hasta el 90% del ancho y permitir ampliar hasta 2x
        if startMessage.size.width > 0 {
            let targetWidth = scene.frame.width * 0.9
            let scale = targetWidth / startMessage.size.width
            let maxUpscale: CGFloat = 2.0
            startMessage.setScale(min(scale, maxUpscale))
        }
        startMessage.isHidden = true // Solo visible en la pausa inicial
        overlay.addChild(startMessage)

        return overlay
    }

    // MARK: - Oferta de cambio de modo
    /// Pantalla que se muestra al llegar al puntaje umbral en modo BÁSICO.
    static func createModeUpgradeOverlay(in scene: SKScene, score: Int) -> SKNode {
        let overlay = SKNode()
        overlay.zPosition = GameConfig.ZPosition.UI + 100
        overlay.name = "modeUpgradeOverlay"

        let dim = SKSpriteNode(color: .black.withAlphaComponent(0.7), size: scene.frame.size)
        dim.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        dim.name = "modeUpgradeDim"
        overlay.addChild(dim)

        let maxWidth = scene.frame.width * 0.85
        func fit(_ label: SKLabelNode, to width: CGFloat) {
            if label.frame.width > width { label.fontSize *= width / label.frame.width }
        }

        let title = SKLabelNode(text: "¡\(score) PUNTOS!")
        title.fontName = FontConstants.GameUI.titleFont
        title.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.titleFontSize, fontName: FontConstants.GameUI.titleFont)
        title.fontColor = .systemYellow
        title.verticalAlignmentMode = .center
        title.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY + 150)
        title.name = "modeUpgradeTitle"
        fit(title, to: maxWidth)
        overlay.addChild(title)

        let subtitle = SKLabelNode(text: "¿Quieres más reto?")
        subtitle.fontName = FontConstants.GameUI.hintFont
        subtitle.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.hintFontSize, fontName: FontConstants.GameUI.hintFont)
        subtitle.fontColor = .white
        subtitle.verticalAlignmentMode = .center
        subtitle.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY + 85)
        subtitle.name = "modeUpgradeSubtitle"
        fit(subtitle, to: maxWidth)
        overlay.addChild(subtitle)

        func makeButton(text: String, color: UIColor, name: String, y: CGFloat) -> SKNode {
            let container = SKNode()
            container.name = name
            container.position = CGPoint(x: scene.frame.midX, y: y)
            let bg = SKShapeNode(rectOf: CGSize(width: 300, height: 64), cornerRadius: 18)
            bg.fillColor = color
            bg.strokeColor = .white
            bg.lineWidth = 3
            let label = SKLabelNode(text: text)
            label.fontName = FontConstants.GameUI.buttonFont
            label.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.buttonFontSize, fontName: FontConstants.GameUI.buttonFont)
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            fit(label, to: 270)
            [bg, label].forEach { node in
                node.name = name
                container.addChild(node)
            }
            return container
        }

        overlay.addChild(makeButton(text: "PASAR A \(GameMode.normal.displayName)", color: .systemTeal, name: "modeSwitchNormal", y: scene.frame.midY - 10))
        overlay.addChild(makeButton(text: "SEGUIR EN \(GameMode.basic.displayName)", color: .systemGreen, name: "modeKeepBasic", y: scene.frame.midY - 100))

        let note = SKLabelNode(text: "Tu puntaje se conserva")
        note.fontName = FontConstants.GameUI.hintFont
        note.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.hintFontSize * 0.7, fontName: FontConstants.GameUI.hintFont)
        note.fontColor = .white.withAlphaComponent(0.7)
        note.verticalAlignmentMode = .center
        note.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY - 175)
        note.name = "modeUpgradeNote"
        overlay.addChild(note)

        return overlay
    }

    // MARK: - Variante de BÁSICO
    /// Elección DINÁMICO / ENTRENAMIENTO que aparece sobre la pantalla de bienvenida.
    static func createBasicVariantOverlay(in scene: SKScene, backButtonPosition: CGPoint) -> SKNode {
        let overlay = SKNode()
        // Muy por encima de la bienvenida (sus hijos llegan a UI + 12) para que el fondo oscuro los cubra
        overlay.zPosition = GameConfig.ZPosition.UI + 100
        overlay.name = "basicVariantOverlay"

        let dim = SKSpriteNode(color: .black.withAlphaComponent(0.8), size: scene.frame.size)
        dim.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        dim.name = "basicVariantDim"
        overlay.addChild(dim)

        func fit(_ label: SKLabelNode, to width: CGFloat) {
            if label.frame.width > width { label.fontSize *= width / label.frame.width }
        }
        func makeLabel(_ text: String, font: String, size: CGFloat, color: UIColor, y: CGFloat) -> SKLabelNode {
            let label = SKLabelNode(text: text)
            label.fontName = font
            label.fontSize = FontConstants.getAdaptiveFontSize(for: size, fontName: font)
            label.fontColor = color
            label.verticalAlignmentMode = .center
            label.position = CGPoint(x: scene.frame.midX, y: y)
            fit(label, to: scene.frame.width * 0.85)
            return label
        }

        overlay.addChild(makeLabel(GameMode.basic.displayName, font: FontConstants.GameUI.titleFont,
                                   size: FontConstants.GameUI.titleFontSize, color: .systemGreen, y: scene.frame.midY + 170))
        overlay.addChild(makeLabel("Elige cómo quieres jugar", font: FontConstants.GameUI.hintFont,
                                   size: FontConstants.GameUI.hintFontSize, color: .white, y: scene.frame.midY + 105))

        func makeOption(title: String, detail: String, color: UIColor, name: String, y: CGFloat) {
            let container = SKNode()
            container.name = name
            container.position = CGPoint(x: scene.frame.midX, y: y)
            let bg = SKShapeNode(rectOf: CGSize(width: 300, height: 64), cornerRadius: 18)
            bg.fillColor = color
            bg.strokeColor = .white
            bg.lineWidth = 3
            let label = SKLabelNode(text: title)
            label.fontName = FontConstants.GameUI.buttonFont
            label.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.buttonFontSize, fontName: FontConstants.GameUI.buttonFont)
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            fit(label, to: 270)
            let hit = SKSpriteNode(color: .clear, size: CGSize(width: 300, height: 100))
            [bg, label, hit].forEach { node in
                node.name = name
                container.addChild(node)
            }
            let hint = SKLabelNode(text: detail)
            hint.fontName = FontConstants.GameUI.hintFont
            hint.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.hintFontSize * 0.65, fontName: FontConstants.GameUI.hintFont)
            hint.fontColor = .white.withAlphaComponent(0.75)
            hint.verticalAlignmentMode = .center
            hint.position = CGPoint(x: 0, y: -50)
            hint.name = name
            fit(hint, to: scene.frame.width * 0.85)
            container.addChild(hint)
            overlay.addChild(container)
        }

        makeOption(title: "DINÁMICO", detail: "A los 20 puntos puedes subir a INTERMEDIO",
                   color: .systemOrange, name: "basicDynamic", y: scene.frame.midY + 20)
        makeOption(title: "ENTRENAMIENTO", detail: "Practica sin cambios de modo",
                   color: .systemGreen, name: "basicTraining", y: scene.frame.midY - 110)

        // Botón de regreso: esquina superior izquierda (estándar iOS), circular con flecha
        let radius: CGFloat = 28
        let back = SKNode()
        back.name = "basicBack"
        back.position = backButtonPosition
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.fillColor = UIColor.white.withAlphaComponent(0.18)
        circle.strokeColor = .white
        circle.lineWidth = 3
        let chevronPath = UIBezierPath()
        chevronPath.move(to: CGPoint(x: 6, y: 14))
        chevronPath.addLine(to: CGPoint(x: -6, y: 0))
        chevronPath.addLine(to: CGPoint(x: 6, y: -14))
        let chevron = SKShapeNode(path: chevronPath.cgPath)
        chevron.strokeColor = .white
        chevron.lineWidth = 5
        chevron.lineCap = .round
        chevron.lineJoin = .round
        let backHit = SKSpriteNode(color: .clear, size: CGSize(width: 64, height: 64))
        [circle, chevron, backHit].forEach { node in
            node.name = "basicBack"
            back.addChild(node)
        }
        overlay.addChild(back)

        return overlay
    }
}
