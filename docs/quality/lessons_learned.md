# Lessons Learned

## 2026-11-23 — Dialog widget tests must control the simulated keyboard

- **Context:** Exercise JSON import and card rename use `AlertDialog` forms on phone-sized test surfaces.
- **Incorrect assumption:** A controller can be disposed as soon as `showDialog` returns its result.
- **Root cause:** `showDialog` completes when the route is popped, while its reverse transition can still rebuild the dialog subtree. Disposing the rename field's controller in the caller caused a use-after-dispose during that transition.
- **Prevention rule:** Let the dialog widget own its `TextEditingController` and dispose it with the dialog state. Give controls stable keys; hide the simulated keyboard and pump before tapping; assert results and check `tester.takeException()` after transitions.
- **Regression coverage:** `test/widget_test.dart` covers import preview/save and rename with keyboard dismissal, then verifies rename/delete and no pending Flutter exception.
- **Verification:** The isolated widget file and full test suite pass with Flutter 3.50.1 / Dart 3.14.0.

## 2026-11-23 — Empty states need a bounded scroll strategy

- **Context:** The Exercise Library places its empty/error state below a header and two filters in a finite-height phone viewport.
- **Root cause:** At 320 × 720, the empty message needed 318 px but received 279 px; a shrink-wrapped `Column` inside `Center` could not scroll and overflowed by 39 px before the import dialog opened.
- **Prevention rule:** Center content when it fits, but give it a vertical scroll viewport with a minimum height matching the available area.
- **Regression coverage:** The narrow-screen widget test asserts the empty state has no Flutter exception immediately after navigation, then exercises the import dialog.
- **Verification:** The 320 × 720 regression and full widget suite pass.

## 2026-11-23 — Dashboard actions must reflect implemented feature availability

- **Context:** Exercise JSON import was implemented in the Exercise Library while the dashboard quick-action card remained disabled.
- **Incorrect assumption:** A dashboard action can remain marked “coming soon” even after its destination feature is available.
- **Why it fails:** The dashboard presents a false product state and hides a working feature from the primary entry point.
- **Prevention rule:** During each feature review, search dashboard/navigation entry points for labels and disabled actions related to the feature; wire them to the implemented destination or clearly document why they remain unavailable.
- **Regression coverage:** A widget test opens the Exercise Library through the dashboard quick action.
