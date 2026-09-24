from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.database.connection import get_db
from app.models.game_attempt import GameAttempt, GameSession
from app.models.people import PatientDailyProgress, PatientProgress
from app.services.adaptation import calculate_next_difficulty


router = APIRouter(
    prefix="/game-attempts",
    tags=["Game Attempts"]
)


class GameAttemptRequest(BaseModel):
    event_id: UUID
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
    # Check if this event was already processed
    existing_attempt = db.query(GameAttempt).filter(
        GameAttempt.event_id == data.event_id
    ).first()

    if existing_attempt:
        return {
            "message": "Game attempt already processed",
            "attempt_id": existing_attempt.attempt_id,
            "next_difficulty": existing_attempt.next_difficulty
        }

    # Calculate the next difficulty
    next_difficulty = calculate_next_difficulty(
        data.difficulty,
        data.accuracy
    )

    # Create database record
    game_attempt = GameAttempt(
        event_id=data.event_id,
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

    # A mobile client creates session IDs while offline. Record that session
    # on first sync so the game-attempt foreign key is always valid.
    if db.get(GameSession, data.session_id) is None:
        db.add(
            GameSession(
                session_id=data.session_id,
                patient_id=data.patient_id,
                started_at=data.started_at,
                completed_at=data.completed_at,
            )
        )
        # GameAttempt has a database FK to this row, but there is no ORM
        # relationship between the models to determine insert order.
        db.flush()

    # Upsert daily progress
    attempt_date = data.started_at.date() if data.started_at else datetime.now().date()
    daily_prog = db.query(PatientDailyProgress).filter(
        PatientDailyProgress.patient_id == data.patient_id,
        PatientDailyProgress.progress_date == attempt_date,
    ).first()

    if daily_prog is None:
        target = 10
        daily_prog = PatientDailyProgress(
            patient_id=data.patient_id,
            progress_date=attempt_date,
            activities_completed=1,
            daily_goal_target=target,
            daily_goal_percentage=min(100.0, round((1.0 / target) * 100.0, 1)),
            average_accuracy=data.accuracy,
            total_score=data.score,
            reminders_completed=0,
            reminders_total=0,
        )
        db.add(daily_prog)
    else:
        prev_acts = daily_prog.activities_completed
        new_acts = prev_acts + 1
        new_daily_avg = ((float(daily_prog.average_accuracy) * prev_acts) + data.accuracy) / new_acts
        daily_prog.activities_completed = new_acts
        daily_prog.total_score += data.score
        daily_prog.average_accuracy = round(new_daily_avg, 2)
        target = daily_prog.daily_goal_target or 10
        daily_prog.daily_goal_percentage = min(100.0, round((new_acts / float(target)) * 100.0, 1))

    # Update overall patient progress
    progress = db.get(PatientProgress, data.patient_id)
    if progress is not None:
        completed_activities = progress.activities_completed
        updated_average_accuracy = (
            (float(progress.average_accuracy) * completed_activities) + data.accuracy
        ) / (completed_activities + 1)

        progress.activities_completed = completed_activities + 1
        progress.total_score += data.score
        progress.average_accuracy = round(updated_average_accuracy, 2)
        progress.overall_progress = min(100.0, round(((completed_activities + 1) / 10.0) * 100.0, 1))

    # Save to PostgreSQL
    db.add(game_attempt)
    db.commit()
    db.refresh(game_attempt)

    return {
        "message": "Game attempt saved successfully",
        "attempt_id": game_attempt.attempt_id,
        "next_difficulty": next_difficulty
    }
