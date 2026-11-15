# Lessons — long-term memory for agents and the owner

Each entry: what we learned, when, who decided, and how to check it is still true.
At the end of every story: delete entries whose check fails; move entries that became permanent rules into AGENTS.md or a gate, and delete them here. A stale lesson is worse than none.

| Date       | Lesson                                                                                                                                                              | Source                | Still true if                                                                          |
|------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------|----------------------------------------------------------------------------------------|
| 2026-11    | Android Studio Gemini (flash) sometimes reports a file write that did not apply (3 times). Verify every claimed change with `git status --porcelain` and `git diff` | Owner trials          | The executor prompt's expected outcome still asks for `git status --porcelain`         |
| 2026-11    | On Windows PowerShell 5.1, editing files through shell commands corrupts encoding. Agents edit files only with file-edit tools                                      | Owner trials          | The dev machine still runs PowerShell 5.1 (`$PSVersionTable.PSVersion`)                |
| 2026-11-15 | `Select-String` alone is not recursive. Use `Get-ChildItem -Recurse lib -Filter *.dart \| Select-String '<pattern>'`                                                | Legacy cleanup review | Same shell                                                                             |
| 2026-11    | `find_usages` can return nothing for symbols that exist. Fall back to a text search and say so                                                                      | Owner trials          | Still observed in the current Android Studio version                                   |
| 2026-11-15 | The legacy add-transaction sheet blocks on insufficient balance (SnackBar + return); the spec wants warn + confirm (AC-05.6)                                        | Spike C-21            | `add_transaction_bottom_sheet.dart` still exists (delete this entry when US-05 merges) |
