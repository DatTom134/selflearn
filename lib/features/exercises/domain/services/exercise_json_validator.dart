import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/exercise_json_validation.dart';

class ExerciseJsonValidator {
  const ExerciseJsonValidator();

  static const int maxBytes = 2 * 1024 * 1024;
  static const int supportedSchemaVersion = 1;

  ExerciseJsonValidationResult validate(String source) {
    final issues = <ExerciseValidationIssue>[];
    // UTF-8 bytes are never fewer than Dart string code units. This fast
    // guard avoids allocating a huge encoded copy for obviously oversized
    // pasted input; the byte-accurate check still handles multibyte text.
    if (source.length > maxBytes || utf8.encode(source).length > maxBytes) {
      return ExerciseJsonValidationResult.invalid([
        const ExerciseValidationIssue(
          path: r'$',
          message: 'Tệp vượt quá giới hạn 2 MB.',
        ),
      ]);
    }
    if (source.trim().isEmpty) {
      return ExerciseJsonValidationResult.invalid([
        const ExerciseValidationIssue(
          path: r'$',
          message: 'Nội dung JSON đang trống.',
        ),
      ]);
    }

    Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      return ExerciseJsonValidationResult.invalid([
        ExerciseValidationIssue(
          path: r'$',
          message: 'Sai cú pháp JSON: ${error.message}',
        ),
      ]);
    }

    if (decoded is! Map<String, dynamic>) {
      return ExerciseJsonValidationResult.invalid([
        const ExerciseValidationIssue(
          path: r'$',
          message: 'Phần tử gốc phải là một JSON object.',
        ),
      ]);
    }
    final root = decoded;

    final schemaVersion = root['schemaVersion'];
    if (schemaVersion is! int) {
      issues.add(
        const ExerciseValidationIssue(
          path: r'$.schemaVersion',
          message: 'Bắt buộc là số nguyên phiên bản schema.',
        ),
      );
    } else if (schemaVersion != supportedSchemaVersion) {
      issues.add(
        ExerciseValidationIssue(
          path: r'$.schemaVersion',
          message:
              'Phiên bản $schemaVersion chưa được hỗ trợ. Hiện hỗ trợ v$supportedSchemaVersion.',
        ),
      );
    }

    final sourceId = _optionalString(root['id'], r'$.id', issues);
    final title = _requiredString(root['title'], r'$.title', issues);
    final topics = _readTopics(root['topics'], issues);
    final questions = _readQuestions(root['questions'], issues);
    final difficulty = _optionalString(
      root['difficulty'],
      r'$.difficulty',
      issues,
      maxLength: 60,
    );
    final declaredQuestionType = _optionalString(
      root['questionType'],
      r'$.questionType',
      issues,
      maxLength: 60,
    );

    if (issues.isNotEmpty ||
        title == null ||
        topics == null ||
        questions == null) {
      return ExerciseJsonValidationResult.invalid(issues);
    }

    final questionTypes =
        questions.map((question) => question['type'] as String).toSet().toList()
          ..sort();
    final questionType =
        declaredQuestionType ??
        (questionTypes.length == 1
            ? questionTypes.single
            : '${questionTypes.length} dạng bài');

    final fingerprintQuestions = questions
        .map((question) {
          final content = Map<String, dynamic>.from(question)..remove('id');
          return content;
        })
        .toList(growable: false);
    final canonicalJson = jsonEncode(
      _canonicalize({
        'schemaVersion': schemaVersion,
        'questions': fingerprintQuestions,
      }),
    );
    final hash = sha256.convert(utf8.encode(canonicalJson)).toString();

    return ExerciseJsonValidationResult.valid(
      ValidatedExercise(
        sourceId: sourceId,
        title: title,
        topics: topics,
        questionType: questionType,
        difficulty: difficulty,
        questionCount: questions.length,
        questionPreviews: questions
            .take(3)
            .map(
              (question) =>
                  (question['prompt'] ?? question['question']) as String,
            )
            .toList(growable: false),
        rawJson: source,
        canonicalJson: canonicalJson,
        contentHash: hash,
      ),
    );
  }

  String? _requiredString(
    Object? value,
    String path,
    List<ExerciseValidationIssue> issues,
  ) {
    if (value is! String || value.trim().isEmpty) {
      issues.add(
        ExerciseValidationIssue(
          path: path,
          message: 'Bắt buộc là chuỗi không được để trống.',
        ),
      );
      return null;
    }
    if (value.trim().length > 180 && path == r'$.title') {
      issues.add(
        ExerciseValidationIssue(
          path: path,
          message: 'Không được dài quá 180 ký tự.',
        ),
      );
      return null;
    }
    return value.trim();
  }

  String? _optionalString(
    Object? value,
    String path,
    List<ExerciseValidationIssue> issues, {
    int maxLength = 120,
  }) {
    if (value == null) return null;
    if (value is! String || value.trim().isEmpty) {
      issues.add(
        ExerciseValidationIssue(
          path: path,
          message: 'Nếu có, giá trị phải là chuỗi không được để trống.',
        ),
      );
      return null;
    }
    if (value.trim().length > maxLength) {
      issues.add(
        ExerciseValidationIssue(
          path: path,
          message: 'Không được dài quá $maxLength ký tự.',
        ),
      );
      return null;
    }
    return value.trim();
  }

  List<String>? _readTopics(
    Object? value,
    List<ExerciseValidationIssue> issues,
  ) {
    if (value is! List || value.isEmpty) {
      issues.add(
        const ExerciseValidationIssue(
          path: r'$.topics',
          message: 'Phải là danh sách có ít nhất một chủ đề.',
        ),
      );
      return null;
    }
    final topics = <String>[];
    for (var index = 0; index < value.length; index++) {
      final topic = value[index];
      if (topic is! String || topic.trim().isEmpty) {
        issues.add(
          ExerciseValidationIssue(
            path: '\u0024.topics[$index]',
            message: 'Chủ đề phải là chuỗi không được để trống.',
          ),
        );
        continue;
      }
      final normalized = topic.trim();
      if (normalized.length > 80) {
        issues.add(
          ExerciseValidationIssue(
            path: '\u0024.topics[$index]',
            message: 'Chủ đề không được dài quá 80 ký tự.',
          ),
        );
        continue;
      }
      if (!topics.any(
        (item) => item.toLowerCase() == normalized.toLowerCase(),
      )) {
        topics.add(normalized);
      }
    }
    return topics.isEmpty ? null : topics;
  }

  List<Map<String, dynamic>>? _readQuestions(
    Object? value,
    List<ExerciseValidationIssue> issues,
  ) {
    if (value is! List || value.isEmpty) {
      issues.add(
        const ExerciseValidationIssue(
          path: r'$.questions',
          message: 'Phải có ít nhất một câu hỏi.',
        ),
      );
      return null;
    }
    if (value.length > 500) {
      issues.add(
        const ExerciseValidationIssue(
          path: r'$.questions',
          message: 'Một bộ đề không được vượt quá 500 câu hỏi.',
        ),
      );
      return null;
    }

    final questions = <Map<String, dynamic>>[];
    final ids = <String>{};
    for (var index = 0; index < value.length; index++) {
      final path = '\u0024.questions[$index]';
      final item = value[index];
      if (item is! Map<String, dynamic>) {
        issues.add(
          ExerciseValidationIssue(
            path: path,
            message: 'Mỗi câu hỏi phải là một JSON object.',
          ),
        );
        continue;
      }
      final type = _requiredString(item['type'], '$path.type', issues);
      final promptValue = item['prompt'] ?? item['question'];
      final prompt = _requiredString(promptValue, '$path.prompt', issues);
      if (!item.containsKey('answer') && !item.containsKey('answers')) {
        issues.add(
          ExerciseValidationIssue(
            path: '$path.answer',
            message: 'Thiếu đáp án (answer hoặc answers).',
          ),
        );
      } else if (item['answer'] == null && item['answers'] == null) {
        issues.add(
          ExerciseValidationIssue(
            path: '$path.answer',
            message: 'Đáp án không được null.',
          ),
        );
      }
      final id = item['id'];
      if (id != null) {
        if (id is! String || id.trim().isEmpty) {
          issues.add(
            ExerciseValidationIssue(
              path: '$path.id',
              message: 'ID câu hỏi phải là chuỗi không được để trống.',
            ),
          );
        } else if (!ids.add(id.trim())) {
          issues.add(
            ExerciseValidationIssue(
              path: '$path.id',
              message: 'ID câu hỏi bị trùng: ${id.trim()}.',
            ),
          );
        }
      }
      if (type != null && type.toLowerCase().contains('multiple')) {
        final options = item['options'];
        if (options is! List || options.length < 2) {
          issues.add(
            ExerciseValidationIssue(
              path: '$path.options',
              message: 'Câu hỏi trắc nghiệm cần ít nhất hai lựa chọn.',
            ),
          );
        } else {
          final answer = item['answer'];
          if (options.any(
            (option) => option is! String || option.trim().isEmpty,
          )) {
            issues.add(
              ExerciseValidationIssue(
                path: '$path.options',
                message: 'Mỗi lựa chọn phải là chuỗi không được để trống.',
              ),
            );
          }
          if (answer is String && !options.contains(answer)) {
            issues.add(
              ExerciseValidationIssue(
                path: '$path.answer',
                message: 'Đáp án không nằm trong danh sách options.',
              ),
            );
          }
        }
      }
      if (type != null && prompt != null) questions.add(item);
    }
    return questions.isEmpty ? null : questions;
  }

  Object? _canonicalize(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((key) => key.toString()).toList()..sort();
      return <String, Object?>{
        for (final key in keys) key: _canonicalize(value[key]),
      };
    }
    if (value is List) return value.map(_canonicalize).toList(growable: false);
    return value;
  }
}
