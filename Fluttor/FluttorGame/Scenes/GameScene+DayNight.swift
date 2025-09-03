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
        // Forzar modo noche por 5 minutos
        BackgroundConstants.forceNightMode(duration: 300)
        
        // Actualizar inmediatamente todos los componentes
        updateBirdAppearanceForDayNight()
        
        // Actualizar fondo
        backgroundComponent?.applyCurrentBackgroundTexture()
    }
    
    func cancelForcedNightMode() {
        // Cancelar modo noche forzado para volver al horario normal
        BackgroundConstants.cancelForcedNightMode()
        
        // Actualizar inmediatamente todos los componentes
        updateBirdAppearanceForDayNight()
        
        // Actualizar fondo
        backgroundComponent?.applyCurrentBackgroundTexture()
    }
}
