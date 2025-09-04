//
//  CoinComponent.swift
//  Fluttor
//
//  Created by Isaac Ortiz on 7/8/25.
//

import SpriteKit

class CoinComponent: SKSpriteNode {
    
    // MARK: - Propiedades
    static let coinValue = 1
    private var isCollected = false
    
    // MARK: - Inicialización
    init() {
        let texture = SKTexture(imageNamed: "coin")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        // Reducir el tamaño de la moneda para que sea más pequeña que el pájaro
        // El pájaro tiene setScale(2.0), así que la moneda será más pequeña
        setScale(0.13) // 60% del tamaño original, más pequeña que el pájaro
        
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
        physicsBody?.categoryBitMask = PhysicsCategory.coin
        physicsBody?.contactTestBitMask = PhysicsCategory.bird
        physicsBody?.collisionBitMask = 0 // No colisiona físicamente, solo detecta contacto
        physicsBody?.usesPreciseCollisionDetection = true
    }
    
    private func setupAppearance() {
        // Configurar apariencia visual
        zPosition = GameConfig.ZPosition.background + 5 // Detrás de tuberías y pájaro, pero encima del fondo
        name = "coin"
        
        // Agregar efecto de brillo/resplandor
        addGlowEffect()
    }
    
    private func setupAnimation() {
        // Animación de flotación suave (movimiento vertical)
        let floatUp = SKAction.moveBy(x: 0, y: Constants.floatDistance, duration: Constants.floatDuration)
        let floatDown = SKAction.moveBy(x: 0, y: -Constants.floatDistance, duration: Constants.floatDuration)
        let floatSequence = SKAction.sequence([floatUp, floatDown])
        let floatForever = SKAction.repeatForever(floatSequence)
        
        // Animación de rotación lenta
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: Constants.rotationDuration)
        let rotateForever = SKAction.repeatForever(rotate)
        
        // Ejecutar ambas animaciones en paralelo
        run(floatForever, withKey: "floating")
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
        childNode(withName: "coinGlow")?.removeAction(forKey: "glowPulse")
        childNode(withName: "coinGlow")?.removeAction(forKey: "glowFade")
        
        // Animación de recolección
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.1)
        let scaleDown = SKAction.scale(to: 0, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let collectSequence = SKAction.sequence([scaleUp, scaleDown])
        let collectGroup = SKAction.group([collectSequence, fadeOut])
        
        run(collectGroup) {
            self.removeFromParent()
        }
        
        return CoinComponent.coinValue
    }
    
    // MARK: - Control de Animaciones
    func stopAnimations() {
        removeAction(forKey: "floating")
        removeAction(forKey: "rotating")
        
        // Detener animaciones del brillo
        childNode(withName: "coinGlow")?.removeAction(forKey: "glowPulse")
        childNode(withName: "coinGlow")?.removeAction(forKey: "glowFade")
    }
    
    func startAnimations() {
        setupAnimation()
    }
    
    // MARK: - Efectos Visuales
    private func addGlowEffect() {
        // Crear un efecto de resplandor dorado
        let glowSize = CGSize(width: size.width * Constants.glowSizeMultiplier, height: size.height * Constants.glowSizeMultiplier)
        let glow = SKSpriteNode(color: .systemYellow, size: glowSize)
        glow.alpha = Constants.glowAlpha
        glow.zPosition = zPosition - 0.1
        glow.name = "coinGlow"
        addChild(glow)
        
        // Animación del resplandor pulsante
        let pulseIn = SKAction.scale(to: 1.2, duration: Constants.glowPulseDuration)
        let pulseOut = SKAction.scale(to: 0.8, duration: Constants.glowPulseDuration)
        let pulse = SKAction.repeatForever(SKAction.sequence([pulseIn, pulseOut]))
        glow.run(pulse, withKey: "glowPulse")
        
        // Animación de opacidad para efecto de parpadeo sutil
        let fadeIn = SKAction.fadeAlpha(to: 0.5, duration: Constants.glowFadeDuration)
        let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: Constants.glowFadeDuration)
        let fadePulse = SKAction.repeatForever(SKAction.sequence([fadeIn, fadeOut]))
        glow.run(fadePulse, withKey: "glowFade")
    }
    
    private func removeGlowEffect() {
        childNode(withName: "coinGlow")?.removeFromParent()
    }
    
    // MARK: - Métodos estáticos
    static func createCoin(at position: CGPoint) -> CoinComponent {
        let coin = CoinComponent()
        coin.position = position
        return coin
    }
}

// MARK: - Extensión para constantes de monedas
extension CoinComponent {
    struct Constants {
        static let size = CGSize(width: 32, height: 32) // Tamaño base antes del escalado
        static let scale: CGFloat = 0.13 // Escala aplicada (13% del tamaño original)
        static let spawnChance: Float = 0.7 // 70% de probabilidad de aparecer
        static let minSpawnDistance: CGFloat = 200.0
        static let maxSpawnDistance: CGFloat = 400.0
        
        // Animaciones
        static let floatDistance: CGFloat = 8.0 // Distancia de flotación vertical
        static let floatDuration: TimeInterval = 1.5 // Duración de cada dirección de flotación
        static let rotationDuration: TimeInterval = 4.0 // Duración de una rotación completa
        
        // Efectos de brillo
        static let glowSizeMultiplier: CGFloat = 1.8 // Tamaño del resplandor relativo a la moneda
        static let glowAlpha: CGFloat = 0.3 // Opacidad base del resplandor
        static let glowPulseDuration: TimeInterval = 2.0 // Duración del pulso de brillo
        static let glowFadeDuration: TimeInterval = 1.5 // Duración del parpadeo de opacidad
    }
}
