import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var isGameOver = false
    
    // MARK: - Constantes de Configuración
    let backgroundSpeed: CGFloat = 30.0 // Fondo lento
    let groundSpeed: CGFloat = 150.0    // Suelo rápido
    
    // MARK: - Propiedades del Escenario
    let birdTexture1 = SKTexture(imageNamed: "redbird-midflap")
    let birdTexture2 = SKTexture(imageNamed: "redbird-downflap")
    let groundTexture = SKTexture(imageNamed: "base")
    let backgroundTexture = SKTexture(imageNamed: "background-day")
    
    // Componentes
    private var birdComponent: BirdComponent!         // Pájaros
    private var groundComponent: GroundComponent!         // Suelo
    private var backgroundComponent: BackgroundComponent!   // Fondo
    private var pipeComponent: PipeComponent!
    private var pipeManager: PipeManager!
    private var restartButton: SKLabelNode!
    
    // MARK: - Ciclo de Vida de la Escena
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        // Configuración del mundo físico
        physicsWorld.gravity = CGVector(dx: 0.0, dy: GameConfig.Physics.gravity)
        physicsWorld.contactDelegate = self
        view.showsPhysics = true // Debug de físicas
        
        setupGameWorld()
        setupComponents()
        setupUI()
        
        // Configuración de los elementos del juego
        pipeManager = PipeManager(scene: self)
        pipeManager.startGeneratingPipes()
    }
    
    private func setupGameWorld() {
        PhysicsManager.configureWorld(for: self, gravity: GameConfig.Physics.gravity)
        PhysicsManager.createBoundary(for: self,
                                      position: CGPoint(x: frame.midX, y: frame.size.height / 2),
                                      size: CGSize(width: frame.size.width, height: 1),
                                      category: PhysicsCategory.top)
    }
    
    private func setupComponents() {
        // Bird Component
        birdComponent = BirdComponent(
            textures: [birdTexture1, birdTexture2],
            position: CGPoint(x: -frame.size.width / 4, y: frame.midY)
        )
        addChild(birdComponent.bird)
        
        groundComponent = GroundComponent(scene: self)
        addChild(groundComponent.createGround())
        
        backgroundComponent = BackgroundComponent(scene: self)
        addChild(backgroundComponent.createBackground())
        
        pipeManager = PipeManager(scene: self)
        pipeManager.startGeneratingPipes()
    }
    
    private func setupUI() {
        restartButton = UIComponent.createRestartButton(in: self)
        addChild(restartButton)
    }
    
    // MARK: - Métodos de Interacción del Usuario
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            handleRestart(touches)
        } else {
            // Lógica existente del salto
            birdComponent.applyImpulse()
        }
    }
    
    private func handleRestart(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if nodes(at: touchLocation).contains(where: { $0.name == "restartButton" }) {
            restartGame()
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
        guard let physicsBody = birdComponent.bird.physicsBody else { return }
        
        let yVelocity = physicsBody.velocity.dy
        let rotationFactor = yVelocity < 0 ? GameConfig.Rotation.downwardFactor : GameConfig.Rotation.upwardFactor
        let targetRotation = yVelocity * rotationFactor
        
        birdComponent.bird.zRotation = clampedRotation(
            value: targetRotation,
            min: GameConfig.Rotation.minAngle,
            max: GameConfig.Rotation.maxAngle
        )
        // Suavizar transicion de rotacion
        let rotateAction = SKAction.rotate(toAngle: targetRotation, duration: 0.2)
        birdComponent.bird.run(rotateAction)
    }
    
    /// Función que limita un valor entre un mínimo y un máximo.
    private func clampedRotation(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.max(min, Swift.min(max, value))
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
        birdComponent.bird.physicsBody?.isDynamic = false
        
        groundComponent?.stopMovement()
        backgroundComponent?.stopMovement()
        pipeManager?.stopAllPipes()
        
        isUserInteractionEnabled = false
    }
    
    private func restartGame() {
        GameState.shared.reset()
        restartButton.isHidden = true
        backgroundComponent.changeBackgroundColor(to: .white)
        
        birdComponent.reset()
        physicsWorld.speed = 1.0
        pipeManager.restart()
        
        // Restablecer estado del juego
        isGameOver = false
        isUserInteractionEnabled = true
    }
}
