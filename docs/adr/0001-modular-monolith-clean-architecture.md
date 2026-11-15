# ADR-0001 — Shared domain kernel with vertical feature slices

Status: Accepted · 2026-11-16 · Decider: Fadi Abd AlJawwad
Revision: v2 after devil's-advocate review (`claude/fintrack/04-architecture-review-v1.md`). v1 proposed per-feature domain layers.
Drivers: explainability (portfolio), correctness (NFR-05, NFR-07), testability (one test per AC), solo developer.

## Context
One Android app, one developer. The finance domain is highly cohesive: recording one transaction reads wallets, categories, and rates, and changes balances, budgets, and net worth. Insights, budgets, and sync touch every entity. Tests are the contract (`02-spec` Conventions).

## Alternatives
| Option | For | Against |
|---|---|---|
| A. Layered by type (`screens/`, `services/`, `models/`) | Familiar | Domain rules leak into widgets; no edit boundary for agents |
| B. Feature-first, each feature with its own `domain/data/presentation` (v1 proposal) | Clear per-feature boundary | The cohesive domain gets split; features import each other or everything moves to `core/`; four representations per entity |
| C. Shared domain kernel + vertical feature slices: one `lib/domain` (entities, invariants, rules R-xx, ports), one `lib/data` (database, sync engine, adapters), and `lib/features/<feature>` holding presentation and the use cases of that feature | Matches domain cohesion; one place for every invariant; features stay thin and independent of each other | Kernel can grow large; boundaries enforced by tests, not the compiler |
| D. One package per feature (monorepo) | Compiler-enforced boundaries | Heavy tooling for one developer |

## Decision
C.
- Dependency rule: `features → domain ← data`. Features never import other features. Domain imports no Flutter, Firebase, HTTP, or Drift.
- Ports in domain: `TransactionStore`, `WalletStore`, `CategoryStore`, `BudgetStore`, `RateStore`, `PreferenceStore`, `UnitOfWork`, `SyncGateway`, `AiExtractor`, `RateProvider`, `AuthGateway`, `AppLock`, `Clock`.
- `UnitOfWork.run(() async {...})` gives use cases one atomic local transaction across stores (for example AC-13.4: move transactions, delete budgets, delete category, write outbox rows).
- Calculation split: per-item rules (validation, conversion, budget version choice, draft rules) are pure Dart; aggregates over many rows (balances, period totals, category totals) are SQL in the data layer and are tested as AC tests against an in-memory Drift database, so NFR-05 tests the real query.
- Representations: domain entity, Drift row, Firestore map. The outbox payload is the Firestore map (no fourth type).

## Consequences
Positive
- Every invariant lives in one place; agents get a clear target per story: one feature folder plus named kernel files.
- Aggregate correctness is tested on real SQL, fast (in-memory database).

Negative
- The kernel needs discipline to stay free of feature-specific code.
- Boundaries depend on architecture tests.

## Verification
Architecture tests fail the build when: a `domain` file imports `package:flutter`, `firebase_*`, `cloud_firestore`, `http`, or `drift`; a feature imports another feature; `data` imports a feature.
