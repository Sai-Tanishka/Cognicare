const API_BASE_URL = "http://127.0.0.1:8000";

async function request(path, options = {}) {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    headers: { "Content-Type": "application/json" },
    ...options,
  });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new Error(body.detail || "The server rejected the request.");
  }
  return body;
}

export const caregiverLogin = (email, password) =>
  request("/people/caregivers/login", {
    method: "POST",
    body: JSON.stringify({ email, password }),
  });

export const caregiverRegister = (data) =>
  request("/people/caregivers", {
    method: "POST",
    body: JSON.stringify(data),
  });

export const getCaregiverPatients = (caregiverId) =>
  request(`/people/caregivers/${caregiverId}/patients`);

export const registerPatient = (data) =>
  request("/people/patients", {
    method: "POST",
    body: JSON.stringify(data),
  });

export const attachPatient = (caregiverId, patientId) =>
  request(`/people/caregivers/${caregiverId}/patients`, {
    method: "POST",
    body: JSON.stringify({ patient_id: patientId, relationship_type: "Primary caregiver" }),
  });

export const getPatientProgress = (patientId) =>
  request(`/people/patients/${patientId}/progress`);

