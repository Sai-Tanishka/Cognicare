-- Adds the fields required by the backend people/auth API.
-- Safe to run more than once.

ALTER TABLE patients
    ADD COLUMN IF NOT EXISTS email VARCHAR(255),
    ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);

ALTER TABLE caregivers
    ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255),
    ADD COLUMN IF NOT EXISTS preferred_language VARCHAR(20) NOT NULL DEFAULT 'en';

CREATE UNIQUE INDEX IF NOT EXISTS uq_patients_email
    ON patients (email)
    WHERE email IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS uq_caregivers_email
    ON caregivers (email);

CREATE UNIQUE INDEX IF NOT EXISTS uq_caregiver_patient_link
    ON caregiver_patient (caregiver_id, patient_id);
