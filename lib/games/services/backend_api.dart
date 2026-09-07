import 'dart:convert';

import 'package:http/http.dart' as http;

class BackendApi {
  static const String baseUrl = 'http://172.20.10.2:8000';

  static Future<Map<String, dynamic>> saveGameAttempt({
    required String eventId,
    required String patientId,
    required String sessionId,
    required String gameId,
    required int difficulty,
    required int score,
    required double accuracy,
    required int attempts,
    required int correctAnswers,
    required int incorrectAnswers,
    required double averageResponseTime,
    required int hintsUsed,
    required int retries,
    required String startedAt,
    required String completedAt,
  }) async {
    final uri = Uri.parse('$baseUrl/game-attempts/');

    final body = {
      'event_id': eventId,
      'patient_id': patientId,
      'session_id': sessionId,
      'game_id': gameId,
      'difficulty': difficulty,
      'score': score,
      'accuracy': accuracy,
      'attempts': attempts,
      'correct_answers': correctAnswers,
      'incorrect_answers': incorrectAnswers,
      'average_response_time': averageResponseTime,
      'hints_used': hintsUsed,
      'retries': retries,
      'started_at': startedAt,
      'completed_at': completedAt,
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to save game attempt. '
      'Status: ${response.statusCode}, '
      'Response: ${response.body}',
    );
  }
}