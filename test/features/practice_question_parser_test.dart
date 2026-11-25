import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:selflearn/features/practice/domain/services/practice_question_parser.dart';

void main() {
  const parser = PracticeQuestionParser();

  test('parses typed questions and separate answer keys in source order', () {
    const source = '''{
      "schemaVersion": 1,
      "id": "set-1",
      "title": "Greetings",
      "topics": ["English"],
      "questionType": "short_answer",
      "questions": [
        {
          "id": "q1",
          "type": "multiple_choice",
          "prompt": "  Pick hello  ",
          "options": [" Hello ", "Goodbye"],
          "answer": "Hello"
        },
        {
          "type": "multiple_choice",
          "question": "Pick goodbye",
          "options": ["Hello", "Goodbye", "Thanks"],
          "answer": "Goodbye"
        }
      ]
    }''';

    final result = parser.parse(source);
    final practiceSet = result.practiceSet!;

    expect(result.isSuccess, isTrue);
    expect(practiceSet.title, 'Greetings');
    expect(practiceSet.sourceId, 'set-1');
    expect(practiceSet.questions.map((question) => question.questionIndex), [
      0,
      1,
    ]);
    expect(practiceSet.questions.map((question) => question.prompt), [
      'Pick hello',
      'Pick goodbye',
    ]);
    expect(practiceSet.questions.first.sourceQuestionId, 'q1');
    expect(practiceSet.questions.last.sourceQuestionId, isNull);
    expect(practiceSet.questions.first.options, ['Hello', 'Goodbye']);
    expect(
      practiceSet.answerKeys.map((answerKey) => answerKey.correctOptionIndex),
      [0, 1],
    );
    expect(practiceSet.answerKeys.map((answerKey) => answerKey.questionIndex), [
      0,
      1,
    ]);
  });

  test('keeps domain collections immutable', () {
    final result = parser.parse(_exercise([_question()]));

    expect(
      () => result.practiceSet!.questions.add(result.practiceSet!.questions[0]),
      throwsUnsupportedError,
    );
    expect(
      () => result.practiceSet!.questions.first.options.add('Maybe'),
      throwsUnsupportedError,
    );
    expect(
      () => result.practiceSet!.answerKeys.add(
        result.practiceSet!.answerKeys.first,
      ),
      throwsUnsupportedError,
    );
  });

  test('trims whitespace without case-folding or Unicode normalization', () {
    final result = parser.parse(
      _exercise([
        {
          ..._question(),
          'options': ['Hello', ' hello ', 'é', 'e\u0301'],
          'answer': ' e\u0301 ',
        },
      ]),
    );

    expect(result.isSuccess, isTrue);
    expect(result.practiceSet!.questions.single.options, [
      'Hello',
      'hello',
      'é',
      'e\u0301',
    ]);
    expect(result.practiceSet!.answerKeys.single.correctOptionIndex, 3);
  });

  test('rejects an unsupported type and returns no partial set', () {
    final result = parser.parse(
      _exercise([
        _question(),
        {'type': 'short_answer', 'prompt': 'Explain', 'answer': 'A'},
      ]),
    );

    expect(result.isSuccess, isFalse);
    expect(result.practiceSet, isNull);
    expect(result.issues, hasLength(1));
    expect(result.issues.single.path, r'$.questions[1].type');
    expect(result.issues.single.code, 'unsupported_question_type');
  });

  test('rejects unsupported multiple-like identifiers without fallback', () {
    for (final type in [
      'multiple_select',
      'Multiple_Choice',
      ' multiple_choice ',
    ]) {
      final result = parser.parse(
        _exercise([
          {'type': type, 'prompt': 'Question', 'answer': 'A'},
        ]),
      );

      expect(result.practiceSet, isNull, reason: type);
      expect(
        result.issues.single.code,
        'unsupported_question_type',
        reason: type,
      );
    }
  });

  test('maps invalid multiple-choice contract to path-aware issues', () {
    final result = parser.parse(
      _exercise([
        {..._question(), 'answer': 'Not an option'},
      ]),
    );

    expect(result.practiceSet, isNull);
    expect(result.issues.single.path, r'$.questions[0].answer');
    expect(result.issues.single.code, 'answer_not_in_options');
  });

  test('rejects invalid JSON syntax', () {
    final result = parser.parse('{"schemaVersion":1,');

    expect(result.practiceSet, isNull);
    expect(result.issues.single.path, r'$');
    expect(result.issues.single.code, 'invalid_json_syntax');
  });

  test('rejects a non-object root', () {
    final result = parser.parse('[]');

    expect(result.practiceSet, isNull);
    expect(result.issues.single.path, r'$');
    expect(result.issues.single.code, 'invalid_root');
  });

  test('rejects an unsupported schema version', () {
    final result = parser.parse(_exercise([_question()], schemaVersion: 2));

    expect(result.practiceSet, isNull);
    expect(result.issues.single.path, r'$.schemaVersion');
    expect(result.issues.single.code, 'unsupported_schema_version');
  });

  test('does not modify the source JSON', () {
    final source = _exercise([
      {
        ..._question(),
        'prompt': '  Trim only in the model  ',
        'options': [' A ', 'B'],
        'answer': ' A ',
      },
    ]);
    final original = source;

    final result = parser.parse(source);

    expect(result.isSuccess, isTrue);
    expect(source, original);
    expect(
      result.practiceSet!.questions.single.prompt,
      'Trim only in the model',
    );
  });
}

Map<String, dynamic> _question() => {
  'type': 'multiple_choice',
  'prompt': 'Question',
  'options': ['A', 'B'],
  'answer': 'A',
};

String _exercise(
  List<Map<String, dynamic>> questions, {
  int schemaVersion = 1,
}) => jsonEncode({
  'schemaVersion': schemaVersion,
  'title': 'Practice set',
  'topics': ['Testing'],
  'questions': questions,
});
