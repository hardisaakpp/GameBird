//
//  MovementUtilities.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 1/2/25.
//  Maneja movimiento de objetos

import SpriteKit

/// Retorna una acción que mueve un nodo hacia la izquierda hasta que se sale de la pantalla y luego lo remueve.
/// - Parameters:
///   - scene: La escena que define los límites de la pantalla.
///   - nodeWidth: El ancho del nodo (usado para calcular la distancia total a mover).
///   - movementSpeed: La velocidad (puntos por segundo) a la que se mueve el nodo.
func createMoveAndRemoveAction(for scene: SKScene, nodeWidth: CGFloat, movementSpeed: CGFloat) -> SKAction {
    // La distancia a recorrer es el ancho de la escena más el ancho del nodo (para que se mueva completamente fuera de la pantalla)
    let moveDistance = scene.frame.width + nodeWidth
    let moveDuration = TimeInterval(moveDistance / movementSpeed)
    let moveAction = SKAction.moveBy(x: -moveDistance, y: 0, duration: moveDuration)
    let removeAction = SKAction.removeFromParent()
    return SKAction.sequence([moveAction, removeAction])
}

/// Retorna una acción de movimiento continuo (looping) que desplaza un nodo una distancia horizontal y luego lo reinicia a su posición original.
/// - Parameters:
///   - distance: La distancia horizontal que se debe mover (valor negativo para moverse a la izquierda).
///   - movementSpeed: La velocidad (puntos por segundo) a la que se realiza el movimiento.
func createLoopingMovementAction(distance: CGFloat, movementSpeed: CGFloat) -> SKAction {
    let moveDuration = TimeInterval(abs(distance) / movementSpeed)
    let moveAction = SKAction.moveBy(x: distance, y: 0, duration: moveDuration)
    // Se utiliza un reset inmediato para volver a la posición inicial
    let resetAction = SKAction.moveBy(x: -distance, y: 0, duration: 0)
    return SKAction.repeatForever(SKAction.sequence([moveAction, resetAction]))
}
