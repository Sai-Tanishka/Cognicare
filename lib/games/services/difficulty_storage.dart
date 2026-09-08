import 'package:shared_preferences/shared_preferences.dart';

import '../models/difficulty_level.dart';

class DifficultyStorage {
  static Future<DifficultyLevel> load(String gameId) async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getInt('difficulty_$gameId');
    return DifficultyLevel.values[value ?? 0];
  }

  static Future<void> save(String gameId, DifficultyLevel difficulty) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('difficulty_$gameId', difficulty.index);
  }
}
