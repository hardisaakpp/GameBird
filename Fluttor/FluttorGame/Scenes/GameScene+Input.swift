import SpriteKit

// MARK: - Métodos de Interacción del Usuario (Optimizada)
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        // Optimización: Procesar inmediatamente sin verificar ubicación
        if isGameOver {
            handleRestart(touches)
            return
        }

        // Manejo de pantalla de bienvenida
        if isWelcomeScreenActive {
            if let welcomeOverlay = welcomeOverlay,
               welcomeOverlay.contains(touchLocation) {
                
                // Verificar si se tocó el campo de texto
                if let nameInputBackground = welcomeOverlay.children.first(where: { $0.name == "textInputBackground" }) {
                    if nameInputBackground.frame.contains(touchLocation) {
                        // Activar el campo de texto y mostrar el teclado del sistema
                        let scaleDown = SKAction.scale(to: 0.95, duration: 0.05)
                        let scaleUp = SKAction.scale(to: 1.0, duration: 0.05)
                        nameInputBackground.run(SKAction.sequence([scaleDown, scaleUp]))
                        
                        // Mostrar el alert de entrada de texto
                        if let viewController = self.view?.window?.rootViewController as? GameViewController {
                            viewController.showTextInputAlert { [weak self] name in
                                // Actualizar el nombre en la escena
                                self?.updatePlayerName(name)
                            }
                        }
                        return
                    }
                }
                
                // Verificar si se tocó el botón PLAY (Modo Normal)
                if nodes(at: touchLocation).contains(where: { $0.name == "welcomePlayButton" }) {
                    let buttonContainer = welcomeOverlay.children.first(where: { $0.name == "welcomeButtonsContainer" })?.children.first(where: { $0.name == "welcomePlayButton" })
                    let scaleDown = SKAction.scale(to: 0.95, duration: 0.05)
                    let scaleUp = SKAction.scale(to: 1.0, duration: 0.05)
                    // Sonido al pulsar PLAY
                    AudioManager.shared.playSwooshSound()
                    (buttonContainer ?? welcomeOverlay).run(SKAction.sequence([scaleDown, scaleUp])) { [weak self] in
                        // Iniciar juego en modo normal
                        self?.hideWelcomeScreen(gameMode: .normal)
                    }
                    return
                }
                
                // Verificar si se tocó el botón PLAY BASIC (Modo Básico)
                if nodes(at: touchLocation).contains(where: { $0.name == "welcomePlayBasicButton" }) {
                    let buttonContainer = welcomeOverlay.children.first(where: { $0.name == "welcomeButtonsContainer" })?.children.first(where: { $0.name == "welcomePlayBasicButton" })
                    let scaleDown = SKAction.scale(to: 0.95, duration: 0.05)
                    let scaleUp = SKAction.scale(to: 1.0, duration: 0.05)
                    // Sonido al pulsar PLAY BASIC
                    AudioManager.shared.playSwooshSound()
                    (buttonContainer ?? welcomeOverlay).run(SKAction.sequence([scaleDown, scaleUp])) { [weak self] in
                        // Iniciar juego en modo básico
                        self?.hideWelcomeScreen(gameMode: .basic)
                    }
                    return
                }
            }
            return
        }
        

        
        // Manejo de pausa
        if isPausedGame {
            if isInitialPauseActive {
                // Reproducir sonido al iniciar desde la pantalla principal (message)
                AudioManager.shared.playSwooshSound()
                // Cualquier toque reanuda el juego al inicio
                resumeGame()
                return
            }
            if let resumeOverlay = resumeOverlay,
               resumeOverlay.contains(touchLocation) {
                if nodes(at: touchLocation).contains(where: { $0.name == "resumeButton" }) {
                    let buttonContainer = resumeOverlay.children.first(where: { $0.name == "resumeButton" })
                    let scaleDown = SKAction.scale(to: 0.95, duration: 0.05)
                    let scaleUp = SKAction.scale(to: 1.0, duration: 0.05)
                    // Sonido al pulsar REANUDAR
                    AudioManager.shared.playSwooshSound()
                    (buttonContainer ?? resumeOverlay).run(SKAction.sequence([scaleDown, scaleUp])) { [weak self] in
                        self?.resumeGame()
                    }
                    return
                }
                // Manejar botón INICIO en la pausa: volver a la pantalla de inicio (pausa inicial)
                if nodes(at: touchLocation).contains(where: { $0.name == "startButton" }) {
                    let startContainer = resumeOverlay.children.first(where: { $0.name == "startButton" })
                    let scaleDown = SKAction.scale(to: 0.95, duration: 0.05)
                    let scaleUp = SKAction.scale(to: 1.0, duration: 0.05)
                    AudioManager.shared.playSwooshSound()
                    (startContainer ?? resumeOverlay).run(SKAction.sequence([scaleDown, scaleUp])) { [weak self] in
                        self?.showStartScreenFromPause()
                    }
                    return
                }
            }
            return
        } else {
            // Si toca el botón de pausa
            if nodes(at: touchLocation).contains(where: { $0.name == "pauseButton" }) {
                // Reproducir sonido al pulsar pausa
                AudioManager.shared.playSwooshSound()
                let scaleDown = SKAction.scale(to: 0.9, duration: 0.05)
                let scaleUp = SKAction.scale(to: 1.0, duration: 0.05)
                pauseButton?.run(SKAction.sequence([scaleDown, scaleUp])) { [weak self] in
                    self?.pauseGame()
                }
            } else if let moonComponent = moonComponent, moonComponent.handleTouch(at: touchLocation) {
                // La luna fue tocada y manejó el toque
                // No hacer nada más, la luna ya cambió a modo día
            } else if let sunComponent = sunComponent, sunComponent.handleTouch(at: touchLocation) {
                // El sol fue tocado y manejó el toque
                // No hacer nada más, el sol ya cambió a modo noche
            } else {
                // Optimización: Ejecutar acciones en paralelo
                DispatchQueue.main.async {
                    self.birdComponent?.applyImpulse(gameMode: self.currentGameMode)
                    AudioManager.shared.playWingSound()
                }
            }
        }
    }
}
