import 'dart:convert';

import '../../../exercises/domain/services/exercise_json_validator.dart';
import '../../../exercises/domain/services/question_type_registry.dart';
import '../models/parsed_practice_set.dart';
import '../models/practice_answer_key.dart';
import '../models/practice_question.dart';
import '../models/practice_question_parse_result.dart';

class PracticeQuestionParser {
  const PracticeQuestionParser({
    this._validator = const ExerciseJsonValidator(),
    this._registry = const QuestionTypeRegistry(),
  });

  final ExerciseJsonValidator _validator;
  final QuestionTypeRegistry _registry;

  PracticeQuestionParseResult parse(String source) {
    final validation = _validator.validate(source);
    if (!validation.isValid) {
      return PracticeQuestionParseResult.failure(
        validation.issues
            .map(
              (issue) => PracticeParseIssue(
                path: issue.path,
                code: issue.code,
                message: issue.message,
              ),
            )
            .toList(growable: false),
      );
    }

    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      return _failure(
        r'$',
        'invalid_root',
        'Phần tử gốc phải là một JSON object.',
      );
    }

    final rawQuestions = decoded['questions'];
    if (rawQuestions is! List) {
      return _failure(
        r'$.questions',
        'invalid_questions',
        'Phải có ít nhất một câu hỏi.',
      );
    }

    final validatedExercise = validation.exercise!;
    final questions = <PracticeQuestion>[];
    final answerKeys = <PracticeAnswerKey>[];
    final issues = <PracticeParseIssue>[];

    for (var index = 0; index < rawQuestions.length; index++) {
      final path = '\$.questions[$index]';
      final rawQuestion = rawQuestions[index];
      if (rawQuestion is! Map<String, dynamic>) {
        issues.add(
          PracticeParseIssue(
            path: path,
            code: 'invalid_question',
            message: 'Mỗi câu hỏi phải là một JSON object.',
          ),
        );
        continue;
      }

      final type = rawQuestion['type'];
      if (type is! String) {
        issues.add(
          PracticeParseIssue(
            path: '$path.type',
            code: 'invalid_question_type',
            message: 'type phải là một chuỗi.',
          ),
        );
        continue;
      }
      if (!_registry.supports(type)) {
        issues.add(
          PracticeParseIssue(
            path: '$path.type',
            code: 'unsupported_question_type',
            message: 'Practice chưa hỗ trợ question type "$type".',
          ),
        );
        continue;
      }

      final promptValue = rawQuestion.containsKey('prompt')
          ? rawQuestion['prompt']
          : rawQuestion['question'];
      final optionsValue = rawQuestion['options'];
      final answerValue = rawQuestion['answer'];
      if (promptValue is! String) {
        issues.add(
          PracticeParseIssue(
            path: '$path.prompt',
            code: 'invalid_prompt',
            message: 'Câu hỏi phải có prompt hợp lệ.',
          ),
        );
        continue;
      }
      if (optionsValue is! List ||
          optionsValue.any((option) => option is! String)) {
        issues.add(
          PracticeParseIssue(
            path: '$path.options',
            code: 'invalid_options',
            message: 'options phải là danh sách các chuỗi hợp lệ.',
          ),
        );
        continue;
      }
      if (answerValue is! String) {
        issues.add(
          PracticeParseIssue(
            path: '$path.answer',
            code: 'invalid_answer',
            message: 'answer phải là một chuỗi.',
          ),
        );
        continue;
      }

      final options = optionsValue
          .cast<String>()
          .map((option) => option.trim())
          .toList(growable: false);
      final correctOptionIndex = options.indexOf(answerValue.trim());
      if (correctOptionIndex < 0) {
        issues.add(
          PracticeParseIssue(
            path: '$path.answer',
            code: 'answer_not_in_options',
            message: 'Đáp án không nằm trong danh sách options.',
          ),
        );
        continue;
      }

      final sourceQuestionId = rawQuestion['id'];
      questions.add(
        PracticeQuestion(
          questionIndex: index,
          sourceQuestionId: sourceQuestionId is String
              ? sourceQuestionId
              : null,
          type: type,
          prompt: promptValue.trim(),
          options: options,
        ),
      );
      answerKeys.add(
        PracticeAnswerKey(
          questionIndex: index,
          correctOptionIndex: correctOptionIndex,
        ),
      );
    }

    if (issues.isNotEmpty) {
      return PracticeQuestionParseResult.failure(issues);
    }

    return PracticeQuestionParseResult.success(
      ParsedPracticeSet(
        sourceId: validatedExercise.sourceId,
        title: validatedExercise.title,
        questions: questions,
        answerKeys: answerKeys,
      ),
    );
  }

  PracticeQuestionParseResult _failure(
    String path,
    String code,
    String message,
  ) => PracticeQuestionParseResult.failure([
    PracticeParseIssue(path: path, code: code, message: message),
  ]);
}
