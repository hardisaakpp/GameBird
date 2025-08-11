import SpriteKit
import UIKit

// MARK: - Ciclo de Vida de la Escena (Optimizada)
extension GameScene {
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
        // Inicio con pantalla de bienvenida
        showWelcomeScreen()
        
        // Precarga de sonidos para mejor rendimiento
        AudioManager.shared.preloadSounds()
        
        // Prueba de carga de sonidos (solo en DEBUG)
        #if DEBUG
        SoundTest.testSoundLoading()
        #endif

        // Cache de dígitos (0-9) para evitar recrear texturas
        preloadDigitTextures()

        // Reposicionar tras el primer ciclo de layout para asegurar safeAreaInsets correctos
        DispatchQueue.main.async { [weak self] in
            self?.repositionScoreDisplay()
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        repositionScoreDisplay()
        repositionPauseButton()
        updateResumeOverlayLayout()
        updateWelcomeOverlayLayout()
        updateGameOverImageLayout()
        updateGameOverScoreLayout()
        // Ajustar dígitos si cambia el tamaño de la escena
        updateFinalScoreDisplay()
    }
}
