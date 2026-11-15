# ADR-0005 — Reference rates: fetched by the device, synced per owner, USD pivot

Status: Accepted · 2026-11-16 · Decider: Fadi Abd AlJawwad
Amended by: ADR-0006 (JOD from the source; the JOD bullet below is superseded)
Revision: v2 after devil's-advocate review. v1 kept rates on each device only and JOD as one configuration value.
Drivers: correctness (R-02b, R-03, R-04, AC-11.2, NFR-05), convergence across devices (AC-14.4), offline (BR-23), cost (no server job).

## Context
Currencies: ILS, USD, JOD. To verify: the ECB reference set used by Frankfurter includes USD and ILS, not JOD; JOD is pegged to USD (about 0.709 JOD per USD since 1995). The ECB publishes no rates on weekends and European bank holidays. Devices of one owner must convert identically. Sign-out wipes the device (AC-01.5).

## Alternatives
| Option | For | Against |
|---|---|---|
| A. Each device fetches and keeps rates locally (v1) | No server | Devices diverge (breaks AC-14.4); cache lost on sign-out; JOD missing |
| B. Device fetches from the public source and writes rates to the owner's synced rate documents; other devices read them | Identical conversions on all devices; survives reinstall and sign-out; 1 write per day | A few reads and writes per day; first device online does the fetch |
| C. Scheduled server job writes one shared rate file for all users | One fetch for everyone | Needs a scheduler and a writer identity outside Spark limits; extra platform |

## Decision
B.
- Storage: one rate per (date, currency) as units per 1 USD (`perUsd`), exact decimal; USD = 1. Firestore: `users/{uid}/rates/{year}` map documents; locally: rate table. Rows are write-once (ADR-0003).
- Conversion A → B uses R-02b (`× perUsd(B) ÷ perUsd(A)`), symmetric by construction.
- Fetch: at most once per day (BR-18), base USD, symbols ILS; missing historical dates fetched as one range request.
- JOD: derived at fetch time from the USD peg and written as a dated row; a peg change affects only later dates.
- Weekends and holidays: dates without a published rate stay empty; R-03 lookback (7 days) covers them.
- "Outdated" = last successful refresh more than 3 days ago (`RateBook.lastRefreshedOn`), not the source's rate date (spec AC-10.4 v1.3).

## Consequences
Positive: all devices agree; historical conversions stable; no server code.
Negative: JOD correctness depends on the peg; a long source outage leaves rates outdated (handled by the spec); dependency on a free third-party API.

## Verification
Unit tests for R-02b symmetry, R-03 lookback over a 4-day holiday gap, R-04 with weekend gaps, JOD derivation; rule tests for write-once rows; contract tests with recorded API responses.
