# Exercise JSON — schema v1

This is the first executable Exercise JSON contract used by the Exercise Library. The product decisions document requires schema-version validation but does not define field names or a concrete schema. Therefore, this v1 contract is an implementation decision for the current feature slice; update this document and add migration/compatibility tests before changing it.

## Root object

| Field | Required | Type | Rules |
|---|---|---|---|
| `schemaVersion` | Yes | integer | Must equal `1` |
| `id` | No | string | Stable source ID, max 120 characters; unique among imported sets when supplied |
| `title` | Yes | string | Non-empty, at most 180 characters |
| `topics` | Yes | string array | At least one non-empty topic, max 80 characters each; duplicate names are collapsed case-insensitively |
| `questionType` | No | string | Non-empty display label, max 60 characters; when omitted it is derived from question `type` values |
| `difficulty` | No | string | Display label, max 60 characters |
| `questions` | Yes | object array | 1–500 question objects |

## Question object

| Field | Required | Type | Rules |
|---|---|---|---|
| `id` | No | string | If supplied, non-empty and unique within the set |
| `type` | Yes | string | Non-empty type identifier. Import accepts other identifiers with the common fields below; Practice support is determined separately by its exact-match registry |
| `prompt` or `question` | Yes | string | Non-empty question text. For `multiple_choice`, if both aliases are present they must match after trimming |
| `answer` or `answers` | Yes | JSON value | Must not be null for generic question types. `multiple_choice` requires one string `answer` and does not allow `answers` |
| `options` | Conditional | array | Required for exact type `multiple_choice`: at least two non-empty strings, unique after trimming (case-sensitive); its trimmed `answer` must exactly match a trimmed option |

The validator preserves generic answer payloads as JSON values so other question types can use structured answers without flattening them. It applies the single-choice contract only when a question's `type` is exactly `multiple_choice`; identifiers such as `multiple_select` remain eligible for generic Exercise import but are not supported by Practice.

For `multiple_choice`, options and answer are trimmed only for validation and Practice domain models. Comparisons are case-sensitive; Unicode and punctuation are not normalized. The source JSON remains unchanged.

## Example

```json
{
  "schemaVersion": 1,
  "id": "english-a1-greetings-001",
  "title": "English A1 — Greetings",
  "topics": ["English", "Greetings"],
  "questionType": "multiple_choice",
  "difficulty": "Beginner",
  "questions": [
    {
      "id": "q1",
      "type": "multiple_choice",
      "prompt": "Choose the correct greeting.",
      "options": ["Hello", "Goodbye"],
      "answer": "Hello"
    }
  ]
}
```

## Import limits and duplicate rules

- UTF-8 JSON only; maximum input size is 2 MiB.
- Maximum 500 questions per set.
- The source `id` is unique when present.
- The question payload (`schemaVersion` + `questions`) is canonicalized with recursively sorted object keys and SHA-256 hashed. Root metadata and per-question `id` values are excluded from the fingerprint. Identical question content is rejected even if object key order, whitespace, source IDs, question IDs, title or topic labels differ.
- One valid JSON object creates one Exercise card. Its complete topic list is attached to that one card.
- The original JSON is stored as an individual app-private `.json` file. SQLite stores card metadata and normalized topic relations.
