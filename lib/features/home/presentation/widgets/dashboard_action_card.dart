import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_elevation.dart';
import '../../../../app/theme/app_radius.dart';

class DashboardActionCard extends StatelessWidget {
  const DashboardActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
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
          Icon(icon, color: scheme.primary, size: 26),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}
