import 'package:material_ui/material_ui.dart';

enum AppDestination {
  home('Tổng quan', Icons.space_dashboard_outlined, Icons.space_dashboard),
  exercises('Kho đề', Icons.library_books_outlined, Icons.library_books),
  vocabulary('Từ vựng', Icons.menu_book_outlined, Icons.menu_book),
  settings('Cài đặt', Icons.settings_outlined, Icons.settings);

  const AppDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
