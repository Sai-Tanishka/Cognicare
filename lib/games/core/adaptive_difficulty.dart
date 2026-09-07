import '../models/difficulty_level.dart';

class AdaptiveDifficulty {
  static DifficultyLevel getNextDifficulty({
    required DifficultyLevel currentDifficulty,
    required DifficultyLevel previousDifficulty,
    required double currentPerformance,
    required double previousPerformance,
  }) {
    final currentAdjustedPerformance =
        currentPerformance + _difficultyAdjustment(
          currentDifficulty,
        );

    final previousAdjustedPerformance =
        previousPerformance + _difficultyAdjustment(
          previousDifficulty,
        );

    final difference =
        currentAdjustedPerformance -
        previousAdjustedPerformance;

    if (difference >= 5) {
      return _increaseDifficulty(currentDifficulty);
    }

    if (difference <= -5) {
      return _decreaseDifficulty(currentDifficulty);
    }

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
    }
  }

  static DifficultyLevel _increaseDifficulty(
    DifficultyLevel difficulty,
  ) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return DifficultyLevel.medium;

      case DifficultyLevel.medium:
        return DifficultyLevel.hard;

      case DifficultyLevel.hard:
        return DifficultyLevel.hard;
    }
  }

  static DifficultyLevel _decreaseDifficulty(
    DifficultyLevel difficulty,
  ) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return DifficultyLevel.easy;

      case DifficultyLevel.medium:
        return DifficultyLevel.easy;

      case DifficultyLevel.hard:
        return DifficultyLevel.medium;
    }
  }
}