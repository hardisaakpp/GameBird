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
    let spawnInterval: TimeInterval = 1.8
    private var activePipes = [SKNode]()
    private var spawnAction: SKAction?
    private var isPaused = false // Nueva propiedad para rastrear el estado de pausa
    
    init(scene: SKScene) {
        self.scene = scene
        self.pipeComponent = PipeComponent(scene: scene)
    }
    
    func startGeneratingPipes() {
        // Limpiar acción previa si existe
        stopAllPipes()
        
        let createPipe = SKAction.run { [weak self] in
            self?.spawnPipe()
        }
        
        let wait = SKAction.wait(forDuration: spawnInterval)
        let sequence = SKAction.sequence([createPipe, wait])
        spawnAction = SKAction.repeatForever(sequence)
        
        scene.run(spawnAction!, withKey: "pipeGeneration")
    }

    private func spawnPipe() {
        let pipePair = pipeComponent.createPipePair()
        pipePair.name = "pipePair"
        scene.addChild(pipePair)
        activePipes.append(pipePair)
        
        let moveDistance = scene.frame.width + pipePair.frame.width
        let moveDuration = TimeInterval(moveDistance / pipeComponent.movementSpeed)
        
        pipePair.run(SKAction.sequence([
            SKAction.moveBy(x: -moveDistance, y: 0, duration: moveDuration),
            SKAction.removeFromParent(),
            SKAction.run { [weak self] in
                self?.activePipes.removeAll { $0 == pipePair }
            }
        ]))
    }
    
    func pausePipes() {
        isPaused = true
        // Pausar la generación de nuevos tubos
        scene.removeAction(forKey: "pipeGeneration")
        
        // Pausar el movimiento de tubos existentes sin remover las acciones
        activePipes.forEach { pipe in
            pipe.isPaused = true
        }
    }
    
    func resumePipes() {
        guard isPaused else { return }
        isPaused = false
        
        // Reanudar el movimiento de tubos existentes
        activePipes.forEach { pipe in
            pipe.isPaused = false
        }
        
        // Reanudar la generación de nuevos tubos
        if spawnAction != nil {
            scene.run(spawnAction!, withKey: "pipeGeneration")
        } else {
            startGeneratingPipes()
        }
    }
    
    func stopAllPipes() {
        // Detener la acción de generación
        scene.removeAction(forKey: "pipeGeneration")
        
        // Solo detener movimiento si no está pausado (para game over)
        if !isPaused {
            spawnAction = nil
            activePipes.forEach { $0.removeAllActions() }
        }
    }
    
    func removeAllPipes() {
        // Eliminar físicamente de la escena
        activePipes.forEach {
            $0.removeAllActions()
            $0.removeFromParent()
        }
        activePipes.removeAll()
        
        // Limpieza adicional por si hubiera tubos huérfanos
        scene.children
            .filter { $0.name == "pipePair" }
            .forEach { $0.removeFromParent() }
    }
    
    func restart() {
        stopAllPipes()
        removeAllPipes()
        startGeneratingPipes()
    }
}
