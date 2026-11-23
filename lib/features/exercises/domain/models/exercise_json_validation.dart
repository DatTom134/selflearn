class ExerciseValidationIssue {
  const ExerciseValidationIssue({required this.path, required this.message});

  final String path;
  final String message;

  @override
  String toString() => '$path: $message';
}

class ValidatedExercise {
  const ValidatedExercise({
    required this.sourceId,
    required this.title,
    required this.topics,
    required this.questionType,
    required this.difficulty,
    required this.questionCount,
    required this.questionPreviews,
    required this.rawJson,
    required this.canonicalJson,
    required this.contentHash,
  });

  final String? sourceId;
  final String title;
  final List<String> topics;
  final String questionType;
  final String? difficulty;
  final int questionCount;
  final List<String> questionPreviews;
  final String rawJson;
  final String canonicalJson;
  final String contentHash;
}

class ExerciseJsonValidationResult {
  const ExerciseJsonValidationResult._({
    required this.exercise,
    required this.issues,
  });

  factory ExerciseJsonValidationResult.valid(ValidatedExercise exercise) =>
      ExerciseJsonValidationResult._(exercise: exercise, issues: const []);

  factory ExerciseJsonValidationResult.invalid(
    List<ExerciseValidationIssue> issues,
  ) => ExerciseJsonValidationResult._(exercise: null, issues: issues);

  final ValidatedExercise? exercise;
  final List<ExerciseValidationIssue> issues;

  bool get isValid => exercise != null && issues.isEmpty;
}
