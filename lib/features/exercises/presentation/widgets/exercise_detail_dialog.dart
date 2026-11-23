import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/models/exercise_set.dart';

class ExerciseDetailDialog extends StatelessWidget {
  const ExerciseDetailDialog({
    super.key,
    required this.exercise,
    required this.json,
  });

  final ExerciseSet exercise;
  final String json;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(exercise.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text('${exercise.questionCount} câu hỏi')),
                  Chip(label: Text(exercise.questionType)),
                  if (exercise.difficulty != null)
                    Chip(label: Text(exercise.difficulty!)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Chủ đề', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: exercise.topics
                    .map((topic) => Chip(label: Text(topic)))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Nội dung JSON gốc',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Sao chép JSON',
                    onPressed: () async {
                      try {
                        await Clipboard.setData(ClipboardData(text: json));
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Không thể sao chép JSON. Hãy thử lại.',
                              ),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                        }
                        return;
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã sao chép JSON.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy_rounded),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 320),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.55,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    json,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}
