enum DifficultyLevel {
  easy,
  medium,
  hard,
}

extension DifficultyLevelExtension on DifficultyLevel {
  String get name {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Easy';

      case DifficultyLevel.medium:
        return 'Medium';

      case DifficultyLevel.hard:
        return 'Hard';
    }
  }

  int get value {
    switch (this) {
      case DifficultyLevel.easy:
        return 1;

      case DifficultyLevel.medium:
        return 2;

      case DifficultyLevel.hard:
        return 3;
    }
  }
}