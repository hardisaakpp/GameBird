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
    var spawnInterval: TimeInterval = 2.0
    private var activePipes = [SKNode]()
    private var spawnAction: SKAction?
    private var lastSpawnTime: TimeInterval = 0
    private var lastGapCenterY: CGFloat?
    
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
        lastSpawnTime = CACurrentMediaTime()
        
        // Suavizado del desplazamiento vertical del hueco
        let targetPair = pipeComponent.createPipePair()
        if let lastCenter = lastGapCenterY {
            let currentCenter = targetPair.position.y
            let maxDelta: CGFloat = 120.0
            let clampedCenter = min(max(currentCenter, lastCenter - maxDelta), lastCenter + maxDelta)
            let delta = clampedCenter - currentCenter
            targetPair.position.y += delta
            lastGapCenterY = clampedCenter
        } else {
            lastGapCenterY = targetPair.position.y
        }
        let pipePair = targetPair
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
    
    func stopAllPipes() {
        // Detener la acción de generación
        scene.removeAction(forKey: "pipeGeneration")
        
        // Detener movimiento de todos los tubos
        spawnAction = nil
        activePipes.forEach { $0.removeAllActions() }
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
        lastGapCenterY = nil
        startGeneratingPipes()
    }
}
