# Repo map

The code is migrating from the legacy layout to the target layout story by story (05-gap-analysis, strangler approach). New code goes only into the target folders.

## Target (ADR-0001)
| Path                                                                      | Contents                                                                                                                                     |
|---------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| `lib/domain/`                                                             | Entities, value objects (`Money`, `CurrencyCode`), invariants I-xx, rules R-xx, ports. Pure Dart. Own rules: `lib/domain/AGENTS.md`          |
| `lib/domain/money/`                                                       | `CurrencyCode`, `Money`, `maxMinorUnits`, `ExactAmount`, `parseMoney` (`ParseMoneyResult`, `AmountError`)                                    |
| `lib/domain/rates/`                                                       | `PerUsdMicros`, `maxPerUsdMicros`, `RateParseResult`, `RateError`, `convert` (R-02b; ADR-0007, ADR-0009)                                     |
| `lib/domain/time/`                                                        | `LocalDate`, `Clock` (port; no adapter yet)                                                                                                  |
| `lib/domain/persistence/`                                                 | UnitOfWork (port): record + outbox row in one local transaction (ADR-0002, ADR-0010/5)                                                                                                 |
| `lib/data/drift/`                                                         | Drift schema, DAOs, SQL aggregates. Own rules: `lib/data/drift/AGENTS.md`                                                                    |
| `lib/data/sync/`                                                          | Outbox, push, pull, Needs attention. Own rules: `lib/data/sync/AGENTS.md`                                                                    |
| `lib/data/remote/`                                                        | Firestore maps                                                                                                                               |
| `lib/data/ai/`, `lib/data/rates/`, `lib/data/auth/`, `lib/data/app_lock/` | Adapters for `AiExtractor`, `RateProvider`, `AuthGateway`, `AppLock`                                                                         |
| `lib/features/<feature>/`                                                 | Screens, Riverpod controllers, use cases of one feature. Own rules: `lib/features/AGENTS.md`                                                 |
| `lib/core/`                                                               | Theme, design tokens, shared widgets, l10n wiring, number/date formatter and digit normalizer (BR-30..BR-32), routing, DI. No business rules |
| `test/`                                                                   | Mirrors `lib/`. AC tests named by AC ID. `test/architecture/` = boundary tests                                                               |
| `test/data/`                                                              | Tests for lib/data/ (in-memory Drift)                                                                                               |
| `drift_schemas/`                                                          | Schema snapshots per schemaVersion (drift_dev schema dump); input for migration tests. Never edit by hand                                                                                                                     |
| `tools/rules-test/`                                                       | Emulator tests for `firestore.rules`. Own rules: `tools/rules-test/AGENTS.md`                                                                |
| `worker/`                                                                 | Cloudflare Worker AI proxy (stage 3)                                                                                                         |
| `tools/check.dart`, `tools/repo_map.dart`                                 | `check.dart` (single gate), `repo_map.dart` (regenerates the exports section below). Stage 0 "Gate and guards"                               |
| `docs/work/`                                                              | `<US-xx or B-nn>-plan.md`: approved plan of the current item; deleted when the item merges                                                   |
| `evals/tasks.md`                                                          | Fixed tasks to run before and after every agent-context change                                                                               |

## Legacy (being replaced; do not extend)
| Path                                                               | Replaced by                                                     |
|--------------------------------------------------------------------|-----------------------------------------------------------------|
| `lib/features/*/domain/`, `lib/features/*/data/`                   | `lib/domain/`, `lib/data/`                                      |
| `lib/features/currency/data/services/exchange_rate_service.dart`   | `lib/data/rates/` (ADR-0005, ADR-0006)                          |
| `lib/core/services/gemini_service.dart` (Apps Script)              | `lib/data/ai/` + `worker/` (ADR-0004)                           |
| `lib/features/wallets/data/services/wallet_migration_service.dart` | Removed (gap C-20)                                              |
| `bench-check.ps1`                                                  | `tools/check.dart` (gap C-24); deleted when the new gate exists |

## Exports (generated)
Not generated yet. From stage 0 "Gate and guards": `dart run tools/repo_map.dart` rewrites this section (one line per file under `lib/domain`, `lib/data`, `lib/core`: path → public top-level names); the gate fails if it is stale. Do not edit by hand.
