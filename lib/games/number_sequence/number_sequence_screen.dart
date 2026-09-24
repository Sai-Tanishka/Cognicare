import 'dart:async';

import 'package:flutter/material.dart';
import '../../repositories/game_repository.dart';
import '../../widgets/language_selector.dart';

import '../core/timer_manager.dart';
import '../models/difficulty_level.dart';
import '../models/game_result.dart';
import 'number_sequence_engine.dart';
import '../services/difficulty_storage.dart';

class NumberSequenceScreen extends StatefulWidget {
  const NumberSequenceScreen({
    super.key,
  });

  @override
  State<NumberSequenceScreen> createState() =>
      _NumberSequenceScreenState();
}

class _NumberSequenceScreenState
    extends State<NumberSequenceScreen> {
  late NumberSequenceEngine _engine;
  late TimerManager _timerManager;

  Timer? _previewTimer;

  bool _isPreviewing = true;
  int _previewSecondsRemaining = 5;

  @override
  void initState() {
    super.initState();

    _engine = NumberSequenceEngine(
      difficulty: DifficultyLevel.easy,
    );

    _timerManager = TimerManager(
      totalSeconds: 60,
    );

    _loadDifficultyAndStart();
  }

  Future<void> _loadDifficultyAndStart() async {
    _engine.setDifficulty(await DifficultyStorage.load('number_sequence'));
    if (mounted) _startPreview();
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    super.dispose();
  }

  void _startPreview() {
    _engine.showSequence();

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

    _engine.hideSequence();

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

  void _onNumberTap(int number) {
    if (_isPreviewing) {
      return;
    }

    if (_timerManager.remainingSeconds <= 0) {
      return;
    }

    if (_engine.isGameComplete) {
      return;
    }

    final added = _engine.addNumber(number);

    if (!added) {
      return;
    }

    setState(() {});
  }

  void _removeLastNumber() {
    if (_isPreviewing || _engine.isGameComplete) {
      return;
    }

    final removed = _engine.removeLastNumber();

    if (!removed) {
      return;
    }

    setState(() {});
  }

  Future<void> _checkSequence() async {
    if (_isPreviewing) {
      return;
    }

    if (_engine.isGameComplete) {
      return;
    }

    if (!_engine.canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enter all ${_engine.sequenceLength} numbers first.',
          ),
        ),
      );

      return;
    }

    _engine.evaluateSequence();

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
    final bool wasPerfect =
        result.accuracy >= 100;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: TrText(
            wasPerfect
                ? 'Perfect Sequence! 🎉'
                : 'Sequence Complete!',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TrText(
                wasPerfect
                    ? 'Excellent memory!'
                    : 'Good effort! Keep practicing.',
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
                'Correct Positions: '
                '${result.correctAnswers}/${_engine.sequenceLength}',
              ),

              TrText(
                'Incorrect Positions: '
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
                'Correct Positions: '
                '${result.correctAnswers}/${_engine.sequenceLength}',
              ),

              TrText(
                'Incorrect Positions: '
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

  Widget _buildSequenceDisplay() {
    final entered = _engine.enteredSequence;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outline,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          TrText(
            _isPreviewing
                ? 'Remember this sequence'
                : 'Your sequence',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              if (_isPreviewing)
                ..._engine.sequence.map(
                  (number) => _numberChip(
                    number.toString(),
                  ),
                )
              else if (entered.isEmpty)
                const TrText(
                  'Tap the numbers below',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                )
              else
                ...entered.map(
                  (number) => _numberChip(
                    number.toString(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _numberChip(String value) {
    return Container(
      width: 58,
      height: 58,
      margin: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context)
            .colorScheme
            .primaryContainer,
      ),
      child: Center(
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _numberButton(int number) {
    return SizedBox(
      height: 72,
      child: ElevatedButton(
        onPressed: () => _onNumberTap(number),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          '$number',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return GridView.count(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _numberButton(1),
        _numberButton(2),
        _numberButton(3),
        _numberButton(4),
        _numberButton(5),
        _numberButton(6),
        _numberButton(7),
        _numberButton(8),
        _numberButton(9),
        SizedBox(
          height: 72,
          child: OutlinedButton(
            onPressed: _removeLastNumber,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
            ),
            child: const Icon(
              Icons.backspace_outlined,
              size: 28,
            ),
          ),
        ),
        _numberButton(0),
        SizedBox(
          height: 72,
          child: ElevatedButton(
            onPressed: _checkSequence,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TrText('Number Sequence'),
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
                    value: _isPreviewing
                        ? 'Preview'
                        : '${_timerManager.remainingSeconds}s',
                  ),
                  _infoBox(
                    icon: Icons.format_list_numbered,
                    label: 'Length',
                    value:
                        '${_engine.sequenceLength}',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              if (_isPreviewing) ...[
                const TrText(
                  'Remember the sequence',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                const TrText(
                  'Remember the numbers in the '
                  'exact order shown.',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                TrText(
                  'Hiding in $_previewSecondsRemaining seconds',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else ...[
                const TrText(
                  'Recreate the sequence',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                const TrText(
                  'Tap the numbers in the same order, '
                  'then press ✓.',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 24),

              _buildSequenceDisplay(),

              const SizedBox(height: 24),

              if (_isPreviewing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _endPreview,
                    style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(
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
              else ...[
                _buildNumberPad(),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _checkSequence,
                    style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 18,
                      ),
                    ),
                    child: const TrText(
                      'Check Sequence',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}