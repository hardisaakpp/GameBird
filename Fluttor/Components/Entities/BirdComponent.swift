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
        let transformation = growthLevel >= 1 ? " (Transformado)" : ""
        print("🍓 Pájaro creció! Nivel: \(growthLevel)/\(maxGrowthLevel) (\(growthType))\(transformation), Escala: \(newScale), Incremento: \(currentIncrement), Peso: \(newMass)")
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
