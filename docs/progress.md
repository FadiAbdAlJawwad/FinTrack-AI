# Progress — B-01 Domain kernel

Read first, update last. One page, four sections, current story only. Stage status lives in `05-gap-analysis.md` §7 (not here). When a story is merged: move durable decisions to an ADR or `lessons.md`, then empty this file for the next story.

Story: B-01 · Branch: `feat/b-01-domain-kernel` · Plan: `docs/work/B-01-plan.md` (approved) · Updated: 2026-11-19
Next story: B-02 Drift schema v1 + UnitOfWork + outbox (05 §7, stage 0).

## Done
- B-05 closed in the first commit of this branch (CI format check and test-change gate).
- Plan approved.
- Contract step: updated domain kernel type signatures (validated factories only, public `.raw` removed in favor of private constructors) and 26 failing contract tests (all test names starting with IDs).
- Domain kernel logic implemented across `lib/domain/money/`, `lib/domain/rates/`, and `lib/domain/time/`.
- Contract amendment `9c23c28` (not an implementation change): replaced the R-02b sampling test in `test/domain/rates/convert_test.dart` to correctly account for the two-step half-up rounding bound of 2 for ILS->USD->ILS, and exactness for USD->ILS->USD.
- Fixed B-01 regression tests (F-01, F-05, F-06): single-dot parse malformed in parseMoney and PerUsdMicros, Money minor bounds assertion, LocalDate year 1..9999 invariant.

## Decisions made in this story
- Calendar date type is `LocalDate` (glossary line added in the docs commit).
- BR-15 half-up rounds half away from zero for negative values.
- Legacy `money.dart` stays untouched; the kernel ports its behavior, never imports it.
- No `SystemClock` adapter yet; the first story that reads the clock adds it.
- Validated factory constructors are the sole public way to instantiate `ExactAmount`, `PerUsdMicros`, and `LocalDate`.
- D1: `const int maxPerUsdMicros = 1000000000000;` (10^12) in `lib/domain/rates/per_usd_micros.dart`. Valid rate: 0 < value ≤ maxPerUsdMicros.
- D2: `PerUsdMicros.parse`: integer part (after stripping leading zeros) longer than 9 digits → `tooManyIntegerDigits`; round half-up using 7th decimal; then check bound on rounded value: 0 → `nonPositive`, > maxPerUsdMicros → `outOfRange`.
- D3: `BigInt ExactAmount.roundToMinor()`: exact, half away from zero, never throws. Converted values are for display and totals. A checked conversion to stored Money is out of scope (US-06, AC-06.3).

## Done (close)
- Review findings F-01, F-03, F-04, F-05, F-06 fixed; F-11 fixed in the docs commit. ADR-0009 (rate bounds) amends ADR-0007.
- Story closes with PR `feat(B-01): domain kernel` (squash merge).

## Next
- Push, PR, squash, Close block; then B-02.

## Open questions
- Checked conversion to Money for AC-06.3 (US-06).
- Firestore rule for rates (rates/rules story): `is int`, `> 0`, `<= 1000000000000` (I-21, ADR-0009).
- `lib/core` formatter must accept `BigInt` from `ExactAmount.roundToMinor()` (ADR-0009).
- Rate decoding in `lib/data`: a stored value outside 0 < v <= 10^12 must not reach `PerUsdMicros(int)` (throws `ArgumentError`); skip the row like malformed transactions. Open for MSE: a non-throwing factory from `int`.
- Rate text grammar (trim, empty, sign, `.5`, `1.`) is defined by the code, not by ADR-0009.
- F-07/F-08 deferred; F-09/F-10 Arabic-Indic digits → `lib/core` (AC-05.8).
