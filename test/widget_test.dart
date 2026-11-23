import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:selflearn/app/app.dart';
import 'package:selflearn/app/theme/theme_controller.dart';
import 'package:selflearn/features/exercises/presentation/screens/exercise_library_screen.dart';

import 'support/fake_exercise_repository.dart';

const _validExerciseJson = '''{
  "schemaVersion": 1,
  "id": "sample-001",
  "title": "English A1 - Greetings",
  "topics": ["English", "Greetings"],
  "questionType": "multiple_choice",
  "difficulty": "Beginner",
  "questions": [
    {"id": "q1", "type": "multiple_choice", "prompt": "Choose hello", "options": ["Hello", "Bye"], "answer": "Hello"}
  ]
}''';

void main() {
  late ThemeController themeController;
  late FakeExerciseRepository exerciseRepository;

  setUp(() {
    themeController = ThemeController();
    exerciseRepository = FakeExerciseRepository();
  });

  tearDown(() {
    themeController.dispose();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      SelfLearnApp(
        themeController: themeController,
        exerciseRepository: exerciseRepository,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the initial home dashboard on a phone', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester);

    expect(find.text('Chào mừng trở lại!'), findsOneWidget);
    expect(find.text('Tổng quan'), findsWidgets);
    expect(find.text('Bộ đề đã lưu'), findsOneWidget);
    expect(find.byTooltip('Giao diện'), findsOneWidget);
  });

  testWidgets('dashboard quick action opens the Exercise JSON library', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester);
    final openLibrary = find.text('Mở kho đề');
    await tester.ensureVisible(openLibrary);
    await tester.tap(openLibrary);
    await tester.pumpAndSettle();

    expect(find.byType(ExerciseLibraryScreen), findsOneWidget);
    expect(find.text('Kho đề đang trống'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone navigation opens the Exercise JSON library', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester);
    await tester.tap(
      find.byKey(const ValueKey('navigation-destination-exercises')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ExerciseLibraryScreen), findsOneWidget);
    expect(find.text('Kho đề đang trống'), findsOneWidget);
    expect(find.text('Nhập Exercise JSON'), findsOneWidget);
  });

  testWidgets('tablet uses a navigation rail and keeps theme controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester);

    expect(find.byTooltip('Giao diện'), findsOneWidget);
    expect(find.text('SelfLearn'), findsOneWidget);
    expect(find.text('Từ vựng'), findsOneWidget);
  });

  testWidgets('Exercise Library renders on a tablet without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester);
    await tester.tap(
      find.byKey(const ValueKey('navigation-destination-exercises')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ExerciseLibraryScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('theme menu switches between light and dark', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Giao diện'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tối'));
    await tester.pumpAndSettle();

    expect(themeController.value, ThemeMode.dark);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });

  testWidgets('keeps the selected destination when switching layouts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester);
    await tester.tap(
      find.byKey(const ValueKey('navigation-destination-vocabulary')),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Khu vực này sẽ được triển khai ở bước tiếp theo.'),
      findsOneWidget,
    );

    tester.view.physicalSize = const Size(900, 700);
    await tester.pumpAndSettle();

    expect(
      find.text('Khu vực này sẽ được triển khai ở bước tiếp theo.'),
      findsOneWidget,
    );
    expect(find.text('Từ vựng'), findsWidgets);
  });

  testWidgets('renders without overflow on a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('import preview stays within a narrow phone dialog', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester);
    await tester.tap(
      find.byKey(const ValueKey('navigation-destination-exercises')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Kho đề đang trống'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Nhập JSON').first);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('exercise-import-dialog')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    final jsonField = find.byKey(const ValueKey('exercise-json-input'));
    await tester.enterText(jsonField, _validExerciseJson);
    tester.testTextInput.hide();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('exercise-json-validate')));
    await tester.pumpAndSettle();

    expect(find.text('JSON hợp lệ · Schema v1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty clipboard clears a previously valid import preview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester);
    await tester.tap(
      find.byKey(const ValueKey('navigation-destination-exercises')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nhập JSON').first);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('exercise-json-input')),
      _validExerciseJson,
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('exercise-json-validate')));
    await tester.pumpAndSettle();
    expect(find.text('JSON hợp lệ · Schema v1'), findsOneWidget);

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => call.method == 'Clipboard.getData' ? null : null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('exercise-json-paste')));
    await tester.pumpAndSettle();

    expect(find.text('Clipboard không có nội dung văn bản.'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('exercise-json-save')),
          )
          .onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('clipboard read failure clears a previously valid preview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester);
    await tester.tap(
      find.byKey(const ValueKey('navigation-destination-exercises')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nhập JSON').first);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('exercise-json-input')),
      _validExerciseJson,
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('exercise-json-validate')));
    await tester.pumpAndSettle();
    expect(find.text('JSON hợp lệ · Schema v1'), findsOneWidget);

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.getData') {
          throw PlatformException(code: 'clipboard_unavailable');
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('exercise-json-paste')));
    await tester.pumpAndSettle();

    expect(
      find.text('Không thể đọc clipboard. Hãy sao chép JSON rồi thử lại.'),
      findsOneWidget,
    );
    expect(find.text('JSON hợp lệ · Schema v1'), findsNothing);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('exercise-json-save')),
          )
          .onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('imports a validated JSON after preview confirmation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester);
    await tester.tap(
      find.byKey(const ValueKey('navigation-destination-exercises')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nhập JSON').first);
    await tester.pumpAndSettle();

    const sample = _validExerciseJson;
    final jsonField = find.byKey(const ValueKey('exercise-json-input'));
    expect(jsonField, findsOneWidget);
    await tester.enterText(jsonField, sample);

    // enterText focuses the field and opens the simulated mobile keyboard.
    // Dismiss it before tapping the dialog action to avoid an obscured tap.
    tester.testTextInput.hide();
    await tester.pumpAndSettle();

    final validateButton = find.byKey(const ValueKey('exercise-json-validate'));
    expect(validateButton, findsOneWidget);
    expect(tester.widget<OutlinedButton>(validateButton).onPressed, isNotNull);

    await tester.tap(validateButton);
    await tester.pumpAndSettle();

    expect(find.text('JSON hợp lệ · Schema v1'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('exercise-json-save')));
    await tester.pumpAndSettle();
    expect(find.text('English A1 - Greetings'), findsOneWidget);
    expect(
      exerciseRepository.items.single.topics,
      containsAll(['English', 'Greetings']),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Thao tác bộ đề'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đổi tên'));
    await tester.pumpAndSettle();
    final renameField = find.byKey(const ValueKey('exercise-rename-input'));
    expect(renameField, findsOneWidget);
    await tester.enterText(renameField, 'English Greetings - Updated');

    // The rename dialog also has actions below the keyboard's viewport.
    tester.testTextInput.hide();
    await tester.pumpAndSettle();

    final renameSave = find.byKey(const ValueKey('exercise-rename-save'));
    expect(renameSave, findsOneWidget);
    expect(tester.widget<FilledButton>(renameSave).onPressed, isNotNull);
    await tester.tap(renameSave);
    await tester.pumpAndSettle();
    expect(find.text('English Greetings - Updated'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Thao tác bộ đề'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa bộ đề'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa bộ đề'));
    await tester.pumpAndSettle();
    expect(find.text('Kho đề đang trống'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
