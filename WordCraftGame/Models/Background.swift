//
//  Background.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 26/1/25.
//

import SpriteKit

class Background: SKSpriteNode {
    func configure(scene: SKScene) {
        self.texture = SKTexture(imageNamed: BackgroundConstants.textureName)
        self.texture?.filteringMode = .linear
        setupSize(scene: scene)
        self.zPosition = BackgroundConstants.zPosition
    }
    
    private func setupSize(scene: SKScene) {
        self.size = CGSize(
            width: scene.frame.width * BackgroundConstants.Size.widthRatio,
            height: scene.frame.height * BackgroundConstants.Size.heightRatio
        )
    }
}
