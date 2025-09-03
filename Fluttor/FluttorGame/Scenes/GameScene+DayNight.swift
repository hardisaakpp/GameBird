import SpriteKit

// MARK: - Day/Night Bird sync
extension GameScene {
    func updateBirdAppearanceForDayNight() {
        guard let birdComponent = birdComponent else { return }
        birdComponent.updateTexturesForCurrentTime()
        birdComponent.restartFlapAnimation()
        
        // Actualizar visibilidad de la luna y el sol
        moonComponent?.updateForDayNight()
        sunComponent?.updateForDayNight()
    }
    
    func forceDayMode() {
        // Forzar modo día por 5 minutos
        BackgroundConstants.forceDayMode(duration: 300)
        
        // Actualizar inmediatamente todos los componentes
        updateBirdAppearanceForDayNight()
        
        // Actualizar fondo
        backgroundComponent?.applyCurrentBackgroundTexture()
    }
    
    func forceNightMode() {
        // Cancelar modo día forzado para volver al horario normal
        BackgroundConstants.cancelForcedDayMode()
        
        // Actualizar inmediatamente todos los componentes
        updateBirdAppearanceForDayNight()
        
        // Actualizar fondo
        backgroundComponent?.applyCurrentBackgroundTexture()
    }
}
