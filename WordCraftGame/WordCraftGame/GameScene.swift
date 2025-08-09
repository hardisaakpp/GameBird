import SpriteKit
import UIKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    var isGameOver = false
    private var isPausedGame = false
    private var isInitialPauseActive = false
    
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
    private var pauseButton: SKNode!
    private var resumeOverlay: SKNode!
    // Marcador
    private var score: Int = 0
    private var scoreContainer: SKNode = SKNode()
    private let scoreDigitScale: CGFloat = 2.0
    private let scoreTopMargin: CGFloat = 45
    private let pauseButtonMargin: CGFloat = 16
    private let pauseButtonExtraOffsetX: CGFloat = 72
    // Offsets de layout para overlay de pausa
    private let overlayTitleOffsetY: CGFloat = 90
    private let overlayButtonOffsetY: CGFloat = -10
    private let overlayHintOffsetY: CGFloat = -120
    
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
        // Inicio en pausa hasta que el usuario toque la pantalla
        startInitialPause()
        
        // Precarga de sonidos para mejor rendimiento
        AudioManager.shared.preloadSounds()
        
        // Prueba de carga de sonidos
        SoundTest.testSoundLoading()

        // Reposicionar tras el primer ciclo de layout para asegurar safeAreaInsets correctos
        DispatchQueue.main.async { [weak self] in
            self?.repositionScoreDisplay()
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
    }
    
    private func setupUI() {
        restartButton = UIComponent.createRestartButton(in: self)
        restartButton.isHidden = true // Inicialmente oculto
        addChild(restartButton)

        // Botón de pausa (arriba derecha)
        pauseButton = UIComponent.createPauseButton(in: self)
        pauseButton.setScale(0.9)
        addChild(pauseButton)
        repositionPauseButton()

        // Overlay de reanudación
        resumeOverlay = UIComponent.createResumeOverlay(in: self)
        resumeOverlay.isHidden = true
        addChild(resumeOverlay)

        setupScoreDisplay()
    }

    // MARK: - Marcador (Score)
    private func setupScoreDisplay() {
        score = 0
        scoreContainer.zPosition = 200
        addChild(scoreContainer)
        updateScoreDisplay()
        repositionScoreDisplay()
    }

    private func updateScoreDisplay() {
        // Limpiar dígitos actuales
        scoreContainer.removeAllChildren()
        let scoreString = String(score)
        var digitNodes: [SKSpriteNode] = []

        // Crear nodos por dígito (usa Assets.xcassets/Numbers/{0-9})
        for char in scoreString {
            let digitName = String(char)
            let texture = SKTexture(imageNamed: digitName)
            let node = SKSpriteNode(texture: texture)
            node.setScale(scoreDigitScale)
            digitNodes.append(node)
        }

        // Calcular ancho total para centrar
        let totalWidth: CGFloat = digitNodes.reduce(0) { $0 + $1.frame.width }
        var currentX = -totalWidth / 2

        // Posicionar dígitos dentro del contenedor
        for node in digitNodes {
            node.position = CGPoint(x: currentX + node.frame.width / 2, y: 0)
            scoreContainer.addChild(node)
            currentX += node.frame.width
        }

        repositionScoreDisplay()
    }

    private func repositionScoreDisplay() {
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
        let halfHeight = scoreContainer.calculateAccumulatedFrame().height / 2
        scoreContainer.position = CGPoint(
            x: frame.midX,
            y: frame.maxY - safeTop - halfHeight - scoreTopMargin
        )
    }

    private func repositionPauseButton() {
        guard let view = view else { return }
        // Calcular safe areas
        let windowSafeTop: CGFloat = {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                return keyWindow.safeAreaInsets.top
            }
            return 0
        }()
        let viewSafeLeft = view.safeAreaInsets.left
        let safeTop = max(windowSafeTop, view.safeAreaInsets.top)

        // Posicionar en esquina superior izquierda
        // Usar tamaño mínimo visible si el frame aún no está calculado
        let buttonWidth = max(pauseButton?.frame.width ?? 72, 72)
        let buttonHeight = max(pauseButton?.frame.height ?? 72, 72)
        let x = frame.minX + viewSafeLeft + buttonWidth / 2 + pauseButtonMargin + pauseButtonExtraOffsetX
        let y = frame.maxY - safeTop - buttonHeight / 2 - pauseButtonMargin
        pauseButton?.position = CGPoint(x: x, y: y)
    }

    private func updateResumeOverlayLayout() {
        guard let resumeOverlay = resumeOverlay else { return }
        // Ajustar tamaño de capa oscura al tamaño de la escena
        if let dim = resumeOverlay.children.first(where: { $0 is SKSpriteNode && $0.name == "resumeOverlay" }) as? SKSpriteNode {
            dim.size = frame.size
            dim.position = CGPoint(x: frame.midX, y: frame.midY)
        }
        // Centrar título, hint y botón con mayor separación vertical
        resumeOverlay.children.forEach { child in
            if let label = child as? SKLabelNode, label.name == "resumeTitle" {
                label.position = CGPoint(x: frame.midX, y: frame.midY + overlayTitleOffsetY)
            }
            if let label = child as? SKLabelNode, label.name == "resumeHint" {
                label.position = CGPoint(x: frame.midX, y: frame.midY + overlayHintOffsetY)
            }
            if child.name == "resumeButton" {
                child.position = CGPoint(x: frame.midX, y: frame.midY + overlayButtonOffsetY)
            }
            if let sprite = child as? SKSpriteNode, sprite.name == "startMessage" {
                sprite.position = CGPoint(x: frame.midX, y: frame.midY)
                // Recalcular escala por si cambia el tamaño
                if sprite.size.width > 0 {
                    let maxWidth = frame.width * 0.8
                    let scale = min(1.0, maxWidth / sprite.size.width)
                    sprite.setScale(scale)
                }
            }
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        repositionScoreDisplay()
        repositionPauseButton()
        updateResumeOverlayLayout()
    }
    
    // MARK: - Métodos de Interacción del Usuario (Optimizada)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        // Optimización: Procesar inmediatamente sin verificar ubicación
        if isGameOver {
            handleRestart(touches)
            return
        }

        // Manejo de pausa
        if isPausedGame {
            if isInitialPauseActive {
                // Cualquier toque reanuda el juego al inicio
                resumeGame()
                return
            }
            if let resumeOverlay = resumeOverlay,
               resumeOverlay.contains(touchLocation),
               nodes(at: touchLocation).contains(where: { $0.name == "resumeButton" }) {
                let buttonContainer = resumeOverlay.children.first(where: { $0.name == "resumeButton" })
                let scaleDown = SKAction.scale(to: 0.95, duration: 0.05)
                let scaleUp = SKAction.scale(to: 1.0, duration: 0.05)
                (buttonContainer ?? resumeOverlay).run(SKAction.sequence([scaleDown, scaleUp])) { [weak self] in
                    self?.resumeGame()
                }
            }
            return
        } else {
            // Si toca el botón de pausa
            if nodes(at: touchLocation).contains(where: { $0.name == "pauseButton" }) {
                let scaleDown = SKAction.scale(to: 0.9, duration: 0.05)
                let scaleUp = SKAction.scale(to: 1.0, duration: 0.05)
                pauseButton.run(SKAction.sequence([scaleDown, scaleUp])) { [weak self] in
                    self?.pauseGame()
                }
            } else {
                // Optimización: Ejecutar acciones en paralelo
                DispatchQueue.main.async {
                    self.birdComponent.applyImpulse()
                    AudioManager.shared.playWingSound()
                }
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
            score += 1
            updateScoreDisplay()
            
        default:
            break
        }
    }
    
    private func handlePipeCollision() {
        // Evitar múltiples colisiones
        guard !isGameOver else { return }
        isGameOver = true
        pauseButton?.isHidden = true
        
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
        pauseButton?.isHidden = true
        
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
        pauseButton?.isHidden = true
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
        
        // Reiniciar marcador al reiniciar el juego
        score = 0
        updateScoreDisplay()
        
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
        pauseButton?.isHidden = false
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

    // MARK: - Pausa/Reanudar
    private func pauseGame() {
        guard !isGameOver, !isPausedGame else { return }
        isPausedGame = true
        // Pausar físicas y acciones
        physicsWorld.speed = 0
        // Pausar scrolls/componentes explícitamente si usan acciones propias
        groundComponent?.stopMovement()
        backgroundComponent?.stopMovement()
        pipeManager?.pause()

        // UI
        resumeOverlay.isHidden = false
        updateResumeOverlayLayout()
        pauseButton?.isHidden = true
        // Configurar textos del overlay para pausa normal
        if let titleLabel = resumeOverlay.children.first(where: { $0.name == "resumeTitle" }) as? SKLabelNode {
            titleLabel.text = "PAUSA"
            titleLabel.isHidden = false
        }
        if let hintLabel = resumeOverlay.children.first(where: { $0.name == "resumeHint" }) as? SKLabelNode {
            hintLabel.removeAction(forKey: "blink")
            hintLabel.alpha = 1.0
            hintLabel.text = "Toca REANUDAR"
            hintLabel.isHidden = false
        }
        if let resumeButton = resumeOverlay.children.first(where: { $0.name == "resumeButton" }) {
            resumeButton.isHidden = false
        }
        if let startMessage = resumeOverlay.children.first(where: { $0.name == "startMessage" }) as? SKSpriteNode {
            startMessage.isHidden = true
        }
    }

    private func resumeGame() {
        guard isPausedGame else { return }
        let resumingFromInitial = isInitialPauseActive
        isPausedGame = false
        isInitialPauseActive = false

        // Reanudar físicas y acciones
        physicsWorld.speed = 1.0
        groundComponent?.startMovement()
        backgroundComponent?.startMovement()
        if resumingFromInitial {
            // Retrasar ligeramente el primer tubo para empezar rápido
            let base = pipeManager?.spawnInterval ?? GameConfig.Timing.pipeSpawnInterval
            let delay = base * Double(GameConfig.Timing.initialSpawnDelayFactor)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.pipeManager?.startGeneratingPipes()
            }
        } else {
            pipeManager?.resume()
        }

        // UI: si venía de pausa inicial, vuelve a mostrar el botón para próximas pausas
        if let resumeButton = resumeOverlay.children.first(where: { $0.name == "resumeButton" }) {
            resumeButton.isHidden = false
        }
        if let startMessage = resumeOverlay.children.first(where: { $0.name == "startMessage" }) as? SKSpriteNode {
            startMessage.isHidden = true
        }
        resumeOverlay.isHidden = true
        if !isGameOver { pauseButton?.isHidden = false }
    }

    private func startInitialPause() {
        isPausedGame = true
        isInitialPauseActive = true
        physicsWorld.speed = 0
        groundComponent?.stopMovement()
        backgroundComponent?.stopMovement()
        pipeManager?.stopAllPipes()
        // Mostrar overlay en la pausa inicial; ocultar el botón de reanudar
        resumeOverlay.isHidden = false
        if let resumeButton = resumeOverlay.children.first(where: { $0.name == "resumeButton" }) {
            resumeButton.isHidden = true
        }
        // Mostrar imagen de mensaje y ocultar textos
        if let startMessage = resumeOverlay.children.first(where: { $0.name == "startMessage" }) as? SKSpriteNode {
            startMessage.isHidden = false
        }
        if let titleLabel = resumeOverlay.children.first(where: { $0.name == "resumeTitle" }) as? SKLabelNode {
            titleLabel.isHidden = true
        }
        if let hintLabel = resumeOverlay.children.first(where: { $0.name == "resumeHint" }) as? SKLabelNode {
            hintLabel.removeAllActions()
            hintLabel.isHidden = true
        }
        pauseButton?.isHidden = false
        updateResumeOverlayLayout()
    }
}

// MARK: - Day/Night Bird sync
extension GameScene {
    func updateBirdAppearanceForDayNight() {
        guard let birdComponent = birdComponent else { return }
        birdComponent.updateTexturesForCurrentTime()
        birdComponent.restartFlapAnimation()
    }
}
