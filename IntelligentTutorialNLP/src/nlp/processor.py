# Simplified NLP processor without external dependencies
import re
from typing import Dict, List, Optional
import asyncio
from dataclasses import dataclass

@dataclass
class PlayerProfile:
    player_id: str
    skill_level: float
    learning_style: str
    preferred_language: str
    difficulty_areas: List[str]

class SimpleNLPProcessor:
    """Procesador simplificado de NLP para el sistema de tutorial inteligente"""

    def __init__(self):
        self.difficulty_keywords = {
            "difícil": "hard",
            "complicado": "hard",
            "fácil": "easy",
            "simple": "easy",
            "confuso": "confusing",
            "claro": "clear",
            "imposible": "impossible",
            "sencillo": "easy"
        }

        self.positive_words = [
            "excelente", "bueno", "genial", "perfecto", "mejor", "progreso",
            "mejorar", "aprender", "lograr", "conseguir", "superar"
        ]

        self.negative_words = [
            "malo", "terrible", "frustrante", "difícil", "imposible", "confuso",
            "perder", "fallar", "fracasar", "abandonar", "renunciar"
        ]

    async def initialize(self):
        """Inicializar el procesador (versión simplificada)"""
        print("Inicializando procesador NLP simplificado...")
        print("Procesador NLP listo")

    async def analyze_player_feedback(self, feedback_text: str) -> Dict:
        """Analizar feedback del jugador usando procesamiento de texto simple"""

        # Análisis de sentimiento simple
        positive_count = sum(1 for word in self.positive_words if word in feedback_text.lower())
        negative_count = sum(1 for word in self.negative_words if word in feedback_text.lower())

        if positive_count > negative_count:
            sentiment = "positive"
            sentiment_score = 0.8
        elif negative_count > positive_count:
            sentiment = "negative"
            sentiment_score = 0.2
        else:
            sentiment = "neutral"
            sentiment_score = 0.5

        # Extraer palabras clave de dificultad
        difficulty_mentions = []
        for keyword, category in self.difficulty_keywords.items():
            if keyword in feedback_text.lower():
                difficulty_mentions.append((keyword, category))

        # Análisis de complejidad del texto
        words = feedback_text.split()
        text_complexity = len(words)

        return {
            "sentiment": {
                "label": sentiment,
                "score": sentiment_score
            },
            "entities": [],  # Simplificado
            "difficulty_indicators": difficulty_mentions,
            "text_complexity": text_complexity,
            "key_topics": self._extract_key_topics_simple(feedback_text)
        }

    def _extract_key_topics_simple(self, text: str) -> List[str]:
        """Extraer temas principales del texto (versión simplificada)"""
        # Palabras clave relacionadas con el juego
        game_keywords = [
            "pájaro", "pájaro", "tubería", "puntuación", "juego", "control",
            "timing", "colisión", "vuelo", "obstáculo", "pantalla", "toque"
        ]

        found_topics = []
        text_lower = text.lower()
        for keyword in game_keywords:
            if keyword in text_lower:
                found_topics.append(keyword)

        return found_topics

    async def generate_tutorial_response(self, player_profile: PlayerProfile,
                                       game_context: Dict) -> str:
        """Generar respuesta de tutorial personalizada"""

        # Determinar el nivel de complejidad según el perfil del jugador
        complexity_level = self._determine_complexity(player_profile)

        # Generar contenido base según el contexto del juego
        tutorial_content = self._generate_contextual_content(game_context, complexity_level)

        # Personalizar según el estilo de aprendizaje
        personalized_content = self._personalize_content(
            tutorial_content,
            player_profile.learning_style
        )

        return personalized_content

    def _determine_complexity(self, profile: PlayerProfile) -> str:
        """Determinar nivel de complejidad del tutorial"""
        if profile.skill_level < 0.3:
            return "beginner"
        elif profile.skill_level < 0.7:
            return "intermediate"
        else:
            return "advanced"

    def _generate_contextual_content(self, context: Dict, complexity: str) -> str:
        """Generar contenido contextual según la situación del juego"""

        templates = {
            "beginner": {
                "high_score": "¡Excelente trabajo! Has logrado un puntaje alto. Para seguir mejorando, intenta mantener un ritmo constante.",
                "game_over": "No te preocupes, es normal fallar al principio. Intenta tocar la pantalla con un ritmo más suave.",
                "pipe_collision": "Toca la pantalla justo antes de llegar a las tuberías. Practica el timing poco a poco."
            },
            "intermediate": {
                "high_score": "Gran puntaje. Ahora puedes intentar técnicas más avanzadas como el vuelo rasante.",
                "game_over": "Analiza el patrón de las tuberías. Cada conjunto tiene un ritmo específico.",
                "pipe_collision": "Considera la física del vuelo: cada toque impulsa al pájaro hacia arriba con la misma fuerza."
            },
            "advanced": {
                "high_score": "Rendimiento excepcional. Puedes intentar desafíos como mantener el pájaro en el centro de las aberturas.",
                "game_over": "Revisa tu estrategia de anticipación. Los jugadores expertos predicen el próximo movimiento.",
                "pipe_collision": "Optimiza tu trayectoria considerando la velocidad y aceleración del pájaro."
            }
        }

        game_state = context.get("game_state", "game_over")
        return templates.get(complexity, templates["beginner"]).get(game_state, "Continúa practicando para mejorar.")

    def _personalize_content(self, content: str, learning_style: str) -> str:
        """Personalizar contenido según estilo de aprendizaje"""

        style_modifiers = {
            "visual": "💡 Observa: " + content + " Imagina la trayectoria ideal del pájaro.",
            "auditory": "🔊 Escucha: " + content + " Intenta seguir el ritmo de los sonidos del juego.",
            "kinesthetic": "✋ Práctica: " + content + " Experimenta con diferentes intensidades de toque.",
            "reading": "📚 Análisis: " + content + " Estudia los patrones y desarrolla una estrategia."
        }

        return style_modifiers.get(learning_style, content)

# Instancia global del procesador
nlp_processor = SimpleNLPProcessor()
