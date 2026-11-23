import 'package:flutter_test/flutter_test.dart';
import 'package:selflearn/features/exercises/data/local/exercise_database.dart';
import 'package:selflearn/features/exercises/data/local/exercise_file_store.dart';
import 'package:selflearn/features/exercises/data/repositories/local_exercise_repository.dart';
import 'package:selflearn/features/exercises/domain/models/exercise_json_validation.dart';
import 'package:selflearn/features/exercises/domain/repositories/exercise_repository.dart';
import 'package:selflearn/features/exercises/domain/services/exercise_json_validator.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late ExerciseDatabase database;
  late LocalExerciseRepository repository;
  late _MemoryExerciseFileStore fileStore;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: ExerciseDatabase.schemaVersion,
        onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) => ExerciseDatabase.createSchema(db, version),
      ),
    );
    database = ExerciseDatabase.forTesting(db);
    fileStore = _MemoryExerciseFileStore();
    repository = LocalExerciseRepository(
      database: database,
      fileStore: fileStore,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('imports one mixed-topic JSON as one card and reads it back', () async {
    final exercise = _validate(
      _json('set-1', 'Mixed English', ['English', 'Grammar']),
    );

    final saved = await repository.importExercise(exercise);
    final results = await repository.getExercises();

    expect(results, hasLength(1));
    expect(results.single.id, saved.id);
    expect(results.single.topics, ['English', 'Grammar']);
    expect(await repository.readExerciseJson(saved.id), exercise.rawJson);
    expect(await repository.getExercises(topic: 'Grammar'), hasLength(1));
  });

  test(
    'searches and filters topic names case-insensitively for Vietnamese text',
    () async {
      await repository.importExercise(
        _validate(_json('unicode-1', 'Địa lý Việt Nam', ['Toán học'])),
      );

      expect(await repository.getExercises(query: 'ĐỊA LÝ'), hasLength(1));
      expect(await repository.getExercises(topic: 'TOÁN HỌC'), hasLength(1));
    },
  );

  test(
    'reuses the first stored spelling for a case-insensitive topic',
    () async {
      final first = await repository.importExercise(
        _validate(_json('topic-1', 'First', ['math'], prompt: 'First math')),
      );
      final second = await repository.importExercise(
        _validate(_json('topic-2', 'Second', ['MATH'], prompt: 'Second math')),
      );

      expect(second.topics, ['MATH']);
      expect((await repository.getExerciseById(first.id))!.topics, ['math']);
      expect((await repository.getExerciseById(second.id))!.topics, ['math']);
      expect(await repository.getTopics(), ['math']);
    },
  );

  test('search treats SQL wildcard characters as literal text', () async {
    await repository.importExercise(
      _validate(
        _json('percent-1', '100% Progress', [
          'Math',
        ], prompt: 'Percent search question'),
      ),
    );
    await repository.importExercise(
      _validate(
        _json('plain-1', '1000 Progress', [
          'Science',
        ], prompt: 'Plain search question'),
      ),
    );

    final results = await repository.getExercises(query: '%');

    expect(results, hasLength(1));
    expect(results.single.title, '100% Progress');
  });

  test('search treats underscore and escape characters literally', () async {
    await repository.importExercise(
      _validate(
        _json('underscore-1', 'Unit_Test', [
          'Coding',
        ], prompt: 'Literal underscore'),
      ),
    );
    await repository.importExercise(
      _validate(
        _json('plain-1', 'UnitXTest', ['Coding'], prompt: 'Wildcard decoy'),
      ),
    );
    await repository.importExercise(
      _validate(
        _json('escape-1', 'Bang!Title', [
          'Coding',
        ], prompt: 'Literal exclamation'),
      ),
    );

    final underscoreResults = await repository.getExercises(query: '_');
    final escapeResults = await repository.getExercises(query: '!');

    expect(underscoreResults.map((item) => item.title), ['Unit_Test']);
    expect(escapeResults.map((item) => item.title), ['Bang!Title']);
  });

  test('rejects duplicate source IDs and duplicate content', () async {
    final first = _validate(
      _json('set-1', 'First', ['English'], prompt: 'First question'),
    );
    await repository.importExercise(first);

    await expectLater(
      repository.importExercise(
        _validate(
          _json('set-1', 'Changed title', ['Math'], prompt: 'Changed question'),
        ),
      ),
      throwsA(isA<DuplicateExerciseException>()),
    );
    final contentOnly = _validate(
      _json('', 'Content only', ['Science'], prompt: 'Unique content'),
    );
    await repository.importExercise(contentOnly);
    await expectLater(
      repository.importExercise(
        _validate(
          _json(
            'other-id',
            'Different title',
            ['Other topic'],
            prompt: 'Unique content',
            questionId: 'q2',
          ),
        ),
      ),
      throwsA(isA<DuplicateExerciseException>()),
    );
  });

  test(
    'rename changes card title but preserves original JSON content',
    () async {
      final exercise = _validate(_json('set-2', 'Original', ['Math']));
      final saved = await repository.importExercise(exercise);

      await repository.renameExercise(saved.id, 'Renamed');

      expect((await repository.getExerciseById(saved.id))!.title, 'Renamed');
      expect(await repository.getExercises(query: 'renamed'), hasLength(1));
      expect(await repository.getExercises(query: 'original'), isEmpty);
      expect(await repository.readExerciseJson(saved.id), exercise.rawJson);
    },
  );

  test('deleting one card keeps a shared topic used by another card', () async {
    final first = await repository.importExercise(
      _validate(
        _json('set-3', 'First', [
          'Shared',
          'Math',
        ], prompt: 'First shared-topic question'),
      ),
    );
    final second = await repository.importExercise(
      _validate(
        _json('set-4', 'Second', [
          'Shared',
          'English',
        ], prompt: 'Second shared-topic question'),
      ),
    );

    await repository.deleteExercise(first.id);

    expect(await repository.getExerciseById(first.id), isNull);
    expect((await repository.getExerciseById(second.id))!.topics, [
      'English',
      'Shared',
    ]);
    expect(await repository.getTopics(), ['English', 'Shared']);
    expect(fileStore.files.containsKey(first.fileName), isFalse);
    expect(fileStore.files.containsKey(second.fileName), isTrue);
  });

  test(
    'startup cleanup preserves referenced JSON and removes orphan files',
    () async {
      final saved = await repository.importExercise(
        _validate(_json('set-5', 'Saved', ['English'])),
      );
      fileStore.files['orphan.json'] = '{}';
      fileStore.files['interrupted.json.tmp'] = '{}';

      await repository.cleanupOrphanFiles();

      expect(fileStore.files.keys, [saved.fileName]);
    },
  );
}

ValidatedExercise _validate(String json) {
  final result = const ExerciseJsonValidator().validate(json);
  if (!result.isValid) throw StateError(result.issues.toString());
  return result.exercise!;
}

String _json(
  String id,
  String title,
  List<String> topics, {
  String prompt = 'Question?',
  String questionId = 'q1',
}) =>
    '''{
  "schemaVersion": 1,
  ${id.isEmpty ? '' : '"id": "$id",'}
  "title": "$title",
  "topics": ${_encode(topics)},
  "questionType": "Short Answer",
  "questions": [
    {"id": "$questionId", "type": "short_answer", "prompt": "$prompt", "answer": "Answer"}
  ]
}''';

String _encode(List<String> values) =>
    '[${values.map((value) => '"$value"').join(',')}]';

class _MemoryExerciseFileStore implements ExerciseFileStore {
  final Map<String, String> files = {};

  @override
  Future<void> write(String fileName, String content) async {
    files[fileName] = content;
  }

  @override
  Future<String> read(String fileName) async => files[fileName]!;

  @override
  Future<void> delete(String fileName) async {
    files.remove(fileName);
  }

  @override
  Future<void> removeOrphans(Set<String> referencedFiles) async {
    files.removeWhere(
      (name, _) => name.endsWith('.tmp') || !referencedFiles.contains(name),
    );
  }
}
