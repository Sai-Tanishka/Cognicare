import 'dart:async';

import 'package:flutter/material.dart';

import '../../repositories/game_repository.dart';
import '../core/timer_manager.dart';
import '../models/difficulty_level.dart';
import '../models/game_result.dart';
import 'memory_match_engine.dart';
import '../services/difficulty_storage.dart';

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  late MemoryMatchEngine _engine;
  late TimerManager _timerManager;

  Timer? _hideCardsTimer;
  Timer? _previewTimer;

  final Stopwatch _responseStopwatch = Stopwatch();

  bool _isPreviewing = true;
  int _previewSecondsRemaining = 5;

  @override
  void initState() {
    super.initState();

    _engine = MemoryMatchEngine(difficulty: DifficultyLevel.easy);

    _timerManager = TimerManager(
      totalSeconds: 60,
    );

    _loadDifficultyAndStart();
  }

  Future<void> _loadDifficultyAndStart() async {
    _engine.difficulty = await DifficultyStorage.load('memory_match');
    _engine.pairsCount = MemoryMatchEngine.pairsForDifficulty(_engine.difficulty);
    if (mounted) _startPreview();
  }

  void _startTimer() {
    _timerManager.start(
      onTick: (remainingSeconds) {
        if (!mounted) {
          return;
        }

        setState(() {});
      },
      onFinished: _handleTimeUp,
    );
  }

  void _startPreview() {
    _engine.showPreview();

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

    _engine.hidePreview();

    setState(() {
      _isPreviewing = false;
      _previewSecondsRemaining = 0;
    });

    _startTimer();
  }

  Future<void> _handleTimeUp() async {
    if (!mounted || _engine.isGameComplete) {
      return;
    }

    _hideCardsTimer?.cancel();

    _responseStopwatch.stop();
    _responseStopwatch.reset();

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
                'Matches: ${_engine.correctMatches}/${_engine.pairsCount}',
              ),
              Text(
                'Attempts: ${result.attempts}',
              ),
              Text(
                'Accuracy: ${result.accuracy.toStringAsFixed(0)}%',
              ),
              Text(
                'Avg. Response Time: '
                '${result.averageResponseTime.toStringAsFixed(1)}s',
              ),
              const SizedBox(height: 8),
              Text('Completed at: ${result.difficulty.name}'),
              Text(
                'Continue at: '
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
              child: const Text('Try Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _hideCardsTimer?.cancel();
    _previewTimer?.cancel();
    _timerManager.dispose();

    super.dispose();
  }

  void _onCardTap(int index) {
    if (_isPreviewing) {
      return;
    }

    if (_engine.isGameComplete || _engine.isCheckingPair) {
      return;
    }

    final selected = _engine.selectCard(index);

    if (!selected) {
      return;
    }

    if (_engine.firstSelectedIndex == index &&
        _engine.secondSelectedIndex == null) {
      _responseStopwatch
        ..reset()
        ..start();
    }

    if (_engine.secondSelectedIndex != null) {
      _responseStopwatch.stop();

      _engine.recordResponseTime(
        _responseStopwatch.elapsed,
      );

      _responseStopwatch.reset();

      _checkSelectedPair();
    }

    setState(() {});
  }

  Future<void> _checkSelectedPair() async {
    _engine.isCheckingPair = true;

    final isMatch = _engine.checkMatch();

    if (isMatch) {
      _engine.isCheckingPair = false;

      setState(() {});

      if (_engine.isGameComplete) {
        _engine.calculateNextDifficulty();

        final result = _engine.createResult();

        await DifficultyStorage.save(
          result.gameId,
          result.nextDifficulty ?? result.difficulty,
        );
        _saveResult(result);

        _showGameCompletedDialog(result);
      }
    } else {
      setState(() {});

      _hideCardsTimer = Timer(
        const Duration(milliseconds: 900),
        () {
          if (!mounted) {
            return;
          }

          setState(() {
            _engine.hideSelectedCards();
            _engine.isCheckingPair = false;
          });
        },
      );
    }
  }

  void _restartGame() {
    _hideCardsTimer?.cancel();
    _previewTimer?.cancel();

    _responseStopwatch.stop();
    _responseStopwatch.reset();

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
    _timerManager.pause();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) {
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Well Done! 🎉',
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'You matched all the pairs!',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Score: ${_engine.score}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Accuracy: ${_engine.accuracy.toStringAsFixed(0)}%',
                ),
                Text(
                  'Attempts: ${_engine.attempts}',
                ),
                Text(
                  'Avg. Response Time: '
                  '${_engine.averageResponseTime.toStringAsFixed(1)}s',
                ),
                const SizedBox(height: 8),
                Text(
                  'Performance: '
                  '${_engine.performance.toStringAsFixed(0)}/100',
                ),
                const SizedBox(height: 8),
                Text(
                  'Next Difficulty: '
                  '${_engine.nextDifficulty?.name ?? _engine.difficultyName}',
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
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F2),
        elevation: 0,
        title: const Text(
          'Memory Match',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF173B35),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildGameHeader(),

              const SizedBox(height: 20),

              if (_isPreviewing) ...[
                const Text(
                  'Remember the cards',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173B35),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Study the cards before they are hidden.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Hiding in $_previewSecondsRemaining seconds',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF376B5C),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: 180,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _endPreview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF376B5C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "I'm Ready",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],

              Expanded(
                child: GridView.builder(
                  itemCount: _engine.cards.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    return _buildCard(index);
                  },
                ),
              ),

              const SizedBox(height: 15),

              _buildRestartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameHeader() {
    return Row(
      children: [
        Expanded(
          child: _infoBox(
            icon: Icons.star_rounded,
            label: 'Score',
            value: '${_engine.score}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _infoBox(
            icon: Icons.touch_app_rounded,
            label: 'Attempts',
            value: '${_engine.attempts}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _infoBox(
            icon: Icons.check_circle_rounded,
            label: 'Matches',
            value: '${_engine.correctMatches}/${_engine.pairsCount}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _infoBox(
            icon: Icons.timer_rounded,
            label: 'Time',
            value: _isPreviewing
                ? 'Preview'
                : '${_timerManager.remainingSeconds}s',
          ),
        ),
      ],
    );
  }

  Widget _infoBox({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF376B5C),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173B35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    final card = _engine.cards[index];

    final isVisible = card.isFaceUp || card.isMatched;

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isVisible
              ? const Color(0xFFE4EFEA)
              : const Color(0xFF376B5C),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: isVisible
              ? Text(
                  card.value,
                  style: const TextStyle(
                    fontSize: 38,
                  ),
                )
              : const Icon(
                  Icons.question_mark_rounded,
                  color: Colors.white,
                  size: 34,
                ),
        ),
      ),
    );
  }

  Widget _buildRestartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _restartGame,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text(
          'Restart Game',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF376B5C),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}