import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/models/exercise_json_validation.dart';
import '../../domain/services/exercise_json_validator.dart';

class ExerciseImportDialog extends StatefulWidget {
  const ExerciseImportDialog({super.key});

  @override
  State<ExerciseImportDialog> createState() => _ExerciseImportDialogState();
}

class _ExerciseImportDialogState extends State<ExerciseImportDialog> {
  final TextEditingController _jsonController = TextEditingController();
  final ExerciseJsonValidator _validator = const ExerciseJsonValidator();
  ExerciseJsonValidationResult? _result;
  String? _inputError;
  bool _isReadingFile = false;
  bool _isReadingClipboard = false;

  bool get _isReadingInput => _isReadingFile || _isReadingClipboard;

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    if (_isReadingInput) return;
    setState(() {
      _isReadingFile = true;
      _inputError = null;
      _result = null;
    });
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      if (file == null || !mounted) return;

      // Reject oversized files before loading their bytes into memory.
      final reportedLength = file.lengthSync() ?? await file.length();
      if (reportedLength != null &&
          reportedLength > ExerciseJsonValidator.maxBytes) {
        setState(() => _inputError = 'Tệp vượt quá giới hạn 2 MB.');
        return;
      }

      final bytes = await file.readAsBytes();
      if (bytes.length > ExerciseJsonValidator.maxBytes) {
        setState(() => _inputError = 'Tệp vượt quá giới hạn 2 MB.');
        return;
      }
      final content = utf8.decode(bytes);
      if (!mounted) return;
      _jsonController.text = content;
      _validate();
    } on FormatException {
      if (mounted) {
        setState(() => _inputError = 'Tệp không phải văn bản UTF-8 hợp lệ.');
      }
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _inputError = 'Không thể đọc tệp. Hãy chọn lại tệp JSON hợp lệ.',
        );
      }
    } finally {
      if (mounted) setState(() => _isReadingFile = false);
    }
  }

  Future<void> _paste() async {
    if (_isReadingInput) return;
    // A failed/empty clipboard read must never leave a previous valid preview
    // active; otherwise the Save action could persist stale content.
    setState(() {
      _isReadingClipboard = true;
      _result = null;
      _inputError = null;
    });
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (!mounted) return;
      final text = data?.text;
      if (text == null || text.trim().isEmpty) {
        setState(() => _inputError = 'Clipboard không có nội dung văn bản.');
        return;
      }
      _jsonController.text = text;
      _validate();
    } catch (_) {
      if (mounted) {
        setState(
          () => _inputError =
              'Không thể đọc clipboard. Hãy sao chép JSON rồi thử lại.',
        );
      }
    } finally {
      if (mounted) setState(() => _isReadingClipboard = false);
    }
  }

  void _validate() {
    if (_isReadingInput) return;
    // Close the software keyboard before rendering the validation result so
    // the dialog actions and preview remain visible on small screens.
    FocusScope.of(context).unfocus();

    final result = _validator.validate(_jsonController.text);
    if (!mounted) return;

    setState(() {
      _result = result;
      _inputError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final validExercise = _result?.exercise;
    return Dialog(
      key: const ValueKey('exercise-import-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 620,
          maxHeight: MediaQuery.sizeOf(context).height - 48,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Nhập Exercise JSON',
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Dán JSON hoặc chọn tệp .json. Dữ liệu sẽ được kiểm tra và xem trước trước khi lưu.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _isReadingInput ? null : _pickFile,
                            icon: _isReadingFile
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.upload_file_rounded),
                            label: const Text('Chọn tệp JSON'),
                          ),
                          OutlinedButton.icon(
                            key: const ValueKey('exercise-json-paste'),
                            onPressed: _isReadingInput ? null : _paste,
                            icon: const Icon(Icons.content_paste_rounded),
                            label: const Text('Dán từ clipboard'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const ValueKey('exercise-json-input'),
                        controller: _jsonController,
                        minLines: 3,
                        maxLines: 5,
                        enabled: !_isReadingInput,
                        keyboardType: TextInputType.multiline,
                        onChanged: (_) => setState(() {
                          _result = null;
                          _inputError = null;
                        }),
                        decoration: const InputDecoration(
                          hintText: '{\n  "schemaVersion": 1,\n  "title": "...",\n  "topics": ["..."],\n  "questions": [...]\n}',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (_inputError != null) ...[
                        const SizedBox(height: 8),
                        _ErrorPanel(message: _inputError!),
                      ],
                      if (_result case final result?) ...[
                        const SizedBox(height: 12),
                        if (!result.isValid)
                          _ValidationIssues(issues: result.issues)
                        else if (validExercise != null)
                          _ExercisePreview(exercise: validExercise),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Hủy'),
                    ),
                    OutlinedButton.icon(
                      key: const ValueKey('exercise-json-validate'),
                      onPressed:
                          _isReadingInput || _jsonController.text.trim().isEmpty
                          ? null
                          : _validate,
                      icon: const Icon(Icons.fact_check_outlined),
                      label: const Text('Kiểm tra'),
                    ),
                    FilledButton.icon(
                      key: const ValueKey('exercise-json-save'),
                      onPressed: validExercise == null
                          ? null
                          : () => Navigator.of(context).pop(validExercise),
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Xác nhận lưu'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExercisePreview extends StatelessWidget {
  const _ExercisePreview({required this.exercise});

  final ValidatedExercise exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'JSON hợp lệ · Schema v1',
                  style: theme.textTheme.titleSmall,
                  softWrap: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(exercise.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            '${exercise.questionCount} câu hỏi · ${exercise.questionType} · ${exercise.difficulty ?? 'Chưa phân cấp độ'}',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: exercise.topics
                .map(
                  (topic) => Chip(
                    label: Text(
                      topic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          Text('Xem trước câu hỏi', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          ...exercise.questionPreviews.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                '${entry.key + 1}. ${entry.value}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          if (exercise.questionCount > exercise.questionPreviews.length)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+${exercise.questionCount - exercise.questionPreviews.length} câu hỏi khác',
                style: theme.textTheme.labelSmall,
              ),
            ),
        ],
      ),
    );
  }
}

class _ValidationIssues extends StatelessWidget {
  const _ValidationIssues({required this.issues});

  final List<ExerciseValidationIssue> issues;

  @override
  Widget build(BuildContext context) {
    return _ErrorPanel(
      message: 'Tìm thấy ${issues.length} vấn đề cần sửa:',
      children: issues
          .take(8)
          .map((issue) => Text('• ${issue.path} — ${issue.message}'))
          .toList(),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, this.children = const []});

  final String message;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              color: scheme.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (children.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...children.map(
              (child) => Padding(
                padding: const EdgeInsets.only(top: 3),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: scheme.onErrorContainer),
                  child: child,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
