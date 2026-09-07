import 'dart:math';

import '../core/adaptive_difficulty.dart';
import '../core/performance_evaluator.dart';
import '../models/difficulty_level.dart';
import '../models/game_result.dart';

class OddOneOutEngine {
  DifficultyLevel difficulty;

  int gridSize;
  int totalItems;

  int oddIndex = 0;
  int? selectedIndex;

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

  bool isGameComplete = false;

  // Symbols that can be used for the normal item and its odd counterpart.
  //
  // The order is:
  // [normal symbol, odd symbol]
  final List<List<String>> _symbolPairs = [
    ['🍎', '🍊'],
    ['🐶', '🐱'],
    ['🌸', '🌼'],
    ['🚗', '🚌'],
    ['⭐', '✨'],
    ['❤️', '💛'],
    ['🔵', '🟢'],
    ['☀️', '🌙'],
    ['🍓', '🍒'],
    ['🥕', '🌽'],
    ['🐼', '🐻'],
    ['⚽', '🏀'],
  ];

  String normalSymbol = '🍎';
  String oddSymbol = '🍊';

  OddOneOutEngine({
    this.difficulty = DifficultyLevel.easy,
  })  : gridSize = _gridSizeForDifficulty(difficulty),
        totalItems = _gridSizeForDifficulty(difficulty) *
            _gridSizeForDifficulty(difficulty) {
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

  void startNewGame() {
    gridSize = _gridSizeForDifficulty(difficulty);
    totalItems = gridSize * gridSize;

    oddIndex = _random.nextInt(totalItems);

    _chooseSymbolPair();

    selectedIndex = null;

    attempts = 0;
    correctAnswers = 0;
    incorrectAnswers = 0;

    responseTime = null;

    startedAt = DateTime.now();
    responseStartedAt = DateTime.now();

    isGameComplete = false;
  }

  void _chooseSymbolPair() {
    final pair = _symbolPairs[
      _random.nextInt(_symbolPairs.length)
    ];

    normalSymbol = pair[0];
    oddSymbol = pair[1];
  }

  void selectItem(int index) {
    if (isGameComplete) {
      return;
    }

    selectedIndex = index;

    attempts++;

    if (index == oddIndex) {
      correctAnswers = 1;
      incorrectAnswers = 0;
    } else {
      correctAnswers = 0;
      incorrectAnswers = 1;
    }

    if (responseStartedAt != null) {
      responseTime = DateTime.now().difference(
        responseStartedAt!,
      );
    }

    isGameComplete = true;
  }

  double get accuracy {
    if (attempts == 0) {
      return 0;
    }

    return (correctAnswers / attempts) * 100;
  }

  double get averageResponseTime {
    if (responseTime == null) {
      return 0;
    }

    return responseTime!.inMilliseconds / 1000;
  }

  int get score {
    if (correctAnswers == 1) {
      return 100;
    }

    return 0;
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

    startNewGame();

    nextDifficulty = null;
  }

  void setDifficulty(DifficultyLevel newDifficulty) {
    difficulty = newDifficulty;

    startNewGame();

    previousPerformance = null;
    previousDifficulty = null;
    nextDifficulty = null;
  }

  GameResult createResult() {
    return GameResult(
      gameId: 'odd_one_out',
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
      gameId: 'odd_one_out',
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