import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/theme/theme_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SelfLearnApp(themeController: ThemeController()));
}
