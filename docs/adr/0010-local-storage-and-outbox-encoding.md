# ADR-0010 — Local storage types, outbox encoding and UnitOfWork rules

Status: Accepted · 2026-11-22 · Decider: Fadi Abd AlJawwad
Amends: ADR-0001 (meaning of "the outbox payload is the Firestore map"), ADR-0002 (rule 4 held dependents, rule 7 trust). Drivers: NFR-04, BR-24, I-08, ADR-0003, B-02 open questions D1–D3, D5 and review findings E1–E3.

## Context
ADR-0001 makes the outbox payload the Firestore map, but `Timestamp` and `FieldValue.serverTimestamp()` have no JSON form. ADR-0002 does not say who writes the outbox row, how a rejected create affects later entries, or how pulled data is decoded. Drift stores `DateTime` by default as unix seconds and returns a local `DateTime`, which shifts calendar dates and loses sub-second order. Drift nests transactions as savepoints, so an outer block can catch an inner failure and commit a partial unit.

## Decision
### Encoding
1. Synced documents hold only JSON-native values: integers (amounts, rates, ids of enums), strings, bools, nested maps and lists. Calendar dates are `'YYYY-MM-DD'` strings; instants are integer milliseconds since the epoch, UTC. The only `Timestamp` field is `serverUpdatedAt`.
2. The outbox payload is the Firestore document shape as JSON text. `serverUpdatedAt` is never stored in it; the push step adds `FieldValue.serverTimestamp()` to every write.
3. One outbox row = one Firestore batch: `seq` (autoincrement, the only order), `writes` (list of `{collection, docId, op, data}`), `keys` (every document key the row writes or references), `status` (`pending | rejected | held`).
4. Operations: create = `set`; edit = `update` with changed fields only; deletion = `update {deleted: true}`. Write-once documents (rates) are create-only.

### Who writes
5. Synced store adapters in `lib/data` write their outbox row in the same `UnitOfWork` transaction. A synced write outside `UnitOfWork.run` throws `StateError`. A multi-document operation (transfer + fee; first transaction + wallet `hasTransactions`) is one store method and one outbox row.
6. Pull-apply and restore write through a path in `lib/data/sync` that writes no outbox row.

### Push results
7. Server errors are terminal (`permission-denied`, `not-found`, `invalid-argument`, `failed-precondition`) or transient (`unavailable`, `deadline-exceeded`, `unauthenticated`, `resource-exhausted`). Transient: the cycle stops; the row stays first in order. Terminal: the row becomes `rejected`.
8. Held dependents: during push, the keys of every `rejected` or `held` row form the blocked set. A pending row whose `keys` intersect it becomes `held`, and its keys join the set. Held and rejected rows are not sent; unrelated rows continue in order. Statuses are persisted, so the result survives a restart (BR-24).

### Storage types
9. `LocalDate` is `TEXT 'YYYY-MM-DD'`; instants are `INTEGER` ms UTC; no `DateTimeColumn`. `serverUpdatedAt` and the pull cursor are `INTEGER` microseconds, never rounded up.
10. Decoding boundary: data entering SQLite from Firestore (pull, restore) is decoded before the write. A date is accepted only if it round-trips: `LocalDate.tryParse(text)?.toIso8601String() == text`. A document that fails decoding is skipped, logged once (collection, id, field), and the cursor still advances. Pulled documents that decode are applied without re-checking domain invariants (ADR-0002 rule 7 unchanged in that sense). Reading a non-canonical date from SQLite throws: only corruption can cause it. No SQL `CHECK` on date format.

### UnitOfWork
11. `run` inside `run` throws `StateError`. One `run` is one atomic unit; savepoints are not used by the domain.
12. Inside `run`: local stores, pure domain code and `Clock` only. No network, AI, rate provider, auth, sync gateway or platform channel. Every future is awaited.
13. Sync engine: read rows (transaction) → send (no transaction) → mark or remove (transaction).

## Enforcement
| Rule                                   | Release                                                                               | Debug / test                                                                              |
|----------------------------------------|---------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|
| 5 write outside `run`, 11 nested `run` | `StateError` (always on: a missing outbox row loses data; a partial unit breaks I-08) | Unit tests                                                                                |
| 12 network inside `run`                | Not checked (accepted risk)                                                           | `assert` on the `UnitOfWork` zone key at each network adapter entry; one test per adapter |
| 12 unawaited futures                   | Not checked                                                                           | Lint `unawaited_futures` everywhere; `discarded_futures` under `lib/data` only            |

## Alternatives
| Option                                                  | Against                                                                                |
|---------------------------------------------------------|----------------------------------------------------------------------------------------|
| Tagged JSON codec (`{"$ts": …}`)                        | A fourth representation and a codec to test; no field needs it                         |
| Use case writes the outbox row through an `Outbox` port | Every use case can forget it; the domain learns Firestore batching                     |
| Full `set` for edits                                    | A stale wallet write carries `hasTransactions = false`; the rule rejects it            |
| `set(merge: true)` for edits                            | Hides the NOT_FOUND of a rejected create behind a schema rejection                     |
| Drift default `DateTime`                                | Date shift across time zones; second precision                                         |
| SQL `CHECK` on dates                                    | One bad pulled value aborts the whole apply transaction; changing it needs a migration |
| Savepoint-nested `run`                                  | Outer code can commit a partial unit                                                   |

## Consequences
Positive: payloads are plain JSON and testable without Firestore; dates compare as text in SQL and match the Firestore field; rejected creates never produce a chain of NOT_FOUND errors; atomicity violations fail in release.
Negative: push needs error classification and a persisted blocked set; the network-in-transaction rule is enforced only in debug and tests; a skipped pulled document stays missing until it changes again.

## Verification
Tests on an in-memory Drift database and a fake Firestore gateway: payload JSON round-trip with no `Timestamp`; write outside `run` and nested `run` throw `StateError`; pull-apply of N documents leaves the outbox unchanged; rejected create → later `update` of the same document and an expense in that wallet are `held`, an unrelated row is sent; transient error stops the cycle with order unchanged; statuses survive reopening the database; `'2026-2-1'`, `' 2026-02-01'`, `'2026-02-30'` skipped at pull with one log entry each, cursor advanced; non-canonical date in SQLite throws on read; network adapter called inside `run` fails the assert.