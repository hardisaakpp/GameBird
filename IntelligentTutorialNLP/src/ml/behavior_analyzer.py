# Simplified behavior analyzer without sklearn dependencies
import numpy as np
from typing import Dict, List, Tuple
from dataclasses import dataclass
import asyncio
import random

@dataclass
class GameMetrics:
    """Métricas del juego para análisis"""
    player_id: str
    session_duration: float
    score: int
    attempts: int
    pipe_collisions: int
    reaction_times: List[float]
    difficulty_level: str
    timestamp: str

class SimpleBehaviorAnalyzer:
    """Analizador simplificado de comportamiento del jugador"""

    def __init__(self):
        self.is_initialized = False

    async def initialize_models(self):
        """Inicializar el analizador (versión simplificada)"""
        print("Inicializando analizador de comportamiento simplificado...")
        self.is_initialized = True
        print("Analizador de comportamiento listo")

    def extract_features(self, metrics: GameMetrics) -> List[float]:
        """Extraer características relevantes de las métricas del juego"""
        features = [
            metrics.session_duration,
            metrics.score,
            metrics.attempts,
            metrics.pipe_collisions,
            np.mean(metrics.reaction_times) if metrics.reaction_times else 0,
            np.std(metrics.reaction_times) if len(metrics.reaction_times) > 1 else 0,
            len(metrics.reaction_times),
            metrics.pipe_collisions / max(metrics.attempts, 1),  # Tasa de colisión
            metrics.score / max(metrics.session_duration, 1),     # Score por minuto
        ]
        return features

    async def analyze_skill_level(self, metrics: GameMetrics) -> Dict:
        """Analizar nivel de habilidad del jugador usando heurísticas"""
        features = self.extract_features(metrics)
        
        # Análisis heurístico basado en métricas
        efficiency = metrics.score / max(metrics.attempts, 1)
        collision_rate = metrics.pipe_collisions / max(metrics.attempts, 1)
        avg_reaction_time = np.mean(metrics.reaction_times) if metrics.reaction_times else 1.0

        # Determinar nivel de habilidad
        if efficiency > 0.8 and collision_rate < 0.2 and avg_reaction_time < 0.8:
            skill_level = "advanced"
            skill_score = 0.9
        elif efficiency > 0.5 and collision_rate < 0.5 and avg_reaction_time < 1.2:
            skill_level = "intermediate"
            skill_score = 0.6
        else:
            skill_level = "beginner"
            skill_score = 0.3

        return {
            "skill_level": skill_level,
            "skill_score": skill_score,
            "confidence": 0.85,
            "raw_score": metrics.score,
            "efficiency": efficiency,
            "consistency": 1 / (1 + (collision_rate * 10)),
            "reaction_time_avg": avg_reaction_time,
            "collision_rate": collision_rate
        }

    async def predict_optimal_difficulty(self, player_history: List[GameMetrics]) -> str:
        """Predecir dificultad óptima basada en historial"""
        if not player_history:
            return "easy"
        
        # Calcular promedio de rendimiento
        avg_score = np.mean([m.score for m in player_history])
        avg_collisions = np.mean([m.pipe_collisions for m in player_history])
        
        if avg_score > 15 and avg_collisions < 3:
            return "hard"
        elif avg_score > 8 and avg_collisions < 6:
            return "medium"
        else:
            return "easy"

    async def identify_learning_style(self, player_history: List[GameMetrics]) -> str:
        """Identificar estilo de aprendizaje del jugador"""
        if not player_history:
            return random.choice(["visual", "auditory", "kinesthetic"])
        
        # Análisis simple basado en patrones de juego
        avg_session_duration = np.mean([m.session_duration for m in player_history])
        avg_attempts = np.mean([m.attempts for m in player_history])
        
        # Jugadores que pasan más tiempo = más analíticos
        if avg_session_duration > 300:  # Más de 5 minutos
            return "reading"
        elif avg_attempts > 20:  # Muchos intentos = práctica kinestésica
            return "kinesthetic"
        else:
            return random.choice(["visual", "auditory"])

    async def generate_improvement_recommendations(self, metrics: GameMetrics,
                                                 skill_analysis: Dict) -> List[str]:
        """Generar recomendaciones de mejora"""
        recommendations = []
        
        skill_score = skill_analysis.get("skill_score", 0.3)
        collision_rate = skill_analysis.get("collision_rate", 0.5)
        efficiency = skill_analysis.get("efficiency", 0.2)
        
        if skill_score < 0.4:
            recommendations.extend([
                "Practica 10 minutos diarios para mejorar tus habilidades básicas",
                "Enfócate en pasar al menos 3 obstáculos consecutivos",
                "Usa toques suaves y constantes en lugar de toques fuertes"
            ])
        elif skill_score < 0.7:
            recommendations.extend([
                "Experimenta con diferentes estrategias de vuelo",
                "Intenta mantener el pájaro en el centro de las aberturas",
                "Practica sesiones de 15-20 minutos para mejorar la consistencia"
            ])
        else:
            recommendations.extend([
                "Perfecciona técnicas avanzadas como el vuelo rasante",
                "Intenta establecer récords de consistencia",
                "Experimenta con desafíos autoimpuestos"
            ])
        
        # Recomendaciones específicas basadas en métricas
        if collision_rate > 0.6:
            recommendations.append("Trabaja en reducir las colisiones con obstáculos")
        
        if efficiency < 0.3:
            recommendations.append("Mejora tu eficiencia practicando el timing perfecto")
        
        return recommendations

    async def analyze_learning_patterns(self, player_history: List[GameMetrics]) -> Dict:
        """Analizar patrones de aprendizaje del jugador"""
        if not player_history:
            return {"pattern": "new_player", "confidence": 0.5}
        
        # Calcular tendencias
        scores = [m.score for m in player_history]
        durations = [m.session_duration for m in player_history]
        
        # Determinar si hay mejora
        if len(scores) >= 3:
            recent_avg = np.mean(scores[-3:])
            early_avg = np.mean(scores[:3])
            improvement = recent_avg > early_avg
        else:
            improvement = False
        
        return {
            "pattern": "improving" if improvement else "plateau",
            "confidence": 0.8,
            "trend": "positive" if improvement else "stable",
            "sessions_analyzed": len(player_history)
        }

# Instancia global del analizador
behavior_analyzer = SimpleBehaviorAnalyzer()
