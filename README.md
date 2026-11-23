# SelfLearn

SelfLearn is an offline-first Flutter learning app. The current source slice contains the App Foundation and Exercise JSON Management.

## Current scope

- Responsive phone/tablet app shell with Light, Dark and System themes.
- Exercise JSON v1 import from pasted text or `.json` file.
- Syntax/schema validation and preview before saving.
- One JSON object becomes one independent Exercise card; a card can be linked to multiple topics.
- SQLite stores card metadata and topic relations; the original JSON is stored in an app-private file.
- Search/filter, detail view, copy/export, rename and confirmed delete.
- No AI API is called from the app. Users create or obtain JSON externally and import it.

Practice, study history, vocabulary management and persistent Settings are later feature slices; the corresponding destinations remain placeholders.

## Requirements

- Flutter stable 3.50.1
- Dart 3.14.0
- Android SDK 36
- JDK 25 (per the current development environment)

## Setup

```powershell
flutter pub get
dart format .
flutter analyze --fatal-infos
flutter test
flutter build apk --debug
```

GitHub Actions runs the same quality gate on every branch push and on pull
requests targeting `main`. A successful run publishes a temporary debug APK
artifact for seven days.

## Architecture

See:
- `docs/architecture/overview.md`
- `docs/architecture/decisions/`
- `docs/features/exercise-json-v1.md`
- `docs/development/testing.md`
- `docs/quality/known_issues.md`
- `docs/quality/lessons_learned.md`
- `docs/quality/review_2026-11-23.md`

## Important verification note

A source review or ZIP inspection is not a substitute for running Flutter. The current review environment does not have the Flutter/Dart SDK, so analyzer, widget/repository tests and Android build must be run on the target Windows development machine before committing.
