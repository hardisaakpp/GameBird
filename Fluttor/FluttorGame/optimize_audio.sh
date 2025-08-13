#!/bin/bash

# Script para optimizar archivos de audio del juego
# Convierte archivos WAV a formatos más eficientes

echo "🎵 Optimizando archivos de audio..."

# Verificar si ffmpeg está instalado
if ! command -v ffmpeg &> /dev/null; then
    echo "❌ ffmpeg no está instalado. Instalando..."
    brew install ffmpeg
fi

# Crear directorio para archivos optimizados
mkdir -p optimized_audio

# Convertir archivos WAV a AAC (más eficiente)
echo "🔄 Convirtiendo archivos WAV a AAC..."

for file in *.wav; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .wav)
        echo "Convirtiendo $file..."
        ffmpeg -i "$file" -c:a aac -b:a 64k "optimized_audio/${filename}.m4a" -y
    fi
done

# Convertir también a MP3 como alternativa
echo "🔄 Convirtiendo archivos WAV a MP3..."

for file in *.wav; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .wav)
        echo "Convirtiendo $file..."
        ffmpeg -i "$file" -c:a mp3 -b:a 64k "optimized_audio/${filename}.mp3" -y
    fi
done

echo "✅ Optimización completada!"
echo "📁 Archivos optimizados en: optimized_audio/"
echo "📊 Comparación de tamaños:"
echo ""

# Mostrar comparación de tamaños
for file in *.wav; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .wav)
        wav_size=$(stat -f%z "$file")
        m4a_size=$(stat -f%z "optimized_audio/${filename}.m4a" 2>/dev/null || echo "N/A")
        mp3_size=$(stat -f%z "optimized_audio/${filename}.mp3" 2>/dev/null || echo "N/A")
        
        echo "$filename:"
        echo "  WAV: $(($wav_size / 1024))KB"
        echo "  M4A: $(($m4a_size / 1024))KB (si existe)"
        echo "  MP3: $(($mp3_size / 1024))KB (si existe)"
        echo ""
    fi
done
