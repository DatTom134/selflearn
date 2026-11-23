# Architecture Overview

## Current structure

```text
lib/
  app/
    app.dart
    navigation/
    theme/
  features/
    home/presentation/
    exercises/
      application/exercise_library_controller.dart
      domain/models/
      domain/repositories/
      domain/services/exercise_json_validator.dart
      data/local/exercise_database.dart
      data/local/exercise_file_store.dart
      data/repositories/local_exercise_repository.dart
      presentation/screens/exercise_library_screen.dart
      presentation/widgets/
    placeholder/presentation/
  main.dart
```

## Exercise feature data flow

```text
ExerciseLibraryScreen
        ↓ user intent / UI state
ExerciseLibraryController
        ↓ commands and queries
ExerciseRepository (domain contract)
        ↓
LocalExerciseRepository
        ├── SQLite: card metadata + normalized topic relations
        └── App-private JSON file store: original Exercise JSON
```

The View does not access SQL or filesystem paths. The repository is the source of truth for reads and writes. `sqflite` is used for the initial small CRUD schema; the repository boundary permits replacing it with Drift if the data model grows.

## Storage invariants

- One imported JSON object maps to one Exercise card.
- Topic relations are many-to-many.
- Original JSON is stored separately from mutable card display title.
- Source IDs and canonical JSON hashes are unique.
- Deleting a card does not touch study history or independently saved vocabulary.
- Unreferenced JSON files are cleaned during repository startup.

## Theme behavior

- `ThemeMode.system` is the default.
- Theme selection currently remains in memory only; persistence belongs to Settings/preferences work.

## Responsive behavior

- Width <= 599 logical px: phone header and bottom navigation.
- Width 600–839 logical px: compact NavigationRail.
- Width >= 840 logical px: expanded sidebar.
- Exercise cards render as a list on narrow layouts and a responsive grid when space allows.
