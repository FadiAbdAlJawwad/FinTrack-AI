# 05-gap-analysis — FinTrack-AI

Status: Accepted v1.0 · 2026-11-16 · Owner: Fadi Abd AlJawwad
Compares the code on `main` (= local copy, owner 2026-11-16) with `docs/01..04` and ADR-0001..0005.
Scope read: domain models, DTOs, repositories, rate service, money utilities, AI parsing, voice screen, auth sign-out, app lock, access rules, Android manifest, architecture test, test inventory (≈ 55 test files), current `AGENTS.md`. Widgets and screens were inventoried, not read line by line.

## 1. Verdict

The UI layer, theme, localization, app lock, and auth flows are reusable. The domain and data layers do not match the accepted documents: no transfers, no wallet currency, fixed categories, double-based rates and AI parsing, a Firestore-cache data layer, and rules without cross-document checks. The gap is a **rebuild of domain + data behind the existing UI**, delivered story by story (strangler approach), not a full rewrite.

Existing Firestore data is test data (owner, 2026-11-16): **no migration**; collections are deleted before the new sync starts.

---

## 2. Keep

| ID | Item | Evidence | Note |
|---|---|---|---|
| K-01 | Integer minor units + per-currency decimals (ILS 2, USD 2, JOD 3) | `AppCurrency.decimals`, `parseMinorUnits` (no floating point, no rounding on input) | Move into `lib/domain` as `Money`/`CurrencyCode` |
| K-02 | Bilingual UI, ARB files ar/en | `lib/l10n/intl_ar.arb`, `intl_en.arb` | Add MSG-01..14 keys |
| K-03 | App lock with device-credential fallback, 30 s timeout | `biometricOnly: false`, `AppLockNotifier.lockTimeout` | See C-14 for the boundary |
| K-04 | Firebase Auth (email/password, Google, reset) | `auth_repository_impl.dart` | Adapter behind `AuthGateway` |
| K-05 | `allowBackup="false"` | AndroidManifest | Matches S5 |
| K-06 | Theme, design tokens, shared widgets, GoRouter | `lib/core/theme`, `lib/core/widgets`, routing | Kept as `lib/core` (no business rules) |
| K-07 | Emulator access-rule test harness | `tools/rules-test` | Reused for ADR-0003 rules |
| K-08 | CI running analyze + test | `.github/workflows/ci.yml` | Extended (C-17, C-18) |
| K-09 | Speech-to-text on device, locale-aware | `use_speech_recognition`, voice screen | Front end of US-07 |
| K-10 | Typed error translation pattern | `translateTransactionError` | Same pattern in new adapters |

---

## 3. Change

| ID | Gap (code → docs) | Spec / ADR | Decision |
|---|---|---|---|
| C-01 | Per-feature `domain/data/presentation` → shared `lib/domain` kernel + `lib/data` + feature slices; features import each other today (wallets → transactions use cases) | ADR-0001 | Change |
| C-02 | Firestore cache as store, 12-month window, 1,000-doc cap → Drift source of truth + outbox + staged sync | ADR-0002, R-01, AC-10.6 | Change |
| C-03 | `TransactionModel` single class, `type` income/expense only → sealed `Income`/`Expense`/`Transfer` + transfer fee | M2, M3, US-06 | Change |
| C-04 | Transaction carries its own currency; wallet has none (only `openingBalanceCurrency`) → wallet currency immutable, transaction currency = wallet currency | BR-02, I-03, I-23 | Change |
| C-05 | `date` as `DateTime` / ISO string with time → calendar date | M4, I-09 | Change |
| C-06 | Fixed `TransactionCategory` enum (also in rules) → `Category` entity, defaults + custom + system keys | US-13, I-15, I-22 | Change |
| C-07 | `title` (≤ 100 chars) → optional `note` | Domain glossary | Change (rename; keep 100-char limit unless spec says otherwise) |
| C-08 | Wallet `icon` and `isDefault` inside the model → appearance in `PreferenceStore`; no default wallet concept | M7, AC-03.7 | Change |
| C-09 | No wallet status → active/archived lifecycle, restore, delete only without transactions | US-04, I-14, I-27 | Change |
| C-10 | Opening balance optional and > 0 → required, ≥ 0, minor units in wallet currency | AC-03.1, AC-03.6, I-18 | Change |
| C-11 | Rates: `double`, latest only, `SharedPreferences`, per device → exact decimal, dated rows vs USD, synced per owner, `lastRefreshedOn` | ADR-0005, R-02b..R-05, I-21 | Change |
| C-12 | `convertMinorUnits` uses `double` → exact-decimal conversion (R-02b), half-up at display | NFR-07, BR-15 | Change |
| C-13 | AI parsing: `double` amount, unknown type → expense, date defaults to now, no future-date check, enum category match → draft with empty type, minor units, R-14..R-16 | BR-07, R-14..R-16, AC-07.4, AC-08.5 | Change |
| C-14 | Relock uses `elapsed > 30 s`; spec says 30 s or more locks | AC-02.3 | Change (`>=`) |
| C-15 | Sign-out keeps Firestore persistence (comment: "debt") → delete local database and owner secure-storage entries | AC-01.5, S4 | Change |
| C-16 | Rules without `get()`, categories hard-coded, opening balance > 0, delete always allowed → ADR-0003 rule set | ADR-0003 | Change (rewrite rules + emulator tests) |
| C-17 | Architecture test checks imports of `package:fin_track_ai/` and colors only → ADR-0001 boundary tests | ADR-0001 | Change |
| C-18 | No guard against editing tests during implementation → CI gate on `test/` changes after the contract commit | 02-spec Conventions, P2 T1 | Change |
| C-19 | AI proxy on Apps Script with shared secret in the app → Cloudflare Worker, token verified, limits, no shared secret | ADR-0004, S7 | Change |
| C-20 | Default wallet seeding (Cash, Bank Account, PayPal, Other) without currency → no seeding; after sign-up the owner creates wallets | AC-01.6 | Change (remove seeding) |
| C-21 | Insufficient balance: `check_sufficient_balance_usecase` exists; behavior not verified (block or warn) | BR-12, R-11 | Verify, then align to warn + confirm |
| C-22 | `AGENTS.md` ~70 lines, duplicated rules (test-expectation rule twice), outdated layout, Apps Script references | P2 backlog | Change in phase P2 (draft saved) |
| C-23 | Rate source: Frankfurter **v2** serves JOD; owner verified conversions against the market rate (2026-11-15) | ADR-0006 | Resolved: keep source JOD; storage still changes per C-11 |

---

## 4. Missing (not built)

| ID | Capability | Spec |
|---|---|---|
| M-01 | Transfers, cross-currency transfers, transfer fees | US-06 |
| M-02 | Custom categories, category deletion with move to Other | US-13 |
| M-03 | Monthly budgets with versions | US-12 |
| M-04 | Receipt entry (camera, image budget, Worker) | US-08 |
| M-05 | AI disclosure acknowledgment (MSG-08) | AC-07.1, BR-22 |
| M-06 | Needs attention list + MSG-09 banner | BR-24, AC-14.3 |
| M-07 | Historical-rate conversion in reports; conversion quality labels | AC-11.2, AC-10.4, AC-10.5 |
| M-08 | Period comparison and custom ranges | AC-11.3, AC-11.4, AC-11.7 |
| M-09 | Wallet archive/restore | US-04 |
| M-10 | Sign-up lands on wallet creation; system categories seeded | AC-01.6, AC-01.7 |
| M-11 | Message catalog MSG-01..14 in ARB | §3 of spec |

---

## 5. Remove

| ID | Item | Reason |
|---|---|---|
| R-01 | `FirestoreTransactionRepository` window, cap, `awaitWriteAck` timeout logic | Replaced by outbox (ADR-0002) |
| R-02 | `WalletMigrationService` seeding | C-20 |
| R-03 | Legacy `TransactionDraft` (double amount, required type) | C-13 |
| R-04 | Tests of removed behavior (window, cap, timeout, seeding, legacy decoding) | They test code that is deleted. Not a breach of test immutability: that rule covers AC tests of the current story. Each removal is listed in the PR of the story that deletes the code |
| R-05 | Apps Script proxy and `APP_SHARED_SECRET` | C-19 |
| R-06 | Existing Firestore collections (test data) | Owner decision: no migration |

---

## 6. Defer

| ID | Item | Reason |
|---|---|---|
| D-01 | Riverpod 2.6 → 3 | Not needed by any AC; record as ADR-0007 when stage 0 is done |
| D-02 | Local database encryption (S9) | Not in v1 |
| D-03 | App Check (S3) | Not on Spark budget |

---

## 7. Backlog (delivery order)

Each item = one story-sized branch, S03 loop: plan → contract → failing AC tests (approved commit) → implement → gate → independent review → small commit.

| Stage | Item | Covers | Depends on |
|---|---|---|---|
| 0 Foundation | Domain kernel: `Money`, `CurrencyCode`, `Clock`, exact decimal | C-01, C-12, K-01 | — |
| 0 | Drift schema v1 + `UnitOfWork` + outbox table | C-02 | kernel |
| 0 | Architecture tests (ADR-0001) + CI test-change gate | C-17, C-18 | — |
| 0 | Access rules v2 + emulator tests; delete test data | C-16, R-06 | — |
| 0 | Walking skeleton: **US-03 create wallet** end to end (UI → use case → Drift → outbox) | C-04, C-10, C-20 | all above |
| 1 Core money | US-13 categories (defaults, custom, delete) | C-06, M-02 | stage 0 |
| 1 | US-05 income/expense | C-03, C-05, C-07, C-21 | US-13 |
| 1 | US-06 transfers + fees | M-01 | US-05 |
| 1 | US-09 edit/delete | — | US-05, US-06 |
| 1 | Rates (ADR-0005 + ADR-0006) | C-11, M-07 | kernel |
| 1 | US-10 balances, net worth, display currency | — | rates |
| 1 | US-04 archive/restore/delete; US-03 appearance (AC-03.7) | C-08, C-09, M-09 | US-03 |
| 2 Sync stage 1 | Push + full restore; Needs attention; sign-out wipe | C-02, C-15, M-06 | stage 1 |
| 3 Assisted entry | Worker + `AiExtractor`; disclosure; US-07 voice; US-08 receipt | C-13, C-19, M-04, M-05, R-05 | stage 2 |
| 4 Insights & budgets | US-11, US-12 | M-03, M-07, M-08 | stage 1 |
| 5 Sync stage 2 | Delta pull, cursor, conflict ACs | ADR-0002 | stage 2 |
| 6 Release | NFR runs, network measurement, O-3 terms check, app lock C-14, MSG catalog | C-14, M-11 | all |

---

## 8. Owner decisions

| ID | Question | Recommendation |
|---|---|---|
| GQ-1 | Strangler approach (new domain + data behind the existing UI, story by story) | Approved 2026-11-15 |
| GQ-2 | Backlog order (walking skeleton = US-03) | Approved 2026-11-15 |
| GQ-3 | Spikes before stage 1 | Approved; C-23 resolved by owner test; C-21 spike remains |

## 9. Open items

| ID | Item |
|---|---|
| OI-1 | Files changed on 2026-11-14, after the freeze (2026-11-13), e.g. `wallet_edit_sheet`, `check_sufficient_balance_usecase`. Owner to confirm whether they were critical fixes (R7 exception); they are covered by C-08, C-09, C-21 either way |
