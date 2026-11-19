# B-01 Domain kernel — plan

Status: approved 2026-11-18 (Q1–Q4 = defaults) · Owner: Fadi Abd AlJawwad · Base: `origin/main @ 7e61f5d` · Delete this file when B-01 merges.
Covers: C-01 (first files in `lib/domain`), C-12 (exact conversion), K-01 (minor units moved into the kernel). Rules: I-02, I-21 (value part), R-02b, BR-15, NFR-07, ADR-0007.
Branch: `feat/b-01-domain-kernel` (first commit `eb13fb6` closes B-05).

## 1. Research
| #  | Fact (source)                                                                                                                                                                                                        |
|----|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| F1 | ADR-0007: `perUsdMicros: int` = units per 1 USD × 10^6, parsed from text half-up, never through `double`; USD = 1,000,000                                                                                            |
| F2 | ADR-0007: A to B = `amountMinorA × perUsdMicros(B) × 10^decimals(B)` over `perUsdMicros(A) × 10^decimals(A)`, `BigInt` numerator and denominator; totals add fractions; round once, half-up, at display (BR-15)      |
| F3 | ADR-0007 verification: symmetry within one minor unit; sum of 1,000 conversions equals the fraction sum; text parsing without `double`; no overflow at 10^12 minor units                                             |
| F4 | K-01: ILS 2, USD 2, JOD 3 decimals; legacy `lib/features/currency/domain/usecases/money.dart` has `parseMinorUnits` (no double, rejects extra decimals, cap 10^12) and `convertMinorUnits` (double: the C-12 defect) |
| F5 | `lib/domain/AGENTS.md`: pure Dart; glossary names; one test per invariant named by ID; read the clock only through `Clock`; expected failures typed, never strings                                                   |
| F6 | Glossary: "Local today" = `Clock.localToday()`; `ConversionQuality` exists (used from B-12, not here)                                                                                                                |
| F7 | `boundaries_test.dart`: `lib/domain` may not import Flutter, Firebase, HTTP, Drift, or legacy paths (`lib/features/*/domain/`, `lib/features/*/data/`) — the kernel cannot reuse legacy code, only port its behavior |
| F8 | Balances may be negative (BR-12 warns and allows), so `Money` allows negative values; "amount > 0" (I-01) belongs to transactions, not to the kernel                                                                 |

## 2. Scope
In: `CurrencyCode`, `Money`, amount parsing and plain text, `PerUsdMicros` with rate-text parsing, exact fraction `ExactAmount`, conversion R-02b, display rounding, `Clock` port and a calendar date value.
Out: `ExchangeRate` entity with date and storage (B-12), rate lookup R-03/R-04 (B-12), any change to legacy features (they keep `money.dart` until their stories migrate), `SystemClock` adapter (first consumer story), UI.

## 3. Files
| File                                   | Content                                                                                                                                                                                                                                   |
|----------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `lib/domain/money/currency_code.dart`  | `enum CurrencyCode { ils, usd, jod }` with `decimals`, `minorFactor`, `isoCode`; `static CurrencyCode? fromIso(String)`                                                                                                                   |
| `lib/domain/money/money.dart`          | `final class Money { int minor; CurrencyCode currency; }`, `                                                                                                                                                                              |minor| <= maxMinorUnits` (10^12); `plus`/`minus` same currency only (`ArgumentError` on mismatch = programming error); `toPlainText()`; value equality |
| `lib/domain/money/parse_money.dart`    | `ParseMoneyResult` sealed: `ParsedMoney(Money)` / `InvalidAmount(AmountError)`; `AmountError { empty, malformed, tooManyDecimals, aboveMaximum }`; same accepted grammar as legacy `parseMinorUnits` (no signs, no grouping, no exponent) |
| `lib/domain/money/exact_amount.dart`   | `final class ExactAmount { BigInt numerator; BigInt denominator; CurrencyCode currency; }` in minor units of `currency`; denominator > 0, reduced by gcd; `plus` same currency; `roundToMinor()` half-up (Q2)                             |
| `lib/domain/rates/per_usd_micros.dart` | `extension type` or final class `PerUsdMicros(int value)`, value > 0; `usd` constant 1,000,000; `static RateParseResult parse(String text)` half-up at 6 decimals, text only                                                              |
| `lib/domain/rates/convert.dart`        | `ExactAmount convert(Money amount, {required PerUsdMicros fromRate, required PerUsdMicros toRate, required CurrencyCode to})` (R-02b); same currency returns the amount unchanged                                                         |
| `lib/domain/time/clock.dart`           | `abstract interface class Clock { LocalDate localToday(); }`                                                                                                                                                                              |
| `lib/domain/time/local_date.dart`      | `final class LocalDate { year, month, day }`, validated, `compareTo`, `isAfter`, ISO `yyyy-MM-dd` text round trip (Q1 name)                                                                                                               |

## 4. AC and rule to test map (contract)
| Test file                                    | Tests (names start with the ID)                                                                                                                                                                                                                                        |
|----------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `test/domain/money/money_test.dart`          | `I-02` decimals never exceed currency precision (ILS 2, USD 2, JOD 3); `I-02` parse rejects extra decimals, signs, grouping, exponent, `NaN`; `K-01` parse/plain text round trip for each currency; maximum 10^12 accepted, 10^12 + 1 rejected; mismatch `plus` throws |
| `test/domain/money/exact_amount_test.dart`   | `BR-15` half-up rounding at .5 (positive and negative, Q2); `NFR-07` sum of 1,000 `ExactAmount`s equals the single-fraction result; gcd reduction keeps value                                                                                                          |
| `test/domain/rates/per_usd_micros_test.dart` | `I-21` value > 0 (0 and negative rejected); `ADR-0007` text parse half-up at the 7th decimal (`3.7123455` → 3,712,346); text with more than 13 integer digits rejected; no `double` (parse of `0.1`, `0.2`, `0.3` exact)                                               |
| `test/domain/rates/convert_test.dart`        | `R-02b` USD→ILS→USD exact; ILS→USD→ILS ≤ 2 minor units at 3.712345; JOD (3 decimals) to ILS (2 decimals) exact fraction; same currency unchanged; `ADR-0007` no overflow at 10^12 minor units with the largest supported rate                                          |
| `test/domain/time/local_date_test.dart`      | invalid dates rejected (2026-02-30); ordering; ISO round trip; `Clock` fake returns fixed date                                                                                                                                                                         |
| `test/architecture/boundaries_test.dart`     | raise `lib/domain` non-vacuous minimum from 0 to 1 (plan v1 note)                                                                                                                                                                                                      |

Contract commit = these test files + the type signatures above with bodies `throw UnimplementedError()`; every new test fails. Implementation then touches `lib/domain/**` and docs only.

## 5. Steps and commits
| # | Commit                                                                                        | Who                           |
|---|-----------------------------------------------------------------------------------------------|-------------------------------|
| 0 | `ci(B-05): …; close B-05` (`eb13fb6`)                                                         | Owner, done                   |
| 1 | `docs(B-01): plan` — this file, `docs/progress.md`                                            | Owner                         |
| 2 | `contract(B-01): kernel types and failing tests`                                              | Agent prompt 1; owner commits |
| 3 | `feat(B-01): domain kernel` — bodies only; tests read-only                                    | Agent prompt 2                |
| 4 | `docs(B-01): repo-map, status` — `docs/repo-map.md` lists `lib/domain` files; 05 §7 B-01 done | Owner                         |
Push once after 4 (G-4). Expected CI gate notice: contract commit found, no `test/` change after it.

Exemplar: legacy `lib/features/currency/domain/usecases/money.dart` (behavior only, never imported).
Diff estimate: 8 lib files (~350 lines), 6 test files (~450 lines). Reviewable in ~10 minutes per prompt.

## 6. Risks
| Risk                                                            | Mitigation                                                                         |
|-----------------------------------------------------------------|------------------------------------------------------------------------------------|
| Duplicate money logic (legacy and kernel) until stories migrate | Accepted (strangler); legacy file listed in repo-map Legacy                        |
| `int` precision on web (2^53)                                   | Targets are Android and iOS only; `BigInt` for every product                       |
| Agent uses `double` "just for tests"                            | Prompt bans `double` in `lib/domain` and in the new tests; reviewer greps `double` |

## 7. Questions for the owner
| ID | Question                                                                       | Decision (owner, 2026-11-18)                             |
|----|--------------------------------------------------------------------------------|----------------------------------------------------------|
| Q1 | Calendar date type name: `LocalDate` (not yet in the glossary)                 | `LocalDate`; add one glossary line in commit 4           |
| Q2 | BR-15 "half-up" for negative values: half away from zero, or toward +infinity? | Half away from zero (−2.5 → −3), same as the legacy code |
| Q3 | Legacy `money.dart` delegates to the kernel now, or stays untouched?           | Untouched (one module per story)                         |
| Q4 | `SystemClock` adapter now?                                                     | No; added by the first story that reads the clock        |
