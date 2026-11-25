class QuestionTypeRegistry {
  const QuestionTypeRegistry();

  static const Set<String> supportedTypes = {'multiple_choice'};

  bool supports(String type) => supportedTypes.contains(type);
}
