import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class ApiService {
    static String generateEventId() {
    return const Uuid().v4();
  }
  // FastAPI backend
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<Map<String, dynamic>> submitGameAttempt({
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
    required DateTime startedAt,
    required DateTime completedAt,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/game-attempts/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
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
        'started_at': startedAt.toUtc().toIso8601String(),
        'completed_at': completedAt.toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to submit game attempt: '
      '${response.statusCode} ${response.body}',
    );
  }
}