# Practice Question Type Registry

## Purpose and scope

The Exercise Library validates and stores Exercise JSON v1. The Practice
registry separately defines which question types the current Practice parser
can turn into typed domain questions.

The MVP registry contains only the exact identifier `multiple_choice`.
Identifiers are case-sensitive and are not inferred from substrings. For
example, `multiple_select`, `Multiple_Choice`, and `short_answer` are not
registered.

Unregistered types remain eligible for Exercise Library import when they meet
the common Exercise JSON v1 structure. The Practice parser rejects the entire
set if any question type is unregistered; it never skips or converts a
question.

## `multiple_choice` contract

- Single-choice: one correct answer and one selected option per question.
- At least two options; each is a non-empty string.
- Options must be unique after trimming. Comparison is case-sensitive.
- `answer` is required as a string; `answers` is unsupported, including when
  supplied alongside `answer`.
- The trimmed answer must exactly match one trimmed option.
- `prompt` or the schema-v1 alias `question` must be non-empty. If both are
  present, their trimmed values must match.
- Trimming is used for domain values and matching only. The imported source
  JSON is not rewritten. Unicode, punctuation, and letter case are not
  normalized.
- Root `questionType` is display metadata; each question's `type` determines
  its parser.

## Typed parsing boundary

`PracticeQuestionParser` accepts a JSON string supplied by the Exercise
repository boundary. It reuses `ExerciseJsonValidator`, then creates typed
questions and separate answer keys. It has no file-system, database, or UI
responsibility.

The parse result is atomic. If syntax, schema, question validation, or registry
support fails, it contains path-aware issues and no `ParsedPracticeSet`.
`PracticeQuestion` contains display data only; the correct option index lives
in `PracticeAnswerKey`.

## Answer evaluation

`MultipleChoiceAnswerEvaluator` evaluates one selected option index against
one correct option index and an option count:

| Selection | Result | Points |
|---|---|---:|
| Correct option | `correct` | 1 |
| Different option | `incorrect` | 0 |
| No selection | `unanswered` | 0 |

An out-of-range correct or selected index is an explicit range error, not an
incorrect answer. Session-level totals and state transitions are outside this
foundation scope.

## Adding a question type

Do not register a type until its JSON contract, typed model, parsing behavior,
answer evaluation, and focused tests are defined. Registration must not change
the Exercise JSON root schema or invalidate existing generic imports.
