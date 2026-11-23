import 'package:selflearn/features/exercises/domain/models/exercise_json_validation.dart';
import 'package:selflearn/features/exercises/domain/models/exercise_set.dart';
import 'package:selflearn/features/exercises/domain/repositories/exercise_repository.dart';

class FakeExerciseRepository implements ExerciseRepository {
  final List<ExerciseSet> items = [];
  final Map<String, String> jsonById = {};
  final Map<String, String> contentHashById = {};
  int _nextId = 0;

  @override
  Future<List<ExerciseSet>> getExercises({
    String query = '',
    String? topic,
  }) async {
    final normalizedQuery = query.trim().toLowerCase();
    final results = items.where((item) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          item.title.toLowerCase().contains(normalizedQuery) ||
          item.questionType.toLowerCase().contains(normalizedQuery) ||
          item.topics.any(
            (value) => value.toLowerCase().contains(normalizedQuery),
          );
      final matchesTopic =
          topic == null ||
          item.topics.any(
            (value) => value.toLowerCase() == topic.toLowerCase(),
          );
      return matchesQuery && matchesTopic;
    }).toList();
    results.sort((first, second) {
      final importedAt = second.importedAt.compareTo(first.importedAt);
      return importedAt != 0 ? importedAt : second.id.compareTo(first.id);
    });
    return results;
  }

  @override
  Future<List<String>> getTopics() async {
    final topicsByNormalizedName = <String, String>{};
    for (final item in items) {
      for (final topic in item.topics) {
        topicsByNormalizedName.putIfAbsent(topic.toLowerCase(), () => topic);
      }
    }
    final topics = topicsByNormalizedName.entries.toList()
      ..sort((first, second) => first.key.compareTo(second.key));
    return topics.map((entry) => entry.value).toList(growable: false);
  }

  @override
  Future<ExerciseSet?> getExerciseById(String id) async {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<ExerciseSet> importExercise(ValidatedExercise exercise) async {
    final sourceDuplicate = items.where(
      (item) => item.sourceId == exercise.sourceId && exercise.sourceId != null,
    );
    if (sourceDuplicate.isNotEmpty) {
      throw DuplicateExerciseException(
        existingTitle: sourceDuplicate.first.title,
        reason: DuplicateExerciseReason.sourceId,
      );
    }
    final contentDuplicate = items.where(
      (item) => contentHashById[item.id] == exercise.contentHash,
    );
    if (contentDuplicate.isNotEmpty) {
      throw DuplicateExerciseException(
        existingTitle: contentDuplicate.first.title,
        reason: DuplicateExerciseReason.content,
      );
    }
    final id = 'fake_${_nextId++}';
    final storedTopics = <String, String>{};
    for (final item in items) {
      for (final topic in item.topics) {
        storedTopics.putIfAbsent(topic.toLowerCase(), () => topic);
      }
    }
    final persisted = ExerciseSet(
      id: id,
      sourceId: exercise.sourceId,
      title: exercise.title,
      topics: exercise.topics
          .map((topic) => storedTopics[topic.toLowerCase()] ?? topic)
          .toList(growable: false),
      questionType: exercise.questionType,
      difficulty: exercise.difficulty,
      questionCount: exercise.questionCount,
      importedAt: DateTime.now(),
      fileName: '$id.json',
    );
    items.add(persisted);
    jsonById[id] = exercise.rawJson;
    contentHashById[id] = exercise.contentHash;
    return ExerciseSet(
      id: id,
      sourceId: exercise.sourceId,
      title: exercise.title,
      topics: exercise.topics,
      questionType: exercise.questionType,
      difficulty: exercise.difficulty,
      questionCount: exercise.questionCount,
      importedAt: persisted.importedAt,
      fileName: persisted.fileName,
    );
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
    final index = items.indexWhere((item) => item.id == id);
    if (index < 0) throw StateError('Không tìm thấy bộ đề cần đổi tên.');
    final old = items[index];
    items[index] = ExerciseSet(
      id: old.id,
      sourceId: old.sourceId,
      title: normalized,
      topics: old.topics,
      questionType: old.questionType,
      difficulty: old.difficulty,
      questionCount: old.questionCount,
      importedAt: old.importedAt,
      fileName: old.fileName,
    );
  }

  @override
  Future<String> readExerciseJson(String id) async {
    final json = jsonById[id];
    if (json == null) throw StateError('Không tìm thấy bộ đề.');
    return json;
  }

  @override
  Future<void> deleteExercise(String id) async {
    items.removeWhere((item) => item.id == id);
    jsonById.remove(id);
    contentHashById.remove(id);
  }
}
