import SpriteKit

// MARK: - Day/Night Bird sync
extension GameScene {
    func updateBirdAppearanceForDayNight() {
        guard let birdComponent = birdComponent else { return }
        birdComponent.updateTexturesForCurrentTime()
        birdComponent.restartFlapAnimation()
        
        // Actualizar visibilidad de la luna
        moonComponent?.updateForDayNight()
    }
}
