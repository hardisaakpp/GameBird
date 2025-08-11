import SpriteKit

// MARK: - Pantalla de Bienvenida
extension GameScene {
    
    // MARK: - Constantes de Espaciado
    private struct WelcomeLayout {
        // Espaciado vertical entre elementos
        static let titleToSubtitle: CGFloat = 80      // Espacio entre título principal y subtítulo (aumentado de 60)
        static let subtitleToDescription: CGFloat = 70 // Espacio entre subtítulo y primera descripción (aumentado de 50)
        static let descriptionToDescription: CGFloat = 25 // Espacio entre las dos líneas de descripción (aumentado de 15)
        static let descriptionToButton: CGFloat = 70   // Espacio entre descripción y botón (aumentado de 50)
        static let buttonToHint: CGFloat = 60          // Espacio entre botón y texto de ayuda (aumentado de 40)
        
        // Posiciones base desde el centro
        static let titleOffset: CGFloat = 160          // Título principal desde el centro (aumentado de 140)
        static let subtitleOffset: CGFloat = 80        // Subtítulo desde el centro (mantenido)
        static let descriptionOffset: CGFloat = 10     // Primera descripción desde el centro (reducido de 30)
        static let description2Offset: CGFloat = -15   // Segunda descripción desde el centro (reducido de 15)
        static let buttonOffset: CGFloat = -85         // Botón desde el centro (reducido de -35)
        static let hintOffset: CGFloat = -145          // Texto de ayuda desde el centro (reducido de -75)
    }
    
    func createWelcomeOverlay() -> SKNode {
        let overlay = SKNode()
        overlay.zPosition = GameConfig.ZPosition.UI + 2  // Por encima de otros overlays
        overlay.name = "welcomeOverlay"
        
        // Título principal
        let title = SKLabelNode(text: "FLUTTOR")
        title.fontName = FontConstants.GameUI.titleFont
        title.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.titleFontSize, fontName: FontConstants.GameUI.titleFont)
        title.fontColor = .white
        title.position = CGPoint(x: self.frame.midX, y: self.frame.midY + WelcomeLayout.titleOffset)
        title.verticalAlignmentMode = .center
        title.name = "welcomeTitle"
        overlay.addChild(title)
        
        // Subtítulo
        let subtitle = SKLabelNode(text: "¡Aventura Aérea!")
        subtitle.fontName = FontConstants.GameUI.hintFont
        subtitle.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.hintFontSize, fontName: FontConstants.GameUI.hintFont)
        subtitle.fontColor = .systemYellow
        subtitle.position = CGPoint(x: self.frame.midX, y: self.frame.midY + WelcomeLayout.subtitleOffset)
        subtitle.verticalAlignmentMode = .center
        subtitle.name = "welcomeSubtitle"
        overlay.addChild(subtitle)
        
        // Descripción del juego
        let description = SKLabelNode(text: "Guía al pájaro a través de las tuberías")
        description.fontName = FontConstants.GameUI.hintFont
        description.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.hintFontSize * 0.9, fontName: FontConstants.GameUI.hintFont)
        description.fontColor = .white.withAlphaComponent(0.8)
        description.position = CGPoint(x: self.frame.midX, y: self.frame.midY + WelcomeLayout.descriptionOffset)
        description.verticalAlignmentMode = .center
        description.name = "welcomeDescription"
        overlay.addChild(description)
        
        // Segunda línea de descripción
        let description2 = SKLabelNode(text: "¡Evita chocar y consigue la mayor puntuación!")
        description2.fontName = FontConstants.GameUI.hintFont
        description2.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.hintFontSize * 0.9, fontName: FontConstants.GameUI.hintFont)
        description2.fontColor = .white.withAlphaComponent(0.8)
        description2.position = CGPoint(x: self.frame.midX, y: self.frame.midY + WelcomeLayout.description2Offset)
        description2.verticalAlignmentMode = .center
        description2.name = "welcomeDescription2"
        overlay.addChild(description2)
        
        // Botón de comenzar
        let startButtonContainer = SKNode()
        startButtonContainer.position = CGPoint(x: self.frame.midX, y: self.frame.midY + WelcomeLayout.buttonOffset)
        startButtonContainer.name = "welcomeStartButton"
        
        let startBg = SKShapeNode(rectOf: CGSize(width: 280, height: 70), cornerRadius: 20)
        startBg.fillColor = .systemOrange  // Naranja energético para comenzar - más llamativo
        startBg.strokeColor = .white
        startBg.lineWidth = 4
        startBg.name = "welcomeStartButton"
        startButtonContainer.addChild(startBg)
        
        let startShadow = SKLabelNode(text: "COMENZAR")
        startShadow.fontName = FontConstants.GameUI.buttonFont
        startShadow.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.buttonFontSize * 1.3, fontName: FontConstants.GameUI.buttonFont)
        startShadow.fontColor = .black
        startShadow.position = CGPoint(x: 2, y: -2)
        startShadow.alpha = 0.3
        startShadow.verticalAlignmentMode = .center
        startShadow.name = "welcomeStartButton"
        startButtonContainer.addChild(startShadow)
        
        let startLabel = SKLabelNode(text: "COMENZAR")
        startLabel.fontName = FontConstants.GameUI.buttonFont
        startLabel.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.buttonFontSize * 1.3, fontName: FontConstants.GameUI.buttonFont)
        startLabel.fontColor = .white
        startLabel.verticalAlignmentMode = .center
        startLabel.name = "welcomeStartButton"
        startButtonContainer.addChild(startLabel)
        
        overlay.addChild(startButtonContainer)
        
        // Indicación para tocar
        let tapHint = SKLabelNode(text: "Toca COMENZAR para ver las instrucciones")
        tapHint.fontName = FontConstants.GameUI.hintFont
        tapHint.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.hintFontSize * 0.9, fontName: FontConstants.GameUI.hintFont)
        tapHint.fontColor = .systemOrange  // Mantener naranja para texto de pista
        tapHint.position = CGPoint(x: self.frame.midX, y: self.frame.midY + WelcomeLayout.hintOffset)
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
        
        // Ocultar el marcador en la pantalla de bienvenida
        scoreContainer.isHidden = true
        
        // Crear y mostrar el overlay de bienvenida
        welcomeOverlay = createWelcomeOverlay()
        addChild(welcomeOverlay)
        
        // Ocultar botón de pausa
        pauseButton?.isHidden = true
    }
    
    func hideWelcomeScreen() {
        isWelcomeScreenActive = false
        
        // Mostrar nuevamente el marcador
        scoreContainer.isHidden = false
        
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
        
        // Actualizar posiciones de todos los elementos usando las constantes de layout
        let title = overlay.children.first(where: { $0.name == "welcomeTitle" }) as? SKLabelNode
        title?.position = CGPoint(x: self.frame.midX, y: self.frame.midY + WelcomeLayout.titleOffset)
        
        let subtitle = overlay.children.first(where: { $0.name == "welcomeSubtitle" }) as? SKLabelNode
        subtitle?.position = CGPoint(x: self.frame.midX, y: self.frame.midY + WelcomeLayout.subtitleOffset)
        
        let description = overlay.children.first(where: { $0.name == "welcomeDescription" }) as? SKLabelNode
        description?.position = CGPoint(x: self.frame.midX, y: self.frame.midY + WelcomeLayout.descriptionOffset)
        
        let description2 = overlay.children.first(where: { $0.name == "welcomeDescription2" }) as? SKLabelNode
        description2?.position = CGPoint(x: self.frame.midX, y: self.frame.midY + WelcomeLayout.description2Offset)
        
        let startButton = overlay.children.first(where: { $0.name == "welcomeStartButton" })
        startButton?.position = CGPoint(x: self.frame.midX, y: self.frame.midY + WelcomeLayout.buttonOffset)
        
        let tapHint = overlay.children.first(where: { $0.name == "welcomeTapHint" }) as? SKLabelNode
        tapHint?.position = CGPoint(x: self.frame.midX, y: self.frame.midY + WelcomeLayout.hintOffset)
    }
}
