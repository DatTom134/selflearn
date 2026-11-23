# Exercise JSON Management — implementation notes

Target branch: `feature/exercise-json-management`

## Included

- Replaces the Kho đề placeholder with the Exercise Library screen.
- Adds JSON paste/file import, schema validation, preview-before-save, duplicate checks, one-card-per-JSON persistence, multi-topic search/filter, details/copy, rename, share/export and confirmed per-card deletion.
- Uses SQLite metadata plus app-private JSON files; includes startup orphan cleanup.
- Adds unit, repository and widget tests plus schema/ADR documentation.

## Apply

Extract this archive over the project root (`D:\dev\FlutterProjects\SelfLearn`) and overwrite the included files. Keep the existing `.git` folder and do not replace it with an archive copy.

## First run on Windows

```powershell
flutter pub get
dart format .
flutter analyze --fatal-infos
flutter test
flutter build apk --debug
```

The new repository tests use `sqflite_common_ffi` and run against SQLite in memory. Runtime Android persistence uses the native `sqflite` plugin.

## Important schema decision

The uploaded product decisions require schema-version validation but do not specify concrete Exercise JSON field names. This slice introduces an explicit first contract (`schemaVersion: 1`) in `docs/features/exercise-json-v1.md`. Align this with the future Template JSON generator before relying on it for production content.

## Verification boundary

This build environment has no Flutter/Dart SDK. The archive was assembled and structurally inspected, but `dart format`, `flutter analyze`, `flutter test` and Android build have not been executed here. Treat the local commands above as required quality gates; do not commit until they pass on the target branch.


### Dependency solver compatibility fix

- Updated `file_picker` from `^10.3.10` to `^13.4.1` to align its Windows `win32` dependency with `share_plus ^13.3.1` (which requires `win32 ^6.0.1`).
- Migrated the import dialog to the `file_picker` v12+ API: `pickFile()` returns a single `PlatformFile?`, and file bytes are read with `readAsBytes()`. The 2 MB limit is checked using the reported file length before reading, then checked again against the actual byte count.
- Requires the project's Flutter 3.50.1 / Dart 3.14 toolchain, which is above the packages' stated minimums.


## Follow-up compatibility patch (file_picker 13.4.1)

- Use the v12+ static API `FilePicker.pickFile()` and `PlatformFile.readAsBytes()`; `FilePicker.platform` is not part of this API.
- Import `ValidatedExercise`'s defining model in the repository test.
- Remove analyzer-reported unused imports/local and resolve strict-info lints.
- This patch has not been executed with Flutter in the patching environment; run the quality gates locally.


## Full-project review follow-up (2026-11-23)

Three review passes were completed against the project roadmap, engineering rules, product decisions, design system and current source tree.

- Connected the dashboard's existing Exercise import quick action to the Exercise Library instead of presenting it as disabled/coming soon.
- Made import/rename widget interactions deterministic with stable keys and explicit simulated-keyboard dismissal before action taps.
- Added actionable clipboard-read error handling and bounded the validator's UTF-8 size-check allocation.
- Escaped SQL LIKE metacharacters so `%` and `_` in a search are treated literally.
- Closed the opened SQLite database if default repository initialization fails.
- Added regression tests and recorded the dialog-keyboard lesson in `docs/quality/lessons_learned.md`.
- Replaced the patch-only root README and removed machine-specific/generated files from the reviewed archive.

**Verification boundary:** Flutter/Dart commands and Android builds were not executable in the review environment. The new and existing tests remain pending execution on the target Flutter 3.50.1 / Dart 3.14.0 Windows toolchain. Do not mark the widget issue Fixed until the full local quality gate passes.


## Widget-test log corrections (2026-11-23)

The supplied logs identified two independent layout defects:

1. The import `AlertDialog` exceeded the available height by 39 px on a 320 × 720 test surface. The dialog now uses its scrollable title/content layout, compact editor height and responsive inset.
2. `ExerciseSetCard` used `Spacer()` in a `Column` rendered by a `ListView`. The unbounded vertical constraints made flex layout invalid and caused the long cascade of follow-on exceptions. The card now shrink-wraps and uses fixed spacing instead. Grid extent was increased to accommodate the natural-height card.

The tests still assert that no Flutter exception occurs. These changes have not been run under Flutter in this environment; local test execution is required.
