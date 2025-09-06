import SpriteKit

// MARK: - Actualización y Lógica del Juego (Ultra Optimizada)
extension GameScene {
    
    override func update(_ currentTime: TimeInterval) {
        // Monitoreo de rendimiento (reducido)
        if Int(currentTime * 10) % 10 == 0 { // Solo cada 0.1 segundos
            PerformanceMonitor.shared.updateFrame()
        }
        
        guard let physicsBody = birdComponent.bird.physicsBody else { return }
        
        // OPTIMIZACIÓN CRÍTICA: Actualizar rotación solo cuando sea necesario
        let yVelocity = physicsBody.velocity.dy
        let velocityChanged = abs(yVelocity - lastVelocity) > velocityThreshold
        let timeToUpdate = currentTime - lastRotationUpdate > rotationUpdateInterval
        
        if velocityChanged || timeToUpdate {
            updateBirdRotation(velocity: yVelocity)
            lastVelocity = yVelocity
            lastRotationUpdate = currentTime
        }
    }
    
    private func updateBirdRotation(velocity: CGFloat) {
        // Cálculo optimizado de rotación
        let rotationFactor = velocity < 0 ? GameConfig.Rotation.downwardFactor : GameConfig.Rotation.upwardFactor
        let targetRotation = clampedRotation(
            value: velocity * rotationFactor,
            min: GameConfig.Rotation.minAngle,
            max: GameConfig.Rotation.maxAngle
        )
        
        // Aplicar rotación directamente (más eficiente que SKAction)
        birdComponent.bird.zRotation = targetRotation
    }
    
    /// Función que limita un valor entre un mínimo y un máximo.
    func clampedRotation(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.max(min, Swift.min(max, value))
    }
}
