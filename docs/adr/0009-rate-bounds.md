# ADR-0009 — Rate bounds and display rounding

Status: Accepted · 2026-11-19 · Decider: Fadi Abd AlJawwad
Amends: ADR-0007 (bounds of `perUsdMicros`, type of the display rounding result). Drivers: NFR-07, I-21, review findings F-03 and F-04 (B-01).

## Context
ADR-0007 fixed the rate representation (`perUsdMicros = rate × 10^6`) but set no upper bound. The B-01 plan borrowed "13 integer digits" from amount parsing; 13 digits × 10^6 overflows int64. Rates are also read as `number` by the Firestore JS SDK, which is exact only up to 2^53 − 1. Separately, a conversion of a valid amount at valid rates can exceed int64 (10^12 minor × 10^12 rate ratio × 10 ≈ 10^25), so `BigInt.toInt()` in the display rounding could clamp silently.

## Decision
- `0 < perUsdMicros ≤ maxPerUsdMicros = 10^12` (at most 10^6 currency units per USD). The bound is below 2^53 − 1, so every stored rate is exact in Dart, SQLite, Firestore and JS readers. It is a hard bound whatever the Worker language or the target platforms.
- Parsing source text: strip leading zeros; more than 9 integer digits → `tooManyIntegerDigits` (overflow guard: 9 digits × 10^6 < 2^53); round half-up on the 7th decimal; then check bounds on the rounded value: 0 → `nonPositive`, above the max → `outOfRange`. No `double` at any step.
- `PerUsdMicros` has a validated factory as its only public constructor; an out-of-range value passed to the raw constructor path is a programmer error (`ArgumentError`).
- Every factor of a conversion is a `BigInt` before any multiplication.
- `ExactAmount.roundToMinor()` returns `BigInt` and does not throw. It serves display and totals only. Converted values are not stored. A checked conversion to stored `Money` (AC-06.3) is decided in US-06.

## Alternatives
| Option | Against |
|---|---|
| Bound by digit count (13 or 12 digits) | 13 overflows int64; 12 is arbitrary and unsafe for JS readers |
| Bound = int64 max | Not exact in JS readers (> 2^53) |
| `roundToMinor` returns `int` and throws `RangeError` | Failure reachable from valid data; contradicts "Error = programmer error" |

## Consequences
Positive: no overflow path from valid data; same exact integer in every store and reader.
Negative: rates above 10^6 per USD are rejected (no currency in scope comes near it); the `lib/core` formatter must accept `BigInt`.

## Verification
Unit tests: `'1000000'` → 10^12; `'999999.9999995'` → 10^12; `'1000000.0000005'` and `'1000000.000001'` → `outOfRange`; `'999999999'` → `outOfRange`; `'1234567890'` → `tooManyIntegerDigits`; `'0000000001'` → 10^6; `'0.0000005'` → 1; `'0.0000004'` and `'0.00000049999'` → `nonPositive`; `roundToMinor` of a ~10^25 fraction returns the exact `BigInt`.
