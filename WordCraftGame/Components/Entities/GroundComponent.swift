
//  Created by Isaac Ortiz on 26/1/25.
//  Ground.swift
//  WordCraftGame
//  Alberga clases o estructuras que se encargan de crear y configurar
//  elementos visuales o logicos en la escena

import SpriteKit

class GroundComponent {
    private let scene: SKScene
    var groundContainer: SKNode!
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func createGround() -> SKNode {
        let groundContainer = SKNode()
        self.groundContainer = groundContainer // Guardar referencia
        let groundYPosition = calculateGroundYPosition()
        
        createVisualPieces(for: groundContainer, yPosition: groundYPosition)
        createPhysicsBody(yPosition: groundYPosition)
        
        return groundContainer
    }
    
    private func calculateGroundYPosition() -> CGFloat {
        let pieceHeight = scene.frame.height * GroundConstants.Size.pieceHeightRatio
        return pieceHeight + GroundConstants.Position.offset.y
    }
    
    private func createVisualPieces(for container: SKNode, yPosition: CGFloat) {
        let pieceWidth = scene.frame.width * GroundConstants.Size.pieceWidthRatio
        let numberOfPieces = Int(ceil(scene.frame.width / pieceWidth)) + 2
        
        for i in 0..<numberOfPieces {
            let groundPiece = Ground()
            groundPiece.configure(scene: scene)
            groundPiece.position = CGPoint(
                x: (CGFloat(i) * pieceWidth) + GroundConstants.Position.offset.x,
                y: yPosition
            )
            // Acción movimiento continuo
            let moveAction = createLoopingMovementAction(distance: -pieceWidth, movementSpeed: GroundConstants.movementSpeed)
            groundPiece.run(moveAction)
            container.addChild(groundPiece)
        }
    }
    
    private func createPhysicsBody(yPosition: CGFloat) {
        let physicsBodyNode = SKNode()
        physicsBodyNode.position = CGPoint(x: scene.frame.midX, y: yPosition)
        physicsBodyNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(
            width: scene.frame.width,
            height: scene.frame.height * GroundConstants.Size.pieceHeightRatio
        ))
        physicsBodyNode.physicsBody?.isDynamic = false
        physicsBodyNode.physicsBody?.categoryBitMask = GroundConstants.physicsCategory
        scene.addChild(physicsBodyNode)
    }
    
    func stopMovement() {
        groundContainer.removeAllActions()
    }
    
    func reset() {
        groundContainer?.removeAllActions()
        groundContainer?.removeFromParent()
        
        let newGround = createGround()
        scene.addChild(newGround)
        groundContainer = newGround
    }
}
