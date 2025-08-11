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
        
        let originalScale: CGFloat = 2.0
        let jumpScale = SKAction.sequence([
            SKAction.scale(to: originalScale * 1.1, duration: 0.1), // Escalar 10% más
            SKAction.scale(to: originalScale, duration: 0.2) // Volver al tamaño original
        ])
        bird.run(jumpScale)
    }
    
    func reset() {
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.velocity = .zero
        bird.physicsBody?.angularVelocity = 0
        bird.zRotation = 0
        bird.position = initialPosition
        bird.setScale(2.0) // Asegurar tamaño original
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
}
