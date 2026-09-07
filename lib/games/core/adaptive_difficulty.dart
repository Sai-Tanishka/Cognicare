import '../models/difficulty_level.dart';

/// Decides the next difficulty level based on the user's
/// performance compared with their previous session.
class AdaptiveDifficulty {
  /// Calculates the next difficulty level.
  ///
  /// [currentDifficulty] is the difficulty used in the current session.
  ///
  /// [currentPerformance] is the performance score from the
  /// current session.
  ///
  /// [previousPerformance] is the performance score from the
  /// previous session.
  ///
  /// If performance improves significantly, difficulty increases.
  /// If performance remains similar, difficulty stays the same.
  /// If performance decreases significantly, difficulty decreases.
  static DifficultyLevel getNextDifficulty({
    required DifficultyLevel currentDifficulty,
    required DifficultyLevel previousDifficulty,
    required double currentPerformance,
    required double previousPerformance,
  }) {
    final currentAdjustedPerformance =
        currentPerformance + _difficultyAdjustment(currentDifficulty);

    final previousAdjustedPerformance =
        previousPerformance + _difficultyAdjustment(previousDifficulty);

    final difference =
        currentAdjustedPerformance - previousAdjustedPerformance;

    // Performance improved.
    if (difference >= 5) {
      return _increaseDifficulty(currentDifficulty);
    }

    // Performance decreased.
    if (difference <= -5) {
      return _decreaseDifficulty(currentDifficulty);
    }

    // Performance remained approximately the same.
    return currentDifficulty;
  }

  static double _difficultyAdjustment(
    DifficultyLevel difficulty,
  ) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 0;

      case DifficultyLevel.medium:
        return 5;

      case DifficultyLevel.hard:
        return 10;

      case DifficultyLevel.veryHard:
        return 15;
    }
  }

  /// Increases difficulty by one level.
  static DifficultyLevel _increaseDifficulty(
    DifficultyLevel currentDifficulty,
  ) {
    switch (currentDifficulty) {
      case DifficultyLevel.easy:
        return DifficultyLevel.medium;

      case DifficultyLevel.medium:
        return DifficultyLevel.hard;

      case DifficultyLevel.hard:
        return DifficultyLevel.veryHard;

      case DifficultyLevel.veryHard:
        return DifficultyLevel.veryHard;
    }
  }

  /// Decreases difficulty by one level.
  static DifficultyLevel _decreaseDifficulty(
    DifficultyLevel currentDifficulty,
  ) {
    switch (currentDifficulty) {
      case DifficultyLevel.easy:
        return DifficultyLevel.easy;

      case DifficultyLevel.medium:
        return DifficultyLevel.easy;

      case DifficultyLevel.hard:
        return DifficultyLevel.medium;

      case DifficultyLevel.veryHard:
        return DifficultyLevel.hard;
    }
  }
}