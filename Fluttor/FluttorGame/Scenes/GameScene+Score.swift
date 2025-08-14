import SpriteKit

// MARK: - Marcador (Score)
extension GameScene {
    func preloadDigitTextures() {
        for c in "0123456789" {
            if digitTextures[c] == nil {
                digitTextures[c] = SKTexture(imageNamed: String(c))
            }
        }
    }

    func setupScoreDisplay() {
        score = 0
        scoreContainer.zPosition = 200
        addChild(scoreContainer)
        
        // Agregar nombre del jugador al extremo derecho
        let playerNameLabel = SKLabelNode(text: Player.current.name)
        playerNameLabel.fontName = FontConstants.GameUI.hintFont
        playerNameLabel.fontSize = FontConstants.getAdaptiveFontSize(for: 18, fontName: FontConstants.GameUI.hintFont)
        playerNameLabel.fontColor = .systemYellow
        playerNameLabel.horizontalAlignmentMode = .right
        playerNameLabel.position = CGPoint(x: 200, y: 0) // Posicionado al extremo derecho
        playerNameLabel.name = "playerNameLabel"
        scoreContainer.addChild(playerNameLabel)
        
        updateScoreDisplay()
        repositionScoreDisplay()
    }

    func updateScoreDisplay() {
        // Limpiar dígitos actuales
        scoreContainer.removeAllChildren()
        let scoreString = String(score)
        var digitNodes: [SKSpriteNode] = []

        // Crear nodos por dígito (usa Assets.xcassets/Numbers/{0-9}) con cache
        for ch in scoreString {
            let texture = digitTextures[ch] ?? SKTexture(imageNamed: String(ch))
            if digitTextures[ch] == nil { digitTextures[ch] = texture }
            let node = SKSpriteNode(texture: texture)
            node.setScale(scoreDigitScale)
            digitNodes.append(node)
        }

        // Calcular ancho total para centrar
        let totalWidth: CGFloat = digitNodes.reduce(0.0) { $0 + $1.frame.width }
        var currentX = -totalWidth / 2

        // Posicionar dígitos dentro del contenedor
        for node in digitNodes {
            node.position = CGPoint(x: currentX + node.frame.width / 2, y: 0)
            scoreContainer.addChild(node)
            currentX += node.frame.width
        }

        // Agregar el nombre del jugador nuevamente (se perdió al limpiar)
        let playerNameLabel = SKLabelNode(text: Player.current.name)
        playerNameLabel.fontName = FontConstants.GameUI.hintFont
        playerNameLabel.fontSize = FontConstants.getAdaptiveFontSize(for: 18, fontName: FontConstants.GameUI.hintFont)
        playerNameLabel.fontColor = .systemYellow
        playerNameLabel.horizontalAlignmentMode = .right
        playerNameLabel.position = CGPoint(x: 200, y: 0)
        playerNameLabel.name = "playerNameLabel"
        scoreContainer.addChild(playerNameLabel)

        repositionScoreDisplay()
    }

    func repositionScoreDisplay() {
        let safeTop = topSafeAreaInset()
        let halfHeight = scoreContainer.calculateAccumulatedFrame().height / 2
        scoreContainer.position = CGPoint(
            x: frame.midX,
            y: frame.maxY - safeTop - halfHeight - scoreTopMargin
        )
    }
    
    func updateScorePlayerName(_ name: String) {
        // Actualizar el nombre del jugador en el marcador
        if let playerNameLabel = scoreContainer.children.first(where: { $0.name == "playerNameLabel" }) as? SKLabelNode {
            playerNameLabel.text = name
        }
    }
}
