import UIKit
import SpriteKit

// MARK: - Prueba de Fuentes Disponibles
class FontTest {
    
    static func testAvailableFonts() {
        print("🔍 VERIFICANDO FUENTES DISPONIBLES...")
        print("=====================================")
        
        // Probar fuentes específicas que queremos usar
        let targetFonts = [
            "Courier",
            "Courier-Bold", 
            "CourierNewPSMT",
            "CourierNewPS-BoldMT",
            "Monaco",
            "Menlo",
            "Menlo-Bold",
            "Impact",
            "Arial-BoldMT",
            "HelveticaNeue",
            "HelveticaNeue-Bold"
        ]
        
        print("\n🎯 FUENTES OBJETIVO:")
        for font in targetFonts {
            if UIFont(name: font, size: 16) != nil {
                print("✅ \(font) - DISPONIBLE")
            } else {
                print("❌ \(font) - NO DISPONIBLE")
            }
        }
        
        // Listar todas las fuentes del sistema
        print("\n📋 TODAS LAS FUENTES DEL SISTEMA:")
        let allFonts = UIFont.familyNames.sorted()
        for family in allFonts {
            print("🏷️ Familia: \(family)")
            let names = UIFont.fontNames(forFamilyName: family)
            for name in names {
                print("   📝 \(name)")
            }
        }
        
        // Probar fuentes específicas con diferentes tamaños
        print("\n🧪 PRUEBA DE FUENTES ESPECÍFICAS:")
        let testFonts = ["Courier-Bold", "Impact", "Monaco"]
        for fontName in testFonts {
            if let font = UIFont(name: fontName, size: 20) {
                print("✅ \(fontName) funciona - Tamaño: \(font.pointSize)")
            } else {
                print("❌ \(fontName) no funciona")
            }
        }
    }
    
    static func getBestAvailableFont() -> String {
        // Prioridad de fuentes para gaming
        let priorityFonts = [
            "Impact",           // Excelente para títulos de juegos
            "Courier-Bold",     // Monospace, buena para botones
            "CourierNewPS-BoldMT", // Alternativa a Courier-Bold
            "Monaco",           // Monospace elegante
            "Menlo-Bold",       // Monospace moderna
            "Arial-BoldMT",     // Bold, buena legibilidad
            "HelveticaNeue-Bold" // Moderna y legible
        ]
        
        for font in priorityFonts {
            if UIFont(name: font, size: 16) != nil {
                print("🎯 Usando fuente: \(font)")
                return font
            }
        }
        
        print("⚠️ Usando fuente de fallback: AvenirNext-Bold")
        return "AvenirNext-Bold"
    }
}

// MARK: - Extensión para Probar en GameScene
extension GameScene {
    func testFontsInGame() {
        // Crear un nodo de prueba para ver las fuentes
        let testNode = SKNode()
        testNode.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        
        let fonts = ["Impact", "Courier-Bold", "Monaco", "Arial-BoldMT"]
        var yOffset: CGFloat = 0
        
        for (index, fontName) in fonts.enumerated() {
            if UIFont(name: fontName, size: 20) != nil {
                let label = SKLabelNode(text: "Prueba: \(fontName)")
                label.fontName = fontName
                label.fontSize = 20
                label.fontColor = .white
                label.position = CGPoint(x: 0, y: yOffset)
                testNode.addChild(label)
                yOffset -= 30
                
                print("✅ Fuente \(fontName) agregada al test")
            } else {
                print("❌ Fuente \(fontName) no disponible")
            }
        }
        
        if !testNode.children.isEmpty {
            addChild(testNode)
            
            // Remover después de 5 segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                testNode.removeFromParent()
            }
        }
    }
}
