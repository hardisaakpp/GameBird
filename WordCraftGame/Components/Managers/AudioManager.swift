//
//  AudioManager.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 7/8/25.
//

import SpriteKit
import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    
    // MARK: - Propiedades optimizadas
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var isSoundEnabled = true
    private var isPreloaded = false
    private let maxConcurrentSounds = 3
    private var activeSounds: Set<String> = []
    
    private init() {
        setupAudioSession()
    }
    
    // MARK: - Configuración optimizada
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Error configurando sesión de audio: \(error)")
        }
    }
    
    // MARK: - Precarga de sonidos (ejecutar al inicio del juego)
    func preloadSounds() {
        guard !isPreloaded else { return }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            let soundFiles = [
                SoundConstants.Files.wing,
                SoundConstants.Files.hit,
                SoundConstants.Files.die,
                SoundConstants.Files.point,
                SoundConstants.Files.swoosh
            ]
            
            for soundFile in soundFiles {
                self?.preloadSound(soundFile)
            }
            
            DispatchQueue.main.async {
                self?.isPreloaded = true
                print("✅ Sonidos precargados exitosamente")
            }
        }
    }
    
    private func preloadSound(_ soundName: String) {
        // Intentar cargar archivo WAV (formato actual)
        if let url = Bundle.main.url(forResource: soundName, withExtension: "wav") {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                player.volume = SoundConstants.Audio.volume
                audioPlayers[soundName] = player
                print("✅ Precargado: \(soundName).wav")
            } catch {
                print("❌ Error precargando \(soundName).wav: \(error)")
            }
        } else {
            print("❌ No se pudo encontrar: \(soundName).wav")
        }
    }
    
    // MARK: - Reproducción optimizada
    func playSound(_ soundName: String, fileExtension: String = "wav") {
        guard isSoundEnabled else { return }
        
        // Limitar sonidos concurrentes
        if activeSounds.count >= maxConcurrentSounds {
            return
        }
        
        // Usar player precargado si existe
        if let player = audioPlayers[soundName] {
            DispatchQueue.main.async {
                player.currentTime = 0
                player.play()
                self.activeSounds.insert(soundName)
                
                // Remover del set activo cuando termine
                DispatchQueue.main.asyncAfter(deadline: .now() + player.duration) {
                    self.activeSounds.remove(soundName)
                }
            }
            return
        }
        
        // Fallback: cargar al momento
        if let url = Bundle.main.url(forResource: soundName, withExtension: fileExtension) {
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    player.volume = SoundConstants.Audio.volume
                    
                    DispatchQueue.main.async {
                        self.audioPlayers[soundName] = player
                        player.play()
                        self.activeSounds.insert(soundName)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + player.duration) {
                            self.activeSounds.remove(soundName)
                        }
                    }
                } catch {
                    print("Error reproduciendo sonido \(soundName).\(fileExtension): \(error)")
                }
            }
        } else {
            print("No se pudo encontrar el archivo de sonido: \(soundName).\(fileExtension)")
        }
    }
    
    // MARK: - Métodos específicos optimizados
    func playWingSound() {
        playSound(SoundConstants.Files.wing)
    }
    
    func playHitSound() {
        playSound(SoundConstants.Files.hit)
    }
    
    func playDieSound() {
        playSound(SoundConstants.Files.die)
    }
    
    func playPointSound() {
        playSound(SoundConstants.Files.point)
    }
    
    func playSwooshSound() {
        playSound(SoundConstants.Files.swoosh)
    }
    
    // MARK: - Control de audio
    func toggleSound() {
        isSoundEnabled.toggle()
    }
    
    func setSoundEnabled(_ enabled: Bool) {
        isSoundEnabled = enabled
    }
    
    func isSoundOn() -> Bool {
        return isSoundEnabled
    }
    
    // MARK: - Limpieza optimizada
    func stopAllSounds() {
        audioPlayers.values.forEach { $0.stop() }
        activeSounds.removeAll()
    }
    
    func clearCache() {
        audioPlayers.removeAll()
        activeSounds.removeAll()
        isPreloaded = false
    }
    
    // MARK: - Información de rendimiento
    func getPerformanceInfo() -> String {
        return """
        🎵 AudioManager Performance:
        - Sonidos precargados: \(isPreloaded ? "Sí" : "No")
        - Sonidos en caché: \(audioPlayers.count)
        - Sonidos activos: \(activeSounds.count)/\(maxConcurrentSounds)
        - Audio habilitado: \(isSoundEnabled ? "Sí" : "No")
        """
    }
}
