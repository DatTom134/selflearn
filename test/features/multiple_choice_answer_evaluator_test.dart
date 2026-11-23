import 'package:flutter_test/flutter_test.dart';
import 'package:selflearn/features/practice/domain/services/multiple_choice_answer_evaluator.dart';

void main() {
  const evaluator = MultipleChoiceAnswerEvaluator();

  test('scores a correct selection as one point', () {
    final result = evaluator.evaluate(
      optionCount: 3,
      correctOptionIndex: 1,
      selectedOptionIndex: 1,
    );

    expect(result, PracticeAnswerEvaluation.correct);
    expect(result.points, 1);
  });

  test('scores an incorrect selection as zero points', () {
    final result = evaluator.evaluate(
      optionCount: 3,
      correctOptionIndex: 1,
      selectedOptionIndex: 2,
    );

    expect(result, PracticeAnswerEvaluation.incorrect);
    expect(result.points, 0);
  });

  test('scores no selection as unanswered with zero points', () {
    final result = evaluator.evaluate(
      optionCount: 3,
      correctOptionIndex: 0,
      selectedOptionIndex: null,
    );

    expect(result, PracticeAnswerEvaluation.unanswered);
    expect(result.points, 0);
  });

  test('accepts correct options at the first, middle, and last index', () {
    for (final correctIndex in [0, 1, 2]) {
      expect(
        evaluator.evaluate(
          optionCount: 3,
          correctOptionIndex: correctIndex,
          selectedOptionIndex: correctIndex,
        ),
        PracticeAnswerEvaluation.correct,
      );
    }
  });

  test('rejects an invalid selected index', () {
    for (final selectedIndex in [-1, 3]) {
      expect(
        () => evaluator.evaluate(
          optionCount: 3,
          correctOptionIndex: 0,
          selectedOptionIndex: selectedIndex,
        ),
        throwsRangeError,
      );
    }
  });

  test('rejects an invalid correct index', () {
    for (final correctIndex in [-1, 3]) {
      expect(
        () => evaluator.evaluate(
          optionCount: 3,
          correctOptionIndex: correctIndex,
          selectedOptionIndex: null,
        ),
        throwsRangeError,
      );
    }
  });

  test('rejects an empty option list', () {
    expect(
      () => evaluator.evaluate(
        optionCount: 0,
        correctOptionIndex: 0,
        selectedOptionIndex: null,
      ),
      throwsArgumentError,
    );
  });
}
