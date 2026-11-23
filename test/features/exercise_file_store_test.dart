import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:selflearn/features/exercises/data/local/exercise_file_store.dart';

void main() {
  late Directory directory;
  late LocalExerciseFileStore fileStore;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('selflearn-exercise-');
    fileStore = LocalExerciseFileStore(directory);
  });

  tearDown(() async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test('writes and reads JSON files within the app-owned directory', () async {
    await fileStore.write('exercise.json', '{"schemaVersion":1}');

    expect(await fileStore.read('exercise.json'), '{"schemaVersion":1}');
    expect(
      await File(p.join(directory.path, 'exercise.json')).exists(),
      isTrue,
    );
  });

  test(
    'orphan cleanup retains referenced files and removes temp files',
    () async {
      await fileStore.write('kept.json', '{}');
      await fileStore.write('orphan.json', '{}');
      await File(p.join(directory.path, 'interrupted.json.tmp'))
          .writeAsString('{}');

      await fileStore.removeOrphans({'kept.json'});

      expect(await File(p.join(directory.path, 'kept.json')).exists(), isTrue);
      expect(
        await File(p.join(directory.path, 'orphan.json')).exists(),
        isFalse,
      );
      expect(
        await File(p.join(directory.path, 'interrupted.json.tmp')).exists(),
        isFalse,
      );
    },
  );
}
