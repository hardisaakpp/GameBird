//
//  UIComponent.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 18/5/25.
//

import SpriteKit

// UIComponent.swift
class UIComponent {
    static func createRestartButton(in scene: SKScene) -> SKLabelNode {
        let button = SKLabelNode(text: "Reiniciar")
        button.name = "restartButton"
        button.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        button.fontSize = 40
        button.fontColor = .white
        button.isHidden = true
        return button
    }
}
