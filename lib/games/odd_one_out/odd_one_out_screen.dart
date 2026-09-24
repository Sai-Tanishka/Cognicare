import 'package:flutter/material.dart';

import '../../repositories/game_repository.dart';
import '../../widgets/language_selector.dart';

import '../core/timer_manager.dart';
import '../models/difficulty_level.dart';
import '../models/game_result.dart';
import 'odd_one_out_engine.dart';
import '../services/difficulty_storage.dart';

class OddOneOutScreen extends StatefulWidget {
  const OddOneOutScreen({
    super.key,
  });

  @override
  State<OddOneOutScreen> createState() =>
      _OddOneOutScreenState();
}

class _OddOneOutScreenState
    extends State<OddOneOutScreen> {
  late OddOneOutEngine _engine;
  late TimerManager _timerManager;

  @override
  void initState() {
    super.initState();

    _engine = OddOneOutEngine(
      difficulty: DifficultyLevel.easy,
    );

    _timerManager = TimerManager(
      totalSeconds: 60,
    );

    _loadDifficultyAndStart();
  }

  Future<void> _loadDifficultyAndStart() async {
    _engine.setDifficulty(await DifficultyStorage.load('odd_one_out'));
    if (mounted) _startTimer();
  }

  @override
  void dispose() {
    _timerManager.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timerManager.start(
      onTick: (_) {
        if (!mounted) {
          return;
        }

        setState(() {});
      },
      onFinished: _handleTimeUp,
    );
  }

  void _onItemTap(int index) {
    if (_engine.isGameComplete) {
      return;
    }

    if (_timerManager.remainingSeconds <= 0) {
      return;
    }

    _engine.selectItem(index);

    _timerManager.pause();

    _engine.calculateNextDifficulty();

    final result = _engine.createResult();

    _saveResultAndShowCompleted(result);
  }

  Future<void> _saveResultAndShowCompleted(
    GameResult result,
  ) async {
    await _saveResult(result);

    if (!mounted) {
      return;
    }

    setState(() {});

    _showGameCompletedDialog(result);
  }

  Future<void> _saveResult(GameResult result) async {
    try {
      await DifficultyStorage.save(
        result.gameId,
        result.nextDifficulty ?? result.difficulty,
      );

      await GameRepository.saveGameResult(result);

      debugPrint(
        'GAME: ${result.gameId} result saved locally.',
      );
    } catch (e) {
      debugPrint(
        'GAME: Failed to save ${result.gameId} result locally: $e',
      );
    }
  }

  Future<void> _handleTimeUp() async {
    if (!mounted || _engine.isGameComplete) {
      return;
    }

    _engine.calculateNextDifficulty();

    final result = _engine.createTimedOutResult();

    await _saveResult(result);

    if (!mounted) {
      return;
    }

    setState(() {});

    _showTimeUpDialog(result);
  }

  void _restartGame() {
    _timerManager.reset();

    _engine.startNewGame();

    setState(() {});

    _startTimer();
  }

  void _startAdaptiveNextGame() {
    _timerManager.reset();

    _engine.startNextGame();

    setState(() {});

    _startTimer();
  }

  void _showGameCompletedDialog(GameResult result) {
    final bool wasCorrect =
        result.correctAnswers > 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: TrText(
            wasCorrect
                ? 'Well Done! 🎉'
                : 'Good Try!',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TrText(
                wasCorrect
                    ? 'You found the odd one out!'
                    : 'Keep practicing and try again.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              TrText(
                'Score: ${result.score}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TrText(
                'Accuracy: '
                '${result.accuracy.toStringAsFixed(0)}%',
              ),

              TrText(
                'Attempts: ${result.attempts}',
              ),

              TrText(
                'Response Time: '
                '${result.averageResponseTime.toStringAsFixed(1)}s',
              ),

              const SizedBox(height: 8),

              TrText(
                'Performance: '
                '${_engine.performance.toStringAsFixed(0)}/100',
              ),

              TrText('Completed at: ${_difficultyName(result.difficulty)}'),
              TrText(
                'Continue at: '
                '${_difficultyName(result.nextDifficulty ?? result.difficulty)}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startAdaptiveNextGame();
              },
              child: const TrText('Play Again'),
            ),

            TextButton(
              onPressed: () {
                final navigator =
                    Navigator.of(context);

                navigator.pop();

                if (navigator.canPop()) {
                  navigator.pop();
                }
              },
              child: const TrText('Done'),
            ),
          ],
        );
      },
    );
  }

  void _showTimeUpDialog(GameResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const TrText(
            'Time Up!',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TrText(
                'Good effort! Your time has ended.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              TrText(
                'Score: ${result.score}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TrText(
                'Accuracy: '
                '${result.accuracy.toStringAsFixed(0)}%',
              ),

              TrText(
                'Attempts: ${result.attempts}',
              ),

              TrText(
                'Response Time: '
                '${result.averageResponseTime.toStringAsFixed(1)}s',
              ),

              const SizedBox(height: 8),

              TrText(
                'Next Difficulty: '
                '${_difficultyName(
                  result.nextDifficulty ??
                      result.difficulty,
                )}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _restartGame();
              },
              child: const TrText('Try Again'),
            ),

            TextButton(
              onPressed: () {
                final navigator =
                    Navigator.of(context);

                navigator.pop();

                if (navigator.canPop()) {
                  navigator.pop();
                }
              },
              child: const TrText('Done'),
            ),
          ],
        );
      },
    );
  }

  String _difficultyName(
    DifficultyLevel difficulty,
  ) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'Easy';

      case DifficultyLevel.medium:
        return 'Medium';

      case DifficultyLevel.hard:
        return 'Hard';
    }
  }

  Widget _infoBox({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 25,
          ),
          const SizedBox(height: 4),
          TrText(
            label,
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          TrText(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemButton(int index) {
    final bool isOdd = index == _engine.oddIndex;

    return SizedBox(
      height: 90,
      child: ElevatedButton(
        onPressed: () => _onItemTap(index),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          isOdd
              ? _engine.oddSymbol
              : _engine.normalSymbol,
          style: const TextStyle(
            fontSize: 36,
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _engine.gridSize,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.2,
      ),
      itemCount: _engine.totalItems,
      itemBuilder: (context, index) {
        return _itemButton(index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TrText('Odd One Out'),
        actions: const [
          LanguageSelectorButton(compact: true),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [
                  _infoBox(
                    icon: Icons.timer_rounded,
                    label: 'Time',
                    value:
                        '${_timerManager.remainingSeconds}s',
                  ),
                  _infoBox(
                    icon: Icons.grid_view_rounded,
                    label: 'Grid',
                    value:
                        '${_engine.gridSize} × ${_engine.gridSize}',
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const TrText(
                'Find the Odd One Out',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              const TrText(
                'Look carefully and choose the item '
                'that is different from the others.',
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              _buildGrid(),

              const SizedBox(height: 24),

              TrText(
                'Performance: '
                '${_engine.performance.toStringAsFixed(0)}/100',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}