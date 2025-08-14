import Foundation

struct Player {
    var name: String
    
    static var current: Player {
        get {
            let name = UserDefaults.standard.string(forKey: "PlayerName") ?? "Jugador"
            return Player(name: name)
        }
        set {
            UserDefaults.standard.set(newValue.name, forKey: "PlayerName")
        }
    }
}
