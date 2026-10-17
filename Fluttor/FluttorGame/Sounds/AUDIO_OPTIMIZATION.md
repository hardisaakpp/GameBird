# (Anexo) Optimización de audio

Capítulo: [`docs/07-audio.md`](../../docs/07-audio.md).

> **Nota:** este anexo describe el diseño anterior basado en `AVAudioPlayer`. El motor actual (`AVAudioEngine` con grupo de voces) se documenta en [`docs/07-audio.md`](../../docs/07-audio.md) §7.4.

---

# 🚀 Optimización de Audio - WordCraftGame

## 📊 Problemas de Rendimiento Identificados

### **❌ Problemas Originales:**
1. **Carga síncrona** - Archivos se cargan en hilo principal
2. **Archivos WAV grandes** - Formato no comprimido (194KB - 354KB)
3. **Sin precarga** - Sonidos se cargan al momento
4. **Sin límite de instancias** - Múltiples sonidos simultáneos
5. **Configuración de audio básica** - Sin optimizaciones

### **✅ Soluciones Implementadas:**

## 🎯 **Optimizaciones de Rendimiento**

### **1. Precarga de Sonidos**
```swift
// Precarga todos los sonidos al inicio del juego
AudioManager.shared.preloadSounds()
```
- **Beneficio**: Elimina latencia durante el juego
- **Implementación**: Carga en hilo de fondo

### **2. Límite de Sonidos Concurrentes**
```swift
private let maxConcurrentSounds = 3
```
- **Beneficio**: Evita sobrecarga de audio
- **Implementación**: Máximo 3 sonidos simultáneos

### **3. Carga Asíncrona**
```swift
DispatchQueue.global(qos: .userInitiated).async {
    // Carga de sonidos
}
```
- **Beneficio**: No bloquea el hilo principal
- **Implementación**: Carga en hilo de alta prioridad

### **4. Configuración de Audio Optimizada**
```swift
try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
```
- **Beneficio**: Mejor integración con otros audio
- **Implementación**: Modo ambiental con mezcla

### **5. Volumen Reducido**
```swift
static let volume: Float = 0.7  // En lugar de 1.0
```
- **Beneficio**: Menor procesamiento de audio
- **Implementación**: Volumen al 70%

## 📁 **Optimización de Formatos**

### **Orden de Preferencia:**
1. **M4A (AAC)** - Más eficiente, menor tamaño
2. **MP3** - Alternativa compatible
3. **WAV** - Fallback original

### **Script de Optimización:**
```bash
# Ejecutar para convertir archivos
./optimize_audio.sh
```

### **Comparación de Tamaños:**
```
wing.wav:   29KB → wing.m4a: ~8KB   (72% reducción)
hit.wav:    96KB → hit.m4a:  ~25KB  (74% reducción)
die.wav:    194KB → die.m4a: ~50KB  (74% reducción)
point.wav:  177KB → point.m4a: ~45KB (75% reducción)
swoosh.wav: 354KB → swoosh.m4a: ~90KB (75% reducción)
```

## 🔧 **Configuración Técnica**

### **AudioManager Optimizado:**
- ✅ Precarga automática
- ✅ Límite de sonidos concurrentes
- ✅ Carga asíncrona
- ✅ Gestión de memoria
- ✅ Configuración optimizada de sesión

### **Constantes de Rendimiento:**
```swift
struct Performance {
    static let enablePreloading = true
    static let enableConcurrentLimit = true
    static let enableBackgroundLoading = true
    static let enableAudioSessionOptimization = true
}
```

## 📈 **Resultados Esperados**

### **Antes de la Optimización:**
- ❌ Latencia al reproducir sonidos
- ❌ Archivos grandes (1.2MB total)
- ❌ Posible lag durante el juego
- ❌ Carga síncrona

### **Después de la Optimización:**
- ✅ Sin latencia (precarga)
- ✅ Archivos optimizados (~300KB total)
- ✅ Rendimiento fluido
- ✅ Carga asíncrona

## 🎮 **Uso en el Juego**

### **Inicialización:**
```swift
// En didMove(to view:)
AudioManager.shared.preloadSounds()
```

### **Reproducción:**
```swift
// Los métodos existentes funcionan igual
AudioManager.shared.playWingSound()
AudioManager.shared.playHitSound()
```

### **Monitoreo:**
```swift
// Ver información de rendimiento
print(AudioManager.shared.getPerformanceInfo())
```

## 🚀 **Próximos Pasos**

1. **Ejecutar script de optimización** para convertir archivos
2. **Probar rendimiento** con archivos optimizados
3. **Ajustar configuración** según necesidades
4. **Monitorear uso de memoria** durante el juego

¡La optimización debería eliminar completamente la ralentización del audio! 🎵
