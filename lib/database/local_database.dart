import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
}