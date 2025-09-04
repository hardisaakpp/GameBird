//
//  BirdComponent.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 18/5/25.
//

import SpriteKit

class BirdComponent {
    let bird: SKSpriteNode
    private var dayTextures: [SKTexture]
    private var nightTextures: [SKTexture]
    private var currentTextures: [SKTexture]
    private let initialPosition: CGPoint
    
    // MARK: - Sistema de Crecimiento
    private var growthLevel: Int = 0
    private let baseScale: CGFloat = 2.0
    private let growthIncrement: CGFloat = 0.15 // Incremento por cada fresa
    private let maxGrowthLevel: Int = 5 // Máximo 5 niveles de crecimiento
    
    // Usar valor directamente desde GameConfig
    init(textures: [SKTexture], position: CGPoint) {
        // textures recibido se ignora en favor de texturas por modo día/noche
        self.dayTextures = [
            SKTexture(imageNamed: "YellowBird-Midflap"),
            SKTexture(imageNamed: "YellowBird-Downflap")
        ]
        self.nightTextures = [
            SKTexture(imageNamed: "BlueBird-Midflap"),
            SKTexture(imageNamed: "BlueBird-Downflap")
        ]
        self.currentTextures = BackgroundConstants.isNightNow() ? nightTextures : dayTextures
        self.bird = SKSpriteNode(texture: currentTextures.first)
        self.initialPosition = position
        configureBird(position: position)
    }
    
    private func configureBird(position: CGPoint) {
        bird.setScale(2.0)
        bird.position = position
        configurePhysics()
        startFlapping()
    }
    
    private func configurePhysics() {
        let physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        physicsBody.mass = GameConfig.Physics.birdMass
        physicsBody.linearDamping = GameConfig.Physics.linearDamping
        physicsBody.allowsRotation = false
        physicsBody.categoryBitMask = PhysicsCategory.bird
        physicsBody.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.top | PhysicsCategory.pipe
        physicsBody.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.pipe | PhysicsCategory.scoreDetector
        bird.physicsBody = physicsBody
    }
    
    private func startFlapping() {
        let flapAnimation = SKAction.animate(with: currentTextures, timePerFrame: 0.2)
        bird.run(SKAction.repeatForever(flapAnimation), withKey: "flap")
    }
    
    func applyImpulse() {
        if let body = bird.physicsBody {
            // Conservar componente positiva para permitir encadenar saltos
            let upwardVelocity = max(0, body.velocity.dy)
            body.velocity = CGVector(dx: 0, dy: upwardVelocity)
        }
        bird.physicsBody?.angularVelocity = 0
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: GameConfig.Physics.birdImpulse))
        
        let currentScale = getCurrentScale()
        let jumpScale = SKAction.sequence([
            SKAction.scale(to: currentScale * 1.1, duration: 0.1), // Escalar 10% más
            SKAction.scale(to: currentScale, duration: 0.2) // Volver al tamaño actual
        ])
        bird.run(jumpScale)
    }
    
    func reset() {
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.velocity = .zero
        bird.physicsBody?.angularVelocity = 0
        bird.zRotation = 0
        bird.position = initialPosition
        
        // Resetear crecimiento y tamaño
        resetGrowth()
        
        // Actualizar a texturas por franja horaria actual
        updateTexturesForCurrentTime()
        restartFlapAnimation()
        
        // Restaurar propiedades físicas originales después de una colisión
        if let physicsBody = bird.physicsBody {
            physicsBody.mass = GameConfig.Physics.birdMass
            physicsBody.allowsRotation = false
            physicsBody.linearDamping = GameConfig.Physics.linearDamping
            physicsBody.angularVelocity = 0
        }
    }

    // MARK: - Day/Night switching
    func updateTexturesForCurrentTime() {
        let newTextures = BackgroundConstants.isNightNow() ? nightTextures : dayTextures
        guard newTextures.first != currentTextures.first else { return }
        currentTextures = newTextures
        bird.texture = currentTextures.first
    }
    
    func restartFlapAnimation() {
        bird.removeAction(forKey: "flap")
        startFlapping()
    }
    
    // MARK: - Sistema de Crecimiento
    func growFromStrawberry() {
        guard growthLevel < maxGrowthLevel else { return }
        
        growthLevel += 1
        let newScale = baseScale + (CGFloat(growthLevel) * growthIncrement)
        
        // Animación suave de crecimiento sin interrumpir la física
        let growAnimation = SKAction.scale(to: newScale, duration: 0.3)
        bird.run(growAnimation)
        
        // Actualizar física de forma más suave después de la animación
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.updatePhysicsForNewSize()
        }
        
        print("🍓 Pájaro creció! Nivel: \(growthLevel)/\(maxGrowthLevel), Escala: \(newScale)")
    }
    
    private func updatePhysicsForNewSize() {
        // Actualizar el radio de colisión para el nuevo tamaño de forma más suave
        guard let currentPhysicsBody = bird.physicsBody else { return }
        
        // Preservar el estado actual de la física
        let currentVelocity = currentPhysicsBody.velocity
        let currentAngularVelocity = currentPhysicsBody.angularVelocity
        let isDynamic = currentPhysicsBody.isDynamic
        
        // Crear nuevo physicsBody con el tamaño actualizado
        let newRadius = bird.size.height / 2
        let newPhysicsBody = SKPhysicsBody(circleOfRadius: newRadius)
        newPhysicsBody.mass = GameConfig.Physics.birdMass
        newPhysicsBody.linearDamping = GameConfig.Physics.linearDamping
        newPhysicsBody.allowsRotation = false
        newPhysicsBody.categoryBitMask = PhysicsCategory.bird
        newPhysicsBody.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.top | PhysicsCategory.pipe
        newPhysicsBody.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.pipe | PhysicsCategory.scoreDetector
        
        // Restaurar el estado de movimiento
        newPhysicsBody.velocity = currentVelocity
        newPhysicsBody.angularVelocity = currentAngularVelocity
        newPhysicsBody.isDynamic = isDynamic
        
        // Asignar el nuevo physicsBody
        bird.physicsBody = newPhysicsBody
    }
    
    func getGrowthLevel() -> Int {
        return growthLevel
    }
    
    func getCurrentScale() -> CGFloat {
        return baseScale + (CGFloat(growthLevel) * growthIncrement)
    }
    
    func resetGrowth() {
        growthLevel = 0
        bird.setScale(baseScale)
        updatePhysicsForNewSize()
    }
}
