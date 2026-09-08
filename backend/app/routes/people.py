import hashlib
import hmac
import secrets
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.database.connection import get_db
from app.models.people import Caregiver, CaregiverPatient, Patient

router = APIRouter(prefix="/people", tags=["People"])


def hash_password(password: str) -> str:
    salt = secrets.token_bytes(16)
    digest = hashlib.pbkdf2_hmac("sha256", password.encode(), salt, 120_000)
    return f"{salt.hex()}:{digest.hex()}"


def verify_password(password: str, stored: str) -> bool:
    try:
        salt_hex, digest_hex = stored.split(":", 1)
        digest = hashlib.pbkdf2_hmac(
            "sha256", password.encode(), bytes.fromhex(salt_hex), 120_000
        )
        return hmac.compare_digest(digest.hex(), digest_hex)
    except ValueError:
        return False


class LoginRequest(BaseModel):
    email: str
    password: str = Field(min_length=8)


class PatientCreateRequest(LoginRequest):
    name: str = Field(min_length=1, max_length=100)
    gender: str | None = None
    preferred_language: str | None = "English"


class CaregiverCreateRequest(LoginRequest):
    name: str = Field(min_length=1, max_length=100)
    phone: str | None = None
    preferred_language: str = "en"


class AttachPatientRequest(BaseModel):
    patient_id: UUID
    relationship_type: str = "Primary caregiver"


def patient_response(patient: Patient) -> dict:
    return {
        "id": str(patient.patient_id),
        "name": patient.name,
        "email": patient.email,
        "gender": patient.gender,
        "preferred_language": patient.preferred_language,
    }


def caregiver_response(caregiver: Caregiver) -> dict:
    return {
        "id": str(caregiver.caregiver_id),
        "name": caregiver.name,
        "email": caregiver.email,
        "preferred_language": caregiver.preferred_language,
    }


@router.post("/patients/login")
def patient_login(data: LoginRequest, db: Session = Depends(get_db)):
    patient = db.scalar(select(Patient).where(Patient.email == data.email.lower()))
    if patient is None or not verify_password(data.password, patient.password_hash):
        raise HTTPException(status_code=401, detail="Invalid patient email or password")
    return {"role": "patient", "person": patient_response(patient)}


@router.post("/caregivers/login")
def caregiver_login(data: LoginRequest, db: Session = Depends(get_db)):
    caregiver = db.scalar(select(Caregiver).where(Caregiver.email == data.email.lower()))
    if caregiver is None or not verify_password(data.password, caregiver.password_hash):
        raise HTTPException(status_code=401, detail="Invalid caregiver email or password")
    return {"role": "caregiver", "person": caregiver_response(caregiver)}


@router.post("/patients")
def create_patient(data: PatientCreateRequest, db: Session = Depends(get_db)):
    existing = db.scalar(select(Patient).where(Patient.email == data.email.lower()))
    if existing is not None:
        raise HTTPException(status_code=409, detail="A patient with this email already exists")

    patient = Patient(
        name=data.name,
        email=data.email.lower(),
        password_hash=hash_password(data.password),
        gender=data.gender,
        preferred_language=data.preferred_language,
    )
    db.add(patient)
    db.commit()
    db.refresh(patient)
    return patient_response(patient)


@router.post("/caregivers")
def create_caregiver(data: CaregiverCreateRequest, db: Session = Depends(get_db)):
    existing = db.scalar(select(Caregiver).where(Caregiver.email == data.email.lower()))
    if existing is not None:
        raise HTTPException(status_code=409, detail="A caregiver with this email already exists")

    caregiver = Caregiver(
        name=data.name,
        email=data.email.lower(),
        password_hash=hash_password(data.password),
        phone=data.phone,
        preferred_language=data.preferred_language,
    )
    db.add(caregiver)
    db.commit()
    db.refresh(caregiver)
    return caregiver_response(caregiver)


@router.get("/caregivers/{caregiver_id}/patients")
def list_patients(caregiver_id: UUID, db: Session = Depends(get_db)):
    rows = db.execute(
        select(Patient)
        .join(CaregiverPatient, CaregiverPatient.patient_id == Patient.patient_id)
        .where(CaregiverPatient.caregiver_id == caregiver_id)
        .order_by(Patient.name)
    )
    return [patient_response(patient) for (patient,) in rows]


@router.post("/caregivers/{caregiver_id}/patients")
def attach_patient(
    caregiver_id: UUID,
    data: AttachPatientRequest,
    db: Session = Depends(get_db),
):
    caregiver = db.get(Caregiver, caregiver_id)
    patient = db.get(Patient, data.patient_id)
    if caregiver is None or patient is None:
        raise HTTPException(status_code=404, detail="Caregiver or patient not found")

    existing = db.scalar(
        select(CaregiverPatient).where(
            CaregiverPatient.caregiver_id == caregiver_id,
            CaregiverPatient.patient_id == data.patient_id,
        )
    )
    if existing is None:
        db.add(
            CaregiverPatient(
                caregiver_id=caregiver_id,
                patient_id=data.patient_id,
                relationship_type=data.relationship_type,
            )
        )
        db.commit()

    return patient_response(patient)


@router.get("/patients/{patient_id}/caregiver")
def get_patient_caregiver(patient_id: UUID, db: Session = Depends(get_db)):
    row = db.execute(
        select(Caregiver)
        .join(CaregiverPatient, CaregiverPatient.caregiver_id == Caregiver.caregiver_id)
        .where(CaregiverPatient.patient_id == patient_id)
        .order_by(CaregiverPatient.created_at)
    ).first()
    if row is None:
        raise HTTPException(status_code=404, detail="No caregiver is attached to this patient")
    return caregiver_response(row[0])
