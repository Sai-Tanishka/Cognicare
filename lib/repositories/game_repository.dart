import 'package:flutter/foundation.dart';

import '../database/local_database.dart';
import '../games/models/game_result.dart';
import '../services/sync_service.dart';

class GameRepository {
  // Temporary prototype patient/session context.
  // Replace these with real logged-in patient/session IDs later.
  static const String patientId =
      'dc881c50-c49b-4545-9ef6-c424ac2785d0';

  static const String sessionId =
      'c524d076-bc3a-4a5c-ad2a-94d62a5eff78';

  static Future<void> saveGameResult(GameResult result) async {
    // 1. Always save locally first.
    await LocalDatabase.saveGameAttempt(
      patientId: patientId,
      sessionId: sessionId,
      gameId: result.gameId,
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
      'REPOSITORY: ${result.gameId} saved to local database.',
    );

    // 2. Try to sync immediately.
    // If there is no internet/backend connection,
    // the event remains Pending in the local sync queue.
    await SyncService.syncPendingEvents();
  }
}