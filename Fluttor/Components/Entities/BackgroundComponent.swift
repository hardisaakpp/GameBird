import SpriteKit

class BackgroundComponent {
    private let scene: SKScene
    var backgroundContainer: SKNode!
    private var backgroundNodes: [Background] = []
    private var dayNightTimer: Timer?
    
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
        
        // Verificar y corregir posicionamiento inicial
        DispatchQueue.main.async { [weak self] in
            self?.ensureSeamlessCoverage()
        }
        
        startInfiniteMovement()
        startDayNightAutoUpdate()
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
                
                // Reposicionar este nodo exactamente donde debe estar para evitar gaps
                // Usar un overlap más agresivo para asegurar cobertura completa
                let aggressiveOverlap: CGFloat = 5.0
                backgroundNode.position.x = rightmostPosition + aggressiveOverlap
            }
        }
        
        // Verificación adicional: asegurar que no haya gaps visibles
        ensureSeamlessCoverage()
    }
    
    private func ensureSeamlessCoverage() {
        // Ordenar nodos por posición X
        let sortedNodes = backgroundNodes.sorted { $0.position.x < $1.position.x }
        
        // Verificar que el primer nodo cubra completamente el lado izquierdo
        if let firstNode = sortedNodes.first {
            let firstNodeLeftEdge = firstNode.position.x - firstNode.size.width/2
            if firstNodeLeftEdge > -scene.frame.width/2 {
                // Mover el primer nodo para cubrir completamente el lado izquierdo
                firstNode.position.x = -scene.frame.width/2 + firstNode.size.width/2
            }
        }
        
        // Verificar que el último nodo cubra completamente el lado derecho
        if let lastNode = sortedNodes.last {
            let lastNodeRightEdge = lastNode.position.x + lastNode.size.width/2
            if lastNodeRightEdge < scene.frame.width/2 {
                // Mover el último nodo para cubrir completamente el lado derecho
                lastNode.position.x = scene.frame.width/2 - lastNode.size.width/2
            }
        }
        
        // Verificar que no haya gaps entre nodos consecutivos
        for i in 0..<sortedNodes.count - 1 {
            let currentNode = sortedNodes[i]
            let nextNode = sortedNodes[i + 1]
            
            let currentRightEdge = currentNode.position.x + currentNode.size.width/2
            let nextLeftEdge = nextNode.position.x - nextNode.size.width/2
            
            // Si hay un gap, cerrarlo moviendo el siguiente nodo
            if nextLeftEdge > currentRightEdge {
                let gap = nextLeftEdge - currentRightEdge
                nextNode.position.x -= gap
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
        // Crear un overlay rojo intenso que refleje una colisión
        let collisionColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0) // Rojo puro e intenso
        let screenOverlay = SKSpriteNode(color: collisionColor, size: scene.size)
        screenOverlay.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        screenOverlay.zPosition = 1000 // Poner encima de todo
        screenOverlay.alpha = 0.0
        screenOverlay.name = "collisionOverlay"
        
        scene.addChild(screenOverlay)
        
        // Hacer el efecto de flash rojo más dramático para colisión
        let flashSequence = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.8, duration: 0.05), // Aparecer muy rápido y más intenso
            SKAction.wait(forDuration: 0.15), // Flash inicial corto
            SKAction.fadeAlpha(to: 0.5, duration: 0.1), // Reducir un poco
            SKAction.wait(forDuration: 0.8), // Mantener visible por más tiempo
            SKAction.fadeAlpha(to: 0.0, duration: 0.4), // Desaparecer más lentamente
            SKAction.removeFromParent() // Eliminar el overlay
        ])
        
        screenOverlay.run(flashSequence)
    }
    
    private func positionBackgroundNode(_ node: Background, index: Int) {
        let nodeWidth = node.size.width
        // Posicionar las imágenes con overlap para asegurar cobertura completa
        let overlap: CGFloat = 10.0 // Overlap más agresivo para eliminar gaps
        node.position = CGPoint(
            x: CGFloat(index) * (nodeWidth - overlap),
            y: scene.frame.midY
        )
    }
    
    func stopMovement() {
        backgroundContainer?.removeAction(forKey: "infiniteBackgroundScroll")
        backgroundContainer?.removeAllActions()
        backgroundContainer?.children.forEach { $0.removeAllActions() }
    }
    
    func startMovement() {
        // Reiniciar el movimiento infinito del fondo
        startInfiniteMovement()
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

    // MARK: - Day/Night
    private func startDayNightAutoUpdate() {
        dayNightTimer?.invalidate()
        // Chequear cada minuto para cambios de franja
        dayNightTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.applyCurrentBackgroundTexture()
        }
        // Aplicar inmediatamente por si cambia al entrar
        applyCurrentBackgroundTexture()
    }

    func applyCurrentBackgroundTexture() {
        let textureName = BackgroundConstants.textureName
        let newTexture = SKTexture(imageNamed: textureName)
        newTexture.filteringMode = .linear

        // Fade crossfade entre texturas para transición suave
        let duration: TimeInterval = 0.5
        for node in backgroundNodes {
            // Añadir overlay temporal para crossfade si ya tiene textura
            if node.texture != nil {
                let overlay = SKSpriteNode(texture: newTexture, size: node.size)
                overlay.position = .zero
                overlay.anchorPoint = node.anchorPoint
                overlay.alpha = 0.0
                overlay.zPosition = node.zPosition + 0.5
                node.addChild(overlay)
                overlay.run(SKAction.sequence([
                    SKAction.fadeAlpha(to: 1.0, duration: duration),
                    SKAction.run { [weak node] in node?.texture = newTexture },
                    SKAction.removeFromParent()
                ]))
            } else {
                node.texture = newTexture
            }
        }
        // Avisar al pájaro para cambiar de color si aplica
        if let scene = scene as? GameScene {
            scene.updateBirdAppearanceForDayNight()
        }
    }
}
