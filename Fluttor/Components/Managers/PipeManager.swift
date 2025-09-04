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
    private var activeCoins = [SKNode]() // Nuevo: rastrear monedas activas
    private var activeStrawberries = [SKNode]() // Nuevo: rastrear fresas activas
    private var spawnAction: SKAction?
    private var lastSpawnTime: TimeInterval = 0
    private var lastGapCenterY: CGFloat?
    private var timeToNextSpawn: TimeInterval = 0
    
    // Configuración de monedas
    private let coinSpawnChance: Float = 0.7 // 70% de probabilidad de aparecer
    
    // Configuración de fresas
    private let strawberrySpawnChance: Float = 0.3 // 30% de probabilidad de aparecer (más raras)
    
    init(scene: SKScene) {
        self.scene = scene
        self.pipeComponent = PipeComponent(scene: scene)
    }
    
    func startGeneratingPipes() {
        // Limpiar acción previa si existe
        stopAllPipes()
        
        // En inicio, generamos inmediatamente y luego esperamos
        let createPipe = SKAction.run { [weak self] in
            self?.spawnPipe()
        }
        
        let wait = SKAction.wait(forDuration: spawnInterval)
        let sequence = SKAction.sequence([createPipe, wait])
        spawnAction = SKAction.repeatForever(sequence)
        
        scene.run(spawnAction!, withKey: "pipeGeneration")
    }

    func pause() {
        // Pausar generación y movimiento de tubos existentes
        scene.removeAction(forKey: "pipeGeneration")
        // Calcular tiempo restante para el próximo spawn manteniendo la fase
        let now = CACurrentMediaTime()
        let elapsed = now - lastSpawnTime
        if elapsed >= 0 {
            let remainder = spawnInterval - (elapsed.truncatingRemainder(dividingBy: spawnInterval))
            timeToNextSpawn = max(0, min(spawnInterval, remainder))
        } else {
            timeToNextSpawn = spawnInterval
        }
        activePipes.forEach { $0.isPaused = true }
        activeCoins.forEach { $0.isPaused = true }
    }

    func resume() {
        // Reanudar movimiento de tubos existentes
        activePipes.forEach { $0.isPaused = false }
        activeCoins.forEach { $0.isPaused = false }
        
        // Reanudar generación respetando el tiempo restante para el próximo spawn
        guard scene.action(forKey: "pipeGeneration") == nil else { return }
        let initialWait = SKAction.wait(forDuration: timeToNextSpawn)
        let createPipe = SKAction.run { [weak self] in
            self?.spawnPipe()
        }
        let wait = SKAction.wait(forDuration: spawnInterval)
        let repeatSeq = SKAction.repeatForever(SKAction.sequence([wait, createPipe]))
        let startSequence = SKAction.sequence([initialWait, createPipe, repeatSeq])
        scene.run(startSequence, withKey: "pipeGeneration")
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
        
        // Generar recompensas con posicionamiento aleatorio para evitar superposición
        spawnRewardsIfNeeded(at: pipePair.position.y)
        
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
    
    // MARK: - Sistema de Recompensas (Monedas y Fresas)
    private func spawnRewardsIfNeeded(at gapCenterY: CGFloat) {
        // Definir el rango vertical del hueco (aproximadamente 200 píxeles de altura)
        let gapHeight: CGFloat = 200.0
        let minY = gapCenterY - gapHeight / 2
        let maxY = gapCenterY + gapHeight / 2
        
        // Generar posiciones aleatorias para evitar superposición
        var coinPosition: CGFloat?
        var strawberryPosition: CGFloat?
        
        // Decidir si generar moneda
        let coinRandom = Float.random(in: 0...1)
        if coinRandom <= coinSpawnChance {
            coinPosition = CGFloat.random(in: minY...maxY)
        }
        
        // Decidir si generar fresa
        let strawberryRandom = Float.random(in: 0...1)
        if strawberryRandom <= strawberrySpawnChance {
            strawberryPosition = CGFloat.random(in: minY...maxY)
        }
        
        // Verificar que no estén muy cerca (mínimo 60 píxeles de separación)
        if let coinY = coinPosition, let strawberryY = strawberryPosition {
            let distance = abs(coinY - strawberryY)
            if distance < 60.0 {
                // Si están muy cerca, reposicionar la fresa
                let newStrawberryY = strawberryY > coinY ? 
                    min(strawberryY + 80, maxY) : 
                    max(strawberryY - 80, minY)
                strawberryPosition = newStrawberryY
            }
        }
        
        // Generar moneda si corresponde
        if let coinY = coinPosition {
            spawnCoin(at: coinY)
        }
        
        // Generar fresa si corresponde
        if let strawberryY = strawberryPosition {
            spawnStrawberry(at: strawberryY)
        }
    }
    
    // MARK: - Sistema de Monedas
    private func spawnCoin(at yPosition: CGFloat) {
        // Crear moneda en la posición específica
        let coin = CoinComponent.createCoin(at: CGPoint(x: scene.frame.maxX + 150, y: yPosition))
        coin.name = "coin"
        scene.addChild(coin)
        activeCoins.append(coin)
        
        // Configurar movimiento de la moneda (mismo que los tubos)
        let moveDistance = scene.frame.width + 300 // Distancia extra para asegurar que salga de pantalla
        let moveDuration = TimeInterval(moveDistance / pipeComponent.movementSpeed)
        
        coin.run(SKAction.sequence([
            SKAction.moveBy(x: -moveDistance, y: 0, duration: moveDuration),
            SKAction.removeFromParent(),
            SKAction.run { [weak self] in
                self?.activeCoins.removeAll { $0 == coin }
            }
        ]))
    }
    
    // MARK: - Sistema de Fresas
    private func spawnStrawberry(at yPosition: CGFloat) {
        // Crear fresa en la posición específica
        let strawberry = StrawberryComponent.createStrawberry(at: CGPoint(x: scene.frame.maxX + 150, y: yPosition))
        strawberry.name = "strawberry"
        scene.addChild(strawberry)
        activeStrawberries.append(strawberry)
        
        // Configurar movimiento de la fresa (mismo que los tubos)
        let moveDistance = scene.frame.width + 300 // Distancia extra para asegurar que salga de pantalla
        let moveDuration = TimeInterval(moveDistance / pipeComponent.movementSpeed)
        
        strawberry.run(SKAction.sequence([
            SKAction.moveBy(x: -moveDistance, y: 0, duration: moveDuration),
            SKAction.removeFromParent(),
            SKAction.run { [weak self] in
                self?.activeStrawberries.removeAll { $0 == strawberry }
            }
        ]))
    }
    
    func stopAllPipes() {
        // Detener la acción de generación
        scene.removeAction(forKey: "pipeGeneration")
        
        // Detener movimiento de todos los tubos
        spawnAction = nil
        activePipes.forEach { $0.removeAllActions() }
        
        // Detener movimiento de todas las monedas
        activeCoins.forEach { $0.removeAllActions() }
        
        // Detener movimiento de todas las fresas
        activeStrawberries.forEach { $0.removeAllActions() }
    }
    
    func removeAllPipes() {
        // Eliminar físicamente de la escena
        activePipes.forEach {
            $0.removeAllActions()
            $0.removeFromParent()
        }
        activePipes.removeAll()
        
        // Eliminar todas las monedas
        activeCoins.forEach {
            $0.removeAllActions()
            $0.removeFromParent()
        }
        activeCoins.removeAll()
        
        // Eliminar todas las fresas
        activeStrawberries.forEach {
            $0.removeAllActions()
            $0.removeFromParent()
        }
        activeStrawberries.removeAll()
        
        // Limpieza adicional por si hubiera tubos huérfanos
        scene.children
            .filter { $0.name == "pipePair" }
            .forEach { $0.removeFromParent() }
            
        // Limpieza adicional por si hubiera monedas huérfanas
        scene.children
            .filter { $0.name == "coin" }
            .forEach { $0.removeFromParent() }
    }
    
    func restart() {
        stopAllPipes()
        removeAllPipes()
        lastGapCenterY = nil
        startGeneratingPipes()
    }
    
    // MARK: - Gestión de Monedas
    func removeCoin(_ coin: SKNode) {
        activeCoins.removeAll { $0 == coin }
    }
    
    func removeStrawberry(_ strawberry: SKNode) {
        activeStrawberries.removeAll { $0 == strawberry }
    }
}
