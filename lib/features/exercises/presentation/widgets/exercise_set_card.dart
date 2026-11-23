import 'package:material_ui/material_ui.dart';

import '../../domain/models/exercise_set.dart';

class ExerciseSetCard extends StatelessWidget {
  const ExerciseSetCard({
    super.key,
    required this.exercise,
    required this.onOpen,
    required this.onRename,
    required this.onExport,
    required this.onDelete,
  });

  final ExerciseSet exercise;
  final VoidCallback onOpen;
  final VoidCallback onRename;
  final VoidCallback onExport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      exercise.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  PopupMenuButton<_ExerciseAction>(
                    tooltip: 'Thao tác bộ đề',
                    onSelected: (action) {
                      switch (action) {
                        case _ExerciseAction.rename:
                          onRename();
                          break;
                        case _ExerciseAction.export:
                          onExport();
                          break;
                        case _ExerciseAction.delete:
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _ExerciseAction.rename,
                        child: _ActionLabel(Icons.edit_outlined, 'Đổi tên'),
                      ),
                      PopupMenuItem(
                        value: _ExerciseAction.export,
                        child: _ActionLabel(
                          Icons.ios_share_rounded,
                          'Xuất JSON',
                        ),
                      ),
                      PopupMenuItem(
                        value: _ExerciseAction.delete,
                        child: _ActionLabel(
                          Icons.delete_outline_rounded,
                          'Xóa bộ đề',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: exercise.topics
                    .take(4)
                    .map((topic) => _TopicChip(topic))
                    .toList(),
              ),
              if (exercise.topics.length > 4) ...[
                const SizedBox(height: 4),
                Text(
                  '+${exercise.topics.length - 4} chủ đề khác',
                  style: theme.textTheme.labelSmall,
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _Metadata(
                    Icons.quiz_outlined,
                    '${exercise.questionCount} câu',
                  ),
                  _Metadata(Icons.category_outlined, exercise.questionType),
                  if (exercise.difficulty != null)
                    _Metadata(
                      Icons.signal_cellular_alt_rounded,
                      exercise.difficulty!,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Đã nhập ${_formatDate(exercise.importedAt)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  TextButton(onPressed: onOpen, child: const Text('Chi tiết')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 156),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}

class _Metadata extends StatelessWidget {
  const _Metadata(this.icon, this.value);
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _ActionLabel extends StatelessWidget {
  const _ActionLabel(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [Icon(icon, size: 18), const SizedBox(width: 10), Text(label)],
  );
}

enum _ExerciseAction { rename, export, delete }
