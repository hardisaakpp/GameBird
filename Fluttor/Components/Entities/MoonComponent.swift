//
//  MoonComponent.swift
//  Fluttor
//
//  Created by Isaac Ortiz on 26/1/25.
//

import SpriteKit

class MoonComponent {
    let moon: SKSpriteNode
    private let scene: SKScene
    
    // Configuración de la luna
    private let moonSize: CGFloat = 120
    private let moonZPosition: CGFloat = GameConfig.ZPosition.background + 5 // Detrás de las tuberías, pero encima del fondo
    
    // Posicionamiento
    private let moonOffsetX: CGFloat = 0.35 // 35% desde el borde derecho
    private let moonOffsetY: CGFloat = 0.75 // 75% desde la parte inferior
    
    // Animaciones
    private var floatAnimation: SKAction?
    private var glowAnimation: SKAction?
    
    init(scene: SKScene) {
        self.scene = scene
        
        // Crear el nodo de la luna
        moon = SKSpriteNode(imageNamed: "moon")
        moon.name = "moon"
        moon.zPosition = moonZPosition
        
        // Configurar tamaño
        let scale = moonSize / moon.size.width
        moon.setScale(scale)
        
        // Configurar posición inicial
        updatePosition()
        
        // Configurar animaciones
        setupAnimations()
    }
    
    // MARK: - Setup
    private func setupAnimations() {
        // Animación de flotación suave
        let floatUp = SKAction.moveBy(x: 0, y: 8, duration: 3.0)
        let floatDown = SKAction.moveBy(x: 0, y: -8, duration: 3.0)
        floatAnimation = SKAction.repeatForever(SKAction.sequence([floatUp, floatDown]))
        
        // Animación de brillo sutil
        let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: 2.0)
        let fadeOut = SKAction.fadeAlpha(to: 1.0, duration: 2.0)
        glowAnimation = SKAction.repeatForever(SKAction.sequence([fadeIn, fadeOut]))
    }
    
    // MARK: - Posicionamiento
    func updatePosition() {
        let x = scene.frame.maxX - (scene.frame.width * moonOffsetX)
        let y = scene.frame.minY + (scene.frame.height * moonOffsetY)
        moon.position = CGPoint(x: x, y: y)
    }
    
    // MARK: - Control de Visibilidad
    func showMoon() {
        guard moon.parent == nil else { return }
        scene.addChild(moon)
        startAnimations()
    }
    
    func hideMoon() {
        moon.removeFromParent()
        stopAnimations()
    }
    
    func setVisible(_ visible: Bool) {
        if visible {
            showMoon()
        } else {
            hideMoon()
        }
    }
    
    // MARK: - Animaciones
    private func startAnimations() {
        guard let floatAnimation = floatAnimation, let glowAnimation = glowAnimation else { return }
        moon.run(floatAnimation, withKey: "float")
        moon.run(glowAnimation, withKey: "glow")
    }
    
    private func stopAnimations() {
        moon.removeAction(forKey: "float")
        moon.removeAction(forKey: "glow")
    }
    
    // MARK: - Sincronización con Día/Noche
    func updateForDayNight() {
        let isNight = BackgroundConstants.isNightNow()
        setVisible(isNight)
    }
    
    // MARK: - Efectos Especiales
    func addGlowEffect() {
        // Crear un efecto de resplandor sutil
        let glow = SKSpriteNode(color: .white, size: CGSize(width: moonSize * 1.5, height: moonSize * 1.5))
        glow.alpha = 0.1
        glow.zPosition = moon.zPosition - 0.1
        glow.name = "moonGlow"
        moon.addChild(glow)
        
        // Animación del resplandor
        let pulseIn = SKAction.scale(to: 1.2, duration: 2.0)
        let pulseOut = SKAction.scale(to: 0.8, duration: 2.0)
        let pulse = SKAction.repeatForever(SKAction.sequence([pulseIn, pulseOut]))
        glow.run(pulse, withKey: "glowPulse")
    }
    
    func removeGlowEffect() {
        moon.childNode(withName: "moonGlow")?.removeFromParent()
    }
}
