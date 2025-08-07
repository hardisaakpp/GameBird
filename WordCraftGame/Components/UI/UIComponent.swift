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
}
