import 'package:flutter/material.dart';

import '../core/timer_manager.dart';
import '../models/difficulty_level.dart';
import '../models/game_result.dart';
import 'odd_one_out_engine.dart';

class OddOneOutScreen extends StatefulWidget {
  const OddOneOutScreen({
    super.key,
  });

  @override
  State<OddOneOutScreen> createState() =>
      _OddOneOutScreenState();
}

class _OddOneOutScreenState extends State<OddOneOutScreen> {
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

    _startTimer();
  }

  @override
  void dispose() {
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

    setState(() {});

    _showGameCompletedDialog(result);
  }

  void _handleTimeUp() {
    if (!mounted || _engine.isGameComplete) {
      return;
    }

    _engine.calculateNextDifficulty();

    final result = _engine.createTimedOutResult();

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
          title: Text(
            wasCorrect
                ? 'Well Done! 🎉'
                : 'Good Try!',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                wasCorrect
                    ? 'You found the odd one out!'
                    : 'Keep practicing and try again.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Text(
                'Score: ${result.score}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Accuracy: '
                '${result.accuracy.toStringAsFixed(0)}%',
              ),

              Text(
                'Attempts: ${result.attempts}',
              ),

              Text(
                'Response Time: '
                '${result.averageResponseTime.toStringAsFixed(1)}s',
              ),

              const SizedBox(height: 8),

              Text(
                'Performance: '
                '${_engine.performance.toStringAsFixed(0)}/100',
              ),

              Text(
                'Next Difficulty: '
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
              child: const Text('Play Again'),
            ),

            TextButton(
              onPressed: () {
                final navigator = Navigator.of(context);

                navigator.pop();

                if (navigator.canPop()) {
                  navigator.pop();
                }
              },
              child: const Text('Done'),
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
          title: const Text(
            'Time Up!',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Good effort! Your time has ended.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Text(
                'Score: ${result.score}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Accuracy: '
                '${result.accuracy.toStringAsFixed(0)}%',
              ),

              Text(
                'Attempts: ${result.attempts}',
              ),

              Text(
                'Response Time: '
                '${result.averageResponseTime.toStringAsFixed(1)}s',
              ),

              const SizedBox(height: 8),

              Text(
                'Next Difficulty: '
                '${_difficultyName(result.nextDifficulty ?? result.difficulty)}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _restartGame();
              },
              child: const Text('Try Again'),
            ),

            TextButton(
              onPressed: () {
                final navigator = Navigator.of(context);

                navigator.pop();

                if (navigator.canPop()) {
                  navigator.pop();
                }
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  String _difficultyName(DifficultyLevel difficulty) {
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
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

  Widget _buildGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _engine.totalItems,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _engine.gridSize,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final isSelected =
            _engine.selectedIndex == index;

        final isOdd =
            index == _engine.oddIndex;

        final symbol = isOdd
          ? _engine.oddSymbol
          : _engine.normalSymbol;

        return GestureDetector(
          onTap: () => _onItemTap(index),
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 200,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: isSelected
                  ? (isOdd
                      ? Colors.green.shade300
                      : Colors.red.shade300)
                  : Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                symbol,
                style: TextStyle(
                  fontSize: _engine.gridSize >= 5
                      ? 38
                      : 50,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Odd One Out'),
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

              const Text(
                'Find the odd one out',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Look carefully and tap the item '
                'that is different.',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 650,
                  ),
                  child: _buildGrid(),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                  ),
                  child: const Text(
                    'Take your time and look carefully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}