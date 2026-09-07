import 'dart:async';

/// Reusable countdown timer for cognitive games.
class TimerManager {
  final int totalSeconds;

  Timer? _timer;

  int _remainingSeconds;
  bool _isRunning = false;

  TimerManager({
    required this.totalSeconds,
  }) : _remainingSeconds = totalSeconds;

  int get remainingSeconds => _remainingSeconds;

  bool get isRunning => _isRunning;

  bool get isFinished => _remainingSeconds <= 0;

  /// Starts the countdown.
  void start({
    required void Function(int remainingSeconds) onTick,
    required void Function() onFinished,
  }) {
    if (_isRunning || isFinished) {
      return;
    }

    _isRunning = true;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        _remainingSeconds--;

        onTick(_remainingSeconds);

        if (_remainingSeconds <= 0) {
          _isRunning = false;
          timer.cancel();
          _timer = null;

          onFinished();
        }
      },
    );
  }

  /// Pauses the countdown.
  void pause() {
    if (!_isRunning) {
      return;
    }

    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  /// Resumes the countdown.
  void resume({
    required void Function(int remainingSeconds) onTick,
    required void Function() onFinished,
  }) {
    if (_isRunning || isFinished) {
      return;
    }

    start(
      onTick: onTick,
      onFinished: onFinished,
    );
  }

  /// Resets the timer to its original duration.
  void reset() {
    _timer?.cancel();
    _timer = null;

    _remainingSeconds = totalSeconds;
    _isRunning = false;
  }

  /// Stops the timer permanently.
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }
}