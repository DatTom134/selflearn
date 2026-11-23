# Testing

## Automated coverage

### App foundation

- Initial Home Dashboard on phone.
- Phone destination selection.
- Tablet NavigationRail/sidebar and theme controls.
- Theme mode selection and narrow-phone overflow.

### Exercise JSON management

- Schema v1 validation and mixed-topic metadata.
- Invalid syntax, unsupported schema version, missing answer and duplicate question IDs.
- Canonical hash stability when JSON object key order differs.
- Input size limit.
- SQLite repository import, topic filtering, source-ID/content duplicate rejection, rename preserving original JSON, and independent card deletion with shared topics retained.
- Widget flow for JSON validation, preview confirmation, card display, rename and delete.
- Dashboard quick action opens the implemented Exercise Library.
- 320 × 720 Exercise Library empty state is checked before opening the import dialog; import preview and validation are checked at the same size.
- Empty and unreadable clipboard inputs clear an earlier valid preview and keep Save disabled.
- Dialog tests use stable keys and dismiss the simulated keyboard before tapping actions; assert no pending Flutter exception after critical transitions, including rename route dismissal.
- SQLite and fake-repository tests cover literal wildcard/escape characters, case-insensitive topics, ordering, duplicate handling, rename and deletion.

## Required local quality gate

```powershell
dart format .
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test --reporter expanded test/widget_test.dart
flutter test --reporter expanded
flutter build apk --debug
```

On the current Windows environment, the default Android build reports Kotlin incremental-cache files as already registered in the shared compiler daemon. A one-process build succeeded with this temporary PowerShell override; it does not change repository configuration:

```powershell
$env:GRADLE_OPTS = '-Dorg.gradle.project.kotlin.compiler.execution.strategy=in-process -Dorg.gradle.project.kotlin.incremental=false -Dorg.gradle.parallel=false'
flutter build apk --debug
Remove-Item Env:GRADLE_OPTS
```

## Manual Exercise Library verification

- Paste a valid schema v1 JSON and confirm preview before save.
- Import the same source ID and same content with different whitespace/key order; both should be rejected as duplicates.
- Import one JSON with multiple topics; verify it remains one card and appears under each topic filter.
- Rename a card and verify exported JSON still contains the original imported title/content.
- Export from Android share sheet and re-import the exported file.
- Delete one card sharing a topic with another; verify the other card remains.
- Close/reopen the app; verify cards and JSON files remain.
- Verify invalid JSON, unsupported schema version, empty questions, invalid multiple-choice answer and files larger than 2 MiB show actionable errors.
- Verify clipboard/platform failures are shown as an actionable import error rather than escaping the dialog.
- Verify the delete confirmation explains that history and saved vocabulary remain independent.

## Responsive / device verification

- 320–360 px: no horizontal overflow.
- 375–430 px: phone layout and bottom navigation.
- 600–800 px: compact rail and responsive content.
- 840–1200 px: expanded sidebar; Exercise grid activates when the content area is at least 620 px wide (narrower tablet widths may correctly retain the list layout).
- Light, Dark and System theme; large text scale; landscape.
- Physical Android device: file picker, share sheet, system back, app relaunch and app-private persistence.

Automated tests do not replace physical-device verification of native file picker/share-sheet behavior.
