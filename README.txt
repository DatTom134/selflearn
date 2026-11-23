SelfLearn test fixes

Replace these two files in your project:
1. test/features/local_exercise_repository_test.dart
2. test/widget_test.dart

What changed:
- The shared-topic deletion test now imports two genuinely different question contents. Duplicate-content protection remains unchanged.
- The widget test now enters JSON into the TextField inside the import AlertDialog, instead of using the last TextField in the whole widget tree (which may be the background search field).

No production Dart code was changed.

After replacing the files, run:
  dart format .
  flutter analyze --fatal-infos
  flutter test
