//
//  SoundConstants.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 7/8/25.
//

import Foundation

struct SoundConstants {
    // MARK: - Nombres de archivos de sonido
    struct Files {
        static let die = "die"
        static let hit = "hit"
        static let point = "point"
        static let swoosh = "swoosh"
        static let wing = "wing"
        static let coin = "coin"
        static let fruit = "fruit"
    }
    
    // MARK: - Extensiones de archivo (orden de preferencia)
    struct Extensions {
        static let preferred = "m4a"  // AAC - más eficiente
        static let fallback = "mp3"   // MP3 - alternativa
        static let original = "wav"   // WAV - original
    }
    
    // MARK: - Rutas de sonido
    struct Paths {
        static let soundsDirectory = "Sounds"
    }
    
    // MARK: - Configuración de audio optimizada
    struct Audio {
        static let volume: Float = 0.7  // Volumen reducido para mejor rendimiento
        static let loop: Bool = false
        static let maxConcurrent: Int = 3
        static let preloadOnStart: Bool = true
    }
    
    // MARK: - Configuración de rendimiento
    struct Performance {
        static let enablePreloading = true
        static let enableConcurrentLimit = true
        static let enableBackgroundLoading = true
        static let enableAudioSessionOptimization = true
    }
}
