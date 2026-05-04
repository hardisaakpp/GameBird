# (Manual) Guía de Fuentes Gaming para iOS

Resumen en el capítulo: **[`docs/03-configuracion-herramientas-y-fuentes.md`](docs/03-configuracion-herramientas-y-fuentes.md)**.

---

# 🎮 Guía de Fuentes Gaming para iOS

## ⚠️ **IMPORTANTE: Fuentes Pixel Art NO Disponibles por Defecto**

Las fuentes pixel art como "Press Start 2P", "VT323" y "Silkscreen" **NO están incluidas** en iOS por defecto. Por eso estabas viendo fuentes genéricas como Arial.

## 🎯 **Solución Implementada: Fuentes del Sistema Gaming**

He actualizado el proyecto para usar fuentes del sistema que **SÍ están garantizadas** y tienen un estilo gaming/arcade:

### **✅ Fuentes Garantizadas en iOS:**

#### **🎮 Para Títulos (Estilo Arcade):**
- **Impact** - Clásica para títulos de juegos, muy llamativa
- **Arial-BoldMT** - Bold y legible, estilo gaming

#### **🔤 Para Botones (Monospace):**
- **Courier-Bold** - Monospace clásica, excelente para botones
- **CourierNewPS-BoldMT** - Versión moderna de Courier
- **Monaco** - Monospace elegante del sistema
- **Menlo-Bold** - Monospace moderna y legible

#### **📝 Para Textos (Legibilidad):**
- **HelveticaNeue-Bold** - Moderna y muy legible
- **AvenirNext-Bold** - Fallback garantizado

## 🚀 **Cómo Probar las Fuentes**

### **Opción 1: Consola de Xcode**
```swift
// En cualquier parte del código, agregar:
FontTest.testAvailableFonts()
```

### **Opción 2: En el Juego**
```swift
// En GameScene, agregar:
testFontsInGame()
```

## 🎨 **Nueva Paleta de Fuentes Implementada**

### **🔴 Botones Rojos (REINICIAR):**
- **Fuente:** Courier-Bold
- **Tamaño:** 26pt
- **Estilo:** Monospace, perfecta para botones

### **🟠 Botón Naranja (COMENZAR):**
- **Fuente:** Courier-Bold  
- **Tamaño:** 26pt
- **Estilo:** Consistente con otros botones

### **🟢 Botón Verde (REANUDAR):**
- **Fuente:** Courier-Bold
- **Tamaño:** 26pt
- **Estilo:** Monospace para botones

### **📱 Títulos de Pantallas:**
- **Fuente:** Impact
- **Tamaño:** 36pt
- **Estilo:** Clásico de arcade, muy llamativo

### **💡 Textos de Pista:**
- **Fuente:** Courier
- **Tamaño:** 18pt
- **Estilo:** Monospace legible

## 🔧 **Implementación Técnica**

### **Archivo: `FontConstants.swift`**
- ✅ Detecta automáticamente fuentes disponibles
- ✅ Usa fuentes garantizadas del sistema
- ✅ Fallback inteligente a AvenirNext
- ✅ Tamaños adaptativos según la fuente

### **Sistema de Fallback:**
1. **Impact** para títulos (estilo arcade)
2. **Courier-Bold** para botones (monospace)
3. **Courier** para textos (legibilidad)
4. **AvenirNext-Bold** como fallback final

## 🎯 **Beneficios de la Nueva Implementación**

1. **✅ Garantizado Funciona** - Usa solo fuentes del sistema
2. **🎮 Estilo Gaming** - Impact para títulos, Courier para botones
3. **👁️ Excelente Legibilidad** - Fuentes optimizadas para móviles
4. **🔄 Sin Dependencias** - No requiere archivos externos
5. **📱 Consistente** - Misma apariencia en todos los dispositivos

## 🚨 **Si Quieres Fuentes Pixel Art Personalizadas**

### **Paso 1: Descargar Fuentes**
- [Press Start 2P](https://fonts.google.com/specimen/Press+Start+2P)
- [VT323](https://fonts.google.com/specimen/VT323)
- [Silkscreen](https://fonts.google.com/specimen/Silkscreen)

### **Paso 2: Agregar al Proyecto**
1. Arrastrar archivos `.ttf` al proyecto
2. Marcar "Add to target"
3. Agregar en `Info.plist`:
```xml
<key>UIAppFonts</key>
<array>
    <string>PressStart2P-Regular.ttf</string>
    <string>VT323-Regular.ttf</string>
    <string>Silkscreen-Regular.ttf</string>
</array>
```

### **Paso 3: Actualizar FontConstants**
```swift
struct GameUI {
    static let buttonFont = "PressStart2P-Regular"
    static let titleFont = "PressStart2P-Regular"
    static let hintFont = "VT323-Regular"
}
```

## 🎉 **Resultado Actual**

**SIN archivos externos:**
- ✅ Títulos con Impact (estilo arcade)
- ✅ Botones con Courier-Bold (monospace)
- ✅ Textos con Courier (legibles)
- ✅ Funciona en TODOS los dispositivos iOS

**CON archivos externos:**
- 🎮 Títulos con Press Start 2P (pixel art puro)
- 🎮 Botones con VT323 (estilo retro)
- 🎮 Textos con Silkscreen (pixel art)

## 🔍 **Próximos Pasos**

1. **Probar el juego** con las nuevas fuentes del sistema
2. **Verificar en consola** qué fuentes están disponibles
3. **Decidir** si quieres agregar fuentes pixel art personalizadas
4. **Personalizar** tamaños y estilos según preferencias

¡Ahora deberías ver una diferencia notable en la apariencia del juego! 🎮✨
