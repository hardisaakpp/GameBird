//
//  ScoreManager.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 7/8/25.
//

import Foundation

class ScoreManager {
    static let shared = ScoreManager()
    
    // MARK: - Claves de UserDefaults
    private let highScoreKey = "HighScore"
    private let totalGamesPlayedKey = "TotalGamesPlayed"
    private let totalScoreKey = "TotalScore"
    
    // MARK: - Propiedades computadas
    var highScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: highScoreKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: highScoreKey)
        }
    }
    
    var totalGamesPlayed: Int {
        get {
            return UserDefaults.standard.integer(forKey: totalGamesPlayedKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: totalGamesPlayedKey)
        }
    }
    
    var totalScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: totalScoreKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: totalScoreKey)
        }
    }
    
    // MARK: - Inicialización
    private init() {
        // Configurar valores por defecto si es la primera vez
        if UserDefaults.standard.object(forKey: highScoreKey) == nil {
            highScore = 0
        }
        if UserDefaults.standard.object(forKey: totalGamesPlayedKey) == nil {
            totalGamesPlayed = 0
        }
        if UserDefaults.standard.object(forKey: totalScoreKey) == nil {
            totalScore = 0
        }
    }
    
    // MARK: - Métodos principales
    func updateHighScore(_ newScore: Int) -> Bool {
        if newScore > highScore {
            highScore = newScore
            return true // Nuevo récord
        }
        return false // No es récord
    }
    
    func recordGameResult(score: Int) {
        totalGamesPlayed += 1
        totalScore += score
        
        // Verificar si es un nuevo récord
        let isNewRecord = updateHighScore(score)
        
        if isNewRecord {
            print("🎉 ¡Nuevo récord! Puntaje: \(score)")
        }
        
        // Guardar inmediatamente
        UserDefaults.standard.synchronize()
    }
    
    func resetAllScores() {
        highScore = 0
        totalGamesPlayed = 0
        totalScore = 0
        UserDefaults.standard.synchronize()
        print("🔄 Todos los puntajes han sido reseteados")
    }
    
    func getAverageScore() -> Double {
        guard totalGamesPlayed > 0 else { return 0.0 }
        return Double(totalScore) / Double(totalGamesPlayed)
    }
    
    func getScoreStats() -> String {
        return """
        📊 Estadísticas del Juego:
        🏆 Mejor Puntaje: \(highScore)
        🎮 Juegos Jugados: \(totalGamesPlayed)
        📈 Puntaje Total: \(totalScore)
        📊 Promedio: \(String(format: "%.1f", getAverageScore()))
        """
    }
}
