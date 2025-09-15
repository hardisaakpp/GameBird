import SpriteKit

// MARK: - Game Over y Efectos
extension GameScene {
    func addImpactEffect() {
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
        // Ocultar el marcador principal en la pantalla de Game Over
        scoreContainer.isHidden = true
        
        // Mostrar sombreado Game Over con transparencia similar a pausa (0.65)
        if let dim = gameOverDim {
            dim.isHidden = false
            dim.removeAllActions()
            dim.alpha = 0.0
            dim.run(SKAction.fadeAlpha(to: 0.65, duration: 0.2))
        }
        
        // Mostrar imagen Game Over
        if let img = gameOverImage {
            img.isHidden = false
            img.alpha = 0.0
            let fadeIn = SKAction.fadeIn(withDuration: 0.25)
            let pop = SKAction.sequence([
                SKAction.scale(by: 1.05, duration: 0.15),
                SKAction.scale(by: 1.0/1.05, duration: 0.1)
            ])
            img.run(SKAction.group([fadeIn, pop]))
        }
        
        // Mostrar y animar botón
        restartButton?.isHidden = false
        pauseButton?.isHidden = true
        restartButton?.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1.1, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
        
        // Actualizar y mostrar los dígitos del puntaje final
        updateFinalScoreDisplay()
        finalScoreContainer.isHidden = false
        finalScoreContainer.alpha = 0.0
        finalScoreContainer.run(SKAction.fadeIn(withDuration: 0.25))
        
        // Mostrar el mejor puntaje
        showHighScoreDisplay()
    }

    func hideRestartButton() {
        // Mostrar nuevamente el marcador principal
        scoreContainer.isHidden = false
        
        // Ocultar imagen y sombreado Game Over
        if let img = gameOverImage {
            img.removeAllActions()
            img.isHidden = true
            img.alpha = 1.0
        }
        if let dim = gameOverDim {
            dim.removeAllActions()
            dim.isHidden = true
            dim.alpha = 0.65
        }
        // Ocultar dígitos del puntaje final
        finalScoreContainer.removeAllActions()
        finalScoreContainer.isHidden = true
        finalScoreContainer.alpha = 1.0
        
        // Ocultar high score
        if let highScoreContainer = highScoreContainer {
            highScoreContainer.removeAllActions()
            highScoreContainer.isHidden = true
            highScoreContainer.alpha = 1.0
        }
    }

    func updateFinalScoreDisplay() {
        // Mostrar los dígitos del puntaje final
        finalScoreContainer.isHidden = false

        // Posición: centrado horizontalmente, debajo del botón de reiniciar
        let restartButtonY = restartButton?.position.y ?? frame.midY
        let offsetY: CGFloat = -80 // Debajo del botón de reiniciar
        finalScoreContainer.position = CGPoint(x: frame.midX, y: restartButtonY + offsetY)

        // Si no cambió el puntaje, no reconstruir los hijos
        if lastFinalScoreRendered == score && !finalScoreContainer.children.isEmpty {
            return
        }

        finalScoreContainer.removeAllChildren()

        let scoreString = String(score)
        var digitNodes: [SKSpriteNode] = []
        for ch in scoreString {
            let texture = digitTextures[ch] ?? SKTexture(imageNamed: String(ch))
            if digitTextures[ch] == nil { digitTextures[ch] = texture }
            let node = SKSpriteNode(texture: texture)
            digitNodes.append(node)
        }
        // Evitar división entre cero
        let baseTotalWidth = digitNodes.reduce(CGFloat(0)) { $0 + $1.size.width }
        guard baseTotalWidth > 0 else { return }

        // Calcular escala fija para los dígitos del puntaje
        let scale = finalScoreScaleFactor * 1.5 // Un poco más grande sin el tablero

        // Centrar los dígitos horizontalmente
        let totalScaledWidth = baseTotalWidth * scale
        var currentX = -totalScaledWidth / 2.0 // Empezar desde la mitad izquierda
        for node in digitNodes {
            let nodeWidth = node.size.width * scale
            node.setScale(scale)
            node.position = CGPoint(x: currentX + nodeWidth / 2.0, y: 0)
            finalScoreContainer.addChild(node)
            currentX += nodeWidth
        }

        lastFinalScoreRendered = score
    }
    
    // MARK: - High Score Display
    func showHighScoreDisplay() {
        // Crear contenedor para el mejor puntaje si no existe
        if highScoreContainer == nil {
            createHighScoreContainer()
        }
        
        // Actualizar el mejor puntaje
        updateHighScoreDisplay()
        
        // Mostrar con animación
        if let highScoreContainer = highScoreContainer {
            highScoreContainer.isHidden = false
            highScoreContainer.alpha = 0.0
            highScoreContainer.run(SKAction.fadeIn(withDuration: 0.3))
        }
    }
    
    private func createHighScoreContainer() {
        // Posición: centrado horizontalmente, arriba del puntaje actual
        let finalScoreY = finalScoreContainer.position.y
        let offsetY: CGFloat = 50 // Arriba del puntaje actual
        
        highScoreContainer = SKNode()
        highScoreContainer?.position = CGPoint(x: frame.midX, y: finalScoreY + offsetY)
        highScoreContainer?.zPosition = GameConfig.ZPosition.UI
        
        // Agregar contenedor para dígitos del mejor puntaje
        highScoreDigitsContainer = SKNode()
        highScoreDigitsContainer?.position = CGPoint(x: 0, y: 0)
        highScoreContainer?.addChild(highScoreDigitsContainer!)
        
        addChild(highScoreContainer!)
    }
    
    private func updateHighScoreDisplay() {
        guard let highScoreDigitsContainer = highScoreDigitsContainer else { return }
        
        // Limpiar dígitos anteriores
        highScoreDigitsContainer.removeAllChildren()
        
        let highScore = ScoreManager.shared.highScore
        let highScoreString = String(highScore)
        
        var digitNodes: [SKSpriteNode] = []
        for ch in highScoreString {
            let texture = digitTextures[ch] ?? SKTexture(imageNamed: String(ch))
            if digitTextures[ch] == nil { digitTextures[ch] = texture }
            let node = SKSpriteNode(texture: texture)
            digitNodes.append(node)
        }
        
        // Calcular escala (más grande que el puntaje actual)
        let baseTotalWidth = digitNodes.reduce(CGFloat(0)) { $0 + $1.size.width }
        guard baseTotalWidth > 0 else { return }
        
        let scale = finalScoreScaleFactor * 1.8 // 50% más grande que el puntaje actual
        
        // Posicionar dígitos
        var currentX: CGFloat = 0
        for node in digitNodes {
            let nodeWidth = node.size.width * scale
            node.setScale(scale)
            node.position = CGPoint(x: currentX + nodeWidth / 2.0, y: 0)
            highScoreDigitsContainer.addChild(node)
            currentX += nodeWidth
        }
    }
}
