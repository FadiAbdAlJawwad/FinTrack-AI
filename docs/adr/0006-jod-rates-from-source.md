# ADR-0006 — JOD rates come from the rate source

Status: Accepted · 2026-11-15 · Decider: Fadi Abd AlJawwad
Supersedes: the JOD bullet of ADR-0005 ("JOD derived at fetch time from the USD peg"). All other ADR-0005 decisions stay in force.

## Context
ADR-0005 assumed the rate source does not publish JOD and planned to derive JOD from the USD peg. Gap analysis (C-23) found that the app uses Frankfurter **v2** (`api.frankfurter.dev/v2/rates?base=USD`), which returns JOD; v1 does not. The owner compared the app's JOD conversions with the global market rate and found them correct (2026-11-15).

## Alternatives
| Option | For | Against |
|---|---|---|
| A. JOD from the source, like ILS | One code path for all currencies; no configuration value; matches observed correct results | Depends on v2 continuing to publish JOD |
| B. Derive JOD from the USD peg (ADR-0005 v2) | Independent of the source for JOD | Extra configuration and code path; peg value must be maintained |
| C. A with B as fallback when JOD is missing | Resilient | Two code paths for a case not observed |

## Decision
A. Fetch USD-based rates for ILS and JOD from Frankfurter v2 and store them as dated `perUsd` rows (ADR-0005). No peg constant, no Remote Config value.

## Consequences
Positive: one fetch and storage path for every currency; less configuration.
Negative: if v2 stops publishing JOD, JOD conversions become "unavailable" (R-03, R-04 already handle this) until a new ADR adds a fallback.

## Verification
Contract test with a recorded v2 response containing ILS and JOD; unit test that a response without JOD marks JOD conversions unavailable.
