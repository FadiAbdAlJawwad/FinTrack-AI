# Progress — B-05 Gate and guards

Read first, update last. One page, four sections, current story only. Stage status lives in `05-gap-analysis.md` §7 (not here). When a story is merged: move durable decisions to an ADR or `lessons.md`, then empty this file for the next story.

Story: B-05 · Branch: `ci/b-05-gate` · Plan: `docs/work/B-05-plan.md` (v2, approved) · Updated: 2026-11-17
Next story: B-01 domain kernel (05 §7, stage 0).

## Done
- Plan v2 approved; Git flow rules G-1..G-9 added to `docs/dev/agent-routing.md`.
- Commit 4 architecture boundary tests (boundaries_test.dart + cross_feature_baseline.txt) and ARB parity tests (arb_parity_test.dart) added and green.

## Decisions made in this story
- B-05 is one branch and one PR (v1's four slices dropped).
- C-18 gate is a CI shell step, not a Dart tool.
- Rest of C-24 deferred until a real violation.
- Desktop platform folders removed (targets: Android, iOS).

## Next
- Commit 5 CI.

## Open questions
- —
