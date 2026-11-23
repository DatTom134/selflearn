import 'dart:ui';

import 'package:material_ui/material_ui.dart';

import '../theme/app_breakpoints.dart';
import '../theme/app_colors.dart';
import '../theme/app_glass.dart';
import '../theme/app_motion.dart';
import '../theme/app_radius.dart';
import 'app_destination.dart';

class GlassNavigation extends StatelessWidget {
  const GlassNavigation({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.isRail,
    this.expanded = false,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool isRail;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final destinations = AppDestination.values;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassColor = Colors.white.withValues(
      alpha: isDark
          ? AppGlass.navigationDarkOpacity
          : AppGlass.navigationLightOpacity,
    );
    final glassBorder = Colors.white.withValues(
      alpha: isDark
          ? AppGlass.navigationDarkBorderOpacity
          : AppGlass.navigationLightBorderOpacity,
    );

    if (isRail) {
      return SizedBox(
        width: expanded
            ? AppBreakpoints.expandedSidebarWidth
            : AppBreakpoints.navigationRailWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            crossAxisAlignment: expanded
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.center,
            children: [
              if (expanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
                  child: Row(
                    children: [
                      const _BrandMark(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'SelfLearn',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 28),
                  child: _BrandMark(),
                ),
              Expanded(
                child: _IndicatorStack(
                  selectedIndex: selectedIndex,
                  itemCount: destinations.length,
                  isVertical: true,
                  reduceMotion: reduceMotion,
                  glassColor: glassColor,
                  glassBorder: glassBorder,
                  itemBuilder: (index) => _NavigationItem(
                    destination: destinations[index],
                    selected: selectedIndex == index,
                    expanded: expanded,
                    onTap: () => onDestinationSelected(index),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: SizedBox(
          height: 68,
          child: _IndicatorStack(
            selectedIndex: selectedIndex,
            itemCount: destinations.length,
            isVertical: false,
            reduceMotion: reduceMotion,
            glassColor: glassColor,
            glassBorder: glassBorder,
            itemBuilder: (index) => _NavigationItem(
              destination: destinations[index],
              selected: selectedIndex == index,
              expanded: true,
              compact: true,
              onTap: () => onDestinationSelected(index),
            ),
          ),
        ),
      ),
    );
  }
}

class _IndicatorStack extends StatelessWidget {
  const _IndicatorStack({
    required this.selectedIndex,
    required this.itemCount,
    required this.isVertical,
    required this.reduceMotion,
    required this.glassColor,
    required this.glassBorder,
    required this.itemBuilder,
  });

  final int selectedIndex;
  final int itemCount;
  final bool isVertical;
  final bool reduceMotion;
  final Color glassColor;
  final Color glassBorder;
  final Widget Function(int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final extent = isVertical
            ? constraints.maxHeight / itemCount
            : constraints.maxWidth / itemCount;
        final duration = reduceMotion
            ? Duration.zero
            : AppMotion.navigationDuration;
        final indicator = AnimatedPositioned(
          duration: duration,
          curve: AppMotion.navigationCurve,
          left: isVertical ? 0 : selectedIndex * extent + 3,
          top: isVertical ? selectedIndex * extent + 3 : 0,
          bottom: isVertical ? null : 0,
          width: isVertical ? null : extent - 6,
          height: isVertical ? extent - 6 : null,
          right: isVertical ? 0 : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: AppGlass.navigationBlur,
                sigmaY: AppGlass.navigationBlur,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: glassColor,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(color: glassBorder),
                  boxShadow: Theme.of(context).brightness == Brightness.dark
                      ? const []
                      : const [
                          BoxShadow(
                            color: Color(0x0A172554),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                ),
              ),
            ),
          ),
        );

        return Stack(
          children: [
            indicator,
            if (isVertical)
              Column(
                children: List.generate(
                  itemCount,
                  (index) => Expanded(child: itemBuilder(index)),
                ),
              )
            else
              Row(
                children: List.generate(
                  itemCount,
                  (index) => Expanded(child: itemBuilder(index)),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.destination,
    required this.selected,
    required this.expanded,
    required this.onTap,
    this.compact = false,
  });

  final AppDestination destination;
  final bool selected;
  final bool expanded;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppSemanticColors>();
    final foreground = selected
        ? scheme.primary
        : (semantic?.textSecondary ?? scheme.onSurfaceVariant);
    return Semantics(
      key: ValueKey('navigation-destination-${destination.name}'),
      selected: selected,
      button: true,
      label: destination.label,
      child: Tooltip(
        message: destination.label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: expanded && !compact ? 14 : 4,
                vertical: compact ? 8 : 10,
              ),
              child: compact
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected
                              ? destination.selectedIcon
                              : destination.icon,
                          color: foreground,
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          destination.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: foreground,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: expanded
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected
                              ? destination.selectedIcon
                              : destination.icon,
                          color: foreground,
                          size: 22,
                        ),
                        if (expanded) ...[
                          const SizedBox(width: 14),
                          Flexible(
                            child: Text(
                              destination.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: foreground,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        Icons.auto_stories_rounded,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
