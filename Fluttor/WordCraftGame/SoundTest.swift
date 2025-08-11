//
//  SoundTest.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 7/8/25.
//

import Foundation
import AVFoundation

class SoundTest {
    static func testSoundLoading() {
        let soundFiles = ["wing", "hit", "die", "point", "swoosh"]
        
        print("🔍 Probando carga de archivos de sonido...")
        
        for soundFile in soundFiles {
            if let url = Bundle.main.url(forResource: soundFile, withExtension: "wav") {
                print("✅ \(soundFile).wav encontrado en: \(url)")
            } else {
                print("❌ \(soundFile).wav NO encontrado")
            }
        }
        
        print("🎵 Prueba de carga completada")
    }
}
