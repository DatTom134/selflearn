class PracticeQuestion {
  PracticeQuestion({
    required this.questionIndex,
    required this.sourceQuestionId,
    required this.type,
    required this.prompt,
    required List<String> options,
  }) : options = List.unmodifiable(options);

  final int questionIndex;
  final String? sourceQuestionId;
  final String type;
  final String prompt;
  final List<String> options;
}
