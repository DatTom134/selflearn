import 'package:material_ui/material_ui.dart';

abstract final class AppElevation {
  static const none = <BoxShadow>[];
  static const low = <BoxShadow>[
    BoxShadow(color: Color(0x0A172554), blurRadius: 12, offset: Offset(0, 3)),
  ];
  static const medium = <BoxShadow>[
    BoxShadow(color: Color(0x14172554), blurRadius: 20, offset: Offset(0, 6)),
  ];
}
