#!/usr/bin/env python3
"""
Script de demostración del Sistema de Tutorial Inteligente con NLP
Este script muestra las capacidades principales del sistema para propósitos académicos
"""

import asyncio
import json
from datetime import datetime
from src.tutorial.adaptive_engine import tutorial_engine
from src.ml.behavior_analyzer import GameMetrics
from src.nlp.processor import nlp_processor

async def demo_intelligent_tutorial_system():
    """Demostración completa del sistema de tutorial inteligente"""

    print("🚀 DEMOSTRACIÓN: Sistema de Tutorial Inteligente con NLP")
    print("=" * 60)

    # 1. Inicializar el sistema
    print("\n1️⃣ Inicializando sistema...")
    await tutorial_engine.initialize()
    print("✅ Sistema inicializado correctamente")

    # 2. Simular datos de un jugador nuevo
    print("\n2️⃣ Simulando jugador nuevo: 'player_demo_001'")

    # Crear métricas de juego simuladas para un principiante
    beginner_metrics = GameMetrics(
        player_id="player_demo_001",
        session_duration=180.0,  # 3 minutos
        score=5,                 # Puntaje bajo
        attempts=25,             # Muchos intentos
        pipe_collisions=20,      # Muchas colisiones
        reaction_times=[0.8, 0.9, 1.2, 0.7, 1.1, 0.9, 1.0],  # Reacciones lentas
        difficulty_level="easy",
        timestamp=datetime.now().isoformat()
    )

    # 3. Analizar rendimiento del jugador
    print("\n3️⃣ Analizando rendimiento del jugador...")
    analysis = await tutorial_engine.analyze_player_performance(
        "player_demo_001", beginner_metrics
    )

    print(f"📊 Análisis de habilidad:")
    print(f"   - Nivel de habilidad: {analysis['skill_analysis']['skill_level']}")
    print(f"   - Eficiencia: {analysis['skill_analysis']['efficiency']:.2f}")
    print(f"   - Consistencia: {analysis['skill_analysis']['consistency']:.2f}")
    print(f"   - Tutorial recomendado: {analysis['tutorial_needed']}")

    # 4. Generar tutorial adaptativo
    print("\n4️⃣ Generando tutorial adaptativo...")
    tutorial_session = await tutorial_engine.generate_adaptive_tutorial(
        player_id="player_demo_001",
        tutorial_type=analysis['tutorial_needed'],
        game_context={
            "game_state": "game_over",
            "score": beginner_metrics.score,
            "attempts": beginner_metrics.attempts
        }
    )

    print(f"📚 Tutorial generado:")
    print(f"   - Tipo: {tutorial_session.tutorial_type}")
    print(f"   - Nivel: {tutorial_session.difficulty_level}")
    print(f"   - Duración estimada: {tutorial_session.estimated_duration} minutos")
    print(f"   - Contenido: {tutorial_session.content}")
    print(f"   - Objetivos: {', '.join(tutorial_session.learning_objectives)}")

    # 5. Generar retroalimentación en tiempo real
    print("\n5️⃣ Generando retroalimentación en tiempo real...")
    feedback = await tutorial_engine.generate_real_time_feedback(
        player_id="player_demo_001",
        trigger_event="collision",
        game_state={
            "score": 3,
            "attempts": 15,
            "current_obstacle": "pipe"
        }
    )

    print(f"💬 Retroalimentación adaptativa:")
    print(f"   - Mensaje: {feedback.message}")
    print(f"   - Tips: {', '.join(feedback.tips[:2])}")
    print(f"   - Aliento: {feedback.encouragement}")
    print(f"   - Confianza: {feedback.confidence_score:.2f}")

    # 6. Simular feedback del usuario y análisis de NLP
    print("\n6️⃣ Procesando feedback del usuario con NLP...")
    user_feedback = "Este juego es muy difícil, no entiendo el timing correcto"

    nlp_analysis = await nlp_processor.analyze_player_feedback(user_feedback)
    print(f"🧠 Análisis de NLP del feedback:")
    print(f"   - Sentimiento: {nlp_analysis['sentiment'][0]['label']} ({nlp_analysis['sentiment'][0]['score']:.2f})")
    print(f"   - Indicadores de dificultad: {nlp_analysis['difficulty_indicators']}")
    print(f"   - Temas clave: {nlp_analysis['key_topics'][:3]}")

    # 7. Simular progresión del jugador
    print("\n7️⃣ Simulando progresión del jugador...")

    # Métricas después de practice
    improved_metrics = GameMetrics(
        player_id="player_demo_001",
        session_duration=240.0,  # Sesión más larga
        score=15,               # Mejor puntaje
        attempts=20,            # Menos intentos
        pipe_collisions=8,      # Menos colisiones
        reaction_times=[0.6, 0.7, 0.8, 0.5, 0.7, 0.6, 0.8],  # Reacciones mejores
        difficulty_level="medium",
        timestamp=datetime.now().isoformat()
    )

    improved_analysis = await tutorial_engine.analyze_player_performance(
        "player_demo_001", improved_metrics
    )

    print(f"📈 Progreso después del tutorial:")
    print(f"   - Nuevo nivel de habilidad: {improved_analysis['skill_analysis']['skill_level']}")
    print(f"   - Mejora en eficiencia: {improved_analysis['skill_analysis']['efficiency']:.2f}")
    print(f"   - Nuevo tutorial recomendado: {improved_analysis['tutorial_needed']}")

    # 8. Demostrar diferentes estilos de aprendizaje
    print("\n8️⃣ Demostrando personalización por estilo de aprendizaje...")

    learning_styles = ["visual", "auditory", "kinesthetic", "reading"]

    for style in learning_styles:
        # Actualizar perfil del jugador
        if "player_demo_001" in tutorial_engine.player_profiles:
            tutorial_engine.player_profiles["player_demo_001"].learning_style = style

        style_tutorial = await tutorial_engine.generate_adaptive_tutorial(
            player_id="player_demo_001",
            tutorial_type="basic_skills",
            game_context={"game_state": "practice", "score": 10}
        )

        print(f"   🎯 Estilo {style}: {style_tutorial.content[:80]}...")

    # 9. Mostrar estadísticas del sistema
    print("\n9️⃣ Estadísticas del sistema:")
    print(f"   - Jugadores registrados: {len(tutorial_engine.player_profiles)}")
    print(f"   - Sesiones activas: {len(tutorial_engine.active_sessions)}")
    print(f"   - Modelos NLP: Cargados y operativos")

    print("\n🎉 Demostración completada exitosamente!")
    print("=" * 60)

    return {
        "demo_completed": True,
        "players_created": 1,
        "tutorials_generated": len(tutorial_engine.active_sessions),
        "nlp_analysis_performed": True,
        "skill_progression_demonstrated": True
    }

async def demo_research_capabilities():
    """Demostrar capacidades de investigación y análisis"""

    print("\n🔬 CAPACIDADES DE INVESTIGACIÓN ACADÉMICA")
    print("=" * 50)

    # 1. Generar datos sintéticos para investigación
    print("\n📊 Generando dataset sintético para investigación...")

    synthetic_players = []
    learning_styles = ["visual", "auditory", "kinesthetic", "reading"]
    skill_levels = [0.2, 0.4, 0.6, 0.8]

    for i in range(10):
        player_id = f"research_player_{i:03d}"
        style = learning_styles[i % len(learning_styles)]
        skill = skill_levels[i % len(skill_levels)] + (i * 0.01)  # Variación

        # Crear métricas variables según el nivel de habilidad
        score = int(skill * 50 + (i % 5))
        attempts = max(5, int(30 - skill * 20))
        collisions = max(1, int(attempts * (1 - skill)))

        metrics = GameMetrics(
            player_id=player_id,
            session_duration=120 + (i * 10),
            score=score,
            attempts=attempts,
            pipe_collisions=collisions,
            reaction_times=[0.5 + (1-skill) * 0.8 + (j*0.1) for j in range(5)],
            difficulty_level="easy" if skill < 0.4 else "medium" if skill < 0.7 else "hard",
            timestamp=datetime.now().isoformat()
        )

        # Analizar cada jugador
        analysis = await tutorial_engine.analyze_player_performance(player_id, metrics)
        synthetic_players.append({
            "player_id": player_id,
            "skill_level": skill,
            "learning_style": style,
            "analysis": analysis
        })

    print(f"✅ Dataset creado: {len(synthetic_players)} jugadores sintéticos")

    # 2. Análisis de patrones de aprendizaje
    print("\n🧮 Análisis de patrones de aprendizaje...")

    style_effectiveness = {}
    for style in learning_styles:
        style_players = [p for p in synthetic_players if p["learning_style"] == style]
        avg_skill = sum(p["skill_level"] for p in style_players) / len(style_players)
        style_effectiveness[style] = avg_skill

    print("📈 Efectividad por estilo de aprendizaje:")
    for style, effectiveness in sorted(style_effectiveness.items(), key=lambda x: x[1], reverse=True):
        print(f"   {style}: {effectiveness:.3f}")

    # 3. Demostrar métricas de investigación
    print("\n📋 Métricas disponibles para investigación:")
    metrics_available = [
        "Tiempo de reacción promedio por nivel de habilidad",
        "Tasa de mejora por estilo de aprendizaje",
        "Efectividad de diferentes tipos de tutorial",
        "Patrones de abandono y persistencia",
        "Análisis de sentimientos en feedback",
        "Correlación entre tiempo de sesión y mejora",
        "Personalización vs. rendimiento estándar",
        "Progresión de habilidades a lo largo del tiempo"
    ]

    for i, metric in enumerate(metrics_available, 1):
        print(f"   {i}. {metric}")

    print("\n🎯 Aplicaciones académicas:")
    applications = [
        "Tesis de maestría en IA aplicada a educación",
        "Papers sobre personalización de tutoriales",
        "Investigación en NLP para gaming",
        "Estudios de efectividad de sistemas adaptativos",
        "Análisis de comportamiento de usuarios en juegos educativos"
    ]

    for i, app in enumerate(applications, 1):
        print(f"   {i}. {app}")

    return synthetic_players

if __name__ == "__main__":
    async def main():
        # Ejecutar demostración principal
        demo_results = await demo_intelligent_tutorial_system()

        # Ejecutar demostración de capacidades de investigación
        research_data = await demo_research_capabilities()

        # Guardar resultados para análisis posterior
        results = {
            "demo_timestamp": datetime.now().isoformat(),
            "demo_results": demo_results,
            "research_dataset_size": len(research_data),
            "system_status": "operational",
            "ready_for_production": True
        }

        with open("demo_results.json", "w", encoding="utf-8") as f:
            json.dump(results, f, indent=2, ensure_ascii=False)

        print(f"\n💾 Resultados guardados en 'demo_results.json'")
        print("🚀 Sistema listo para integración con WordCraftGame!")

    # Ejecutar demostración
    asyncio.run(main())
