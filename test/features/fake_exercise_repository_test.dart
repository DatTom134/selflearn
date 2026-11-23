import 'package:flutter_test/flutter_test.dart';
import 'package:selflearn/features/exercises/domain/models/exercise_json_validation.dart';
import 'package:selflearn/features/exercises/domain/models/exercise_set.dart';
import 'package:selflearn/features/exercises/domain/repositories/exercise_repository.dart';
import 'package:selflearn/features/exercises/domain/services/exercise_json_validator.dart';

import '../support/fake_exercise_repository.dart';

void main() {
  late FakeExerciseRepository repository;

  setUp(() {
    repository = FakeExerciseRepository();
  });

  test('searches literally and orders results newest first', () async {
    repository.items.addAll([
      _set(id: 'older', title: '1000 Progress', importedAt: DateTime(2026)),
      _set(id: 'newer', title: '100% Progress', importedAt: DateTime(2026, 2)),
    ]);

    expect((await repository.getExercises()).map((item) => item.id), [
      'newer',
      'older',
    ]);
    final results = await repository.getExercises(query: '  %  ');

    expect(results.map((item) => item.title), ['100% Progress']);
  });

  test('returns case-insensitive unique topics in normalized order', () async {
    repository.items.addAll([
      _set(
        id: 'one',
        title: 'One',
        importedAt: DateTime(2026),
        topics: ['math', 'English'],
      ),
      _set(
        id: 'two',
        title: 'Two',
        importedAt: DateTime(2026, 2),
        topics: ['MATH', 'Science'],
      ),
    ]);

    expect(await repository.getTopics(), ['English', 'math', 'Science']);
  });

  test('stores the first spelling when later imports reuse a topic', () async {
    final first = await repository.importExercise(
      _exercise('source-one', 'First', 'One', topic: 'math'),
    );
    final second = await repository.importExercise(
      _exercise('source-two', 'Second', 'Two', topic: 'MATH'),
    );

    expect(second.topics, ['MATH']);
    expect((await repository.getExerciseById(first.id))!.topics, ['math']);
    expect((await repository.getExerciseById(second.id))!.topics, ['math']);
    expect(await repository.getTopics(), ['math']);
  });

  test('duplicate errors identify the matching existing set', () async {
    await repository.importExercise(_exercise('source-one', 'First', 'One'));
    await repository.importExercise(_exercise('source-two', 'Second', 'Two'));

    await expectLater(
      repository.importExercise(_exercise('source-one', 'Changed', 'Other')),
      throwsA(
        isA<DuplicateExerciseException>().having(
          (error) => error.existingTitle,
          'existingTitle',
          'First',
        ),
      ),
    );
    await expectLater(
      repository.importExercise(_exercise('source-three', 'Changed', 'Two')),
      throwsA(
        isA<DuplicateExerciseException>().having(
          (error) => error.existingTitle,
          'existingTitle',
          'Second',
        ),
      ),
    );
  });

  test(
    'rename follows local repository validation and missing reads fail',
    () async {
      final saved = await repository.importExercise(
        _exercise('source', 'Original', 'Question'),
      );

      await repository.renameExercise(saved.id, '  Renamed  ');

      expect((await repository.getExerciseById(saved.id))!.title, 'Renamed');
      await expectLater(
        repository.renameExercise(saved.id, '  '),
        throwsArgumentError,
      );
      await expectLater(
        repository.readExerciseJson('missing'),
        throwsStateError,
      );
    },
  );
}

ExerciseSet _set({
  required String id,
  required String title,
  required DateTime importedAt,
  List<String> topics = const ['General'],
}) {
  return ExerciseSet(
    id: id,
    title: title,
    topics: topics,
    questionType: 'short_answer',
    difficulty: null,
    questionCount: 1,
    importedAt: importedAt,
    fileName: '$id.json',
  );
}

ValidatedExercise _exercise(
  String id,
  String title,
  String prompt, {
  String topic = 'English',
}) {
  final result = const ExerciseJsonValidator().validate('''
{
  "schemaVersion": 1,
  "id": "$id",
  "title": "$title",
  "topics": ["$topic"],
  "questions": [
    {"type": "short_answer", "prompt": "$prompt", "answer": "Answer"}
  ]
}
''');
  if (!result.isValid) throw StateError(result.issues.toString());
  return result.exercise!;
}
