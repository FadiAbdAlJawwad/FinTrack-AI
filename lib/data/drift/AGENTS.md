# lib/data/drift — rules (ADR-0001, ADR-0002, ADR-0010)

- Aggregates (balances, period and category totals) are SQL here, tested as AC tests on an in-memory Drift database (`NativeDatabase.memory()`).
- Raw SQL only through `customSelect` / `customStatement` with `variables`. Never build SQL by string interpolation or concatenation.
- Amounts and rates are `INTEGER` columns. No `REAL` column for money or rates.
- Every write that must sync runs inside the caller's `UnitOfWork` and adds its outbox row in the same transaction.
- Schema change = bump `schemaVersion` + a migration step + a migration test. Never edit a released migration.
- Dates are `TEXT 'YYYY-MM-DD'` through the `LocalDate` converter; reading a non-canonical date throws. Instants are `INTEGER` ms UTC; `server_updated_at` and the sync cursor are `INTEGER` microseconds. No `DateTimeColumn`, no `CHECK` on dates. Synced stores write their outbox row in the same `UnitOfWork` transaction and throw `StateError` outside `UnitOfWork.run`. ADR-0010.
