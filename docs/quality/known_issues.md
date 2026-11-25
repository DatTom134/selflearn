# Known Issues

## App Foundation

- Theme choice is currently in-memory only; it resets to System after process restart. Persist it when the Settings/preferences data layer is introduced.
- Dashboard summary values are presentation placeholders and are not connected to repositories or local storage.
- Vocabulary and Settings destinations remain navigation placeholders.
- Glass blur and animation require physical Android device verification, especially on lower-end hardware and under Reduce Motion.

## Exercise JSON Management

| ID | Date | Area | Symptom | Root cause | Mitigation / verification | Status |
|---|---|---|---|---|---|---|
| SEL-0001 | 2026-11-23 | Exercise JSON / Practice | Per-type answer validation is not exhaustive for every possible question type | Product decisions do not define contracts for all question types | `multiple_choice` now has an exact-match registry and complete single-choice validation; other types remain generically importable but unsupported by Practice until their contracts are approved | Partially resolved by Practice foundation |
| SEL-0002 | 2026-11-23 | File storage | SQLite and app-private JSON file operations are not one atomic transaction | SQLite transaction cannot atomically commit filesystem operations | Import cleans the file on transaction failure; startup orphan cleanup retries files not referenced by SQLite | Mitigated |
| SEL-0003 | 2026-11-23 | Exercise Library / responsive layout | Kho đề overflowed vertically by 39 px at 320 × 720 before the import dialog opened | `_MessageState` centered a non-scrollable column whose 318 px content exceeded the 279 px remaining after the library header and filters | Make the empty/error state vertically scrollable while preserving centering when it fits; assert no exception immediately after navigation and through the import flow | Resolved; narrow-screen widget test and full suite pass |
| SEL-0004 | 2026-11-23 | Dashboard navigation | Dashboard showed the implemented Exercise import action as disabled / coming soon | Dashboard quick action was not connected to AppShell navigation after the Exercise Library feature landed | Wire the dashboard action to the Kho đề destination and cover it with a widget test | Verified; dashboard navigation widget test passes |
| SEL-0005 | 2026-11-23 | Project packaging | Uploaded ZIP included generated Gradle/Kotlin caches, machine-specific `android/local.properties`, IDE metadata and patch-only README files | The archive was assembled from a working directory without applying the repository ignore rules | Rebuild the deliverable from source while excluding local/generated/IDE/patch-only files; keep local paths out of Git | Corrected in the revised deliverable archive; verify tracked files before commit |
| SEL-0006 | 2026-11-23 | Exercise import dialog | Empty or unreadable clipboard content could leave a previous valid preview available for saving | Clipboard failure paths did not clear the previously validated result | Clear validation state before every clipboard read and keep Save disabled until the new input validates | Verified; empty and failed clipboard widget tests pass |
| SEL-0007 | 2026-11-23 | Rename dialog lifecycle | Saving a rename disposed its text controller while the closing route transition still rebuilt the dialog | The screen disposed a controller immediately when `showDialog` returned, before the dialog subtree was removed | Let a stateful rename dialog own and dispose its controller with its widget lifecycle | Resolved; import/rename/delete widget flow passes without Flutter exceptions |
| SEL-0008 | 2026-11-23 | Android debug build | Default `flutter build apk --debug` fails while closing Kotlin incremental caches for `share_plus` and `android_file_picker` | Kotlin reports `Storage ... is already registered` for incremental cache files in the shared compiler daemon | A process-local Gradle configuration using in-process Kotlin compilation, disabled incremental compilation and disabled parallel execution produced the APK; no project build/dependency setting was changed | Environment-limited; default command still fails on this machine, workaround build passes |

## Verification boundary

Verified locally with Flutter 3.50.1, Dart 3.14.0, Android SDK 36 and Java 25: formatting, fatal-info analysis, `widget_test.dart` and the full test suite pass. The default Android debug build fails with the Kotlin cache-registration error above; the APK was built successfully using a process-local Gradle workaround. The Android emulator installed and launched the APK without fatal Android or Flutter log errors; native file-picker, share-sheet and persistence workflows remain unverified on-device.
