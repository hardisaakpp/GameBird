//
//  PhysicsCategory.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 18/5/25.
//

import Foundation

struct PhysicsCategory {
    static let bird: UInt32 = 0b0001    // 1
    static let ground: UInt32 = 0b0010   // 2
    static let top: UInt32 = 0b0100      // 4
    static let pipe: UInt32 = 0b1000     // 8
    static let scoreDetector: UInt32 = 0b1_0000 // 16
    static let coin: UInt32 = 0b10_0000  // 32
    static let strawberry: UInt32 = 0b100_0000 // 64
    
    // Método para debugging
    static func name(for category: UInt32) -> String {
        switch category {
        case PhysicsCategory.bird:
            return "Bird"
        case PhysicsCategory.ground:
            return "Ground"
        case PhysicsCategory.top:
            return "Top"
        case PhysicsCategory.pipe:
            return "Pipe"
        case PhysicsCategory.scoreDetector:
            return "ScoreDetector"
        case PhysicsCategory.coin:
            return "Coin"
        case PhysicsCategory.strawberry:
            return "Strawberry"
        default:
            return "Unknown"
        }
    }
}
