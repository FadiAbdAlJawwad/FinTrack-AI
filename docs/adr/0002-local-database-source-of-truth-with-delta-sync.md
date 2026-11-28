# ADR-0002 — Source of truth on the device: local database with staged delta sync

Status: Accepted · 2026-11-16 · Decider: Fadi Abd AlJawwad · Amended by ADR-0010 (2026-11-22)
Revision: v2 after devil's-advocate review. Changes: push/pull order, cursor rule, deletion protection, outbox dependencies, staged delivery instead of a false fallback.
Drivers: offline-first (NFR-04, BR-23), correctness of all-time balances (R-01, NFR-05), cost (Spark: 50,000 reads / 20,000 writes per day, no card).

## Context
- Balances are all-time (R-01); reports aggregate all history.
- 30 days offline with 500 transactions, nothing lost (NFR-04).
- Multi-device: the change that reaches the server first wins against later conflicting ones as defined per case; deletion beats edit; a deleted record never comes back (BR-25, AC-04.8, AC-09.8, AC-13.6).
- A rejected change is shown, never silently rolled back (BR-24).
- Firestore bills one read per returned document; a listener detached for over 30 minutes re-reads its whole result.

## Alternatives
| Option | For | Against |
|---|---|---|
| A. Firestore offline cache only | Least code | Full re-read of history on cold starts; no SQL; SDK rollback is silent (breaks BR-24); no deletion markers |
| B. Firestore cache + client-maintained summary documents | Cheap headline reads | Counters drift; still breaks BR-24 |
| C. Local SQLite (Drift) as source of truth + own sync engine | Free offline reads; SQL reports; cost = changed documents only; explicit BR-24/BR-25 handling | Riskiest component to build; two schemas; data migration |
| D. Firestore SDK as transport + SQLite projection of snapshots | SDK retries for free | Two stores to keep aligned; rejections lost after an app restart (breaks BR-24) |
| E. Operation log with hybrid logical clocks, or a sync service (PowerSync) | Strong conflict model | Needs a server or a backend not available on Spark |

## Decision
C, with these rules.
1. **Local first.** Every write goes to SQLite with an outbox row in the same `UnitOfWork` transaction. Ids are generated on the client, so a repeated push is idempotent.
2. **Order.** Each sync cycle runs push, then pull.
3. **Push.** Outbox entries are sent strictly in creation order. A transfer and its fee travel in one Firestore batch (I-08). Each write sets `serverUpdatedAt` to the server timestamp.
4. **Dependencies.** If the server rejects an entry, every later entry that references the same record (for example an expense in a wallet whose creation was rejected) is held, not sent. The rejected entry and its held dependents appear together in Needs attention with MSG-09 (BR-24).
5. **Deletion.** Deletion is a marker (`deleted = true`). Access rules reject any write to a document whose stored `deleted` is true (ADR-0003), so an old offline edit can never revive it; that edit goes to Needs attention (AC-09.8).
6. **Pull.** Per collection: documents where `serverUpdatedAt >= cursor`, ordered by (`serverUpdatedAt`, document id). The cursor is the greatest `serverUpdatedAt` actually received, never the device clock. Applying a pulled document is idempotent, so re-reading the boundary is safe.
7. **Trust.** Pulled documents passed server validation (ADR-0003) and are applied without re-validation.
8. Firestore offline persistence is off; the outbox is the only queue.

## Staged delivery (replaces the v1 "fallback to A")
- **Stage 1 — single device:** push + full restore on sign-in. Covers NFR-04, BR-24, AC-01.5 restore. Multi-device editing at the same time is not supported yet.
- **Stage 2 — multi-device:** delta pull, cursor, conflict cases (AC-04.8, AC-09.7, AC-09.8, AC-13.6, AC-14.4).
- Release can ship after stage 1 if stage 2 is not stable; the spec ACs of stage 2 stay open and visible.

## Consequences
Positive: NFR-04 and R-01 hold by construction; daily reads ≈ documents changed elsewhere; every sync rule is code with tests.
Negative: the sync engine needs dedicated tests (mid-sync drop AC-14.6, session expiry AC-14.7, held dependents); two schemas; one-time migration of existing Firestore data (`05-gap-analysis`).

## Verification
NFR-04 endurance test; AC-14.1–14.7, AC-09.7, AC-09.8, AC-04.8, AC-13.6 against the Firestore emulator and a fake clock.
