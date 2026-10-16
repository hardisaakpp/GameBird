import UIKit
import SpriteKit

// MARK: - Extensión para Manejo de Entrada de Texto
extension GameViewController {
    
    func showTextInputAlert(completion: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: "Ingresa tu nombre", message: "Escribe tu nombre para personalizar el juego", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Tu nombre"
            textField.text = Player.current.name
            textField.autocapitalizationType = .words
            textField.returnKeyType = .done
        }
        
        let confirmAction = UIAlertAction(title: "Confirmar", style: .default) { _ in
            if let textField = alertController.textFields?.first,
               let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
               !text.isEmpty {
                completion(text)
            } else {
                completion("Jugador")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            completion(Player.current.name)
        }
        
        alertController.addAction(confirmAction)
        
        // Permitir volver a usar un jugador registrado anteriormente
        let registered = ScoreManager.shared.getRegisteredPlayerNames()
        if !registered.isEmpty {
            alertController.addAction(UIAlertAction(title: "Elegir jugador registrado", style: .default) { [weak self] _ in
                self?.showRegisteredPlayersAlert(registered, completion: completion)
            })
        }
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func showRegisteredPlayersAlert(_ names: [String], completion: @escaping (String) -> Void) {
        let picker = UIAlertController(title: "Jugadores registrados", message: "Elige tu usuario para seguir sumando puntos", preferredStyle: .alert)
        for name in names.prefix(8) {
            let best = ScoreManager.shared.getBestScore(for: name)
            picker.addAction(UIAlertAction(title: "\(name) · \(best) pts", style: .default) { _ in
                completion(name)
            })
        }
        picker.addAction(UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            completion(Player.current.name)
        })
        present(picker, animated: true)
    }
    
    func updatePlayerNameInScene(_ name: String) {
        guard let skView = self.view as? SKView,
              let gameScene = skView.scene as? GameScene else { return }
        
        // Actualizar el nombre en la escena
        gameScene.updatePlayerName(name)
    }
}
