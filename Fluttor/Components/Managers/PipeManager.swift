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
    private var activeGrapes = [SKNode]() // Nuevo: rastrear uvas activas
    private var spawnAction: SKAction?
    private var lastSpawnTime: TimeInterval = 0
    private var lastGapCenterY: CGFloat?
    private var timeToNextSpawn: TimeInterval = 0
    
    // Configuración de monedas
    private let coinSpawnChance: Float = 0.7 // 70% de probabilidad de aparecer
    private let coinSpeedMultiplier: CGFloat = 1.0 // Velocidad normal
    
    // Configuración de fresas
    private let strawberrySpawnChance: Float = 0.3 // 30% de probabilidad de aparecer (más raras)
    private let strawberrySpeedMultiplier: CGFloat = 1.4 // 40% más rápido que las monedas
    
    // Configuración de uvas
    private let grapeSpawnChance: Float = 0.15 // 15% de probabilidad de aparecer (más raras que las fresas)
    private let grapeSpeedMultiplier: CGFloat = 2.8 // 180% más rápido que las monedas (doble que las fresas)
    
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
        activeStrawberries.forEach { $0.isPaused = true }
        activeGrapes.forEach { $0.isPaused = true }
    }

    func resume() {
        // Reanudar movimiento de tubos existentes
        activePipes.forEach { $0.isPaused = false }
        activeCoins.forEach { $0.isPaused = false }
        activeStrawberries.forEach { $0.isPaused = false }
        activeGrapes.forEach { $0.isPaused = false }
        
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
        
        // OPTIMIZACIÓN: Crear tubería de forma más eficiente
        let targetPair = pipeComponent.createPipePair()
        
        // OPTIMIZACIÓN: Cálculo de posición más eficiente
        if let lastCenter = lastGapCenterY {
            let currentCenter = targetPair.position.y
            let maxDelta: CGFloat = 120.0
            let clampedCenter = min(max(currentCenter, lastCenter - maxDelta), lastCenter + maxDelta)
            targetPair.position.y = clampedCenter
            lastGapCenterY = clampedCenter
        } else {
            lastGapCenterY = targetPair.position.y
        }
        
        targetPair.name = "pipePair"
        scene.addChild(targetPair)
        activePipes.append(targetPair)
        
        // OPTIMIZACIÓN: Generar recompensas de forma más eficiente
        spawnRewardsIfNeeded(at: targetPair.position.y)
        
        // OPTIMIZACIÓN: Cálculo de movimiento más eficiente
        let moveDistance = scene.frame.width + targetPair.frame.width
        let moveDuration = TimeInterval(moveDistance / pipeComponent.movementSpeed)
        
        // OPTIMIZACIÓN: Usar SKAction más eficiente
        let moveAction = SKAction.moveBy(x: -moveDistance, y: 0, duration: moveDuration)
        let cleanupAction = SKAction.run { [weak self] in
            self?.activePipes.removeAll { $0 == targetPair }
        }
        
        targetPair.run(SKAction.sequence([moveAction, SKAction.removeFromParent(), cleanupAction]))
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
        var grapePosition: CGFloat?
        
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
        
        // Decidir si generar uva
        let grapeRandom = Float.random(in: 0...1)
        if grapeRandom <= grapeSpawnChance {
            grapePosition = CGFloat.random(in: minY...maxY)
        }
        
        // Verificar que no estén muy cerca (mínimo 60 píxeles de separación)
        // Verificar proximidad entre moneda y fresa
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
        
        // Verificar proximidad entre moneda y uva
        if let coinY = coinPosition, let grapeY = grapePosition {
            let distance = abs(coinY - grapeY)
            if distance < 60.0 {
                // Si están muy cerca, reposicionar la uva
                let newGrapeY = grapeY > coinY ? 
                    min(grapeY + 80, maxY) : 
                    max(grapeY - 80, minY)
                grapePosition = newGrapeY
            }
        }
        
        // Verificar proximidad entre fresa y uva
        if let strawberryY = strawberryPosition, let grapeY = grapePosition {
            let distance = abs(strawberryY - grapeY)
            if distance < 60.0 {
                // Si están muy cerca, reposicionar la uva
                let newGrapeY = grapeY > strawberryY ? 
                    min(grapeY + 80, maxY) : 
                    max(grapeY - 80, minY)
                grapePosition = newGrapeY
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
        
        // Generar uva si corresponde
        if let grapeY = grapePosition {
            spawnGrape(at: grapeY)
        }
    }
    
    // MARK: - Sistema de Monedas
    private func spawnCoin(at yPosition: CGFloat) {
        // Crear moneda en la posición específica
        let coin = CoinComponent.createCoin(at: CGPoint(x: scene.frame.maxX + 150, y: yPosition))
        coin.name = "coin"
        scene.addChild(coin)
        activeCoins.append(coin)
        
        // Configurar movimiento de la moneda con velocidad específica
        let moveDistance = scene.frame.width + 300 // Distancia extra para asegurar que salga de pantalla
        let coinSpeed = pipeComponent.movementSpeed * coinSpeedMultiplier
        let moveDuration = TimeInterval(moveDistance / coinSpeed)
        
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
        
        // Configurar movimiento de la fresa con velocidad más rápida
        let moveDistance = scene.frame.width + 300 // Distancia extra para asegurar que salga de pantalla
        let strawberrySpeed = pipeComponent.movementSpeed * strawberrySpeedMultiplier
        let moveDuration = TimeInterval(moveDistance / strawberrySpeed)
        
        strawberry.run(SKAction.sequence([
            SKAction.moveBy(x: -moveDistance, y: 0, duration: moveDuration),
            SKAction.removeFromParent(),
            SKAction.run { [weak self] in
                self?.activeStrawberries.removeAll { $0 == strawberry }
            }
        ]))
    }
    
    // MARK: - Sistema de Uvas
    private func spawnGrape(at yPosition: CGFloat) {
        // Crear uva en la posición específica
        let grape = GrapeComponent.createGrape(at: CGPoint(x: scene.frame.maxX + 150, y: yPosition))
        grape.name = "grape"
        scene.addChild(grape)
        activeGrapes.append(grape)
        
        // Configurar movimiento de la uva con velocidad más rápida
        let moveDistance = scene.frame.width + 300 // Distancia extra para asegurar que salga de pantalla
        let grapeSpeed = pipeComponent.movementSpeed * grapeSpeedMultiplier
        let moveDuration = TimeInterval(moveDistance / grapeSpeed)
        
        grape.run(SKAction.sequence([
            SKAction.moveBy(x: -moveDistance, y: 0, duration: moveDuration),
            SKAction.removeFromParent(),
            SKAction.run { [weak self] in
                self?.activeGrapes.removeAll { $0 == grape }
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
        
        // Detener movimiento de todas las uvas
        activeGrapes.forEach { $0.removeAllActions() }
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
        
        // Eliminar todas las uvas
        activeGrapes.forEach {
            $0.removeAllActions()
            $0.removeFromParent()
        }
        activeGrapes.removeAll()
        
        // Limpieza adicional por si hubiera tubos huérfanos
        scene.children
            .filter { $0.name == "pipePair" }
            .forEach { $0.removeFromParent() }
            
        // Limpieza adicional por si hubiera monedas huérfanas
        scene.children
            .filter { $0.name == "coin" }
            .forEach { $0.removeFromParent() }
            
        // Limpieza adicional por si hubiera fresas huérfanas
        scene.children
            .filter { $0.name == "strawberry" }
            .forEach { $0.removeFromParent() }
            
        // Limpieza adicional por si hubiera uvas huérfanas
        scene.children
            .filter { $0.name == "grape" }
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
    
    func removeGrape(_ grape: SKNode) {
        activeGrapes.removeAll { $0 == grape }
    }
}
