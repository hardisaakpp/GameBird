#!/usr/bin/env python3
"""
Script completo para demostrar el Sistema de Tutorial Inteligente
Inicia la API y ejecuta pruebas automáticamente
"""

import subprocess
import time
import requests
import json
from datetime import datetime

def wait_for_api():
    """Esperar a que la API esté lista"""
    print("⏳ Esperando a que la API esté lista...")
    max_attempts = 30
    for attempt in range(max_attempts):
        try:
            response = requests.get("http://localhost:8000/health", timeout=2)
            if response.status_code == 200:
                print("✅ API lista!")
                return True
        except:
            pass
        time.sleep(1)
        if attempt % 5 == 0:
            print(f"   Intento {attempt + 1}/{max_attempts}...")
    
    print("❌ La API no se inició correctamente")
    return False

def run_demo():
    """Ejecutar demostración completa"""
    
    print("🚀 DEMOSTRACIÓN COMPLETA DEL SISTEMA DE TUTORIAL INTELIGENTE")
    print("=" * 70)
    
    # 1. Ejecutar demostración del motor
    print("\n1️⃣ Ejecutando demostración del motor de tutorial...")
    try:
        result = subprocess.run(["python3", "simple_demo.py"], 
                              capture_output=True, text=True, timeout=30)
        if result.returncode == 0:
            print("✅ Demostración del motor completada")
            # Mostrar parte de la salida
            lines = result.stdout.split('\n')
            for line in lines[:10]:  # Mostrar primeras 10 líneas
                if line.strip():
                    print(f"   {line}")
        else:
            print(f"❌ Error en demostración: {result.stderr}")
    except Exception as e:
        print(f"❌ Error ejecutando demostración: {e}")
    
    # 2. Iniciar API en segundo plano
    print("\n2️⃣ Iniciando API del sistema...")
    try:
        api_process = subprocess.Popen(["python3", "simple_api.py"], 
                                     stdout=subprocess.PIPE, 
                                     stderr=subprocess.PIPE)
        print("✅ API iniciada en segundo plano")
        
        # Esperar a que la API esté lista
        if not wait_for_api():
            api_process.terminate()
            return
        
        # 3. Ejecutar pruebas de la API
        print("\n3️⃣ Ejecutando pruebas de la API...")
        result = subprocess.run(["python3", "test_api.py"], 
                              capture_output=True, text=True, timeout=60)
        if result.returncode == 0:
            print("✅ Pruebas de API completadas")
            # Mostrar parte de la salida
            lines = result.stdout.split('\n')
            for line in lines:
                if line.strip() and ("✅" in line or "❌" in line or "ℹ️" in line):
                    print(f"   {line}")
        else:
            print(f"❌ Error en pruebas: {result.stderr}")
        
        # 4. Mostrar información final
        print("\n4️⃣ Información final del sistema...")
        try:
            response = requests.get("http://localhost:8000/")
            if response.status_code == 200:
                data = response.json()
                print(f"✅ API funcionando: {data['message']}")
                print(f"   - Versión: {data['version']}")
                print(f"   - Endpoints: {len(data['endpoints'])}")
            
            response = requests.get("http://localhost:8000/health")
            if response.status_code == 200:
                data = response.json()
                print(f"   - Jugadores: {data['players_registered']}")
                print(f"   - Sesiones: {data['active_sessions']}")
        except Exception as e:
            print(f"❌ Error obteniendo información: {e}")
        
        # Terminar API
        api_process.terminate()
        print("\n✅ API terminada")
        
    except Exception as e:
        print(f"❌ Error iniciando API: {e}")
    
    print("\n🎉 Demostración completada!")
    print("=" * 70)
    print("\n📋 RESUMEN DE LO QUE VISTE:")
    print("1. Motor de tutorial inteligente funcionando")
    print("2. API REST completa con FastAPI")
    print("3. Generación de tutoriales adaptativos")
    print("4. Análisis de comportamiento del jugador")
    print("5. Feedback en tiempo real")
    print("6. Sistema de recomendaciones personalizadas")
    print("\n🔗 Para usar la API completa:")
    print("   - Ejecuta: python3 simple_api.py")
    print("   - Visita: http://localhost:8000/docs")
    print("   - Prueba los endpoints manualmente")

if __name__ == "__main__":
    run_demo() 