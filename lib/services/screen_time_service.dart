import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenTimeService extends ChangeNotifier {
  static final ScreenTimeService instance = ScreenTimeService._internal();
  ScreenTimeService._internal();

  /// Maximum screen time allowed per day: 1 hour (3600 seconds)
  static const int maxScreenTimeSeconds = 3600;

  /// Milestone warning thresholds in seconds
  static const int warning45Min = 2700; // 45 minutes used -> 15 min remaining
  static const int warning55Min = 3300; // 55 minutes used -> 5 min remaining

  int _elapsedSecondsToday = 0;
  Timer? _ticker;
  bool _warned15Min = false;
  bool _warned5Min = false;

  void Function(int remainingMinutes)? onWarning;
  VoidCallback? onLimitReached;

  int get elapsedSeconds => _elapsedSecondsToday;
  int get remainingSeconds => math.max(0, maxScreenTimeSeconds - _elapsedSecondsToday);
  int get remainingMinutes => (remainingSeconds / 60).ceil();
  double get progressFraction =>
      (_elapsedSecondsToday / maxScreenTimeSeconds).clamp(0.0, 1.0);

  bool get isLimitReached => _elapsedSecondsToday >= maxScreenTimeSeconds;

  String _getTodayKey() {
    final now = DateTime.now();
    return 'cognicare_screentime_${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
  }

  /// Load today's saved screen time from SharedPreferences
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getTodayKey();
      _elapsedSecondsToday = prefs.getInt(key) ?? 0;

      // Check if warnings were already passed
      if (_elapsedSecondsToday >= warning45Min) _warned15Min = true;
      if (_elapsedSecondsToday >= warning55Min) _warned5Min = true;

      notifyListeners();
    } catch (_) {}
  }

  /// Check whether the 1-hour limit has already been reached for today
  Future<bool> isLimitReachedForToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getTodayKey();
      final seconds = prefs.getInt(key) ?? 0;
      return seconds >= maxScreenTimeSeconds;
    } catch (_) {
      return false;
    }
  }

  /// Starts the 1-second timer to track active usage in the patient view
  void startTracking({
    void Function(int remainingMinutes)? onWarningCallback,
    VoidCallback? onLimitReachedCallback,
  }) {
    onWarning = onWarningCallback;
    onLimitReached = onLimitReachedCallback;

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  /// Stops tracking active screen time (e.g. when paused, logged out, or screen closed)
  void stopTracking() {
    _ticker?.cancel();
    _ticker = null;
    _saveToStorage();
  }

  void _tick() {
    _elapsedSecondsToday++;

    // Save every 10 seconds or when crossing milestones
    if (_elapsedSecondsToday % 10 == 0) {
      _saveToStorage();
    }

    notifyListeners();

    // Check 15-minute warning (45 minutes used)
    if (_elapsedSecondsToday >= warning45Min && !_warned15Min) {
      _warned15Min = true;
      onWarning?.call(15);
    }

    // Check 5-minute warning (55 minutes used)
    if (_elapsedSecondsToday >= warning55Min && !_warned5Min) {
      _warned5Min = true;
      onWarning?.call(5);
    }

    // Check 1-hour maximum reached (3600 seconds)
    if (_elapsedSecondsToday >= maxScreenTimeSeconds) {
      _saveToStorage();
      stopTracking();
      onLimitReached?.call();
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_getTodayKey(), _elapsedSecondsToday);
    } catch (_) {}
  }

  /// Human readable format for badge: e.g. "42m / 60m" or "58m / 1h"
  String get formattedUsage {
    final usedMin = (_elapsedSecondsToday / 60).floor();
    return '${usedMin}m / 60m';
  }

  /// Reset today's screen time (useful for caregiver or testing)
  Future<void> resetToday() async {
    _elapsedSecondsToday = 0;
    _warned15Min = false;
    _warned5Min = false;
    await _saveToStorage();
    notifyListeners();
  }

  /// Fast-forward screen time for testing (adds minutes)
  Future<void> addMinutesForTesting(int minutes) async {
    _elapsedSecondsToday = math.min(
      maxScreenTimeSeconds,
      _elapsedSecondsToday + (minutes * 60),
    );
    await _saveToStorage();
    notifyListeners();
  }
}

