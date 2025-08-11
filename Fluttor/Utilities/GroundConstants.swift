//
//  GroundConstants.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 26/1/25.
//  Funciones y extensiones de ayuda, fn matematicas, formateo o logic

import CoreGraphics

struct GroundConstants {
    static let textureName = "base"
    static let movementSpeed: CGFloat = 150.0
    static let zPosition: CGFloat = -98
    static let physicsCategory: UInt32 = 0b10
    
    struct Size {
        static let pieceWidthRatio: CGFloat = 0.3
        static let pieceHeightRatio: CGFloat = 0.12
    }
    
    struct Position {
        static let offset = CGPoint(x: -240, y: -750)
    }
}
