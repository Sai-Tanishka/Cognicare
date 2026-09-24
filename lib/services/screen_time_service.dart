import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ScreenTimeService tracks daily screen time in the Patient View.
/// - Patients are limited to 1 hour (3600 seconds) per day.
/// - Issues advance alerts (at 45 minutes / 15m remaining, and 55 minutes / 5m remaining).
/// - Triggers auto-logout when 1 hour is reached.
class ScreenTimeService extends ChangeNotifier {
  ScreenTimeService._internal();
  static final ScreenTimeService instance = ScreenTimeService._internal();

  static const int maxDailySeconds = 3600; // 1 Hour
  static const int warning15MinSeconds = 2700; // 45 Mins (15m left)
  static const int warning5MinSeconds = 3300; // 55 Mins (5m left)

  int _secondsToday = 0;
  Timer? _ticker;
  bool _warning15Fired = false;
  bool _warning5Fired = false;
  bool _limitFired = false;
  bool _isInitialized = false;

  void Function(int minutesRemaining)? onWarning;
  VoidCallback? onLimitReached;

  int get secondsToday => _secondsToday;
  int get maxSeconds => maxDailySeconds;
  int get remainingSeconds => math.max(0, maxDailySeconds - _secondsToday);
  double get progress => (_secondsToday / maxDailySeconds).clamp(0.0, 1.0);
  bool get isLimitReached => _secondsToday >= maxDailySeconds;

  String _getTodayKey() {
    final now = DateTime.now();
    final yyyy = now.year.toString().padLeft(4, '0');
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    return 'cognicare_screentime_${yyyy}_${mm}_$dd';
  }

  /// Initialize and load today's saved screen time
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getTodayKey();
      _secondsToday = prefs.getInt(key) ?? 0;

      if (_secondsToday >= warning15MinSeconds) {
        _warning15Fired = true;
      }
      if (_secondsToday >= warning5MinSeconds) {
        _warning5Fired = true;
      }
      if (_secondsToday >= maxDailySeconds) {
        _limitFired = true;
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('ScreenTimeService init error: $e');
    }
  }

  /// Checks if the daily limit was already reached today
  Future<bool> isLimitReachedForToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getTodayKey();
      final seconds = prefs.getInt(key) ?? _secondsToday;
      return seconds >= maxDailySeconds;
    } catch (_) {
      return _secondsToday >= maxDailySeconds;
    }
  }

  /// Starts tracking screen time when patient view is active
  void startTracking() {
    if (_ticker != null && _ticker!.isActive) return;

    // Run ticker every second
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsToday++;

      // Check 15-minute warning (45 mins used)
      if (_secondsToday >= warning15MinSeconds && !_warning15Fired && _secondsToday < warning5MinSeconds) {
        _warning15Fired = true;
        onWarning?.call(15);
      }

      // Check 5-minute warning (55 mins used)
      if (_secondsToday >= warning5MinSeconds && !_warning5Fired && _secondsToday < maxDailySeconds) {
        _warning5Fired = true;
        onWarning?.call(5);
      }

      // Check 1-hour limit reached
      if (_secondsToday >= maxDailySeconds && !_limitFired) {
        _limitFired = true;
        stopTracking();
        _saveToPrefs();
        notifyListeners();
        onLimitReached?.call();
        return;
      }

      // Periodically persist to SharedPreferences every 5 seconds
      if (_secondsToday % 5 == 0) {
        _saveToPrefs();
      }

      notifyListeners();
    });
  }

  /// Stops tracking when screen is paused or disposed
  void stopTracking() {
    _ticker?.cancel();
    _ticker = null;
    _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_getTodayKey(), _secondsToday);
    } catch (e) {
      debugPrint('Error saving screen time: $e');
    }
  }

  /// Reset today's screen time (for testing / caregiver reset)
  Future<void> resetToday() async {
    _secondsToday = 0;
    _warning15Fired = false;
    _warning5Fired = false;
    _limitFired = false;
    await _saveToPrefs();
    notifyListeners();
  }

  /// Add minutes for quick testing / demonstration
  Future<void> addMinutesForTesting(int minutes) async {
    _secondsToday = math.min(maxDailySeconds, _secondsToday + (minutes * 60));
    await _saveToPrefs();

    if (_secondsToday >= warning5MinSeconds && !_warning5Fired) {
      _warning5Fired = true;
      onWarning?.call(5);
    } else if (_secondsToday >= warning15MinSeconds && !_warning15Fired) {
      _warning15Fired = true;
      onWarning?.call(15);
    }

    if (_secondsToday >= maxDailySeconds && !_limitFired) {
      _limitFired = true;
      stopTracking();
      notifyListeners();
      onLimitReached?.call();
      return;
    }

    notifyListeners();
  }

  /// Formatted strings for display
  String get formattedUsage {
    final mins = _secondsToday ~/ 60;
    return '${mins}m / 60m';
  }

  String get formattedRemaining {
    final remMins = (maxDailySeconds - _secondsToday) ~/ 60;
    if (remMins <= 0) return '0m';
    return '${remMins}m left';
  }
}
