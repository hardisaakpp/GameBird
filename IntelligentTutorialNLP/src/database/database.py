from sqlalchemy import create_engine, Column, Integer, String, Float, Text, DateTime, JSON
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime
import os

# Configuración de base de datos
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./intelligent_tutorial.db")

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False} if "sqlite" in DATABASE_URL else {})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

class PlayerProfile(Base):
    """Modelo de perfil de jugador en base de datos"""
    __tablename__ = "player_profiles"

    id = Column(Integer, primary_key=True, index=True)
    player_id = Column(String, unique=True, index=True)
    skill_level = Column(Float, default=0.3)
    learning_style = Column(String, default="visual")
    preferred_language = Column(String, default="es")
    difficulty_areas = Column(JSON, default=list)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class TutorialSession(Base):
    """Modelo de sesión de tutorial"""
    __tablename__ = "tutorial_sessions"

    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(String, unique=True, index=True)
    player_id = Column(String, index=True)
    tutorial_type = Column(String)
    content = Column(Text)
    difficulty_level = Column(String)
    learning_objectives = Column(JSON, default=list)
    estimated_duration = Column(Integer)
    completed = Column(Integer, default=0)  # 0=active, 1=completed, 2=abandoned
    created_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime, nullable=True)

class GameSession(Base):
    """Modelo de sesión de juego"""
    __tablename__ = "game_sessions"

    id = Column(Integer, primary_key=True, index=True)
    player_id = Column(String, index=True)
    session_duration = Column(Float)
    score = Column(Integer)
    attempts = Column(Integer)
    pipe_collisions = Column(Integer)
    reaction_times = Column(JSON, default=list)
    difficulty_level = Column(String)
    timestamp = Column(DateTime, default=datetime.utcnow)

class PlayerFeedback(Base):
    """Modelo de feedback de jugador"""
    __tablename__ = "player_feedback"

    id = Column(Integer, primary_key=True, index=True)
    player_id = Column(String, index=True)
    feedback_text = Column(Text)
    sentiment_score = Column(Float, nullable=True)
    sentiment_label = Column(String, nullable=True)
    difficulty_indicators = Column(JSON, default=list)
    key_topics = Column(JSON, default=list)
    rating = Column(Integer, nullable=True)
    category = Column(String, nullable=True)
    processed = Column(Integer, default=0)  # 0=pending, 1=processed
    created_at = Column(DateTime, default=datetime.utcnow)

async def init_database():
    """Inicializar base de datos y crear tablas"""
    try:
        Base.metadata.create_all(bind=engine)
        print("Base de datos inicializada correctamente")
    except Exception as e:
        print(f"Error inicializando base de datos: {e}")

def get_db():
    """Dependency para obtener sesión de base de datos"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
