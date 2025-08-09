//
//  Pipe.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 1/2/25.
//

import SpriteKit

struct Pipe {
    // Texturas cacheadas por modo
    private static let dayTubo1 = SKTexture(imageNamed: "pipe-green2")
    private static let dayTubo2 = SKTexture(imageNamed: "pipe-green1")
    private static let nightTubo1 = SKTexture(imageNamed: "pipe-red2")
    private static let nightTubo2 = SKTexture(imageNamed: "pipe-red1")

    // Accesores dinámicos: día = verde, noche = rojo
    static var texturaTubo1: SKTexture {
        return BackgroundConstants.isNightNow() ? nightTubo1 : dayTubo1
    }
    static var texturaTubo2: SKTexture {
        return BackgroundConstants.isNightNow() ? nightTubo2 : dayTubo2
    }
}
