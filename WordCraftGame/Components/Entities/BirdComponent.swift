//
//  BirdComponent.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 18/5/25.
//

import SpriteKit

class BirdComponent {
    let bird: SKSpriteNode
    private let textures: [SKTexture]
    
    // Usar valor directamente desde GameConfig
    init(textures: [SKTexture], position: CGPoint) {
        self.textures = textures
        self.bird = SKSpriteNode(texture: textures.first)
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
        let flapAnimation = SKAction.animate(with: textures, timePerFrame: 0.2)
        bird.run(SKAction.repeatForever(flapAnimation))
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
        bird.position = CGPoint(
            x: -bird.parent!.frame.width / 4,
            y: bird.parent!.frame.midY
        )
        bird.setScale(2.0) // Asegurar tamaño original
        
        // Restaurar propiedades físicas originales después de una colisión
        if let physicsBody = bird.physicsBody {
            physicsBody.mass = GameConfig.Physics.birdMass
            physicsBody.allowsRotation = false
            physicsBody.linearDamping = GameConfig.Physics.linearDamping
            physicsBody.angularVelocity = 0
        }
    }
}
