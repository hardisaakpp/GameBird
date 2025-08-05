from typing import Dict, List, Optional
from dataclasses import dataclass, asdict
import asyncio
from datetime import datetime
import json

from ..nlp.processor import nlp_processor, PlayerProfile
from ..ml.behavior_analyzer import behavior_analyzer, GameMetrics

@dataclass
class TutorialSession:
    """Sesión de tutoría personalizada"""
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
    """Retroalimentación adaptativa generada"""
    feedback_id: str
    player_id: str
    trigger_event: str
    message: str
    tips: List[str]
    encouragement: str
    next_steps: List[str]
    confidence_score: float

class IntelligentTutorialEngine:
    """Motor principal de tutoría inteligente"""

    def __init__(self):
        self.active_sessions = {}
        self.player_profiles = {}
        self.tutorial_templates = self._load_tutorial_templates()

    async def initialize(self):
        """Inicializar el motor de tutoría"""
        await nlp_processor.initialize()
        await behavior_analyzer.initialize_models()
        print("Motor de tutoría inteligente inicializado")

    def _load_tutorial_templates(self) -> Dict:
        """Cargar plantillas de tutoriales"""
        return {
            "onboarding": {
                "beginner": {
                    "title": "Bienvenido a WordCraft",
                    "objectives": ["Aprender controles básicos", "Comprender mecánicas del juego"],
                    "content": "En este tutorial aprenderás los fundamentos del juego paso a paso."
                },
                "intermediate": {
                    "title": "Mejora tu técnica",
                    "objectives": ["Optimizar timing", "Desarrollar estrategias"],
                    "content": "Vamos a perfeccionar tu técnica con ejercicios específicos."
                }
            },
            "skill_building": {
                "timing": "Practica el timing perfecto con estos ejercicios de precisión",
                "consistency": "Desarrolla consistencia con patrones de vuelo repetitivos",
                "advanced": "Técnicas avanzadas para jugadores experimentados"
            },
            "problem_solving": {
                "collision_frequent": "Estrategias para reducir colisiones con obstáculos",
                "score_plateau": "Técnicas para superar mesetas de puntaje",
                "reaction_slow": "Ejercicios para mejorar tiempo de reacción"
            }
        }

    async def analyze_player_performance(self, player_id: str,
                                       game_metrics: GameMetrics) -> Dict:
        """Analizar rendimiento completo del jugador"""

        # Análisis de habilidad con ML
        skill_analysis = await behavior_analyzer.analyze_skill_level(game_metrics)

        # Obtener o crear perfil del jugador
        player_profile = await self._get_or_create_player_profile(
            player_id, skill_analysis
        )

        # Generar recomendaciones
        recommendations = await behavior_analyzer.generate_improvement_recommendations(
            game_metrics, skill_analysis
        )

        return {
            "player_profile": asdict(player_profile),
            "skill_analysis": skill_analysis,
            "recommendations": recommendations,
            "tutorial_needed": self._determine_tutorial_need(skill_analysis, game_metrics)
        }

    async def _get_or_create_player_profile(self, player_id: str,
                                          skill_analysis: Dict) -> PlayerProfile:
        """Obtener o crear perfil del jugador"""

        if player_id in self.player_profiles:
            # Actualizar perfil existente
            profile = self.player_profiles[player_id]
            profile.skill_level = skill_analysis.get("efficiency", profile.skill_level)
        else:
            # Crear nuevo perfil
            profile = PlayerProfile(
                player_id=player_id,
                skill_level=skill_analysis.get("efficiency", 0.3),
                learning_style="visual",  # Default, se refinará con más datos
                preferred_language="es",
                difficulty_areas=[]
            )
            self.player_profiles[player_id] = profile

        return profile

    def _determine_tutorial_need(self, skill_analysis: Dict,
                               metrics: GameMetrics) -> str:
        """Determinar si el jugador necesita tutorial"""

        collision_rate = metrics.pipe_collisions / max(metrics.attempts, 1)
        efficiency = skill_analysis.get("efficiency", 0)

        if metrics.attempts < 5:
            return "onboarding"
        elif collision_rate > 0.7:
            return "collision_reduction"
        elif efficiency < 0.3:
            return "basic_skills"
        elif efficiency > 0.8:
            return "advanced_techniques"
        else:
            return "skill_refinement"

    async def generate_adaptive_tutorial(self, player_id: str,
                                       tutorial_type: str,
                                       game_context: Dict) -> TutorialSession:
        """Generar tutorial adaptativo personalizado"""

        player_profile = self.player_profiles.get(player_id)
        if not player_profile:
            # Crear perfil básico si no existe
            player_profile = PlayerProfile(
                player_id=player_id,
                skill_level=0.3,
                learning_style="visual",
                preferred_language="es",
                difficulty_areas=[]
            )

        # Generar contenido usando NLP
        tutorial_content = await nlp_processor.generate_tutorial_response(
            player_profile, game_context
        )

        # Determinar objetivos de aprendizaje
        learning_objectives = self._get_learning_objectives(tutorial_type, player_profile)

        # Estimar duración basada en complejidad
        estimated_duration = self._estimate_tutorial_duration(
            tutorial_type, player_profile.skill_level
        )

        session = TutorialSession(
            session_id=f"tutorial_{player_id}_{datetime.now().isoformat()}",
            player_id=player_id,
            tutorial_type=tutorial_type,
            content=tutorial_content,
            difficulty_level=self._map_skill_to_difficulty(player_profile.skill_level),
            learning_objectives=learning_objectives,
            estimated_duration=estimated_duration,
            created_at=datetime.now().isoformat()
        )

        self.active_sessions[session.session_id] = session
        return session

    def _get_learning_objectives(self, tutorial_type: str,
                               profile: PlayerProfile) -> List[str]:
        """Obtener objetivos de aprendizaje específicos"""

        objectives_map = {
            "onboarding": [
                "Comprender controles básicos del juego",
                "Aprender mecánica de vuelo del pájaro",
                "Familiarizarse con obstáculos"
            ],
            "collision_reduction": [
                "Mejorar timing de toques",
                "Desarrollar anticipación visual",
                "Reducir colisiones en 50%"
            ],
            "basic_skills": [
                "Mantener vuelo estable",
                "Lograr puntaje consistente",
                "Desarrollar confianza"
            ],
            "advanced_techniques": [
                "Dominar vuelo rasante",
                "Optimizar trayectorias",
                "Maximizar eficiencia de movimientos"
            ]
        }

        return objectives_map.get(tutorial_type, ["Mejorar habilidades generales"])

    def _estimate_tutorial_duration(self, tutorial_type: str, skill_level: float) -> int:
        """Estimar duración del tutorial en minutos"""

        base_durations = {
            "onboarding": 5,
            "collision_reduction": 8,
            "basic_skills": 10,
            "advanced_techniques": 15,
            "skill_refinement": 12
        }

        base_time = base_durations.get(tutorial_type, 10)

        # Ajustar según nivel de habilidad
        if skill_level < 0.3:
            return int(base_time * 1.5)  # Más tiempo para principiantes
        elif skill_level > 0.7:
            return int(base_time * 0.8)  # Menos tiempo para expertos
        else:
            return base_time

    def _map_skill_to_difficulty(self, skill_level: float) -> str:
        """Mapear nivel de habilidad a dificultad"""
        if skill_level < 0.3:
            return "beginner"
        elif skill_level < 0.7:
            return "intermediate"
        else:
            return "advanced"

    async def generate_real_time_feedback(self, player_id: str,
                                        trigger_event: str,
                                        game_state: Dict) -> AdaptiveFeedback:
        """Generar retroalimentación en tiempo real"""

        player_profile = self.player_profiles.get(player_id)
        if not player_profile:
            player_profile = PlayerProfile(
                player_id=player_id,
                skill_level=0.3,
                learning_style="visual",
                preferred_language="es",
                difficulty_areas=[]
            )

        # Generar mensaje principal
        main_message = await self._generate_contextual_message(
            trigger_event, game_state, player_profile
        )

        # Generar tips específicos
        tips = self._generate_contextual_tips(trigger_event, player_profile)

        # Mensaje de aliento
        encouragement = self._generate_encouragement(player_profile, game_state)

        # Próximos pasos
        next_steps = self._generate_next_steps(trigger_event, player_profile)

        feedback = AdaptiveFeedback(
            feedback_id=f"feedback_{player_id}_{datetime.now().isoformat()}",
            player_id=player_id,
            trigger_event=trigger_event,
            message=main_message,
            tips=tips,
            encouragement=encouragement,
            next_steps=next_steps,
            confidence_score=0.85  # Confianza en la retroalimentación
        )

        return feedback

    async def _generate_contextual_message(self, trigger_event: str,
                                         game_state: Dict,
                                         profile: PlayerProfile) -> str:
        """Generar mensaje contextual usando NLP"""

        context = {
            "game_state": trigger_event,
            "current_score": game_state.get("score", 0),
            "attempts": game_state.get("attempts", 0)
        }

        return await nlp_processor.generate_tutorial_response(profile, context)

    def _generate_contextual_tips(self, trigger_event: str,
                                profile: PlayerProfile) -> List[str]:
        """Generar tips contextuales"""

        tips_map = {
            "collision": [
                "Intenta tocar la pantalla justo antes de llegar al obstáculo",
                "Mantén un ritmo constante en lugar de toques desesperados",
                "Observa el patrón de altura de las tuberías"
            ],
            "high_score": [
                "¡Excelente! Mantén este ritmo",
                "Intenta no cambiar tu técnica cuando tengas una buena racha",
                "La consistencia es clave para puntajes altos"
            ],
            "game_start": [
                "Comienza con toques suaves para calibrar el control",
                "Enfócate en pasar los primeros obstáculos sin prisa",
                "Establece un ritmo cómodo desde el inicio"
            ]
        }

        base_tips = tips_map.get(trigger_event, ["Continúa practicando"])

        # Personalizar según estilo de aprendizaje
        if profile.learning_style == "visual":
            base_tips.append("Imagina la trayectoria ideal antes de actuar")
        elif profile.learning_style == "kinesthetic":
            base_tips.append("Experimenta con diferentes intensidades de toque")

        return base_tips[:3]  # Máximo 3 tips

    def _generate_encouragement(self, profile: PlayerProfile,
                              game_state: Dict) -> str:
        """Generar mensaje de aliento personalizado"""

        score = game_state.get("score", 0)

        if score > 20:
            return "¡Increíble progreso! Estás dominando el juego."
        elif score > 10:
            return "¡Muy bien! Tu técnica está mejorando notablemente."
        elif score > 5:
            return "¡Buen trabajo! Cada intento te acerca más al éxito."
        else:
            return "¡No te rindas! Cada jugador experto comenzó como tú."

    def _generate_next_steps(self, trigger_event: str,
                           profile: PlayerProfile) -> List[str]:
        """Generar próximos pasos recomendados"""

        if trigger_event == "collision":
            return [
                "Practica en modo lento si está disponible",
                "Concéntrate en pasar 3 obstáculos seguidos",
                "Observa el patrón antes de intentar nuevamente"
            ]
        elif trigger_event == "high_score":
            return [
                "Intenta superar tu récord actual",
                "Experimenta con técnicas más avanzadas",
                "Mantén la concentración por períodos más largos"
            ]
        else:
            return [
                "Continúa practicando regularmente",
                "Revisa los tutoriales disponibles",
                "Analiza tu progreso en las estadísticas"
            ]

# Instancia global del motor de tutoría
tutorial_engine = IntelligentTutorialEngine()
