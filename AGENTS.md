# AGENTS.md — FinTrack AI

Portfolio-grade Flutter finance tracker. Quality metric = architectural clarity, explainable in a job interview.

## Stack
- Flutter + Dart, Clean Architecture, **feature-first**.
- State: Riverpod (`StreamNotifier`, `AsyncNotifier`) + `flutter_hooks` (`HookConsumerWidget`).
- Models: Freezed. Every Freezed class MUST keep the private constructor `const ClassName._();`.
- Routing: GoRouter, isolated in its own layer.
- Backend: Firebase **Spark plan only**.

## Layout
- `lib/core/{constant,error,extension,providers,routing,services,theme,widgets}/`
- `lib/features/<feature>/{domain,data,presentation}/` — features: `auth`, `currency`, `dashboard`, `transactions`, `wallets` (`dashboard` has `presentation/` only).
- `lib/l10n/`, `lib/generated/`

## Dependency rules (hard)
- Domain → nothing. **No `package:flutter/*` imports in domain**, no Firebase imports. Allowed third-party packages in Domain: `freezed_annotation`, `json_annotation` only.
- Data → Domain only. Presentation → Domain (+ DI wiring).
- Firestore types (`DocumentSnapshot`, `Timestamp`) never leave the Data layer; map to domain entities.
- Domain models carry no JSON. Firestore serialization lives in Data-layer DTOs.

## Riverpod rules
- Riverpod is 2.6.1 and has no `ref.mounted`. After an await inside a Notifier, check a `_disposed` flag (set in `ref.onDispose`) before touching `state` or `ref`. Code that does nothing after an await needs no flag. Never access provider internals through `dynamic`.
- Real-time Firestore data → `StreamNotifier`. No `setState`, no `StatefulWidget` for business state.
- Firestore writes rely on the SDK's local cache for immediate UI updates: do not add manual optimistic state to StreamNotifiers. Repositories translate SDK errors into typed exceptions; controllers never wrap errors into strings.

## UI rules
- **Reuse before create:** search `lib/core/widgets/` before creating any widget. If a match exists, extend it.
- No hardcoded `Color(0xFF...)` and no literal spacing or `EdgeInsets` values inside widgets. Use `Theme.of(context)`, `ColorManager` (`lib/core/constant`), and the `app_sizes` and `text_style_extension` extensions (`lib/core/extension`). Literal values are allowed only inside those definition files. The app supports dark mode: never hardcode a color that breaks in the dark theme.
- Network images: always set `cacheWidth` / `cacheHeight`.

## Firebase Spark constraints
- Forbidden: Cloud Functions, Cloud Storage, Firebase AI Logic, anything requiring Blaze.
- Substitutes: file storage → Google Drive API; server logic → Google Apps Script HTTP endpoint.
- Daily quota: 50k reads / 20k writes / 20k deletes. Avoid unbounded listeners; always `limit()` queries; no N+1 reads.

## Security
- Secrets are injected only through `--dart-define` or `--dart-define-from-file`. The local `.env` is gitignored: never create, read, print, or edit any `.env*` file except `.env.example`, which is tracked, holds key names only (no values), and may be edited. Never write real values into any tracked file.
- Never read, print, or modify: `google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart` secrets, any keystore, any file containing API keys or the Apps Script URL.

## Workflow (mandatory loop)
1. Plan first: list files to touch, then wait for approval if >5 files or any Domain contract change. In an unattended session (for example a cloud session) never wait for approval: if the task exceeds the files or Domain contracts named in the prompt, stop and report instead of asking.
2. Use the Dart MCP server when it is available; otherwise use the CLI, for analysis, symbol lookup, tests, pub.
3. After Freezed/Riverpod-generator edits: `dart run build_runner build --delete-conflicting-outputs`.
4. Finish only when `flutter analyze` reports zero issues and `flutter test` passes.

## Forbidden without explicit approval
- Adding/removing/upgrading packages in `pubspec.yaml`.
- Editing files outside the scope stated in the task prompt.
- `git push` to any branch other than the current cloud session branch, `firebase deploy`, deleting files.

## Git
- Local agents (agy, OpenCode): run no git command that changes state (commit, restore, checkout, reset, push).
- Cloud sessions: may commit and push to the session branch and open a PR; never merge and never push to main.
- Never use `git update-index` (`--assume-unchanged`, `--skip-worktree`): it hides defects from clean-clone verification.

## Quality
- Never edit a test expectation to make a test pass: report the failing test with the exact error.
- Never sum income and expense into one number (for example a per-category total): separate by `TransactionType`.
- Money is stored as `int` minor units plus the original currency. Never use `double` for stored or summed amounts; convert to the app currency only at display time.

## Output
- Summary: files changed + why, analyzer result, test result, open risks.
- ممنوع كتابة أو حذف أي ملف خارج مجلد المشروع، وممنوع إنهاء عمليات النظام. أي «نجاح» لـflutter analyze أو flutter test يجب أن يرفق مخرجه الفعلي؛ وإن تعذّر تشغيله فيُكتب «NOT RUN» مع السبب.