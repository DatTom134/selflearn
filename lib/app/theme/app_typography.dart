import 'package:material_ui/material_ui.dart';

abstract final class AppTypography {
  static const display = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static const h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );
  static const h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  static const h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );
  static const title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static const button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static TextTheme get textTheme => const TextTheme(
    displayLarge: display,
    headlineLarge: h1,
    headlineMedium: h2,
    headlineSmall: h3,
    titleMedium: title,
    bodyLarge: body,
    bodyMedium: bodyMedium,
    bodySmall: caption,
    labelLarge: button,
  );
}
