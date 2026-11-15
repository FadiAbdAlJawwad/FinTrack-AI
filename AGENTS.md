# AGENTS.md — FinTrack-AI

Docs index: docs/index.md (open only what the task needs) · Repo map: docs/repo-map.md · Lessons: docs/lessons.md
Progress of the current story: docs/progress.md (read first, update last)

## Commands
- Gate: `flutter analyze` (0 issues) and `flutter test` (all pass) before you finish; becomes `dart run tools/check.dart` when it exists. Report the summary line and failures only, never the full log; write NOT RUN + reason if not run.
- Codegen: the owner runs `build_runner`. Never edit `*.freezed.dart` or `*.g.dart`.
- Rules tests: `tools/rules-test` against the emulator after any `firestore.rules` change.

## Rules not obvious from the code
- `features → domain ← data`. A feature never imports another feature. `lib/domain` imports no Flutter, Firebase, HTTP, or Drift (ADR-0001). New code never imports legacy paths (docs/repo-map.md).
- Every write goes through `UnitOfWork`: record + outbox row in one local transaction (ADR-0002).
- Money = `int` minor units + currency. Rates = `int` micros (ADR-0007). Never `double` for stored or summed values.
- Never swallow an error: return a typed failure or rethrow. Never show `error.toString()` to the user; map typed failures to MSG-IDs, anything unexpected to MSG-16.
- Tests of the current story are read-only during implementation. If a test looks wrong: stop and report its AC ID. Never change an expectation to make it pass.
- User-visible text only in ARB files (ar, en). Numbers and dates only through the `lib/core` formatter (BR-30..BR-32).
- Firebase Spark only: no Cloud Functions, Cloud Storage, or anything that needs Blaze.

## Never without the owner's approval
- Add or upgrade a dependency (the story prompt lists approved ones) · run a git command that changes state · edit an accepted ADR (write a new one) · touch files outside the task's list.
- Never read, print, or edit secret or config files: `.env*` (except `.env.example`), `google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`, keystores, files holding API keys or endpoints. Never write a secret into any file.
