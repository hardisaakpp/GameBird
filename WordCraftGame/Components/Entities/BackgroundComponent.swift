import SpriteKit

class BackgroundComponent {
    private let scene: SKScene
    var backgroundContainer: SKNode!
    
    init(scene: SKScene) {
        self.scene = scene
        self.backgroundContainer = createBackground()
    }
    
    func createBackground() -> SKNode {
        backgroundContainer = SKNode()
        
        for i in 0..<2 {
            let backgroundNode = Background()
            backgroundNode.configure(scene: scene)
            positionBackgroundNode(backgroundNode, index: i)
            addMovement(to: backgroundNode)
            backgroundContainer.addChild(backgroundNode)
        }
        
        return backgroundContainer
    }
    
    func resetBackgroundColor() {
        backgroundContainer.children.forEach { node in
            if let bgNode = node as? Background {
                bgNode.resetColor()
            }
        }
    }
    
    func changeBackgroundColor(to color: UIColor) {
        let flashAction = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.backgroundContainer.children.forEach {
                    ($0 as? Background)?.applyTemporaryColor(color)
                }
            },
            SKAction.wait(forDuration: 0.1),
            SKAction.run { [weak self] in
                self?.resetBackgroundColor()
            },
            SKAction.wait(forDuration: 0.1)
        ])
        backgroundContainer.run(flashAction)
    }
    
    private func positionBackgroundNode(_ node: Background, index: Int) {
        node.position = CGPoint(
            x: CGFloat(index) * scene.frame.width,
            y: scene.frame.midY
        )
    }
    
    private func addMovement(to node: Background) {
        let moveAction = createLoopingMovementAction(
            distance: -scene.frame.width,
            movementSpeed: BackgroundConstants.movementSpeed
        )
        node.run(moveAction)
    }
    
    func stopMovement() {
        backgroundContainer?.removeAllActions()
        backgroundContainer?.children.forEach { $0.removeAllActions() }
    }
    
    func reset() {
        // Guardar posición actual antes de resetear
        let currentPosition = backgroundContainer.position
        
        // Limpiar el fondo anterior
        backgroundContainer?.removeAllActions()
        backgroundContainer?.removeFromParent()
        
        // Crear nuevo fondo
        backgroundContainer = createBackground()
        backgroundContainer.position = currentPosition
        scene.addChild(backgroundContainer)
    }
    
    // Helper para movimiento continuo
    private func createLoopingMovementAction(distance: CGFloat, movementSpeed: CGFloat) -> SKAction {
        let moveAction = SKAction.moveBy(x: distance, y: 0, duration: TimeInterval(abs(distance) / movementSpeed))
        return SKAction.repeatForever(moveAction)
    }
}
