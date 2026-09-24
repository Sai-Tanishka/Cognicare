from uuid import uuid4

from sqlalchemy import Column, Date, DateTime, ForeignKey, Integer, Numeric, String, text
from sqlalchemy.dialects.postgresql import UUID

from app.database.connection import Base


class Patient(Base):
    __tablename__ = "patients"

    patient_id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    name = Column(String(100), nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    date_of_birth = Column(Date)
    gender = Column(String(20))
    preferred_language = Column(String(50))
    phone = Column(String(20))
    age = Column(Integer)
    diagnosis = Column(String(100))
    severity = Column(String(50))
    doctor_name = Column(String(100))
    doctor_contact = Column(String(50))
    doctor_credentials = Column(String(100))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class Caregiver(Base):
    __tablename__ = "caregivers"

    caregiver_id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    name = Column(String(100), nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    preferred_language = Column(String(20), nullable=False, server_default="en")
    phone = Column(String(20))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class CaregiverPatient(Base):
    __tablename__ = "caregiver_patient"

    relationship_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)
    caregiver_id = Column(UUID(as_uuid=True), nullable=False)
    patient_id = Column(UUID(as_uuid=True), nullable=False)
    relationship_type = Column(String(50))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class PatientProgress(Base):
    """The progress summary created for every patient at registration."""

    __tablename__ = "patient_progress"

    patient_id = Column(
        UUID(as_uuid=True),
        ForeignKey("patients.patient_id", ondelete="CASCADE"),
        primary_key=True,
    )
    overall_progress = Column(Numeric(5, 2), nullable=False, server_default=text("0"))
    activities_completed = Column(Integer, nullable=False, server_default=text("0"))
    total_score = Column(Integer, nullable=False, server_default=text("0"))
    average_accuracy = Column(Numeric(5, 2), nullable=False, server_default=text("0"))
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class PatientDailyProgress(Base):
    __tablename__ = "patient_daily_progress"

    daily_progress_id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    patient_id = Column(
        UUID(as_uuid=True),
        ForeignKey("patients.patient_id", ondelete="CASCADE"),
        nullable=False,
    )
    progress_date = Column(Date, nullable=False, server_default=text("CURRENT_DATE"))
    activities_completed = Column(Integer, nullable=False, server_default=text("0"))
    daily_goal_target = Column(Integer, nullable=False, server_default=text("10"))
    daily_goal_percentage = Column(Numeric(5, 2), nullable=False, server_default=text("0"))
    average_accuracy = Column(Numeric(5, 2), nullable=False, server_default=text("0"))
    total_score = Column(Integer, nullable=False, server_default=text("0"))
    reminders_completed = Column(Integer, nullable=False, server_default=text("0"))
    reminders_total = Column(Integer, nullable=False, server_default=text("0"))
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
