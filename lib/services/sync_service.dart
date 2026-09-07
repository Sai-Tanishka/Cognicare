import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../database/local_database.dart';

class SyncService {
 static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<void> syncPendingEvents() async {
    final hasConnection = await _hasInternetConnection();

    if (!hasConnection) {
      debugPrint('SYNC: No internet connection. Sync skipped.');
      return;
    }

    final events = await LocalDatabase.getPendingSyncEvents();

    if (events.isEmpty) {
      debugPrint('SYNC: No pending events.');
      return;
    }

    debugPrint('SYNC: Found ${events.length} pending event(s).');

    for (final event in events) {
      await _syncEvent(event);
    }
  }

  static Future<bool> _hasInternetConnection() async {
    final connectivityResults =
        await Connectivity().checkConnectivity();

    return connectivityResults.any(
      (result) => result != ConnectivityResult.none,
    );
  }

  static Future<void> _syncEvent(
    Map<String, dynamic> event,
  ) async {
    final eventId = event['event_id'] as String;
    final entityType = event['entity_type'] as String;
    final entityId = event['entity_id'] as String;

    try {
      if (entityType != 'game_attempt') {
        await LocalDatabase.markSyncEventFailed(
          eventId,
          'Unsupported entity type: $entityType',
        );
        return;
      }

      final gameAttempt =
          await LocalDatabase.getGameAttemptById(entityId);

      if (gameAttempt == null) {
        await LocalDatabase.markSyncEventFailed(
          eventId,
          'Game attempt not found locally.',
        );
        return;
      }

      final requestBody = {
        'event_id': eventId,
        'patient_id': gameAttempt['patient_id'],
        'session_id': gameAttempt['session_id'],
        'game_id': gameAttempt['game_id'],
        'difficulty': gameAttempt['difficulty'],
        'score': (gameAttempt['score'] as num?)?.round(),
        'accuracy': gameAttempt['accuracy'],
        'attempts': gameAttempt['attempts'],
        'correct_answers': gameAttempt['correct_answers'],
        'incorrect_answers': gameAttempt['incorrect_answers'],
        'average_response_time':
            gameAttempt['average_response_time'],
        'hints_used': gameAttempt['hints_used'],
        'retries': gameAttempt['retries'],
        'started_at': gameAttempt['started_at'],
        'completed_at': gameAttempt['completed_at'],
      };

      debugPrint(
        'SYNC: Sending game attempt $entityId to backend...',
      );

      final response = await http
          .post(
            Uri.parse('$baseUrl/game-attempts/'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData =
            jsonDecode(response.body) as Map<String, dynamic>;

        final nextDifficulty =
            responseData['next_difficulty'];

        if (nextDifficulty is int) {
          await LocalDatabase.updateNextDifficulty(
            entityId,
            nextDifficulty,
          );
        }

        await LocalDatabase.markSyncEventSynced(eventId);

        debugPrint(
          'SYNC: Event $eventId synced successfully!',
        );

        debugPrint(
          'SYNC: Backend next difficulty = $nextDifficulty',
        );
      } else {
        await LocalDatabase.markSyncEventFailed(
          eventId,
          'Server returned ${response.statusCode}: '
              '${response.body}',
        );

        debugPrint(
          'SYNC: Event $eventId failed with '
          'status ${response.statusCode}.',
        );
      }
    } catch (e) {
      await LocalDatabase.markSyncEventFailed(
        eventId,
        e.toString(),
      );

      debugPrint(
        'SYNC: Event $eventId failed: $e',
      );
    }
  }
}