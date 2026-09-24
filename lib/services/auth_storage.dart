import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _patientLoggedInKey = 'patient_logged_in';
  static const _patientIdKey = 'patient_id';
  static const _patientProfileKey = 'patient_profile_json';

  static Future<bool> isPatientLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_patientLoggedInKey) ?? false;
  }

  static Future<void> setPatientLoggedIn(
    String patientId, {
    Map<String, dynamic>? profile,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_patientLoggedInKey, true);
    await preferences.setString(_patientIdKey, patientId);
    if (profile != null) {
      await preferences.setString(_patientProfileKey, jsonEncode(profile));
    }
  }

  static Future<String?> getPatientId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_patientIdKey);
  }

  static Future<void> savePatientProfile(Map<String, dynamic> profile) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_patientProfileKey, jsonEncode(profile));
  }

  static Future<Map<String, dynamic>?> getPatientProfile() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_patientProfileKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearPatientSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_patientLoggedInKey);
    await preferences.remove(_patientIdKey);
    await preferences.remove(_patientProfileKey);
  }

  static const _caregiverLoggedInKey = 'caregiver_logged_in';
  static const _caregiverIdKey = 'caregiver_id';
  static const _caregiverProfileKey = 'caregiver_profile_json';

  static Future<bool> isCaregiverLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_caregiverLoggedInKey) ?? false;
  }

  static Future<void> setCaregiverLoggedIn(
    String caregiverId, {
    Map<String, dynamic>? profile,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_caregiverLoggedInKey, true);
    await preferences.setString(_caregiverIdKey, caregiverId);
    if (profile != null) {
      await preferences.setString(_caregiverProfileKey, jsonEncode(profile));
    }
  }

  static Future<String?> getCaregiverId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_caregiverIdKey);
  }

  static Future<Map<String, dynamic>?> getCaregiverProfile() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_caregiverProfileKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearCaregiverSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_caregiverLoggedInKey);
    await preferences.remove(_caregiverIdKey);
    await preferences.remove(_caregiverProfileKey);
  }
}
