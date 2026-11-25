import 'parsed_practice_set.dart';

class PracticeParseIssue {
  const PracticeParseIssue({
    required this.path,
    required this.code,
    required this.message,
  });

  final String path;
  final String code;
  final String message;
}

class PracticeQuestionParseResult {
  PracticeQuestionParseResult._({
    required this.practiceSet,
    required List<PracticeParseIssue> issues,
  }) : issues = List.unmodifiable(issues);

  factory PracticeQuestionParseResult.success(ParsedPracticeSet practiceSet) =>
      PracticeQuestionParseResult._(practiceSet: practiceSet, issues: const []);

  factory PracticeQuestionParseResult.failure(
    List<PracticeParseIssue> issues,
  ) => PracticeQuestionParseResult._(practiceSet: null, issues: issues);

  final ParsedPracticeSet? practiceSet;
  final List<PracticeParseIssue> issues;

  bool get isSuccess => practiceSet != null && issues.isEmpty;
}
