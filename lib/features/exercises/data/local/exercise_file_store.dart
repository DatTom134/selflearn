import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract interface class ExerciseFileStore {
  Future<void> write(String fileName, String content);
  Future<String> read(String fileName);
  Future<void> delete(String fileName);
  Future<void> removeOrphans(Set<String> referencedFiles);
}

class LocalExerciseFileStore implements ExerciseFileStore {
  LocalExerciseFileStore(this.directory);

  final Directory directory;

  static Future<LocalExerciseFileStore> createDefault() async {
    final supportDirectory = await getApplicationSupportDirectory();
    final directory = Directory(p.join(supportDirectory.path, 'exercise_sets'));
    await directory.create(recursive: true);
    return LocalExerciseFileStore(directory);
  }

  File _file(String fileName) => File(p.join(directory.path, fileName));

  @override
  Future<void> write(String fileName, String content) async {
    await directory.create(recursive: true);
    final temporary = _file('$fileName.tmp');
    final destination = _file(fileName);
    await temporary.writeAsString(content, flush: true);
    if (await destination.exists()) await destination.delete();
    await temporary.rename(destination.path);
  }

  @override
  Future<String> read(String fileName) => _file(fileName).readAsString();

  @override
  Future<void> delete(String fileName) async {
    final file = _file(fileName);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<void> removeOrphans(Set<String> referencedFiles) async {
    if (!await directory.exists()) return;
    await for (final entity in directory.list()) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      if (name.endsWith('.tmp') || !referencedFiles.contains(name)) {
        await entity.delete();
      }
    }
  }
}
