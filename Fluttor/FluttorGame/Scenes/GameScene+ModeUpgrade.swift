import SpriteKit

// MARK: - Oferta de pasar de BÁSICO a INTERMEDIO
extension GameScene {
    /// Se llama cada vez que cambia el puntaje. Al llegar al umbral en modo BÁSICO, pausa y ofrece el cambio (una vez por partida).
    func checkModeUpgradeOffer() {
        guard currentGameMode == .basic,
              !isTrainingMode,
              !hasOfferedModeUpgrade,
              score >= modeUpgradeScoreThreshold,
              !isGameOver, !isPausedGame, !isWelcomeScreenActive else { return }
        hasOfferedModeUpgrade = true
        // Fuera del callback de contacto de físicas
        DispatchQueue.main.async { [weak self] in
            guard let self = self, !self.isGameOver, !self.isPausedGame else { return }
            self.showModeUpgradeOffer()
        }
    }

    private func showModeUpgradeOffer() {
        pauseGame(showOverlay: false)
        isModeUpgradeOfferActive = true
        let overlay = UIComponent.createModeUpgradeOverlay(in: self, score: score)
        addChild(overlay)
        modeUpgradeOverlay = overlay
        AudioManager.shared.playPointSound()
    }

    /// Procesa toques mientras la oferta está visible (o durante la cuenta regresiva).
    func handleModeUpgradeTouch(_ touches: Set<UITouch>) {
        guard let overlay = modeUpgradeOverlay, let touch = touches.first,
              overlay.childNode(withName: "modeUpgradeCountdown") == nil else { return }
        let names = nodes(at: touch.location(in: self)).compactMap { $0.name }
        if names.contains("modeSwitchNormal") {
            AudioManager.shared.playSwooshSound()
            switchToIntermediateMode()
            startModeUpgradeCountdown()
        } else if names.contains("modeKeepBasic") {
            AudioManager.shared.playSwooshSound()
            startModeUpgradeCountdown()
        }
    }

    private func switchToIntermediateMode() {
        currentGameMode = .normal
        applyGameModePhysics()
        // Los tubos ya generados tienen la separación de BÁSICO: se limpian para que el cambio sea parejo
        pipeManager?.prepareForModeSwitch()
    }

    private func startModeUpgradeCountdown() {
        guard let overlay = modeUpgradeOverlay else { return }
        overlay.children.filter { $0.name != "modeUpgradeDim" }.forEach { $0.removeFromParent() }

        let label = SKLabelNode(text: "3")
        label.name = "modeUpgradeCountdown"
        label.fontName = FontConstants.GameUI.titleFont
        label.fontSize = FontConstants.getAdaptiveFontSize(for: FontConstants.GameUI.titleFontSize * 1.6, fontName: FontConstants.GameUI.titleFont)
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: frame.midX, y: frame.midY)
        overlay.addChild(label)

        let tick = { (n: Int) in SKAction.run { label.text = "\(n)" } }
        let wait = SKAction.wait(forDuration: 0.8)
        label.run(SKAction.sequence([tick(3), wait, tick(2), wait, tick(1), wait,
            SKAction.run { [weak self] in self?.finishModeUpgradeOffer() }]))
    }

    private func finishModeUpgradeOffer() {
        modeUpgradeOverlay?.removeFromParent()
        modeUpgradeOverlay = nil
        isModeUpgradeOfferActive = false
        resumeGame()
    }
}
