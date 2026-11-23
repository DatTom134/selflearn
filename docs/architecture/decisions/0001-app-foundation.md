# ADR 0001 — App Foundation & Adaptive Shell

- Status: Accepted for the first implementation slice
- Scope: Design tokens, themes, top-level navigation and initial Home Dashboard

## Decisions

1. Keep the app feature-first with shared app infrastructure under `lib/app/`.
2. Implement the approved Blue Modern design tokens without adding a UI/state-management dependency.
3. Use Flutter `ThemeMode.system` as the default and expose System/Light/Dark selection. Persistence is deferred until the Settings/preferences data layer is introduced.
4. Choose navigation from available width: phone bottom navigation at <=599 logical px, compact rail from 600 to 839, expanded sidebar at >=840.
5. Use one shared glass indicator layer per navigation surface. Animate it for 180 ms with `Curves.easeOutCubic`; set duration to zero when Reduce Motion is enabled.
6. Keep the Home Dashboard presentation-only. Counts are placeholders until repositories and persistence are implemented.
7. Keep future top-level destinations navigable but explicitly marked as not yet implemented.

## Consequences

- The shell and theme are usable without Riverpod, routing, database or preference packages.
- Theme selection resets to System after process restart until persistence is added.
- Physical Android verification is still required for blur performance, system insets and touch behavior.
