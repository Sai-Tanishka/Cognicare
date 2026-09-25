from datetime import datetime, timezone
from uuid import uuid4

from sqlalchemy import Column, Date, DateTime, ForeignKey, Integer, String, Text, UniqueConstraint, text
from sqlalchemy.dialects.postgresql import UUID, JSONB

from app.database.connection import Base


class DailyTaskTemplate(Base):
    """Catalog of reusable daily home-based tasks for dementia patients."""

    __tablename__ = "daily_task_templates"

    template_id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid4,
        server_default=text("gen_random_uuid()"),
    )
    code = Column(String(50), unique=True, nullable=False)
    title = Column(String(150), nullable=False)
    description = Column(Text, nullable=False)
    instructions = Column(Text, nullable=False)
    visual_steps = Column(JSONB, nullable=False, server_default=text("'[]'::jsonb"))
    task_category = Column(String(50), nullable=False)
    difficulty = Column(String(30), nullable=False, server_default="EASY")
    submission_type = Column(String(30), nullable=False)  # PHOTO, VIDEO, AUDIO, NONE
    visual_instruction_url = Column(String(255), nullable=True)
    reference_image_url = Column(String(255), nullable=True)
    estimated_duration = Column(String(50), nullable=False, server_default="5 mins")
    reading_passage = Column(Text, nullable=True)
    order_index = Column(Integer, nullable=False, server_default=text("0"))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class DailyTask(Base):
    """Patient-assigned daily task for a specific date (one per day)."""

    __tablename__ = "daily_tasks"

    daily_task_id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid4,
        server_default=text("gen_random_uuid()"),
    )
    patient_id = Column(
        UUID(as_uuid=True),
        ForeignKey("patients.patient_id", ondelete="CASCADE"),
        nullable=False,
    )
    template_id = Column(
        UUID(as_uuid=True),
        ForeignKey("daily_task_templates.template_id", ondelete="SET NULL"),
        nullable=True,
    )
    assigned_date = Column(Date, nullable=False, server_default=text("CURRENT_DATE"))
    title = Column(String(150), nullable=False)
    description = Column(Text, nullable=False)
    instructions = Column(Text, nullable=False)
    visual_steps = Column(JSONB, nullable=False, server_default=text("'[]'::jsonb"))
    task_category = Column(String(50), nullable=False)
    difficulty = Column(String(30), nullable=False, server_default="EASY")
    submission_type = Column(String(30), nullable=False)  # PHOTO, VIDEO, AUDIO, NONE
    visual_instruction_url = Column(String(255), nullable=True)
    reference_image_url = Column(String(255), nullable=True)
    estimated_duration = Column(String(50), nullable=False, server_default="5 mins")
    reading_passage = Column(Text, nullable=True)

    # Status tracking: ASSIGNED, IN_PROGRESS, SUBMITTED, REVIEWED, APPROVED, NEEDS_RETRY
    status = Column(String(30), nullable=False, server_default="ASSIGNED")
    submitted_at = Column(DateTime(timezone=True), nullable=True)
    submission_url = Column(String(500), nullable=True)
    submission_file_name = Column(String(255), nullable=True)
    submission_file_type = Column(String(100), nullable=True)
    submission_notes = Column(Text, nullable=True)

    # Caregiver review: PENDING, APPROVED, NEEDS_RETRY
    caregiver_review_status = Column(String(30), nullable=False, server_default="PENDING")
    caregiver_feedback = Column(Text, nullable=True)
    reviewed_at = Column(DateTime(timezone=True), nullable=True)

    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))

    __table_args__ = (
        UniqueConstraint("patient_id", "assigned_date", name="unique_patient_daily_task_date"),
    )
