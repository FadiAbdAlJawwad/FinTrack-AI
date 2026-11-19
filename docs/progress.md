# Progress — B-01 Domain kernel

Read first, update last. One page, four sections, current story only. Stage status lives in `05-gap-analysis.md` §7 (not here). When a story is merged: move durable decisions to an ADR or `lessons.md`, then empty this file for the next story.

Story: B-01 · Branch: `feat/b-01-domain-kernel` · Plan: `docs/work/B-01-plan.md` (approved) · Updated: 2026-11-18
Next story: B-02 Drift schema v1 + UnitOfWork + outbox (05 §7, stage 0).

## Done
- B-05 closed in the first commit of this branch (CI format check and test-change gate).
- Plan approved.
- Contract step: updated domain kernel type signatures (validated factories only, public `.raw` removed in favor of private constructors) and 26 failing contract tests (all test names starting with IDs).
- Domain kernel logic implemented across `lib/domain/money/`, `lib/domain/rates/`, and `lib/domain/time/`.
- Replaced the R-02b sampling test in `test/domain/rates/convert_test.dart` to correctly account for the two-step half-up rounding bound of 2 for ILS->USD->ILS, and exactness for USD->ILS->USD.

## Decisions made in this story
- Calendar date type is `LocalDate` (glossary line added with the implementation).
- BR-15 half-up rounds half away from zero for negative values.
- Legacy `money.dart` stays untouched; the kernel ports its behavior, never imports it.
- No `SystemClock` adapter yet; the first story that reads the clock adds it.
- Validated factory constructors are the sole public way to instantiate `ExactAmount`, `PerUsdMicros`, and `LocalDate`.

## Next
- PR review and merge B-01.

## Open questions
- None.
