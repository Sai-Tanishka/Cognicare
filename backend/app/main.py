from fastapi import FastAPI
from sqlalchemy import text

from app.database.connection import engine
from app.routes.game_attempts import router as game_attempts_router


app = FastAPI(
    title="Cognicare API",
    description="Backend API for the Cognicare cognitive wellness platform",
    version="1.0.0"
)


# Register game attempts API
app.include_router(game_attempts_router)


@app.get("/")
def root():
    return {
        "message": "Welcome to Cognicare API",
        "status": "running"
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy"
    }


@app.get("/db-test")
def database_test():
    try:
        with engine.connect() as connection:
            result = connection.execute(text("SELECT 1"))
            value = result.scalar()

        return {
            "database": "connected",
            "test_result": value
        }

    except Exception as e:
        return {
            "database": "connection failed",
            "error": str(e)
        }