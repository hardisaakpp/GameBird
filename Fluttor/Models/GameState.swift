//
//  GameState.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 18/5/25.
//

class GameState {
    static let shared = GameState()
    private init() {}
    
    var isGameOver = false
    
    func reset() {
        isGameOver = false
    }
}
