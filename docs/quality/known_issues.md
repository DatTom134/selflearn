# Known Issues

## App Foundation baseline

- Theme choice is currently in-memory only; it resets to System after process restart. Persist it when the Settings/preferences data layer is introduced.
- Dashboard summary values are presentation placeholders (zero / em dash); they are not connected to repositories or local storage.
- Exercise library, vocabulary and settings destinations are navigation placeholders for later feature phases.
- Glass blur and animation require physical Android device verification, especially on lower-end hardware and under Reduce Motion.
- The source snapshot was edited in an environment without the Flutter/Dart SDK. Run the project quality gate on the developer's Windows Flutter 3.50.1 / Dart 3.14.0 installation before treating this change as verified.
