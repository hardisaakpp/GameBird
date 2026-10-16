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
        
        // Botón casita justo debajo de REINICIAR
        if let restartButton = restartButton, let levelSelectButton = levelSelectButton {
            levelSelectButton.removeAllActions()
            levelSelectButton.setScale(1.0)
            levelSelectButton.position = CGPoint(x: restartButton.position.x,
                                                 y: restartButton.position.y - levelSelectButtonOffsetY)
            levelSelectButton.alpha = 0.0
            levelSelectButton.isHidden = false
            levelSelectButton.run(SKAction.fadeIn(withDuration: 0.3))
        }

        // Organizar toda la información de puntajes debajo de los botones
        organizeScoreInfoDisplay()
    }

    func hideRestartButton() {
        // Mostrar nuevamente el marcador principal
        scoreContainer.isHidden = false

        // Ocultar botón INICIO
        levelSelectButton?.removeAllActions()
        levelSelectButton?.isHidden = true
        levelSelectButton?.alpha = 0.0
        
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
        
        // Ocultar todos los elementos de la información organizada
        cleanupOrganizedScoreDisplay()
    }

    func updateFinalScoreDisplay() {
        // Mostrar los dígitos del puntaje final
        finalScoreContainer.isHidden = false

        // Posición: centrado horizontalmente, debajo del botón de reiniciar
        let restartButtonY = restartButton?.position.y ?? frame.midY
        let offsetY: CGFloat = -160 // Aún más abajo del botón de reiniciar (era -120)
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
        let scale = finalScoreScaleFactor * 2.0 // Mucho más grande para mejor visibilidad

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
    
    // MARK: - High Score Display (Legacy functions - now integrated in organizeScoreInfoDisplay)
    
    private func updateHighScoreDisplay() {
        guard let highScoreDigitsContainer = highScoreDigitsContainer else { return }
        
        // Limpiar dígitos anteriores
        highScoreDigitsContainer.removeAllChildren()
        
        // Usar el mejor puntaje del jugador actual en lugar del global
        let highScore = ScoreManager.shared.getCurrentPlayerHighScore()
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
    
    // MARK: - Organized Score Display
    func organizeScoreInfoDisplay() {
        let restartButtonY = restartButton?.position.y ?? frame.midY
        // Empezar debajo de REINICIAR + INICIO (se suma la separación del botón INICIO)
        let startingY = restartButtonY - 95 - levelSelectButtonOffsetY
        
        // 1. Puntaje de esta partida (arriba, justo debajo de los botones)
        var currentY = startingY
        showCurrentScoreAtPosition(y: currentY)
        
        // 2. Nombre del jugador (debajo del puntaje, con separación para que no se toquen)
        currentY -= 65
        showPlayerNameAtPosition(y: currentY)
        
        // 3. Texto "Top 5 Jugadores" + leyenda de colores
        currentY -= 60
        showGlobalLeaderboardLabelAtPosition(y: currentY)
        currentY -= 75
        
        // 4. Los mejores puntajes de diferentes jugadores (leaderboard global)
        currentY = showGlobalLeaderboardAtPosition(startingY: currentY)
        
        debugLog("📊 Información de puntajes organizada debajo del botón REINICIAR")
    }
    
    private func showPlayerNameAtPosition(y: CGFloat) {
        let playerName = Player.current.name
        let playerLabel = SKLabelNode(text: "👤 \(playerName)")
        playerLabel.fontName = "AvenirNext-Bold"
        playerLabel.fontSize = 34
        playerLabel.fontColor = modeColor(for: currentGameMode.displayName)
        playerLabel.name = "playerNameLabel"
        playerLabel.zPosition = GameConfig.ZPosition.UI
        playerLabel.position = CGPoint(x: frame.midX, y: y)
        
        playerLabel.alpha = 0.0
        addChild(playerLabel)
        playerLabel.run(SKAction.fadeIn(withDuration: 0.4))
    }
    
    private func showGlobalLeaderboardLabelAtPosition(y: CGFloat) {
        let leaderboardLabel = SKLabelNode(text: "🌟 Top 5 Jugadores")
        leaderboardLabel.fontName = "AvenirNext-Medium"
        leaderboardLabel.fontSize = 26
        leaderboardLabel.fontColor = .systemGray
        leaderboardLabel.name = "globalLeaderboardLabel"
        leaderboardLabel.zPosition = GameConfig.ZPosition.UI
        leaderboardLabel.position = CGPoint(x: frame.midX, y: y)
        
        leaderboardLabel.alpha = 0.0
        addChild(leaderboardLabel)
        leaderboardLabel.run(SKAction.fadeIn(withDuration: 0.5))
        
        // Leyenda de colores por modo, justo debajo del título
        let legend = SKLabelNode()
        let font = UIFont(name: "AvenirNext-DemiBold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        let text = NSMutableAttributedString()
        text.append(NSAttributedString(string: "● \(GameMode.basic.displayName)", attributes: [.font: font, .foregroundColor: modeColor(for: GameMode.basic.displayName)]))
        text.append(NSAttributedString(string: "     ", attributes: [.font: font]))
        text.append(NSAttributedString(string: "● \(GameMode.normal.displayName)", attributes: [.font: font, .foregroundColor: modeColor(for: GameMode.normal.displayName)]))
        legend.attributedText = text
        legend.name = "globalLeaderboardLegend"
        legend.zPosition = GameConfig.ZPosition.UI
        legend.position = CGPoint(x: frame.midX, y: y - 30)
        legend.alpha = 0.0
        addChild(legend)
        legend.run(SKAction.fadeIn(withDuration: 0.5))
    }
    
    /// Color fijo por modo (verde = BÁSICO, turquesa = INTERMEDIO), igual al de los botones de inicio de día
    private func modeColor(for modeName: String) -> UIColor {
        return modeName == GameMode.basic.displayName ? .systemGreen : .systemTeal
    }
    
    private func showGlobalLeaderboardAtPosition(startingY: CGFloat) -> CGFloat {
        let globalLeaderboard = ScoreManager.shared.getTop5Leaderboard()
        let scoreSpacing: CGFloat = 40 // Espaciado entre cada puntaje (aún más amplio)
        var currentY = startingY
        let currentPlayerName = Player.current.name
        
        // Si no hay puntajes, mostrar mensaje
        if globalLeaderboard.isEmpty {
            let noScoresLabel = SKLabelNode(text: "¡Sé el primer jugador en el leaderboard!")
            noScoresLabel.fontName = "AvenirNext-Regular"
            noScoresLabel.fontSize = 22
            noScoresLabel.fontColor = .systemGray2
            noScoresLabel.name = "noScoresLabel"
            noScoresLabel.zPosition = GameConfig.ZPosition.UI
            noScoresLabel.position = CGPoint(x: frame.midX, y: currentY)
            
            noScoresLabel.alpha = 0.0
            addChild(noScoresLabel)
            noScoresLabel.run(SKAction.fadeIn(withDuration: 0.6))
            
            return currentY - scoreSpacing
        }
        
        // Mostrar cada jugador con su mejor puntaje
        for (index, playerScore) in globalLeaderboard.enumerated() {
            let position = index + 1
            let medal = getMedalForPosition(position)
            let isCurrentPlayer = playerScore.playerName == currentPlayerName
            
            // Formato: "🥇 1. Juan - 1250 pts"
            let scoreText = "\(medal) \(position). \(playerScore.playerName) - \(playerScore.score) pts"
            
            let scoreLabel = SKLabelNode(text: scoreText)
            scoreLabel.fontName = position == 1 ? "AvenirNext-Bold" : "AvenirNext-Medium"
            scoreLabel.fontSize = position == 1 ? 28 : 24
            
            // Destacar al jugador actual
            scoreLabel.fontColor = modeColor(for: playerScore.gameMode)
            if isCurrentPlayer {
                scoreLabel.fontName = "AvenirNext-Bold"
                scoreLabel.text = "👤 \(scoreText)"
            }
            
            scoreLabel.name = "globalScore\(position)"
            scoreLabel.zPosition = GameConfig.ZPosition.UI
            scoreLabel.position = CGPoint(x: frame.midX, y: currentY)
            
            // Animación escalonada
            scoreLabel.alpha = 0.0
            addChild(scoreLabel)
            let delay = 0.6 + (Double(index) * 0.1)
            scoreLabel.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.fadeIn(withDuration: 0.3)
            ]))
            
            currentY -= scoreSpacing
        }
        
        // Verificar si el jugador actual no está en el top 5
        let currentPlayerInTop5 = globalLeaderboard.contains { $0.playerName == currentPlayerName }
        if !currentPlayerInTop5 {
            currentY -= 15 // Espacio antes del mensaje
            showPlayerNotInTop5Message(y: currentY, playerScore: ScoreManager.shared.getCurrentPlayerHighScore())
            currentY -= 25 // Espacio después del mensaje
        }
        
        return currentY - 20 // Espacio extra después de la lista (más amplio)
    }
    
    private func getMedalForPosition(_ position: Int) -> String {
        switch position {
        case 1: return "🥇"
        case 2: return "🥈" 
        case 3: return "🥉"
        case 4: return "🏅"
        case 5: return "🎖️"
        default: return "•"
        }
    }
    
    private func showPlayerNotInTop5Message(y: CGFloat, playerScore: Int) {
        let message = "Tu mejor: \(playerScore) pts - ¡Sigue jugando para entrar al top 5!"
        let messageLabel = SKLabelNode(text: message)
        messageLabel.fontName = "AvenirNext-Medium"
        messageLabel.fontSize = 22
        messageLabel.fontColor = .systemGray2
        messageLabel.name = "notInTop5Message"
        messageLabel.zPosition = GameConfig.ZPosition.UI
        messageLabel.position = CGPoint(x: frame.midX, y: y)
        
        messageLabel.alpha = 0.0
        addChild(messageLabel)
        messageLabel.run(SKAction.fadeIn(withDuration: 0.9))
    }
    
    private func showCurrentScoreAtPosition(y: CGFloat) {
        // Actualizar y mostrar los dígitos del puntaje final
        // (updateFinalScoreDisplay reposiciona el contenedor, por eso la posición se fija después)
        updateFinalScoreDisplay()
        finalScoreContainer.position = CGPoint(x: frame.midX, y: y)
        finalScoreContainer.isHidden = false
        finalScoreContainer.alpha = 0.0
        finalScoreContainer.run(SKAction.fadeIn(withDuration: 0.8))
    }
    
    private func cleanupOrganizedScoreDisplay() {
        // Remover todos los labels de la información organizada
        var labelsToRemove = ["playerNameLabel", "globalLeaderboardLabel", "globalLeaderboardLegend", "noScoresLabel", "notInTop5Message"]
        
        // Agregar los 5 puntajes del leaderboard global
        for i in 1...5 {
            labelsToRemove.append("globalScore\(i)")
        }
        
        for labelName in labelsToRemove {
            if let label = childNode(withName: labelName) {
                label.removeFromParent()
            }
        }
        
        debugLog("🧹 Leaderboard global limpiado")
    }
}
