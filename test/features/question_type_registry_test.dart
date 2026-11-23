import 'package:flutter_test/flutter_test.dart';
import 'package:selflearn/features/exercises/domain/services/question_type_registry.dart';

void main() {
  const registry = QuestionTypeRegistry();

  test('supports the exact multiple_choice identifier', () {
    expect(registry.supports('multiple_choice'), isTrue);
  });

  test('does not infer support from other or similarly named identifiers', () {
    for (final type in [
      'short_answer',
      'fill_blank',
      'multiple_select',
      'Multiple_Choice',
      ' multiple_choice ',
      'prefix_multiple_choice_suffix',
    ]) {
      expect(registry.supports(type), isFalse, reason: type);
    }
  });
}
