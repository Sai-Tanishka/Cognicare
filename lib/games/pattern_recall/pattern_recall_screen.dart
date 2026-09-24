import 'dart:async';

import 'package:flutter/material.dart';

import '../../repositories/game_repository.dart';
import '../../widgets/language_selector.dart';

import '../core/timer_manager.dart';
import '../models/difficulty_level.dart';
import '../models/game_result.dart';
import 'pattern_recall_engine.dart';
import '../services/difficulty_storage.dart';

class PatternRecallScreen extends StatefulWidget {
  const PatternRecallScreen({
    super.key,
  });

  @override
  State<PatternRecallScreen> createState() =>
      _PatternRecallScreenState();
}

class _PatternRecallScreenState
    extends State<PatternRecallScreen> {
  late PatternRecallEngine _engine;
  late TimerManager _timerManager;

  Timer? _previewTimer;

  bool _isPreviewing = true;
  int _previewSecondsRemaining = 5;

  @override
  void initState() {
    super.initState();

    _engine = PatternRecallEngine(
      difficulty: DifficultyLevel.easy,
    );

    _timerManager = TimerManager(
      totalSeconds: 60,
    );

    _loadDifficultyAndStart();
  }

  Future<void> _loadDifficultyAndStart() async {
    _engine.setDifficulty(await DifficultyStorage.load('pattern_recall'));
    if (mounted) _startPreview();
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    super.dispose();
  }

  void _startPreview() {
    _engine.showPattern();

    _previewSecondsRemaining = 5;
    _isPreviewing = true;

    setState(() {});

    _previewTimer?.cancel();

    _previewTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          _previewSecondsRemaining--;
        });

        if (_previewSecondsRemaining <= 0) {
          timer.cancel();
          _endPreview();
        }
      },
    );
  }

  void _endPreview() {
    _previewTimer?.cancel();

    _engine.hidePattern();

    setState(() {
      _isPreviewing = false;
      _previewSecondsRemaining = 0;
    });

    _startTimer();
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

  void _onCellTap(int index) {
    if (_isPreviewing) {
      return;
    }

    if (_timerManager.remainingSeconds <= 0) {
      return;
    }

    if (_engine.isGameComplete) {
      return;
    }

    final changed = _engine.toggleCell(index);

    if (!changed) {
      return;
    }

    setState(() {});
  }

  Future<void> _checkPattern() async {
    if (_isPreviewing) {
      return;
    }

    if (_engine.isGameComplete) {
      return;
    }

    if (_engine.selectedCells.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Select the cells you remember first.',
          ),
        ),
      );

      return;
    }

    _engine.evaluatePattern();

    _timerManager.pause();

    _engine.calculateNextDifficulty();

    final result = _engine.createResult();

    await DifficultyStorage.save(
      result.gameId,
      result.nextDifficulty ?? result.difficulty,
    );

    await _saveResult(result);

    if (!mounted) {
      return;
    }

    setState(() {});

    _showGameCompletedDialog(result);
  }

  Future<void> _saveResult(GameResult result) async {
    try {
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

    _previewTimer?.cancel();

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
    _previewTimer?.cancel();

    _timerManager.reset();

    _engine.startNewGame();

    _startPreview();
  }

  void _startAdaptiveNextGame() {
    _timerManager.reset();

    _engine.startNextGame();

    _startPreview();
  }

  void _showGameCompletedDialog(GameResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const TrText(
            'Pattern Complete!',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TrText(
                'Score: ${result.score}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TrText(
                'Correct Cells: '
                '${result.correctAnswers}/${_engine.patternLength}',
              ),

              TrText(
                'Incorrect Cells: '
                '${result.incorrectAnswers}',
              ),

              TrText(
                'Accuracy: '
                '${result.accuracy.toStringAsFixed(0)}%',
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

              TrText('Completed at: ${result.difficulty.name}'),
              TrText(
                'Continue at: '
                '${result.nextDifficulty?.name ?? result.difficulty.name}',
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
                final navigator = Navigator.of(context);

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
                'Correct Cells: '
                '${result.correctAnswers}/${_engine.patternLength}',
              ),

              TrText(
                'Incorrect Cells: '
                '${result.incorrectAnswers}',
              ),

              TrText(
                'Accuracy: '
                '${result.accuracy.toStringAsFixed(0)}%',
              ),

              TrText(
                'Response Time: '
                '${result.averageResponseTime.toStringAsFixed(1)}s',
              ),

              const SizedBox(height: 8),

              TrText(
                'Next Difficulty: '
                '${result.nextDifficulty?.name ?? result.difficulty.name}',
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
                final navigator = Navigator.of(context);

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

  Widget _infoBox({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22,
          ),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TrText(
                label,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
              TrText(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final totalCells =
        _engine.gridSize * _engine.gridSize;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _engine.gridSize,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final isPatternCell =
            _engine.pattern.contains(index);

        final isSelected =
            _engine.selectedCells.contains(index);

        final showPattern =
            _isPreviewing && isPatternCell;

        return GestureDetector(
          onTap: () => _onCellTap(index),
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 200,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: showPattern
                  ? Colors.blue
                  : isSelected
                      ? Colors.green
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
            child: showPattern
                ? const Icon(
                    Icons.star_rounded,
                    size: 36,
                    color: Colors.white,
                  )
                : isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 32,
                      )
                    : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TrText('Pattern Recall'),
        actions: const [
          LanguageSelectorButton(compact: true),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
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
                    value: _isPreviewing
                        ? 'Preview'
                        : '${_timerManager.remainingSeconds}s',
                  ),

                  _infoBox(
                    icon: Icons.grid_4x4_rounded,
                    label: 'Pattern',
                    value: '${_engine.patternLength}',
                  ),

                  _infoBox(
                    icon: Icons.touch_app_rounded,
                    label: 'Selected',
                    value: '${_engine.selectedCells.length}',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              if (_isPreviewing) ...[
                const TrText(
                  'Remember the pattern',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                TrText(
                  'Study the highlighted cells.',
                  style: TextStyle(
                    fontSize: 17,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                TrText(
                  'Hiding in $_previewSecondsRemaining seconds',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else ...[
                const TrText(
                  'Recreate the pattern',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                TrText(
                  'Tap the cells you remember, then check your answer.',
                  style: TextStyle(
                    fontSize: 17,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 24),

              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 450,
                      maxHeight: 450,
                    ),
                    child: _buildGrid(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (_isPreviewing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _endPreview,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                      ),
                    ),
                    child: const TrText(
                      "I'm Ready",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _checkPattern,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                      ),
                    ),
                    child: const TrText(
                      'Check Pattern',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}