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
    private let playerScoresKey = "PlayerScores" // Nuevo: puntajes por jugador
    
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
    
    // MARK: - Sistema de Puntajes por Jugador
    
    /// Estructura para almacenar información del puntaje de un jugador
    struct PlayerScore: Codable {
        let playerName: String
        let score: Int
        let date: Date
        let gameMode: String // "NORMAL" o "BÁSICO"
        
        init(playerName: String, score: Int, gameMode: GameMode) {
            self.playerName = playerName
            self.score = score
            self.date = Date()
            self.gameMode = gameMode.displayName
        }
    }
    
    /// Obtener todos los puntajes guardados
    private func getAllPlayerScores() -> [PlayerScore] {
        guard let data = UserDefaults.standard.data(forKey: playerScoresKey),
              let scores = try? JSONDecoder().decode([PlayerScore].self, from: data) else {
            return []
        }
        return scores
    }
    
    /// Guardar todos los puntajes
    private func savePlayerScores(_ scores: [PlayerScore]) {
        if let data = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(data, forKey: playerScoresKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    /// Registrar un nuevo puntaje para el jugador actual
    func recordPlayerScore(score: Int, gameMode: GameMode) {
        let playerName = Player.current.name
        let newScore = PlayerScore(playerName: playerName, score: score, gameMode: gameMode)
        
        var allScores = getAllPlayerScores()
        allScores.append(newScore)
        
        // Mantener solo los últimos 100 puntajes para no llenar la memoria
        if allScores.count > 100 {
            allScores = Array(allScores.suffix(100))
        }
        
        savePlayerScores(allScores)
        
        print("💾 Puntaje guardado: \(playerName) - \(score) pts (\(gameMode.displayName))")
    }
    
    /// Obtener el mejor puntaje del jugador actual
    func getCurrentPlayerHighScore() -> Int {
        let playerName = Player.current.name
        let playerScores = getAllPlayerScores().filter { $0.playerName == playerName }
        return playerScores.map { $0.score }.max() ?? 0
    }
    
    /// Obtener los últimos 5 puntajes del jugador actual
    func getCurrentPlayerRecentScores() -> [PlayerScore] {
        let playerName = Player.current.name
        let playerScores = getAllPlayerScores()
            .filter { $0.playerName == playerName }
            .sorted { $0.date > $1.date } // Más recientes primero
        return Array(playerScores.prefix(5))
    }
    
    /// Obtener los mejores 5 puntajes del jugador actual
    func getCurrentPlayerTop5Scores() -> [PlayerScore] {
        let playerName = Player.current.name
        let playerScores = getAllPlayerScores()
            .filter { $0.playerName == playerName }
            .sorted { $0.score > $1.score } // Mejores puntajes primero
        return Array(playerScores.prefix(5))
    }
    
    /// Obtener el top 10 de todos los jugadores
    func getGlobalLeaderboard() -> [PlayerScore] {
        let allScores = getAllPlayerScores()
        // Agrupar por jugador y tomar el mejor puntaje de cada uno
        var bestScorePerPlayer: [String: PlayerScore] = [:]
        
        for score in allScores {
            if let existingScore = bestScorePerPlayer[score.playerName] {
                if score.score > existingScore.score {
                    bestScorePerPlayer[score.playerName] = score
                }
            } else {
                bestScorePerPlayer[score.playerName] = score
            }
        }
        
        return Array(bestScorePerPlayer.values)
            .sorted { $0.score > $1.score }
            .prefix(10)
            .map { $0 }
    }
    
    /// Obtener el top 5 de todos los jugadores (para el leaderboard de Game Over)
    func getTop5Leaderboard() -> [PlayerScore] {
        let allScores = getAllPlayerScores()
        // Agrupar por jugador y tomar el mejor puntaje de cada uno
        var bestScorePerPlayer: [String: PlayerScore] = [:]
        
        for score in allScores {
            if let existingScore = bestScorePerPlayer[score.playerName] {
                if score.score > existingScore.score {
                    bestScorePerPlayer[score.playerName] = score
                }
            } else {
                bestScorePerPlayer[score.playerName] = score
            }
        }
        
        return Array(bestScorePerPlayer.values)
            .sorted { $0.score > $1.score }
            .prefix(5) // Solo los mejores 5 jugadores
            .map { $0 }
    }
    
    /// Obtener estadísticas detalladas del jugador actual
    func getCurrentPlayerStats() -> String {
        let playerName = Player.current.name
        let playerScores = getAllPlayerScores().filter { $0.playerName == playerName }
        let highScore = getCurrentPlayerHighScore()
        let totalGames = playerScores.count
        let totalScore = playerScores.reduce(0) { $0 + $1.score }
        let average = totalGames > 0 ? Double(totalScore) / Double(totalGames) : 0.0
        
        return """
        👤 Estadísticas de \(playerName):
        🏆 Mejor Puntaje: \(highScore)
        🎮 Partidas Jugadas: \(totalGames)
        📈 Puntaje Total: \(totalScore)
        📊 Promedio: \(String(format: "%.1f", average))
        """
    }
}
