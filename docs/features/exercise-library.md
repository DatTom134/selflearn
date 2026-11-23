# Exercise Library

## Implemented in this slice

- Open the Exercise Library from phone/tablet navigation or the dashboard quick action.
- Import Exercise JSON from pasted text or a `.json` file.
- Validate syntax, schema version, required root fields, question structure, duplicate question IDs, multiple-choice options and answer membership.
- Preview validated title, topics, question count, type and difficulty before saving.
- Create exactly one card for one JSON object, including mixed-topic sets.
- Persist metadata and topic relations in SQLite; persist original JSON in one app-private file per set.
- Search by title/type/topic and filter by an exact topic; matching is case-insensitive, including Vietnamese text.
- Open details and copy the original JSON.
- Rename the card without rewriting the original imported JSON.
- Export the original JSON through the platform share sheet.
- Delete one card after confirmation; shared topics remain while referenced. History and vocabulary are not touched by this feature.

## Deliberate boundaries

- Exercise JSON schema v1 is a first contract because the product decisions file did not yet define exact JSON field names. See `exercise-json-v1.md`.
- Per-question-type answer semantics are not fully enforced yet. The validator enforces a common minimum structure; a finalized type registry and Practice feature will add stricter validation.
- Practice, study history and vocabulary management are separate features and are not implemented by this library screen.
- This feature is local-first. It does not call an AI API or require an API key.
