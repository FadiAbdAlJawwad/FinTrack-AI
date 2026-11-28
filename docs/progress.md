# Progress — B-02 Drift schema v1 + UnitOfWork + outbox

Read first, update last. One page, four sections, current story only. Stage status lives in `05-gap-analysis.md` §7 (not here). When a story is merged: move durable decisions to an ADR or `lessons.md`, then empty this file for the next story.

Story: B-02 · Branch: `feat/b-02-drift-schema` · Plan: `docs/work/B-02-plan.md` (approved) · Updated: 2026-11-26
Next story: B-20 Kernel hardening (rates) (05 §7, stage 0).

## Done
- ADR-0010 "Local storage types, outbox encoding and UnitOfWork rules" committed (`6168c25`); it amends ADR-0001 and ADR-0002.
- B-02 contract step C1: declared Drift schema v1 (9 tables), AppDatabase, DatabaseFactory, stub LocalDateConverter, and CorruptStoredValueException.
- B-02 contract step C2: declared UnitOfWork, unit_of_work_zone, DriftUnitOfWork, WalletsWriter, TransactionsWriter, PulledDoc, PulledDocApplier, and OutboxReader stubs; written 12 contract tests.
- B-02 step 5 (Implementation): implemented LocalDateConverter, unit_of_work_zone, DriftUnitOfWork, WalletsWriter, TransactionsWriter, PulledDocApplier, and OutboxReader; all 12 contract tests and 575 existing tests pass (587 total), flutter analyze clean.
- Fixed review findings IM1 and IM2 of B-02 in implementation: WalletsWriter.update validates matching wallet.id and id before writing; unit_of_work_zone.dart is now a part file of drift_unit_of_work.dart with library-private zone key and zone helper.

## Decisions made in this story
- ADR-0010 is the decision record for B-02 (D1–D3, D5, E1–E3). D4 (database encryption) stays with 04 §7 S9.
- Op per collection (owner 2026-11-22) and outbox `keys` per collection (owner 2026-11-23): tables in the plan.
- Q2a = A approved: synced-store writers in B-02 are data-internal (`WalletsWriter`, `TransactionsWriter` in `lib/data`); domain ports land in B-07.
- 2026-11-26 Q2a = A: B-02 uses data-internal writers in `lib/data/drift` (`WalletsWriter.create/update`, `TransactionsWriter.saveTransfer(TransactionDto transfer, TransactionDto? fee)`); domain port signatures (`WalletStore`, `TransactionStore`) deferred to B-07 (target entities do not exist yet, C-03).
- 2026-11-26 Q2b: pull-apply = `PulledDocApplier.apply` in `lib/data/sync`, no outbox row, `assertNotInUnitOfWork()` first.
- 2026-11-26 Q2c: corrupt stored value on read throws `CorruptStoredValueException` (`lib/data/drift`). Open for MSE (non-blocking): domain-level failure type if features must handle it (ADR-0001 `features → domain ← data`).

## Next
- B-02 complete; ready for commit and merge into main.

## Open questions
Decide in MSE before US-14; none blocks B-02.
- F1: ADR-0010 has no `held` → `pending` transition; a held row never releases after its rejected parent is retried or discarded.
- F2: Firestore codes outside rule 7 (`aborted`, `cancelled`, `internal`, `unknown`, `data-loss`, `out-of-range`, `already-exists`) have no class; a default is needed (transient stalls the queue, terminal gives false Needs attention).
- F3: `preferences` create is `set`; a device that writes preferences before its first restore overwrites the other device's document. Depends on the restore order in 02-spec (not checked).
