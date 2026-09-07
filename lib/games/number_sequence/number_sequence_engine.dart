import 'dart:math';

import '../core/adaptive_difficulty.dart';
import '../core/performance_evaluator.dart';
import '../models/difficulty_level.dart';
import '../models/game_result.dart';

class NumberSequenceEngine {
  DifficultyLevel difficulty;

  int sequenceLength;

  late List<int> sequence;
  final List<int> enteredSequence = [];

  int attempts = 0;
  int correctAnswers = 0;
  int incorrectAnswers = 0;

  double? previousPerformance;
  DifficultyLevel? previousDifficulty;
  DifficultyLevel? nextDifficulty;

  DateTime? startedAt;
  DateTime? responseStartedAt;

  Duration? responseTime;

  bool isPreviewVisible = true;
  bool isGameComplete = false;

  final Random _random = Random();

  NumberSequenceEngine({
    this.difficulty = DifficultyLevel.easy,
  }) : sequenceLength = _lengthForDifficulty(difficulty) {
    startNewGame();
  }

  static int _lengthForDifficulty(
    DifficultyLevel difficulty,
  ) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 3;

      case DifficultyLevel.medium:
        return 4;

      case DifficultyLevel.hard:
        return 5;

    }
  }

  void startNewGame() {
    sequenceLength = _lengthForDifficulty(difficulty);

    sequence = List<int>.generate(
      sequenceLength,
      (_) => _random.nextInt(10),
    );

    enteredSequence.clear();

    attempts = 0;
    correctAnswers = 0;
    incorrectAnswers = 0;

    responseTime = null;
    responseStartedAt = null;

    isPreviewVisible = true;
    isGameComplete = false;

    startedAt = DateTime.now();
  }

  void showSequence() {
    isPreviewVisible = true;
  }

  void hideSequence() {
    isPreviewVisible = false;
    responseStartedAt = DateTime.now();
  }

  bool addNumber(int number) {
    if (isPreviewVisible || isGameComplete) {
      return false;
    }

    if (enteredSequence.length >= sequenceLength) {
      return false;
    }

    enteredSequence.add(number);

    return true;
  }

  bool removeLastNumber() {
    if (isPreviewVisible || isGameComplete) {
      return false;
    }

    if (enteredSequence.isEmpty) {
      return false;
    }

    enteredSequence.removeLast();

    return true;
  }

  bool get canSubmit {
    return enteredSequence.length == sequenceLength;
  }

  void evaluateSequence() {
    if (isPreviewVisible ||
        isGameComplete ||
        !canSubmit) {
      return;
    }

    attempts++;

    correctAnswers = 0;

    for (int i = 0; i < sequenceLength; i++) {
      if (enteredSequence[i] == sequence[i]) {
        correctAnswers++;
      }
    }

    incorrectAnswers =
        sequenceLength - correctAnswers;

    if (responseStartedAt != null) {
      responseTime = DateTime.now().difference(
        responseStartedAt!,
      );
    }

    isGameComplete = true;
  }

  double get accuracy {
    if (attempts == 0 || sequenceLength == 0) {
      return 0;
    }

    return ((correctAnswers / sequenceLength) * 100)
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
    return correctAnswers * 100;
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
        nextDifficulty =
            AdaptiveDifficulty.getNextDifficulty(
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

    nextDifficulty =
        AdaptiveDifficulty.getNextDifficulty(
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

    sequenceLength =
        _lengthForDifficulty(difficulty);

    startNewGame();

    nextDifficulty = null;
  }

  void setDifficulty(
    DifficultyLevel newDifficulty,
  ) {
    difficulty = newDifficulty;

    sequenceLength =
        _lengthForDifficulty(difficulty);

    startNewGame();

    previousPerformance = null;
    previousDifficulty = null;
    nextDifficulty = null;
  }

  GameResult createResult() {
    return GameResult(
      gameId: 'number_sequence',
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
      gameId: 'number_sequence',
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