//
//  ScoreTest.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 7/8/25.
//

import Foundation

// MARK: - Pruebas del ScoreManager
class ScoreTest {
    
    static func testScoreManager() {
        print("🧪 Iniciando pruebas del ScoreManager...")
        
        let scoreManager = ScoreManager.shared
        
        // Prueba 1: Verificar valores iniciales
        print("📊 Valores iniciales:")
        print("- High Score: \(scoreManager.highScore)")
        print("- Total Games: \(scoreManager.totalGamesPlayed)")
        print("- Total Score: \(scoreManager.totalScore)")
        
        // Prueba 2: Simular algunos juegos
        print("\n🎮 Simulando juegos...")
        
        let testScores = [5, 12, 8, 20, 15, 25, 18, 30]
        
        for (index, score) in testScores.enumerated() {
            print("Juego \(index + 1): Puntaje \(score)")
            let isNewRecord = scoreManager.updateHighScore(score)
            if isNewRecord {
                print("  🎉 ¡Nuevo récord!")
            }
        }
        
        // Prueba 3: Verificar estadísticas
        print("\n📈 Estadísticas finales:")
        print(scoreManager.getScoreStats())
        
        // Prueba 4: Verificar persistencia
        print("\n💾 Verificando persistencia...")
        let newScoreManager = ScoreManager.shared
        print("- High Score persistido: \(newScoreManager.highScore)")
        print("- Total Games persistido: \(newScoreManager.totalGamesPlayed)")
        
        print("\n✅ Pruebas completadas!")
    }
    
    static func resetScores() {
        print("🔄 Reseteando todos los puntajes...")
        ScoreManager.shared.resetAllScores()
        print("✅ Puntajes reseteados")
    }
}

// MARK: - Uso en el juego
/*
 Para usar el ScoreManager en tu juego:
 
 1. Al final de cada partida:
    ScoreManager.shared.recordGameResult(score: tuPuntaje)
 
 2. Para mostrar el mejor puntaje:
    let bestScore = ScoreManager.shared.highScore
 
 3. Para obtener estadísticas:
    let stats = ScoreManager.shared.getScoreStats()
 
 4. Para resetear (opcional):
    ScoreManager.shared.resetAllScores()
 */
