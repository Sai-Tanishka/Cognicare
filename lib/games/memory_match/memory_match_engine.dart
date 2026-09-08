import 'dart:math';

import '../core/adaptive_difficulty.dart';

import '../core/performance_evaluator.dart';

import '../models/difficulty_level.dart';

import '../models/game_result.dart';

/// Represents one card in the Memory Match game.
class MemoryCard {
  final int id;
  final String value;
  bool isFaceUp;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.value,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}

/// Handles the rules and state of the Memory Match game.
///
/// The UI should communicate with this class instead of containing
/// the actual game rules.
class MemoryMatchEngine {
  final Random _random = Random();

  late List<MemoryCard> cards;

  DifficultyLevel difficulty;
  int pairsCount;
  int attempts = 0;
  int correctMatches = 0;
  int incorrectMatches = 0;

  double? previousPerformance;
  DifficultyLevel? previousDifficulty;
  DifficultyLevel? nextDifficulty;

  DateTime? startedAt;

  final List<Duration> responseTimes = [];

  int? firstSelectedIndex;
  int? secondSelectedIndex;

  bool isCheckingPair = false;
  bool isGameComplete = false;

  MemoryMatchEngine({
    this.difficulty = DifficultyLevel.easy,
  }) : pairsCount = _pairsForDifficulty(difficulty) {
    startNewGame();
  }

  static int _pairsForDifficulty(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 2;

      case DifficultyLevel.medium:
        return 4;

      case DifficultyLevel.hard:
        return 6;
    }
  }

  static int pairsForDifficulty(DifficultyLevel difficulty) =>
      _pairsForDifficulty(difficulty);

  String get difficultyName {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'Easy';

      case DifficultyLevel.medium:
        return 'Medium';

      case DifficultyLevel.hard:
        return 'Hard';
    }
  }

  /// Creates a new game.
  void startNewGame() {
    startedAt = DateTime.now();

    attempts = 0;
    correctMatches = 0;
    incorrectMatches = 0;
    responseTimes.clear();

    firstSelectedIndex = null;
    secondSelectedIndex = null;

    isCheckingPair = false;
    isGameComplete = false;

    _createCards();
  }

  /// Reveals all cards during the preview phase.
  void showPreview() {
    for (final card in cards) {
      card.isFaceUp = true;
    }
  }

  /// Hides all cards and starts the actual memory challenge.
  void hidePreview() {
    for (final card in cards) {
      if (!card.isMatched) {
        card.isFaceUp = false;
      }
    }
  }

  /// Starts the next game using the difficulty determined
  /// from the previous performance.
  void startNextGame() {
    // If this is the first game, there is no previous
    // performance to compare against.
    nextDifficulty ??= difficulty;

    // The completed game's performance and difficulty become
    // the previous session's values.
    previousPerformance = performance;
    previousDifficulty = difficulty;

    // Apply the calculated difficulty.
    difficulty = nextDifficulty!;

    // Update the number of pairs.
    pairsCount = _pairsForDifficulty(difficulty);

    // Start a fresh game.
    startNewGame();

    // Clear the previous next-difficulty decision.
    nextDifficulty = null;
  }

  /// Creates pairs of cards and shuffles them.
  void _createCards() {
    const symbols = [
      '🍎',
      '🌸',
      '⭐',
      '🐟',
      '🍀',
      '☀️',
      '🦋',
      '🎵',
      '🌈',
      '🐘',
      '🍉',
      '🚗',
    ];

    if (pairsCount > symbols.length) {
      throw ArgumentError(
        'pairsCount cannot be greater than ${symbols.length}',
      );
    }

    final selectedSymbols = symbols.take(pairsCount).toList();

    final List<MemoryCard> newCards = [];

    int id = 0;

    for (final symbol in selectedSymbols) {
      newCards.add(
        MemoryCard(
          id: id++,
          value: symbol,
        ),
      );

      newCards.add(
        MemoryCard(
          id: id++,
          value: symbol,
        ),
      );
    }

    newCards.shuffle(_random);

    cards = newCards;
  }

  /// Selects a card.
  ///
  /// Returns:
  /// - true if the card was successfully selected.
  /// - false if the selection should be ignored.
  bool selectCard(int index) {
    // Invalid index.
    if (index < 0 || index >= cards.length) {
      return false;
    }

    // Ignore input while checking a pair.
    if (isCheckingPair) {
      return false;
    }

    final card = cards[index];

    // Ignore cards that are already visible or matched.
    if (card.isFaceUp || card.isMatched) {
      return false;
    }

    // First card.
    if (firstSelectedIndex == null) {
      card.isFaceUp = true;
      firstSelectedIndex = index;
      return true;
    }

    // Prevent selecting the same card twice.
    if (firstSelectedIndex == index) {
      return false;
    }

    // Second card.
    card.isFaceUp = true;
    secondSelectedIndex = index;

    attempts++;

    return true;
  }

  /// Records the response time for a completed attempt.
  void recordResponseTime(Duration responseTime) {
    if (responseTime.isNegative) {
      return;
    }

    responseTimes.add(responseTime);
  }

  /// Checks whether the currently selected two cards match.
  ///
  /// Returns true if they match.
  bool checkMatch() {
    if (firstSelectedIndex == null || secondSelectedIndex == null) {
      return false;
    }

    final first = cards[firstSelectedIndex!];
    final second = cards[secondSelectedIndex!];

    if (first.value == second.value) {
      first.isMatched = true;
      second.isMatched = true;

      correctMatches++;

      _clearSelection();

      _checkGameComplete();

      return true;
    }

    incorrectMatches++;

    return false;
  }

  /// Hides the two currently selected cards after an incorrect attempt.
  void hideSelectedCards() {
    if (firstSelectedIndex == null || secondSelectedIndex == null) {
      return;
    }

    cards[firstSelectedIndex!].isFaceUp = false;
    cards[secondSelectedIndex!].isFaceUp = false;

    _clearSelection();
  }

  /// Resets the currently selected cards.
  void _clearSelection() {
    firstSelectedIndex = null;
    secondSelectedIndex = null;
  }

  /// Checks whether all pairs have been matched.
  void _checkGameComplete() {
    if (correctMatches == pairsCount) {
      isGameComplete = true;
    }
  }

  /// Number of cards in the game.
  int get totalCards => cards.length;

  /// Number of pairs remaining.
  int get remainingPairs => pairsCount - correctMatches;

  /// Accuracy based on completed attempts.
  double get accuracy {
    if (attempts == 0) {
      return 0;
    }

    return (correctMatches / attempts) * 100;
  }

  /// Average response time for completed attempts.
  double get averageResponseTime {
    if (responseTimes.isEmpty) {
      return 0;
    }

    final totalMilliseconds = responseTimes.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );

    return totalMilliseconds / responseTimes.length / 1000;
  }

  /// Overall performance score from 0 to 100.
  double get performance {
    return PerformanceEvaluator.calculatePerformance(
      accuracy: accuracy,
      averageResponseTime: averageResponseTime,
      hintsUsed: 0,
      retries: 0,
    );
  }

  /// Current game score.
  ///
  /// This is intentionally simple for the first version.
  int get score {
    final baseScore = correctMatches * 100;
    final mistakePenalty = incorrectMatches * 10;

    final calculatedScore = baseScore - mistakePenalty;

    return max(0, calculatedScore);
  }

  /// Calculates the difficulty for the next game.
  void calculateNextDifficulty() {
    // First game:
    // There is no previous session, so compare the first
    // performance against our baseline of 70.
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

    // Every game after the first:
    // Compare current performance with the previous session,
    // while also considering the difficulty of each session.
    nextDifficulty = AdaptiveDifficulty.getNextDifficulty(
      currentDifficulty: difficulty,
      previousDifficulty: previousDifficulty!,
      currentPerformance: performance,
      previousPerformance: previousPerformance!,
    );
  }

  /// Creates a result object representing the current game.
  GameResult createResult() {
    return GameResult(
      gameId: 'memory_match',
      difficulty: difficulty,
      score: score,
      accuracy: accuracy,
      attempts: attempts,
      correctAnswers: correctMatches,
      incorrectAnswers: incorrectMatches,
      averageResponseTime: averageResponseTime,
      hintsUsed: 0,
      retries: 0,
      nextDifficulty: nextDifficulty,
      sessionStatus: GameSessionStatus.completed,
      startedAt: startedAt ?? DateTime.now(),
      completedAt: DateTime.now(),
    );
  }

  /// Creates a result when the game timer expires.
  ///
  /// The patient's progress up to the timeout is preserved.
  GameResult createTimedOutResult() {
    return GameResult(
      gameId: 'memory_match',
      difficulty: difficulty,
      score: score,
      accuracy: accuracy,
      attempts: attempts,
      correctAnswers: correctMatches,
      incorrectAnswers: incorrectMatches,
      averageResponseTime: averageResponseTime,
      hintsUsed: 0,
      retries: 0,
      nextDifficulty: nextDifficulty,
      sessionStatus: GameSessionStatus.timedOut,
      startedAt: startedAt ?? DateTime.now(),
      completedAt: DateTime.now(),
    );
  }

  /// Changes the difficulty level and starts a new game.
  void setDifficulty(DifficultyLevel newDifficulty) {
    difficulty = newDifficulty;
    pairsCount = _pairsForDifficulty(newDifficulty);

    startNewGame();
  }
}