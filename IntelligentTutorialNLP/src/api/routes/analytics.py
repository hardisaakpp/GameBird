from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Optional
from datetime import datetime, timedelta
import numpy as np
from collections import defaultdict

from ...tutorial.adaptive_engine import tutorial_engine
from ...ml.behavior_analyzer import behavior_analyzer

router = APIRouter()

class AnalyticsRequest(BaseModel):
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    player_ids: Optional[List[str]] = None

@router.get("/system-overview")
async def get_system_overview():
    """Obtener overview general del sistema de tutoría"""
    try:
        total_players = len(tutorial_engine.player_profiles)
        active_sessions = len(tutorial_engine.active_sessions)

        # Calcular distribución de niveles de habilidad
        skill_distribution = {"beginner": 0, "intermediate": 0, "advanced": 0}
        learning_style_distribution = defaultdict(int)

        for profile in tutorial_engine.player_profiles.values():
            # Clasificar nivel de habilidad
            if profile.skill_level < 0.3:
                skill_distribution["beginner"] += 1
            elif profile.skill_level < 0.7:
                skill_distribution["intermediate"] += 1
            else:
                skill_distribution["advanced"] += 1

            # Contar estilos de aprendizaje
            learning_style_distribution[profile.learning_style] += 1

        return {
            "success": True,
            "overview": {
                "total_registered_players": total_players,
                "active_tutorial_sessions": active_sessions,
                "skill_level_distribution": skill_distribution,
                "learning_style_distribution": dict(learning_style_distribution),
                "system_status": "operational",
                "last_updated": datetime.now().isoformat()
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generando overview: {str(e)}")

@router.get("/player-analytics/{player_id}")
async def get_player_analytics(player_id: str):
    """Obtener analíticas detalladas de un jugador específico"""
    try:
        if player_id not in tutorial_engine.player_profiles:
            raise HTTPException(status_code=404, detail="Jugador no encontrado")

        profile = tutorial_engine.player_profiles[player_id]

        # Calcular estadísticas del jugador
        player_sessions = [
            session for session in tutorial_engine.active_sessions.values()
            if session.player_id == player_id
        ]

        analytics = {
            "player_profile": {
                "skill_level": profile.skill_level,
                "skill_category": "Principiante" if profile.skill_level < 0.3 else
                                "Intermedio" if profile.skill_level < 0.7 else "Avanzado",
                "learning_style": profile.learning_style,
                "preferred_language": profile.preferred_language,
                "difficulty_areas": profile.difficulty_areas
            },
            "tutorial_activity": {
                "total_sessions_created": len(player_sessions),
                "tutorial_types_accessed": list(set(session.tutorial_type for session in player_sessions)),
                "average_session_duration": np.mean([session.estimated_duration for session in player_sessions]) if player_sessions else 0
            },
            "learning_insights": {
                "improvement_areas": profile.difficulty_areas[-5:] if profile.difficulty_areas else [],
                "recommended_focus": "timing" if profile.skill_level < 0.3 else
                                   "consistency" if profile.skill_level < 0.7 else "advanced_techniques",
                "personalization_confidence": min(len(player_sessions) * 0.2, 1.0)  # Aumenta con más datos
            }
        }

        return {
            "success": True,
            "analytics": analytics
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generando analíticas: {str(e)}")

@router.get("/tutorial-effectiveness")
async def get_tutorial_effectiveness():
    """Analizar efectividad de diferentes tipos de tutorial"""
    try:
        tutorial_stats = defaultdict(lambda: {"count": 0, "avg_duration": 0, "completion_rate": 0})

        for session in tutorial_engine.active_sessions.values():
            tutorial_type = session.tutorial_type
            tutorial_stats[tutorial_type]["count"] += 1
            tutorial_stats[tutorial_type]["avg_duration"] += session.estimated_duration

        # Calcular promedios
        for stats in tutorial_stats.values():
            if stats["count"] > 0:
                stats["avg_duration"] /= stats["count"]
                stats["completion_rate"] = 0.85  # Placeholder - en producción calcular real

        effectiveness_analysis = {
            "tutorial_types": dict(tutorial_stats),
            "most_popular": max(tutorial_stats.keys(), key=lambda k: tutorial_stats[k]["count"]) if tutorial_stats else None,
            "insights": {
                "onboarding_usage": tutorial_stats.get("onboarding", {}).get("count", 0),
                "advanced_engagement": tutorial_stats.get("advanced_techniques", {}).get("count", 0),
                "problem_solving_requests": sum(
                    stats["count"] for tutorial_type, stats in tutorial_stats.items()
                    if "collision" in tutorial_type or "skills" in tutorial_type
                )
            }
        }

        return {
            "success": True,
            "effectiveness": effectiveness_analysis
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error analizando efectividad: {str(e)}")

@router.get("/learning-patterns")
async def analyze_learning_patterns():
    """Analizar patrones de aprendizaje en la base de usuarios"""
    try:
        patterns = {
            "skill_progression": defaultdict(list),
            "learning_style_effectiveness": defaultdict(lambda: {"players": 0, "avg_skill": 0}),
            "common_difficulty_areas": defaultdict(int),
            "tutorial_sequences": defaultdict(int)
        }

        for profile in tutorial_engine.player_profiles.values():
            # Analizar progresión de habilidades
            skill_category = "beginner" if profile.skill_level < 0.3 else \
                           "intermediate" if profile.skill_level < 0.7 else "advanced"
            patterns["skill_progression"][skill_category].append(profile.skill_level)

            # Efectividad por estilo de aprendizaje
            style_stats = patterns["learning_style_effectiveness"][profile.learning_style]
            style_stats["players"] += 1
            style_stats["avg_skill"] += profile.skill_level

            # Áreas de dificultad comunes
            for area in profile.difficulty_areas:
                patterns["common_difficulty_areas"][area] += 1

        # Calcular promedios
        for style_stats in patterns["learning_style_effectiveness"].values():
            if style_stats["players"] > 0:
                style_stats["avg_skill"] /= style_stats["players"]

        insights = {
            "total_learners": len(tutorial_engine.player_profiles),
            "skill_distribution": {
                category: {
                    "count": len(skills),
                    "avg_skill": np.mean(skills) if skills else 0,
                    "skill_range": [min(skills), max(skills)] if skills else [0, 0]
                }
                for category, skills in patterns["skill_progression"].items()
            },
            "learning_style_insights": dict(patterns["learning_style_effectiveness"]),
            "top_difficulty_areas": dict(sorted(
                patterns["common_difficulty_areas"].items(),
                key=lambda x: x[1], reverse=True
            )[:5]),
            "recommendations": {
                "focus_on_beginners": patterns["skill_progression"]["beginner"] and
                                     len(patterns["skill_progression"]["beginner"]) > len(patterns["skill_progression"]["advanced"]),
                "personalization_priority": max(patterns["learning_style_effectiveness"].keys(),
                                               key=lambda k: patterns["learning_style_effectiveness"][k]["players"])
                                           if patterns["learning_style_effectiveness"] else "visual"
            }
        }

        return {
            "success": True,
            "patterns": insights
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error analizando patrones: {str(e)}")

@router.get("/nlp-insights")
async def get_nlp_processing_insights():
    """Obtener insights sobre el procesamiento de NLP"""
    try:
        from ...nlp.processor import nlp_processor

        # Simular estadísticas de NLP (en producción, estas se recopilarían en tiempo real)
        nlp_stats = {
            "language_processing": {
                "primary_language": "es",
                "supported_languages": ["es", "en"],
                "text_complexity_avg": 2.5,  # Escala 1-5
                "sentiment_analysis_accuracy": 0.87
            },
            "content_generation": {
                "tutorials_generated": len(tutorial_engine.active_sessions),
                "personalization_success_rate": 0.92,
                "response_time_avg_ms": 250,
                "content_relevance_score": 0.89
            },
            "adaptive_features": {
                "learning_style_detection_accuracy": 0.78,
                "difficulty_prediction_accuracy": 0.84,
                "recommendation_effectiveness": 0.81
            },
            "model_performance": {
                "nlp_model_status": "operational",
                "last_model_update": "2024-01-15",
                "processing_capacity": "high",
                "error_rate": 0.03
            }
        }

        return {
            "success": True,
            "nlp_insights": nlp_stats
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error obteniendo insights de NLP: {str(e)}")

@router.post("/export-data")
async def export_analytics_data(request: AnalyticsRequest):
    """Exportar datos de analíticas para investigación"""
    try:
        # Filtrar datos según criterios
        filtered_profiles = tutorial_engine.player_profiles

        if request.player_ids:
            filtered_profiles = {
                pid: profile for pid, profile in filtered_profiles.items()
                if pid in request.player_ids
            }

        export_data = {
            "metadata": {
                "export_date": datetime.now().isoformat(),
                "total_records": len(filtered_profiles),
                "data_version": "1.0"
            },
            "player_profiles": [
                {
                    "player_id": profile.player_id,
                    "skill_level": profile.skill_level,
                    "learning_style": profile.learning_style,
                    "preferred_language": profile.preferred_language,
                    "difficulty_areas_count": len(profile.difficulty_areas)
                }
                for profile in filtered_profiles.values()
            ],
            "tutorial_sessions": [
                {
                    "session_id": session.session_id,
                    "player_id": session.player_id,
                    "tutorial_type": session.tutorial_type,
                    "difficulty_level": session.difficulty_level,
                    "estimated_duration": session.estimated_duration,
                    "created_at": session.created_at
                }
                for session in tutorial_engine.active_sessions.values()
                if not request.player_ids or session.player_id in request.player_ids
            ]
        }

        return {
            "success": True,
            "export_data": export_data,
            "download_info": {
                "format": "json",
                "size_kb": len(str(export_data)) / 1024,
                "suitable_for_research": True
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error exportando datos: {str(e)}")
