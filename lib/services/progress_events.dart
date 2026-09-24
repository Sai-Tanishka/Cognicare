import 'package:flutter/foundation.dart';

/// Centralized event bus for notifying UI screens (Home, Activities, Progress)
/// whenever a game attempt is completed or synced.
class ProgressEvents extends ChangeNotifier {
  static final ProgressEvents instance = ProgressEvents._internal();
  ProgressEvents._internal();

  /// Call this whenever a game attempt is saved or synced.
  void notifyGameCompleted() {
    debugPrint('PROGRESS_EVENTS: Game completed or synced. Notifying UI listeners.');
    notifyListeners();
  }
}

