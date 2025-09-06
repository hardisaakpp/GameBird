//
//  BirdComponent.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 18/5/25.
//

import SpriteKit

class BirdComponent {
    let bird: SKSpriteNode
    private var dayTextures: [SKTexture]
    private var nightTextures: [SKTexture]
    private var redBirdTextures: [SKTexture]
    private var currentTextures: [SKTexture]
    private let initialPosition: CGPoint
    
    // MARK: - Sistema de Crecimiento
    private var growthLevel: Int = 0
    private let baseScale: CGFloat = 2.0
    private let baseGrowthIncrement: CGFloat = 0.15 // Incremento base por cada fresa
    private let maxGrowthLevel: Int = 10 // Máximo 10 niveles de crecimiento
    private let slowGrowthStartLevel: Int = 6 // A partir del nivel 6, crecimiento más lento
    
    // MARK: - Sistema de Peso
    private let baseMass: CGFloat = GameConfig.Physics.birdMass
    private let weightIncrement: CGFloat = 0.02 // Incremento muy sutil de peso por cada fresa
    
    // MARK: - Sistema de Poder Magnético Simple
    private var isMagneticActive: Bool = false
    private var magneticRadius: CGFloat = 150.0 // Radio de atracción magnética
    private var magneticDuration: TimeInterval = 8.0 // Duración del poder en segundos
    
    // Usar valor directamente desde GameConfig
    init(textures: [SKTexture], position: CGPoint) {
        // textures recibido se ignora en favor de texturas por modo día/noche
        self.dayTextures = [
            SKTexture(imageNamed: "YellowBird-Midflap"),
            SKTexture(imageNamed: "YellowBird-Downflap")
        ]
        self.nightTextures = [
            SKTexture(imageNamed: "BlueBird-Midflap"),
            SKTexture(imageNamed: "BlueBird-Downflap")
        ]
        self.redBirdTextures = [
            SKTexture(imageNamed: "redbird-midflap"),
            SKTexture(imageNamed: "redbird-downflap"),
            SKTexture(imageNamed: "RedBird-Upflap")
        ]
        self.currentTextures = BackgroundConstants.isNightNow() ? nightTextures : dayTextures
        self.bird = SKSpriteNode(texture: currentTextures.first)
        self.initialPosition = position
        configureBird(position: position)
    }
    
    private func configureBird(position: CGPoint) {
        bird.setScale(2.0)
        bird.position = position
        configurePhysics()
        startFlapping()
    }
    
    private func configurePhysics() {
        let physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        physicsBody.mass = GameConfig.Physics.birdMass
        physicsBody.linearDamping = GameConfig.Physics.linearDamping
        physicsBody.allowsRotation = false
        physicsBody.categoryBitMask = PhysicsCategory.bird
        physicsBody.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.top | PhysicsCategory.pipe
        physicsBody.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.pipe | PhysicsCategory.scoreDetector
        bird.physicsBody = physicsBody
    }
    
    private func startFlapping() {
        let flapAnimation = SKAction.animate(with: currentTextures, timePerFrame: 0.2)
        bird.run(SKAction.repeatForever(flapAnimation), withKey: "flap")
    }
    
    func applyImpulse() {
        if let body = bird.physicsBody {
            // Conservar componente positiva para permitir encadenar saltos
            let upwardVelocity = max(0, body.velocity.dy)
            body.velocity = CGVector(dx: 0, dy: upwardVelocity)
        }
        bird.physicsBody?.angularVelocity = 0
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: GameConfig.Physics.birdImpulse))
        
        let currentScale = getCurrentScale()
        let jumpScale = SKAction.sequence([
            SKAction.scale(to: currentScale * 1.1, duration: 0.1), // Escalar 10% más
            SKAction.scale(to: currentScale, duration: 0.2) // Volver al tamaño actual
        ])
        bird.run(jumpScale)
    }
    
    func reset() {
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.velocity = .zero
        bird.physicsBody?.angularVelocity = 0
        bird.zRotation = 0
        bird.position = initialPosition
        
        // Resetear crecimiento y tamaño
        resetGrowth()
        
        // Actualizar a texturas por franja horaria actual
        updateTexturesForCurrentTime()
        restartFlapAnimation()
        
        // Restaurar propiedades físicas originales después de una colisión
        if let physicsBody = bird.physicsBody {
            physicsBody.mass = baseMass // Usar el peso base
            physicsBody.allowsRotation = false
            physicsBody.linearDamping = GameConfig.Physics.linearDamping
            physicsBody.angularVelocity = 0
        }
        
        // Desactivar poder magnético si está activo
        if isMagneticActive {
            deactivateMagneticPower()
        }
    }

    // MARK: - Day/Night switching
    func updateTexturesForCurrentTime() {
        // Solo cambiar texturas si no está transformado (nivel < 1)
        guard growthLevel < 1 else { return }
        
        let newTextures = BackgroundConstants.isNightNow() ? nightTextures : dayTextures
        guard newTextures.first != currentTextures.first else { return }
        currentTextures = newTextures
        bird.texture = currentTextures.first
    }
    
    func restartFlapAnimation() {
        bird.removeAction(forKey: "flap")
        startFlapping()
    }
    
    // MARK: - Transformación de Sprites
    func transformToRedBird() {
        currentTextures = redBirdTextures
        bird.texture = currentTextures.first
        restartFlapAnimation()
        print("🐦 Pájaro transformado a pájaro rojo!")
    }
    
    func transformToBlueBird() {
        currentTextures = nightTextures // BlueBird usa las texturas de noche
        bird.texture = currentTextures.first
        restartFlapAnimation()
        print("🐦 Pájaro transformado a pájaro azul!")
    }
    
    // MARK: - Sistema de Crecimiento
    func growFromStrawberry() {
        guard growthLevel < maxGrowthLevel else { return }
        
        growthLevel += 1
        let newScale = getCurrentScale()
        
        // Transformar a pájaro rojo desde la primera fresa
        if growthLevel == 1 {
            transformToRedBird()
        }
        
        // Animación suave de crecimiento sin interrumpir la física
        let growAnimation = SKAction.scale(to: newScale, duration: 0.3)
        bird.run(growAnimation)
        
        // Actualizar física de forma más suave después de la animación
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.updatePhysicsForNewSize()
        }
        
        let newMass = getCurrentMass()
        let currentIncrement = getGrowthIncrement(for: growthLevel)
        let growthType = growthLevel < slowGrowthStartLevel ? "Normal" : "Lento"
        let transformation = growthLevel >= 1 ? " (Transformado a Rojo)" : ""
        print("🍓 Pájaro creció! Nivel: \(growthLevel)/\(maxGrowthLevel) (\(growthType))\(transformation), Escala: \(newScale), Incremento: \(currentIncrement), Peso: \(newMass)")
    }
    
    func growFromGrape() {
        // Las uvas transforman al pájaro a BlueBird pero sin crecimiento
        transformToBlueBird()
        print("🍇 Pájaro transformado a BlueBird por la uva!")
    }
    
    // MARK: - Sistema de Poder Magnético Simple
    func activateMagneticPower() {
        guard !isMagneticActive else { return }
        
        isMagneticActive = true
        addMagneticVisualEffect()
        
        // Usar un timer simple en lugar de acciones complejas
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self, self.isMagneticActive else {
                timer.invalidate()
                return
            }
            self.attractNearbyObjectsSimple()
        }
        
        // Desactivar después de la duración
        DispatchQueue.main.asyncAfter(deadline: .now() + magneticDuration) { [weak self] in
            self?.deactivateMagneticPower()
        }
        
        print("🧲 Poder magnético simple activado por \(magneticDuration) segundos!")
    }
    
    func deactivateMagneticPower() {
        guard isMagneticActive else { return }
        
        isMagneticActive = false
        removeMagneticVisualEffect()
        
        print("🧲 Poder magnético desactivado")
    }
    
    private func attractNearbyObjectsSimple() {
        guard let scene = bird.scene, isMagneticActive else { return }
        
        // Buscar solo monedas y fresas de forma simple
        for child in scene.children {
            guard let name = child.name,
                  (name == "coin" || name == "strawberry") else { continue }
            
            let distance = self.distance(from: bird.position, to: child.position)
            guard distance <= magneticRadius else { continue }
            
            // Mover el objeto directamente hacia el pájaro
            let moveAction = SKAction.move(to: bird.position, duration: 0.3)
            child.run(moveAction)
        }
    }
    
    private func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        let dx = point1.x - point2.x
        let dy = point1.y - point2.y
        return sqrt(dx * dx + dy * dy)
    }
    
    private func addMagneticVisualEffect() {
        // Crear un efecto magnético ultra avanzado con múltiples elementos
        
        // 1. Campo magnético principal con gradiente
        addMagneticFieldGradient()
        
        // 2. Ondas de energía que se expanden
        addEnergyWaves()
        
        // 3. Partículas orbitales mejoradas
        addAdvancedMagneticParticles()
        
        // 4. Efecto de chispas eléctricas
        addElectricSparks()
        
        // 5. Campo de fuerza con líneas de energía
        addEnergyFieldLines()
        
        // 6. Efecto de distorsión del espacio
        addSpaceDistortion()
    }
    
    private func addMagneticFieldGradient() {
        // Campo exterior con gradiente
        let outerField = SKShapeNode(circleOfRadius: magneticRadius)
        outerField.name = "magneticFieldOuter"
        outerField.strokeColor = .systemBlue
        outerField.fillColor = .clear
        outerField.lineWidth = 3.0
        outerField.alpha = 0.3
        outerField.zPosition = -5
        
        // Campo medio con cian brillante
        let middleField = SKShapeNode(circleOfRadius: magneticRadius * 0.75)
        middleField.name = "magneticFieldMiddle"
        middleField.strokeColor = .systemCyan
        middleField.fillColor = .clear
        middleField.lineWidth = 2.5
        middleField.alpha = 0.5
        middleField.zPosition = -4
        
        // Campo interior con blanco puro
        let innerField = SKShapeNode(circleOfRadius: magneticRadius * 0.5)
        innerField.name = "magneticFieldInner"
        innerField.strokeColor = .white
        innerField.fillColor = .clear
        innerField.lineWidth = 2.0
        innerField.alpha = 0.8
        innerField.zPosition = -3
        
        // Campo central ultra brillante
        let coreField = SKShapeNode(circleOfRadius: magneticRadius * 0.25)
        coreField.name = "magneticFieldCore"
        coreField.strokeColor = .yellow
        coreField.fillColor = .clear
        coreField.lineWidth = 1.5
        coreField.alpha = 1.0
        coreField.zPosition = -2
        
        bird.addChild(outerField)
        bird.addChild(middleField)
        bird.addChild(innerField)
        bird.addChild(coreField)
        
        // Animaciones complejas y sincronizadas
        let outerPulse = SKAction.sequence([
            SKAction.scale(to: 1.4, duration: 1.2),
            SKAction.scale(to: 0.7, duration: 1.2)
        ])
        let outerRotate = SKAction.rotate(byAngle: .pi * 2, duration: 5.0)
        outerField.run(SKAction.repeatForever(outerPulse))
        outerField.run(SKAction.repeatForever(outerRotate))
        
        let middlePulse = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.9),
            SKAction.scale(to: 0.8, duration: 0.9)
        ])
        let middleRotate = SKAction.rotate(byAngle: -.pi * 2, duration: 3.5)
        middleField.run(SKAction.repeatForever(middlePulse))
        middleField.run(SKAction.repeatForever(middleRotate))
        
        let innerPulse = SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.6),
            SKAction.scale(to: 0.5, duration: 0.6)
        ])
        let innerFade = SKAction.sequence([
            SKAction.fadeAlpha(to: 1.0, duration: 0.4),
            SKAction.fadeAlpha(to: 0.4, duration: 0.4)
        ])
        innerField.run(SKAction.repeatForever(innerPulse))
        innerField.run(SKAction.repeatForever(innerFade))
        
        let corePulse = SKAction.sequence([
            SKAction.scale(to: 1.8, duration: 0.3),
            SKAction.scale(to: 0.3, duration: 0.3)
        ])
        let coreRotate = SKAction.rotate(byAngle: .pi * 4, duration: 1.0)
        coreField.run(SKAction.repeatForever(corePulse))
        coreField.run(SKAction.repeatForever(coreRotate))
    }
    
    private func addEnergyWaves() {
        // Crear ondas de energía que se expanden desde el centro
        for i in 0..<3 {
            let wave = SKShapeNode(circleOfRadius: 10)
            wave.name = "energyWave\(i)"
            wave.strokeColor = .systemBlue
            wave.fillColor = .clear
            wave.lineWidth = 2.0
            wave.alpha = 0.8
            wave.zPosition = -6
            
            bird.addChild(wave)
            
            // Animación de expansión con delay
            let expand = SKAction.sequence([
                SKAction.scale(to: magneticRadius / 10, duration: 1.5),
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent()
            ])
            
            let delay = SKAction.wait(forDuration: Double(i) * 0.5)
            let waveSequence = SKAction.sequence([delay, expand])
            
            wave.run(waveSequence)
            
            // Repetir la onda
            let repeatWave = SKAction.sequence([
                SKAction.wait(forDuration: 2.0),
                SKAction.run { [weak self] in
                    self?.addEnergyWaves()
                }
            ])
            bird.run(repeatWave, withKey: "energyWaveRepeat")
        }
    }
    
    private func addAdvancedMagneticParticles() {
        // Partículas orbitales con diferentes tamaños y colores
        let particleCount = 12
        for i in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            particle.name = "magneticParticle\(i)"
            
            // Colores aleatorios entre azul y cian
            let colors: [UIColor] = [.systemBlue, .systemCyan, .white, .systemIndigo]
            particle.fillColor = colors[i % colors.count]
            particle.strokeColor = .white
            particle.alpha = 0.8
            particle.zPosition = -1
            
            // Posicionar en círculo con variación
            let angle = (CGFloat(i) / CGFloat(particleCount)) * .pi * 2
            let radius = magneticRadius * CGFloat.random(in: 0.6...0.9)
            particle.position = CGPoint(
                x: cos(angle) * radius,
                y: sin(angle) * radius
            )
            
            bird.addChild(particle)
            
            // Animación orbital compleja
            let orbitDuration = Double.random(in: 1.5...3.0)
            let orbit = SKAction.rotate(byAngle: .pi * 2, duration: orbitDuration)
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.5, duration: 0.3),
                SKAction.scale(to: 0.5, duration: 0.3)
            ])
            let fade = SKAction.sequence([
                SKAction.fadeAlpha(to: 1.0, duration: 0.5),
                SKAction.fadeAlpha(to: 0.3, duration: 0.5)
            ])
            
            let orbitGroup = SKAction.group([
                orbit,
                SKAction.repeatForever(pulse),
                SKAction.repeatForever(fade)
            ])
            particle.run(SKAction.repeatForever(orbitGroup))
        }
    }
    
    private func addElectricSparks() {
        // Chispas eléctricas que aparecen aleatoriamente
        for _ in 0..<6 {
            let spark = SKShapeNode(circleOfRadius: 1)
            spark.name = "electricSpark"
            spark.fillColor = .yellow
            spark.strokeColor = .white
            spark.alpha = 0.9
            spark.zPosition = 0
            
            // Posición aleatoria dentro del campo magnético
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let radius = CGFloat.random(in: 0...(magneticRadius * 0.8))
            spark.position = CGPoint(
                x: cos(angle) * radius,
                y: sin(angle) * radius
            )
            
            bird.addChild(spark)
            
            // Animación de chispa
            let sparkle = SKAction.sequence([
                SKAction.scale(to: 3, duration: 0.1),
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ])
            spark.run(sparkle)
        }
        
        // Repetir chispas cada cierto tiempo
        let sparkRepeat = SKAction.sequence([
            SKAction.wait(forDuration: 0.8),
            SKAction.run { [weak self] in
                self?.addElectricSparks()
            }
        ])
        bird.run(sparkRepeat, withKey: "sparkRepeat")
    }
    
    private func addEnergyFieldLines() {
        // Líneas de energía que conectan el centro con el borde
        for i in 0..<8 {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 0))
            
            let angle = (CGFloat(i) / 8.0) * .pi * 2
            let endX = cos(angle) * magneticRadius
            let endY = sin(angle) * magneticRadius
            path.addLine(to: CGPoint(x: endX, y: endY))
            
            line.path = path
            line.name = "energyLine\(i)"
            line.strokeColor = .systemCyan
            line.lineWidth = 1.0
            line.alpha = 0.6
            line.zPosition = -7
            
            bird.addChild(line)
            
            // Animación de pulso de las líneas
            let linePulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 1.0, duration: 0.5),
                SKAction.fadeAlpha(to: 0.2, duration: 0.5)
            ])
            line.run(SKAction.repeatForever(linePulse))
        }
    }
    
    private func addSpaceDistortion() {
        // Efecto de distorsión del espacio con múltiples círculos
        for i in 0..<5 {
            let distortion = SKShapeNode(circleOfRadius: magneticRadius * CGFloat(i + 1) / 5)
            distortion.name = "spaceDistortion\(i)"
            distortion.strokeColor = .systemPurple
            distortion.fillColor = .clear
            distortion.lineWidth = 1.0
            distortion.alpha = 0.1
            distortion.zPosition = -8
            
            bird.addChild(distortion)
            
            // Animación de distorsión
            let distort = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.8),
                SKAction.scale(to: 0.8, duration: 0.8)
            ])
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 4.0)
            distortion.run(SKAction.repeatForever(distort))
            distortion.run(SKAction.repeatForever(rotate))
        }
    }
    
    private func addMagneticParticles() {
        // Crear partículas que orbiten alrededor del pájaro
        for i in 0..<8 {
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.name = "magneticParticle\(i)"
            particle.fillColor = .systemBlue
            particle.strokeColor = .white
            particle.alpha = 0.7
            particle.zPosition = -1
            
            // Posicionar partículas en un círculo
            let angle = (CGFloat(i) / 8.0) * .pi * 2
            let radius = magneticRadius * 0.8
            particle.position = CGPoint(
                x: cos(angle) * radius,
                y: sin(angle) * radius
            )
            
            bird.addChild(particle)
            
            // Animación orbital
            let orbit = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
            let orbitGroup = SKAction.group([
                orbit,
                SKAction.sequence([
                    SKAction.fadeAlpha(to: 1.0, duration: 0.5),
                    SKAction.fadeAlpha(to: 0.3, duration: 0.5)
                ])
            ])
            particle.run(SKAction.repeatForever(orbitGroup))
        }
    }
    
    private func removeMagneticVisualEffect() {
        // Remover todas las capas del campo magnético
        bird.childNode(withName: "magneticFieldOuter")?.removeFromParent()
        bird.childNode(withName: "magneticFieldMiddle")?.removeFromParent()
        bird.childNode(withName: "magneticFieldInner")?.removeFromParent()
        bird.childNode(withName: "magneticFieldCore")?.removeFromParent()
        
        // Remover ondas de energía
        for i in 0..<3 {
            bird.childNode(withName: "energyWave\(i)")?.removeFromParent()
        }
        
        // Remover partículas magnéticas avanzadas
        for i in 0..<12 {
            bird.childNode(withName: "magneticParticle\(i)")?.removeFromParent()
        }
        
        // Remover chispas eléctricas
        bird.enumerateChildNodes(withName: "electricSpark") { node, _ in
            node.removeFromParent()
        }
        
        // Remover líneas de energía
        for i in 0..<8 {
            bird.childNode(withName: "energyLine\(i)")?.removeFromParent()
        }
        
        // Remover distorsiones del espacio
        for i in 0..<5 {
            bird.childNode(withName: "spaceDistortion\(i)")?.removeFromParent()
        }
        
        // Detener acciones repetitivas
        bird.removeAction(forKey: "energyWaveRepeat")
        bird.removeAction(forKey: "sparkRepeat")
    }
    
    func isMagneticPowerActive() -> Bool {
        return isMagneticActive
    }
    
    private func updatePhysicsForNewSize() {
        // Actualizar el radio de colisión para el nuevo tamaño de forma más suave
        guard let currentPhysicsBody = bird.physicsBody else { return }
        
        // Preservar el estado actual de la física
        let currentVelocity = currentPhysicsBody.velocity
        let currentAngularVelocity = currentPhysicsBody.angularVelocity
        let isDynamic = currentPhysicsBody.isDynamic
        
        // Crear nuevo physicsBody con el tamaño y peso actualizados
        let newRadius = bird.size.height / 2
        let newPhysicsBody = SKPhysicsBody(circleOfRadius: newRadius)
        newPhysicsBody.mass = getCurrentMass() // Usar el peso actual basado en el crecimiento
        newPhysicsBody.linearDamping = GameConfig.Physics.linearDamping
        newPhysicsBody.allowsRotation = false
        newPhysicsBody.categoryBitMask = PhysicsCategory.bird
        newPhysicsBody.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.top | PhysicsCategory.pipe
        newPhysicsBody.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.pipe | PhysicsCategory.scoreDetector
        
        // Restaurar el estado de movimiento
        newPhysicsBody.velocity = currentVelocity
        newPhysicsBody.angularVelocity = currentAngularVelocity
        newPhysicsBody.isDynamic = isDynamic
        
        // Asignar el nuevo physicsBody
        bird.physicsBody = newPhysicsBody
    }
    
    func getGrowthLevel() -> Int {
        return growthLevel
    }
    
    func getCurrentScale() -> CGFloat {
        guard growthLevel > 0 else { return baseScale }
        
        var totalIncrement: CGFloat = 0.0
        for level in 1...growthLevel {
            totalIncrement += getGrowthIncrement(for: level)
        }
        return baseScale + totalIncrement
    }
    
    func getCurrentMass() -> CGFloat {
        return baseMass + (CGFloat(growthLevel) * weightIncrement)
    }
    
    private func getGrowthIncrement(for level: Int) -> CGFloat {
        if level < slowGrowthStartLevel {
            // Niveles 1-5: Crecimiento normal
            return baseGrowthIncrement
        } else {
            // Niveles 6-10: Crecimiento gradualmente más lento
            let slowLevel = level - slowGrowthStartLevel + 1 // 1, 2, 3, 4, 5
            let reductionFactor = CGFloat(slowLevel) * 0.02 // 0.02, 0.04, 0.06, 0.08, 0.10
            return max(baseGrowthIncrement - reductionFactor, 0.05) // Mínimo 0.05
        }
    }
    
    func resetGrowth() {
        growthLevel = 0
        bird.setScale(baseScale)
        
        // Resetear a las texturas originales (día/noche)
        currentTextures = BackgroundConstants.isNightNow() ? nightTextures : dayTextures
        bird.texture = currentTextures.first
        restartFlapAnimation()
        
        updatePhysicsForNewSize()
    }
}
