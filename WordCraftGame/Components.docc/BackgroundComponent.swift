//
//  BackgroundComponent.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 26/1/25.
//

import SpriteKit
import Models

class BackgroundComponent {
    private let scene: SKScene
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func createBackground() -> SKNode {
        let backgroundContainer = SKNode()
        
        for i in 0..<2 {
            let backgroundNode = Background()
            backgroundNode.configure(scene: scene)
            positionBackgroundNode(backgroundNode, index: i)
            addMovement(to: backgroundNode)
            backgroundContainer.addChild(backgroundNode)
        }
        
        return backgroundContainer
    }
    
    private func positionBackgroundNode(_ node: Background, index: Int) {
        node.position = CGPoint(
            x: CGFloat(index) * scene.frame.width,
            y: scene.frame.midY
        )
    }
    
    private func addMovement(to node: Background) {
        let moveAction = SKAction.moveBy(
            x: -scene.frame.width,
            y: 0,
            duration: TimeInterval(scene.frame.width / BackgroundConstants.movementSpeed)
        )
        
        let resetAction = SKAction.moveBy(
            x: scene.frame.width,
            y: 0,
            duration: 0
        )
        
        node.run(SKAction.repeatForever(
            SKAction.sequence([moveAction, resetAction])
        ))
    }
}
