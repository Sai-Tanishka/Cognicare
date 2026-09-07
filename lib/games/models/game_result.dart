import 'difficulty_level.dart';

enum GameSessionStatus {
  completed,
  timedOut,
  abandoned,
}

/// Represents the result of one completed or timed-out game.
class GameResult {
  final String gameId;

  final DifficultyLevel difficulty;

  final int score;
  final double accuracy;

  final int attempts;
  final int correctAnswers;
  final int incorrectAnswers;

  final double averageResponseTime;

  final int hintsUsed;
  final int retries;

  final DifficultyLevel? nextDifficulty;

  final GameSessionStatus sessionStatus;

  final DateTime startedAt;
  final DateTime completedAt;

  GameResult({
    required this.gameId,
    required this.difficulty,
    required this.score,
    required this.accuracy,
    required this.attempts,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.averageResponseTime,
    required this.hintsUsed,
    required this.retries,
    required this.nextDifficulty,
    required this.sessionStatus,
    required this.startedAt,
    required this.completedAt,
  });

  /// Converts the difficulty level into the integer
  /// expected by the database.
  int get difficultyValue {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 1;

      case DifficultyLevel.medium:
        return 2;

      case DifficultyLevel.hard:
        return 3;

      case DifficultyLevel.veryHard:
        return 4;
    }
  }

  /// Converts the next difficulty into the integer
  /// expected by the database.
  int? get nextDifficultyValue {
    if (nextDifficulty == null) {
      return null;
    }

    switch (nextDifficulty!) {
      case DifficultyLevel.easy:
        return 1;

      case DifficultyLevel.medium:
        return 2;

      case DifficultyLevel.hard:
        return 3;

      case DifficultyLevel.veryHard:
        return 4;
    }
  }
}