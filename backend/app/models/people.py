from uuid import uuid4

from sqlalchemy import Column, Date, DateTime, String, text
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
