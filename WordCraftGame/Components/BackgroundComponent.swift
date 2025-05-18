//
//  BackgroundComponent.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 26/1/25.
//

import SpriteKit

class BackgroundComponent {
    private let scene: SKScene
    var backgroundContainer: SKNode!
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func createBackground() -> SKNode {
            backgroundContainer = SKNode()  // Guardar referencia
            
            for i in 0..<2 {
                let backgroundNode = Background()
                backgroundNode.configure(scene: scene)
                positionBackgroundNode(backgroundNode, index: i)
                addMovement(to: backgroundNode)
                backgroundContainer?.addChild(backgroundNode)
            }
            
            return backgroundContainer!
        }
    
    // Nuevo método para cambiar color
    func changeBackgroundColor(to color: UIColor) {
        let flashAction = SKAction.sequence([
            SKAction.run {
                self.backgroundContainer?.children.forEach {
                    ($0 as? SKSpriteNode)?.color = color
                    ($0 as? SKSpriteNode)?.colorBlendFactor = 1.0
                }
            },
            SKAction.wait(forDuration: 0.1),
            SKAction.run {
                self.backgroundContainer?.children.forEach {
                    ($0 as? SKSpriteNode)?.color = .white
                    ($0 as? SKSpriteNode)?.colorBlendFactor = 0.0
                }
            },
            SKAction.wait(forDuration: 0.1)
        ])
        backgroundContainer?.run(flashAction)
        
        }
    
    private func positionBackgroundNode(_ node: Background, index: Int) {
        node.position = CGPoint(
            x: CGFloat(index) * scene.frame.width,
            y: scene.frame.midY
        )
    }
    
    private func addMovement(to node: Background) {
            // Se mueve una distancia igual al ancho de la escena
            let moveAction = createLoopingMovementAction(distance: -scene.frame.width, movementSpeed: BackgroundConstants.movementSpeed)
            node.run(moveAction)
    }
    
    func stopMovement () {
        backgroundContainer.removeAllActions()
    }
    
    //func startMovement() {
    //  backgroundNodes.forEach { $0.speed = 1.0 }
    //}
}
