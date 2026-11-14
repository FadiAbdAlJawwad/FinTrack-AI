> **Status: Legacy — describes the implementation as of 2026-11. Not a specification.**
> Superseded by `docs/01-brief.md` where they conflict (12-month balance window, silent rollback, lock fallback).
> Input for `05-gap-analysis.md`. Delete after its content is migrated.


# Production notes

Concise notes on the Firestore read-cost and security design, written for the
Spark (free) plan. Read alongside `firestore.rules` and the Data layer.

## Why the transactions listener is windowed

`FirestoreTransactionRepository` streams only transactions whose `date` is on
or after the first day of the month `windowMonths - 1` months ago (default:
the current month plus the 11 before it), newest first, capped at
`maxDocuments` (default 1000).

What that means for users:

- Dashboard balance, income, expense and the transactions list cover **only
  the window**. Older transactions still exist in Firestore but are not
  loaded, so they are excluded from totals and filters.
- If a user has more than `maxDocuments` transactions inside the window, the
  oldest ones in the window are dropped as well (a debug log reports the cap).
- The window is fixed when the listener is created; it moves forward the next
  time the listener is rebuilt (for example on app restart or sign-in).

Totals stay client-side on purpose: they work offline from the local cache
and need no extra documents or server logic.

## How I would do it in production

| Option | How | Why not here |
|---|---|---|
| Summary document per user and currency | Each write also increments `income`/`expense` counters in `users/{uid}/summaries/{currency}` (same batch or transaction); a "recompute" action rebuilds it from the transactions. | Increments in a client batch can drift (partial failures, edits of old rows, deleted rows, rule bypass bugs) and need a recompute path. Offline, transactions spanning two docs complicate conflict handling. More moving parts than the window for a portfolio app. |
| Server-side aggregation | `count()`/`sum()` aggregation queries over the full collection, cached per screen. | Aggregations do not work offline and do not stream; they are billed per index entries scanned, and the UI would need a second code path for live updates. |
| Server logic | Cloud Functions maintaining summaries. | Requires the Blaze plan (forbidden by the project constraints). |

A production system would most likely combine a summary document (for the
headline balance over all time) with the windowed listener (for the list).

## Read-cost notes

- A listener costs one read per document in its initial result, then one read
  per added/changed/removed document. The window and cap bound the initial
  cost to at most `maxDocuments` reads per listener start.
- If a listener has been disconnected for more than 30 minutes (for example
  the app was closed), re-attaching it is billed like a new query: assume a
  full re-read of the window on cold start.
- Wallet reads are limited to 50 documents. Default-wallet seeding reads the
  wallet list once per user per app process and writes at most four documents.
- The old wallet migration read the **entire** transactions collection on the
  first launch of every new device session; that backfill is removed.
- Security rules use no `get()`/`exists()`, so rule evaluation costs no reads.

## Late server rejection after the write timeout

Transaction writes wait at most `writeTimeout` (3 s) for the server
acknowledgement, then report success because the write is queued in the local
cache. If the server later rejects it (for example the rules deny an invalid
document, or permissions changed), the SDK silently rolls the local change
back: the transaction disappears from the list without an error message.
The schema in `firestore.rules` mirrors the client validation, so this should
only happen for clients with bugs or tampered data.

## Deployment order

1. Deploy indexes first, if `../../firestore.indexes.json` changed
   (`firebase deploy --only firestore:indexes`) and wait until they are built.
   This change needs none: the transactions query is a range plus `orderBy` on
   the single field `date`, served by the automatic single-field index.
2. Deploy rules (`firebase deploy --only firestore:rules`) **before** shipping
   a client that relies on them, and before testing on a device.
3. Ship the client.

Run `../../tools/rules-test` against the emulator before every rules deploy.

## Known open items

- Wallet and base-currency writes (including wallet seeding in `WalletMigrationService` via `FirestoreWalletRepository.upsertWallet`) now use `awaitWriteAck` with a 3 s timeout, preventing offline hangs.
- The listener window does not advance while the app stays open across a
  month boundary.
- Transactions older than the window are invisible in the app; there is no
  "load older" action yet.
- `WalletRepository.addWallet` still creates auto-id wallets; nothing in the
  UI calls it today.

## Security model and accepted risks

| ID | Topic | Status | Production approach |
|---|---|---|---|
| S1 | Firestore rules | Schema validation for users, wallets, transactions; negative rules tests in `../../tools/rules-test` run on the emulator (56 tests); not yet in CI | Run rules tests in CI pipeline. |
| S2 | Biometric lock | In-session lock with 30 s background timeout (`AppLockNotifier`), unlocked after sign-in | Enforce on device unlock & app restart. |
| S3 | App Check not enabled | Spark plan, no Play Integrity attestation here | Enable App Check (Play Integrity / App Attest) and enforce on Firestore. |
| S4 | Offline persistence | Offline persistence is not cleared on sign-out | Clear persistence via `clearPersistence` on shared devices. |
| S5 | Android backup | Disabled (`allowBackup=false`) | Keep `allowBackup=false` or configure explicit backup rules. |
| S6 | Logs | Debug-only, no uid, tokens or secrets | Retain debug-only logging with strict sanitization. |
| S7 | Apps Script proxy | `APP_SHARED_SECRET` is embedded in the client (extractable); real protection is Firebase ID token verified via Identity Toolkit `accounts:lookup` plus per-uid rate limit (20 requests per 6 h, `CacheService`, best-effort) | Cloud Functions/Cloud Run with Admin SDK token verification and App Check. |
| S8 | Firebase API keys | Firebase API keys in `firebase_options.dart` are client identifiers, restricted by rules, not secrets | Restrict API keys by package name and SHA-1 fingerprint in Google Cloud Console. |

### Local setup and secrets

`../../config/dev.local.json` (git-ignored) supplies `APPS_SCRIPT_PROXY_URL` and `APP_SHARED_SECRET` via `--dart-define-from-file`; `config/dev.example.json` is the template.
