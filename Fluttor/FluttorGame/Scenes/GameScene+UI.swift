import SpriteKit

// MARK: - UI y Layout
extension GameScene {
    func setupUI() {
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

        // Sombreado de fondo para Game Over (similar a la pausa)
        let dimGO = SKSpriteNode(color: .black, size: frame.size)
        dimGO.alpha = 0.0 // se animará hasta 0.65
        dimGO.position = CGPoint(x: frame.midX, y: frame.midY)
        dimGO.zPosition = GameConfig.ZPosition.UI - 1
        dimGO.isHidden = true
        dimGO.name = "gameOverDim"
        gameOverDim = dimGO
        addChild(dimGO)

        // Imagen de Game Over (asset: UI-GameOver)
        let img = SKSpriteNode(imageNamed: "UI-GameOver")
        img.name = "gameOverImage"
        img.zPosition = GameConfig.ZPosition.UI
        img.isHidden = true
        gameOverImage = img
        addChild(img)
        updateGameOverImageLayout()
        
        // Imagen de marcador "score.png" debajo del botón Reiniciar
        let scoreImg = SKSpriteNode(imageNamed: "score")
        scoreImg.name = "gameOverScore"
        scoreImg.zPosition = GameConfig.ZPosition.UI - 0.1 // Debajo del botón
        scoreImg.isHidden = true
        gameOverScoreImage = scoreImg
        addChild(scoreImg)
        updateGameOverScoreLayout()

        // Contenedor para los dígitos del puntaje final sobre el tablero (como hermano en la escena)
        finalScoreContainer.name = "finalScoreContainer"
        finalScoreContainer.zPosition = GameConfig.ZPosition.UI - 0.05 // Sobre el tablero, debajo de otros UI
        finalScoreContainer.isHidden = true
        addChild(finalScoreContainer)

        setupScoreDisplay()
    }

    func repositionPauseButton() {
        guard let view = view else { return }
        // Calcular safe areas
        let viewSafeLeft = view.safeAreaInsets.left
        let safeTop = topSafeAreaInset()

        // Posicionar en esquina superior izquierda
        // Usar tamaño mínimo visible si el frame aún no está calculado
        let buttonWidth = max(pauseButton?.frame.width ?? 72, 72)
        let buttonHeight = max(pauseButton?.frame.height ?? 72, 72)
        let x = frame.minX + viewSafeLeft + buttonWidth / 2 + pauseButtonMargin + pauseButtonExtraOffsetX
        let y = frame.maxY - safeTop - buttonHeight / 2 - pauseButtonMargin
        pauseButton?.position = CGPoint(x: x, y: y)
    }

    func updateResumeOverlayLayout() {
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
            // Posicionar el botón de Inicio debajo del de reanudar
            if child.name == "startButton" {
                child.position = CGPoint(x: frame.midX, y: frame.midY + overlayButtonOffsetY - 80)
            }
            if let sprite = child as? SKSpriteNode, sprite.name == "startMessage" {
                sprite.position = CGPoint(x: frame.midX, y: frame.midY)
                // Recalcular escala por si cambia el tamaño
                if sprite.size.width > 0 {
                    let targetWidth = frame.width * 0.9
                    let scale = targetWidth / sprite.size.width
                    let maxUpscale: CGFloat = 2.0
                    sprite.setScale(min(scale, maxUpscale))
                }
            }
        }
    }

    func updateGameOverImageLayout() {
        guard let _ = gameOverImage else { return }
        // Posicionar centrada, un poco arriba del botón REINICIAR
        let offsetY: CGFloat = 140
        gameOverImage?.position = CGPoint(x: frame.midX, y: frame.midY + offsetY)
        // Escalar para que ocupe hasta el 70% del ancho de la escena y permitir ampliar por encima de 1x (máx 2x)
        if let width = gameOverImage?.size.width, width > 0 {
            let targetWidth = frame.width * 0.7
            let scale = targetWidth / width
            let maxUpscale: CGFloat = 2.0
            gameOverImage?.setScale(min(scale, maxUpscale))
        }
        // Ajustar sombreado al tamaño de la escena
        if let dim = gameOverDim {
            dim.size = frame.size
            dim.position = CGPoint(x: frame.midX, y: frame.midY)
        }
    }

    func updateGameOverScoreLayout() {
        guard let scoreImg = gameOverScoreImage else { return }
        
        // Escalar para que no exceda 65% del ancho de la escena (y permitir ampliación hasta 2x)
        if scoreImg.size.width > 0 {
            let targetWidth = frame.width * 0.65
            let scale = targetWidth / scoreImg.size.width
            let maxUpscale: CGFloat = 2.0
            scoreImg.setScale(min(scale, maxUpscale))
        }
        
        // Calcular una separación equivalente a la que hay entre la imagen "Game Over" y el botón
        let buttonHalfH = restartButton.calculateAccumulatedFrame().height / 2
        let scoreHalfH = scoreImg.calculateAccumulatedFrame().height / 2
        var topHalfH: CGFloat = 0
        if let go = gameOverImage {
            topHalfH = go.calculateAccumulatedFrame().height / 2
        }
        // Distancia centro-a-centro usada para la imagen superior
        let topCenterOffset: CGFloat = 110
        // Margen (borde a borde) real arriba del botón
        let topGap = topCenterOffset - (buttonHalfH + topHalfH)
        // Asegurar un margen mínimo cómodo
        let gapBelow = max(topGap, 24)
        
        // Posicionar centrado, por debajo del botón con la misma separación
        let centerY = restartButton.position.y
        let targetCenterOffsetBelow = buttonHalfH + scoreHalfH + gapBelow
        scoreImg.position = CGPoint(x: frame.midX, y: centerY - targetCenterOffsetBelow)

        // Actualizar posición/escala de los dígitos del puntaje final para el nuevo tamaño
        updateFinalScoreDisplay()
    }
}
