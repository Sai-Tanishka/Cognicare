from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.database.connection import get_db
from app.models.game_attempt import GameAttempt
from app.services.adaptation import calculate_next_difficulty


router = APIRouter(
    prefix="/game-attempts",
    tags=["Game Attempts"]
)


class GameAttemptRequest(BaseModel):
    patient_id: UUID
    session_id: UUID
    game_id: UUID

    difficulty: int
    score: int
    accuracy: float

    attempts: int
    correct_answers: int
    incorrect_answers: int

    average_response_time: float

    hints_used: int
    retries: int

    started_at: datetime
    completed_at: datetime


@router.post("/")
def create_game_attempt(
    data: GameAttemptRequest,
    db: Session = Depends(get_db)
):
    # Calculate the next difficulty
    next_difficulty = calculate_next_difficulty(
        data.difficulty,
        data.accuracy
    )

    # Create database record
    game_attempt = GameAttempt(
        patient_id=data.patient_id,
        session_id=data.session_id,
        game_id=data.game_id,
        difficulty=data.difficulty,
        score=data.score,
        accuracy=data.accuracy,
        attempts=data.attempts,
        correct_answers=data.correct_answers,
        incorrect_answers=data.incorrect_answers,
        average_response_time=data.average_response_time,
        hints_used=data.hints_used,
        retries=data.retries,
        started_at=data.started_at,
        completed_at=data.completed_at,
        next_difficulty=next_difficulty
    )

    # Save to PostgreSQL
    db.add(game_attempt)
    db.commit()
    db.refresh(game_attempt)

    return {
        "message": "Game attempt saved successfully",
        "attempt_id": game_attempt.attempt_id,
        "next_difficulty": next_difficulty
    }