# Testing — App Foundation

## Automated widget coverage

- Initial Home Dashboard render on a phone-sized viewport.
- Phone destination selection.
- Tablet NavigationRail/sidebar and theme control.
- Theme mode selection (Light/Dark).

## Required local quality gate

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
flutter build apk --debug
```

## Manual verification matrix

- 320–360 px: no horizontal overflow; bottom navigation labels remain legible.
- 375–430 px: phone layout, header and bottom navigation.
- 600–800 px: compact rail and dashboard columns.
- 840–1200 px: expanded sidebar and wider dashboard.
- 1200+ px: content max-width and multi-column spacing.
- Light, Dark and System theme.
- Large text scale, landscape and system Reduce Motion.
- Physical Android device: system bars, blur performance, touch targets and navigation animation.

Automated tests do not replace physical-device verification of BackdropFilter performance.
