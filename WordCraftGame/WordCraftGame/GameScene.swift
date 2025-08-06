import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var isGameOver = false
    var isGamePaused = false // Nueva propiedad para manejar el estado de pausa
    
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
    private var restartButton: SKNode!
    private var pauseButton: SKNode! // Nuevo botón de pausa
    private var pauseMenu: SKNode! // Menú de pausa
    
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
        backgroundComponent = BackgroundComponent(scene: self)
        addChild(backgroundComponent.createBackground())
        
        groundComponent = GroundComponent(scene: self)
        addChild(groundComponent.createGround())
        
        // Bird Component
        birdComponent = BirdComponent(
            textures: [birdTexture1, birdTexture2],
            position: CGPoint(x: -frame.size.width / 4, y: frame.midY)
        )
        addChild(birdComponent.bird)
        
        pipeManager = PipeManager(scene: self)
        pipeManager.startGeneratingPipes()
    }
    
    private func setupUI() {
        restartButton = UIComponent.createRestartButton(in: self)
        restartButton.isHidden = true // Inicialmente oculto
        addChild(restartButton)
        
        // Botón de pausa
        pauseButton = UIComponent.createPauseButton(in: self)
        addChild(pauseButton)
        
        // Menú de pausa
        pauseMenu = UIComponent.createPauseMenu(in: self)
        pauseMenu.isHidden = true
        addChild(pauseMenu)
    }
    
    // MARK: - Métodos de Interacción del Usuario
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if isGameOver {
            handleRestart(touches)
        } else if isGamePaused {
            handlePauseMenuTouches(touches)
        } else {
            // Verificar si se tocó el botón de pausa
            if pauseButton.contains(touchLocation) {
                pauseGame()
            } else {
                // Lógica existente del salto
                birdComponent.applyImpulse()
            }
        }
    }
    
    private func handlePauseMenuTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        // Buscar directamente los botones en el menú de pausa
        for child in pauseMenu.children {
            // Convertir la ubicación del toque al sistema de coordenadas del nodo hijo
            let localLocation = child.convert(touchLocation, from: self)
            
            if child.contains(localLocation) {
                // Verificar si es un botón basándose en el nombre de sus nodos hijos
                for grandChild in child.children {
                    if grandChild.name?.contains("resumeButton") == true {
                        print("Botón CONTINUAR tocado")
                        resumeGame()
                        return
                    } else if grandChild.name?.contains("restartFromPauseButton") == true {
                        print("Botón REINICIAR tocado")
                        restartFromPause()
                        return
                    }
                }
            }
        }
    }
    
    // MARK: - Sistema de Pausa
    private func pauseGame() {
        guard !isGameOver && !isGamePaused else { return }
        
        isGamePaused = true
        physicsWorld.speed = 0
        birdComponent.bird.physicsBody?.isDynamic = false
        
        // Pausar movimiento de componentes
        groundComponent?.stopMovement()
        backgroundComponent?.stopMovement()
        pipeManager?.pausePipes() // Cambiar a pausePipes() para mantener las acciones
        
        // Mostrar menú de pausa con animación
        pauseMenu.isHidden = false
        pauseMenu.alpha = 0.0
        pauseMenu.run(SKAction.fadeIn(withDuration: 0.3))
        
        // Ocultar botón de pausa
        pauseButton.isHidden = true
    }
    
    private func resumeGame() {
        isGamePaused = false
        physicsWorld.speed = 1.0
        birdComponent.bird.physicsBody?.isDynamic = true
        
        // Reiniciar movimiento de componentes
        groundComponent?.startMovement()
        backgroundComponent?.startMovement()
        pipeManager?.resumePipes() // Usar el nuevo método específico
        
        // Ocultar menú de pausa con animación
        pauseMenu.run(SKAction.fadeOut(withDuration: 0.2)) {
            self.pauseMenu.isHidden = true
        }
        
        // Mostrar botón de pausa
        pauseButton.isHidden = false
    }
    
    private func restartFromPause() {
        isGamePaused = false
        pauseMenu.isHidden = true
        pauseButton.isHidden = false
        restartGame()
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
        
        // Verificar colisión con tubo - hacer que el pájaro caiga
        if collisionMask == (PhysicsCategory.bird | PhysicsCategory.pipe) {
            guard !isGameOver else { return }
            
            print("¡Colisión con tubo! El pájaro cae...")
            handlePipeCollision()
            return
        }
        
        // Verificar colisión con el suelo - game over definitivo
        if collisionMask == (PhysicsCategory.bird | PhysicsCategory.ground) {
            guard !isGameOver else { return }
            
            print("¡Game Over! Pájaro tocó el suelo")
            triggerGameOver()
        }
    }
    
    private func handlePipeCollision() {
        // Evitar múltiples colisiones
        guard !isGameOver else { return }
        isGameOver = true
        
        // Detener la generación de nuevos tubos pero mantener los existentes
        pipeManager?.stopAllPipes()
        
        // Detener movimiento del fondo y suelo
        groundComponent?.stopMovement()
        backgroundComponent?.stopMovement()
        
        // Configurar el pájaro para que caiga dramáticamente
        if let birdPhysics = birdComponent.bird.physicsBody {
            // Reducir la masa para una caída más dramática
            birdPhysics.mass = 0.1
            
            // Aplicar un impulso hacia abajo y ligeramente hacia atrás
            let fallImpulse = CGVector(dx: -50, dy: -200)
            birdPhysics.applyImpulse(fallImpulse)
            
            // Permitir rotación para efecto dramático
            birdPhysics.allowsRotation = true
            birdPhysics.angularVelocity = -3.0 // Rotación hacia atrás
            
            // Reducir la fricción para que caiga más rápido
            birdPhysics.linearDamping = 0.1
        }
        
        // Cambiar el color de fondo para indicar el impacto
        backgroundComponent?.changeBackgroundColor(to: .red)
        
        // Efecto visual de impacto
        addImpactEffect()
        
        // Mostrar el botón de reinicio con un temporizador de seguridad
        // Esto asegura que siempre aparezca, independientemente de si toca el suelo
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.isGameOver && self.restartButton.isHidden {
                self.showRestartButton()
            }
        }
    }
    
    private func triggerGameOver() {
        // Solo ejecutar si no se ha ejecutado ya
        guard isGameOver else { return }
        
        print("¡Game Over final!")
        
        // Detener completamente el pájaro
        birdComponent.bird.physicsBody?.isDynamic = false
        
        // Mostrar botón de reinicio con delay para dramatismo
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showRestartButton()
        }
    }
    
    private func addImpactEffect() {
        // Efecto de vibración/sacudida de la pantalla
        let shakeAction = SKAction.sequence([
            SKAction.moveBy(x: -5, y: 0, duration: 0.05),
            SKAction.moveBy(x: 10, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.05),
            SKAction.moveBy(x: 5, y: 0, duration: 0.05),
            SKAction.moveBy(x: 0, y: 0, duration: 0.05)
        ])
        
        // Aplicar shake a la cámara/escena
        self.run(shakeAction)
        
        // Efecto de flash blanco
        let flashOverlay = SKSpriteNode(color: .white, size: frame.size)
        flashOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
        flashOverlay.alpha = 0.0
        flashOverlay.zPosition = 100
        
        addChild(flashOverlay)
        
        let flashEffect = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 0.05),
            SKAction.fadeAlpha(to: 0.0, duration: 0.2),
            SKAction.removeFromParent()
        ])
        
        flashOverlay.run(flashEffect)
    }
    
    func showRestartButton() {
        // Animación de elementos del juego
        let dimAction = SKAction.customAction(withDuration: 0.1) { node, _ in
            if let sprite = node as? SKSpriteNode {
                sprite.color = .darkGray
            }
        }
        
        // Aplicar a elementos principales (excepto botón)
        children.filter { $0.name != "restartButton" }.forEach {
            $0.run(dimAction)
        }
        
        // Mostrar y animar botón
        restartButton.isHidden = false
        restartButton.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1.1, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
    }
    
    private func hideRestartButton() {
        // Restaurar elementos del juego
        let restoreAction = SKAction.customAction(withDuration: 0.1) { node, _ in
            if let sprite = node as? SKSpriteNode {
                sprite.colorBlendFactor = 0.0
            }
        }
        children.forEach { $0.run(restoreAction) }
    }
    
    func stopAllGameElements() {
        physicsWorld.speed = 0
        birdComponent.bird.physicsBody?.isDynamic = false
        
        groundComponent?.stopMovement()
        backgroundComponent?.stopMovement()
        pipeManager?.stopAllPipes()
        
        // Mostrar botón y habilitar interacción
        showRestartButton()
        isUserInteractionEnabled = true // Permitir tocar el botón
    }
    
    private func restartGame() {
        restartButton.isHidden = true
        // Resetear estado general
        isGameOver = false
        physicsWorld.speed = 1.0
        removeAllActions()
        
        // Limpiar elementos antiguos
        children.forEach { node in
            if node.name == "pipe" || node.name == "scoreDetector" {
                node.removeFromParent()
            }
        }
        
        // Reiniciar componentes
        birdComponent.reset()
        groundComponent.reset()
        backgroundComponent.reset()
        backgroundComponent.resetBackgroundColor()
        pipeManager.removeAllPipes() // Limpieza adicional
        pipeManager.restart()
        
        // Restaurar UI
        hideRestartButton()
        backgroundComponent.reset()
        birdComponent.bird.physicsBody?.isDynamic = true
    }
    
    private func handleRestart(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if restartButton.contains(touchLocation) {
            // Feedback visual
            let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
            
            restartButton.run(SKAction.sequence([scaleDown, scaleUp])) {
                self.restartButton.isHidden = true
                self.restartGame()
            }
        }
    }
}
