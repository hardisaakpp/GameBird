#!/usr/bin/env python3
"""
API REST simplificada del Sistema de Tutorial Inteligente
Versión sin dependencias de NLP para pruebas rápidas
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Dict, List, Optional
import uvicorn
import asyncio
from datetime import datetime
import json

# Importar el motor simplificado
from simple_demo import SimpleTutorialEngine, GameMetrics

# Crear instancia del motor
tutorial_engine = SimpleTutorialEngine()

# Crear aplicación FastAPI
app = FastAPI(
    title="Sistema de Tutorial Inteligente (Simplificado)",
    description="API REST para tutoriales adaptativos sin dependencias de NLP",
    version="1.0.0"
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Modelos Pydantic para la API
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

# Endpoints de la API
@app.get("/")
async def root():
    """Endpoint raíz"""
    return {
        "message": "Sistema de Tutorial Inteligente API (Simplificado)",
        "status": "active",
        "version": "1.0.0",
        "endpoints": [
            "/api/v1/tutorial/generate",
            "/api/v1/tutorial/feedback", 
            "/api/v1/tutorial/analyze-session",
            "/api/v1/tutorial/recommendations/{player_id}",
            "/health"
        ]
    }

@app.get("/health")
async def health_check():
    """Verificar estado del sistema"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "players_registered": len(tutorial_engine.player_profiles),
        "active_sessions": len(tutorial_engine.active_sessions)
    }

@app.post("/api/v1/tutorial/generate")
async def generate_tutorial(request: TutorialRequest):
    """Generar tutorial adaptativo personalizado"""
    try:
        # Crear métricas básicas si no existen
        game_metrics = GameMetrics(
            player_id=request.player_id,
            session_duration=120.0,
            score=5,
            attempts=10,
            pipe_collisions=5,
            reaction_times=[1.0, 1.1, 0.9, 1.2, 1.0],
            difficulty_level="easy",
            timestamp=datetime.now().isoformat()
        )
        
        # Analizar rendimiento primero
        analysis = await tutorial_engine.analyze_player_performance(
            request.player_id, game_metrics
        )
        
        # Generar tutorial
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
                "estimated_duration": tutorial_session.estimated_duration,
                "player_analysis": analysis
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generando tutorial: {str(e)}")

@app.post("/api/v1/tutorial/feedback")
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
                "feedback_id": feedback.feedback_id,
                "message": feedback.message,
                "tips": feedback.tips,
                "encouragement": feedback.encouragement,
                "next_steps": feedback.next_steps,
                "confidence_score": feedback.confidence_score
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generando feedback: {str(e)}")

@app.post("/api/v1/tutorial/analyze-session")
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

@app.get("/api/v1/tutorial/recommendations/{player_id}")
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

@app.get("/api/v1/players")
async def get_all_players():
    """Obtener lista de todos los jugadores registrados"""
    try:
        players = []
        for player_id, profile in tutorial_engine.player_profiles.items():
            players.append({
                "player_id": player_id,
                "skill_level": profile.skill_level,
                "learning_style": profile.learning_style,
                "preferred_language": profile.preferred_language
            })
        
        return {
            "success": True,
            "players": players,
            "total_players": len(players)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error obteniendo jugadores: {str(e)}")

@app.get("/api/v1/sessions")
async def get_active_sessions():
    """Obtener todas las sesiones activas"""
    try:
        sessions = []
        for session_id, session in tutorial_engine.active_sessions.items():
            sessions.append({
                "session_id": session_id,
                "player_id": session.player_id,
                "tutorial_type": session.tutorial_type,
                "difficulty_level": session.difficulty_level,
                "estimated_duration": session.estimated_duration,
                "created_at": session.created_at
            })
        
        return {
            "success": True,
            "sessions": sessions,
            "total_sessions": len(sessions)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error obteniendo sesiones: {str(e)}")

if __name__ == "__main__":
    print("🚀 Iniciando API del Sistema de Tutorial Inteligente...")
    print("📖 Documentación disponible en: http://localhost:8000/docs")
    print("🔗 Endpoints disponibles:")
    print("   - GET  / - Información del sistema")
    print("   - GET  /health - Estado del sistema")
    print("   - POST /api/v1/tutorial/generate - Generar tutorial")
    print("   - POST /api/v1/tutorial/feedback - Generar feedback")
    print("   - POST /api/v1/tutorial/analyze-session - Analizar sesión")
    print("   - GET  /api/v1/tutorial/recommendations/{player_id} - Recomendaciones")
    print("   - GET  /api/v1/players - Lista de jugadores")
    print("   - GET  /api/v1/sessions - Sesiones activas")
    
    uvicorn.run(app, host="0.0.0.0", port=8000) 