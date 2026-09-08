from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database.connection import engine
from app.database.connection import Base
from app.routes.game_attempts import router as game_attempts_router

app = FastAPI(
    title="Cognicare Backend",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

Base.metadata.create_all(bind=engine)

app.include_router(game_attempts_router)


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/db-test")
def db_test():
    from sqlalchemy import text
    from app.database.connection import SessionLocal

    db = SessionLocal()

    try:
        result = db.execute(text("SELECT 1"))
        return {
            "database": "connected",
            "test_result": result.scalar(),
        }
    finally:
        db.close()