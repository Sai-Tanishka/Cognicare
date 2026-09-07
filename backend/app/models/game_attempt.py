from sqlalchemy import Column, Integer, Numeric, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import text

from app.database.connection import Base


class GameAttempt(Base):
    __tablename__ = "game_attempts"

    attempt_id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()")
    )
    event_id = Column(UUID(as_uuid=True), nullable=False, unique=True)

    event_id = Column(
        UUID(as_uuid=True),
        unique=True,
        nullable=False
    )

    patient_id = Column(UUID(as_uuid=True), nullable=False)
    session_id = Column(UUID(as_uuid=True), nullable=False)
    game_id = Column(UUID(as_uuid=True), nullable=False)

    difficulty = Column(Integer, nullable=False)
    score = Column(Integer, nullable=False, default=0)
    accuracy = Column(Numeric(5, 2))

    attempts = Column(Integer, nullable=False, default=0)
    correct_answers = Column(Integer, nullable=False, default=0)
    incorrect_answers = Column(Integer, nullable=False, default=0)

    average_response_time = Column(Numeric(10, 2))

    hints_used = Column(Integer, nullable=False, default=0)
    retries = Column(Integer, nullable=False, default=0)

    started_at = Column(DateTime(timezone=True), nullable=False)
    completed_at = Column(DateTime(timezone=True))

    next_difficulty = Column(Integer)