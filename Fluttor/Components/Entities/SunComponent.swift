//
//  SunComponent.swift
//  Fluttor
//
//  Created by Isaac Ortiz on 26/1/25.
//

import SpriteKit

class SunComponent {
    let sun: SKSpriteNode
    private let scene: SKScene
    
    // Configuración del sol
    private let sunSize: CGFloat = 120
    private let sunZPosition: CGFloat = GameConfig.ZPosition.background + 5 // Misma posición que la luna
    
    // Interactividad
    private var isInteractive: Bool = true
    private var lastTouchTime: TimeInterval = 0
    private let touchCooldown: TimeInterval = 2.0 // Cooldown de 2 segundos entre toques
    
    // Posicionamiento (mismo lugar que la luna)
    private let sunOffsetX: CGFloat = 0.35 // 35% desde el borde derecho
    private let sunOffsetY: CGFloat = 0.75 // 75% desde la parte inferior
    
    // Animaciones
    private var floatAnimation: SKAction?
    private var glowAnimation: SKAction?
    
    init(scene: SKScene) {
        self.scene = scene
        
        // Crear el nodo del sol
        sun = SKSpriteNode(imageNamed: "sun")
        sun.name = "sun"
        sun.zPosition = sunZPosition
        
        // Configurar tamaño
        let scale = sunSize / sun.size.width
        sun.setScale(scale)
        
        // Configurar posición inicial
        updatePosition()
        
        // Configurar animaciones
        setupAnimations()
    }
    
    // MARK: - Setup
    private func setupAnimations() {
        // Animación de flotación suave (más sutil que la luna)
        let floatUp = SKAction.moveBy(x: 0, y: 6, duration: 4.0)
        let floatDown = SKAction.moveBy(x: 0, y: -6, duration: 4.0)
        floatAnimation = SKAction.repeatForever(SKAction.sequence([floatUp, floatDown]))
        
        // Animación de brillo sutil (más intensa que la luna)
        let fadeIn = SKAction.fadeAlpha(to: 0.9, duration: 1.5)
        let fadeOut = SKAction.fadeAlpha(to: 1.0, duration: 1.5)
        glowAnimation = SKAction.repeatForever(SKAction.sequence([fadeIn, fadeOut]))
    }
    
    // MARK: - Posicionamiento
    func updatePosition() {
        let x = scene.frame.maxX - (scene.frame.width * sunOffsetX)
        let y = scene.frame.minY + (scene.frame.height * sunOffsetY)
        sun.position = CGPoint(x: x, y: y)
    }
    
    // MARK: - Control de Visibilidad
    func showSun() {
        guard sun.parent == nil else { return }
        scene.addChild(sun)
        startAnimations()
    }
    
    func hideSun() {
        sun.removeFromParent()
        stopAnimations()
    }
    
    func setVisible(_ visible: Bool) {
        if visible {
            showSun()
        } else {
            hideSun()
        }
    }
    
    // MARK: - Animaciones
    private func startAnimations() {
        guard let floatAnimation = floatAnimation, let glowAnimation = glowAnimation else { return }
        sun.run(floatAnimation, withKey: "float")
        sun.run(glowAnimation, withKey: "glow")
    }
    
    private func stopAnimations() {
        sun.removeAction(forKey: "float")
        sun.removeAction(forKey: "glow")
    }
    
    // MARK: - Sincronización con Día/Noche
    func updateForDayNight() {
        let isDay = !BackgroundConstants.isNightNow()
        setVisible(isDay)
    }
    
    // MARK: - Interactividad
    func handleTouch(at location: CGPoint) -> Bool {
        guard isInteractive else { return false }
        
        // Verificar cooldown
        let currentTime = CACurrentMediaTime()
        guard currentTime - lastTouchTime >= touchCooldown else { return false }
        
        // Verificar si el toque está dentro del área del sol
        let sunFrame = sun.calculateAccumulatedFrame()
        guard sunFrame.contains(location) else { return false }
        
        // Actualizar tiempo del último toque
        lastTouchTime = currentTime
        
        // Cambiar a modo noche
        forceNightMode()
        
        // Feedback visual
        showTouchFeedback()
        
        return true
    }
    
    private func forceNightMode() {
        // Notificar al GameScene para cambiar a modo noche
        if let gameScene = scene as? GameScene {
            gameScene.forceNightMode()
        }
    }
    
    private func showTouchFeedback() {
        // Efecto visual al tocar el sol
        let originalScale = sun.xScale
        let pulseUp = SKAction.scale(to: originalScale * 1.3, duration: 0.1)
        let pulseDown = SKAction.scale(to: originalScale, duration: 0.1)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        
        // Efecto de brillo intenso
        let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.1)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        let glow = SKAction.sequence([fadeOut, fadeIn])
        
        // Ejecutar efectos en paralelo
        sun.run(SKAction.group([pulse, glow]))
    }
    
    func setInteractive(_ interactive: Bool) {
        isInteractive = interactive
    }
    
    // MARK: - Efectos Especiales
    func addGlowEffect() {
        // Crear un efecto de resplandor más intenso que la luna
        let glow = SKSpriteNode(color: .yellow, size: CGSize(width: sunSize * 1.8, height: sunSize * 1.8))
        glow.alpha = 0.15
        glow.zPosition = sun.zPosition - 0.1
        glow.name = "sunGlow"
        sun.addChild(glow)
        
        // Animación del resplandor más dinámica
        let pulseIn = SKAction.scale(to: 1.3, duration: 1.5)
        let pulseOut = SKAction.scale(to: 0.7, duration: 1.5)
        let pulse = SKAction.repeatForever(SKAction.sequence([pulseIn, pulseOut]))
        glow.run(pulse, withKey: "glowPulse")
    }
    
    func removeGlowEffect() {
        sun.childNode(withName: "sunGlow")?.removeFromParent()
    }
}
