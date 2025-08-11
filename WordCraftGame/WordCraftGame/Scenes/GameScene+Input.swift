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
                if nodes(at: touchLocation).contains(where: { $0.name == "welcomeStartButton" }) {
                    let buttonContainer = welcomeOverlay.children.first(where: { $0.name == "welcomeStartButton" })
                    let scaleDown = SKAction.scale(to: 0.95, duration: 0.05)
                    let scaleUp = SKAction.scale(to: 1.0, duration: 0.05)
                    // Sonido al pulsar COMENZAR
                    AudioManager.shared.playSwooshSound()
                    (buttonContainer ?? welcomeOverlay).run(SKAction.sequence([scaleDown, scaleUp])) { [weak self] in
                        self?.hideWelcomeScreen()
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
                pauseButton.run(SKAction.sequence([scaleDown, scaleUp])) { [weak self] in
                    self?.pauseGame()
                }
            } else {
                // Optimización: Ejecutar acciones en paralelo
                DispatchQueue.main.async {
                    self.birdComponent.applyImpulse()
                    AudioManager.shared.playWingSound()
                }
            }
        }
    }
}
