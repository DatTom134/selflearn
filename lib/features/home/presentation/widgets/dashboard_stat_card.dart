import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_elevation.dart';
import '../../../../app/theme/app_radius.dart';

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.caption,
    super.key,
  });

  final IconData icon;
  final String title;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: scheme.outline),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? AppElevation.none
            : AppElevation.low,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: scheme.primary, size: 20),
              ),
              const Spacer(),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 3),
          Text(
            caption,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
