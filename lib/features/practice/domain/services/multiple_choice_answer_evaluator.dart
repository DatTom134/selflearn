enum PracticeAnswerEvaluation {
  correct(1),
  incorrect(0),
  unanswered(0);

  const PracticeAnswerEvaluation(this.points);

  final int points;
}

class MultipleChoiceAnswerEvaluator {
  const MultipleChoiceAnswerEvaluator();

  PracticeAnswerEvaluation evaluate({
    required int optionCount,
    required int correctOptionIndex,
    required int? selectedOptionIndex,
  }) {
    if (optionCount < 1) {
      throw ArgumentError.value(
        optionCount,
        'optionCount',
        'Must be greater than zero.',
      );
    }
    if (correctOptionIndex < 0 || correctOptionIndex >= optionCount) {
      throw RangeError.range(
        correctOptionIndex,
        0,
        optionCount - 1,
        'correctOptionIndex',
      );
    }
    if (selectedOptionIndex == null) {
      return PracticeAnswerEvaluation.unanswered;
    }
    if (selectedOptionIndex < 0 || selectedOptionIndex >= optionCount) {
      throw RangeError.range(
        selectedOptionIndex,
        0,
        optionCount - 1,
        'selectedOptionIndex',
      );
    }

    return selectedOptionIndex == correctOptionIndex
        ? PracticeAnswerEvaluation.correct
        : PracticeAnswerEvaluation.incorrect;
  }
}
