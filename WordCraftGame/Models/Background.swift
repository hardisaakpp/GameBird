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
        
        // Asegurar valores por defecto del color
        self.color = .white
        self.colorBlendFactor = 0.0
    }
    
    func applyTemporaryColor(_ color: UIColor) {
        self.color = color
        self.colorBlendFactor = 1.0
    }
    
    func resetColor() {
        self.color = .white
        self.colorBlendFactor = 0.0
    }
    
    private func setupSize(scene: SKScene) {
        self.size = CGSize(
            width: scene.frame.width * BackgroundConstants.Size.widthRatio,
            height: scene.frame.height * BackgroundConstants.Size.heightRatio
        )
    }
}
