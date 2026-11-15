# ADR-0008 — Archived-wallet check only on create and move

Status: Accepted · 2026-11-15 · Decider: Fadi Abd AlJawwad
Amends: the "Transaction writes" bullet of ADR-0003. All other ADR-0003 rules stay in force.

## Context
ADR-0003 rejects any transaction write whose wallet is archived. Deletion is a soft-delete update (ADR-0002), and deleting a custom category rewrites its transactions to "Other" (AC-13.4). So the rule also blocked correcting or deleting an old transaction in an archived wallet, and blocked category deletion whenever one affected transaction sat in an archived wallet. Spec v1.4 allows those edits (AC-04.9) and forbids only new or moved transactions (AC-04.3).

## Alternatives
| Option | For | Against |
|---|---|---|
| A. Keep the check on every write | Simplest rule | Blocks AC-04.9 and AC-13.4; history in archived wallets becomes read-only by accident |
| B. Check "not archived" only when a transaction is created or its wallet id changes | Matches the spec; history stays correctable | Rule must compare `request.resource` with `resource` |
| C. Drop the archived check on the server | No extra logic | I-13 unprotected against multi-device races |

## Decision
B. On create, and on update where `walletId`, `fromWalletId`, or `toWalletId` differs from the stored value, the referenced wallet must exist, not be deleted, and not be archived. On other updates (including the deletion marker) the wallet must exist and the currency must still match (I-03); its archived status is not checked.

## Consequences
Positive: AC-04.3, AC-04.9, AC-13.4 all hold on the server.
Negative: one more branch in the rules and two more emulator tests.

## Verification
Emulator tests: create in archived wallet denied; move into archived wallet denied; amount edit and deletion marker in archived wallet allowed; category move to "Other" in archived wallet allowed.
