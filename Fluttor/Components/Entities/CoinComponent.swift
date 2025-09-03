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
        
        setupPhysics()
        setupAppearance()
        setupAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuración
    private func setupPhysics() {
        // Configurar física para detección de colisión
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.coin
        physicsBody?.contactTestBitMask = PhysicsCategory.bird
        physicsBody?.collisionBitMask = 0 // No colisiona físicamente
        physicsBody?.usesPreciseCollisionDetection = true
    }
    
    private func setupAppearance() {
        // Configurar apariencia visual
        zPosition = GameConfig.ZPosition.pipes + 1 // Justo encima de los tubos
        name = "coin"
        
        // Agregar un ligero brillo
        let glowEffect = SKEffectNode()
        glowEffect.filter = CIFilter(name: "CIGaussianBlur")
        glowEffect.filter?.setValue(2.0, forKey: "inputRadius")
        addChild(glowEffect)
    }
    
    private func setupAnimation() {
        // Animación de flotación suave
        let floatUp = SKAction.moveBy(x: 0, y: 10, duration: 1.0)
        let floatDown = SKAction.moveBy(x: 0, y: -10, duration: 1.0)
        let floatSequence = SKAction.sequence([floatUp, floatDown])
        let floatForever = SKAction.repeatForever(floatSequence)
        
        // Animación de rotación lenta
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 3.0)
        let rotateForever = SKAction.repeatForever(rotate)
        
        // Ejecutar ambas animaciones
        run(floatForever)
        run(rotateForever)
    }
    
    // MARK: - Métodos públicos
    func collect() -> Int {
        guard !isCollected else { return 0 }
        
        isCollected = true
        
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
        static let size = CGSize(width: 32, height: 32)
        static let spawnChance: Float = 0.7 // 70% de probabilidad de aparecer
        static let minSpawnDistance: CGFloat = 200.0
        static let maxSpawnDistance: CGFloat = 400.0
    }
}
