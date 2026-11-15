# AGENTS.md — FinTrack-AI

Docs index: docs/index.md (open only what the task needs) · Repo map: docs/repo-map.md
Progress: docs/progress.md (read first, update last)

## Commands
- Gate: `flutter analyze` (0 issues) and `flutter test` (all pass) before you finish. Paste the real output, or write NOT RUN + reason.
- Codegen: the owner runs `build_runner`. Never edit `*.freezed.dart` or `*.g.dart`.
- Rules tests: `tools/rules-test` against the emulator after any `firestore.rules` change.

## Rules not obvious from the code
- `features → domain ← data`. A feature never imports another feature. `lib/domain` imports no Flutter, Firebase, HTTP, or Drift (ADR-0001).
- Every write goes through `UnitOfWork`: record + outbox row in one local transaction (ADR-0002).
- Money = `int` minor units + currency. Rates = exact decimals. Never `double` for stored or summed values.
- Tests of the current story are read-only during implementation. If a test looks wrong: stop and report its AC ID. Never change an expectation to make it pass.
- User-visible text only in ARB files (ar, en). User messages by MSG-ID (02-spec §3).
- Firebase Spark only: no Cloud Functions, Cloud Storage, or anything that needs Blaze.

## Never without the owner's approval
- Add or upgrade a dependency · run a git command that changes state · write a secret into any file · edit an accepted ADR (write a new one) · touch files outside the task's list.
