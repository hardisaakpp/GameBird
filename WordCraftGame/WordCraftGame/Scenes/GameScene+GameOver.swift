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
        restartButton.isHidden = false
        pauseButton?.isHidden = true
        restartButton.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1.1, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
        
        // Mostrar imagen de marcador "score"
        if let scoreImg = gameOverScoreImage {
            scoreImg.isHidden = false
            scoreImg.alpha = 0.0
            let fadeIn = SKAction.fadeIn(withDuration: 0.25)
            let pop = SKAction.sequence([
                SKAction.scale(by: 1.05, duration: 0.15),
                SKAction.scale(by: 1.0/1.05, duration: 0.1)
            ])
            scoreImg.run(SKAction.group([fadeIn, pop]))
            
            // Actualizar y mostrar los dígitos del puntaje final sobre el tablero
            updateFinalScoreDisplay()
            finalScoreContainer.isHidden = false
            finalScoreContainer.alpha = 0.0
            finalScoreContainer.run(SKAction.fadeIn(withDuration: 0.25))
        }
    }

    func hideRestartButton() {
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
        // Ocultar imagen de marcador
        if let scoreImg = gameOverScoreImage {
            scoreImg.removeAllActions()
            scoreImg.isHidden = true
            scoreImg.alpha = 1.0
        }
        // Ocultar dígitos del puntaje final
        finalScoreContainer.removeAllActions()
        finalScoreContainer.isHidden = true
        finalScoreContainer.alpha = 1.0
    }

    func updateFinalScoreDisplay() {
        guard let scoreBoard = gameOverScoreImage else { return }

        // Si el tablero no está en escena o está oculto, ocultar los dígitos
        if scoreBoard.parent == nil || scoreBoard.isHidden {
            finalScoreContainer.isHidden = true
            return
        } else {
            finalScoreContainer.isHidden = false
        }

        // Posición: alinear vertical con pequeño offset y acercar a borde derecho del tablero
        let boardFrame = scoreBoard.calculateAccumulatedFrame()
        let offsetY = boardFrame.height * finalScoreYOffsetRatio
        let rightPadding = boardFrame.width * finalScoreRightPaddingRatio
        // Punto X en el borde derecho menos padding, convertido al sistema del padre (la escena)
        let targetX = boardFrame.maxX - rightPadding
        finalScoreContainer.position = CGPoint(x: targetX, y: scoreBoard.position.y + offsetY)

        // Si no cambió el puntaje ni el ancho del tablero, no reconstruir los hijos
        if lastFinalScoreRendered == score && abs(lastFinalBoardWidth - boardFrame.width) < 0.5 && !finalScoreContainer.children.isEmpty {
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

        // Calcular escala para que quepa dentro de un % del ancho del tablero (usando tamaño acumulado para incluir escala del tablero)
        let targetWidth = boardFrame.width * finalScoreMaxWidthRatio
        let baseScale = max(0.2, min(2.0, targetWidth / baseTotalWidth))
        let scale = baseScale * finalScoreScaleFactor

        // Alinear a la derecha: calcular ancho total escalado y ubicar desde el borde derecho hacia la izquierda
        let totalScaledWidth = baseTotalWidth * scale
        var currentX = -totalScaledWidth // contenedor se coloca en el borde derecho; empezamos desde -ancho
        for node in digitNodes {
            let nodeWidth = node.size.width * scale
            node.setScale(scale)
            node.position = CGPoint(x: currentX + nodeWidth / 2.0, y: 0)
            finalScoreContainer.addChild(node)
            currentX += nodeWidth
        }

        lastFinalScoreRendered = score
        lastFinalBoardWidth = boardFrame.width
    }
}
