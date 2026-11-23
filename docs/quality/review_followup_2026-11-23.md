# SelfLearn follow-up source review — 2026-11-23

## Scope

Reviewed the uploaded `selflearn.zip` as the source of truth, including `lib/`, `test/`, Android Gradle configuration, dependency lockfile, product decisions, Exercise JSON v1 contract, test plan and known-issues register.

## Pass 1 — Product contract, validation and persistence

- Confirmed that one valid JSON object maps to one Exercise card and retains all topics on that card.
- Compared `ExerciseJsonValidator` with `docs/features/exercise-json-v1.md`: schema version, source ID, title, topics, question count, answer presence, multiple-choice options, canonical content hash and 2 MiB limit are represented in code.
- Reviewed SQL parameterization, literal `LIKE` wildcard escaping, duplicate checks, transaction cleanup and startup orphan cleanup.
- Corrected the widget fake repository so duplicate detection uses `contentHash`, matching the documented duplicate contract rather than exact raw JSON string equality.
- No schema or dependency version was changed.

## Pass 2 — UI, responsive behavior and widget regression

- Reviewed phone/tablet navigation and the Exercise Library header, filters, cards, details, import and rename dialogs.
- The prior test log identifies a real `RenderFlex overflowed by 124 pixels` at the assertion immediately after the import preview appeared. The preview heading used a `Row` with an unconstrained `Text`; dialog actions also lacked an explicit compact-width wrapping layout. The captured exception did not name the exact offending RenderFlex, so both likely pressure points were hardened rather than claiming a proven widget-level root cause.
- Changed the preview heading to use `Expanded`, and placed the dialog actions in a `Wrap`.
- Added stable keys for the import dialog, save action and navigation destinations.
- Added a 320 × 720 widget regression test that opens the import dialog, validates the fixture, checks the preview and asserts `tester.takeException()` is null.
- Existing assertions remain; no overflow assertion was removed or weakened.

## Pass 3 — Android configuration, packaging and verification boundaries

- Inspected `pubspec.yaml` / `pubspec.lock` and Android Gradle settings without upgrading package or plugin versions.
- The uploaded archive contained generated Gradle/Kotlin and Flutter plugin metadata. These are not source files and can carry stale or machine-specific state; the deliverable archive excludes generated caches, and `.gitignore` now also excludes `android/.kotlin/`.
- The earlier Gradle incremental-cache lock errors are not treated as proof of a Kotlin source defect. The local Android build must be rerun from a clean cache on the target Windows environment.
- The source ZIP does not include a Flutter/Dart executable in this review environment. Therefore `dart format`, `flutter analyze`, `flutter test` and `flutter build apk --debug` were not run and are not reported as passing.

## Files changed

- `lib/features/exercises/presentation/widgets/exercise_import_dialog.dart`
- `lib/app/navigation/glass_navigation.dart`
- `test/widget_test.dart`
- `test/support/fake_exercise_repository.dart`
- `docs/quality/known_issues.md`
- `.gitignore`

## Required target-machine quality gate

Run from the project root:

```powershell
dart format .
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
flutter build apk --debug
```

If Gradle again reports only incremental cache lock/deletion failures, close Android Studio/VS Code and other Gradle processes, run `cd android; .\\gradlew --stop; cd ..`, then `flutter clean`, `flutter pub get`, and rebuild. Do not mark the issue resolved until the complete widget suite and Android debug build pass.


## Additional regression hardening

- Clipboard paste now clears any previously validated result before attempting to read clipboard data. An empty or failed clipboard read can no longer leave stale JSON eligible for saving.
- The fake exercise repository now mirrors production search behavior for trimmed query text and question-type matching.
- Added validator coverage proving that content fingerprints ignore set metadata and question IDs, as required by the Exercise JSON v1 duplicate contract.
- Added SQLite search regression coverage for literal underscore and exclamation-mark characters, complementing the existing percent-character test.

**Verification boundary:** These changes are source-reviewed only in this environment. Flutter/Dart SDK is not installed here; run the full target-machine quality gate before marking the issues Fixed.
