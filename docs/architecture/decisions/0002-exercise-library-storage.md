# ADR 0002: Exercise Library storage and JSON contract

- Status: Accepted for the first Exercise Library slice
- Date: 2026-11-23

## Context

SelfLearn's product decisions require one Exercise JSON per independent card, multiple topic associations, offline persistence, duplicate detection, individual JSON export and deletion that does not cascade into study history or user-saved vocabulary. The source documents select SQLite/Drift for structured metadata and separate JSON files for complete exercise content. They do not define a concrete Exercise JSON schema or require Drift specifically.

## Decision

- Use SQLite through `sqflite` for this first small CRUD schema. SQL access is isolated inside `LocalExerciseRepository`; UI and application controller never call SQL directly. This follows the blueprint's explicit allowance for `sqflite` when the schema and CRUD workload are small, while keeping the repository boundary replaceable by Drift later.
- Store card metadata in `exercise_sets`, reusable topic names in `exercise_topics`, and the many-to-many relation in `exercise_set_topics`.
- Store each original Exercise JSON in a separate file under the app-specific support directory.
- Use schema v1 as documented in `docs/features/exercise-json-v1.md`.
- Use a feature-scoped `ChangeNotifier` controller for the current screen because the App Foundation has no state-management package/provider graph. Keep repository injection explicit; evaluate the referenced Riverpod direction when state must be shared across multiple features, and record that migration separately.
- Enforce source ID and canonical-content uniqueness in SQLite. The canonical question payload (`schemaVersion` + `questions`, with per-question IDs removed) uses recursively sorted object keys and SHA-256, so changing card title, topics or IDs does not bypass content-duplicate detection.
- Keep the exercise repository independent from future history and vocabulary repositories. Deleting a card deletes only its metadata, topic links and owned JSON file; shared topics are retained while referenced.

## Consequences

- `sqflite`, `path_provider`, `path`, `crypto`, `file_picker`, `share_plus` and `cross_file` are added for local persistence, hashing and file import/export.
- Database schema changes require a version increment and migration tests.
- File and SQLite operations cannot share one atomic transaction. Imports write the owned file before metadata commit and clean it up on failure; startup orphan cleanup removes files not referenced by SQLite. Deletes remove metadata first and best-effort delete the owned file; startup cleanup retries orphan removal.
- `sqflite_common_ffi` is used in tests to exercise real SQLite repository behavior without a device.
- The controller is intentionally local to the Exercise Library; this does not establish a second app-wide state-management framework.
- If the data model expands substantially, revisit Drift and record a new ADR rather than mixing persistence frameworks.
