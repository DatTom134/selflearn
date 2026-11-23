class ExerciseSet {
  const ExerciseSet({
    required this.id,
    required this.title,
    required this.topics,
    required this.questionType,
    required this.difficulty,
    required this.questionCount,
    required this.importedAt,
    required this.fileName,
    this.sourceId,
  });

  final String id;
  final String? sourceId;
  final String title;
  final List<String> topics;
  final String questionType;
  final String? difficulty;
  final int questionCount;
  final DateTime importedAt;
  final String fileName;
}
