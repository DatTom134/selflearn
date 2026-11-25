import 'practice_answer_key.dart';
import 'practice_question.dart';

class ParsedPracticeSet {
  ParsedPracticeSet({
    required this.sourceId,
    required this.title,
    required List<PracticeQuestion> questions,
    required List<PracticeAnswerKey> answerKeys,
  }) : questions = List.unmodifiable(questions),
       answerKeys = List.unmodifiable(answerKeys);

  final String? sourceId;
  final String title;
  final List<PracticeQuestion> questions;
  final List<PracticeAnswerKey> answerKeys;
}
