import 'dart:convert';

import 'package:http/http.dart' as http;

class PeopleApi {
  static String get baseUrl => 'http://127.0.0.1:8000';

  static Future<void> loginPatient(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/people/patients/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['detail'] ?? 'Patient login failed');
    }
  }
}