import 'package:material_ui/material_ui.dart';

abstract final class AppColors {
  // Approved Blue Modern palette — Light.
  static const lightBackground = Color(0xFFF5F7FB);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFEDF2FA);
  static const lightSurfaceElevated = Color(0xFFFFFFFF);
  static const lightPrimary = Color(0xFF315FEA);
  static const lightPrimaryHover = Color(0xFF1746B5);
  static const lightPrimaryContainer = Color(0xFFEAF0FF);
  static const lightTextPrimary = Color(0xFF172554);
  static const lightTextSecondary = Color(0xFF64748B);
  static const lightTextDisabled = Color(0xFF94A3B8);
  static const lightBorder = Color(0xFFDCE4F0);
  static const lightDivider = Color(0xFFE8EDF5);

  // Approved Blue Modern palette — Dark.
  static const darkBackground = Color(0xFF0B1220);
  static const darkSurface = Color(0xFF111C2E);
  static const darkSurfaceVariant = Color(0xFF1A2940);
  static const darkSurfaceElevated = Color(0xFF22334D);
  static const darkPrimary = Color(0xFF6B91FF);
  static const darkPrimaryHover = Color(0xFF8BAAFF);
  static const darkPrimaryContainer = Color(0xFF1C315C);
  static const darkTextPrimary = Color(0xFFF1F5FF);
  static const darkTextSecondary = Color(0xFFA9B8CE);
  static const darkTextDisabled = Color(0xFF718096);
  static const darkBorder = Color(0xFF2B3B52);
  static const darkDivider = Color(0xFF25354B);

  static const lightSuccess = Color(0xFF15803D);
  static const darkSuccess = Color(0xFF4ADE80);
  static const lightWarning = Color(0xFFB45309);
  static const darkWarning = Color(0xFFFBBF24);
  static const lightError = Color(0xFFDC2626);
  static const darkError = Color(0xFFF87171);
  static const lightInfo = Color(0xFF2563EB);
  static const darkInfo = Color(0xFF60A5FA);
}

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.border,
    required this.divider,
    required this.textSecondary,
    required this.textDisabled,
    required this.surfaceVariant,
  });

  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color border;
  final Color divider;
  final Color textSecondary;
  final Color textDisabled;
  final Color surfaceVariant;

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? border,
    Color? divider,
    Color? textSecondary,
    Color? textDisabled,
    Color? surfaceVariant,
  }) => AppSemanticColors(
    success: success ?? this.success,
    warning: warning ?? this.warning,
    error: error ?? this.error,
    info: info ?? this.info,
    border: border ?? this.border,
    divider: divider ?? this.divider,
    textSecondary: textSecondary ?? this.textSecondary,
    textDisabled: textDisabled ?? this.textDisabled,
    surfaceVariant: surfaceVariant ?? this.surfaceVariant,
  );

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      error: Color.lerp(error, other.error, t) ?? error,
      info: Color.lerp(info, other.info, t) ?? info,
      border: Color.lerp(border, other.border, t) ?? border,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textDisabled:
          Color.lerp(textDisabled, other.textDisabled, t) ?? textDisabled,
      surfaceVariant:
          Color.lerp(surfaceVariant, other.surfaceVariant, t) ?? surfaceVariant,
    );
  }
}
