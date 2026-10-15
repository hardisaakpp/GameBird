import Foundation

/// Log de depuración sin costo en el hot path.
/// `print` dentro de Xcode bloquea el hilo principal hasta escribir en la consola,
/// lo que causa hitches al colisionar. Con `enabled = false` (por defecto) el mensaje
/// ni siquiera se construye. Actívalo solo cuando necesites ver los logs del juego.
enum DebugLog {
    #if DEBUG
    static var enabled = false
    #endif
}

@inline(__always)
func debugLog(_ message: @autoclosure () -> String) {
    #if DEBUG
    if DebugLog.enabled { print(message()) }
    #endif
}
