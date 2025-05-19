//
//  GameConfing.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 18/5/25.
//

// GameConfig.swift
import Foundation

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
    }
    
    // MARK: - Rotación del pájaro
    struct Rotation {
        static let minAngle: CGFloat = -1.0    // Rotación máxima hacia abajo
        static let maxAngle: CGFloat = 0.5     // Rotación máxima hacia arriba
        static let downwardFactor: CGFloat = 0.003
        static let upwardFactor: CGFloat = 0.001
    }
    
    // MARK: - Posiciones
    struct Position {
        static let groundOffsetX: CGFloat = -240
        static let groundOffsetY: CGFloat = -760
    }
}
