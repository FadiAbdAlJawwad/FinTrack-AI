# Agent routing and executor prompt template

Status: v1.1 · 2026-11-15 (S03/S04 alignment: story flow, sessions, reviewer template) · Owner: Fadi Abd AlJawwad
Source: FinTrack project Instructions (Oct–Nov 2026 trials), moved here so one file holds it. Update after every calibration task.

## Routing

| Situation                                                             | Tool → model                                                  | Evidence / note                                                                                                                                          |
|-----------------------------------------------------------------------|---------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Default**: feature, refactor, tests, wiring layers, diagnosis       | Android Studio Gemini agent → flash (new session)             | 6 of 6 tasks: clean analyze, tests passing, respected git ban. Weakness: sometimes reports a write that did not apply (3 times) → verification mandatory |
| Flash failed twice on the same task, or the task spans several layers | Android Studio Gemini agent → pro                             | Not yet tested: first such task is a calibration run; record the result here                                                                             |
| Security or architecture audit, pre-merge review, unclear-cause bug   | agy → `claude-sonnet-4-6`                                     | Most disciplined; costly (≈ 11% of weekly Claude quota per medium task)                                                                                  |
| Android Studio quota exhausted or environment broken                  | agy → `gemini-3.8-flash-high`                                 | —                                                                                                                                                        |
| Small tasks: docs, formatting, boilerplate                            | agy → `gemini-3.8-flash-low`                                  | —                                                                                                                                                        |
| Second opinion or all Gemini quotas exhausted                         | OpenCode → MiMo-V2.6-Flash Free                               | May train on data: no sensitive data; stability unproven                                                                                                 |
| Code outside the repo (Worker deploy config, legacy Apps Script)      | No agent; owner applies text prepared in the FinTrack project | —                                                                                                                                                        |

Removed: Claude Code cloud sessions (credit expired 2026-11-05).
Forbidden: `gemini-3.1-pro` (hid an error by editing a test), Nemotron Free (breaks on multi-tool tasks), `gpt-oss`. No secrets or sensitive data in any prompt; no free model for sensitive data.
Every prompt states in one line why this model was chosen and the fallback when quota runs out.

## Story flow (S03 loop + S04 phased sessions)

Each phase runs in a **new session** that reads only the previous phase's file, never the previous chat.

| Phase            | Input                                                          | Output                                                                                                    | Who approves                                                    |
|------------------|----------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------|
| 1 Research       | Story or backlog ID, `docs/index.md`, `docs/repo-map.md`       | Files involved, constraints (I-xx, R-xx, ADR), questions — top of `docs/work/<US-xx or B-nn>-plan.md`     | —                                                               |
| 2 Plan           | The research section only                                      | Steps, file list, AC → test-file map, exemplar to follow, diff estimate (readable in ~10 min) — same file | Owner (reviewing the plan matters more than reviewing the code) |
| 3 Contract       | Approved plan                                                  | Types, signatures, typed failures, failing AC tests; commit `contract(US-xx): …`                          | Owner commits                                                   |
| 4 Implementation | Approved plan + contract commit                                | Minimal code, gate green, `docs/progress.md` updated                                                      | —                                                               |
| 5 Review         | AC list + `AGENTS.md` + diff (`git --no-pager diff main`) only | Findings table (reviewer template)                                                                        | Owner decides and merges                                        |

Too big if: more than one module, schema + logic + UI together, more than one story, or ACs that do not fit in five lines → split, or clarify the spec first.

Start a new session when: the phase changes; the agent repeats an error you already corrected; context is about half full; the session has carried failed attempts for a long time.

What a prompt carries, stable first: tool rules → `AGENTS.md` (auto-loaded) → index/map pointers → story and ACs → progress, recent error, the ask. Never put a date, a random ID, or a pasted log at the top.

After every review: a finding seen twice becomes a line in `AGENTS.md` or a folder `AGENTS.md`; if a lint rule or test can catch it, add that instead and delete the line. Record tool quirks in `docs/lessons.md`. After any change to agent context, run `evals/tasks.md`.

## Git flow — one story = one branch = one PR = one squash commit on main

| ID  | Rule                                                                                                                                                                                                                                                                                                                                                                                     |
|-----|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| G-1 | A branch exists only for a backlog item (B-nn / US-xx) that adds behavior, a guard, or fixes a defect. Docs-only changes (progress.md, 05 §7 status, lessons, ADR wording) ride inside the current story's PR; never their own branch.                                                                                                                                                   |
| G-2 | Name: `<type>/<id>-<slug>`, type ∈ feat · fix · ci · refactor · chore.                                                                                                                                                                                                                                                                                                                   |
| G-3 | Local commits per story: `docs(<ID>): plan` → optional `retire(<ID>)` → `contract(<ID>)` (behavior stories only) → implementation. Fix-ups to an unpushed implementation commit: `git commit --amend --no-edit`, never a new "fix typo" commit. Never amend the contract commit. Update a branch with `git rebase main` before the contract commit only; never merge main into it after. |
| G-4 | Push once: gate green locally and every AC of the story met. Then open the PR. Later pushes only for review findings.                                                                                                                                                                                                                                                                    |
| G-5 | Merge = GitHub "Squash and merge" only. PR title `<type>(<ID>): <outcome>` becomes the single commit on main. Repo settings: merge commits off, rebase merging off, "Automatically delete head branches" on.                                                                                                                                                                             |
| G-6 | Close the branch in the same sitting as the merge (Close block). Done = `git branch` shows only `main`, `git status --short` empty.                                                                                                                                                                                                                                                      |
| G-7 | Hotfix (crash, data loss, security): `fix/<id>-<slug>` from main, plan file optional, push immediately.                                                                                                                                                                                                                                                                                  |
| G-8 | Every story prompt from the FinTrack project starts with the Open block and ends with the Close block, with concrete names (no placeholders).                                                                                                                                                                                                                                            |
| G-9 | No tags except releases `vX.Y.Z`. Contract evidence lives in the PR's commit list (kept after squash).                                                                                                                                                                                                                                                                                   |

Open block:
```powershell
git switch main
git pull --ff-only
git fetch --prune
git status --short
git switch -c <type>/<id>-<slug>
```
`git status --short` must print nothing before the last line.

Close block (after "Squash and merge" on GitHub):
```powershell
git switch main
git pull --ff-only
git fetch --prune
git branch -vv
git branch -D <type>/<id>-<slug>
git branch
```
Use `-D` only when `git branch -vv` showed `[origin/<branch>: gone]` and `git log -1 --oneline` shows the squash commit. Squash rewrites commits, so `-d` always refuses.

## Executor prompt template (S03 loop)

One story per branch. The contract commit message starts with `contract(US-xx):`; from stage 0 item B-05 "Gate and guards", CI fails if any file under `test/` changes after that commit on the branch; until then the owner checks `git diff <contract-commit> -- test/` before merging. Deleting tests of removed code (gap R-04) happens in a commit **before** the contract commit, never after it. Items that only remove or restructure code have no contract step: the gate stays green and the PR explains any change in the test count. Two prompts per story: **contract** (types + failing AC tests; owner approves and commits) then **implementation** (tests read-only).

```
Target: <tool> → <model> (new session) · Why: <one line> · Fallback: <tool → model>

Objective: <one sentence, one story or one sub-step>

Context (read only these):
- AGENTS.md, docs/progress.md
- docs/02-spec.md → <US-xx: AC-xx.1..AC-xx.n>
- docs/03-domain.md → <I-xx, R-xx>
- docs/adr/<nnnn> → <rule numbers>
- Plan: docs/work/<US-xx or B-nn>-plan.md (approved)
- Exemplar to follow: <path, or "none yet">
- Approved packages for this story: <list, or none>

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
4. Gate (`flutter analyze` + `flutter test`, later `dart run tools/check.dart`): summary line with counts and the failures only.
5. `git --no-pager diff main --stat` (read-only).
6. AC IDs satisfied and not satisfied.
7. Update docs/progress.md: Done, Decisions, Next, Open questions (no command output).
```

## Reviewer prompt template (independent review)

Use a different session, preferably a different model from the executor's (routing table: pre-merge review). Give it the spec excerpt, `AGENTS.md`, and the diff, never the writing chat.

```
Target: <tool> → <model> (new session) · Why: independent of the executor (<executor model>)

You are a skeptical code reviewer who did not take part in writing this change.
Inputs: <US-xx and AC-xx.1..n text>, AGENTS.md, `git diff main` output.

Read in this order and stop to report at the first Blocker:
1. Stats: files and lines; anything outside the plan's file list?
2. Tests: one test per AC, named by ID; does each fail if the behavior breaks? Any existing test changed after the contract commit?
3. Contracts and types: match the spec? Every expected failure typed?
4. Domain: invariants I-xx and rules R-xx respected? Names from the glossary (03-domain)?
5. Adapters: Drift (parameterized SQL, UnitOfWork + outbox), Firestore, HTTP: where can it fail, and what does the user see then?
6. Config and dependencies: new package? changed config? secret or endpoint in code?

Checklist: correctness incl. unhappy paths · scope · design (ADR-0001 boundaries, no legacy imports) · readability · errors (no swallowed catch, no toString to users) · security · tests (not tautological, not mocking everything) · dependencies · visible performance (query in a loop, whole table in memory) · i18n (ARB only, six Arabic plural forms, directional layout, BR-30..BR-32 formatting).

Output one table: file:line · finding · severity (Blocker = no merge · Important = fix in this change · Suggestion = optional).
Say "no issue" explicitly for any checklist item with none. No praise. Do not rewrite the code.
```
