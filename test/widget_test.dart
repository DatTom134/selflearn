import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:selflearn/app/app.dart';
import 'package:selflearn/app/theme/theme_controller.dart';

void main() {
  late ThemeController themeController;

  setUp(() {
    themeController = ThemeController();
  });

  tearDown(() {
    themeController.dispose();
  });

  testWidgets('shows the initial home dashboard on a phone', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(SelfLearnApp(themeController: themeController));

    expect(find.text('Chào mừng trở lại!'), findsOneWidget);
    expect(find.text('Tổng quan'), findsWidgets);
    expect(find.text('Bộ đề đã lưu'), findsOneWidget);
    expect(find.byTooltip('Giao diện'), findsOneWidget);
  });

  testWidgets('phone navigation changes destination', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(SelfLearnApp(themeController: themeController));
    await tester.tap(find.text('Kho đề').last);
    await tester.pumpAndSettle();

    expect(
      find.text('Khu vực này sẽ được triển khai ở bước tiếp theo.'),
      findsOneWidget,
    );
    expect(find.text('Kho đề'), findsWidgets);
  });

  testWidgets('tablet uses a navigation rail and keeps theme controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(SelfLearnApp(themeController: themeController));

    expect(find.byTooltip('Giao diện'), findsOneWidget);
    expect(find.text('SelfLearn'), findsOneWidget);
    expect(find.text('Từ vựng'), findsOneWidget);
  });

  testWidgets('theme menu switches between light and dark', (tester) async {
    await tester.pumpWidget(SelfLearnApp(themeController: themeController));

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

    await tester.pumpWidget(SelfLearnApp(themeController: themeController));
    await tester.tap(find.text('Từ vựng').last);
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

    await tester.pumpWidget(SelfLearnApp(themeController: themeController));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
