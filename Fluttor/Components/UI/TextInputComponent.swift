import SpriteKit

class TextInputComponent {
    let background: SKSpriteNode
    private let textLabel: SKLabelNode
    private let placeholderLabel: SKLabelNode
    private let cursor: SKSpriteNode
    
    var text: String = "" {
        didSet {
            updateDisplay()
        }
    }
    
    var isActive: Bool = false {
        didSet {
            updateCursorVisibility()
        }
    }
    
    var onTextChanged: ((String) -> Void)?
    
    init(size: CGSize) {
        // Fondo del campo de texto
        background = SKSpriteNode(color: .white, size: size)
        background.alpha = 0.9
        background.name = "textInputBackground"
        
        // Etiqueta del texto ingresado
        textLabel = SKLabelNode(fontNamed: FontConstants.GameUI.hintFont)
        textLabel.fontSize = FontConstants.getAdaptiveFontSize(for: 24, fontName: FontConstants.GameUI.hintFont)
        textLabel.fontColor = .black
        textLabel.verticalAlignmentMode = .center
        textLabel.name = "textInputLabel"
        
        // Placeholder
        placeholderLabel = SKLabelNode(text: "Ingresa tu nombre")
        placeholderLabel.fontName = FontConstants.GameUI.hintFont
        placeholderLabel.fontSize = FontConstants.getAdaptiveFontSize(for: 20, fontName: FontConstants.GameUI.hintFont)
        placeholderLabel.fontColor = .systemGray
        placeholderLabel.verticalAlignmentMode = .center
        placeholderLabel.name = "textInputPlaceholder"
        
        // Cursor parpadeante
        cursor = SKSpriteNode(color: .black, size: CGSize(width: 2, height: 20))
        cursor.name = "textInputCursor"
        
        setupLayout()
        setupAnimations()
    }
    
    private func setupLayout() {
        textLabel.position = CGPoint(x: 0, y: 0)
        placeholderLabel.position = CGPoint(x: 0, y: 0)
        cursor.position = CGPoint(x: 0, y: 0)
        
        background.addChild(textLabel)
        background.addChild(placeholderLabel)
        background.addChild(cursor)
        
        updateDisplay()
    }
    
    private func setupAnimations() {
        let blinkAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.0, duration: 0.5),
            SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        ])
        cursor.run(SKAction.repeatForever(blinkAction))
    }
    
    private func updateDisplay() {
        if text.isEmpty {
            textLabel.isHidden = true
            placeholderLabel.isHidden = false
            cursor.isHidden = true
        } else {
            textLabel.isHidden = false
            placeholderLabel.isHidden = true
            cursor.isHidden = false
            
            textLabel.text = text
            updateCursorPosition()
        }
        
        onTextChanged?(text)
    }
    
    private func updateCursorPosition() {
        let textWidth = textLabel.frame.width
        cursor.position = CGPoint(x: textWidth / 2 + 5, y: 0)
    }
    
    private func updateCursorVisibility() {
        cursor.isHidden = !isActive
    }
    
    func addToParent(_ parent: SKNode, at position: CGPoint) {
        background.position = position
        parent.addChild(background)
    }
    
    func handleTap(at point: CGPoint) -> Bool {
        return background.frame.contains(point)
    }
    
    func activate() {
        isActive = true
        // Aquí podrías mostrar el teclado del sistema
    }
    
    func deactivate() {
        isActive = false
    }
    
    func setText(_ newText: String) {
        text = newText
    }
    
    func getText() -> String {
        return text
    }
}
