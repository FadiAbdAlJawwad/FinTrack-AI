# lib/data/drift — rules (ADR-0001, ADR-0002)

- Aggregates (balances, period and category totals) are SQL here, tested as AC tests on an in-memory Drift database (`NativeDatabase.memory()`).
- Raw SQL only through `customSelect` / `customStatement` with `variables`. Never build SQL by string interpolation or concatenation.
- Amounts and rates are `INTEGER` columns. No `REAL` column for money or rates.
- Every write that must sync runs inside the caller's `UnitOfWork` and adds its outbox row in the same transaction.
- Schema change = bump `schemaVersion` + a migration step + a migration test. Never edit a released migration.
