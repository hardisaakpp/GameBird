//
//  SceneDelegate.swift
//  WordCraftGame
//
//  Ciclo de vida UIScene, obligatorio en apps compiladas con el SDK de iOS 27.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Con UIScene ya no se crea la ventana desde UIMainStoryboardFile:
        // se instancia el controlador inicial de Main.storyboard (GameViewController).
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        self.window = window
        window.makeKeyAndVisible()
    }
}
