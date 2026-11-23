# Architecture Overview — App Foundation

## Current structure

```text
lib/
  app/
    app.dart
    navigation/
      app_destination.dart
      glass_navigation.dart
    theme/
      app_breakpoints.dart
      app_colors.dart
      app_elevation.dart
      app_glass.dart
      app_motion.dart
      app_radius.dart
      app_spacing.dart
      app_theme.dart
      app_typography.dart
      theme_controller.dart
  features/
    home/presentation/
      screens/home_dashboard_screen.dart
      widgets/
        dashboard_action_card.dart
        dashboard_stat_card.dart
    placeholder/presentation/placeholder_screen.dart
  main.dart
```

The shell owns the selected top-level destination and the theme-mode controller. Feature screens remain presentation-only. The current dashboard contains placeholder counts, not persisted domain data.

## Theme behavior

- `ThemeMode.system` is the default.
- Light and dark token sets are defined in `AppColors` and applied by `AppTheme`.
- `ThemeController` currently holds the selection in memory only. Persistent preference belongs to the future Settings/data implementation.

## Responsive behavior

- Width <= 599 logical px: phone header and bottom navigation.
- Width 600–839 logical px: compact NavigationRail.
- Width >= 840 logical px: expanded 252 px sidebar.
- Dashboard content is constrained to 1440 logical px and changes its card grid based on available width.

These are implementation defaults based on the approved design system and must be verified on physical devices and window sizes.
