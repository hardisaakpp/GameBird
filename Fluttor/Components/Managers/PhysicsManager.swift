//
//  PhysicsManager.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 18/5/25.
//

import CoreFoundation
import SpriteKit

class PhysicsManager {
    static func configureWorld(for scene: SKScene, gravity: CGFloat) {
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: gravity)
        scene.physicsWorld.contactDelegate = scene as? SKPhysicsContactDelegate
    }

    static func configureBirdPhysics(_ bird: SKSpriteNode) {
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.categoryBitMask = PhysicsCategory.bird
        bird.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.top | PhysicsCategory.pipe
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.pipe
        bird.physicsBody?.restitution = 0.5
        
        // Optimización: Configuración de física para mejor rendimiento
        bird.physicsBody?.linearDamping = 0.8 // Reducir fricción para mejor respuesta
        bird.physicsBody?.angularDamping = 1.0 // Sin rotación angular
        bird.physicsBody?.mass = 0.15 // Masa optimizada
        bird.physicsBody?.friction = 0.0 // Sin fricción para mejor rendimiento
    }
    
    static func createBoundary(for scene: SKScene, position: CGPoint, size: CGSize, category: UInt32) {
        let boundary = SKNode()
        boundary.position = position
        boundary.physicsBody = SKPhysicsBody(rectangleOf: size)
        boundary.physicsBody?.isDynamic = false
        boundary.physicsBody?.categoryBitMask = category
        scene.addChild(boundary)
    }
}
