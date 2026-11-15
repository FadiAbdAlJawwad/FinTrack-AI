# B-00-F1 plan — unsupported saved locale resolves to en at the source

Status: APPROVED (owner, 2026-11-15: option C, one test) · Backlog: 05 §7 B-00 (post-merge review finding F-1, Important) · Branch: `fix/b-00-f1` · Merge: merge commit (`--no-ff`, no squash)
Not a 02-spec story: no US/AC IDs. Contract: one failing test, then the fix.

## 1. Research

### 1.1 Facts (main @ 8286ee0, text search)
| # | Fact                                                                                                                             | Evidence                                              |
|---|----------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------|
| 1 | `LocaleNotifier.build()` returns `Locale(savedString)` for any saved string, else `Locale('en')`                                 | `lib/core/providers/locale_provider.dart:13-16`       |
| 2 | `lookupAppLocalizations` supports `ar`, `en` only; anything else throws `FlutterError`                                           | `lib/l10n/app_localizations.dart` (generated)         |
| 3 | `biometricServiceProvider` calls `lookupAppLocalizations(ref.watch(localeProvider))`                                             | `lib/core/services/biometric_service.dart:6-11`       |
| 4 | `MaterialApp`: `supportedLocales` = `[ar, en]`, no `localeResolutionCallback` → an unsupported locale resolves to `ar` in the UI | `lib/main.dart:79,86`; `app_localizations.dart:96-98` |
| 5 | The only writer is the language selector (`en`, `ar`)                                                                            | `language_selector_dialog.dart:12-13,31`              |
| 6 | The generated delegate exposes `isSupported(Locale)`                                                                             | `app_localizations.dart:1222`                         |
| 7 | Prefs test pattern: `SharedPreferences.setMockInitialValues` + `ProviderContainer` with `sharedPrefsProvider` override           | `test/features/auth/auth_controller_test.dart:35-47`  |

### 1.2 Decision (owner)
Option C: validate in `LocaleNotifier.build()`. One source for every locale reader (`MaterialApp`, biometric reason, later screens). Behavior changes only for an unsupported saved value; the existing `en` default for "nothing saved" is extended to "saved value unsupported". Options A (guard in the biometric provider) and B (catch `FlutterError`) rejected.

### 1.3 Constraints
- AGENTS.md: no swallowed errors; contract test read-only during implementation; no git state change by the agent.
- Out of scope: `setLocale` input validation (only writer offers `ar`/`en`), C-27.

## 2. Plan

### 2.1 Steps
| # | Phase             | Content                                                                                                                                                                                                                                                 | Who                            |
|---|-------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------|
| 0 | Branch            | `git switch -c fix/b-00-f1 main`                                                                                                                                                                                                                        | Owner                          |
| 1 | Contract          | New `test/core/providers/locale_provider_test.dart`, one test `F-1 unsupported saved locale resolves to en`. Fails on main (assertion 1 gets `Locale('fr')`). No production change. Commit `contract(B-00-F1): unsupported saved locale resolves to en` | Agent → owner commits          |
| 2 | Implementation    | `locale_provider.dart`: `AppLocalizations.delegate.isSupported(locale) ? locale : const Locale('en')`                                                                                                                                                   | Agent                          |
| 3 | Gate              | `flutter analyze` 0 issues; `flutter test` **522** passed (521 + 1)                                                                                                                                                                                     | Agent: summary + failures only |
| 4 | Test-change check | `git diff <contract-sha> -- test/` empty                                                                                                                                                                                                                | Owner                          |
| 5 | Review            | Reviewer template, `git diff main...fix/b-00-f1`, model other than the executor                                                                                                                                                                         | Reviewer                       |
| 6 | Merge             | Merge commit                                                                                                                                                                                                                                            | Owner                          |

### 2.2 Files
- Contract: new `test/core/providers/locale_provider_test.dart`.
- Implementation, may edit: `lib/core/providers/locale_provider.dart` only.
- Never: `lib/core/services/biometric_service.dart`, `lib/main.dart`, `lib/l10n/**`, `pubspec.*`, `AGENTS.md`, `docs/**`, secret or config files, generated files; every file under `test/` after step 1.

### 2.3 Test map
| Test                                        | Assertions                                                                                                                                                                                         | Fails today because        |
|---------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------|
| F-1 unsupported saved locale resolves to en | prefs `{'locale_code': 'fr'}` → (1) `container.read(localeProvider) == const Locale('en')`; (2) `container.read(biometricServiceProvider).localizedReason == AppLocalizationsEn().biometricReason` | (1) returns `Locale('fr')` |

Exemplar: `test/features/auth/auth_controller_test.dart:35-47`. Approved packages: none.

### 2.4 Size
1 new test file (~30 lines); 1 production file, ~+3/−1.
