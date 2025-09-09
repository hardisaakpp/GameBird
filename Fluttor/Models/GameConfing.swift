//
//  GameConfing.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 18/5/25.
//

// GameConfig.swift
import Foundation
import UIKit

// MARK: - Game Mode Enum
enum GameMode {
    case normal
    case basic
    
    var displayName: String {
        switch self {
        case .normal: return "Normal"
        case .basic: return "Básico"
        }
    }
}

struct GameConfig {
    // MARK: - Física (Optimizada para mejor rendimiento)
    struct Physics {
        static func gravity(for mode: GameMode) -> CGFloat {
            switch mode {
            case .normal: return -4.7
            case .basic: return -3.2  // 32% menos gravedad para modo básico
            }
        }
        
        static func birdImpulse(for mode: GameMode) -> CGFloat {
            switch mode {
            case .normal: return 62.0
            case .basic: return 45.0  // Impulso más suave para modo básico
            }
        }
        
        static let birdMass: CGFloat = 0.15
        static let linearDamping: CGFloat = 0.8  // Aumentado para mejor control
        static let angularDamping: CGFloat = 1.0  // Nuevo: amortiguación angular
        static let friction: CGFloat = 0.0        // Nuevo: sin fricción para mejor rendimiento
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
        
        static func pipeSpacing(for mode: GameMode) -> CGFloat {
            switch mode {
            case .normal: return 300.0
            case .basic: return 380.0  // 27% más espacio entre pipes para modo básico
            }
        }
        
        static func pipeGap(for mode: GameMode) -> CGFloat {
            switch mode {
            case .normal: return 150.0  // Gap normal entre pipes superior e inferior
            case .basic: return 200.0   // 33% más gap para modo básico
            }
        }
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
        static let initialSpawnDelayFactor: CGFloat = 0.4 // fracción del spawnInterval para el primer tubo tras tocar
    }
    
    // MARK: - Características del Juego por Modo
    struct GameFeatures {
        static func enableFruits(for mode: GameMode) -> Bool {
            switch mode {
            case .normal: return true
            case .basic: return false  // Sin frutas en modo básico para simplificar
            }
        }
        
        static func enableDayNightCycle(for mode: GameMode) -> Bool {
            switch mode {
            case .normal: return true
            case .basic: return false  // Sin cambios automáticos día/noche en modo básico
            }
        }
        
        static func enableCoins(for mode: GameMode) -> Bool {
            switch mode {
            case .normal: return true
            case .basic: return true   // Mantener monedas en ambos modos
            }
        }
    }
}
