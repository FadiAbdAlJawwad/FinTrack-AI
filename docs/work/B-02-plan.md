# B-02 — Drift schema v1 + UnitOfWork + outbox table

Status: approved · 2026-11-23 · Story: 05 §7 stage 0, gap C-02, depends: kernel.
Sources: ADR-0001 (amended), ADR-0002 rules 1, 8 (amended), ADR-0003, ADR-0010 rules 1–13, 04 §4 ports (`UnitOfWork`, `RateStore`), 04 §7 S4, S5, S9, MSE-3.

## In scope
1. Dependencies: `drift`, `drift_dev`; `build_runner` only if not already a dev dependency; versions pinned in `pubspec.lock`. `sqlite3` 3.x bundles SQLite through build hooks; no `sqlite3_flutter_libs` (EOL with `sqlite3` 3.x). No `sqlcipher_flutter_libs` (S9).
2. One database factory in `lib/data/drift/` (single open point; an S9 switch touches one file).
3. Schema v1: wallets, categories, transactions, budgets, rates, preferences, outbox, needs_attention, sync_cursor.
    - ids `TEXT`, client-generated (ADR-0002/1); amounts `INTEGER` minor units (I-02).
    - `LocalDate` `TEXT 'YYYY-MM-DD'` via `TypeConverter<LocalDate, String>`; reading a non-canonical value throws (ADR-0010/10). No SQL `CHECK` on date format.
    - Instants `INTEGER` ms UTC; no `DateTimeColumn` (ADR-0010/9).
    - Synced tables: `server_updated_at INTEGER` microseconds, null until first pull; sync_cursor `INTEGER` microseconds.
    - rates: `per_usd_micros INTEGER`, PK (date, currency), no CHECK, no `TypeConverter` to `PerUsdMicros` (MSE-3).
4. outbox: `seq INTEGER PRIMARY KEY AUTOINCREMENT`, `writes TEXT` (JSON list of `{collection, docId, op, data}`), `keys TEXT` (JSON list of `collection/docId`), `status TEXT` (`pending | rejected | held`, default `pending`). One row = one Firestore batch (ADR-0010/3).
5. `UnitOfWork` port in `lib/domain` (`Future<T> run<T>(Future<T> Function() action)`); Drift adapter sets a zone key. Nested `run` → `StateError`; synced-store write outside `run` → `StateError`; both always on, release included (ADR-0010/5, 11).
6. Synced-store write path: record + outbox row in the same transaction; ops per the table below (ADR-0010/4). Only the stores the contract tests need: wallets, transactions (`saveTransfer(transfer, fee)`).
7. Pull-apply write path in `lib/data/sync` that writes no outbox row (ADR-0010/6). Decoding (ADR-0010/10) lands with US-14.
8. `assertNotInUnitOfWork()` helper in `lib/data` for network adapters (ADR-0010/12); per-adapter tests land with each adapter.
9. Schema snapshot v1 exported with `drift_dev`.
10. Folder rules `lib/data/drift/AGENTS.md`, `lib/data/sync/AGENTS.md` (texts below).
11. Lints: `unawaited_futures` in root `analysis_options.yaml`; `discarded_futures` in `lib/data/analysis_options.yaml` with `include: ../../analysis_options.yaml`. Scoping verified by V1.

## Out of scope
Push/pull engine, error classification, held dependents, pull decoding (US-14); Firestore rules incl. E1a, E1b (B-06); stores beyond item 6 (B-07 onward); rate mapping and `validate` (B-20, B-12).

## Op per collection (owner approved 2026-11-22)
| Collection   | create                            | edit                                                          | delete marker                                 |
|--------------|-----------------------------------|---------------------------------------------------------------|-----------------------------------------------|
| wallets      | `set`                             | `update` changed fields; `hasTransactions` only `update true` | n/a (I-14: never deleted; archive = `update`) |
| categories   | `set`                             | `update` changed fields                                       | `update {deleted: true}`                      |
| transactions | `set`                             | `update` changed fields                                       | `update {deleted: true}`                      |
| budgets      | `set` (one doc per version, I-16) | `update` limit of that version                                | `update {deleted: true}`                      |
| rates        | `set`                             | none (I-21)                                                   | none                                          |
| preferences  | `set`                             | `update`                                                      | n/a                                           |

## Outbox `keys` per collection (ADR-0010/3, owner approved 2026-11-23)
Own key of every write in the row, plus:
| Collection | Referenced keys |
|---|---|
| wallets | — |
| categories | — |
| transactions | wallet; category; transfer: both wallets; fee: its wallet |
| budgets | category |
| rates | — |
| preferences | — |

## Contract tests (in-memory Drift, `contract(B-02)`)
| ID               | Test                                                                                                           |
|------------------|----------------------------------------------------------------------------------------------------------------|
| ADR-0002/1       | A throw inside `run` rolls back the record and its outbox row                                                  |
| I-08             | Transfer + fee → one outbox row with two writes, or nothing                                                    |
| ADR-0010/11      | `run` inside `run` throws `StateError`; outer writes rolled back                                               |
| ADR-0010/5       | Synced-store write outside `run` throws `StateError`                                                           |
| ADR-0010/6       | Pull-apply path writes N documents → outbox count unchanged                                                    |
| ADR-0010/2       | Payload `jsonDecode(jsonEncode(x)) == x`; no `Timestamp`, no `serverUpdatedAt` key                             |
| ADR-0010/3       | Transfer + fee row: `keys` = both transaction keys + both wallet keys + category keys                          |
| ADR-0010/4       | create → `set`; edit → `update` with changed fields only; delete → `update {deleted: true}`                    |
| ADR-0010/9       | `LocalDate` stored as `'YYYY-MM-DD'`; text order = date order across a year boundary; instant stored as ms UTC |
| ADR-0010/10      | Raw `'2026-2-1'` inserted with `customStatement` → read throws                                                 |
| ADR-0002 order   | Outbox rows read back in `seq` order regardless of instant values                                              |
| NFR-04 (partial) | Same client id saved twice → one record row (upsert), two outbox rows                                          |

## Verification
V1 — lint scope: one discarded future in `lib/data`, one in `lib/features`; `flutter analyze` flags only the first. If not: global `unawaited_futures` only; record residual risk in `docs/progress.md`.

## Folder rules
`lib/data/drift/AGENTS.md`:
> Dates are `TEXT 'YYYY-MM-DD'` through the `LocalDate` converter; reading a non-canonical date throws. Instants are `INTEGER` ms UTC; `server_updated_at` and the sync cursor are `INTEGER` microseconds. No `DateTimeColumn`, no `CHECK` on dates. Synced stores write their outbox row in the same `UnitOfWork` transaction and throw `StateError` outside `UnitOfWork.run`. ADR-0010.

`lib/data/sync/AGENTS.md`:
> Outbox payload is JSON with JSON-native types only; `serverUpdatedAt` is never in it and is added at push as `FieldValue.serverTimestamp()`. Pull-apply and restore never write outbox rows and decode before writing (ADR-0010/10). No network call inside `UnitOfWork.run`: read rows (tx) → send (no tx) → mark or remove (tx).

## Commits
1. `docs(adr): ADR-0010` — done.
2. `docs(B-02): plan` — done.
3. `chore(B-02): add drift dependencies` — `pubspec.yaml`, `pubspec.lock` only (owner, `flutter pub add`).
4. `contract(B-02)` — C1 schema → owner runs `build_runner` → C2 ports, stubs, tests above; one commit including `*.g.dart`.
5. Implementation.
6. Docs (folder rules, repo-map, status).

CI (Linear history, G-3, G-4, G-10, SHA rule): moved out of B-02; one workflow PR after B-02 merge (MSE).