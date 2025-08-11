import SpriteKit

// MARK: - SKPhysicsContactDelegate
extension GameScene {
    func didBegin(_ contact: SKPhysicsContact) {
        // Optimización: Verificar game over primero para evitar procesamiento innecesario
        guard !isGameOver else { return }
        
        let collisionMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // Optimización: Usar switch para mejor rendimiento
        switch collisionMask {
        case PhysicsCategory.bird | PhysicsCategory.pipe:
            print("¡Colisión con tubo! El pájaro cae...")
            AudioManager.shared.playHitSound()
            // Reproducir "die" justo después del impacto
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                AudioManager.shared.playDieSound()
            }
            handlePipeCollision()
            
        case PhysicsCategory.bird | PhysicsCategory.ground:
            print("¡Game Over! Pájaro tocó el suelo")
            AudioManager.shared.playHitSound()
            triggerGameOver()

        case PhysicsCategory.bird | PhysicsCategory.scoreDetector:
            print("¡Punto! Ave cruzó el hueco")
            AudioManager.shared.playPointSound()
            score += 1
            updateScoreDisplay()
            
        default:
            break
        }
    }
    
    func handlePipeCollision() {
        // Evitar múltiples colisiones
        guard !isGameOver else { return }
        enterGameOverState()
    }
    
    func triggerGameOver() {
        // Solo ejecutar si no se ha ejecutado ya
        guard !isGameOver else { return }
        
        print("¡Game Over final!")
        enterGameOverState()
    }
    
    // Nuevo: método común para entrar al estado de Game Over (dedup)
    func enterGameOverState() {
        isGameOver = true
        pauseButton?.isHidden = true
        
        // Registrar el resultado del juego
        ScoreManager.shared.recordGameResult(score: score)
        
        // Detener la generación de nuevos tubos pero mantener los existentes
        pipeManager?.stopAllPipes()
        
        // Detener movimiento del fondo y suelo
        groundComponent?.stopMovement()
        backgroundComponent?.stopMovement()
        
        // Configurar el pájaro para que caiga dramáticamente
        if let birdPhysics = birdComponent.bird.physicsBody {
            birdPhysics.mass = 0.1
            let fallImpulse = CGVector(dx: -50, dy: -200)
            birdPhysics.applyImpulse(fallImpulse)
            birdPhysics.allowsRotation = true
            birdPhysics.angularVelocity = -3.0
            birdPhysics.linearDamping = 0.1
        }
        
        // Cambiar el color de fondo para indicar el impacto
        backgroundComponent?.changeBackgroundColor(to: .red)
        
        // Efecto visual de impacto
        addImpactEffect()
        
        // Mostrar el botón de reinicio con un temporizador de seguridad
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            if let self = self, self.isGameOver && self.restartButton.isHidden {
                self.showRestartButton()
            }
        }
    }
}
