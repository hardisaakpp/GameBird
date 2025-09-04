import SpriteKit
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // Estado principal
    var isGameOver = false
    var isPausedGame = false
    var isInitialPauseActive = false
    var isWelcomeScreenActive = false  // Nuevo estado para la pantalla de bienvenida
    
    // MARK: - Propiedades del Escenario
    let birdTexture1 = SKTexture(imageNamed: "redbird-midflap")
    let birdTexture2 = SKTexture(imageNamed: "redbird-downflap")
    
    // Componentes
    var birdComponent: BirdComponent!         // Pájaros
    var groundComponent: GroundComponent!         // Suelo
    var backgroundComponent: BackgroundComponent!   // Fondo
    var moonComponent: MoonComponent!         // Luna
    var sunComponent: SunComponent!           // Sol
    var coinComponent: CoinComponent!         // Moneda
    var pipeManager: PipeManager!
    
    // UI
    var restartButton: SKNode!
    var pauseButton: SKNode!
    var resumeOverlay: SKNode!
    var welcomeOverlay: SKNode!  // Nuevo overlay para la pantalla de bienvenida
    var gameOverImage: SKSpriteNode? // Imagen de Game Over
    var gameOverDim: SKSpriteNode?   // Sombreado de fondo para Game Over
    var gameOverScoreImage: SKSpriteNode? // Imagen "score" debajo del botón reiniciar
    
    // Marcador
    var score: Int = 0
    var scoreContainer: SKNode = SKNode()
    let scoreDigitScale: CGFloat = 2.0
    let scoreTopMargin: CGFloat = 45
    
    // Botón de pausa
    let pauseButtonMargin: CGFloat = 16
    let pauseButtonExtraOffsetX: CGFloat = 72
    
    // Offsets de layout para overlay de pausa
    let overlayTitleOffsetY: CGFloat = 90
    let overlayButtonOffsetY: CGFloat = -10
    let overlayHintOffsetY: CGFloat = -120
    
    // Puntaje final sobre tablero `score.png`
    var finalScoreContainer: SKNode = SKNode()
    // Porción del ancho del tablero usada para los dígitos (45%)
    let finalScoreMaxWidthRatio: CGFloat = 0.45
    // Desplazamiento vertical relativo dentro del tablero para centrar mejor los dígitos
    let finalScoreYOffsetRatio: CGFloat = 0.11
    // Padding horizontal derecho como fracción del ancho del tablero para alinear a la derecha
    let finalScoreRightPaddingRatio: CGFloat = 0.13
    // Nuevo: factor para reducir el tamaño de los dígitos del puntaje final
    let finalScoreScaleFactor: CGFloat = 1.0 / 2.1
    // Cache de texturas de dígitos y memo de layout final
    var digitTextures: [Character: SKTexture] = [:]
    var lastFinalScoreRendered: Int = -1
    var lastFinalBoardWidth: CGFloat = -1
    
    // MARK: - High Score Properties
    var highScoreContainer: SKNode?
    var highScoreDigitsContainer: SKNode?
}
