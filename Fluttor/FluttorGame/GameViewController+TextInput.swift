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
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    func updatePlayerNameInScene(_ name: String) {
        guard let skView = self.view as? SKView,
              let gameScene = skView.scene as? GameScene else { return }
        
        // Actualizar el nombre en la escena
        gameScene.updatePlayerName(name)
    }
}
