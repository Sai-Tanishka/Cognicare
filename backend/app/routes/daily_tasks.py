import os
import shutil
from datetime import date, datetime, timezone
from pathlib import Path
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.database.connection import get_db
from app.models.daily_task import DailyTask, DailyTaskTemplate
from app.models.people import Patient

router = APIRouter(tags=["Daily SPT Tasks"])

# Upload directory: backend/uploads/daily_tasks
UPLOAD_DIR = Path(__file__).resolve().parents[2] / "uploads" / "daily_tasks"
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


def serialize_daily_task(task: DailyTask) -> dict:
    return {
        "daily_task_id": str(task.daily_task_id),
        "patient_id": str(task.patient_id),
        "template_id": str(task.template_id) if task.template_id else None,
        "assigned_date": task.assigned_date.isoformat() if task.assigned_date else None,
        "title": task.title,
        "description": task.description,
        "instructions": task.instructions,
        "visual_steps": task.visual_steps or [],
        "task_category": task.task_category,
        "difficulty": task.difficulty,
        "submission_type": task.submission_type,
        "visual_instruction_url": task.visual_instruction_url,
        "reference_image_url": task.reference_image_url,
        "estimated_duration": task.estimated_duration,
        "reading_passage": task.reading_passage,
        "status": task.status,
        "submitted_at": task.submitted_at.isoformat() if task.submitted_at else None,
        "submission_url": task.submission_url,
        "submission_file_name": task.submission_file_name,
        "submission_file_type": task.submission_file_type,
        "submission_notes": task.submission_notes,
        "caregiver_review_status": task.caregiver_review_status,
        "caregiver_feedback": task.caregiver_feedback,
        "reviewed_at": task.reviewed_at.isoformat() if task.reviewed_at else None,
        "created_at": task.created_at.isoformat() if task.created_at else None,
    }


def assign_today_task_for_patient(patient_id: UUID, db: Session) -> DailyTask:
    """Helper to get or assign today's task from the catalog for a patient."""
    today = date.today()
    existing = (
        db.query(DailyTask)
        .filter(DailyTask.patient_id == patient_id, DailyTask.assigned_date == today)
        .first()
    )
    if existing:
        return existing

    # Find total tasks assigned to rotate deterministically through templates
    assigned_count = (
        db.query(DailyTask).filter(DailyTask.patient_id == patient_id).count()
    )

    templates = (
        db.query(DailyTaskTemplate)
        .order_index_asc() if hasattr(DailyTaskTemplate, "order_index_asc")
        else db.query(DailyTaskTemplate).order_by(DailyTaskTemplate.order_index.asc()).all()
    )

    if not templates:
        # Fallback default template if catalog is empty
        template_data = {
            "title": "Seated Arm Exercise",
            "description": "Gently raise and lower both arms while seated comfortably.",
            "instructions": "Sit upright. Slowly raise both arms to shoulder level. Hold for 2 seconds, lower down. Repeat 5 times.",
            "visual_steps": [
                {"step": 1, "title": "Sit upright", "detail": "Sit comfortably in a sturdy chair.", "icon": "chair"},
                {"step": 2, "title": "Raise arms", "detail": "Slowly raise arms forward.", "icon": "accessibility_new"},
                {"step": 3, "title": "Lower arms", "detail": "Lower arms and repeat 5 times.", "icon": "self_improvement"},
            ],
            "task_category": "PHYSICAL_ACTIVITY",
            "difficulty": "EASY",
            "submission_type": "VIDEO",
            "estimated_duration": "5 mins",
        }
        selected_template = None
    else:
        selected_template = templates[assigned_count % len(templates)]
        template_data = {
            "title": selected_template.title,
            "description": selected_template.description,
            "instructions": selected_template.instructions,
            "visual_steps": selected_template.visual_steps,
            "task_category": selected_template.task_category,
            "difficulty": selected_template.difficulty,
            "submission_type": selected_template.submission_type,
            "visual_instruction_url": selected_template.visual_instruction_url,
            "reference_image_url": selected_template.reference_image_url,
            "estimated_duration": selected_template.estimated_duration,
            "reading_passage": selected_template.reading_passage,
        }

    new_task = DailyTask(
        patient_id=patient_id,
        template_id=selected_template.template_id if selected_template else None,
        assigned_date=today,
        title=template_data["title"],
        description=template_data["description"],
        instructions=template_data["instructions"],
        visual_steps=template_data["visual_steps"],
        task_category=template_data["task_category"],
        difficulty=template_data["difficulty"],
        submission_type=template_data["submission_type"],
        visual_instruction_url=template_data.get("visual_instruction_url"),
        reference_image_url=template_data.get("reference_image_url"),
        estimated_duration=template_data["estimated_duration"],
        reading_passage=template_data.get("reading_passage"),
        status="ASSIGNED",
        caregiver_review_status="PENDING",
    )

    db.add(new_task)
    db.commit()
    db.refresh(new_task)
    return new_task


# ============================================================
# 1. GET TODAY'S TASK
# ============================================================
@router.get("/daily-tasks/today/{patient_id}")
@router.get("/api/daily-tasks/today/{patient_id}")
def get_today_task(patient_id: UUID, db: Session = Depends(get_db)):
    patient = db.query(Patient).filter(Patient.patient_id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")

    task = assign_today_task_for_patient(patient_id, db)
    return serialize_daily_task(task)


# ============================================================
# 2. SUBMIT TASK PROOF
# ============================================================
@router.post("/daily-tasks/{daily_task_id}/submit")
@router.post("/api/daily-tasks/{daily_task_id}/submit")
def submit_task_proof(
    daily_task_id: UUID,
    file: UploadFile | None = File(None),
    notes: str | None = Form(None),
    submission_type: str | None = Form(None),
    db: Session = Depends(get_db),
):
    task = db.query(DailyTask).filter(DailyTask.daily_task_id == daily_task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Daily task not found")

    submission_url = task.submission_url
    file_name = task.submission_file_name
    file_type = task.submission_file_type

    if file is not None and file.filename:
        # Determine file extension safely
        orig_name = Path(file.filename).name
        ext = Path(orig_name).suffix
        safe_filename = f"{uuid4().hex[:12]}_{orig_name}"
        destination = UPLOAD_DIR / safe_filename

        try:
            with destination.open("wb") as buffer:
                shutil.copyfileobj(file.file, buffer)
        finally:
            file.file.close()

        submission_url = f"/uploads/daily_tasks/{safe_filename}"
        file_name = orig_name
        file_type = file.content_type or "application/octet-stream"

    task.status = "SUBMITTED"
    task.submitted_at = datetime.now(timezone.utc)
    task.submission_url = submission_url
    task.submission_file_name = file_name
    task.submission_file_type = file_type
    if notes is not None:
        task.submission_notes = notes
    task.caregiver_review_status = "PENDING"

    db.commit()
    db.refresh(task)

    return {
        "message": "Task proof submitted successfully",
        "task": serialize_daily_task(task),
    }


# ============================================================
# 3. GET PATIENT TASK HISTORY
# ============================================================
@router.get("/daily-tasks/history/{patient_id}")
@router.get("/api/daily-tasks/history/{patient_id}")
def get_patient_task_history(patient_id: UUID, db: Session = Depends(get_db)):
    patient = db.query(Patient).filter(Patient.patient_id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")

    tasks = (
        db.query(DailyTask)
        .filter(DailyTask.patient_id == patient_id)
        .order_by(DailyTask.assigned_date.desc(), DailyTask.created_at.desc())
        .all()
    )

    return [serialize_daily_task(t) for t in tasks]


# ============================================================
# 4. CAREGIVER TASK OVERVIEW
# ============================================================
@router.get("/caregiver/daily-tasks/{patient_id}")
@router.get("/api/caregiver/daily-tasks/{patient_id}")
@router.get("/api/daily-tasks/caregiver/{patient_id}")
def get_caregiver_daily_task_overview(patient_id: UUID, db: Session = Depends(get_db)):
    patient = db.query(Patient).filter(Patient.patient_id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")

    today = date.today()
    today_task = (
        db.query(DailyTask)
        .filter(DailyTask.patient_id == patient_id, DailyTask.assigned_date == today)
        .first()
    )

    all_tasks = (
        db.query(DailyTask)
        .filter(DailyTask.patient_id == patient_id)
        .order_by(DailyTask.assigned_date.desc())
        .all()
    )

    total_assigned = len(all_tasks)
    total_submitted = sum(
        1 for t in all_tasks if t.status in ("SUBMITTED", "APPROVED", "REVIEWED")
    )
    total_approved = sum(1 for t in all_tasks if t.status == "APPROVED")

    return {
        "patient_id": str(patient_id),
        "patient_name": patient.name,
        "today_task": serialize_daily_task(today_task) if today_task else None,
        "total_assigned": total_assigned,
        "total_submitted": total_submitted,
        "total_approved": total_approved,
        "history": [serialize_daily_task(t) for t in all_tasks],
    }


# ============================================================
# 5. CAREGIVER REVIEW TASK
# ============================================================
class ReviewRequest(BaseModel):
    status: str  # APPROVED, NEEDS_RETRY, REVIEWED
    caregiver_feedback: str | None = None


@router.patch("/daily-tasks/{daily_task_id}/review")
@router.patch("/api/daily-tasks/{daily_task_id}/review")
def review_daily_task(
    daily_task_id: UUID,
    payload: ReviewRequest,
    db: Session = Depends(get_db),
):
    task = db.query(DailyTask).filter(DailyTask.daily_task_id == daily_task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Daily task not found")

    clean_status = payload.status.strip().upper()
    if clean_status not in ("APPROVED", "NEEDS_RETRY", "REVIEWED"):
        raise HTTPException(
            status_code=400,
            detail="Status must be one of: APPROVED, NEEDS_RETRY, REVIEWED",
        )

    task.status = clean_status
    task.caregiver_review_status = clean_status
    task.caregiver_feedback = payload.caregiver_feedback
    task.reviewed_at = datetime.now(timezone.utc)

    db.commit()
    db.refresh(task)

    return {
        "message": f"Task review updated to {clean_status}",
        "task": serialize_daily_task(task),
    }
