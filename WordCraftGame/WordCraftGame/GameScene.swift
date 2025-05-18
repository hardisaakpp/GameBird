import SpriteKit

// MARK: - Constantes Globales del Escenario
struct RotationSettings {
    static let minAngle: CGFloat = -1.0           // Rotación máxima hacia abajo
    static let maxAngle: CGFloat = 0.5            // Rotación máxima hacia arriba
    static let downwardFactor: CGFloat = 0.003    // Factor de rotación al caer
    static let upwardFactor: CGFloat = 0.001      // Factor de rotación al subir
}

// MARK: - Categorías de Física
struct PhysicsCategory {
    static let bird: UInt32 = 1 << 0     // 1
    static let ground: UInt32 = 1 << 1  // 2
    static let top: UInt32 = 1 << 2    // 4
    static let pipe: UInt32 = 1 << 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var isGameOver = false
    
    // MARK: - Constantes de Configuración
    let gravity: CGFloat = -5.0
    let birdImpulse: CGFloat = 50.0
    let groundOffsetX: CGFloat = -240
    let groundOffsetY: CGFloat = -760
    let backgroundSpeed: CGFloat = 30.0 // Fondo lento
    let groundSpeed: CGFloat = 150.0    // Suelo rápido

    // MARK: - Propiedades del Escenario
    var bird = SKSpriteNode()
    let birdTexture1 = SKTexture(imageNamed: "redbird-midflap")
    let birdTexture2 = SKTexture(imageNamed: "redbird-downflap")
    let groundTexture = SKTexture(imageNamed: "base")
    let backgroundTexture = SKTexture(imageNamed: "background-day")
    
    var restartButton: SKLabelNode!
    
    // Componentes
    private var groundComponent: GroundComponent?         // Suelo
    private var backgroundComponent: BackgroundComponent?   // Fondo
    private var pipeComponent: PipeComponent?
    var pipeManager: PipeManager!

    // MARK: - Ciclo de Vida de la Escena
    override func didMove(to view: SKView) {
        // Configuración del mundo físico
        physicsWorld.gravity = CGVector(dx: 0.0, dy: gravity)
        physicsWorld.contactDelegate = self
        view.showsPhysics = true // Debug de físicas

        // Configuración de los elementos del juego
        configureGround()
        configureBackground()
        configureTopBoundary()
        
        configureBird()
        pipeManager = PipeManager(scene: self)
        pipeManager.startGeneratingPipes()
        configureRestartButton()
    }

    // MARK: - Configuración de Elementos del Juego

    /// Configura al pájaro, sus texturas, animación y cuerpo físico.
    func configureBird() {
        birdTexture1.filteringMode = .nearest
        birdTexture2.filteringMode = .nearest

        let flapAnimation = SKAction.animate(with: [birdTexture1, birdTexture2], timePerFrame: 0.2)
        let flyAction = SKAction.repeatForever(flapAnimation)
        
        bird = SKSpriteNode(texture: birdTexture1)
        bird.setScale(2.0)
        bird.position = CGPoint(x: -frame.size.width / 4, y: frame.midY)
        bird.run(flyAction)
        
        // Configuración del cuerpo físico del pájaro
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.categoryBitMask = PhysicsCategory.bird
        bird.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.top | PhysicsCategory.pipe
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.pipe
        bird.physicsBody?.restitution = 0.5

        addChild(bird)
    }
    
    /// Configura el suelo utilizando su componente.
    func configureGround() {
        groundComponent = GroundComponent(scene: self)
        let ground = groundComponent!.createGround()
        addChild(ground)
    }
    
    /// Configura el fondo utilizando su componente.
    func configureBackground() {
        backgroundComponent = BackgroundComponent(scene: self)
        let background = backgroundComponent!.createBackground()
        addChild(background)
    }
    
    /// Configura los tubos utilizando el PipeComponent
    func configurePipes() {
        pipeComponent = PipeComponent(scene: self)
        let pipePair = pipeComponent!.createPipePair()
        addChild(pipePair)
    }
    
    /// Configura la barrera superior que limita el movimiento del pájaro.
    func configureTopBoundary() {
        let topBoundary = SKNode()
        topBoundary.position = CGPoint(x: frame.midX, y: frame.size.height / 2)
        topBoundary.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.size.width, height: 1))
        topBoundary.physicsBody?.isDynamic = false
        topBoundary.physicsBody?.categoryBitMask = PhysicsCategory.top
        topBoundary.physicsBody?.collisionBitMask = PhysicsCategory.bird
        addChild(topBoundary)
    }
    
    // MARK: - Métodos de Interacción del Usuario
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            guard let touch = touches.first else { return }
            let touchLocation = touch.location(in: self)
            
            // Verificar toque en el botón
            if nodes(at: touchLocation).contains(where: { $0.name == "restartButton" }) {
                restartGame()
            }
        } else {
            // Lógica existente del salto
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: birdImpulse))
        }
    }
    
    func configureRestartButton() {
        restartButton = SKLabelNode(text: "Reiniciar")
        restartButton.name = "restartButton"
        restartButton.position = CGPoint(x: frame.midX, y: frame.midY)
        restartButton.fontSize = 40
        restartButton.fontColor = .white
        restartButton.isHidden = true
        addChild(restartButton)
    }
    
    // MARK: - Actualización y Lógica del Juego
    override func update(_ currentTime: TimeInterval) {
        guard let physicsBody = bird.physicsBody else { return }
        
        let yVelocity = physicsBody.velocity.dy
        let rotationFactor = yVelocity < 0 ? RotationSettings.downwardFactor : RotationSettings.upwardFactor
        let targetRotation = yVelocity * rotationFactor
        
        bird.zRotation = clampedRotation(
            value: targetRotation,
            min: RotationSettings.minAngle,
            max: RotationSettings.maxAngle
        )
    }
    
    /// Función que limita un valor entre un mínimo y un máximo.
    func clampedRotation(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        if value < min {
            return min
        } else if value > max {
            return max
        } else {
            return value
        }
    }
}

// MARK: - SKPhysicsContactDelegate
extension GameScene {
    func didBegin(_ contact: SKPhysicsContact) {
        let collisionMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // Verifica si el pájaro (1) colisionó con el suelo (2)
        if collisionMask == (PhysicsCategory.bird | PhysicsCategory.ground) || collisionMask == (PhysicsCategory.bird | PhysicsCategory.pipe) {
            
            guard !isGameOver else { return }
            isGameOver = true
            
            print("¡Game Over!")
            backgroundComponent!.changeBackgroundColor(to: .red)
            showRestartButton()
            stopAllGameElements()
        }
    }
    
    func showRestartButton() {
        restartButton.isHidden = false
    }
    
    func stopAllGameElements() {
        physicsWorld.speed = 0
        bird.physicsBody?.isDynamic = false
        
        groundComponent?.stopMovement()
        backgroundComponent?.stopMovement()
        pipeManager?.stopAllPipes()
        
        isUserInteractionEnabled = false
    }
    
    func restartGame() {
        // Restablecer estado del juego
        isGameOver = false
        restartButton.isHidden = true
        backgroundComponent?.changeBackgroundColor(to: .white)
        
        // Reiniciar pájaro
        bird.position = CGPoint(x: -frame.size.width / 4, y: frame.midY)
        bird.zRotation = 0
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.velocity = .zero
        bird.physicsBody?.angularVelocity = 0
        
        // Reiniciar física
        physicsWorld.speed = 1.0
        
        // Reiniciar componentes
        // groundComponent?.startMovement()
        // backgroundComponent?.startMovement()
        pipeManager?.removeAllPipes()
        pipeManager?.startGeneratingPipes()
        
        // Restablecer contactos
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.pipe
    }
}
