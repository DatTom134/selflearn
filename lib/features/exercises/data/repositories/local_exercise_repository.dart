import 'dart:io';
import 'dart:math';

import 'package:sqflite/sqflite.dart';

import '../../domain/models/exercise_json_validation.dart';
import '../../domain/models/exercise_set.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../local/exercise_database.dart';
import '../local/exercise_file_store.dart';

class LocalExerciseRepository implements ExerciseRepository {
  LocalExerciseRepository({required this.database, required this.fileStore});

  final ExerciseDatabase database;
  final ExerciseFileStore fileStore;
  final Random _random = Random.secure();

  static Future<LocalExerciseRepository> createDefault() async {
    final database = await ExerciseDatabase.open();
    try {
      final fileStore = await LocalExerciseFileStore.createDefault();
      final repository = LocalExerciseRepository(
        database: database,
        fileStore: fileStore,
      );
      await repository.cleanupOrphanFiles();
      return repository;
    } catch (_) {
      try {
        await database.close();
      } catch (_) {
        // Preserve the initialization error; closing is best-effort cleanup.
      }
      rethrow;
    }
  }

  Future<void> cleanupOrphanFiles() async {
    final rows = await database.database.query(
      'exercise_sets',
      columns: ['file_name'],
    );
    final referenced = rows.map((row) => row['file_name']! as String).toSet();
    await fileStore.removeOrphans(referenced);
  }

  @override
  Future<List<ExerciseSet>> getExercises({
    String query = '',
    String? topic,
  }) async {
    final normalizedQuery = query.trim().toLowerCase();
    final escapedQuery = normalizedQuery
        .replaceAll('!', '!!')
        .replaceAll('%', '!%')
        .replaceAll('_', '!_');
    final like = '%$escapedQuery%';
    final rows = await database.database.rawQuery(
      '''
      SELECT e.*
      FROM exercise_sets e
      WHERE (
        ? = ''
        OR e.title_search LIKE ? ESCAPE '!'
        OR e.question_type_search LIKE ? ESCAPE '!'
        OR EXISTS (
          SELECT 1
          FROM exercise_set_topics st
          INNER JOIN exercise_topics t ON t.id = st.topic_id
          WHERE st.exercise_set_id = e.id
            AND t.normalized_name LIKE ? ESCAPE '!'
        )
      )
      AND (? IS NULL OR EXISTS (
        SELECT 1 FROM exercise_set_topics st
        INNER JOIN exercise_topics t ON t.id = st.topic_id
        WHERE st.exercise_set_id = e.id AND t.normalized_name = ?
      ))
      ORDER BY e.imported_at DESC, e.id DESC
    ''',
      [
        normalizedQuery,
        like,
        like,
        like,
        topic?.toLowerCase(),
        topic?.toLowerCase(),
      ],
    );

    if (rows.isEmpty) return const [];
    final ids = rows.map((row) => row['id']! as String).toList(growable: false);
    final placeholders = List.filled(ids.length, '?').join(', ');
    final topicRows = await database.database.rawQuery('''
      SELECT st.exercise_set_id, t.name
      FROM exercise_set_topics st
      INNER JOIN exercise_topics t ON t.id = st.topic_id
      WHERE st.exercise_set_id IN ($placeholders)
      ORDER BY t.normalized_name
    ''', ids);
    final topicsByExercise = <String, List<String>>{};
    for (final topicRow in topicRows) {
      final exerciseId = topicRow['exercise_set_id']! as String;
      topicsByExercise
          .putIfAbsent(exerciseId, () => [])
          .add(topicRow['name']! as String);
    }
    return rows
        .map(
          (row) => _mapExercise(
            row,
            topics: topicsByExercise[row['id']! as String] ?? const [],
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<String>> getTopics() async {
    final rows = await database.database.rawQuery('''
      SELECT DISTINCT t.name
      FROM exercise_topics t
      INNER JOIN exercise_set_topics st ON st.topic_id = t.id
      ORDER BY t.normalized_name
    ''');
    return rows.map((row) => row['name']! as String).toList(growable: false);
  }

  @override
  Future<ExerciseSet?> getExerciseById(String id) async {
    final rows = await database.database.query(
      'exercise_sets',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final topics = await _topicsFor(id);
    return _mapExercise(rows.single, topics: topics);
  }

  @override
  Future<ExerciseSet> importExercise(ValidatedExercise exercise) async {
    final id = _newId();
    final fileName = '$id.json';
    final importedAt = DateTime.now().toUtc();

    try {
      await database.database.transaction((transaction) async {
        final duplicate = await _findDuplicateIn(transaction, exercise);
        if (duplicate != null) throw duplicate;

        await fileStore.write(fileName, exercise.rawJson);
        await transaction.insert('exercise_sets', {
          'id': id,
          'source_id': exercise.sourceId,
          'title': exercise.title,
          'title_search': exercise.title.toLowerCase(),
          'question_type': exercise.questionType,
          'question_type_search': exercise.questionType.toLowerCase(),
          'difficulty': exercise.difficulty,
          'question_count': exercise.questionCount,
          'imported_at': importedAt.millisecondsSinceEpoch,
          'content_hash': exercise.contentHash,
          'file_name': fileName,
        });

        for (final topic in exercise.topics) {
          await transaction.insert('exercise_topics', {
            'name': topic,
            'normalized_name': topic.toLowerCase(),
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
          final topicRows = await transaction.query(
            'exercise_topics',
            columns: ['id'],
            where: 'normalized_name = ?',
            whereArgs: [topic.toLowerCase()],
            limit: 1,
          );
          final topicId = topicRows.single['id'] as int;
          await transaction.insert('exercise_set_topics', {
            'exercise_set_id': id,
            'topic_id': topicId,
          });
        }
      });
    } catch (error) {
      try {
        await fileStore.delete(fileName);
      } on FileSystemException {
        // Startup orphan cleanup retries failed temporary-file cleanup.
      }
      if (error is DuplicateExerciseException) rethrow;
      if (error is DatabaseException) {
        final duplicate = await _findDuplicateIn(database.database, exercise);
        if (duplicate != null) throw duplicate;
      }
      rethrow;
    }

    return ExerciseSet(
      id: id,
      sourceId: exercise.sourceId,
      title: exercise.title,
      topics: exercise.topics,
      questionType: exercise.questionType,
      difficulty: exercise.difficulty,
      questionCount: exercise.questionCount,
      importedAt: importedAt,
      fileName: fileName,
    );
  }

  Future<DuplicateExerciseException?> _findDuplicateIn(
    DatabaseExecutor executor,
    ValidatedExercise exercise,
  ) async {
    if (exercise.sourceId != null) {
      final rows = await executor.query(
        'exercise_sets',
        columns: ['title'],
        where: 'source_id = ?',
        whereArgs: [exercise.sourceId],
        limit: 1,
      );
      if (rows.isNotEmpty) {
        return DuplicateExerciseException(
          existingTitle: rows.single['title']! as String,
          reason: DuplicateExerciseReason.sourceId,
        );
      }
    }
    final rows = await executor.query(
      'exercise_sets',
      columns: ['title'],
      where: 'content_hash = ?',
      whereArgs: [exercise.contentHash],
      limit: 1,
    );
    if (rows.isNotEmpty) {
      return DuplicateExerciseException(
        existingTitle: rows.single['title']! as String,
        reason: DuplicateExerciseReason.content,
      );
    }
    return null;
  }

  @override
  Future<void> renameExercise(String id, String title) async {
    final normalized = title.trim();
    if (normalized.isEmpty || normalized.length > 180) {
      throw ArgumentError.value(
        title,
        'title',
        'Tên phải có từ 1 đến 180 ký tự.',
      );
    }
    final changed = await database.database.update(
      'exercise_sets',
      {'title': normalized, 'title_search': normalized.toLowerCase()},
      where: 'id = ?',
      whereArgs: [id],
    );
    if (changed == 0) throw StateError('Không tìm thấy bộ đề cần đổi tên.');
  }

  @override
  Future<String> readExerciseJson(String id) async {
    final rows = await database.database.query(
      'exercise_sets',
      columns: ['file_name'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) throw StateError('Không tìm thấy bộ đề.');
    return fileStore.read(rows.single['file_name']! as String);
  }

  @override
  Future<void> deleteExercise(String id) async {
    String? fileName;
    await database.database.transaction((transaction) async {
      final rows = await transaction.query(
        'exercise_sets',
        columns: ['file_name'],
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return;
      fileName = rows.single['file_name']! as String;
      await transaction.delete(
        'exercise_sets',
        where: 'id = ?',
        whereArgs: [id],
      );
      await transaction.rawDelete('''
        DELETE FROM exercise_topics
        WHERE id NOT IN (SELECT topic_id FROM exercise_set_topics)
      ''');
    });
    if (fileName != null) {
      // A failed file deletion leaves only an orphan; startup cleanup removes it.
      try {
        await fileStore.delete(fileName!);
      } on FileSystemException {
        // Metadata deletion is authoritative; cleanupOrphanFiles retries later.
      }
    }
  }

  Future<List<String>> _topicsFor(String id) async {
    final rows = await database.database.rawQuery(
      '''
      SELECT t.name FROM exercise_topics t
      INNER JOIN exercise_set_topics st ON st.topic_id = t.id
      WHERE st.exercise_set_id = ?
      ORDER BY t.normalized_name
    ''',
      [id],
    );
    return rows.map((row) => row['name']! as String).toList(growable: false);
  }

  ExerciseSet _mapExercise(
    Map<String, Object?> row, {
    required List<String> topics,
  }) {
    return ExerciseSet(
      id: row['id']! as String,
      sourceId: row['source_id'] as String?,
      title: row['title']! as String,
      topics: topics,
      questionType: row['question_type']! as String,
      difficulty: row['difficulty'] as String?,
      questionCount: row['question_count']! as int,
      importedAt: DateTime.fromMillisecondsSinceEpoch(
        row['imported_at']! as int,
        isUtc: true,
      ).toLocal(),
      fileName: row['file_name']! as String,
    );
  }

  String _newId() {
    final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final random = List.generate(
      12,
      (_) => _random.nextInt(36).toRadixString(36),
    ).join();
    return 'ex_${time}_$random';
  }
}
