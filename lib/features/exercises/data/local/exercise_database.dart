import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class ExerciseDatabase {
  ExerciseDatabase._(this.database);

  factory ExerciseDatabase.forTesting(Database database) =>
      ExerciseDatabase._(database);

  final Database database;

  static const int schemaVersion = 1;
  static const String databaseName = 'selflearn_exercises.db';

  static Future<ExerciseDatabase> open() async {
    final databasesDirectory = await getDatabasesPath();
    final path = p.join(databasesDirectory, databaseName);
    final database = await openDatabase(
      path,
      version: schemaVersion,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) => createSchema(db, version),
    );
    return ExerciseDatabase._(database);
  }

  static Future<void> createSchema(DatabaseExecutor db, int version) async {
    await db.execute('''
      CREATE TABLE exercise_sets (
        id TEXT PRIMARY KEY,
        source_id TEXT UNIQUE,
        title TEXT NOT NULL,
        title_search TEXT NOT NULL,
        question_type TEXT NOT NULL,
        question_type_search TEXT NOT NULL,
        difficulty TEXT,
        question_count INTEGER NOT NULL,
        imported_at INTEGER NOT NULL,
        content_hash TEXT NOT NULL UNIQUE,
        file_name TEXT NOT NULL UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE exercise_topics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        normalized_name TEXT NOT NULL UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE exercise_set_topics (
        exercise_set_id TEXT NOT NULL,
        topic_id INTEGER NOT NULL,
        PRIMARY KEY (exercise_set_id, topic_id),
        FOREIGN KEY (exercise_set_id) REFERENCES exercise_sets(id) ON DELETE CASCADE,
        FOREIGN KEY (topic_id) REFERENCES exercise_topics(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_exercise_sets_imported_at ON exercise_sets(imported_at DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_exercise_set_topics_topic ON exercise_set_topics(topic_id)',
    );
  }

  Future<void> close() => database.close();
}
