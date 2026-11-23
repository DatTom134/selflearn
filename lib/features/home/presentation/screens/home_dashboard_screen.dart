import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_breakpoints.dart';
import '../../../../app/theme/app_elevation.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../widgets/dashboard_action_card.dart';
import '../widgets/dashboard_stat_card.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isWide =
        MediaQuery.sizeOf(context).width >=
        AppBreakpoints.wideDashboardMinWidth;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20, bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KHÔNG GIAN HỌC TẬP CỦA BẠN',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chào mừng trở lại!',
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sẵn sàng tiếp tục hành trình học tập hôm nay?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (MediaQuery.sizeOf(context).width >
                  AppBreakpoints.phoneMaxWidth)
                const _DatePill(),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxl),
          _WelcomePanel(isWide: isWide),
          const SizedBox(height: AppSpacing.xxxl),
          Text('Tổng quan', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 3
                  : constraints.maxWidth >= 520
                  ? 2
                  : 1;
              const gap = 12.0;
              final cardWidth =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: const DashboardStatCard(
                      icon: Icons.library_books_outlined,
                      title: 'Bộ đề đã lưu',
                      value: '0',
                      caption: 'Bắt đầu xây dựng kho đề',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: const DashboardStatCard(
                      icon: Icons.menu_book_outlined,
                      title: 'Từ vựng đã lưu',
                      value: '0',
                      caption: 'Lưu từ trong lúc luyện tập',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: const DashboardStatCard(
                      icon: Icons.local_fire_department_outlined,
                      title: 'Chuỗi ngày học',
                      value: '—',
                      caption: 'Theo dõi khi bắt đầu học',
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text('Bắt đầu nhanh', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 650 ? 2 : 1;
              final width =
                  (constraints.maxWidth - 12 * (columns - 1)) / columns;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: width,
                    child: DashboardActionCard(
                      icon: Icons.auto_awesome_outlined,
                      title: 'Tạo mẫu đề JSON',
                      description: 'Chuẩn bị cấu trúc để tạo câu hỏi bằng ChatGPT hoặc Gemini.',
                      actionLabel: 'Tìm hiểu quy trình',
                      onPressed: () => _showComingSoon(context),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: DashboardActionCard(
                      icon: Icons.file_upload_outlined,
                      title: 'Nhập bộ đề',
                      description: 'Dán nội dung JSON hoặc chọn file để kiểm tra và xem trước.',
                      actionLabel: 'Sắp ra mắt',
                      onPressed: null,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxxl),
          const _RecentActivityEmptyState(),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Quy trình tạo mẫu JSON sẽ được triển khai ở phase tiếp theo.',
        ),
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 28 : 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.large),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.primary.withValues(alpha: 0.82)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Học theo cách của bạn',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tạo bộ đề phù hợp, luyện tập chủ động và lưu lại những từ vựng đáng nhớ.',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: Colors.white.withValues(alpha: 0.88)),
                ),
              ],
            ),
          ),
          if (isWide) ...[
            const SizedBox(width: 20),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, size: 16),
          const SizedBox(width: 8),
          Text(
            'Không gian học tập',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _RecentActivityEmptyState extends StatelessWidget {
  const _RecentActivityEmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: scheme.outline),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? AppElevation.none
            : AppElevation.low,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(Icons.history_rounded, color: scheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoạt động gần đây',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Lịch sử học tập sẽ xuất hiện tại đây khi bạn bắt đầu luyện tập.',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
