//
//  PipeComponent.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 1/2/25.
//  Componente creará y configurará los tubos

import SpriteKit
import Models

class PipeComponent {
    let scene: SKScene
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    /// Crea un tubo (o par de tubos) y lo configura
    func createPipePair() -> SKNode {
        let pipePair = SKNode()
        
        // Crea el tubo superior
        let upperPipe = SKSpriteNode(texture: Pipe.texturaTubo1)
        upperPipe.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY + 200)
        // Configura física, escalado, etc.
        upperPipe.physicsBody = SKPhysicsBody(rectangleOf: upperPipe.size)
        upperPipe.physicsBody?.isDynamic = false
        // Asigna las categorias de física que se necesiten...
        
        // Crea el tubo inferior
        let lowerPipe = SKSpriteNode(texture: Pipe.texturaTubo2)
        lowerPipe.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY - 200)
        lowerPipe.physicsBody = SKPhysicsBody(rectangleOf: lowerPipe.size)
        lowerPipe.physicsBody?.isDynamic = false
        
        // Agrega ambos tubos al nodo contenedor
        pipePair.addChild(upperPipe)
        pipePair.addChild(lowerPipe)
        
        return pipePair
    }
}
