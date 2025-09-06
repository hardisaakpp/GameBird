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
    private let maxConcurrentSounds = SoundConstants.Audio.maxConcurrent
    private var activeSounds: Set<String> = []
    private var lastPlayTime: [String: TimeInterval] = [:] // Evitar spam de sonidos
    private let minPlayInterval: TimeInterval = 0.1 // Intervalo mínimo entre sonidos
    
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
        
        // OPTIMIZACIÓN: Usar userInitiated en lugar de background para mejor prioridad
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let soundFiles = [
                SoundConstants.Files.wing,
                SoundConstants.Files.hit,
                SoundConstants.Files.die,
                SoundConstants.Files.point,
                SoundConstants.Files.swoosh,
                SoundConstants.Files.coin,
                SoundConstants.Files.fruit
            ]
            
            for soundFile in soundFiles {
                self?.preloadSound(soundFile)
            }
            
            DispatchQueue.main.async {
                self?.isPreloaded = true
                print("✅ Sonidos precargados exitosamente - Rendimiento optimizado")
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
    
    // MARK: - Reproducción ultra optimizada
    func playSound(_ soundName: String, fileExtension: String = "wav") {
        guard isSoundEnabled else { return }
        
        // OPTIMIZACIÓN CRÍTICA: Evitar spam de sonidos con verificación más eficiente
        let currentTime = CACurrentMediaTime()
        if let lastTime = lastPlayTime[soundName], 
           currentTime - lastTime < minPlayInterval {
            return
        }
        lastPlayTime[soundName] = currentTime
        
        // OPTIMIZACIÓN: Limitar sonidos concurrentes más estrictamente
        if activeSounds.count >= maxConcurrentSounds {
            return
        }
        
        // OPTIMIZACIÓN: Usar player precargado directamente en el hilo principal
        if let player = audioPlayers[soundName] {
            // Reproducir inmediatamente sin DispatchQueue para mejor rendimiento
            player.currentTime = 0
            player.play()
            activeSounds.insert(soundName)
            
            // OPTIMIZACIÓN: Usar Timer en lugar de DispatchQueue para mejor rendimiento
            Timer.scheduledTimer(withTimeInterval: player.duration, repeats: false) { _ in
                self.activeSounds.remove(soundName)
            }
            return
        }
        
        // OPTIMIZACIÓN: Fallback optimizado - cargar solo si es crítico
        if soundName == SoundConstants.Files.hit || soundName == SoundConstants.Files.die {
            loadAndPlaySound(soundName, fileExtension: fileExtension)
        }
    }
    
    private func loadAndPlaySound(_ soundName: String, fileExtension: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: fileExtension) else {
            print("No se pudo encontrar el archivo de sonido: \(soundName).\(fileExtension)")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                player.volume = SoundConstants.Audio.volume
                
                DispatchQueue.main.async {
                    self.audioPlayers[soundName] = player
                    player.play()
                    self.activeSounds.insert(soundName)
                    
                    Timer.scheduledTimer(withTimeInterval: player.duration, repeats: false) { _ in
                        self.activeSounds.remove(soundName)
                    }
                }
            } catch {
                print("Error reproduciendo sonido \(soundName).\(fileExtension): \(error)")
            }
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
    
    func playCoinSound() {
        playSound(SoundConstants.Files.coin)
    }
    
    func playFruitSound() {
        playSound(SoundConstants.Files.fruit)
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
