import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _patientLoggedInKey = 'patient_logged_in';

  static Future<bool> isPatientLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_patientLoggedInKey) ?? false;
  }

  static Future<void> setPatientLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_patientLoggedInKey, true);
  }

  static Future<void> clearPatientSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_patientLoggedInKey);
  }
}