# FinTrack AI

A bilingual (Arabic / English) personal finance tracker built with Flutter on Firebase Spark.

## Documentation

- [docs/index.md](docs/index.md) — Start here: index to specifications, domain rules, and architecture.
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
