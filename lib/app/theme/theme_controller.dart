import 'package:material_ui/material_ui.dart';

/// Holds the user's in-session theme choice. Persistence will be added with
/// the settings/preferences feature rather than introducing storage here.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    if (value != mode) value = mode;
  }
}
