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
        
        // Organizar toda la información de puntajes debajo del botón REINICIAR
        organizeScoreInfoDisplay()
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
        
        // Ocultar todos los elementos de la información organizada
        cleanupOrganizedScoreDisplay()
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
        let startingY = restartButtonY - 60 // Empezar 60 puntos debajo del botón
        let verticalSpacing: CGFloat = 45 // Espaciado entre elementos
        
        var currentY = startingY
        
        // 1. Nombre del jugador (arriba de todo)
        showPlayerNameAtPosition(y: currentY)
        currentY -= verticalSpacing
        
        // 2. Texto "Top 5 Jugadores" 
        showGlobalLeaderboardLabelAtPosition(y: currentY)
        currentY -= verticalSpacing * 0.7 // Menos espacio para el label
        
        // 3. Los mejores puntajes de diferentes jugadores (leaderboard global)
        currentY = showGlobalLeaderboardAtPosition(startingY: currentY)
        
        // 4. Texto "Esta partida"
        showCurrentGameLabelAtPosition(y: currentY) 
        currentY -= verticalSpacing * 0.7 // Menos espacio para el label
        
        // 5. Puntaje de esta partida (números medianos)
        showCurrentScoreAtPosition(y: currentY)
        
        print("📊 Información de puntajes organizada debajo del botón REINICIAR")
    }
    
    private func showPlayerNameAtPosition(y: CGFloat) {
        let playerName = Player.current.name
        let playerLabel = SKLabelNode(text: "👤 \(playerName)")
        playerLabel.fontName = "AvenirNext-Bold"
        playerLabel.fontSize = 22
        playerLabel.fontColor = .systemYellow
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
        leaderboardLabel.fontSize = 16
        leaderboardLabel.fontColor = .systemGray
        leaderboardLabel.name = "globalLeaderboardLabel"
        leaderboardLabel.zPosition = GameConfig.ZPosition.UI
        leaderboardLabel.position = CGPoint(x: frame.midX, y: y)
        
        leaderboardLabel.alpha = 0.0
        addChild(leaderboardLabel)
        leaderboardLabel.run(SKAction.fadeIn(withDuration: 0.5))
    }
    
    private func showGlobalLeaderboardAtPosition(startingY: CGFloat) -> CGFloat {
        let globalLeaderboard = ScoreManager.shared.getGlobalLeaderboard()
        let scoreSpacing: CGFloat = 25 // Espaciado entre cada puntaje
        var currentY = startingY
        let currentPlayerName = Player.current.name
        
        // Si no hay puntajes, mostrar mensaje
        if globalLeaderboard.isEmpty {
            let noScoresLabel = SKLabelNode(text: "¡Sé el primer jugador en el leaderboard!")
            noScoresLabel.fontName = "AvenirNext-Regular"
            noScoresLabel.fontSize = 14
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
            scoreLabel.fontSize = position == 1 ? 18 : 16
            
            // Destacar al jugador actual
            if isCurrentPlayer {
                scoreLabel.fontColor = .systemYellow
                // Agregar un indicador visual
                let indicator = "👤 "
                scoreLabel.text = "\(indicator)\(scoreText)"
            } else {
                scoreLabel.fontColor = position == 1 ? .systemOrange : .white
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
        
        return currentY - 10 // Espacio extra después de la lista
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
    
    private func showCurrentGameLabelAtPosition(y: CGFloat) {
        let currentGameLabel = SKLabelNode(text: "📊 Esta partida")
        currentGameLabel.fontName = "AvenirNext-Medium"
        currentGameLabel.fontSize = 16
        currentGameLabel.fontColor = .systemGray
        currentGameLabel.name = "currentGameLabel"
        currentGameLabel.zPosition = GameConfig.ZPosition.UI
        currentGameLabel.position = CGPoint(x: frame.midX, y: y)
        
        currentGameLabel.alpha = 0.0
        addChild(currentGameLabel)
        currentGameLabel.run(SKAction.fadeIn(withDuration: 0.7))
    }
    
    private func showCurrentScoreAtPosition(y: CGFloat) {
        // Posicionar el contenedor del puntaje actual
        finalScoreContainer.position = CGPoint(x: frame.midX, y: y)
        
        // Actualizar y mostrar los dígitos del puntaje final
        updateFinalScoreDisplay()
        finalScoreContainer.isHidden = false
        finalScoreContainer.alpha = 0.0
        finalScoreContainer.run(SKAction.fadeIn(withDuration: 0.8))
    }
    
    private func cleanupOrganizedScoreDisplay() {
        // Remover todos los labels de la información organizada
        var labelsToRemove = ["playerNameLabel", "globalLeaderboardLabel", "currentGameLabel", "noScoresLabel"]
        
        // Agregar los 5 puntajes del leaderboard global
        for i in 1...5 {
            labelsToRemove.append("globalScore\(i)")
        }
        
        for labelName in labelsToRemove {
            if let label = childNode(withName: labelName) {
                label.removeFromParent()
            }
        }
        
        print("🧹 Leaderboard global limpiado")
    }
}
