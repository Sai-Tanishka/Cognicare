import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class LocalDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'cognicare.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE game_attempts (
            attempt_id TEXT PRIMARY KEY,
            patient_id TEXT NOT NULL,
            session_id TEXT,
            game_id TEXT NOT NULL,
            difficulty INTEGER NOT NULL,
            score REAL,
            accuracy REAL,
            attempts INTEGER,
            correct_answers INTEGER,
            incorrect_answers INTEGER,
            average_response_time REAL,
            hints_used INTEGER,
            retries INTEGER,
            started_at TEXT,
            completed_at TEXT,
            next_difficulty INTEGER,
            sync_status TEXT NOT NULL DEFAULT 'Pending'
          )
        ''');

        await db.execute('''
          CREATE TABLE sync_queue (
            event_id TEXT PRIMARY KEY,
            entity_type TEXT NOT NULL,
            entity_id TEXT NOT NULL,
            event_type TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'Pending',
            created_at TEXT NOT NULL,
            synced_at TEXT,
            retry_count INTEGER NOT NULL DEFAULT 0,
            last_error TEXT
          )
        ''');
      },
    );
  }

  static Future<void> saveGameAttempt({
    required String patientId,
    String? sessionId,
    required String gameId,
    required int difficulty,
    required double score,
    required double accuracy,
    required int attempts,
    required int correctAnswers,
    required int incorrectAnswers,
    required double averageResponseTime,
    required int hintsUsed,
    required int retries,
    String? startedAt,
    String? completedAt,
    required int nextDifficulty,
  }) async {
    final db = await database;

    final attemptId = const Uuid().v4();
    final eventId = const Uuid().v4();
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await txn.insert(
        'game_attempts',
        {
          'attempt_id': attemptId,
          'patient_id': patientId,
          'session_id': sessionId,
          'game_id': gameId,
          'difficulty': difficulty,
          'score': score,
          'accuracy': accuracy,
          'attempts': attempts,
          'correct_answers': correctAnswers,
          'incorrect_answers': incorrectAnswers,
          'average_response_time': averageResponseTime,
          'hints_used': hintsUsed,
          'retries': retries,
          'started_at': startedAt,
          'completed_at': completedAt,
          'next_difficulty': nextDifficulty,
          'sync_status': 'Pending',
        },
      );

      await txn.insert(
        'sync_queue',
        {
          'event_id': eventId,
          'entity_type': 'game_attempt',
          'entity_id': attemptId,
          'event_type': 'CREATE',
          'status': 'Pending',
          'created_at': now,
          'synced_at': null,
          'retry_count': 0,
          'last_error': null,
        },
      );
    });
  }

  static Future<List<Map<String, dynamic>>> getPendingSyncEvents() async {
    final db = await database;

    return await db.query(
      'sync_queue',
      where: 'status = ?',
      whereArgs: ['Pending'],
      orderBy: 'created_at ASC',
    );
  }
}