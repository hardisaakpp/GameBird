from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import List, Dict, Optional
from datetime import datetime

from ...tutorial.adaptive_engine import tutorial_engine, TutorialSession, AdaptiveFeedback
from ...ml.behavior_analyzer import GameMetrics

router = APIRouter()

class TutorialRequest(BaseModel):
    player_id: str
    tutorial_type: str
    game_context: Dict
    preferred_language: Optional[str] = "es"

class FeedbackRequest(BaseModel):
    player_id: str
    trigger_event: str
    game_state: Dict
    session_context: Optional[Dict] = None

class GameSessionData(BaseModel):
    player_id: str
    session_duration: float
    score: int
    attempts: int
    pipe_collisions: int
    reaction_times: List[float]
    difficulty_level: str
    timestamp: Optional[str] = None

@router.post("/generate", response_model=Dict)
async def generate_tutorial(request: TutorialRequest):
    """Generar tutorial adaptativo personalizado"""
    try:
        tutorial_session = await tutorial_engine.generate_adaptive_tutorial(
            player_id=request.player_id,
            tutorial_type=request.tutorial_type,
            game_context=request.game_context
        )

        return {
            "success": True,
            "tutorial_session": {
                "session_id": tutorial_session.session_id,
                "content": tutorial_session.content,
                "difficulty_level": tutorial_session.difficulty_level,
                "learning_objectives": tutorial_session.learning_objectives,
                "estimated_duration": tutorial_session.estimated_duration
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generando tutorial: {str(e)}")

@router.post("/feedback", response_model=Dict)
async def generate_real_time_feedback(request: FeedbackRequest):
    """Generar retroalimentación en tiempo real"""
    try:
        feedback = await tutorial_engine.generate_real_time_feedback(
            player_id=request.player_id,
            trigger_event=request.trigger_event,
            game_state=request.game_state
        )

        return {
            "success": True,
            "feedback": {
                "message": feedback.message,
                "tips": feedback.tips,
                "encouragement": feedback.encouragement,
                "next_steps": feedback.next_steps,
                "confidence_score": feedback.confidence_score
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generando feedback: {str(e)}")

@router.post("/analyze-session")
async def analyze_game_session(session_data: GameSessionData):
    """Analizar sesión de juego y proporcionar insights"""
    try:
        # Convertir datos a GameMetrics
        metrics = GameMetrics(
            player_id=session_data.player_id,
            session_duration=session_data.session_duration,
            score=session_data.score,
            attempts=session_data.attempts,
            pipe_collisions=session_data.pipe_collisions,
            reaction_times=session_data.reaction_times,
            difficulty_level=session_data.difficulty_level,
            timestamp=session_data.timestamp or datetime.now().isoformat()
        )

        # Analizar rendimiento
        analysis = await tutorial_engine.analyze_player_performance(
            session_data.player_id, metrics
        )

        return {
            "success": True,
            "analysis": analysis
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error analizando sesión: {str(e)}")

@router.get("/recommendations/{player_id}")
async def get_player_recommendations(player_id: str):
    """Obtener recomendaciones personalizadas para un jugador"""
    try:
        # Verificar si existe perfil del jugador
        if player_id not in tutorial_engine.player_profiles:
            return {
                "success": False,
                "message": "Jugador no encontrado. Juega algunas partidas para generar recomendaciones."
            }

        profile = tutorial_engine.player_profiles[player_id]

        # Generar recomendaciones generales
        recommendations = {
            "skill_level": profile.skill_level,
            "learning_style": profile.learning_style,
            "recommended_tutorials": [],
            "practice_suggestions": []
        }

        # Sugerencias basadas en nivel de habilidad
        if profile.skill_level < 0.3:
            recommendations["recommended_tutorials"] = ["onboarding", "basic_skills"]
            recommendations["practice_suggestions"] = [
                "Practica 10 minutos diarios",
                "Enfócate en pasar 3 obstáculos consecutivos",
                "Usa toques suaves y constantes"
            ]
        elif profile.skill_level < 0.7:
            recommendations["recommended_tutorials"] = ["skill_refinement", "collision_reduction"]
            recommendations["practice_suggestions"] = [
                "Experimenta con diferentes estrategias",
                "Intenta mantener el pájaro en el centro",
                "Practica sesiones de 15-20 minutos"
            ]
        else:
            recommendations["recommended_tutorials"] = ["advanced_techniques"]
            recommendations["practice_suggestions"] = [
                "Perfecciona técnicas avanzadas",
                "Intenta récords de consistencia",
                "Experimenta con desafíos autoimpuestos"
            ]

        return {
            "success": True,
            "recommendations": recommendations
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error obteniendo recomendaciones: {str(e)}")

@router.get("/active-sessions/{player_id}")
async def get_active_sessions(player_id: str):
    """Obtener sesiones activas de tutorial para un jugador"""
    try:
        active_sessions = [
            session for session in tutorial_engine.active_sessions.values()
            if session.player_id == player_id
        ]

        return {
            "success": True,
            "active_sessions": [
                {
                    "session_id": session.session_id,
                    "tutorial_type": session.tutorial_type,
                    "difficulty_level": session.difficulty_level,
                    "estimated_duration": session.estimated_duration,
                    "created_at": session.created_at
                }
                for session in active_sessions
            ]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error obteniendo sesiones: {str(e)}")

@router.delete("/session/{session_id}")
async def complete_tutorial_session(session_id: str):
    """Marcar sesión de tutorial como completada"""
    try:
        if session_id in tutorial_engine.active_sessions:
            del tutorial_engine.active_sessions[session_id]
            return {"success": True, "message": "Sesión completada exitosamente"}
        else:
            raise HTTPException(status_code=404, detail="Sesión no encontrada")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error completando sesión: {str(e)}")

@router.post("/initialize")
async def initialize_tutorial_system():
    """Inicializar sistema de tutorial (útil para reiniciar)"""
    try:
        await tutorial_engine.initialize()
        return {
            "success": True,
            "message": "Sistema de tutorial inicializado correctamente"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error inicializando sistema: {str(e)}")
