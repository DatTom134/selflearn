import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(isDark: false);
  static ThemeData get dark => _build(isDark: true);

  static ThemeData _build({required bool isDark}) {
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final background = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final onSurface = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final divider = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final surfaceVariant = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSurfaceVariant;
    final primaryContainer = isDark
        ? AppColors.darkPrimaryContainer
        : AppColors.lightPrimaryContainer;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primary,
      onPrimary: isDark ? AppColors.darkBackground : Colors.white,
      secondary: primary,
      onSecondary: isDark ? AppColors.darkBackground : Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onSurface,
      secondaryContainer: surfaceVariant,
      onSecondaryContainer: onSurface,
      error: isDark ? AppColors.darkError : AppColors.lightError,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: textSecondary,
      outline: border,
      surfaceTint: primary,
      outlineVariant: divider,
      surfaceContainerHighest: surfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      dividerColor: divider,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          side: BorderSide(color: border),
        ),
        shadowColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.title.copyWith(color: onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 48),
          elevation: 0,
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),
          textStyle: AppTypography.button,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
      ),
      extensions: [
        AppSemanticColors(
          success: isDark ? AppColors.darkSuccess : AppColors.lightSuccess,
          warning: isDark ? AppColors.darkWarning : AppColors.lightWarning,
          error: isDark ? AppColors.darkError : AppColors.lightError,
          info: isDark ? AppColors.darkInfo : AppColors.lightInfo,
          border: border,
          divider: divider,
          textSecondary: textSecondary,
          textDisabled: isDark
              ? AppColors.darkTextDisabled
              : AppColors.lightTextDisabled,
          surfaceVariant: surfaceVariant,
        ),
      ],
    );
  }
}
