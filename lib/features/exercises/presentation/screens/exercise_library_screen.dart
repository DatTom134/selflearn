import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../application/exercise_library_controller.dart';
import '../../domain/models/exercise_json_validation.dart';
import '../../domain/models/exercise_set.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../widgets/exercise_detail_dialog.dart';
import '../widgets/exercise_import_dialog.dart';
import '../widgets/exercise_set_card.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key, required this.repository});

  final ExerciseRepository repository;

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  late final ExerciseLibraryController _controller;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _controller = ExerciseLibraryController(widget.repository)..load();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) _controller.setQuery(value);
    });
  }

  Future<void> _importExercise() async {
    final exercise = await showDialog<ValidatedExercise>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ExerciseImportDialog(),
    );
    if (exercise == null || !mounted) return;
    try {
      await widget.repository.importExercise(exercise);
      await _controller.refresh();
      if (mounted) _showMessage('Đã thêm bộ đề "${exercise.title}".');
    } on DuplicateExerciseException catch (error) {
      if (mounted) _showMessage(error.toString(), isError: true);
    } catch (_) {
      if (mounted) {
        _showMessage('Không thể lưu bộ đề. Hãy thử lại.', isError: true);
      }
    }
  }

  Future<void> _openDetails(ExerciseSet exercise) async {
    try {
      final json = await widget.repository.readExerciseJson(exercise.id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => ExerciseDetailDialog(exercise: exercise, json: json),
      );
    } catch (_) {
      if (mounted) {
        _showMessage('Không thể mở bộ đề. Hãy thử lại.', isError: true);
      }
    }
  }

  Future<void> _rename(ExerciseSet exercise) async {
    final title = await showDialog<String>(
      context: context,
      builder: (_) => _RenameExerciseDialog(initialTitle: exercise.title),
    );
    if (title == null || !mounted) return;
    if (title.isEmpty) {
      _showMessage('Tên bộ đề không được để trống.', isError: true);
      return;
    }
    try {
      await _controller.rename(exercise.id, title);
      if (mounted) _showMessage('Đã đổi tên bộ đề.');
    } catch (_) {
      if (mounted) {
        _showMessage('Không thể đổi tên bộ đề. Hãy thử lại.', isError: true);
      }
    }
  }

  Future<void> _export(ExerciseSet exercise) async {
    try {
      final json = await widget.repository.readExerciseJson(exercise.id);
      await SharePlus.instance.share(
        ShareParams(
          title: 'Xuất Exercise JSON',
          subject: '${exercise.title}.json',
          text: 'Exercise JSON · ${exercise.title}',
          files: [
            XFile.fromData(
              Uint8List.fromList(utf8.encode(json)),
              mimeType: 'application/json',
            ),
          ],
          fileNameOverrides: ['${_safeFileName(exercise.title)}.json'],
        ),
      );
    } catch (_) {
      if (mounted) {
        _showMessage('Không thể xuất JSON. Hãy thử lại.', isError: true);
      }
    }
  }

  Future<void> _delete(ExerciseSet exercise) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded),
        title: const Text('Xóa bộ đề này?'),
        content: Text(
          '"${exercise.title}" sẽ bị xóa khỏi Kho đề. Lịch sử học tập và từ vựng đã lưu độc lập sẽ không bị xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Giữ lại'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Xóa bộ đề'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _controller.remove(exercise.id);
      if (mounted) _showMessage('Đã xóa "${exercise.title}".');
    } catch (_) {
      if (mounted) {
        _showMessage('Không thể xóa bộ đề. Hãy thử lại.', isError: true);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }

  String _safeFileName(String value) {
    final safe = value
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
    return safe.isEmpty ? 'exercise' : safe;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildFilters(context),
          const SizedBox(height: 16),
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kho đề luyện tập', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 3),
            Text(
              'Quản lý các bộ đề Exercise JSON của bạn',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
        final action = FilledButton.icon(
          onPressed: _importExercise,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Nhập JSON'),
        );
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerLeft, child: action),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: title),
            action,
          ],
        );
      },
    );
  }

  Widget _buildFilters(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final topicFilter = InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Chủ đề',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            border: OutlineInputBorder(),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _controller.selectedTopic ?? '',
              items: [
                const DropdownMenuItem(value: '', child: Text('Tất cả chủ đề')),
                ..._controller.topics.map(
                  (topic) => DropdownMenuItem(
                    value: topic,
                    child: Text(topic, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
              onChanged: (value) => _controller.setTopic(
                value == null || value.isEmpty ? null : value,
              ),
            ),
          ),
        );
        final search = TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Tìm tên bộ đề hoặc chủ đề...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Xóa tìm kiếm',
                    onPressed: () {
                      _searchController.clear();
                      _controller.setQuery('');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        );
        if (constraints.maxWidth < 520) {
          return Column(
            children: [search, const SizedBox(height: 10), topicFilter],
          );
        }
        return Row(
          children: [
            Expanded(flex: 3, child: search),
            const SizedBox(width: 12),
            SizedBox(width: 220, child: topicFilter),
          ],
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_controller.isLoading && _controller.exercises.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.error != null && _controller.exercises.isEmpty) {
      return _MessageState(
        icon: Icons.cloud_off_rounded,
        title: 'Không thể tải Kho đề',
        message: 'Không thể truy cập dữ liệu trên thiết bị. Hãy thử lại.',
        actionLabel: 'Thử lại',
        onAction: _controller.refresh,
      );
    }
    if (_controller.exercises.isEmpty) {
      final hasFilter =
          _controller.query.isNotEmpty || _controller.selectedTopic != null;
      return _MessageState(
        icon: hasFilter
            ? Icons.search_off_rounded
            : Icons.library_books_outlined,
        title: hasFilter ? 'Không tìm thấy bộ đề' : 'Kho đề đang trống',
        message: hasFilter ? 'Thử thay đổi từ khóa hoặc chọn chủ đề khác.' : 'Nhập một Exercise JSON để tạo card bộ đề đầu tiên. Mỗi JSON sẽ được lưu thành một card độc lập.',
        actionLabel: hasFilter ? 'Xóa bộ lọc' : 'Nhập Exercise JSON',
        onAction: hasFilter
            ? () {
                _searchController.clear();
                _controller.setQuery('');
                _controller.setTopic(null);
              }
            : _importExercise,
      );
    }

    return RefreshIndicator(
      onRefresh: _controller.refresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1000
              ? 3
              : constraints.maxWidth >= 620
              ? 2
              : 1;
          if (columns == 1) {
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: _controller.exercises.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _card(_controller.exercises[index]),
            );
          }
          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 280,
            ),
            itemCount: _controller.exercises.length,
            itemBuilder: (context, index) =>
                _card(_controller.exercises[index]),
          );
        },
      ),
    );
  }

  Widget _card(ExerciseSet exercise) => ExerciseSetCard(
    exercise: exercise,
    onOpen: () => _openDetails(exercise),
    onRename: () => _rename(exercise),
    onExport: () => _export(exercise),
    onDelete: () => _delete(exercise),
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 48, color: theme.colorScheme.primary),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  FilledButton(onPressed: onAction, child: Text(actionLabel)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RenameExerciseDialog extends StatefulWidget {
  const _RenameExerciseDialog({required this.initialTitle});

  final String initialTitle;

  @override
  State<_RenameExerciseDialog> createState() => _RenameExerciseDialogState();
}

class _RenameExerciseDialogState extends State<_RenameExerciseDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Đổi tên bộ đề'),
    content: TextField(
      key: const ValueKey('exercise-rename-input'),
      controller: _controller,
      autofocus: true,
      maxLength: 180,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Tên bộ đề',
        helperText: 'Chỉ đổi tên hiển thị; JSON gốc được giữ nguyên.',
      ),
      onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Hủy'),
      ),
      FilledButton(
        key: const ValueKey('exercise-rename-save'),
        onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
        child: const Text('Lưu'),
      ),
    ],
  );
}
