import SpriteKit

// MARK: - Actualización y Lógica del Juego (Optimizada)
extension GameScene {
    override func update(_ currentTime: TimeInterval) {
        // Monitoreo de rendimiento
        PerformanceMonitor.shared.updateFrame()
        
        guard let physicsBody = birdComponent.bird.physicsBody else { return }
        
        // Optimización: Calcular rotación solo si es necesario
        let yVelocity = physicsBody.velocity.dy
        let rotationFactor = yVelocity < 0 ? GameConfig.Rotation.downwardFactor : GameConfig.Rotation.upwardFactor
        let targetRotation = clampedRotation(
            value: yVelocity * rotationFactor,
            min: GameConfig.Rotation.minAngle,
            max: GameConfig.Rotation.maxAngle
        )
        
        // Optimización: Aplicar rotación directamente sin SKAction
        birdComponent.bird.zRotation = targetRotation
    }
    
    /// Función que limita un valor entre un mínimo y un máximo.
    func clampedRotation(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.max(min, Swift.min(max, value))
    }
}
