# FinTrack AI

A bilingual (Arabic / English) personal finance tracker built with Flutter on Firebase Spark.

FinTrack AI helps one person keep an exact record of their money across several wallets and currencies: cash, e-wallets and bank accounts. Transactions can be typed in, spoken, or (planned) scanned from a receipt; AI turns voice and receipt input into a draft transaction that the user confirms before saving.

Design goals:
- **Exact money.** Amounts are stored as integer minor units with their currency, and exchange rates as integers, so totals never drift through floating-point rounding.
- **Works on weak connections.** The target is mid- and low-end Android phones on 3G-class networks. The app is moving to a local-first model: the phone's database is the source of truth and syncs to the cloud when a connection is available.
- **Arabic first-class.** Full right-to-left layout, Arabic plural forms, and locale-aware number and date formatting, alongside English.
- **Private and secure.** Biometric app lock, per-user access rules on the server, and no secrets in the repository.
## Features

| Area | Feature | Status |
|---|---|---|
| Account | Sign-in with email/password or Google; sign-up; password reset; onboarding | Available |
| Security | App lock with biometrics | Available |
| Wallets | Cash, e-wallet and bank wallets; opening balance; add, edit, delete | Available |
| Wallets | Archive and restore a wallet | Planned |
| Transactions | Income and expense with categories; transaction list and details | Available |
| Transactions | Transfers between wallets, cross-currency transfers, transfer fees | Planned |
| Transactions | Custom categories; deleting a category moves its transactions to Other | Planned |
| Assisted entry | Voice entry: speech to text, then AI extracts a draft transaction | Available |
| Assisted entry | Receipt scanning: camera + AI extract a draft transaction | Planned |
| Currency | Display currency selection | Available |
| Currency | Balances and net worth in the display currency, with historical rates | Planned |
| Insights | Analytics screen with period filter and spending by category | Available |
| Insights | Period comparison and custom date ranges | Planned |
| Budgets | Monthly budgets per category | Planned |
| Settings | Language, light/dark theme, currency, biometrics, sign-out | Available |
| Data | Exact money model: integer minor units and integer rates | In progress (domain layer built, not yet used by the screens) |
| Data | Local-first storage: on-device database with an outbox for sync | In progress |
| Data | Offline use with background sync and a "Needs attention" list | Planned |

The current screens are kept; the domain and data layers behind them are being rebuilt one feature at a time. Delivery order: [docs/05-gap-analysis.md](docs/05-gap-analysis.md) §7.

## Tech stack

| Area | Tools |
|---|---|
| Framework | Flutter, Dart |
| State management | Riverpod (`hooks_riverpod`, `flutter_hooks`) |
| Routing | `go_router` |
| Models and codegen | `freezed`, `json_serializable`, `build_runner` |
| Backend | Firebase Auth, Cloud Firestore (Spark plan) |
| Local database | Drift on SQLite (being added) |
| Localization | `flutter_localizations`, `intl`, ARB files |
| Device | `local_auth`, `speech_to_text`, `share_plus` |
| Quality | `flutter_lints`, unit and widget tests, Firestore rules tests, GitHub Actions CI |

## Architecture

- **Clean Architecture**: `features → domain ← data`. `lib/domain` is pure Dart: no Flutter, Firebase, HTTP or database imports. A feature never imports another feature. [ADR-0001](docs/adr)
- **Local-first**: every write stores the record and its outbox row in one local transaction; the outbox is pushed to Firestore. [ADR-0002](docs/adr)
- **Money**: `int` minor units plus a currency; exchange rates as `int` micros; never `double` for stored or summed values. [ADR-0007](docs/adr)
- **Errors**: typed failures mapped to localized messages; raw error text is never shown to the user.
- **Security**: Firestore access rules with emulator tests; configuration injected at build time with `--dart-define`.
## Project structure

```
fin_track_ai/
├── lib/
│   ├── core/              # Theme, shared widgets, routing, providers, formatting, errors
│   ├── domain/            # Pure Dart: Money, CurrencyCode, Clock, rates, ports
│   ├── data/              # (being added) Drift database, outbox and sync, Firestore and API adapters
│   ├── features/
│   │   ├── analytics/     # Analytics screen and period filter
│   │   ├── auth/          # Splash, onboarding, sign-in, sign-up, reset password, lock screen
│   │   ├── currency/      # Display currency
│   │   ├── dashboard/     # Home screen
│   │   ├── settings/      # Preferences and security settings
│   │   ├── shell/         # Bottom navigation shell
│   │   ├── transactions/  # Transaction list, details, add/edit sheet, voice entry
│   │   └── wallets/       # Wallet list, add/edit wallet
│   └── l10n/              # ARB files (ar, en) and generated localizations
├── test/                  # Mirrors lib/; architecture boundary tests in test/architecture/
├── tools/rules-test/      # Emulator tests for firestore.rules
├── config/                # dev.example.json (copy to dev.local.json)
├── docs/                  # Spec, domain model, architecture, ADRs, repo map
├── firestore.rules        # Server access rules
└── AGENTS.md              # Rules for coding agents working in this repo
```

Full map with legacy paths: [docs/repo-map.md](docs/repo-map.md).

## Documentation

- [docs/index.md](docs/index.md) — Start here: index to specifications, domain rules, and architecture.
- [docs/02-spec.md](docs/02-spec.md) — User stories and acceptance criteria.
- [docs/adr/](docs/adr) — Architecture decisions.
- [AGENTS.md](AGENTS.md) — Project ground rules and operational commands.
- [docs/progress.md](docs/progress.md) — Current stage and delivery progress.
- [docs/repo-map.md](docs/repo-map.md) — Repository structure and directory layout.
## Local setup

1. Run `flutter pub get`.
2. Add Firebase configuration files (not in the repository; both are git-ignored):
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
3. Copy `config/dev.example.json` to `config/dev.local.json` (git-ignored) and fill in the values.
4. Run the app:
```bash
flutter run --dart-define-from-file=config/dev.local.json
```
This is also the VS Code launch configuration (`.vscode/launch.json`).

## Checks

- `flutter analyze`
- `flutter test`
- Firestore rules tests: see [tools/rules-test/README.md](tools/rules-test/README.md)
 