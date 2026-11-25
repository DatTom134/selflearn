import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:selflearn/features/exercises/domain/services/exercise_json_validator.dart';

void main() {
  const validator = ExerciseJsonValidator();

  test('accepts schema v1 and keeps multiple topics in one exercise', () {
    final result = validator.validate(_validJson);

    expect(result.isValid, isTrue);
    expect(result.exercise!.topics, ['English', 'Greetings']);
    expect(result.exercise!.questionCount, 2);
    expect(result.exercise!.questionPreviews, ['Choose hello', 'Say goodbye']);
    expect(result.exercise!.sourceId, 'exercise-001');
  });

  test('reports invalid JSON syntax with a useful message', () {
    final result = validator.validate('{"schemaVersion": 1,');

    expect(result.isValid, isFalse);
    expect(result.issues.single.path, r'$');
    expect(result.issues.single.message, contains('Sai cú pháp JSON'));
  });

  test('rejects unsupported schema versions', () {
    final result = validator.validate(
      _validJson.replaceFirst('"schemaVersion": 1', '"schemaVersion": 2'),
    );

    expect(result.isValid, isFalse);
    expect(
      result.issues.any((issue) => issue.path == r'$.schemaVersion'),
      isTrue,
    );
  });

  test('reports missing answer and duplicate question ids', () {
    const json = '''{
      "schemaVersion": 1,
      "title": "Invalid set",
      "topics": ["Math"],
      "questions": [
        {"id": "q1", "type": "short_answer", "prompt": "First", "answer": "A"},
        {"id": "q1", "type": "short_answer", "prompt": "Second"}
      ]
    }''';
    final result = validator.validate(json);

    expect(result.isValid, isFalse);
    expect(
      result.issues.any((issue) => issue.path.endsWith('.answer')),
      isTrue,
    );
    expect(
      result.issues.any(
        (issue) => issue.message.contains('ID câu hỏi bị trùng'),
      ),
      isTrue,
    );
  });

  test('rejects a multiple-choice answer that is not one of its options', () {
    const json = '''{
      "schemaVersion": 1,
      "title": "Invalid answer",
      "topics": ["English"],
      "questions": [
        {
          "type": "multiple_choice",
          "prompt": "Choose hello",
          "options": ["Hello", "Goodbye"],
          "answer": "Welcome"
        }
      ]
    }''';

    final result = validator.validate(json);

    expect(result.isValid, isFalse);
    expect(
      result.issues.any(
        (issue) =>
            issue.path.endsWith('.answer') &&
            issue.message.contains('không nằm trong danh sách'),
      ),
      isTrue,
    );
  });

  group('multiple_choice contract', () {
    test('rejects a question without a type', () {
      final question = _validMultipleChoiceQuestion()..remove('type');
      final result = validator.validate(_exerciseFor(question));

      expect(result.isValid, isFalse);
      expect(
        result.issues.any((issue) => issue.path == r'$.questions[0].type'),
        isTrue,
      );
    });

    test('accepts trimmed prompt aliases and answer-option matching', () {
      final result = validator.validate(
        _exerciseFor({
          'type': 'multiple_choice',
          'prompt': '  Chọn đáp án  ',
          'question': 'Chọn đáp án',
          'options': ['  Xin chào ', 'Tạm biệt'],
          'answer': ' Xin chào ',
        }),
      );

      expect(result.isValid, isTrue);
      expect(result.issues, isEmpty);
    });

    test('accepts the question alias when prompt is absent', () {
      final result = validator.validate(
        _exerciseFor({
          'type': 'multiple_choice',
          'question': '  Chọn đáp án  ',
          'options': ['Xin chào', 'Tạm biệt'],
          'answer': 'Xin chào',
        }),
      );

      expect(result.isValid, isTrue);
      expect(result.issues, isEmpty);
    });

    test('rejects conflicting prompt aliases', () {
      final result = validator.validate(
        _exerciseFor({
          'type': 'multiple_choice',
          'prompt': 'Prompt A',
          'question': 'Prompt B',
          'options': ['A', 'B'],
          'answer': 'A',
        }),
      );

      expect(
        result.issues.any(
          (issue) => issue.code == 'conflicting_prompt_aliases',
        ),
        isTrue,
      );
    });

    test('does not apply multiple-choice rules to other type identifiers', () {
      for (final type in [
        'short_answer',
        'multiple_select',
        'Multiple_Choice',
        ' multiple_choice ',
      ]) {
        final result = validator.validate(
          _exerciseFor({'type': type, 'prompt': 'Question', 'answer': 'A'}),
        );

        expect(result.isValid, isTrue, reason: type);
      }
    });

    final invalidCases = <String, (Map<String, dynamic>, String)>{
      'missing options': (() {
        final question = _validMultipleChoiceQuestion();
        question.remove('options');
        return (question, 'invalid_options');
      })(),
      'options not an array': (
        {..._validMultipleChoiceQuestion(), 'options': 'A, B'},
        'invalid_options',
      ),
      'fewer than two options': (
        {
          ..._validMultipleChoiceQuestion(),
          'options': ['A'],
        },
        'invalid_options',
      ),
      'non-string option': (
        {
          ..._validMultipleChoiceQuestion(),
          'options': ['A', 2],
        },
        'invalid_options',
      ),
      'empty option': (
        {
          ..._validMultipleChoiceQuestion(),
          'options': ['A', '  '],
        },
        'invalid_options',
      ),
      'duplicate option after trimming': (
        {
          ..._validMultipleChoiceQuestion(),
          'options': ['A', ' A '],
        },
        'duplicate_option',
      ),
      'missing answer': (() {
        final question = _validMultipleChoiceQuestion();
        question.remove('answer');
        return (question, 'answer_required');
      })(),
      'null answer': (
        {..._validMultipleChoiceQuestion(), 'answer': null},
        'invalid_answer',
      ),
      'non-string answer': (
        {
          ..._validMultipleChoiceQuestion(),
          'answer': ['A'],
        },
        'invalid_answer',
      ),
      'answer with different case': (
        {..._validMultipleChoiceQuestion(), 'answer': 'hello'},
        'answer_not_in_options',
      ),
      'answer not in options': (
        {..._validMultipleChoiceQuestion(), 'answer': 'C'},
        'answer_not_in_options',
      ),
      'answers instead of answer': (() {
        final question = _validMultipleChoiceQuestion();
        question.remove('answer');
        question['answers'] = ['A'];
        return (question, 'answers_not_supported');
      })(),
      'answer and answers together': (
        {
          ..._validMultipleChoiceQuestion(),
          'answers': ['A'],
        },
        'answers_not_supported',
      ),
    };

    for (final entry in invalidCases.entries) {
      test('rejects ${entry.key}', () {
        final result = validator.validate(_exerciseFor(entry.value.$1));

        expect(result.isValid, isFalse);
        expect(
          result.issues.any((issue) => issue.code == entry.value.$2),
          isTrue,
          reason: result.issues.map((issue) => issue.toString()).join('\n'),
        );
      });
    }

    test('does not report an answer mismatch when options are invalid', () {
      final question = _validMultipleChoiceQuestion()..remove('options');
      final result = validator.validate(_exerciseFor(question));

      expect(
        result.issues.any((issue) => issue.code == 'invalid_options'),
        isTrue,
      );
      expect(
        result.issues.any((issue) => issue.code == 'answer_not_in_options'),
        isFalse,
      );
    });
  });

  test('collapses duplicate topics without changing their first spelling', () {
    const json = '''{
      "schemaVersion": 1,
      "title": "Topic normalization",
      "topics": ["English", " english ", "Grammar"],
      "questions": [
        {"type": "short_answer", "prompt": "Hello?", "answer": "Hello"}
      ]
    }''';

    final result = validator.validate(json);

    expect(result.isValid, isTrue);
    expect(result.exercise!.topics, ['English', 'Grammar']);
  });

  test('rejects an empty question list', () {
    const json = '''{
      "schemaVersion": 1,
      "title": "Empty",
      "topics": ["English"],
      "questions": []
    }''';

    final result = validator.validate(json);

    expect(result.isValid, isFalse);
    expect(result.issues.any((issue) => issue.path == r'$.questions'), isTrue);
  });

  test('content hash ignores set metadata and question IDs', () {
    const first = '''{
      "schemaVersion": 1,
      "id": "source-a",
      "title": "First title",
      "topics": ["Math"],
      "questions": [
        {"id": "q1", "type": "short_answer", "prompt": "2+2?", "answer": "4"}
      ]
    }''';
    const second = '''{
      "schemaVersion": 1,
      "id": "source-b",
      "title": "Another title",
      "topics": ["Science"],
      "questions": [
        {"id": "different-question-id", "type": "short_answer", "prompt": "2+2?", "answer": "4"}
      ]
    }''';

    expect(
      validator.validate(first).exercise!.contentHash,
      validator.validate(second).exercise!.contentHash,
    );
  });

  test('canonical content hash is independent of object key order', () {
    const first =
        '{"schemaVersion":1,"title":"Same","topics":["Math"],"questions":[{"type":"short_answer","prompt":"2+2?","answer":"4"}]}';
    const second =
        '{"questions":[{"answer":"4","prompt":"2+2?","type":"short_answer"}],"topics":["Math"],"title":"Same","schemaVersion":1}';

    expect(
      validator.validate(first).exercise!.contentHash,
      validator.validate(second).exercise!.contentHash,
    );
  });

  test('enforces the byte limit for multibyte UTF-8 input', () {
    final source = List.filled(
      ExerciseJsonValidator.maxBytes ~/ 2 + 1,
      'é',
    ).join();

    expect(source.length, lessThanOrEqualTo(ExerciseJsonValidator.maxBytes));
    final result = validator.validate(source);

    expect(result.isValid, isFalse);
    expect(result.issues.single.message, contains('2 MB'));
  });

  test('rejects input larger than two megabytes', () {
    final result = validator.validate(
      List.filled(ExerciseJsonValidator.maxBytes + 1, ' ').join(),
    );

    expect(result.isValid, isFalse);
    expect(result.issues.single.message, contains('2 MB'));
  });
}

const _validJson = '''{
  "schemaVersion": 1,
  "id": "exercise-001",
  "title": "English A1 - Greetings",
  "topics": ["English", "Greetings"],
  "questionType": "mixed",
  "difficulty": "Beginner",
  "questions": [
    {"id": "q1", "type": "multiple_choice", "prompt": "Choose hello", "options": ["Hello", "Bye"], "answer": "Hello"},
    {"id": "q2", "type": "short_answer", "prompt": "Say goodbye", "answer": "Goodbye"}
  ]
}''';

Map<String, dynamic> _validMultipleChoiceQuestion() => {
  'type': 'multiple_choice',
  'prompt': 'Choose one',
  'options': ['A', 'B'],
  'answer': 'A',
};

String _exerciseFor(Map<String, dynamic> question) => jsonEncode({
  'schemaVersion': 1,
  'title': 'Test exercise',
  'topics': ['Testing'],
  'questions': [question],
});
