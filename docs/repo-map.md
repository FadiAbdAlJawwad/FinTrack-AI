# Repo map

The code is migrating from the legacy layout to the target layout story by story (05-gap-analysis, strangler approach). New code goes only into the target folders.

## Target (ADR-0001)
| Path | Contents |
|---|---|
| `lib/domain/` | Entities, value objects (`Money`, `CurrencyCode`), invariants I-xx, rules R-xx, ports. Pure Dart. Own rules: `lib/domain/AGENTS.md` |
| `lib/data/drift/` | Drift schema, DAOs, SQL aggregates |
| `lib/data/sync/` | Outbox, push, pull, Needs attention. Own rules: `lib/data/sync/AGENTS.md` |
| `lib/data/remote/` | Firestore maps |
| `lib/data/ai/`, `lib/data/rates/`, `lib/data/auth/`, `lib/data/app_lock/` | Adapters for `AiExtractor`, `RateProvider`, `AuthGateway`, `AppLock` |
| `lib/features/<feature>/` | Screens, Riverpod controllers, use cases of one feature |
| `lib/core/` | Theme, design tokens, shared widgets, l10n wiring, routing, DI. No business rules |
| `test/` | Mirrors `lib/`. AC tests named by AC ID. `test/architecture/` = boundary tests |
| `tools/rules-test/` | Emulator tests for `firestore.rules`. Own rules: `tools/rules-test/AGENTS.md` |
| `worker/` | Cloudflare Worker AI proxy (stage 3) |

## Legacy (being replaced; do not extend)
| Path | Replaced by |
|---|---|
| `lib/features/*/domain/`, `lib/features/*/data/` | `lib/domain/`, `lib/data/` |
| `lib/features/currency/data/services/exchange_rate_service.dart` | `lib/data/rates/` (ADR-0005, ADR-0006) |
| `lib/core/services/gemini_service.dart` (Apps Script) | `lib/data/ai/` + `worker/` (ADR-0004) |
| `lib/features/wallets/data/services/wallet_migration_service.dart` | Removed (gap C-20) |
