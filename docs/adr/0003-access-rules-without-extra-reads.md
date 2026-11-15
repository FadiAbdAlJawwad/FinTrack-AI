# ADR-0003 — Server access rules validate ownership, schema, and cross-document invariants

Status: Accepted · 2026-11-16 · Decider: Fadi Abd AlJawwad
Revision: v2 after devil's-advocate review. v1 chose "no extra reads"; reversed. File name kept for link stability.
Amended by: ADR-0008 (the archived-wallet check applies only to create and move).
Drivers: data isolation (NFR-08, BR-27), correctness across devices (AC-04.8, AC-09.8, BR-24), cost.

## Context
The local domain checks every single-document invariant before a change enters the outbox, so the server rejects nothing in normal use unless it also checks the cross-document cases. Those cases are exactly the multi-device races the spec defines (AC-04.8, AC-09.8), and "Needs attention" (BR-24) exists to show them. Extra `get()` calls cost about 1–2 billed reads per write: around 1–2% of the daily read quota for one active owner.

## Alternatives
| Option | For | Against |
|---|---|---|
| A. Ownership + schema only (v1) | Zero extra reads | Server accepts conflicting writes; AC-04.8 and AC-09.8 impossible; Needs attention almost never fills; clients must re-validate pulled data, which can loop on bad records |
| B. A + selective `get()` + a `hasTransactions` flag on each wallet, written in the same batch as the wallet's first transaction | Enforces I-03, I-13, I-14, deletion protection on the server; pulled data is trustworthy | 1–2 reads per transaction write; more complex rules and rule tests |
| C. Server code validates writes (Cloud Functions) | Full control | Needs the Blaze plan: impossible |

## Decision
B. Rules enforce:
- Ownership only (I-19); schema, types, closed sets (I-24); amounts > 0 (I-01); integer minor units (I-02); `from ≠ to` (I-04); limits > 0 (I-17); opening balance ≥ 0 (I-18); immutable wallet currency and category type (I-23).
- **Deletion protection:** any write to a document whose stored `deleted` is true is rejected (uses `resource`, no extra read).
- **Transaction writes:** `get()` of the referenced wallet(s): wallet exists, not deleted, not archived for new or moved transactions (I-13), and amount currency equals wallet currency (I-03).
- **Wallet flag:** the first transaction in a wallet sets `hasTransactions = true` in the same batch; the flag can only go from false to true.
- **Wallet deletion:** allowed only while `hasTransactions` is false (I-14), using `resource`, no extra read. With arrival order this produces AC-04.8 v1.3.
- Rate documents: write-once per (date, currency) (I-21).

## Consequences
Positive: every spec race has a server-side outcome; Needs attention receives real rejections; pulled records are trusted (no re-validation loop).
Negative: about 1–2 extra reads per transaction write; rules become code that needs its own test suite.

## Verification
Emulator rule tests for every bullet above, including negative tests and the two arrival orders of AC-04.8; run before every rules deploy and in CI (NFR-08).
