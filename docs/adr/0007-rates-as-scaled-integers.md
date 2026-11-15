# ADR-0007 — Rates as scaled integers, exact conversion without a decimal package

Status: Accepted · 2026-11-15 · Decider: Fadi Abd AlJawwad
Refines: "exact decimal" in ADR-0005 and `03-domain` (I-21, R-02b). Drivers: NFR-07 (no floating point), NFR-05 (exact balances), dependency rule in `AGENTS.md`.

## Context
The documents require exact rates and conversions, but Dart has no decimal type and `double` is forbidden for stored or summed values. The current code converts with `double`. A decision is needed before the domain kernel is built.

## Alternatives
| Option | For | Against |
|---|---|---|
| A. `decimal` / `rational` package | Ready-made arithmetic | New dependency in the pure domain; API leaks into every rule |
| B. Rates as `int` micros (rate × 1,000,000) and conversion as an integer fraction with `BigInt` from `dart:core` | No dependency; storable as plain integers in SQLite and Firestore; easy to test | Small amount of own arithmetic code; 6-decimal rate precision is a fixed limit |
| C. Keep `double` for display-only conversion | No work | Breaks NFR-07; sums of converted values drift |

## Decision
B.
- `ExchangeRate.perUsdMicros: int` (units of the currency per 1 USD, × 10^6, rounded half-up when parsed from the source text; the source value is parsed as text, never through `double`). USD = 1,000,000.
- Conversion A → B (R-02b) is the exact fraction `amountMinorA × perUsdMicros(B) × 10^decimals(B)` over `perUsdMicros(A) × 10^decimals(A)`, held as a `BigInt` numerator and denominator.
- Totals add exact fractions; rounding happens once, half-up, when a value is shown (BR-15).
- The fraction type is a small value object in `lib/domain`, with unit tests.

## Consequences
Positive: no package; NFR-07 holds by construction; same integer in every storage.
Negative: rates beyond 6 decimals are rounded at input; own code to maintain (about one file).

## Verification
Unit tests: symmetry (A→B→A returns the original within one minor unit after rounding), sums of 1,000 conversions equal the fraction sum, parsing of source text without `double`, overflow-free at the maximum amount (10^12 minor units).
