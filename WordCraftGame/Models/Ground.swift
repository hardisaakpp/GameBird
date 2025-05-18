//
//  Ground.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 26/1/25.
//  Contiene estructuras o modelos que representan objetos

import SpriteKit

class Ground: SKSpriteNode {
    func configure(scene: SKScene) {
        self.texture = SKTexture(imageNamed: GroundConstants.textureName)
        self.texture?.filteringMode = .nearest
        setupVisuals(scene: scene)
        setupPhysics(scene: scene)
    }
    
    private func setupVisuals(scene: SKScene) {
        let pieceWidth = scene.frame.width * GroundConstants.Size.pieceWidthRatio
        let pieceHeight = scene.frame.height * GroundConstants.Size.pieceHeightRatio
        
        self.size = CGSize(width: pieceWidth, height: pieceHeight)
        self.zPosition = GroundConstants.zPosition
    }
    
    private func setupPhysics(scene: SKScene) {
        let physicsBody = SKPhysicsBody(rectangleOf: CGSize(
            width: scene.frame.width,
            height: self.size.height
        ))
        physicsBody.isDynamic = false
        physicsBody.categoryBitMask = GroundConstants.physicsCategory
        self.physicsBody = physicsBody
    }
}
