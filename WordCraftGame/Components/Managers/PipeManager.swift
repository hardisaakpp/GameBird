//
//  PipeManager.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 1/2/25.
//  Maneja la creación de nuevos tubos

import SpriteKit

class PipeManager {
    let scene: SKScene
    let pipeComponent: PipeComponent
    let spawnInterval: TimeInterval = 1.8  // Tiempo entre apariciones
    var pipes = [SKNode]()
    var generationTimer: Timer?
    
    init(scene: SKScene) {
        self.scene = scene
        self.pipeComponent = PipeComponent(scene: scene)
    }
    
    /// Inicia la generación automática de tubos
    func startGeneratingPipes() {
        let createPipe = SKAction.run { [weak self] in
            self?.spawnPipe()
        }
        let wait = SKAction.wait(forDuration: spawnInterval)
        let sequence = SKAction.sequence([createPipe, wait])
        let repeatForever = SKAction.repeatForever(sequence)
        scene.run(repeatForever)
    }

    /// Crea y añade un nuevo par de tubos a la escena
    private func spawnPipe() {
        let pipePair = pipeComponent.createPipePair()
        scene.addChild(pipePair)
        
        // Mueve y elimina los tubos cuando salgan de la pantalla
        let moveDistance = scene.frame.width + pipePair.frame.width
        let moveDuration = TimeInterval(moveDistance / pipeComponent.movementSpeed)
        let moveAction = SKAction.moveBy(x: -moveDistance, y: 0, duration: moveDuration)
        let removeAction = SKAction.removeFromParent()
        pipePair.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    func stopAllPipes() {
        generationTimer?.invalidate()
        
        pipes.forEach { pipe in
            pipe.removeAllActions()
        }
    }
    
    func removeAllPipes() {
        scene.children.forEach { node in
            if node.name == "pipePair" {
                node.removeFromParent()
            }
        }
    }
    
    func restart() {
        stopAllPipes()
        removeAllPipes()
        startGeneratingPipes()
    }
}
