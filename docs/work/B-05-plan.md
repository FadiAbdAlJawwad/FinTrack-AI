# B-05 Gate and guards — plan v2

Status: approved 2026-11-17 · Owner: Fadi Abd AlJawwad · Base: `origin/main @ c47b263` · Supersedes v1 (4 slices, `tools/` Dart gate). Delete this file when B-05 merges.
Covers: C-17, C-25 (architecture tests), C-18 (test-change gate), C-24 part (format check, ARB parity).
Deferred until a real violation is observed: rest of C-24 (`tools/check.dart` runner, JSON test summary, repo-map freshness, AGENTS.md size limits).

## Facts (main, 2026-11-17)
| #   | Fact                                                                                                                                                       |
|-----|------------------------------------------------------------------------------------------------------------------------------------------------------------|
| F1  | `ci.yml`: `pull_request` + `push` to main; `pub get`, `flutter analyze`, `flutter test`; `actions/checkout@v4` depth 1                                     |
| F3  | `test/architecture/code_hygiene_test.dart` exists (relative imports, `Colors.white`, scan > 50 files)                                                      |
| F4  | ADR-0001: domain imports no `flutter`/`firebase_*`/`cloud_firestore`/`http`/`drift`; a feature never imports another feature; data never imports a feature |
| F5  | `lib/domain`, `lib/data`: `AGENTS.md` only, no Dart                                                                                                        |
| F6  | ~42 of 112 files in `lib/features` import another feature (approximate)                                                                                    |
| F7  | `lib/core/routing/main_shell_route.dart` imports feature screens (composition root; allowed)                                                               |
| F9  | ARB: placeholders come from message text (`intl_ar.arb` has no `@` metadata)                                                                               |
| F12 | No new packages; `analyzer` is not a dependency                                                                                                            |
| F13 | `dart format` changes 133 of 224 files (85 lib, 48 test); no generated file in the list                                                                    |

## Branch and commits
Branch `ci/b-05-gate`, one PR, squash merge.

| # | Commit                                               | Content                                                                                                                                       | Who           |
|---|------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|---------------|
| 1 | `docs(B-05): plan v2, git flow, progress`            | this file; Git flow section in `docs/dev/agent-routing.md`; `docs/progress.md`; delete `docs/dev/legacy-cleanup.md` and every reference to it | Owner         |
| 2 | `chore(B-05): remove desktop platform folders`       | `git rm -r linux macos windows` (targets: Android, iOS)                                                                                       | Owner         |
| 3 | `style(B-05): dart format`                           | `dart format lib test`; no logic change                                                                                                       | Owner         |
| 4 | `test(B-05): architecture boundaries and ARB parity` | rules below                                                                                                                                   | Agent         |
| 5 | `ci(B-05): format check and test-change gate`        | CI below + `docs/05-gap-analysis.md` §7 B-05 row                                                                                              | Agent + owner |

No contract commit: guard tests pass on day one (same rule as items that only remove or restructure code). Non-vacuity is proven by hand and recorded in the PR description: add one forbidden import locally, see the test fail, revert.

## Commit 4 — `test/architecture/boundaries_test.dart`
| Rule        | Check                                                                                                                                            |
|-------------|--------------------------------------------------------------------------------------------------------------------------------------------------|
| Domain      | No import of `package:flutter/`, `package:firebase_`, `package:cloud_firestore/`, `package:http/`, `package:drift/` in `lib/domain`              |
| Feature     | No `lib/features/<a>/…` file imports `lib/features/<b>/…` (a ≠ b), except baseline lines                                                         |
| Data        | No `lib/data` file imports `lib/features/`                                                                                                       |
| Legacy      | No import of a legacy path in `lib/domain`, `lib/data`, `lib/core`; legacy list is a constant in the test copied from `docs/repo-map.md` §Legacy |
| Parsing     | `import` and `export` lines; every URI of a conditional import; ignore `part of`; resolve relative URIs to `lib/…`; normalize `\` → `/`          |
| Non-vacuous | `lib/features` ≥ 50 files and `lib/core` ≥ 10 files scanned; `lib/domain`, `lib/data` must exist (0 Dart files allowed until B-01/B-02)          |

Baseline `test/architecture/cross_feature_baseline.txt`: one `from_file -> to_file` per line, sorted. New violation → fail. Baseline line with no matching import → fail (stale; the list only shrinks). A story that removes a cross-feature import deletes its line in its contract commit.

## Commit 4 — `test/l10n/arb_parity_test.dart`
| Rule         | Check                                                                                                                                       |
|--------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| Keys         | Same key set in `intl_en.arb` and `intl_ar.arb` (ignore `@`-keys and `@@locale`)                                                            |
| Placeholders | Same placeholder set per key; placeholder = first identifier of each top-level `{…}` in the message                                         |
| Plurals      | English message is a plural → Arabic has `zero`, `one`, `two`, `few`, `many`, `other` keywords (`=0`/`=1`/`=2` do not count)                |
| Fixtures     | Each rule also tested on small inline ARB maps (missing key, placeholder mismatch, missing Arabic category) so the checker itself is tested |

## Commit 5 — `.github/workflows/ci.yml`
- `actions/checkout@v4` with `fetch-depth: 0`.
- After `pub get`, before analyze:
```yaml
- name: Format
  run: dart format --output=none --set-exit-if-changed lib test
- name: Test-change gate (C-18)
  if: github.event_name == 'pull_request'
  run: |
    c=$(git log --format=%H --grep='^contract(' origin/${{ github.base_ref }}..HEAD | tail -1)
    if [ -z "$c" ]; then echo "notice: no contract commit"; exit 0; fi
    git diff --name-status --exit-code "$c" HEAD -- test/
```

## Known blind spots (accepted)
| ID   | Gap                                                                                       | Mitigation                                                                                       |
|------|-------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| BS-1 | Merging `main` into a story branch after the contract brings `test/` changes → gate fails | Branches are short; update with `git rebase main` before the contract, never merge main after it |
| BS-2 | Mis-typed contract subject → no contract → pass with notice                               | Notice visible in CI log; reviewer checks                                                        |
| BS-3 | Edit then revert a test after the contract → net zero → pass                              | Harmless by definition                                                                           |
| BS-4 | `integration_test/` not guarded                                                           | Folder absent; extend when added                                                                 |

## Done when
- `flutter analyze` clean; `flutter test` green incl. new tests; format check passes.
- Non-vacuity proof in the PR description (one rule per test file).
- PR CI green; squash merged; Close block run; `docs/progress.md` emptied in the next story's first commit.
