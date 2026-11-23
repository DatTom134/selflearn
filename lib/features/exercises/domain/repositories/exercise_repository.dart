import '../models/exercise_json_validation.dart';
import '../models/exercise_set.dart';

abstract interface class ExerciseRepository {
  Future<List<ExerciseSet>> getExercises({String query = '', String? topic});
  Future<List<String>> getTopics();
  Future<ExerciseSet?> getExerciseById(String id);
  Future<ExerciseSet> importExercise(ValidatedExercise exercise);
  Future<void> renameExercise(String id, String title);
  Future<String> readExerciseJson(String id);
  Future<void> deleteExercise(String id);
}

class DuplicateExerciseException implements Exception {
  const DuplicateExerciseException({
    required this.existingTitle,
    required this.reason,
  });

  final String existingTitle;
  final DuplicateExerciseReason reason;

  @override
  String toString() => reason == DuplicateExerciseReason.sourceId
      ? 'Bộ đề có ID này đã tồn tại: $existingTitle.'
      : 'Nội dung bộ đề này đã được nhập: $existingTitle.';
}

enum DuplicateExerciseReason { sourceId, content }
