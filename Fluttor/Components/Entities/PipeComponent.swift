//
//  PipeComponent.swift
//  WordCraftGame
//
//  Componente creará y configurará los tubos

import SpriteKit

class PipeComponent {
    let scene: SKScene
    let movementSpeed: CGFloat = 150.0
    var gapHeight: CGFloat = 240.0 // Altura inicial del espacio entre tubos (más indulgente)
    private let minGapHeight: CGFloat = 200.0 // Mínimo para dificultad
    private let gapDecreasePerPoint: CGFloat = 2.0 // Reduce con el score
    private let pipeCategory: UInt32 = PhysicsCategory.pipe // Categoría de física para los tubos
    private var currentGameMode: GameMode = .normal // Modo de juego actual
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    // MARK: - Game Mode Configuration
    func setGameMode(_ mode: GameMode) {
        currentGameMode = mode
        
        // Configurar gap height según el modo de juego
        gapHeight = getGapHeight(for: mode)
        
        print("🔧 PipeComponent configurado para modo \(mode.displayName) - Gap: \(gapHeight)px")
    }
    
    private func getGapHeight(for mode: GameMode) -> CGFloat {
        switch mode {
        case .normal: return 240.0  // Gap normal
        case .basic: return 300.0   // 25% más gap para modo básico
        }
    }
    
    /// Crea un par de tubos y lo configura
    func createPipePair() -> SKNode {
        let pipePair = SKNode()
        pipePair.zPosition = GameConfig.ZPosition.pipes // Asignar Z-Position correcta
        let scaleFactor: CGFloat = 1.6
        let startingX = scene.frame.maxX + 150
        
        // Generar desplazamiento vertical aleatorio limitado
        let maxOffset = scene.frame.size.height * 0.28
        let yOffset = CGFloat.random(in: -maxOffset...maxOffset)
        
        // Crea el tubo superior
        let upperPipe = SKSpriteNode(texture: Pipe.texturaTubo1)
        upperPipe.setScale(scaleFactor)
        upperPipe.position = CGPoint(
            x: startingX,
            y: scene.frame.midY + (gapHeight / 2) + (upperPipe.size.height / 2) + yOffset
        )
        upperPipe.physicsBody = SKPhysicsBody(rectangleOf: upperPipe.size)
        upperPipe.physicsBody?.isDynamic = false
        upperPipe.physicsBody?.categoryBitMask = pipeCategory
        upperPipe.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        upperPipe.physicsBody?.collisionBitMask = PhysicsCategory.bird
        
        // Crea el tubo inferior
        let lowerPipe = SKSpriteNode(texture: Pipe.texturaTubo2)
        lowerPipe.setScale(scaleFactor)
        lowerPipe.position = CGPoint(
            x: startingX,
            y: upperPipe.position.y - upperPipe.size.height - gapHeight
        )
        lowerPipe.physicsBody = SKPhysicsBody(rectangleOf: lowerPipe.size)
        lowerPipe.physicsBody?.isDynamic = false
        lowerPipe.physicsBody?.categoryBitMask = pipeCategory
        lowerPipe.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        lowerPipe.physicsBody?.collisionBitMask = PhysicsCategory.bird
        
        // Agregar al contenedor
        pipePair.addChild(upperPipe)
        pipePair.addChild(lowerPipe)
        
        // Detector de puntuación: un nodo estrecho entre los tubos
        let detectorWidth: CGFloat = 10
        let detectorHeight: CGFloat = scene.frame.height
        let scoreDetector = SKNode()
        scoreDetector.name = "scoreDetector"
        scoreDetector.position = CGPoint(x: startingX, y: scene.frame.midY)
        scoreDetector.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: detectorWidth, height: detectorHeight))
        scoreDetector.physicsBody?.isDynamic = false
        scoreDetector.physicsBody?.categoryBitMask = PhysicsCategory.scoreDetector
        scoreDetector.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        scoreDetector.physicsBody?.collisionBitMask = 0
        pipePair.addChild(scoreDetector)
        
        // Animación de movimiento
        let moveAndRemove = createMoveAndRemoveAction(
            for: scene,
            nodeWidth: upperPipe.size.width,
            movementSpeed: movementSpeed
        )
        pipePair.run(moveAndRemove)
        
        return pipePair
    }
    
    /// Crea la acción de movimiento y eliminación
    private func createMoveAndRemoveAction(for scene: SKScene, nodeWidth: CGFloat, movementSpeed: CGFloat) -> SKAction {
        let distanceToMove = scene.frame.width + nodeWidth * 2
        let moveDuration = distanceToMove / movementSpeed
        
        return SKAction.sequence([
            SKAction.moveBy(x: -distanceToMove, y: 0, duration: TimeInterval(moveDuration)),
            SKAction.removeFromParent()
        ])
    }
}
