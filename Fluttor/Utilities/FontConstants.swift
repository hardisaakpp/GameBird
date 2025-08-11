import UIKit

// MARK: - Constantes de Fuentes Pixel Art
struct FontConstants {
    
    // MARK: - Fuentes Pixel Art Disponibles
    struct PixelArt {
        // Fuentes del sistema que tienen estilo pixel art
        static let pressStart2P = "PressStart2P-Regular"
        static let vt323 = "VT323-Regular"
        static let silkscreen = "Silkscreen-Regular"
        
        // Fuentes alternativas del sistema (fallback)
        static let courier = "Courier"
        static let courierBold = "Courier-Bold"
        static let monaco = "Monaco"
    }
    
    // MARK: - Fuentes Actuales (para mantener compatibilidad)
    struct Current {
        static let avenirBold = "AvenirNext-Bold"
        static let avenirMedium = "AvenirNext-Medium"
        static let avenirRegular = "AvenirNext-Regular"
    }
    
    // MARK: - Fuentes del Sistema que SÍ están Disponibles
    struct SystemAvailable {
        // Fuentes monospace que están garantizadas en iOS
        static let courier = "Courier"
        static let courierBold = "Courier-Bold"
        static let courierNew = "CourierNewPSMT"
        static let courierNewBold = "CourierNewPS-BoldMT"
        static let monaco = "Monaco"
        static let menlo = "Menlo"
        static let menloBold = "Menlo-Bold"
        
        // Fuentes del sistema con estilo más "gaming"
        static let impact = "Impact"
        static let arialBlack = "Arial-BoldMT"
        static let helveticaNeue = "HelveticaNeue"
        static let helveticaNeueBold = "HelveticaNeue-Bold"
    }
    
    // MARK: - Configuración de Fuentes por Contexto
    struct GameUI {
        // Botones principales - usar fuentes garantizadas del sistema
        static let buttonFont = SystemAvailable.courierBold
        static let buttonFontSize: CGFloat = 26  // Ajustado para Courier
        
        // Títulos
        static let titleFont = SystemAvailable.impact
        static let titleFontSize: CGFloat = 36
        
        // Texto de pista
        static let hintFont = SystemAvailable.courier
        static let hintFontSize: CGFloat = 18
        
        // Puntajes
        static let scoreFont = SystemAvailable.courierBold
        static let scoreFontSize: CGFloat = 24
    }
    
    // MARK: - Verificación de Fuentes Disponibles
    static func getAvailableFont() -> String {
        let fonts = [
            SystemAvailable.courierBold,
            SystemAvailable.impact,
            SystemAvailable.courier,
            SystemAvailable.monaco,
            SystemAvailable.menloBold,
            Current.avenirBold  // Fallback final
        ]
        
        for font in fonts {
            if UIFont(name: font, size: 16) != nil {
                return font
            }
        }
        
        // Si ninguna está disponible, usar la fuente del sistema
        return Current.avenirBold
    }
    
    // MARK: - Listar Todas las Fuentes Disponibles (Para Debug)
    static func listAllAvailableFonts() -> [String] {
        var availableFonts: [String] = []
        
        // Fuentes del sistema
        let systemFonts = [
            "Courier", "Courier-Bold", "CourierNewPSMT", "CourierNewPS-BoldMT",
            "Monaco", "Menlo", "Menlo-Bold", "Impact", "Arial-BoldMT",
            "HelveticaNeue", "HelveticaNeue-Bold", "AvenirNext-Bold",
            "AvenirNext-Medium", "AvenirNext-Regular"
        ]
        
        for font in systemFonts {
            if UIFont(name: font, size: 16) != nil {
                availableFonts.append(font)
            }
        }
        
        // También listar todas las fuentes del sistema (puede ser lento)
        let allFonts = UIFont.familyNames.sorted()
        for family in allFonts {
            let names = UIFont.fontNames(forFamilyName: family)
            availableFonts.append(contentsOf: names)
        }
        
        return availableFonts
    }
    
    // MARK: - Tamaños de Fuente Adaptativos
    static func getAdaptiveFontSize(for baseSize: CGFloat, fontName: String) -> CGFloat {
        // Ajustar tamaño según la fuente para mantener legibilidad
        switch fontName {
        case SystemAvailable.impact:
            return baseSize * 0.9  // Impact es más grande
        case SystemAvailable.courierBold:
            return baseSize * 1.0  // Courier Bold es estándar
        case SystemAvailable.courier:
            return baseSize * 1.1  // Courier regular es más pequeña
        case SystemAvailable.monaco:
            return baseSize * 1.0  // Monaco es estándar
        default:
            return baseSize
        }
    }
}
