"""
Configuración y variables de entorno para el Sistema de Tutorial Inteligente
"""

import os
from typing import Dict, Any

class Config:
    """Configuración principal del sistema"""

    # Configuración de la API
    API_HOST = os.getenv("API_HOST", "0.0.0.0")
    API_PORT = int(os.getenv("API_PORT", 8000))
    DEBUG_MODE = os.getenv("DEBUG_MODE", "true").lower() == "true"

    # Configuración de base de datos
    DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./intelligent_tutorial.db")

    # Configuración de modelos NLP
    SPACY_MODEL = os.getenv("SPACY_MODEL", "es_core_news_sm")
    SENTIMENT_MODEL = os.getenv("SENTIMENT_MODEL", "nlptown/bert-base-multilingual-uncased-sentiment")
    TEXT_GENERATION_MODEL = os.getenv("TEXT_GENERATION_MODEL", "microsoft/DialoGPT-medium")

    # Configuración de ML
    MODEL_CACHE_DIR = os.getenv("MODEL_CACHE_DIR", "./models")
    TRAINING_DATA_DIR = os.getenv("TRAINING_DATA_DIR", "./data")

    # Configuración de personalización
    DEFAULT_LANGUAGE = os.getenv("DEFAULT_LANGUAGE", "es")
    DEFAULT_LEARNING_STYLE = os.getenv("DEFAULT_LEARNING_STYLE", "visual")

    # Límites del sistema
    MAX_ACTIVE_SESSIONS = int(os.getenv("MAX_ACTIVE_SESSIONS", 1000))
    MAX_PLAYERS = int(os.getenv("MAX_PLAYERS", 10000))
    SESSION_TIMEOUT_MINUTES = int(os.getenv("SESSION_TIMEOUT_MINUTES", 30))

    # Configuración de logging
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
    LOG_FILE = os.getenv("LOG_FILE", "tutorial_system.log")

    @classmethod
    def get_model_config(cls) -> Dict[str, Any]:
        """Obtener configuración de modelos"""
        return {
            "spacy_model": cls.SPACY_MODEL,
            "sentiment_model": cls.SENTIMENT_MODEL,
            "text_generation_model": cls.TEXT_GENERATION_MODEL,
            "cache_dir": cls.MODEL_CACHE_DIR
        }

    @classmethod
    def get_api_config(cls) -> Dict[str, Any]:
        """Obtener configuración de API"""
        return {
            "host": cls.API_HOST,
            "port": cls.API_PORT,
            "debug": cls.DEBUG_MODE
        }

    @classmethod
    def validate_config(cls) -> bool:
        """Validar configuración del sistema"""
        required_dirs = [cls.MODEL_CACHE_DIR, cls.TRAINING_DATA_DIR]

        for dir_path in required_dirs:
            if not os.path.exists(dir_path):
                os.makedirs(dir_path, exist_ok=True)

        return True

# Configuración específica para desarrollo
class DevelopmentConfig(Config):
    DEBUG_MODE = True
    DATABASE_URL = "sqlite:///./dev_tutorial.db"

# Configuración específica para producción
class ProductionConfig(Config):
    DEBUG_MODE = False
    API_HOST = "0.0.0.0"
    DATABASE_URL = os.getenv("PROD_DATABASE_URL", "postgresql://user:pass@localhost/tutorial_db")

# Configuración específica para testing
class TestingConfig(Config):
    DEBUG_MODE = True
    DATABASE_URL = "sqlite:///:memory:"
    MAX_ACTIVE_SESSIONS = 10
    MAX_PLAYERS = 100

# Mapeo de configuraciones
config_map = {
    "development": DevelopmentConfig,
    "production": ProductionConfig,
    "testing": TestingConfig
}

def get_config(env: str = None) -> Config:
    """Obtener configuración según el entorno"""
    if env is None:
        env = os.getenv("ENVIRONMENT", "development")

    return config_map.get(env, DevelopmentConfig)
