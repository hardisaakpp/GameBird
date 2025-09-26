import SpriteKit

// MARK: - Pantalla de Bienvenida
extension GameScene {
    
    // MARK: - Constantes de Espaciado
    private struct WelcomeLayout {
        // Espaciado vertical entre elementos
        static let titleToNameInput: CGFloat = 100     // Espacio entre título principal y campo de nombre (aumentado)
        static let nameInputToSubtitle: CGFloat = 80   // Espacio entre campo de nombre y subtítulo (aumentado)
        static let subtitleToButton: CGFloat = 90      // Espacio entre subtítulo y botón (aumentado)
        static let buttonToPlayHint: CGFloat = 80      // Espacio entre botón y texto de ayuda final (aumentado)
        
        // Posiciones base desde el centro
        static let titleOffset: CGFloat = 160          // Título principal desde el centro
        static let nameInputOffset: CGFloat = 90       // Campo de nombre desde el centro (movido más arriba)
        static let subtitleOffset: CGFloat = -20       // Subtítulo desde el centro (ajustado)
        static let buttonOffset: CGFloat = -110        // Botón desde el centro (ajustado)
        static let playHintOffset: CGFloat = -190      // Texto de ayuda final desde el centro (ajustado)
    }
    
    func createWelcomeOverlay() -> SKNode {
        let overlay = SKNode()
        overlay.zPosition = GameConfig.ZPosition.UI + 2  // Por encima de otros overlays
        overlay.name = "welcomeOverlay"
        
        // Título principal - Ahora usando imagen FluttoRTittle.png
        let titleImage = SKSpriteNode(imageNamed: "FluttoRTittle")
        titleImage.name = "welcomeTitle"
        
        // Ajustar tamaño de la imagen para que sea apropiado - AUMENTADO AL TRIPLE
        let titleTargetWidth: CGFloat = 900  // Ancho objetivo del título (antes 300, ahora 3x)
        let titleTargetHeight: CGFloat = 360  // Alto objetivo del título (antes 120, ahora 3x)
        
        if titleImage.size.width > 0 {
            let scaleX = titleTargetWidth / titleImage.size.width
            let scaleY = titleTargetHeight / titleImage.size.height
            let scale = min(scaleX, scaleY)  // Mantener proporción
            titleImage.setScale(scale)
        }
        
        titleImage.position = CGPoint(x: self.frame.midX, y: self.frame.midY + WelcomeLayout.titleOffset + 80)  // Movido 80 puntos más arriba
        overlay.addChild(titleImage)
        
        // Campo de entrada de nombre
        let nameInputComponent = TextInputComponent(size: CGSize(width: 300, height: 50))
        nameInputComponent.setText(Player.current.name)
        nameInputComponent.addToParent(overlay, at: CGPoint(x: self.frame.midX, y: self.frame.midY + WelcomeLayout.nameInputOffset))
        
        // Instrucción para el campo de nombre (movido más arriba)
        let nameHint = SKLabelNode(text: "Toca el campo para ingresar tu nombre")
        nameHint.fontName = FontConstants.GameUI.hintFont
        nameHint.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.hintFontSize * 0.8, fontName: FontConstants.GameUI.hintFont)
        nameHint.fontColor = .systemGray
        nameHint.position = CGPoint(x: self.frame.midX, y: self.frame.midY + WelcomeLayout.nameInputOffset - 40)  // Posicionado justo debajo del camp
        nameHint.verticalAlignmentMode = .center
        nameHint.name = "welcomeNameHint"
        overlay.addChild(nameHint)
        
        // Subtítulo
        let subtitle = SKLabelNode(text: "¡Aventura Aérea!")
        subtitle.fontName = FontConstants.GameUI.hintFont
        subtitle.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.hintFontSize * 1.5, fontName: FontConstants.GameUI.hintFont)  // Aumentado 50%
        subtitle.fontColor = .systemYellow
        subtitle.position = CGPoint(x: self.frame.midX, y: self.frame.midY + WelcomeLayout.subtitleOffset)
        subtitle.verticalAlignmentMode = .center
        subtitle.name = "welcomeSubtitle"
        overlay.addChild(subtitle)
        
        // Contenedor para los botones de juego
        let buttonsContainer = SKNode()
        buttonsContainer.position = CGPoint(x: self.frame.midX, y: self.frame.midY + WelcomeLayout.buttonOffset)
        buttonsContainer.name = "welcomeButtonsContainer"
        
        // Ajustar tamaño de los botones
        let targetWidth: CGFloat = 140  // Ancho objetivo de cada botón (reducido para acomodar dos)
        let targetHeight: CGFloat = 140  // Alto objetivo de cada botón
        let buttonSpacing: CGFloat = 200  // Espaciado entre botones
        
        // BOTÓN PLAY (Modo Normal) - Lado derecho
        let playButtonContainer = SKNode()
        playButtonContainer.position = CGPoint(x: buttonSpacing/2, y: 0)
        playButtonContainer.name = "welcomePlayButton"
        
        let playButton = SKSpriteNode(imageNamed: "Play")
        playButton.name = "welcomePlayButton"
        
        if playButton.size.width > 0 {
            let scaleX = targetWidth / playButton.size.width
            let scaleY = targetHeight / playButton.size.height
            let scale = min(scaleX, scaleY)
            playButton.setScale(scale)
        }
        
        // Sombra para botón Play
        let playShadow = SKSpriteNode(imageNamed: "Play")
        playShadow.name = "welcomePlayButton"
        playShadow.setScale(playButton.xScale)
        playShadow.position = CGPoint(x: 3, y: -3)
        playShadow.alpha = 0.3
        playShadow.color = .black
        playShadow.colorBlendFactor = 1.0
        
        playButtonContainer.addChild(playShadow)
        playButtonContainer.addChild(playButton)
        
        // Área táctil para botón Play
        let playTouchArea = SKSpriteNode(color: .clear, size: CGSize(width: targetWidth, height: targetHeight))
        playTouchArea.name = "welcomePlayButton"
        playButtonContainer.addChild(playTouchArea)
        
        // Etiqueta para botón Play
        let playLabel = SKLabelNode(text: GameMode.normal.displayName)
        playLabel.fontName = FontConstants.GameUI.hintFont
        playLabel.fontSize = FontConstants.getAdaptiveFontSize(for: 24, fontName: FontConstants.GameUI.hintFont)
        playLabel.fontColor = getIntermediateSubtitleColor()  // Color dinámico
        playLabel.position = CGPoint(x: 0, y: -90)
        playLabel.verticalAlignmentMode = .center
        playLabel.name = "intermediateSubtitle"  // Agregar nombre para identificarlo
        playButtonContainer.addChild(playLabel)
        
        // BOTÓN PLAY BASIC (Modo Básico) - Lado izquierdo
        let playBasicButtonContainer = SKNode()
        playBasicButtonContainer.position = CGPoint(x: -buttonSpacing/2, y: 0)
        playBasicButtonContainer.name = "welcomePlayBasicButton"
        
        let playBasicButton = SKSpriteNode(imageNamed: "playBasic")
        playBasicButton.name = "welcomePlayBasicButton"
        
        // Tamaño ligeramente mayor para el botón básico
        let targetWidthBasic: CGFloat = 160  // 20 puntos más grande que el normal (140 -> 160)
        let targetHeightBasic: CGFloat = 160  // 20 puntos más grande que el normal (140 -> 160)
        
        if playBasicButton.size.width > 0 {
            let scaleX = targetWidthBasic / playBasicButton.size.width
            let scaleY = targetHeightBasic / playBasicButton.size.height
            let scale = min(scaleX, scaleY)
            playBasicButton.setScale(scale)
        }
        
        // Sombra para botón Play Basic
        let playBasicShadow = SKSpriteNode(imageNamed: "playBasic")
        playBasicShadow.name = "welcomePlayBasicButton"
        playBasicShadow.setScale(playBasicButton.xScale)
        playBasicShadow.position = CGPoint(x: 3, y: -3)
        playBasicShadow.alpha = 0.3
        playBasicShadow.color = .black
        playBasicShadow.colorBlendFactor = 1.0
        
        playBasicButtonContainer.addChild(playBasicShadow)
        playBasicButtonContainer.addChild(playBasicButton)
        
        // Área táctil para botón Play Basic (ajustada al nuevo tamaño)
        let playBasicTouchArea = SKSpriteNode(color: .clear, size: CGSize(width: targetWidthBasic, height: targetHeightBasic))
        playBasicTouchArea.name = "welcomePlayBasicButton"
        playBasicButtonContainer.addChild(playBasicTouchArea)
        
        // Etiqueta para botón Play Basic
        let playBasicLabel = SKLabelNode(text: GameMode.basic.displayName)
        playBasicLabel.fontName = FontConstants.GameUI.hintFont
        playBasicLabel.fontSize = FontConstants.getAdaptiveFontSize(for: 24, fontName: FontConstants.GameUI.hintFont)
        playBasicLabel.fontColor = getBasicSubtitleColor()  // Color dinámico según día/noche
        playBasicLabel.position = CGPoint(x: 0, y: -90)
        playBasicLabel.verticalAlignmentMode = .center
        playBasicLabel.zPosition = 10  // Asegurar que esté por encima de otros elementos
        playBasicLabel.alpha = 1.0     // Asegurar opacidad completa
        playBasicLabel.name = "basicSubtitle"  // Agregar nombre para debug
        playBasicButtonContainer.addChild(playBasicLabel)
        
        // Debug: verificar que el label se creó correctamente
        print("🔍 DEBUG: Label BÁSICO creado - Texto: '\(playBasicLabel.text ?? "nil")', Color: \(String(describing: playBasicLabel.fontColor)), Posición: \(playBasicLabel.position)")
        
        // Agregar efecto de vibración al botón Play (Normal)
        let shakeActionPlay = SKAction.sequence([
            SKAction.moveBy(x: -2, y: 0, duration: 0.05),
            SKAction.moveBy(x: 4, y: 0, duration: 0.05),
            SKAction.moveBy(x: -4, y: 0, duration: 0.05),
            SKAction.moveBy(x: 2, y: 0, duration: 0.05)
        ])
        
        let shakeSequencePlay = SKAction.sequence([
            SKAction.wait(forDuration: 1.5),  // Esperar 1.5 segundos antes de empezar
            SKAction.repeatForever(SKAction.sequence([
                shakeActionPlay,
                SKAction.wait(forDuration: 3.0)  // Pausa de 3 segundos entre vibraciones
            ]))
        ])
        
        playButton.run(shakeSequencePlay)
        
        // Agregar efecto de vibración al botón Play Basic (con timing diferente)
        let shakeActionBasic = SKAction.sequence([
            SKAction.moveBy(x: -2, y: 0, duration: 0.05),
            SKAction.moveBy(x: 4, y: 0, duration: 0.05),
            SKAction.moveBy(x: -4, y: 0, duration: 0.05),
            SKAction.moveBy(x: 2, y: 0, duration: 0.05)
        ])
        
        let shakeSequenceBasic = SKAction.sequence([
            SKAction.wait(forDuration: 2.5),  // Esperar 2.5 segundos antes de empezar (1 segundo después que el normal)
            SKAction.repeatForever(SKAction.sequence([
                shakeActionBasic,
                SKAction.wait(forDuration: 3.0)  // Pausa de 3 segundos entre vibraciones
            ]))
        ])
        
        playBasicButton.run(shakeSequenceBasic)
        
        // Agregar ambos contenedores de botones al contenedor principal
        buttonsContainer.addChild(playButtonContainer)
        buttonsContainer.addChild(playBasicButtonContainer)
        overlay.addChild(buttonsContainer)
        
        // Indicación para tocar - Actualizada para ambos botones (más abajo)
        let tapHint = SKLabelNode(text: "Elige tu modo de juego: \(GameMode.normal.displayName) o \(GameMode.basic.displayName)")
        tapHint.fontName = FontConstants.GameUI.hintFont
        tapHint.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.hintFontSize * 0.9, fontName: FontConstants.GameUI.hintFont)
        tapHint.fontColor = .systemOrange  // Mantener naranja para texto de pista
        tapHint.position = CGPoint(x: self.frame.midX, y: self.frame.midY + WelcomeLayout.playHintOffset - 40)  // Movido 40 puntos más abajo
        tapHint.verticalAlignmentMode = .center
        tapHint.name = "welcomeTapHint"
        overlay.addChild(tapHint)
        
        // Créditos del juego en la parte inferior de la pantalla
        let creditsTitle = SKLabelNode(text: "Desarrollado por Isaac Ortiz")
        creditsTitle.fontName = FontConstants.GameUI.hintFont
        creditsTitle.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.hintFontSize * 0.8, fontName: FontConstants.GameUI.hintFont)
        creditsTitle.fontColor = .systemGray
        creditsTitle.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 90)  // 100 puntos desde el borde inferior
        creditsTitle.verticalAlignmentMode = .center
        creditsTitle.name = "welcomeCreditsTitle"
        overlay.addChild(creditsTitle)
        
        let creditsSubtitle = SKLabelNode(text: "Fluttor v1.0 • SpriteKit • Swift • iOS")
        creditsSubtitle.fontName = FontConstants.GameUI.hintFont
        creditsSubtitle.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.hintFontSize * 0.7, fontName: FontConstants.GameUI.hintFont)
        creditsSubtitle.fontColor = .systemGray2
        creditsSubtitle.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 60)  // 70 puntos desde el borde inferior
        creditsSubtitle.verticalAlignmentMode = .center
        creditsSubtitle.name = "welcomeCreditsSubtitle"
        overlay.addChild(creditsSubtitle)
        
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
        if let welcomeOverlay = welcomeOverlay {
            addChild(welcomeOverlay)
        }
        
        // Ocultar botón de pausa
        pauseButton?.isHidden = true
    }
    
    func hideWelcomeScreen(gameMode: GameMode = .normal) {
        isWelcomeScreenActive = false
        currentGameMode = gameMode  // Establecer el modo de juego seleccionado
        
        // Mostrar en consola el modo seleccionado (para debugging)
        print("🎮 Modo de juego seleccionado: \(gameMode.displayName)")
        
        // Aplicar configuraciones de física específicas del modo
        applyGameModePhysics()
        
        // Guardar el nombre del jugador antes de ocultar la pantalla
        if let nameInputBackground = welcomeOverlay?.children.first(where: { $0.name == "textInputBackground" }) {
            // Buscar el label del texto ingresado
            if let textLabel = nameInputBackground.children.first(where: { $0.name == "textInputLabel" }) as? SKLabelNode,
               let text = textLabel.text, !text.isEmpty {
                Player.current = Player(name: text)
            }
        }
        
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
        
        let buttonsContainer = overlay.children.first(where: { $0.name == "welcomeButtonsContainer" })
        buttonsContainer?.position = CGPoint(x: self.frame.midX, y: self.frame.midY + WelcomeLayout.buttonOffset)
        
        let tapHint = overlay.children.first(where: { $0.name == "welcomeTapHint" }) as? SKLabelNode
        tapHint?.position = CGPoint(x: self.frame.midX, y: self.frame.midY + WelcomeLayout.playHintOffset - 40)
        
        let creditsTitle = overlay.children.first(where: { $0.name == "welcomeCreditsTitle" }) as? SKLabelNode
        creditsTitle?.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 90)
        
        let creditsSubtitle = overlay.children.first(where: { $0.name == "welcomeCreditsSubtitle" }) as? SKLabelNode
        creditsSubtitle?.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 60)
    }
    
    func updatePlayerName(_ name: String) {
        // Actualizar el nombre del jugador en el marcador usando la función auxiliar
        updateScorePlayerName(name)
        
        // Actualizar el nombre en el campo de entrada si la pantalla de bienvenida está activa
        if let nameInputBackground = welcomeOverlay?.children.first(where: { $0.name == "textInputBackground" }) {
            if let textLabel = nameInputBackground.children.first(where: { $0.name == "textInputLabel" }) as? SKLabelNode {
                textLabel.text = name
            }
        }
    }
    
    // MARK: - Physics Configuration for Game Modes
    func applyGameModePhysics() {
        // Actualizar gravedad del mundo según el modo de juego
        let newGravity = GameConfig.Physics.gravity(for: currentGameMode)
        physicsWorld.gravity = CGVector(dx: 0.0, dy: newGravity)
        
        // Configurar PipeManager para el modo de juego
        pipeManager?.setGameMode(currentGameMode)
        
        // Debug: Mostrar configuración de física aplicada
        let impulse = GameConfig.Physics.birdImpulse(for: currentGameMode)
        print("⚙️ Física aplicada - Gravedad: \(newGravity), Impulso: \(impulse)")
        
        // Nota: El impulso se aplicará automáticamente en BirdComponent.applyImpulse()
        // cuando el usuario toque la pantalla
    }
    
    // MARK: - Dynamic Color Helper
    private func getBasicSubtitleColor() -> UIColor {
        // Verificar si es modo noche usando el mismo sistema que el fondo
        let isNightMode = BackgroundConstants.textureName == "Background-Night"
        
        if isNightMode {
            return .white  // Blanco para modo noche
        } else {
            return .systemGreen  // Verde para modo día (como el color del botón)
        }
    }
    
    private func getIntermediateSubtitleColor() -> UIColor {
        // Verificar si es modo noche usando el mismo sistema que el fondo
        let isNightMode = BackgroundConstants.textureName == "Background-Night"
        
        if isNightMode {
            return .systemYellow  // Amarillo para modo noche (color actual)
        } else {
            return .systemTeal  // Azul turquesa para modo día
        }
    }
    
    // MARK: - Update Subtitle Color on Day/Night Change
    func updateBasicSubtitleColor() {
        // Buscar el subtítulo BÁSICO en el overlay de bienvenida
        if let welcomeOverlay = welcomeOverlay,
           let buttonsContainer = welcomeOverlay.children.first(where: { $0.name == "welcomeButtonsContainer" }),
           let playBasicButtonContainer = buttonsContainer.children.first(where: { $0.name == "welcomePlayBasicButton" }),
           let basicSubtitle = playBasicButtonContainer.children.first(where: { $0.name == "basicSubtitle" }) as? SKLabelNode {
            
            let newColor = getBasicSubtitleColor()
            basicSubtitle.fontColor = newColor
            
            print("🌅🌙 Subtítulo BÁSICO actualizado: \(BackgroundConstants.textureName == "Background-Night" ? "Blanco (Noche)" : "Verde (Día)")")
        }
    }
    
    func updateIntermediateSubtitleColor() {
        // Buscar el subtítulo INTERMEDIO en el overlay de bienvenida
        if let welcomeOverlay = welcomeOverlay,
           let buttonsContainer = welcomeOverlay.children.first(where: { $0.name == "welcomeButtonsContainer" }),
           let playButtonContainer = buttonsContainer.children.first(where: { $0.name == "welcomePlayButton" }),
           let intermediateSubtitle = playButtonContainer.children.first(where: { $0.name == "intermediateSubtitle" }) as? SKLabelNode {
            
            let newColor = getIntermediateSubtitleColor()
            intermediateSubtitle.fontColor = newColor
            
            print("🌅🌙 Subtítulo INTERMEDIO actualizado: \(BackgroundConstants.textureName == "Background-Night" ? "Amarillo (Noche)" : "Azul Turquesa (Día)")")
        }
    }
}
