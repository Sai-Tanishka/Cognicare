-- =========================================================
-- COGNICARE DATABASE SCHEMA
-- PostgreSQL 18
-- =========================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- =========================================================
-- 1. PATIENTS
-- =========================================================

CREATE TABLE patients (
    patient_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(20),
    preferred_language VARCHAR(50),
    phone VARCHAR(20),
    age INTEGER,
    diagnosis VARCHAR(100),
    severity VARCHAR(50),
    doctor_name VARCHAR(100),
    doctor_contact VARCHAR(50),
    doctor_credentials VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- =========================================================
-- 1A. PATIENT PROGRESS
-- Every patient begins with an empty (zero) progress summary.
-- =========================================================

CREATE TABLE patient_progress (
    patient_id UUID PRIMARY KEY,
    overall_progress DECIMAL(5,2) NOT NULL DEFAULT 0,
    activities_completed INTEGER NOT NULL DEFAULT 0,
    total_score INTEGER NOT NULL DEFAULT 0,
    average_accuracy DECIMAL(5,2) NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_progress_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE CASCADE
);


-- =========================================================
-- 1B. PATIENT DAILY PROGRESS
-- Tracks day-by-day activity completion, daily goal, and accuracy.
-- =========================================================

CREATE TABLE patient_daily_progress (
    daily_progress_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL,
    progress_date DATE NOT NULL DEFAULT CURRENT_DATE,
    activities_completed INTEGER NOT NULL DEFAULT 0,
    daily_goal_target INTEGER NOT NULL DEFAULT 10,
    daily_goal_percentage DECIMAL(5,2) NOT NULL DEFAULT 0,
    average_accuracy DECIMAL(5,2) NOT NULL DEFAULT 0,
    total_score INTEGER NOT NULL DEFAULT 0,
    reminders_completed INTEGER NOT NULL DEFAULT 0,
    reminders_total INTEGER NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_daily_progress_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE CASCADE,

    CONSTRAINT unique_patient_date
        UNIQUE (patient_id, progress_date)
);

CREATE INDEX idx_daily_progress_patient_date
    ON patient_daily_progress(patient_id, progress_date);



-- =========================================================
-- 2. CAREGIVERS
-- =========================================================

CREATE TABLE caregivers (
    caregiver_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    preferred_language VARCHAR(20) NOT NULL DEFAULT 'en',
    phone VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- =========================================================
-- 3. CAREGIVER ↔ PATIENT RELATIONSHIP
-- =========================================================

CREATE TABLE caregiver_patient (
    relationship_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    caregiver_id UUID NOT NULL,
    patient_id UUID NOT NULL,
    relationship_type VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_caregiver
        FOREIGN KEY (caregiver_id)
        REFERENCES caregivers(caregiver_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE CASCADE,

    CONSTRAINT unique_caregiver_patient
        UNIQUE (caregiver_id, patient_id)
);


-- =========================================================
-- 4. GAMES / ACTIVITIES
-- =========================================================

CREATE TABLE games (
    game_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- =========================================================
-- 5. GAME SESSIONS
-- =========================================================

CREATE TABLE game_sessions (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL,
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,

    CONSTRAINT fk_session_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE CASCADE
);


-- =========================================================
-- 6. GAME ATTEMPTS
-- =========================================================

CREATE TABLE game_attempts (
    attempt_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL,
    session_id UUID NOT NULL,
    game_id UUID NOT NULL,

    difficulty INTEGER NOT NULL,
    score INTEGER NOT NULL DEFAULT 0,
    accuracy DECIMAL(5,2),

    attempts INTEGER NOT NULL DEFAULT 0,
    correct_answers INTEGER NOT NULL DEFAULT 0,
    incorrect_answers INTEGER NOT NULL DEFAULT 0,

    average_response_time DECIMAL(10,2),

    hints_used INTEGER NOT NULL DEFAULT 0,
    retries INTEGER NOT NULL DEFAULT 0,

    started_at TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ,

    next_difficulty INTEGER,

    CONSTRAINT fk_attempt_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_attempt_session
        FOREIGN KEY (session_id)
        REFERENCES game_sessions(session_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_attempt_game
        FOREIGN KEY (game_id)
        REFERENCES games(game_id)
        ON DELETE CASCADE
);


-- =========================================================
-- 7. REMINDERS
-- =========================================================

CREATE TABLE reminders (
    reminder_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL,

    reminder_type VARCHAR(50) NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT,

    scheduled_time TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_reminder_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE CASCADE
);


-- =========================================================
-- 8. REMINDER EVENTS
-- =========================================================

CREATE TABLE reminder_events (
    reminder_event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reminder_id UUID NOT NULL,

    event_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status VARCHAR(30) NOT NULL,

    CONSTRAINT fk_reminder_event
        FOREIGN KEY (reminder_id)
        REFERENCES reminders(reminder_id)
        ON DELETE CASCADE
);


-- =========================================================
-- 9. OFFLINE SYNC EVENTS
-- =========================================================

CREATE TABLE sync_events (
    sync_event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL,

    event_type VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID,

    status VARCHAR(20) NOT NULL DEFAULT 'Pending',

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    synced_at TIMESTAMPTZ,

    CONSTRAINT fk_sync_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE CASCADE
);


-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX idx_game_attempts_patient
    ON game_attempts(patient_id);

CREATE INDEX idx_game_attempts_session
    ON game_attempts(session_id);

CREATE INDEX idx_game_attempts_game
    ON game_attempts(game_id);

CREATE INDEX idx_reminders_patient
    ON reminders(patient_id);

CREATE INDEX idx_reminder_events_reminder
    ON reminder_events(reminder_id);

CREATE INDEX idx_sync_events_patient
    ON sync_events(patient_id);

CREATE INDEX idx_sync_events_status
    ON sync_events(status);


-- =========================================================
-- 10. DAILY TASKS (DAILY SPT - SUBJECT PERFORMED TASKS)
-- Completely separate from cognitive games. Home-based, safe,
-- non-fatiguing daily activities for dementia patients.
-- =========================================================

CREATE TABLE daily_task_templates (
    template_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    instructions TEXT NOT NULL,
    visual_steps JSONB NOT NULL DEFAULT '[]'::jsonb,
    task_category VARCHAR(50) NOT NULL,
    difficulty VARCHAR(30) NOT NULL DEFAULT 'EASY',
    submission_type VARCHAR(30) NOT NULL, -- PHOTO, VIDEO, AUDIO, NONE
    visual_instruction_url VARCHAR(255),
    reference_image_url VARCHAR(255),
    estimated_duration VARCHAR(50) NOT NULL DEFAULT '5 mins',
    reading_passage TEXT,
    order_index INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE daily_tasks (
    daily_task_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL,
    template_id UUID,
    assigned_date DATE NOT NULL DEFAULT CURRENT_DATE,
    title VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    instructions TEXT NOT NULL,
    visual_steps JSONB NOT NULL DEFAULT '[]'::jsonb,
    task_category VARCHAR(50) NOT NULL,
    difficulty VARCHAR(30) NOT NULL DEFAULT 'EASY',
    submission_type VARCHAR(30) NOT NULL, -- PHOTO, VIDEO, AUDIO, NONE
    visual_instruction_url VARCHAR(255),
    reference_image_url VARCHAR(255),
    estimated_duration VARCHAR(50) NOT NULL DEFAULT '5 mins',
    reading_passage TEXT,

    status VARCHAR(30) NOT NULL DEFAULT 'ASSIGNED', -- ASSIGNED, IN_PROGRESS, SUBMITTED, REVIEWED, APPROVED, NEEDS_RETRY
    submitted_at TIMESTAMPTZ,
    submission_url VARCHAR(500),
    submission_file_name VARCHAR(255),
    submission_file_type VARCHAR(100),
    submission_notes TEXT,

    caregiver_review_status VARCHAR(30) NOT NULL DEFAULT 'PENDING', -- PENDING, APPROVED, NEEDS_RETRY
    caregiver_feedback TEXT,
    reviewed_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_daily_task_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_daily_task_template
        FOREIGN KEY (template_id)
        REFERENCES daily_task_templates(template_id)
        ON DELETE SET NULL,

    CONSTRAINT unique_patient_daily_task_date
        UNIQUE (patient_id, assigned_date)
);

CREATE INDEX idx_daily_tasks_patient_date
    ON daily_tasks(patient_id, assigned_date);

CREATE INDEX idx_daily_tasks_status
    ON daily_tasks(status);

