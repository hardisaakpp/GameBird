import SpriteKit

// MARK: - Variante del modo BÁSICO (DINÁMICO / ENTRENAMIENTO)
extension GameScene {
    /// Se muestra al tocar BÁSICO en la pantalla de bienvenida.
    func showBasicVariantChoice() {
        guard basicVariantOverlay == nil else { return }
        // Misma esquina superior izquierda que usa el botón de pausa (ya compensa el recorte lateral de la escena)
        repositionPauseButton()
        let backPosition = pauseButton?.position ?? CGPoint(x: frame.minX + 100, y: frame.maxY - 100)
        let overlay = UIComponent.createBasicVariantOverlay(in: self, backButtonPosition: backPosition)
        addChild(overlay)
        basicVariantOverlay = overlay
    }

    func handleBasicVariantTouch(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let names = nodes(at: touch.location(in: self)).compactMap { $0.name }
        if names.contains("basicDynamic") {
            chooseBasicVariant(training: false)
        } else if names.contains("basicTraining") {
            chooseBasicVariant(training: true)
        } else if names.contains("basicBack") {
            AudioManager.shared.playSwooshSound()
            closeBasicVariantChoice()
        }
    }

    private func chooseBasicVariant(training: Bool) {
        AudioManager.shared.playSwooshSound()
        isTrainingMode = training
        closeBasicVariantChoice()
        hideWelcomeScreen(gameMode: .basic)
    }

    private func closeBasicVariantChoice() {
        basicVariantOverlay?.removeFromParent()
        basicVariantOverlay = nil
    }
}
