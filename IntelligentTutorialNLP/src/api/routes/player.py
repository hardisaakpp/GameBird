from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Optional
from datetime import datetime

from ...tutorial.adaptive_engine import tutorial_engine
from ...nlp.processor import PlayerProfile

router = APIRouter()

class PlayerRegistration(BaseModel):
    player_id: str
    preferred_language: Optional[str] = "es"
    learning_style: Optional[str] = "visual"
    initial_skill_level: Optional[float] = 0.3

class PlayerUpdate(BaseModel):
    learning_style: Optional[str] = None
    preferred_language: Optional[str] = None
    difficulty_areas: Optional[List[str]] = None

class PlayerFeedbackSubmission(BaseModel):
    player_id: str
    feedback_text: str
    rating: Optional[int] = None
    category: Optional[str] = None

@router.post("/register")
async def register_player(registration: PlayerRegistration):
    """Registrar nuevo jugador en el sistema"""
    try:
        # Crear perfil del jugador
        player_profile = PlayerProfile(
            player_id=registration.player_id,
            skill_level=registration.initial_skill_level,
            learning_style=registration.learning_style,
            preferred_language=registration.preferred_language,
            difficulty_areas=[]
        )

        # Guardar en el sistema
        tutorial_engine.player_profiles[registration.player_id] = player_profile

        return {
            "success": True,
            "message": f"Jugador {registration.player_id} registrado exitosamente",
            "profile": {
                "player_id": player_profile.player_id,
                "skill_level": player_profile.skill_level,
                "learning_style": player_profile.learning_style,
                "preferred_language": player_profile.preferred_language
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error registrando jugador: {str(e)}")

@router.get("/{player_id}/profile")
async def get_player_profile(player_id: str):
    """Obtener perfil completo del jugador"""
    try:
        if player_id not in tutorial_engine.player_profiles:
            raise HTTPException(status_code=404, detail="Jugador no encontrado")

        profile = tutorial_engine.player_profiles[player_id]

        return {
            "success": True,
            "profile": {
                "player_id": profile.player_id,
                "skill_level": profile.skill_level,
                "learning_style": profile.learning_style,
                "preferred_language": profile.preferred_language,
                "difficulty_areas": profile.difficulty_areas
            }
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error obteniendo perfil: {str(e)}")

@router.put("/{player_id}/profile")
async def update_player_profile(player_id: str, update: PlayerUpdate):
    """Actualizar perfil del jugador"""
    try:
        if player_id not in tutorial_engine.player_profiles:
            raise HTTPException(status_code=404, detail="Jugador no encontrado")

        profile = tutorial_engine.player_profiles[player_id]

        # Actualizar campos proporcionados
        if update.learning_style:
            profile.learning_style = update.learning_style
        if update.preferred_language:
            profile.preferred_language = update.preferred_language
        if update.difficulty_areas is not None:
            profile.difficulty_areas = update.difficulty_areas

        return {
            "success": True,
            "message": "Perfil actualizado exitosamente",
            "updated_profile": {
                "player_id": profile.player_id,
                "skill_level": profile.skill_level,
                "learning_style": profile.learning_style,
                "preferred_language": profile.preferred_language,
                "difficulty_areas": profile.difficulty_areas
            }
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error actualizando perfil: {str(e)}")

@router.post("/{player_id}/feedback")
async def submit_player_feedback(player_id: str, feedback: PlayerFeedbackSubmission):
    """Procesar feedback del jugador usando NLP"""
    try:
        from ...nlp.processor import nlp_processor

        # Analizar feedback con NLP
        analysis = await nlp_processor.analyze_player_feedback(feedback.feedback_text)

        # Extraer insights del análisis
        sentiment = analysis.get("sentiment", {})
        difficulty_indicators = analysis.get("difficulty_indicators", [])
        key_topics = analysis.get("key_topics", [])

        # Actualizar perfil basado en el feedback
        if player_id in tutorial_engine.player_profiles:
            profile = tutorial_engine.player_profiles[player_id]

            # Agregar nuevas áreas de dificultad si se mencionan
            for indicator in difficulty_indicators:
                if indicator not in profile.difficulty_areas:
                    profile.difficulty_areas.append(indicator)

        return {
            "success": True,
            "message": "Feedback procesado exitosamente",
            "analysis": {
                "sentiment_score": sentiment.get("score", 0) if sentiment else 0,
                "sentiment_label": sentiment.get("label", "neutral") if sentiment else "neutral",
                "difficulty_mentions": difficulty_indicators,
                "key_topics": key_topics,
                "feedback_category": feedback.category or "general"
            },
            "ai_response": "Gracias por tu feedback. Hemos actualizado tu perfil para mejorar tu experiencia de tutoría."
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error procesando feedback: {str(e)}")

@router.get("/{player_id}/learning-progress")
async def get_learning_progress(player_id: str):
    """Obtener progreso de aprendizaje del jugador"""
    try:
        if player_id not in tutorial_engine.player_profiles:
            raise HTTPException(status_code=404, detail="Jugador no encontrado")

        profile = tutorial_engine.player_profiles[player_id]

        # Calcular métricas de progreso
        progress_metrics = {
            "current_skill_level": profile.skill_level,
            "skill_category": "Principiante" if profile.skill_level < 0.3 else
                            "Intermedio" if profile.skill_level < 0.7 else "Avanzado",
            "learning_style": profile.learning_style,
            "difficulty_areas": profile.difficulty_areas,
            "completed_tutorials": len([
                session for session in tutorial_engine.active_sessions.values()
                if session.player_id == player_id
            ]),
            "recommendations": {
                "next_tutorial": "basic_skills" if profile.skill_level < 0.3 else
                               "skill_refinement" if profile.skill_level < 0.7 else
                               "advanced_techniques",
                "focus_areas": profile.difficulty_areas[-3:] if profile.difficulty_areas else ["timing", "consistency"]
            }
        }

        return {
            "success": True,
            "progress": progress_metrics
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error obteniendo progreso: {str(e)}")

@router.delete("/{player_id}")
async def delete_player(player_id: str):
    """Eliminar jugador del sistema"""
    try:
        if player_id not in tutorial_engine.player_profiles:
            raise HTTPException(status_code=404, detail="Jugador no encontrado")

        # Eliminar perfil
        del tutorial_engine.player_profiles[player_id]

        # Eliminar sesiones activas
        sessions_to_remove = [
            session_id for session_id, session in tutorial_engine.active_sessions.items()
            if session.player_id == player_id
        ]

        for session_id in sessions_to_remove:
            del tutorial_engine.active_sessions[session_id]

        return {
            "success": True,
            "message": f"Jugador {player_id} eliminado exitosamente"
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error eliminando jugador: {str(e)}")

@router.get("/")
async def list_all_players():
    """Listar todos los jugadores registrados (para admin)"""
    try:
        players = []
        for player_id, profile in tutorial_engine.player_profiles.items():
            players.append({
                "player_id": profile.player_id,
                "skill_level": profile.skill_level,
                "learning_style": profile.learning_style,
                "preferred_language": profile.preferred_language,
                "difficulty_areas_count": len(profile.difficulty_areas)
            })

        return {
            "success": True,
            "total_players": len(players),
            "players": players
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error listando jugadores: {str(e)}")
