import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/theme_controller.dart';
import 'features/exercises/data/repositories/local_exercise_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SelfLearnBootstrap());
}

class SelfLearnBootstrap extends StatefulWidget {
  const SelfLearnBootstrap({super.key});

  @override
  State<SelfLearnBootstrap> createState() => _SelfLearnBootstrapState();
}

class _SelfLearnBootstrapState extends State<SelfLearnBootstrap> {
  final ThemeController _themeController = ThemeController();
  late Future<LocalExerciseRepository> _repositoryFuture;

  @override
  void initState() {
    super.initState();
    _repositoryFuture = LocalExerciseRepository.createDefault();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  void _retry() {
    setState(() => _repositoryFuture = LocalExerciseRepository.createDefault());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocalExerciseRepository>(
      future: _repositoryFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SelfLearnApp(
            themeController: _themeController,
            exerciseRepository: snapshot.data!,
          );
        }
        return MaterialApp(
          title: 'SelfLearn',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: snapshot.hasError
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.storage_rounded, size: 44),
                                const SizedBox(height: 16),
                                Text(
                                  'Không thể khởi tạo Kho đề',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Không thể truy cập dữ liệu trên thiết bị. Hãy thử khởi động lại ứng dụng rồi thử lại.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: _retry,
                                  child: const Text('Thử lại'),
                                ),
                              ],
                            )
                          : const CircularProgressIndicator(),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
