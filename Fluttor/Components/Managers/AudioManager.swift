//
//  AudioManager.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 7/8/25.
//

import SpriteKit
import AVFoundation

/// Reproducción de efectos de baja latencia con AVAudioEngine.
///
/// - Los sonidos se decodifican una vez a buffers PCM en memoria (mismo formato para todos).
/// - Un pool de AVAudioPlayerNode siempre "en play" reproduce los buffers: lanzar un sonido es
///   solo encolar un buffer, sin arrancar nada en el hilo principal.
/// - Todo el estado vive en `queue` (serial). Las funciones públicas son seguras desde cualquier hilo.
/// - Si el motor no puede arrancar, se usa AVAudioPlayer como respaldo.
final class AudioManager {
    static let shared = AudioManager()

    // MARK: - Estado (solo se toca desde `queue`)
    private let queue = DispatchQueue(label: "game.audio", qos: .userInteractive)
    private let engine = AVAudioEngine()
    // Formato único del grafo: los archivos (mono/estéreo, cualquier tasa) se convierten a este.
    private let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 2, interleaved: false)!
    private let voiceCount = 8
    private var voices: [AVAudioPlayerNode] = []
    private var voiceBusyUntil: [CFTimeInterval] = []
    private var buffers: [String: AVAudioPCMBuffer] = [:]
    private var fallbackPlayers: [String: AVAudioPlayer] = [:]
    private var isSoundEnabled = true
    private var isPreloaded = false
    private var isGraphBuilt = false

    private init() {
        observeAudioEvents()
    }

    // MARK: - Precarga (ejecutar al inicio del juego)
    func preloadSounds() {
        queue.async { [self] in prepareIfNeeded() }
    }

    private func prepareIfNeeded() {
        guard !isPreloaded else { return }
        configureSession()
        loadBuffers()
        buildGraph()
        _ = startEngine()
        isPreloaded = true
        debugLog("✅ Sonidos precargados exitosamente (AVAudioEngine): \(buffers.count)")
    }

    private func configureSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            // Búfer de hardware pequeño = menos latencia (el sistema puede ajustarlo).
            try session.setPreferredIOBufferDuration(0.005)
            try session.setActive(true)
        } catch {
            debugLog("Error configurando sesión de audio: \(error)")
        }
    }

    private func loadBuffers() {
        let names = [
            SoundConstants.Files.wing,
            SoundConstants.Files.hit,
            SoundConstants.Files.die,
            SoundConstants.Files.point,
            SoundConstants.Files.swoosh,
            SoundConstants.Files.coin,
            SoundConstants.Files.fruit
        ]
        for name in names where buffers[name] == nil {
            if let buffer = makeBuffer(named: name) {
                buffers[name] = buffer
            }
        }
    }

    /// Decodifica un WAV completo y lo convierte al formato del grafo.
    private func makeBuffer(named name: String) -> AVAudioPCMBuffer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            debugLog("❌ No se pudo encontrar: \(name).wav")
            return nil
        }
        do {
            let file = try AVAudioFile(forReading: url)
            let source = file.processingFormat
            guard let input = AVAudioPCMBuffer(pcmFormat: source, frameCapacity: AVAudioFrameCount(file.length)) else { return nil }
            try file.read(into: input)

            guard let converter = AVAudioConverter(from: source, to: format) else { return nil }
            let ratio = format.sampleRate / source.sampleRate
            let capacity = AVAudioFrameCount(Double(input.frameLength) * ratio) + 1024
            guard let output = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: capacity) else { return nil }

            var delivered = false
            var conversionError: NSError?
            let status = converter.convert(to: output, error: &conversionError) { _, outStatus in
                if delivered {
                    outStatus.pointee = .endOfStream
                    return nil
                }
                delivered = true
                outStatus.pointee = .haveData
                return input
            }
            if status == .error || output.frameLength == 0 {
                debugLog("❌ Error convirtiendo \(name).wav: \(String(describing: conversionError))")
                return nil
            }
            debugLog("✅ Precargado: \(name).wav")
            return output
        } catch {
            debugLog("❌ Error precargando \(name).wav: \(error)")
            return nil
        }
    }

    private func buildGraph() {
        guard !isGraphBuilt else { return }
        isGraphBuilt = true
        engine.mainMixerNode.outputVolume = SoundConstants.Audio.volume
        for _ in 0..<voiceCount {
            let node = AVAudioPlayerNode()
            engine.attach(node)
            engine.connect(node, to: engine.mainMixerNode, format: format)
            voices.append(node)
            voiceBusyUntil.append(0)
        }
    }

    /// Arranca el motor si está detenido (primer uso, interrupción, vuelta de segundo plano...).
    @discardableResult
    private func startEngine() -> Bool {
        if engine.isRunning { return true }
        do {
            engine.prepare()
            try engine.start()
            voices.forEach { $0.play() }
            return true
        } catch {
            debugLog("❌ No se pudo iniciar AVAudioEngine: \(error)")
            return false
        }
    }

    // MARK: - Reproducción
    func playSound(_ soundName: String, fileExtension: String = "wav") {
        queue.async { [self] in
            guard isSoundEnabled else { return }
            prepareIfNeeded()

            guard let buffer = buffers[soundName], startEngine() else {
                playWithFallback(soundName, fileExtension: fileExtension)
                return
            }

            // Voz libre; si todas están ocupadas, se interrumpe la que termina antes.
            let now = CACurrentMediaTime()
            let index = voiceBusyUntil.firstIndex(where: { $0 <= now })
                ?? voiceBusyUntil.indices.min(by: { voiceBusyUntil[$0] < voiceBusyUntil[$1] })
                ?? 0
            let voice = voices[index]
            voiceBusyUntil[index] = now + Double(buffer.frameLength) / format.sampleRate

            voice.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
            if !voice.isPlaying { voice.play() }
        }
    }

    /// Respaldo si el motor no arranca o falta el buffer: AVAudioPlayer clásico.
    private func playWithFallback(_ soundName: String, fileExtension: String) {
        if fallbackPlayers[soundName] == nil,
           let url = Bundle.main.url(forResource: soundName, withExtension: fileExtension),
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.volume = SoundConstants.Audio.volume
            player.prepareToPlay()
            fallbackPlayers[soundName] = player
        }
        guard let player = fallbackPlayers[soundName] else {
            debugLog("No se pudo reproducir el sonido: \(soundName).\(fileExtension)")
            return
        }
        player.currentTime = 0
        player.play()
    }

    // MARK: - Recuperación (interrupciones, segundo plano, cambio de salida)
    private func observeAudioEvents() {
        let center = NotificationCenter.default
        let restart: (Notification) -> Void = { [weak self] _ in
            self?.queue.async { self?.recoverEngine() }
        }
        center.addObserver(forName: .AVAudioEngineConfigurationChange, object: engine, queue: nil, using: restart)
        center.addObserver(forName: AVAudioSession.mediaServicesWereResetNotification, object: nil, queue: nil, using: restart)
        center.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil, using: restart)
        center.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: nil) { [weak self] note in
            guard let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  AVAudioSession.InterruptionType(rawValue: raw) == .ended else { return }
            self?.queue.async { self?.recoverEngine() }
        }
    }

    private func recoverEngine() {
        guard isPreloaded else { return }
        try? AVAudioSession.sharedInstance().setActive(true)
        startEngine()
    }

    // MARK: - Métodos específicos
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
        queue.async { [self] in isSoundEnabled.toggle() }
    }

    func setSoundEnabled(_ enabled: Bool) {
        queue.async { [self] in isSoundEnabled = enabled }
    }

    func isSoundOn() -> Bool {
        return queue.sync { isSoundEnabled }
    }

    // MARK: - Limpieza
    func stopAllSounds() {
        queue.async { [self] in
            voices.forEach { $0.stop() }
            for index in voiceBusyUntil.indices { voiceBusyUntil[index] = 0 }
            fallbackPlayers.values.forEach { $0.stop() }
        }
    }

    func clearCache() {
        queue.async { [self] in
            voices.forEach { $0.stop() }
            buffers.removeAll()
            fallbackPlayers.removeAll()
            isPreloaded = false
        }
    }

    // MARK: - Información de rendimiento
    func getPerformanceInfo() -> String {
        return queue.sync {
            """
            🎵 AudioManager Performance:
            - Sonidos precargados: \(isPreloaded ? "Sí" : "No")
            - Sonidos en memoria: \(buffers.count)
            - Voces: \(voices.count) (motor \(engine.isRunning ? "activo" : "detenido"))
            - Audio habilitado: \(isSoundEnabled ? "Sí" : "No")
            """
        }
    }
}
