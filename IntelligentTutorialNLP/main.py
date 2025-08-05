from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from src.api.routes import tutorial, player, analytics
from src.database.database import init_database

app = FastAPI(
    title="Intelligent Tutorial NLP System",
    description="Sistema de tutorial inteligente con procesamiento de lenguaje natural para WordCraftGame",
    version="1.0.0"
)

# Configurar CORS para permitir conexión desde el juego iOS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, especificar dominios exactos
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Incluir rutas de la API
app.include_router(tutorial.router, prefix="/api/v1/tutorial", tags=["tutorial"])
app.include_router(player.router, prefix="/api/v1/player", tags=["player"])
app.include_router(analytics.router, prefix="/api/v1/analytics", tags=["analytics"])

@app.on_event("startup")
async def startup_event():
    """Inicializar base de datos y modelos de NLP al arrancar"""
    await init_database()
    print("Sistema de Tutorial Inteligente iniciado correctamente")

@app.get("/")
async def root():
    return {
        "message": "Intelligent Tutorial NLP System API",
        "status": "active",
        "version": "1.0.0"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8002)
