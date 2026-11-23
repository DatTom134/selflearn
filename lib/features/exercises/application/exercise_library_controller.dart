import 'package:flutter/foundation.dart';

import '../domain/models/exercise_set.dart';
import '../domain/repositories/exercise_repository.dart';

class ExerciseLibraryController extends ChangeNotifier {
  ExerciseLibraryController(this.repository);

  final ExerciseRepository repository;

  List<ExerciseSet> exercises = const [];
  List<String> topics = const [];
  bool isLoading = false;
  Object? error;
  String query = '';
  String? selectedTopic;
  int _requestId = 0;
  bool _disposed = false;

  Future<void> load() async {
    if (_disposed) return;
    final requestId = ++_requestId;
    isLoading = true;
    error = null;
    if (!_disposed) notifyListeners();
    try {
      final results = await Future.wait([
        repository.getExercises(query: query, topic: selectedTopic),
        repository.getTopics(),
      ]);
      if (requestId != _requestId) return;
      topics = results[1] as List<String>;
      var loadedExercises = results[0] as List<ExerciseSet>;
      final activeTopic = selectedTopic;
      if (activeTopic != null &&
          !topics.any(
            (topic) => topic.toLowerCase() == activeTopic.toLowerCase(),
          )) {
        selectedTopic = null;
        loadedExercises = await repository.getExercises(query: query);
        if (requestId != _requestId) return;
      }
      exercises = loadedExercises;
    } catch (exception) {
      if (requestId == _requestId) error = exception;
    } finally {
      if (requestId == _requestId) {
        isLoading = false;
        if (!_disposed) notifyListeners();
      }
    }
  }

  Future<void> setQuery(String value) async {
    query = value;
    await load();
  }

  Future<void> setTopic(String? value) async {
    selectedTopic = value;
    await load();
  }

  Future<void> refresh() => load();

  @override
  void dispose() {
    _disposed = true;
    _requestId++;
    super.dispose();
  }

  Future<void> remove(String id) async {
    await repository.deleteExercise(id);
    await load();
  }

  Future<void> rename(String id, String title) async {
    await repository.renameExercise(id, title);
    await load();
  }
}
