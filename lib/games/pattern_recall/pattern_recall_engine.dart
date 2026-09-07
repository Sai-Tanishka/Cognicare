import 'dart:math';

import '../core/adaptive_difficulty.dart';
import '../core/performance_evaluator.dart';
import '../models/difficulty_level.dart';
import '../models/game_result.dart';

class PatternRecallEngine {
  DifficultyLevel difficulty;

  int gridSize;
  int patternLength;

  int attempts = 0;
  int correctAnswers = 0;
  int incorrectAnswers = 0;

  double? previousPerformance;
  DifficultyLevel? previousDifficulty;
  DifficultyLevel? nextDifficulty;

  DateTime? startedAt;
  DateTime? responseStartedAt;

  Duration? responseTime;

  final Random _random = Random();

  late List<int> pattern;

  final Set<int> selectedCells = {};

  bool isPreviewVisible = true;
  bool isGameComplete = false;

  PatternRecallEngine({
    this.difficulty = DifficultyLevel.easy,
  })  : gridSize = _gridSizeForDifficulty(difficulty),
        patternLength = _patternLengthForDifficulty(difficulty) {
    startNewGame();
  }

  static int _gridSizeForDifficulty(
    DifficultyLevel difficulty,
  ) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 2;

      case DifficultyLevel.medium:
        return 3;

      case DifficultyLevel.hard:
        return 4;
    }
  }

  static int _patternLengthForDifficulty(
    DifficultyLevel difficulty,
  ) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 1;

      case DifficultyLevel.medium:
        return 3;

      case DifficultyLevel.hard:
        return 5;
    }
  }

  void startNewGame() {
    attempts = 0;
    correctAnswers = 0;
    incorrectAnswers = 0;

    responseTime = null;
    responseStartedAt = null;

    selectedCells.clear();

    isPreviewVisible = true;
    isGameComplete = false;

    startedAt = DateTime.now();

    _generatePattern();
  }

  void _generatePattern() {
    final totalCells = gridSize * gridSize;

    final availableCells = List<int>.generate(
      totalCells,
      (index) => index,
    );

    availableCells.shuffle(_random);

    pattern = availableCells.take(patternLength).toList();
  }

  void showPattern() {
    isPreviewVisible = true;
  }

  void hidePattern() {
    isPreviewVisible = false;
    responseStartedAt = DateTime.now();
  }

  bool toggleCell(int index) {
    if (isPreviewVisible || isGameComplete) {
      return false;
    }

    if (selectedCells.contains(index)) {
      selectedCells.remove(index);
    } else {
      selectedCells.add(index);
    }

    return true;
  }

  void evaluatePattern() {
    if (isPreviewVisible || isGameComplete) {
      return;
    }

    if (selectedCells.isEmpty) {
      return;
    }

    attempts++;

    correctAnswers = selectedCells
        .where((index) => pattern.contains(index))
        .length;

    incorrectAnswers = selectedCells
        .where((index) => !pattern.contains(index))
        .length;

    if (responseStartedAt != null) {
      responseTime = DateTime.now().difference(
        responseStartedAt!,
      );
    }

    isGameComplete = true;
  }

  double get accuracy {
    if (attempts == 0 || patternLength == 0) {
      return 0;
    }

    return ((correctAnswers / patternLength) * 100)
        .clamp(0, 100)
        .toDouble();
  }

  double get averageResponseTime {
    if (responseTime == null) {
      return 0;
    }

    return responseTime!.inMilliseconds / 1000;
  }

  int get score {
    final calculatedScore =
        (correctAnswers * 100) - (incorrectAnswers * 25);

    return max(0, calculatedScore);
  }

  double get performance {
    return PerformanceEvaluator.calculatePerformance(
      accuracy: accuracy,
      averageResponseTime: averageResponseTime,
      hintsUsed: 0,
      retries: 0,
    );
  }

  void calculateNextDifficulty() {
    if (previousPerformance == null) {
      if (performance >= 80) {
        nextDifficulty = AdaptiveDifficulty.getNextDifficulty(
          currentDifficulty: difficulty,
          previousDifficulty: difficulty,
          currentPerformance: performance,
          previousPerformance: 70,
        );
      } else {
        nextDifficulty = difficulty;
      }

      return;
    }

    nextDifficulty = AdaptiveDifficulty.getNextDifficulty(
      currentDifficulty: difficulty,
      previousDifficulty: previousDifficulty!,
      currentPerformance: performance,
      previousPerformance: previousPerformance!,
    );
  }

  void startNextGame() {
    nextDifficulty ??= difficulty;

    previousPerformance = performance;
    previousDifficulty = difficulty;

    difficulty = nextDifficulty!;

    gridSize = _gridSizeForDifficulty(difficulty);
    patternLength = _patternLengthForDifficulty(difficulty);

    startNewGame();

    nextDifficulty = null;
  }

  void setDifficulty(DifficultyLevel newDifficulty) {
    difficulty = newDifficulty;

    gridSize = _gridSizeForDifficulty(difficulty);
    patternLength = _patternLengthForDifficulty(difficulty);

    startNewGame();

    previousPerformance = null;
    previousDifficulty = null;
    nextDifficulty = null;
  }

  GameResult createResult() {
    return GameResult(
      gameId: 'pattern_recall',
      difficulty: difficulty,
      score: score,
      accuracy: accuracy,
      attempts: attempts,
      correctAnswers: correctAnswers,
      incorrectAnswers: incorrectAnswers,
      averageResponseTime: averageResponseTime,
      hintsUsed: 0,
      retries: 0,
      nextDifficulty: nextDifficulty,
      sessionStatus: GameSessionStatus.completed,
      startedAt: startedAt ?? DateTime.now(),
      completedAt: DateTime.now(),
    );
  }

  GameResult createTimedOutResult() {
    return GameResult(
      gameId: 'pattern_recall',
      difficulty: difficulty,
      score: score,
      accuracy: accuracy,
      attempts: attempts,
      correctAnswers: correctAnswers,
      incorrectAnswers: incorrectAnswers,
      averageResponseTime: averageResponseTime,
      hintsUsed: 0,
      retries: 0,
      nextDifficulty: nextDifficulty,
      sessionStatus: GameSessionStatus.timedOut,
      startedAt: startedAt ?? DateTime.now(),
      completedAt: DateTime.now(),
    );
  }
}