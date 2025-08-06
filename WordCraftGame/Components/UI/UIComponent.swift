import SpriteKit
class UIComponent {
    static func createRestartButton(in scene: SKScene) -> SKNode {
        let buttonContainer = SKNode()
        buttonContainer.zPosition = GameConfig.ZPosition.UI
        
        // Fondo del botón
        let buttonBackground = SKShapeNode(
            rect: CGRect(x: -110, y: -30, width: 220, height: 60),
            cornerRadius: 15
        )
        buttonBackground.fillColor = .systemBlue
        buttonBackground.strokeColor = .white
        buttonBackground.lineWidth = 3
        
        // Elementos de texto
        let textShadow = SKLabelNode(text: "REINICIAR")
        textShadow.fontName = "AvenirNext-Bold"
        textShadow.fontSize = 28
        textShadow.fontColor = .black
        textShadow.position = CGPoint(x: 2, y: -2)
        textShadow.alpha = 0.3
        
        let buttonLabel = SKLabelNode(text: "REINICIAR")
        buttonLabel.fontName = "AvenirNext-Bold"
        buttonLabel.fontSize = 28
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
    
    // MARK: - Pause System Components
    
    static func createPauseButton(in scene: SKScene) -> SKNode {
        let buttonContainer = SKNode()
        buttonContainer.zPosition = GameConfig.ZPosition.UI
        
        // Crear un botón de pausa más visible
        let buttonBackground = SKShapeNode(
            rect: CGRect(x: -30, y: -30, width: 60, height: 60),
            cornerRadius: 12
        )
        buttonBackground.fillColor = .white
        buttonBackground.strokeColor = .black
        buttonBackground.lineWidth = 3
        buttonBackground.alpha = 0.9
        
        // Crear el símbolo de pausa (dos barras verticales) más grande y visible
        let pauseSymbol1 = SKShapeNode(rect: CGRect(x: -10, y: -15, width: 6, height: 30))
        pauseSymbol1.fillColor = .black
        pauseSymbol1.strokeColor = .clear
        
        let pauseSymbol2 = SKShapeNode(rect: CGRect(x: 4, y: -15, width: 6, height: 30))
        pauseSymbol2.fillColor = .black
        pauseSymbol2.strokeColor = .clear
        
        [buttonBackground, pauseSymbol1, pauseSymbol2].forEach { node in
            node.name = "pauseButton"
            buttonContainer.addChild(node)
        }
        
        // Mantener la ubicación original del botón de pausa
        buttonContainer.position = CGPoint(
            x: scene.frame.minX + 120,
            y: scene.frame.maxY - 70
        )
        
        return buttonContainer
    }
    
    static func createPauseMenu(in scene: SKScene) -> SKNode {
        let menuContainer = SKNode()
        menuContainer.zPosition = GameConfig.ZPosition.UI + 10
        
        // Fondo semi-transparente que cubre toda la pantalla
        let overlay = SKSpriteNode(color: .black, size: scene.size)
        overlay.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        overlay.alpha = 0.6
        overlay.name = "pauseOverlay"
        menuContainer.addChild(overlay)
        
        // Panel principal del menú
        let menuPanel = SKShapeNode(
            rect: CGRect(x: -150, y: -120, width: 300, height: 240),
            cornerRadius: 20
        )
        menuPanel.fillColor = .white
        menuPanel.strokeColor = .systemBlue
        menuPanel.lineWidth = 4
        menuPanel.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        menuContainer.addChild(menuPanel)
        
        // Título "PAUSADO"
        let titleLabel = SKLabelNode(text: "PAUSADO")
        titleLabel.fontName = "AvenirNext-Bold"
        titleLabel.fontSize = 32
        titleLabel.fontColor = .systemBlue
        titleLabel.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY + 60)
        titleLabel.verticalAlignmentMode = .center
        menuContainer.addChild(titleLabel)
        
        // Botón de reanudar
        let resumeButtonContainer = createResumeButton(in: scene)
        resumeButtonContainer.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        menuContainer.addChild(resumeButtonContainer)
        
        // Botón de reiniciar desde pausa
        let restartFromPauseContainer = createRestartFromPauseButton(in: scene)
        restartFromPauseContainer.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY - 60)
        menuContainer.addChild(restartFromPauseContainer)
        
        return menuContainer
    }
    
    static func createResumeButton(in scene: SKScene) -> SKNode {
        let buttonContainer = SKNode()
        
        let buttonBackground = SKShapeNode(
            rect: CGRect(x: -80, y: -25, width: 160, height: 50),
            cornerRadius: 12
        )
        buttonBackground.fillColor = .systemGreen
        buttonBackground.strokeColor = .white
        buttonBackground.lineWidth = 2
        
        let buttonLabel = SKLabelNode(text: "CONTINUAR")
        buttonLabel.fontName = "AvenirNext-Bold"
        buttonLabel.fontSize = 18
        buttonLabel.fontColor = .white
        buttonLabel.verticalAlignmentMode = .center
        
        [buttonBackground, buttonLabel].forEach { node in
            node.name = "resumeButton"
            buttonContainer.addChild(node)
        }
        
        return buttonContainer
    }
    
    static func createRestartFromPauseButton(in scene: SKScene) -> SKNode {
        let buttonContainer = SKNode()
        
        let buttonBackground = SKShapeNode(
            rect: CGRect(x: -80, y: -25, width: 160, height: 50),
            cornerRadius: 12
        )
        buttonBackground.fillColor = .systemRed
        buttonBackground.strokeColor = .white
        buttonBackground.lineWidth = 2
        
        let buttonLabel = SKLabelNode(text: "REINICIAR")
        buttonLabel.fontName = "AvenirNext-Bold"
        buttonLabel.fontSize = 18
        buttonLabel.fontColor = .white
        buttonLabel.verticalAlignmentMode = .center
        
        [buttonBackground, buttonLabel].forEach { node in
            node.name = "restartFromPauseButton"
            buttonContainer.addChild(node)
        }
        
        return buttonContainer
    }
}
