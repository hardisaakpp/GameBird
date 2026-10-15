import SpriteKit

// MARK: - SKPhysicsContactDelegate
extension GameScene {
    func didBegin(_ contact: SKPhysicsContact) {
        // OPTIMIZACIÓN CRÍTICA: Verificar game over primero para evitar procesamiento innecesario
        guard !isGameOver else { return }
        
        // OPTIMIZACIÓN: Calcular collisionMask una sola vez
        let collisionMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // OPTIMIZACIÓN: Usar switch con early return para mejor rendimiento
        switch collisionMask {
        case PhysicsCategory.bird | PhysicsCategory.pipe:
            handlePipeCollisionOptimized()
            
        case PhysicsCategory.bird | PhysicsCategory.ground:
            handleGroundCollisionOptimized()

        case PhysicsCategory.bird | PhysicsCategory.scoreDetector:
            handleScoreCollisionOptimized()
            
        case PhysicsCategory.bird | PhysicsCategory.coin:
            handleCoinCollectionOptimized(contact: contact)
            
        case PhysicsCategory.bird | PhysicsCategory.strawberry:
            handleStrawberryCollectionOptimized(contact: contact)
            
        case PhysicsCategory.bird | PhysicsCategory.grape:
            handleGrapeCollectionOptimized(contact: contact)
            
        default:
            break
        }
    }
    
    // MARK: - Métodos de colisión optimizados
    private func handlePipeCollisionOptimized() {
        debugLog("¡Colisión con tubo! El pájaro cae...")
        AudioManager.shared.playHitSound()
        // OPTIMIZACIÓN: Usar DispatchQueue.main.async en lugar de asyncAfter para mejor rendimiento
        DispatchQueue.main.async {
            AudioManager.shared.playDieSound()
        }
        handlePipeCollision()
    }
    
    private func handleGroundCollisionOptimized() {
        debugLog("¡Game Over! Pájaro tocó el suelo")
        AudioManager.shared.playHitSound()
        triggerGameOver()
    }
    
    private func handleScoreCollisionOptimized() {
        debugLog("¡Punto! Ave cruzó el hueco")
        AudioManager.shared.playPointSound()
        score += 1
        updateScoreDisplay()
    }
    
    private func handleCoinCollectionOptimized(contact: SKPhysicsContact) {
        debugLog("¡Moneda recolectada!")
        handleCoinCollection(contact: contact)
    }
    
    private func handleStrawberryCollectionOptimized(contact: SKPhysicsContact) {
        debugLog("¡Fresa recolectada!")
        handleStrawberryCollection(contact: contact)
    }
    
    private func handleGrapeCollectionOptimized(contact: SKPhysicsContact) {
        debugLog("¡Uva recolectada!")
        handleGrapeCollection(contact: contact)
    }
    
    func handlePipeCollision() {
        // Evitar múltiples colisiones
        guard !isGameOver else { return }
        enterGameOverState()
    }
    
    func triggerGameOver() {
        // Solo ejecutar si no se ha ejecutado ya
        guard !isGameOver else { return }
        
        debugLog("¡Game Over final!")
        enterGameOverState()
    }
    
    // Nuevo: método común para entrar al estado de Game Over (dedup)
    func enterGameOverState() {
        isGameOver = true
        pauseButton?.isHidden = true
        
        // Registrar el resultado del juego
        ScoreManager.shared.recordGameResult(score: score)
        // Nuevo: Registrar puntaje específico del jugador
        ScoreManager.shared.recordPlayerScore(score: score, gameMode: currentGameMode)
        
        // Detener la generación de nuevos tubos pero mantener los existentes
        pipeManager?.stopAllPipes()
        
        // Detener movimiento del fondo y suelo
        groundComponent?.stopMovement()
        backgroundComponent?.stopMovement()
        
        // Configurar el pájaro para que caiga dramáticamente
        if let birdPhysics = birdComponent?.bird.physicsBody {
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
            if let self = self, self.isGameOver, let restartButton = self.restartButton, restartButton.isHidden {
                self.showRestartButton()
            }
        }
    }
    
    // MARK: - Manejo de Recolección de Monedas
    func handleCoinCollection(contact: SKPhysicsContact) {
        // Determinar cuál de los dos cuerpos es la moneda
        let coinBody = contact.bodyA.categoryBitMask == PhysicsCategory.coin ? contact.bodyA : contact.bodyB
        guard let coinNode = coinBody.node as? CoinComponent else { return }
        
        // Recolectar la moneda
        let coinValue = coinNode.collect()
        
        // Notificar al PipeManager para remover de la lista de monedas activas
        pipeManager?.removeCoin(coinNode)
        
        // Agregar puntos al score
        score += coinValue
        updateScoreDisplay()
        
        // Reproducir sonido de moneda
        AudioManager.shared.playCoinSound()
        
        debugLog("💰 Moneda recolectada! +\(coinValue) puntos. Score total: \(score)")
    }
    
    // MARK: - Manejo de Recolección de Fresas
    func handleStrawberryCollection(contact: SKPhysicsContact) {
        // Determinar cuál de los dos cuerpos es la fresa
        let strawberryBody = contact.bodyA.categoryBitMask == PhysicsCategory.strawberry ? contact.bodyA : contact.bodyB
        guard let strawberryNode = strawberryBody.node as? StrawberryComponent else { return }
        
        // Recolectar la fresa
        let strawberryValue = strawberryNode.collect()
        
        // Notificar al PipeManager para remover de la lista de fresas activas
        pipeManager?.removeStrawberry(strawberryNode)
        
        // Agregar puntos al score
        score += strawberryValue
        updateScoreDisplay()
        
        // Hacer crecer al pájaro
        birdComponent?.growFromStrawberry()
        
        // Reproducir sonido de fresa
        AudioManager.shared.playFruitSound()
        
        debugLog("🍓 Fresa recolectada! +\(strawberryValue) puntos. Score total: \(score)")
    }
    
    // MARK: - Manejo de Recolección de Uvas
    func handleGrapeCollection(contact: SKPhysicsContact) {
        // Determinar cuál de los dos cuerpos es la uva
        let grapeBody = contact.bodyA.categoryBitMask == PhysicsCategory.grape ? contact.bodyA : contact.bodyB
        guard let grapeNode = grapeBody.node as? GrapeComponent else { return }
        
        // Recolectar la uva
        let grapeValue = grapeNode.collect()
        
        // Notificar al PipeManager para remover de la lista de uvas activas
        pipeManager?.removeGrape(grapeNode)
        
        // Agregar puntos al score
        score += grapeValue
        updateScoreDisplay()
        
        // Transformar a BlueBird (sin crecimiento)
        birdComponent?.growFromGrape()
        
        // Activar poder magnético con mejoras de seguridad
        birdComponent?.activateMagneticPower()
        
        // Reproducir sonido de fruta (reutilizamos el sonido de fresa)
        AudioManager.shared.playFruitSound()
        
        debugLog("🍇 Uva recolectada! +\(grapeValue) puntos. Score total: \(score)")
    }
}
