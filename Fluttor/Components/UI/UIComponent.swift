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
        
        // Elementos de texto (misma fuente/tamaño que los otros: 30pt)
        let textShadow = SKLabelNode(text: "REINICIAR")
        textShadow.fontName = "AvenirNext-Bold"
        textShadow.fontSize = 30
        textShadow.fontColor = .black
        textShadow.position = CGPoint(x: 2, y: -2)
        textShadow.alpha = 0.3
        
        let buttonLabel = SKLabelNode(text: "REINICIAR")
        buttonLabel.fontName = "AvenirNext-Bold"
        buttonLabel.fontSize = 30
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

        // Título
        let title = SKLabelNode(text: "PAUSA")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 40
        title.fontColor = .white
        title.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY + 40)
        title.verticalAlignmentMode = .center
        title.name = "resumeTitle"
        overlay.addChild(title)

        // Texto de indicación para inicio
        let hint = SKLabelNode(text: "Toca para comenzar")
        hint.fontName = "AvenirNext-Medium"
        hint.fontSize = 22
        hint.fontColor = .white.withAlphaComponent(0.9)
        hint.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY - 48)
        hint.verticalAlignmentMode = .center
        hint.name = "resumeHint"
        overlay.addChild(hint)

        // Botón de reanudar
        let buttonContainer = SKNode()
        buttonContainer.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY - 10)
        buttonContainer.name = "resumeButton"

        let bg = SKShapeNode(rectOf: CGSize(width: 240, height: 64), cornerRadius: 18)
        bg.fillColor = .systemGreen  // Verde para reanudar - acción positiva de continuar
        bg.strokeColor = .white
        bg.lineWidth = 3
        bg.name = "resumeButton"
        buttonContainer.addChild(bg)

        let labelShadow = SKLabelNode(text: "REANUDAR")
        labelShadow.fontName = "AvenirNext-Bold"
        labelShadow.fontSize = 30
        labelShadow.fontColor = .black
        labelShadow.position = CGPoint(x: 2, y: -2)
        labelShadow.alpha = 0.3
        labelShadow.verticalAlignmentMode = .center
        labelShadow.name = "resumeButton"
        buttonContainer.addChild(labelShadow)

        let label = SKLabelNode(text: "REANUDAR")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 30
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = "resumeButton"
        buttonContainer.addChild(label)

        overlay.addChild(buttonContainer)

        // Botón de Inicio (mismo estilo) -> Renombrado de texto a REINICIAR
        let startButtonContainer = SKNode()
        startButtonContainer.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY - 90)
        startButtonContainer.name = "startButton"

        let startBg = SKShapeNode(rectOf: CGSize(width: 240, height: 64), cornerRadius: 18)
        startBg.fillColor = .systemRed  // Rojo para reiniciar desde pausa - consistente con game over
        startBg.strokeColor = .white
        startBg.lineWidth = 3
        startBg.name = "startButton"
        startButtonContainer.addChild(startBg)

        let startShadow = SKLabelNode(text: "REINICIAR")
        startShadow.fontName = "AvenirNext-Bold"
        startShadow.fontSize = 30
        startShadow.fontColor = .black
        startShadow.position = CGPoint(x: 2, y: -2)
        startShadow.alpha = 0.3
        startShadow.verticalAlignmentMode = .center
        startShadow.name = "startButton"
        startButtonContainer.addChild(startShadow)

        let startLabel = SKLabelNode(text: "REINICIAR")
        startLabel.fontName = "AvenirNext-Bold"
        startLabel.fontSize = 30
        startLabel.fontColor = .white
        startLabel.verticalAlignmentMode = .center
        startLabel.name = "startButton"
        startButtonContainer.addChild(startLabel)

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
