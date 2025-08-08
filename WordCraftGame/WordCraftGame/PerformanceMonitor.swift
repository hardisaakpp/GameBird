//
//  PerformanceMonitor.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 7/8/25.
//

import Foundation
import SpriteKit

class PerformanceMonitor {
    static let shared = PerformanceMonitor()
    
    private var frameCount = 0
    private var lastFrameTime: TimeInterval = 0
    private var fpsHistory: [Double] = []
    private let maxHistorySize = 60 // 1 segundo a 60 FPS
    
    private init() {}
    
    // MARK: - Monitoreo de FPS
    func updateFrame() {
        frameCount += 1
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastFrameTime >= 1.0 {
            let fps = Double(frameCount)
            fpsHistory.append(fps)
            
            // Mantener solo los últimos valores
            if fpsHistory.count > maxHistorySize {
                fpsHistory.removeFirst()
            }
            
            // Mostrar FPS si es bajo
            if fps < 50 {
                print("⚠️ FPS bajo detectado: \(fps)")
            }
            
            frameCount = 0
            lastFrameTime = currentTime
        }
    }
    
    // MARK: - Información de rendimiento
    func getPerformanceInfo() -> String {
        let avgFPS = fpsHistory.isEmpty ? 0 : fpsHistory.reduce(0, +) / Double(fpsHistory.count)
        let minFPS = fpsHistory.min() ?? 0
        let maxFPS = fpsHistory.max() ?? 0
        
        return """
        📊 Performance Monitor:
        - FPS Promedio: \(String(format: "%.1f", avgFPS))
        - FPS Mínimo: \(String(format: "%.1f", minFPS))
        - FPS Máximo: \(String(format: "%.1f", maxFPS))
        - Muestras: \(fpsHistory.count)
        """
    }
    
    // MARK: - Optimizaciones automáticas
    func suggestOptimizations() -> [String] {
        let avgFPS = fpsHistory.isEmpty ? 0 : fpsHistory.reduce(0, +) / Double(fpsHistory.count)
        var suggestions: [String] = []
        
        if avgFPS < 55 {
            suggestions.append("🔧 Reducir efectos visuales")
            suggestions.append("🔧 Optimizar física del pájaro")
            suggestions.append("🔧 Reducir sonidos concurrentes")
        }
        
        if avgFPS < 45 {
            suggestions.append("🚨 Desactivar debug de físicas")
            suggestions.append("🚨 Reducir calidad de audio")
            suggestions.append("🚨 Simplificar colisiones")
        }
        
        return suggestions
    }
    
    // MARK: - Limpieza
    func reset() {
        frameCount = 0
        lastFrameTime = 0
        fpsHistory.removeAll()
    }
}
