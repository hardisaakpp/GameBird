#!/usr/bin/env python3
"""
Script de demostración simplificado del Sistema de Tutorial Inteligente
Versión sin dependencias de NLP para pruebas rápidas
"""

import asyncio
import json
from datetime import datetime
from typing import Dict, List, Optional
from dataclasses import dataclass
import random

# Simular las clases que necesitamos
@dataclass
class GameMetrics:
    player_id: str
    session_duration: float
    score: int
    attempts: int
    pipe_collisions: int
    reaction_times: List[float]
    difficulty_level: str
    timestamp: str

@dataclass
class PlayerProfile:
    player_id: str
    skill_level: float
    learning_style: str
    preferred_language: str
    difficulty_areas: List[str]

@dataclass
class TutorialSession:
    session_id: str
    player_id: str
    tutorial_type: str
    content: str
    difficulty_level: str
    learning_objectives: List[str]
    estimated_duration: int
    created_at: str

@dataclass
class AdaptiveFeedback:
    feedback_id: str
    player_id: str
    trigger_event: str
    message: str
    tips: List[str]
    encouragement: str
    next_steps: List[str]
    confidence_score: float

class SimpleTutorialEngine:
    """Motor simplificado de tutorial inteligente"""
    
    def __init__(self):
        self.active_sessions = {}
        self.player_profiles = {}
        self.tutorial_templates = self._load_tutorial_templates()
    
    def _load_tutorial_templates(self) -> Dict:
        """Cargar plantillas de tutoriales"""
        return {
            "onboarding": {
                "beginner": {
                    "title": "Bienvenido a WordCraft",
                    "objectives": ["Aprender controles básicos", "Comprender mecánicas del juego"],
                    "content": "En este tutorial aprenderás los fundamentos del juego paso a paso. Usa toques suaves para controlar el pájaro y evita los obstáculos."
                },
                "intermediate": {
                    "title": "Mejora tu técnica",
                    "objectives": ["Optimizar timing", "Desarrollar estrategias"],
                    "content": "Vamos a perfeccionar tu técnica con ejercicios específicos. Enfócate en el timing y la consistencia."
                }
            },
            "skill_building": {
                "timing": "Practica el timing perfecto con estos ejercicios de precisión. El secreto está en la anticipación.",
                "consistency": "Desarrolla consistencia con patrones de vuelo repetitivos. La práctica hace al maestro.",
                "advanced": "Técnicas avanzadas para jugadores experimentados. Domina las mecánicas complejas."
            },
            "problem_solving": {
                "collision_frequent": "Estrategias para reducir colisiones con obstáculos. Mantén el pájaro en el centro.",
                "score_plateau": "Técnicas para superar mesetas de puntaje. Varía tu estrategia.",
                "reaction_slow": "Ejercicios para mejorar tiempo de reacción. Practica con obstáculos más rápidos."
            }
        }
    
    async def analyze_player_performance(self, player_id: str, game_metrics: GameMetrics) -> Dict:
        """Analizar rendimiento del jugador (versión simplificada)"""
        
        # Calcular nivel de habilidad basado en métricas
        efficiency = game_metrics.score / max(game_metrics.attempts, 1)
        collision_rate = game_metrics.pipe_collisions / max(game_metrics.attempts, 1)
        
        if efficiency > 0.8 and collision_rate < 0.2:
            skill_level = "advanced"
            skill_score = 0.9
        elif efficiency > 0.5 and collision_rate < 0.5:
            skill_level = "intermediate"
            skill_score = 0.6
        else:
            skill_level = "beginner"
            skill_score = 0.3
        
        # Crear o actualizar perfil del jugador
        if player_id not in self.player_profiles:
            self.player_profiles[player_id] = PlayerProfile(
                player_id=player_id,
                skill_level=skill_score,
                learning_style=random.choice(["visual", "auditory", "kinesthetic"]),
                preferred_language="es",
                difficulty_areas=[]
            )
        
        # Determinar tutorial necesario
        if skill_score < 0.4:
            tutorial_needed = "onboarding"
        elif skill_score < 0.7:
            tutorial_needed = "skill_building"
        else:
            tutorial_needed = "problem_solving"
        
        return {
            "player_profile": {
                "player_id": player_id,
                "skill_level": skill_score,
                "learning_style": self.player_profiles[player_id].learning_style,
                "preferred_language": "es",
                "difficulty_areas": []
            },
            "skill_analysis": {
                "skill_level": skill_level,
                "confidence": 0.85,
                "raw_score": game_metrics.score,
                "efficiency": efficiency,
                "consistency": 1 / (1 + (collision_rate * 10))
            },
            "recommendations": [
                f"Practica {max(10, int(30 - skill_score * 20))} minutos diarios",
                "Enfócate en reducir colisiones" if collision_rate > 0.3 else "Mantén tu consistencia",
                "Experimenta con diferentes estrategias" if skill_score > 0.6 else "Domina los fundamentos"
            ],
            "tutorial_needed": tutorial_needed
        }
    
    async def generate_adaptive_tutorial(self, player_id: str, tutorial_type: str, game_context: Dict) -> TutorialSession:
        """Generar tutorial adaptativo"""
        
        profile = self.player_profiles.get(player_id)
        if not profile:
            profile = PlayerProfile(player_id, 0.3, "visual", "es", [])
        
        # Determinar nivel de dificultad
        if profile.skill_level < 0.4:
            difficulty = "beginner"
        elif profile.skill_level < 0.7:
            difficulty = "intermediate"
        else:
            difficulty = "advanced"
        
        # Obtener contenido del tutorial
        if tutorial_type in self.tutorial_templates:
            if isinstance(self.tutorial_templates[tutorial_type], dict):
                content = self.tutorial_templates[tutorial_type].get(difficulty, {}).get("content", "Tutorial personalizado")
            else:
                content = str(self.tutorial_templates[tutorial_type])
        else:
            content = "Tutorial personalizado para mejorar tus habilidades"
        
        # Personalizar según estilo de aprendizaje
        if profile.learning_style == "visual":
            content += " [Incluye elementos visuales y diagramas]"
        elif profile.learning_style == "auditory":
            content += " [Incluye explicaciones verbales detalladas]"
        else:  # kinesthetic
            content += " [Incluye ejercicios prácticos interactivos]"
        
        session = TutorialSession(
            session_id=f"session_{player_id}_{datetime.now().timestamp()}",
            player_id=player_id,
            tutorial_type=tutorial_type,
            content=content,
            difficulty_level=difficulty,
            learning_objectives=["Mejorar habilidades", "Reducir errores", "Aumentar puntaje"],
            estimated_duration=max(5, int(15 - profile.skill_level * 10)),
            created_at=datetime.now().isoformat()
        )
        
        self.active_sessions[session.session_id] = session
        return session
    
    async def generate_real_time_feedback(self, player_id: str, trigger_event: str, game_state: Dict) -> AdaptiveFeedback:
        """Generar retroalimentación en tiempo real"""
        
        profile = self.player_profiles.get(player_id)
        if not profile:
            profile = PlayerProfile(player_id, 0.3, "visual", "es", [])
        
        # Generar mensajes según el evento
        if trigger_event == "collision":
            message = "¡No te preocupes! Las colisiones son parte del aprendizaje."
            tips = ["Mantén el pájaro en el centro", "Usa toques más suaves", "Anticipa los obstáculos"]
        elif trigger_event == "score_milestone":
            message = "¡Excelente progreso! Sigues mejorando."
            tips = ["Mantén la consistencia", "Intenta nuevos desafíos", "Practica técnicas avanzadas"]
        else:
            message = "¡Sigue así! Cada intento te hace mejor."
            tips = ["Practica regularmente", "Analiza tus errores", "Celebra tus logros"]
        
        # Personalizar según el perfil
        if profile.skill_level < 0.4:
            encouragement = "Eres principiante, es normal cometer errores. ¡Sigue practicando!"
        elif profile.skill_level < 0.7:
            encouragement = "Ya tienes buenas bases. ¡Ahora es momento de perfeccionar!"
        else:
            encouragement = "¡Eres un experto! Ayuda a otros a mejorar."
        
        return AdaptiveFeedback(
            feedback_id=f"feedback_{player_id}_{datetime.now().timestamp()}",
            player_id=player_id,
            trigger_event=trigger_event,
            message=message,
            tips=tips,
            encouragement=encouragement,
            next_steps=["Practica 10 minutos", "Analiza tu técnica", "Establece metas"],
            confidence_score=0.8
        )

# Instancia global del motor
tutorial_engine = SimpleTutorialEngine()

async def demo_simple_tutorial_system():
    """Demostración del sistema simplificado"""
    
    print("🚀 DEMOSTRACIÓN: Sistema de Tutorial Inteligente (Versión Simplificada)")
    print("=" * 70)
    
    # 1. Simular jugador principiante
    print("\n1️⃣ Simulando jugador principiante: 'player_001'")
    
    beginner_metrics = GameMetrics(
        player_id="player_001",
        session_duration=180.0,
        score=3,
        attempts=20,
        pipe_collisions=15,
        reaction_times=[1.2, 1.5, 1.1, 1.3, 1.4],
        difficulty_level="easy",
        timestamp=datetime.now().isoformat()
    )
    
    # 2. Analizar rendimiento
    print("\n2️⃣ Analizando rendimiento del jugador...")
    analysis = await tutorial_engine.analyze_player_performance("player_001", beginner_metrics)
    
    print(f"📊 Análisis de habilidad:")
    print(f"   - Nivel: {analysis['skill_analysis']['skill_level']}")
    print(f"   - Eficiencia: {analysis['skill_analysis']['efficiency']:.2f}")
    print(f"   - Consistencia: {analysis['skill_analysis']['consistency']:.2f}")
    print(f"   - Tutorial recomendado: {analysis['tutorial_needed']}")
    
    # 3. Generar tutorial
    print("\n3️⃣ Generando tutorial adaptativo...")
    tutorial = await tutorial_engine.generate_adaptive_tutorial(
        "player_001", 
        analysis['tutorial_needed'],
        {"game_state": "game_over", "score": 3}
    )
    
    print(f"📚 Tutorial generado:")
    print(f"   - Tipo: {tutorial.tutorial_type}")
    print(f"   - Nivel: {tutorial.difficulty_level}")
    print(f"   - Duración: {tutorial.estimated_duration} minutos")
    print(f"   - Contenido: {tutorial.content}")
    
    # 4. Generar feedback
    print("\n4️⃣ Generando retroalimentación en tiempo real...")
    feedback = await tutorial_engine.generate_real_time_feedback(
        "player_001",
        "collision",
        {"score": 3, "attempts": 15}
    )
    
    print(f"💬 Retroalimentación:")
    print(f"   - Mensaje: {feedback.message}")
    print(f"   - Tips: {', '.join(feedback.tips[:2])}")
    print(f"   - Aliento: {feedback.encouragement}")
    
    # 5. Simular progresión
    print("\n5️⃣ Simulando progresión del jugador...")
    
    improved_metrics = GameMetrics(
        player_id="player_001",
        session_duration=240.0,
        score=12,
        attempts=15,
        pipe_collisions=6,
        reaction_times=[0.8, 0.9, 0.7, 0.8, 0.9],
        difficulty_level="medium",
        timestamp=datetime.now().isoformat()
    )
    
    improved_analysis = await tutorial_engine.analyze_player_performance("player_001", improved_metrics)
    
    print(f"📈 Progreso después del tutorial:")
    print(f"   - Nuevo nivel: {improved_analysis['skill_analysis']['skill_level']}")
    print(f"   - Mejora en eficiencia: {improved_analysis['skill_analysis']['efficiency']:.2f}")
    print(f"   - Nuevo tutorial: {improved_analysis['tutorial_needed']}")
    
    # 6. Mostrar estadísticas
    print("\n6️⃣ Estadísticas del sistema:")
    print(f"   - Jugadores registrados: {len(tutorial_engine.player_profiles)}")
    print(f"   - Sesiones activas: {len(tutorial_engine.active_sessions)}")
    print(f"   - Tutoriales disponibles: {len(tutorial_engine.tutorial_templates)}")
    
    print("\n🎉 Demostración completada exitosamente!")
    print("=" * 70)
    
    return {
        "demo_completed": True,
        "players_created": len(tutorial_engine.player_profiles),
        "tutorials_generated": len(tutorial_engine.active_sessions),
        "system_status": "operational"
    }

if __name__ == "__main__":
    # Ejecutar demostración
    results = asyncio.run(demo_simple_tutorial_system())
    
    # Guardar resultados
    with open("simple_demo_results.json", "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    print(f"\n💾 Resultados guardados en 'simple_demo_results.json'")
    print("🚀 Sistema listo para integración con WordCraftGame!") 