from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, Numeric, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import text

from app.database.connection import Base


class Game(Base):
    __tablename__ = "games"

    game_id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    name = Column(String(100), nullable=False)
    description = Column(String)
    category = Column(String(50))
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class GameSession(Base):
    __tablename__ = "game_sessions"

    session_id = Column(UUID(as_uuid=True), primary_key=True)
    patient_id = Column(
        UUID(as_uuid=True),
        ForeignKey("patients.patient_id", ondelete="CASCADE"),
        nullable=False,
    )
    started_at = Column(DateTime(timezone=True), nullable=False)
    completed_at = Column(DateTime(timezone=True))


class GameAttempt(Base):
    __tablename__ = "game_attempts"

    attempt_id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()")
    )
    event_id = Column(UUID(as_uuid=True), nullable=False, unique=True)

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
