import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DailyTasksApi {
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8000'
        : 'http://127.0.0.1:8000';
  }

  /// Converts a relative file path (e.g. /uploads/daily_tasks/...) to an absolute URL
  static String? resolveMediaUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    final trimmed = path.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return '$baseUrl$trimmed';
  }

  /// Get today's assigned Daily SPT task for the given patient.
  static Future<Map<String, dynamic>?> getTodayTask(String patientId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/daily-tasks/today/$patientId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('DailyTasksApi.getTodayTask error: $e');
      return null;
    }
  }

  /// Submit task proof (photo, video, audio) with optional patient notes.
  static Future<Map<String, dynamic>> submitTask({
    required String dailyTaskId,
    Uint8List? fileBytes,
    String? fileName,
    String? notes,
    String? submissionType,
  }) async {
    final uri = Uri.parse('$baseUrl/daily-tasks/$dailyTaskId/submit');
    final request = http.MultipartRequest('POST', uri);

    if (notes != null && notes.trim().isNotEmpty) {
      request.fields['notes'] = notes.trim();
    }
    if (submissionType != null && submissionType.trim().isNotEmpty) {
      request.fields['submission_type'] = submissionType.trim();
    }

    if (fileBytes != null && fileBytes.isNotEmpty && fileName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );
    }

    final streamed = await request.send().timeout(const Duration(seconds: 45));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      try {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(body['detail'] ?? 'Submission failed (${response.statusCode})');
      } catch (_) {
        throw Exception('Submission failed with status ${response.statusCode}');
      }
    }

    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  /// Get history of all daily tasks for a patient.
  static Future<List<Map<String, dynamic>>> getTaskHistory(String patientId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/daily-tasks/history/$patientId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final list = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('DailyTasksApi.getTaskHistory error: $e');
      return [];
    }
  }

  /// Get caregiver overview for a patient's daily tasks.
  static Future<Map<String, dynamic>> getCaregiverDailyTaskOverview(
      String patientId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/caregiver/daily-tasks/$patientId'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    }
    throw Exception('Failed to load caregiver task overview (${response.statusCode})');
  }

  /// Review a patient's daily task submission (Approve or Needs Retry).
  static Future<Map<String, dynamic>> reviewTask({
    required String dailyTaskId,
    required String status,
    String? feedback,
  }) async {
    final response = await http
        .patch(
          Uri.parse('$baseUrl/daily-tasks/$dailyTaskId/review'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'status': status,
            'caregiver_feedback': feedback,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    throw Exception(body['detail'] ?? 'Review update failed');
  }
}
