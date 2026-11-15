# Agent routing and executor prompt template

Status: v1 · 2026-11-15 · Owner: Fadi Abd AlJawwad
Source: FinTrack project Instructions (Oct–Nov 2026 trials), moved here so one file holds it. Update after every calibration task.

## Routing

| Situation | Tool → model | Evidence / note |
|---|---|---|
| **Default**: feature, refactor, tests, wiring layers, diagnosis | Android Studio Gemini agent → flash (new session) | 6 of 6 tasks: clean analyze, tests passing, respected git ban. Weakness: sometimes reports a write that did not apply (3 times) → verification mandatory |
| Flash failed twice on the same task, or the task spans several layers | Android Studio Gemini agent → pro | Not yet tested: first such task is a calibration run; record the result here |
| Security or architecture audit, pre-merge review, unclear-cause bug | agy → `claude-sonnet-4-6` | Most disciplined; costly (≈ 11% of weekly Claude quota per medium task) |
| Android Studio quota exhausted or environment broken | agy → `gemini-3.8-flash-high` | — |
| Small tasks: docs, formatting, boilerplate | agy → `gemini-3.8-flash-low` | — |
| Second opinion or all Gemini quotas exhausted | OpenCode → MiMo-V2.6-Flash Free | May train on data: no sensitive data; stability unproven |
| Code outside the repo (Worker deploy config, legacy Apps Script) | No agent; owner applies text prepared in the FinTrack project | — |

Removed: Claude Code cloud sessions (credit expired 2026-11-05).
Forbidden: `gemini-3.1-pro` (hid an error by editing a test), Nemotron Free (breaks on multi-tool tasks), `gpt-oss`. No secrets or sensitive data in any prompt; no free model for sensitive data.
Every prompt states in one line why this model was chosen and the fallback when quota runs out.

## Executor prompt template (S03 loop)

One story per branch. Two prompts per story: **contract** (types + failing AC tests; owner approves and commits) then **implementation** (tests read-only).

```
Target: <tool> → <model> (new session) · Why: <one line> · Fallback: <tool → model>

Objective: <one sentence, one story or one sub-step>

Context (read only these):
- AGENTS.md, docs/progress.md
- docs/02-spec.md → <US-xx: AC-xx.1..AC-xx.n>
- docs/03-domain.md → <I-xx, R-xx>
- docs/adr/<nnnn> → <rule numbers>

Boundaries:
- May edit: <explicit file list>
- Read-only: <approved test files of this story> (implementation step)
- Never: lib/main.dart (unless listed), pubspec.*, .gitignore, AGENTS.md, secrets, *.freezed.dart, *.g.dart

Tool rules:
- No git command that changes state (commit, add, restore, checkout, reset, stash). Read-only git is fine.
- No `task` tool for writing tests; edit files directly.
- No file edits through shell commands (PowerShell 5.1 corrupts encoding); use file-edit tools only.
- No full rewrite of an existing file with write_file; local edits only.
- No build_runner.
- If find_usages returns nothing, use grep and say so.

Ambiguity: state every assumption in the summary. If a test fails, report it with the exact error; never change its expectation. If a file outside the list is needed: stop and report.

Expected outcome:
1. Files changed + why; `git status --porcelain` output at the end.
2. Leftover check after any rename or replacement (text search for the old name).
3. Tool actually used for each search; every assumption.
4. `flutter analyze` and `flutter test` (whole project) with counts and real output.
5. AC IDs satisfied and not satisfied.
6. Update docs/progress.md (one line).
```
