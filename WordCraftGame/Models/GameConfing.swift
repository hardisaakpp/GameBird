//
//  GameConfing.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 18/5/25.
//

// GameConfig.swift
import Foundation
import UIKit


struct GameConfig {
    // MARK: - Física
    struct Physics {
        static let gravity: CGFloat = -5.0
        static let birdImpulse: CGFloat = 50.0
        static let birdMass: CGFloat = 0.15
        static let linearDamping: CGFloat = 0.5
    }
    
    // MARK: - Velocidades
    struct Speed {
        static let background: CGFloat = 30.0
        static let ground: CGFloat = 150.0
        static let pipes: CGFloat = 180.0       // Nueva constante
    }
    
    // MARK: - Rotación del pájaro
    struct Rotation {
        static let minAngle: CGFloat = -1.0     // Rotación máxima hacia abajo (radianes)
        static let maxAngle: CGFloat = 0.5      // Rotación máxima hacia arriba (radianes)
        static let rotationSpeed: CGFloat = 0.2 // Nueva: velocidad de rotación
        static let upwardFactor: CGFloat = 0.001
        static let downwardFactor: CGFloat = 0.003
    }
    
    // MARK: - Posiciones
    struct Position {
        static let birdInitial = CGPoint(x: -240, y: 0) // Nueva posición inicial del pájaro
        static let groundOffset = CGPoint(x: -240, y: -760)
        static let pipeSpacing: CGFloat = 300.0         // Nueva: espacio entre tuberías
    }
    
    // MARK: - Capas Visuales (Z Positions)
    struct ZPosition {
        static let background: CGFloat = 0
        static let ground: CGFloat = 10
        static let pipes: CGFloat = 20
        static let bird: CGFloat = 30
        static let UI: CGFloat = 9999
    }
    
    // MARK: - Tiempos
    struct Timing {
        static let pipeSpawnInterval: TimeInterval = 1.8
        static let colorFlashDuration: TimeInterval = 0.15 // Nueva: duración parpadeo
    }
}
