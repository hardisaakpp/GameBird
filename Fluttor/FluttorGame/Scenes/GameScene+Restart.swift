import SpriteKit

// MARK: - Reinicio
extension GameScene {
    func restartGame(playPointSound: Bool = true) {
        restartButton?.isHidden = true
        
        // Sonido opcional de punto cuando se reinicia el juego
        if playPointSound {
            AudioManager.shared.playPointSound()
        }
        
        // Reiniciar marcador al reiniciar el juego
        score = 0
        updateScoreDisplay()
        
        // Resetear estado general
        isGameOver = false
        physicsWorld.speed = 1.0
        removeAllActions()
        
        // Limpiar elementos antiguos (delegado al PipeManager)
        pipeManager?.removeAllPipes()
        
        // Reiniciar componentes
        birdComponent?.reset()
        groundComponent?.reset()
        backgroundComponent?.reset()
        backgroundComponent?.resetBackgroundColor()
        pipeManager?.restart()
        
        // Restaurar UI
        hideRestartButton()
        birdComponent?.bird.physicsBody?.isDynamic = true
        pauseButton?.isHidden = false
    }

    func handleRestart(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if let restartButton = restartButton, restartButton.contains(touchLocation) {
            // Sonido de botón presionado
            AudioManager.shared.playSwooshSound()
            
            // Feedback visual
            let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
            
            restartButton.run(SKAction.sequence([scaleDown, scaleUp])) {
                self.restartButton?.isHidden = true
                // En modo noche, no reproducir point.wav al reiniciar
                let isNightMode = BackgroundConstants.isNightNow()
                self.restartGame(playPointSound: !isNightMode)
            }
        }
    }
}
