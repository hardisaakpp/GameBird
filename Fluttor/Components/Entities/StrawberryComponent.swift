//
//  StrawberryComponent.swift
//  Fluttor
//
//  Created by Isaac Ortiz on 7/8/25.
//

import SpriteKit

class StrawberryComponent: SKSpriteNode {
    
    // MARK: - Propiedades
    static let strawberryValue = 2  // Las fresas valen más que las monedas
    private var isCollected = false
    
    // MARK: - Inicialización
    init() {
        let texture = SKTexture(imageNamed: "strawberry")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        // Reducir el tamaño de la fresa para que sea similar a la moneda
        setScale(0.3) // Ligeramente más grande que la moneda (0.13)
        
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
        physicsBody?.categoryBitMask = PhysicsCategory.strawberry
        physicsBody?.contactTestBitMask = PhysicsCategory.bird
        physicsBody?.collisionBitMask = 0 // No colisiona físicamente, solo detecta contacto
        physicsBody?.usesPreciseCollisionDetection = true
    }
    
    private func setupAppearance() {
        // Configurar apariencia visual
        zPosition = GameConfig.ZPosition.background + 6 // Detrás de tuberías y pájaro, pero encima del fondo
        name = "strawberry"
        
        // Agregar efecto de brillo/resplandor específico para fresas
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
        childNode(withName: "strawberryGlow")?.removeAction(forKey: "glowPulse")
        childNode(withName: "strawberryGlow")?.removeAction(forKey: "glowFade")
        
        // Animación de recolección específica para fresas
        let scaleUp = SKAction.scale(to: 1.8, duration: 0.1) // Más dramático que las monedas
        let scaleDown = SKAction.scale(to: 0, duration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let collectSequence = SKAction.sequence([scaleUp, scaleDown])
        let collectGroup = SKAction.group([collectSequence, fadeOut])
        
        run(collectGroup) {
            self.removeFromParent()
        }
        
        return StrawberryComponent.strawberryValue
    }
    
    // MARK: - Control de Animaciones
    func stopAnimations() {
        removeAction(forKey: "floating")
        removeAction(forKey: "rotating")
        
        // Detener animaciones del brillo
        childNode(withName: "strawberryGlow")?.removeAction(forKey: "glowPulse")
        childNode(withName: "strawberryGlow")?.removeAction(forKey: "glowFade")
    }
    
    func startAnimations() {
        setupAnimation()
    }
    
    // MARK: - Efectos Visuales
    private func addGlowEffect() {
        // OPTIMIZACIÓN: Efecto de brillo estático para mejor rendimiento
        let glow = SKSpriteNode(color: .systemRed, size: CGSize(width: size.width * Constants.glowSizeMultiplier, height: size.height * Constants.glowSizeMultiplier))
        glow.name = "strawberryGlow"
        glow.alpha = Constants.glowAlpha * 0.6 // Brillo más sutil y estático
        glow.zPosition = -1 // Detrás de la fresa
        
        addChild(glow)
        
        // Solo una animación simple de pulso (eliminar fade para mejor rendimiento)
        let pulseUp = SKAction.scale(to: 1.2, duration: Constants.glowPulseDuration)
        let pulseDown = SKAction.scale(to: 0.9, duration: Constants.glowPulseDuration)
        let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
        let pulseForever = SKAction.repeatForever(pulseSequence)
        
        glow.run(pulseForever, withKey: "glowPulse")
    }
    
    private func removeGlowEffect() {
        childNode(withName: "strawberryGlow")?.removeFromParent()
    }
    
    // MARK: - Factory Method
    static func createStrawberry(at position: CGPoint) -> StrawberryComponent {
        let strawberry = StrawberryComponent()
        strawberry.position = position
        return strawberry
    }
    
    // MARK: - Constantes
    private struct Constants {
        static let scale: CGFloat = 0.15
        static let floatDistance: CGFloat = 8.0  // Flotación más pronunciada que las monedas
        static let floatDuration: TimeInterval = 1.2  // Más lenta que las monedas
        static let rotationDuration: TimeInterval = 3.0  // Rotación más lenta
        
        // Efectos de brillo específicos para fresas
        static let glowSizeMultiplier: CGFloat = 2.0
        static let glowAlpha: CGFloat = 0.4
        static let glowPulseDuration: TimeInterval = 0.8
        static let glowFadeDuration: TimeInterval = 1.0
    }
}
