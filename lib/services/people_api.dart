import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'auth_storage.dart';

class PeopleApi {
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8000'
        : 'http://127.0.0.1:8000';
  }

  static Future<String> loginPatient(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/people/patients/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['detail'] ?? 'Patient login failed');
    }

    final person = body['person'] as Map<String, dynamic>;
    final patientId = person['id'] as String;
    await AuthStorage.setPatientLoggedIn(patientId, profile: person);
    return patientId;
  }

  static Future<String> loginCaregiver(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/people/caregivers/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['detail'] ?? 'Caregiver login failed');
    }

    final person = body['person'] as Map<String, dynamic>;
    final caregiverId = person['id'] as String;
    await AuthStorage.setCaregiverLoggedIn(caregiverId, profile: person);
    return caregiverId;
  }

  static Future<String> quickAccessCaregiver(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/people/caregivers/quick-access'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['detail'] ?? 'Caregiver quick access failed');
    }

    final person = body['person'] as Map<String, dynamic>;
    final caregiverId = person['id'] as String;
    await AuthStorage.setCaregiverLoggedIn(caregiverId, profile: person);
    return caregiverId;
  }

  static Future<void> resetCaregiverPassword(
    String email,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/people/caregivers/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'new_password': newPassword}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['detail'] ?? 'Password update failed');
    }
  }

  static Future<Map<String, dynamic>> registerPatient({
    required String name,
    required String email,
    required String password,
    String? phone,
    int? age,
    String? diagnosis,
    String? severity,
    String? doctorName,
    String? doctorContact,
    String? doctorCredentials,
    String? caregiverName,
    String? caregiverEmail,
    String? caregiverPhone,
    String? caregiverRelationship,
  }) async {
    final payload = {
      'name': name,
      'email': email,
      'password': password,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      'age': ?age,
      if (diagnosis != null && diagnosis.isNotEmpty) 'diagnosis': diagnosis,
      if (severity != null && severity.isNotEmpty) 'severity': severity,
      if (doctorName != null && doctorName.isNotEmpty) 'doctor_name': doctorName,
      if (doctorContact != null && doctorContact.isNotEmpty)
        'doctor_contact': doctorContact,
      if (doctorCredentials != null && doctorCredentials.isNotEmpty)
        'doctor_credentials': doctorCredentials,
      if (caregiverName != null && caregiverName.isNotEmpty)
        'caregiver_name': caregiverName,
      if (caregiverEmail != null && caregiverEmail.isNotEmpty)
        'caregiver_email': caregiverEmail,
      if (caregiverPhone != null && caregiverPhone.isNotEmpty)
        'caregiver_phone': caregiverPhone,
      if (caregiverRelationship != null && caregiverRelationship.isNotEmpty)
        'caregiver_relationship': caregiverRelationship,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/people/patients'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['detail'] ?? 'Patient registration failed');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getPatientProfile(String patientId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/people/patients/$patientId'),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['detail'] ?? 'Unable to load patient profile');
    }

    await AuthStorage.savePatientProfile(body);
    return body;
  }

  static Future<Map<String, dynamic>> getPatientProgress(
    String patientId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/people/patients/$patientId/progress'),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['detail'] ?? 'Unable to load patient progress');
    }
    return body;
  }

  static Future<Map<String, dynamic>> getPatientDailyProgress(
    String patientId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/people/patients/$patientId/daily-progress'),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['detail'] ?? 'Unable to load patient daily progress');
    }
    return body;
  }

  static Future<Map<String, dynamic>> getCaregiverPatientsDailyProgress(
    String caregiverId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/people/caregivers/$caregiverId/patients-daily-progress'),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(
        body['detail'] ?? 'Unable to load caregiver patients daily progress',
      );
    }
    return body;
  }

  static Future<Map<String, dynamic>> registerCaregiverWithPatient({
    required String caregiverName,
    required String caregiverEmail,
    required String caregiverPassword,
    String? caregiverPhone,
    String caregiverRelationship = 'Primary caregiver',
    required String patientName,
    required String patientEmail,
    required String patientPassword,
    int? patientAge,
    String? patientDiagnosis,
    String? patientSeverity,
    String? patientGender,
    String? patientPhone,
    String? patientDoctorName,
    String? patientDoctorContact,
    String? patientDoctorCredentials,
  }) async {
    final payload = {
      'caregiver_name': caregiverName.trim(),
      'caregiver_email': caregiverEmail.trim().toLowerCase(),
      'caregiver_password': caregiverPassword,
      if (caregiverPhone != null && caregiverPhone.isNotEmpty)
        'caregiver_phone': caregiverPhone.trim(),
      'caregiver_relationship': caregiverRelationship,
      'patient_name': patientName.trim(),
      'patient_email': patientEmail.trim().toLowerCase(),
      'patient_password': patientPassword,
      'patient_age': ?patientAge,
      if (patientDiagnosis != null && patientDiagnosis.isNotEmpty)
        'patient_diagnosis': patientDiagnosis,
      if (patientSeverity != null && patientSeverity.isNotEmpty)
        'patient_severity': patientSeverity,
      if (patientGender != null && patientGender.isNotEmpty)
        'patient_gender': patientGender,
      if (patientPhone != null && patientPhone.isNotEmpty)
        'patient_phone': patientPhone,
      if (patientDoctorName != null && patientDoctorName.isNotEmpty)
        'patient_doctor_name': patientDoctorName,
      if (patientDoctorContact != null && patientDoctorContact.isNotEmpty)
        'patient_doctor_contact': patientDoctorContact,
      if (patientDoctorCredentials != null && patientDoctorCredentials.isNotEmpty)
        'patient_doctor_credentials': patientDoctorCredentials,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/people/caregivers/register-with-patient'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['detail'] ?? 'Registration failed');
    }

    final cg = body['caregiver'] as Map<String, dynamic>;
    final caregiverId = cg['id'] as String;
    await AuthStorage.setCaregiverLoggedIn(caregiverId, profile: cg);

    return body;
  }

  static Future<Map<String, dynamic>> caregiverCreatePatient({
    required String caregiverId,
    required String patientName,
    required String patientEmail,
    required String patientPassword,
    int? patientAge,
    String? patientDiagnosis,
    String? patientSeverity,
    String? patientGender,
    String? patientPhone,
    String? patientDoctorName,
    String? patientDoctorContact,
    String? patientDoctorCredentials,
    String relationshipType = 'Primary caregiver',
  }) async {
    final payload = {
      'patient_name': patientName.trim(),
      'patient_email': patientEmail.trim().toLowerCase(),
      'patient_password': patientPassword,
      'patient_age': ?patientAge,
      if (patientDiagnosis != null && patientDiagnosis.isNotEmpty)
        'patient_diagnosis': patientDiagnosis,
      if (patientSeverity != null && patientSeverity.isNotEmpty)
        'patient_severity': patientSeverity,
      if (patientGender != null && patientGender.isNotEmpty)
        'patient_gender': patientGender,
      if (patientPhone != null && patientPhone.isNotEmpty)
        'patient_phone': patientPhone,
      if (patientDoctorName != null && patientDoctorName.isNotEmpty)
        'patient_doctor_name': patientDoctorName,
      if (patientDoctorContact != null && patientDoctorContact.isNotEmpty)
        'patient_doctor_contact': patientDoctorContact,
      if (patientDoctorCredentials != null && patientDoctorCredentials.isNotEmpty)
        'patient_doctor_credentials': patientDoctorCredentials,
      'relationship_type': relationshipType,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/people/caregivers/$caregiverId/create-patient'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['detail'] ?? 'Failed to register patient');
    }

    return body;
  }
}

