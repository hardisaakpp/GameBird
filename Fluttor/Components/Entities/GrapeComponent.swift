//
//  GrapeComponent.swift
//  Fluttor
//
//  Created by Isaac Ortiz on 7/8/25.
//

import SpriteKit

class GrapeComponent: SKSpriteNode {
    
    // MARK: - Propiedades
    static let grapeValue = 3  // Las uvas valen más que las fresas
    private var isCollected = false
    
    // MARK: - Inicialización
    init() {
        let texture = SKTexture(imageNamed: "grape")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        // Reducir el tamaño de la uva para que sea similar a la fresa
        setScale(0.15) // Ligeramente más pequeña que la fresa (0.3)
        
        setupPhysics()
        setupAppearance()
        setupAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuración
    private func setupPhysics() {
        // Configurar física para detección de colisión con el pájaro
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.grape
        physicsBody?.contactTestBitMask = PhysicsCategory.bird
        physicsBody?.collisionBitMask = 0 // No colisiona físicamente, solo detecta contacto
        physicsBody?.usesPreciseCollisionDetection = true
    }
    
    private func setupAppearance() {
        // Configurar apariencia visual
        zPosition = GameConfig.ZPosition.background + 7 // Detrás de tuberías y pájaro, pero encima del fondo
        name = "grape"
        
        // Agregar efecto de brillo/resplandor específico para uvas
        addGlowEffect()
    }
    
    private func setupAnimation() {
        // OPTIMIZACIÓN: Solo una animación simple de rotación para mejor rendimiento
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: Constants.rotationDuration)
        let rotateForever = SKAction.repeatForever(rotate)
        
        // Solo ejecutar rotación (eliminar flotación para mejor rendimiento)
        run(rotateForever, withKey: "rotating")
    }
    
    // MARK: - Métodos públicos
    func collect() -> Int {
        guard !isCollected else { return 0 }
        
        isCollected = true
        
        // Deshabilitar física para evitar múltiples colisiones
        physicsBody = nil
        
        // Detener animaciones de flotación y rotación
        removeAction(forKey: "floating")
        removeAction(forKey: "rotating")
        
        // Detener animaciones del brillo
        childNode(withName: "grapeGlow")?.removeAction(forKey: "glowPulse")
        childNode(withName: "grapeGlow")?.removeAction(forKey: "glowFade")
        
        // Animación de recolección específica para uvas
        let scaleUp = SKAction.scale(to: 2.0, duration: 0.1) // Más dramático que las fresas
        let scaleDown = SKAction.scale(to: 0, duration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let collectSequence = SKAction.sequence([scaleUp, scaleDown])
        let collectGroup = SKAction.group([collectSequence, fadeOut])
        
        run(collectGroup) {
            self.removeFromParent()
        }
        
        return GrapeComponent.grapeValue
    }
    
    // MARK: - Control de Animaciones
    func stopAnimations() {
        removeAction(forKey: "floating")
        removeAction(forKey: "rotating")
        
        // Detener animaciones del brillo
        childNode(withName: "grapeGlow")?.removeAction(forKey: "glowPulse")
        childNode(withName: "grapeGlow")?.removeAction(forKey: "glowFade")
    }
    
    func startAnimations() {
        setupAnimation()
    }
    
    // MARK: - Efectos Visuales
    private func addGlowEffect() {
        // OPTIMIZACIÓN: Efecto de brillo estático para mejor rendimiento
        let glow = SKSpriteNode(color: .systemPurple, size: CGSize(width: size.width * Constants.glowSizeMultiplier, height: size.height * Constants.glowSizeMultiplier))
        glow.name = "grapeGlow"
        glow.alpha = Constants.glowAlpha * 0.6 // Brillo más sutil y estático
        glow.zPosition = -1 // Detrás de la uva
        
        addChild(glow)
        
        // Solo una animación simple de pulso (eliminar fade para mejor rendimiento)
        let pulseUp = SKAction.scale(to: 1.2, duration: Constants.glowPulseDuration)
        let pulseDown = SKAction.scale(to: 0.9, duration: Constants.glowPulseDuration)
        let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
        let pulseForever = SKAction.repeatForever(pulseSequence)
        
        glow.run(pulseForever, withKey: "glowPulse")
    }
    
    private func removeGlowEffect() {
        childNode(withName: "grapeGlow")?.removeFromParent()
    }
    
    // MARK: - Factory Method
    static func createGrape(at position: CGPoint) -> GrapeComponent {
        let grape = GrapeComponent()
        grape.position = position
        return grape
    }
    
    // MARK: - Constantes
    private struct Constants {
        static let scale: CGFloat = 0.2
        static let floatDistance: CGFloat = 10.0  // Flotación más pronunciada que las fresas
        static let floatDuration: TimeInterval = 1.0  // Más rápida que las fresas
        static let rotationDuration: TimeInterval = 2.5  // Rotación más rápida
        
        // Efectos de brillo específicos para uvas
        static let glowSizeMultiplier: CGFloat = 2.2
        static let glowAlpha: CGFloat = 0.5
        static let glowPulseDuration: TimeInterval = 0.6
        static let glowFadeDuration: TimeInterval = 0.8
    }
}
