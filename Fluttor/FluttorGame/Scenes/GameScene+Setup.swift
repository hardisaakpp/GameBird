import SpriteKit

// MARK: - Setup Mundo y Componentes
extension GameScene {
    func topSafeAreaInset() -> CGFloat {
        let windowTop: CGFloat = {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                return keyWindow.safeAreaInsets.top
            }
            return 0
        }()
        let viewTop = view?.safeAreaInsets.top ?? 0
        return max(windowTop, viewTop)
    }

    func setupGameWorld() {
        PhysicsManager.configureWorld(for: self, gravity: GameConfig.Physics.gravity)
        PhysicsManager.createBoundary(for: self,
                                      position: CGPoint(x: frame.midX, y: frame.size.height / 2),
                                      size: CGSize(width: frame.size.width, height: 1),
                                      category: PhysicsCategory.top)
    }
    
    func setupComponents() {
        backgroundComponent = BackgroundComponent(scene: self)
        addChild(backgroundComponent.createBackground())
        
        groundComponent = GroundComponent(scene: self)
        addChild(groundComponent.createGround())
        
        // Moon Component
        moonComponent = MoonComponent(scene: self)
        moonComponent.updateForDayNight() // Mostrar/ocultar según hora actual
        
        // Bird Component
        birdComponent = BirdComponent(
            textures: [birdTexture1, birdTexture2],
            position: CGPoint(x: -frame.size.width / 4, y: frame.midY)
        )
        addChild(birdComponent.bird)
    }
}
