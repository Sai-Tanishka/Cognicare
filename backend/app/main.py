from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy.exc import SQLAlchemyError

from app.database.connection import engine
from app.database.connection import Base
from app.models.daily_task import DailyTask, DailyTaskTemplate
from app.models.game_attempt import GameAttempt, GameSession
from app.models.people import Caregiver, CaregiverPatient, Patient, PatientDailyProgress, PatientProgress
from app.routes.daily_tasks import router as daily_tasks_router
from app.routes.game_attempts import router as game_attempts_router
from app.routes.people import router as people_router
from app.routes.translation import router as translation_router

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

# Mount static uploads directory for daily task proof (photo, video, audio)
uploads_dir = Path(__file__).resolve().parents[1] / "uploads"
uploads_dir.mkdir(parents=True, exist_ok=True)
(uploads_dir / "daily_tasks").mkdir(parents=True, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=str(uploads_dir)), name="uploads")

app.include_router(daily_tasks_router)
app.include_router(game_attempts_router)
app.include_router(people_router)
app.include_router(translation_router)


@app.on_event("startup")
def initialize_database():
    if engine is None:
        return

    try:
        Base.metadata.create_all(bind=engine)
    except SQLAlchemyError:
        # Keep health and API documentation available while the database is
        # being started or configured.
        pass


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/db-test")
def db_test():
    from sqlalchemy import text
    from app.database.connection import SessionLocal

    if engine is None:
        raise HTTPException(
            status_code=503,
            detail="PostgreSQL driver is unavailable in the active Python environment",
        )

    db = SessionLocal()

    try:
        result = db.execute(text("SELECT 1"))
        return {
            "database": "connected",
            "test_result": result.scalar(),
        }
    finally:
        db.close()