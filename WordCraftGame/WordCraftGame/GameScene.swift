import SpriteKit
import UIKit
import AVFoundation

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
    private var restartButton: SKNode!
    private var scoreImageNode: SKSpriteNode?
    
    // MARK: - Ciclo de Vida de la Escena (Optimizada)
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Optimización: Configuración de física optimizada
        physicsWorld.gravity = CGVector(dx: 0.0, dy: GameConfig.Physics.gravity)
        physicsWorld.contactDelegate = self
        physicsWorld.speed = 1.0
        
        // Optimización: Desactivar debug de físicas en producción
        view.showsPhysics = false // Cambiar a false para mejor rendimiento
        
        setupGameWorld()
        setupComponents()
        setupUI()
        
        // Configuración de los elementos del juego
        pipeManager = PipeManager(scene: self)
        pipeManager.startGeneratingPipes()
        
        // Precarga de sonidos para mejor rendimiento
        AudioManager.shared.preloadSounds()
        
        // Prueba de carga de sonidos
        SoundTest.testSoundLoading()

        // Reposicionar tras el primer ciclo de layout para asegurar safeAreaInsets correctos
        DispatchQueue.main.async { [weak self] in
            self?.repositionScoreImageNode()
        }
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

        setupTopCenterZero()
    }

    private func setupTopCenterZero() {
        // Crear sprite con la imagen "0" del catálogo de assets
        let zeroTexture = SKTexture(imageNamed: "0")
        let zeroNode = SKSpriteNode(texture: zeroTexture)
        zeroNode.zPosition = 200
        zeroNode.setScale(2.0) // Duplicar tamaño
        scoreImageNode = zeroNode
        addChild(zeroNode)
        repositionScoreImageNode()
    }

    private func repositionScoreImageNode() {
        guard let zeroNode = scoreImageNode else { return }
        // Priorizar safeArea de la ventana (mejor para Dynamic Island/notch)
        let windowSafeTop: CGFloat = {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                return keyWindow.safeAreaInsets.top
            }
            return 0
        }()
        let viewSafeTop = view?.safeAreaInsets.top ?? 0
        let safeTop = max(windowSafeTop, viewSafeTop)

        // Margen adicional para quedar claramente debajo de la Dynamic Island
        let topMargin: CGFloat = 45
        let halfHeight = zeroNode.frame.height / 2 // Usar frame para considerar el escalado
        zeroNode.position = CGPoint(
            x: frame.midX,
            y: frame.maxY - safeTop - halfHeight - topMargin
        )
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        repositionScoreImageNode()
    }
    
    // MARK: - Métodos de Interacción del Usuario (Optimizada)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Optimización: Procesar inmediatamente sin verificar ubicación
        if isGameOver {
            handleRestart(touches)
        } else {
            // Optimización: Ejecutar acciones en paralelo
            DispatchQueue.main.async {
                self.birdComponent.applyImpulse()
                AudioManager.shared.playWingSound()
            }
        }
    }
    
    // MARK: - Actualización y Lógica del Juego (Optimizada)
    override func update(_ currentTime: TimeInterval) {
        // Monitoreo de rendimiento
        PerformanceMonitor.shared.updateFrame()
        
        guard let physicsBody = birdComponent.bird.physicsBody else { return }
        
        // Optimización: Calcular rotación solo si es necesario
        let yVelocity = physicsBody.velocity.dy
        let rotationFactor = yVelocity < 0 ? GameConfig.Rotation.downwardFactor : GameConfig.Rotation.upwardFactor
        let targetRotation = clampedRotation(
            value: yVelocity * rotationFactor,
            min: GameConfig.Rotation.minAngle,
            max: GameConfig.Rotation.maxAngle
        )
        
        // Optimización: Aplicar rotación directamente sin SKAction
        birdComponent.bird.zRotation = targetRotation
    }
    
    /// Función que limita un valor entre un mínimo y un máximo.
    private func clampedRotation(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.max(min, Swift.min(max, value))
    }
}

// MARK: - SKPhysicsContactDelegate
extension GameScene {
    func didBegin(_ contact: SKPhysicsContact) {
        // Optimización: Verificar game over primero para evitar procesamiento innecesario
        guard !isGameOver else { return }
        
        let collisionMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // Optimización: Usar switch para mejor rendimiento
        switch collisionMask {
        case PhysicsCategory.bird | PhysicsCategory.pipe:
            print("¡Colisión con tubo! El pájaro cae...")
            AudioManager.shared.playHitSound()
            // Reproducir "die" justo después del impacto
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                AudioManager.shared.playDieSound()
            }
            handlePipeCollision()
            
        case PhysicsCategory.bird | PhysicsCategory.ground:
            print("¡Game Over! Pájaro tocó el suelo")
            AudioManager.shared.playHitSound()
            triggerGameOver()

        case PhysicsCategory.bird | PhysicsCategory.scoreDetector:
            print("¡Punto! Ave cruzó el hueco")
            AudioManager.shared.playPointSound()
            
        default:
            break
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
        guard !isGameOver else { return }
        
        print("¡Game Over final!")
        isGameOver = true
        
        // Detener la generación de nuevos tubos
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
        
        // Sonido de punto cuando se reinicia el juego
        AudioManager.shared.playPointSound()
        
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
            // Sonido de botón presionado
            AudioManager.shared.playSwooshSound()
            
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
