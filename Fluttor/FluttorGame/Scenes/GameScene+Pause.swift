import SpriteKit

// MARK: - Pausa/Reanudar
extension GameScene {
    enum OverlayMode { case hidden, initial, paused }

    func configureResumeOverlay(for mode: OverlayMode) {
        guard let overlay = resumeOverlay else { return }
        let resumeButton = overlay.children.first(where: { $0.name == "resumeButton" })
        let startButton = overlay.children.first(where: { $0.name == "startButton" })
        let levelSelectButton = overlay.children.first(where: { $0.name == "pauseLevelSelectButton" })
        let startMessage = overlay.children.first(where: { $0.name == "startMessage" }) as? SKSpriteNode
        let titleLabel = overlay.children.first(where: { $0.name == "resumeTitle" }) as? SKLabelNode
        let hintLabel = overlay.children.first(where: { $0.name == "resumeHint" }) as? SKLabelNode
        
        switch mode {
        case .hidden:
            overlay.isHidden = true
        case .initial:
            overlay.isHidden = false
            resumeButton?.isHidden = true
            startButton?.isHidden = true
            levelSelectButton?.isHidden = true
            startMessage?.isHidden = false
            titleLabel?.isHidden = true
            hintLabel?.removeAllActions()
            hintLabel?.isHidden = true
        case .paused:
            overlay.isHidden = false
            titleLabel?.text = "PAUSA"
            titleLabel?.isHidden = false
            hintLabel?.removeAllActions()
            hintLabel?.isHidden = true
            resumeButton?.isHidden = false
            startButton?.isHidden = false
            levelSelectButton?.isHidden = false
            startMessage?.isHidden = true
        }
        updateResumeOverlayLayout()
    }

    func pauseGame() {
        guard !isGameOver, !isPausedGame else { return }
        isPausedGame = true
        // Pausar físicas y acciones
        physicsWorld.speed = 0
        // Pausar scrolls/componentes explícitamente si usan acciones propias
        groundComponent?.stopMovement()
        backgroundComponent?.stopMovement()
        pipeManager?.pause()
        // Congela aleteo, crecimiento y poder magnético (acciones del pájaro y sus efectos)
        birdComponent?.bird.isPaused = true

        // UI
        configureResumeOverlay(for: .paused)
        pauseButton?.isHidden = true
    }

    func resumeGame() {
        guard isPausedGame else { return }
        let resumingFromInitial = isInitialPauseActive
        isPausedGame = false
        isInitialPauseActive = false

        // Reanudar físicas y acciones
        birdComponent?.bird.isPaused = false
        physicsWorld.speed = 1.0
        groundComponent?.startMovement()
        backgroundComponent?.startMovement()
        if resumingFromInitial {
            // Retrasar ligeramente el primer tubo para empezar rápido
            let base = pipeManager?.spawnInterval ?? GameConfig.Timing.pipeSpawnInterval
            let delay = base * Double(GameConfig.Timing.initialSpawnDelayFactor)
            // El primer tubo es una acción de la escena: si se pausa/reinicia antes, se cancela sola
            pipeManager?.startGeneratingPipes(afterDelay: delay)
        } else {
            pipeManager?.resume()
        }

        // UI
        configureResumeOverlay(for: .hidden)
        if !isGameOver { pauseButton?.isHidden = false }
    }

    func startInitialPause() {
        isPausedGame = true
        isInitialPauseActive = true
        physicsWorld.speed = 0
        groundComponent?.stopMovement()
        backgroundComponent?.stopMovement()
        pipeManager?.stopAllPipes()
        // UI de pausa inicial
        configureResumeOverlay(for: .initial)
        pauseButton?.isHidden = false
    }

    /// Vuelve a la pantalla de selección de nivel (BÁSICO / NORMAL) desde la pausa o el Game Over.
    func showLevelSelectScreen() {
        guard !isWelcomeScreenActive else { return }
        // Reinicia todo el estado de la partida sin sonido de punto (también oculta la UI de Game Over)
        restartGame(playPointSound: false)
        configureResumeOverlay(for: .hidden)
        isInitialPauseActive = false
        showWelcomeScreen()
    }

    func showStartScreenFromPause() {
        // Reiniciar el juego sin sonido de punto y mostrar directamente la pantalla de instrucciones
        restartGame(playPointSound: false)
        startInitialPause()
    }
}
