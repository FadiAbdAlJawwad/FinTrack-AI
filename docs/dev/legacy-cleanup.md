# Legacy cleanup — backlog item B-00

Status: v1 · 2026-11-15 · Owner: Fadi Abd AlJawwad
Scope: only code that existed before the docs chain (base `origin/main @ a100ef4`, gate green: 519 tests). Work that the backlog will rebuild (B-01..B-19) is out of scope. Delete this file when B-00 is done.

## Owner decisions
| ID | Decision |
|---|---|
| D-1 | Commit `2f12ab7` (after the code freeze) stays; replaced later by C-08, C-09, C-10, C-21 |
| D-2 | Remove the biometric login button, `unlockWithBiometrics`, `isBiometricAvailableProvider` (no AC; always fails on the login screen) |
| D-3 | No global spacing-token cleanup; per story |
| D-4 | Short, accurate README linking to `docs/` |
| D-5 | Keep `.vscode/launch.json`; add `!.vscode/launch.json` to `.gitignore` |
| D-7 | Accepted ADR dates are not edited (gap OI-2) |
| D-8 | Unused packages: deferred |
| D-9 | rules-test step in CI belongs to B-06 "Access rules v2" |

## Tasks
| Group | Tasks | Who | Contract step |
|---|---|---|---|
| G0 | Align local `main` to `origin/main` (backup branch first; only when `git status` is clean and `git diff origin/main main` is empty); move `Claude outputs/` out of the repo | Owner | — |
| G1 | #6 biometric reason text from ARB · #7 no `error.toString()` to users (MSG-16 via the existing `unknownError` key) · #8 ColorManager colors instead of literal colors · #9 reuse `skeletonColors` · #10 `AppRoutes` constants instead of route literals | Agent, one branch | Only for #7 (new tests); the rest is refactor |
| G2 | #11 owner runs `git rm --cached CLEANUP_REPORT.md` · #12 remove the unused ARB key and enum value · #13 remove `.env.example` · D-2 | Agent + owner | None (removal). Delete only the tests of removed functions, in a commit before any other change (gap R-04) |
| G3 | D-4 README · D-5 `.gitignore` line | Agent or owner | None |

Out of scope, recorded: C-27 swallowed error in app-lock code (fixed when the `AppLock` adapter is built).
Plan files: `docs/work/B-00-G1-plan.md`, `B-00-G2-plan.md`.
