import 'package:material_ui/material_ui.dart';

import '../features/home/presentation/screens/home_dashboard_screen.dart';
import '../features/exercises/domain/repositories/exercise_repository.dart';
import '../features/exercises/presentation/screens/exercise_library_screen.dart';
import '../features/placeholder/presentation/placeholder_screen.dart';
import 'navigation/app_destination.dart';
import 'navigation/glass_navigation.dart';
import 'theme/app_breakpoints.dart';
import 'theme/app_spacing.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

class SelfLearnApp extends StatefulWidget {
  const SelfLearnApp({
    super.key,
    required this.themeController,
    required this.exerciseRepository,
  });

  final ThemeController themeController;
  final ExerciseRepository exerciseRepository;

  @override
  State<SelfLearnApp> createState() => _SelfLearnAppState();
}

class _SelfLearnAppState extends State<SelfLearnApp> {
  @override
  void initState() {
    super.initState();
    widget.themeController.addListener(_handleThemeChanged);
  }

  @override
  void didUpdateWidget(covariant SelfLearnApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeController != widget.themeController) {
      oldWidget.themeController.removeListener(_handleThemeChanged);
      widget.themeController.addListener(_handleThemeChanged);
    }
  }

  @override
  void dispose() {
    widget.themeController.removeListener(_handleThemeChanged);
    super.dispose();
  }

  void _handleThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SelfLearn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: widget.themeController.value,
      home: AppShell(
        themeController: widget.themeController,
        exerciseRepository: widget.exerciseRepository,
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.themeController,
    required this.exerciseRepository,
  });

  final ThemeController themeController;
  final ExerciseRepository exerciseRepository;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  void _selectDestination(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isPhone = width <= AppBreakpoints.phoneMaxWidth;
        final isExpandedSidebar =
            width >= AppBreakpoints.expandedSidebarMinWidth;
        final isRail = !isPhone;

        final page = switch (_selectedIndex) {
          0 => HomeDashboardScreen(
            onOpenExercises: () => _selectDestination(1),
          ),
          1 => ExerciseLibraryScreen(repository: widget.exerciseRepository),
          _ => PlaceholderScreen(
            destination: AppDestination.values[_selectedIndex],
          ),
        };

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Row(
              children: [
                if (isRail)
                  GlassNavigation(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _selectDestination,
                    isRail: true,
                    expanded: isExpandedSidebar,
                  ),
                Expanded(
                  child: Column(
                    children: [
                      if (isPhone)
                        _PhoneHeader(themeController: widget.themeController)
                      else
                        _TabletHeader(
                          destination: AppDestination.values[_selectedIndex],
                          themeController: widget.themeController,
                        ),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: AppBreakpoints.maxContentWidth,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isPhone
                                    ? AppSpacing.phoneInset
                                    : AppSpacing.tabletInset,
                              ),
                              child: page,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: isPhone
              ? GlassNavigation(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _selectDestination,
                  isRail: false,
                )
              : null,
        );
      },
    );
  }
}

class _PhoneHeader extends StatelessWidget {
  const _PhoneHeader({required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Text('SelfLearn', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          ThemeModeButton(controller: themeController),
        ],
      ),
    );
  }
}

class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({required this.controller, super.key});

  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ThemeMode>(
      tooltip: 'Giao diện',
      initialValue: controller.value,
      onSelected: controller.setThemeMode,
      icon: const Icon(Icons.contrast_rounded),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: ThemeMode.system,
          child: _ThemeMenuLabel(
            icon: Icons.settings_suggest_outlined,
            label: 'Theo hệ thống',
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.light,
          child: _ThemeMenuLabel(
            icon: Icons.light_mode_outlined,
            label: 'Sáng',
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: _ThemeMenuLabel(icon: Icons.dark_mode_outlined, label: 'Tối'),
        ),
      ],
    );
  }
}

class _ThemeMenuLabel extends StatelessWidget {
  const _ThemeMenuLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [Icon(icon, size: 20), const SizedBox(width: 12), Text(label)],
  );
}

class _TabletHeader extends StatelessWidget {
  const _TabletHeader({
    required this.destination,
    required this.themeController,
  });

  final AppDestination destination;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
      child: Row(
        children: [
          Text(
            destination.label,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          ThemeModeButton(controller: themeController),
        ],
      ),
    );
  }
}
