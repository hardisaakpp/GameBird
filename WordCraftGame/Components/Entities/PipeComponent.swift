//
//  PipeComponent.swift
//  WordCraftGame
//
//  Componente creará y configurará los tubos

import SpriteKit

class PipeComponent {
    let scene: SKScene
    let movementSpeed: CGFloat = 150.0
    let gapHeight: CGFloat = 200.0 // Altura del espacio entre tubos
    private let pipeCategory: UInt32 = PhysicsCategory.pipe // Categoría de física para los tubos
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    /// Crea un par de tubos y lo configura
    func createPipePair() -> SKNode {
        let pipePair = SKNode()
        let scaleFactor: CGFloat = 1.6
        let startingX = scene.frame.maxX + 150
        
        // Generar desplazamiento vertical aleatorio
        let alturaMaxima = scene.frame.size.height / 2
        let yOffset = CGFloat.random(in: -alturaMaxima/2...alturaMaxima/2)
        
        // Crea el tubo superior
        let upperPipe = SKSpriteNode(texture: Pipe.texturaTubo1)
        upperPipe.setScale(scaleFactor)
        upperPipe.position = CGPoint(
            x: startingX,
            y: scene.frame.midY + (gapHeight / 2) + (upperPipe.size.height / 2) + yOffset
        )
        upperPipe.physicsBody = SKPhysicsBody(rectangleOf: upperPipe.size)
        upperPipe.physicsBody?.isDynamic = false
        upperPipe.physicsBody?.categoryBitMask = pipeCategory
        upperPipe.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        upperPipe.physicsBody?.collisionBitMask = PhysicsCategory.bird
        
        // Crea el tubo inferior
        let lowerPipe = SKSpriteNode(texture: Pipe.texturaTubo2)
        lowerPipe.setScale(scaleFactor)
        lowerPipe.position = CGPoint(
            x: startingX,
            y: upperPipe.position.y - upperPipe.size.height - gapHeight
        )
        lowerPipe.physicsBody = SKPhysicsBody(rectangleOf: lowerPipe.size)
        lowerPipe.physicsBody?.isDynamic = false
        lowerPipe.physicsBody?.categoryBitMask = pipeCategory
        lowerPipe.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        lowerPipe.physicsBody?.collisionBitMask = PhysicsCategory.bird
        
        // Agregar al contenedor
        pipePair.addChild(upperPipe)
        pipePair.addChild(lowerPipe)
        
        // Animación de movimiento
        let moveAndRemove = createMoveAndRemoveAction(
            for: scene,
            nodeWidth: upperPipe.size.width,
            movementSpeed: movementSpeed
        )
        pipePair.run(moveAndRemove)
        
        return pipePair
    }
    
    /// Crea la acción de movimiento y eliminación
    private func createMoveAndRemoveAction(for scene: SKScene, nodeWidth: CGFloat, movementSpeed: CGFloat) -> SKAction {
        let distanceToMove = scene.frame.width + nodeWidth * 2
        let moveDuration = distanceToMove / movementSpeed
        
        return SKAction.sequence([
            SKAction.moveBy(x: -distanceToMove, y: 0, duration: TimeInterval(moveDuration)),
            SKAction.removeFromParent()
        ])
    }
}
