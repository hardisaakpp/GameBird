import SpriteKit

class BackgroundComponent {
    private let scene: SKScene
    var backgroundContainer: SKNode!
    private var backgroundNodes: [Background] = []
    
    init(scene: SKScene) {
        self.scene = scene
        self.backgroundContainer = createBackground()
    }
    
    func createBackground() -> SKNode {
        backgroundContainer = SKNode()
        backgroundNodes.removeAll()
        
        // Crear 3 nodos para asegurar cobertura completa
        for i in 0..<3 {
            let backgroundNode = Background()
            backgroundNode.configure(scene: scene)
            positionBackgroundNode(backgroundNode, index: i)
            backgroundNodes.append(backgroundNode)
            backgroundContainer.addChild(backgroundNode)
        }
        
        startInfiniteMovement()
        return backgroundContainer
    }
    
    private func startInfiniteMovement() {
        let updateAction = SKAction.run { [weak self] in
            self?.updateBackgroundPositions()
        }
        let waitAction = SKAction.wait(forDuration: 1.0/60.0) // 60 FPS
        let sequenceAction = SKAction.sequence([updateAction, waitAction])
        let repeatAction = SKAction.repeatForever(sequenceAction)
        
        backgroundContainer.run(repeatAction, withKey: "infiniteBackgroundScroll")
    }
    
    private func updateBackgroundPositions() {
        let moveSpeed = BackgroundConstants.movementSpeed / 60.0 // Velocidad por frame
        
        for backgroundNode in backgroundNodes {
            // Mover cada nodo hacia la izquierda
            backgroundNode.position.x -= moveSpeed
            
            // Verificar si el nodo ha salido completamente de la pantalla por la izquierda
            let nodeWidth = backgroundNode.size.width
            let leftEdge = backgroundNode.position.x - nodeWidth/2
            
            if leftEdge <= -scene.frame.width/2 - nodeWidth {
                // Encontrar la posición X más a la derecha de todos los nodos
                let rightmostPosition = backgroundNodes.compactMap { node in
                    node != backgroundNode ? node.position.x + node.size.width/2 : nil
                }.max() ?? scene.frame.width/2
                
                // Reposicionar este nodo inmediatamente después del más a la derecha
                backgroundNode.position.x = rightmostPosition + nodeWidth/2
            }
        }
    }
    
    func resetBackgroundColor() {
        backgroundContainer.children.forEach { node in
            if let bgNode = node as? Background {
                bgNode.resetColor()
            }
        }
    }
    
    func changeBackgroundColor(to color: UIColor) {
        // Crear un overlay rojo que cubra toda la pantalla
        let screenOverlay = SKSpriteNode(color: color, size: scene.size)
        screenOverlay.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        screenOverlay.zPosition = 1000 // Poner encima de todo
        screenOverlay.alpha = 0.0
        screenOverlay.name = "redOverlay"
        
        scene.addChild(screenOverlay)
        
        // Hacer el efecto de flash rojo
        let flashSequence = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.1), // Aparecer rápidamente
            SKAction.wait(forDuration: 1.0), // Mantener visible por 1 segundo
            SKAction.fadeAlpha(to: 0.0, duration: 0.3), // Desaparecer gradualmente
            SKAction.removeFromParent() // Eliminar el overlay
        ])
        
        screenOverlay.run(flashSequence)
    }
    
    private func positionBackgroundNode(_ node: Background, index: Int) {
        let nodeWidth = node.size.width
        node.position = CGPoint(
            x: CGFloat(index) * nodeWidth - nodeWidth/2,
            y: scene.frame.midY
        )
    }
    
    func stopMovement() {
        backgroundContainer?.removeAction(forKey: "infiniteBackgroundScroll")
        backgroundContainer?.removeAllActions()
        backgroundContainer?.children.forEach { $0.removeAllActions() }
    }
    
    func reset() {
        // Guardar posición actual antes de resetear
        let currentPosition = backgroundContainer.position
        
        // Limpiar el fondo anterior
        stopMovement()
        backgroundContainer?.removeFromParent()
        
        // Crear nuevo fondo
        backgroundContainer = createBackground()
        backgroundContainer.position = currentPosition
        scene.addChild(backgroundContainer)
    }
}
