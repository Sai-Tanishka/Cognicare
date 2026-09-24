-- Creates zeroed progress summaries for all existing and future patients.
-- Run after 001_auth_and_relationships.sql on an existing database.

CREATE TABLE IF NOT EXISTS patient_progress (
    patient_id UUID PRIMARY KEY REFERENCES patients(patient_id) ON DELETE CASCADE,
    overall_progress DECIMAL(5,2) NOT NULL DEFAULT 0,
    activities_completed INTEGER NOT NULL DEFAULT 0,
    total_score INTEGER NOT NULL DEFAULT 0,
    average_accuracy DECIMAL(5,2) NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO patient_progress (patient_id)
SELECT patient_id
FROM patients
ON CONFLICT (patient_id) DO NOTHING;
