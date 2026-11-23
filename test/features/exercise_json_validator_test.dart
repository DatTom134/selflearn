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
