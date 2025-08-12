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
        startButtonContainer.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY - 90)
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
}
