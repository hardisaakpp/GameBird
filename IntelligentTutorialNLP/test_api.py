#!/usr/bin/env python3
"""
Script de prueba para la API del Sistema de Tutorial Inteligente
"""

import requests
import json
from datetime import datetime

# Configuración
BASE_URL = "http://localhost:8000"

def test_api_endpoints():
    """Probar todos los endpoints de la API"""
    
    print("🧪 PRUEBAS DE LA API DEL SISTEMA DE TUTORIAL INTELIGENTE")
    print("=" * 60)
    
    # 1. Probar endpoint raíz
    print("\n1️⃣ Probando endpoint raíz...")
    try:
        response = requests.get(f"{BASE_URL}/")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ API funcionando: {data['message']}")
            print(f"   - Versión: {data['version']}")
            print(f"   - Endpoints disponibles: {len(data['endpoints'])}")
        else:
            print(f"❌ Error: {response.status_code}")
    except Exception as e:
        print(f"❌ Error conectando a la API: {e}")
        return
    
    # 2. Probar health check
    print("\n2️⃣ Probando health check...")
    try:
        response = requests.get(f"{BASE_URL}/health")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Sistema saludable: {data['status']}")
            print(f"   - Jugadores registrados: {data['players_registered']}")
            print(f"   - Sesiones activas: {data['active_sessions']}")
        else:
            print(f"❌ Error: {response.status_code}")
    except Exception as e:
        print(f"❌ Error: {e}")
    
    # 3. Probar generación de tutorial
    print("\n3️⃣ Probando generación de tutorial...")
    try:
        tutorial_request = {
            "player_id": "test_player_001",
            "tutorial_type": "onboarding",
            "game_context": {
                "game_state": "game_over",
                "score": 5,
                "attempts": 15
            },
            "preferred_language": "es"
        }
        
        response = requests.post(f"{BASE_URL}/api/v1/tutorial/generate", json=tutorial_request)
        if response.status_code == 200:
            data = response.json()
            tutorial = data['tutorial_session']
            print(f"✅ Tutorial generado exitosamente:")
            print(f"   - Session ID: {tutorial['session_id']}")
            print(f"   - Tipo: {tutorial['difficulty_level']}")
            print(f"   - Duración: {tutorial['estimated_duration']} minutos")
            print(f"   - Contenido: {tutorial['content'][:100]}...")
        else:
            print(f"❌ Error: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"❌ Error: {e}")
    
    # 4. Probar generación de feedback
    print("\n4️⃣ Probando generación de feedback...")
    try:
        feedback_request = {
            "player_id": "test_player_001",
            "trigger_event": "collision",
            "game_state": {
                "score": 3,
                "attempts": 10,
                "current_obstacle": "pipe"
            }
        }
        
        response = requests.post(f"{BASE_URL}/api/v1/tutorial/feedback", json=feedback_request)
        if response.status_code == 200:
            data = response.json()
            feedback = data['feedback']
            print(f"✅ Feedback generado exitosamente:")
            print(f"   - Mensaje: {feedback['message']}")
            print(f"   - Tips: {', '.join(feedback['tips'][:2])}")
            print(f"   - Aliento: {feedback['encouragement']}")
        else:
            print(f"❌ Error: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"❌ Error: {e}")
    
    # 5. Probar análisis de sesión
    print("\n5️⃣ Probando análisis de sesión...")
    try:
        session_data = {
            "player_id": "test_player_001",
            "session_duration": 180.0,
            "score": 8,
            "attempts": 12,
            "pipe_collisions": 6,
            "reaction_times": [0.8, 0.9, 1.1, 0.7, 0.8],
            "difficulty_level": "medium",
            "timestamp": datetime.now().isoformat()
        }
        
        response = requests.post(f"{BASE_URL}/api/v1/tutorial/analyze-session", json=session_data)
        if response.status_code == 200:
            data = response.json()
            analysis = data['analysis']
            print(f"✅ Análisis de sesión completado:")
            print(f"   - Nivel de habilidad: {analysis['skill_analysis']['skill_level']}")
            print(f"   - Eficiencia: {analysis['skill_analysis']['efficiency']:.2f}")
            print(f"   - Tutorial recomendado: {analysis['tutorial_needed']}")
        else:
            print(f"❌ Error: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"❌ Error: {e}")
    
    # 6. Probar recomendaciones
    print("\n6️⃣ Probando recomendaciones...")
    try:
        response = requests.get(f"{BASE_URL}/api/v1/tutorial/recommendations/test_player_001")
        if response.status_code == 200:
            data = response.json()
            if data['success']:
                recommendations = data['recommendations']
                print(f"✅ Recomendaciones generadas:")
                print(f"   - Nivel de habilidad: {recommendations['skill_level']:.2f}")
                print(f"   - Estilo de aprendizaje: {recommendations['learning_style']}")
                print(f"   - Tutoriales recomendados: {', '.join(recommendations['recommended_tutorials'])}")
            else:
                print(f"ℹ️ {data['message']}")
        else:
            print(f"❌ Error: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"❌ Error: {e}")
    
    # 7. Probar lista de jugadores
    print("\n7️⃣ Probando lista de jugadores...")
    try:
        response = requests.get(f"{BASE_URL}/api/v1/players")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Jugadores registrados: {data['total_players']}")
            for player in data['players']:
                print(f"   - {player['player_id']}: Nivel {player['skill_level']:.2f} ({player['learning_style']})")
        else:
            print(f"❌ Error: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"❌ Error: {e}")
    
    # 8. Probar sesiones activas
    print("\n8️⃣ Probando sesiones activas...")
    try:
        response = requests.get(f"{BASE_URL}/api/v1/sessions")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Sesiones activas: {data['total_sessions']}")
            for session in data['sessions']:
                print(f"   - {session['session_id']}: {session['tutorial_type']} ({session['difficulty_level']})")
        else:
            print(f"❌ Error: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"❌ Error: {e}")
    
    print("\n🎉 Pruebas completadas!")
    print("=" * 60)

if __name__ == "__main__":
    print("🚀 Iniciando pruebas de la API...")
    print("⚠️  Asegúrate de que la API esté ejecutándose en http://localhost:8000")
    print("   (Ejecuta 'python3 simple_api.py' en otra terminal)")
    
    input("\nPresiona Enter para continuar con las pruebas...")
    
    test_api_endpoints() 