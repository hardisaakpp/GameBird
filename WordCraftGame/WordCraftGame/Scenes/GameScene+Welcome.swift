import SpriteKit

// MARK: - Pantalla de Bienvenida
extension GameScene {
    
    func createWelcomeOverlay() -> SKNode {
        let overlay = SKNode()
        overlay.zPosition = GameConfig.ZPosition.UI + 2  // Por encima de otros overlays
        overlay.name = "welcomeOverlay"
        
        // Capa semitransparente
        let dim = SKSpriteNode(color: .black.withAlphaComponent(0.7), size: self.frame.size)
        dim.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        dim.name = "welcomeDim"
        overlay.addChild(dim)
        
        // Título principal
        let title = SKLabelNode(text: "¡BIENVENIDO!")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 48
        title.fontColor = .white
        title.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 120)
        title.verticalAlignmentMode = .center
        title.name = "welcomeTitle"
        overlay.addChild(title)
        
        // Subtítulo
        let subtitle = SKLabelNode(text: "WordCraft Game")
        subtitle.fontName = "AvenirNext-Medium"
        subtitle.fontSize = 28
        subtitle.fontColor = .systemYellow
        subtitle.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 70)
        subtitle.verticalAlignmentMode = .center
        subtitle.name = "welcomeSubtitle"
        overlay.addChild(subtitle)
        
        // Descripción del juego
        let description = SKLabelNode(text: "Ayuda al pájaro a volar")
        description.fontName = "AvenirNext-Regular"
        description.fontSize = 22
        description.fontColor = .white.withAlphaComponent(0.9)
        description.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 20)
        description.verticalAlignmentMode = .center
        description.name = "welcomeDescription"
        overlay.addChild(description)
        
        let description2 = SKLabelNode(text: "evitando las tuberías")
        description2.fontName = "AvenirNext-Regular"
        description2.fontSize = 22
        description2.fontColor = .white.withAlphaComponent(0.9)
        description2.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 10)
        description2.verticalAlignmentMode = .center
        description2.name = "welcomeDescription2"
        overlay.addChild(description2)
        
        // Botón de comenzar
        let startButtonContainer = SKNode()
        startButtonContainer.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 80)
        startButtonContainer.name = "welcomeStartButton"
        
        let startBg = SKShapeNode(rectOf: CGSize(width: 280, height: 70), cornerRadius: 20)
        startBg.fillColor = .systemGreen
        startBg.strokeColor = .white
        startBg.lineWidth = 4
        startBg.name = "welcomeStartButton"
        startButtonContainer.addChild(startBg)
        
        let startShadow = SKLabelNode(text: "COMENZAR")
        startShadow.fontName = "AvenirNext-Bold"
        startShadow.fontSize = 32
        startShadow.fontColor = .black
        startShadow.position = CGPoint(x: 2, y: -2)
        startShadow.alpha = 0.3
        startShadow.verticalAlignmentMode = .center
        startShadow.name = "welcomeStartButton"
        startButtonContainer.addChild(startShadow)
        
        let startLabel = SKLabelNode(text: "COMENZAR")
        startLabel.fontName = "AvenirNext-Bold"
        startLabel.fontSize = 32
        startLabel.fontColor = .white
        startLabel.verticalAlignmentMode = .center
        startLabel.name = "welcomeStartButton"
        startButtonContainer.addChild(startLabel)
        
        overlay.addChild(startButtonContainer)
        
        // Indicación para tocar
        let tapHint = SKLabelNode(text: "Toca COMENZAR para ver las instrucciones")
        tapHint.fontName = "AvenirNext-Medium"
        tapHint.fontSize = 18
        tapHint.fontColor = .white.withAlphaComponent(0.7)
        tapHint.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 140)
        tapHint.verticalAlignmentMode = .center
        tapHint.name = "welcomeTapHint"
        overlay.addChild(tapHint)
        
        // Animación de entrada
        overlay.alpha = 0.0
        overlay.setScale(0.8)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let scaleIn = SKAction.scale(to: 1.0, duration: 0.5)
        let group = SKAction.group([fadeIn, scaleIn])
        
        overlay.run(group)
        
        return overlay
    }
    
    func showWelcomeScreen() {
        isWelcomeScreenActive = true
        isPausedGame = true
        physicsWorld.speed = 0
        groundComponent?.stopMovement()
        backgroundComponent?.stopMovement()
        pipeManager?.stopAllPipes()
        
        // Crear y mostrar el overlay de bienvenida
        welcomeOverlay = createWelcomeOverlay()
        addChild(welcomeOverlay)
        
        // Ocultar botón de pausa
        pauseButton?.isHidden = true
    }
    
    func hideWelcomeScreen() {
        isWelcomeScreenActive = false
        
        // Animación de salida
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let scaleOut = SKAction.scale(to: 0.8, duration: 0.3)
        let group = SKAction.group([fadeOut, scaleOut])
        
        welcomeOverlay?.run(group) { [weak self] in
            self?.welcomeOverlay?.removeFromParent()
            self?.welcomeOverlay = nil
        }
        
        // Mostrar la pantalla de instrucciones
        startInitialPause()
    }
    
    func updateWelcomeOverlayLayout() {
        guard let overlay = welcomeOverlay else { return }
        
        // Actualizar posición del overlay si cambia el tamaño de la escena
        if let dim = overlay.children.first(where: { $0.name == "welcomeDim" }) as? SKSpriteNode {
            dim.size = self.frame.size
            dim.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        }
        
        // Actualizar posiciones de todos los elementos
        let title = overlay.children.first(where: { $0.name == "welcomeTitle" }) as? SKLabelNode
        title?.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 120)
        
        let subtitle = overlay.children.first(where: { $0.name == "welcomeSubtitle" }) as? SKLabelNode
        subtitle?.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 70)
        
        let description = overlay.children.first(where: { $0.name == "welcomeDescription" }) as? SKLabelNode
        description?.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 20)
        
        let description2 = overlay.children.first(where: { $0.name == "welcomeDescription2" }) as? SKLabelNode
        description2?.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 10)
        
        let startButton = overlay.children.first(where: { $0.name == "welcomeStartButton" })
        startButton?.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 80)
        
        let tapHint = overlay.children.first(where: { $0.name == "welcomeTapHint" }) as? SKLabelNode
        tapHint?.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 140)
    }
}
