import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../database/local_database.dart';
import '../games/models/game_result.dart';
import '../services/sync_service.dart';
import '../services/auth_storage.dart';
import '../services/progress_events.dart';

class GameRepository {
  static const _gameIds = {
    'memory_match': '6a2e63ce-3e84-4583-90d1-4373ddde79fb',
    'pattern_recall': '7e99bd7e-d0cb-480e-a9db-8f548b78692d',
    'odd_one_out': '389ae015-4d44-425c-a285-c360ab001983',
    'number_sequence': '310f6d9d-bc51-44a8-b282-6722742bad58',
  };

  static Future<void> saveGameResult(GameResult result) async {
    final patientId = await AuthStorage.getPatientId();
    if (patientId == null) {
      throw StateError('Please log in before saving a game result.');
    }

    final gameId = _gameIds[result.gameId];
    if (gameId == null) {
      throw StateError('Unsupported game: ${result.gameId}.');
    }

    // 1. Always save locally first.
    await LocalDatabase.saveGameAttempt(
      patientId: patientId,
      sessionId: const Uuid().v4(),
      gameId: gameId,
      difficulty: result.difficultyValue,
      score: result.score.toDouble(),
      accuracy: result.accuracy,
      attempts: result.attempts,
      correctAnswers: result.correctAnswers,
      incorrectAnswers: result.incorrectAnswers,
      averageResponseTime: result.averageResponseTime,
      hintsUsed: result.hintsUsed,
      retries: result.retries,
      startedAt: result.startedAt.toIso8601String(),
      completedAt: result.completedAt.toIso8601String(),

      // Initial local value.
      // SyncService replaces this with the backend-calculated value.
      nextDifficulty:
          result.nextDifficultyValue ?? result.difficultyValue,
    );

    debugPrint(
      'REPOSITORY: $gameId saved to local database.',
    );

    // Notify UI immediately (zero latency)
    ProgressEvents.instance.notifyGameCompleted();

    // 2. Try to sync immediately.
    // If there is no internet/backend connection,
    // the event remains Pending in the local sync queue.
    try {
      await SyncService.syncPendingEvents();
    } catch (e) {
      debugPrint('REPOSITORY: Immediate sync attempt failed: $e');
    }

    // Notify UI again after server sync finishes
    ProgressEvents.instance.notifyGameCompleted();
  }
}
