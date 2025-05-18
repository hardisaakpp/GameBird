//  Created by Isaac Ortiz on 26/1/25.
//  Ground.swift
//  WordCraftGame
//  Alberga clases o estructuras que se encargan de crear y configurar
//  elementos visuales o logicos en la escena

import SpriteKit
import Models

class GroundComponent {
    private let scene: SKScene
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func createGround() -> SKNode {
        let groundContainer = SKNode()
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
            groundPiece.run(movementAction(pieceWidth: pieceWidth))
            container.addChild(groundPiece)
        }
    }
    
    private func movementAction(pieceWidth: CGFloat) -> SKAction {
        let moveDistance = -pieceWidth
        let duration = TimeInterval(abs(moveDistance) / GroundConstants.movementSpeed)
        
        return SKAction.repeatForever(
            SKAction.sequence([
                SKAction.moveBy(x: moveDistance, y: 0, duration: duration),
                SKAction.moveBy(x: pieceWidth, y: 0, duration: 0)
            ])
        )
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
}
