//
//  GameViewController.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 25/1/25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as? GameScene,
               let skView = self.view as? SKView {
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill

                // Present the scene
                skView.presentScene(sceneNode)
                skView.ignoresSiblingOrder = true
                // OPTIMIZACIÓN: Desactivar debug para mejor rendimiento
                skView.showsFPS = false
                skView.showsNodeCount = false
            }
        }

        // Auto-pausar cuando la app pierde foco o entra en background
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppDeactivation), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppDeactivation), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc private func handleAppDeactivation() {
        guard let skView = self.view as? SKView,
              let gameScene = skView.scene as? GameScene else { return }
        gameScene.pauseGame()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
