# Docs index

Open only the file and section the task needs. IDs (`US-`, `AC-`, `BR-`, `NFR-`, `I-`, `R-`, `MSG-`) are stable anchors; search for the ID instead of reading the whole file.

| File                   | Read it when                                                                             |
|------------------------|------------------------------------------------------------------------------------------|
| `progress.md`          | You start or finish a session (read first, update last)                                  |
| `02-spec.md`           | You implement or change a story: its ACs, BRs, NFRs, MSG-IDs                             |
| `03-domain.md`         | You name anything, or touch invariants, rules, or lifecycles                             |
| `04-architecture.md`   | You add a module, a port, or a Firestore path, or cross a layer                          |
| `adr/0001..0008`       | You want to change structure, storage, sync, rules, or a dependency                      |
| `05-gap-analysis.md`   | You need to know what legacy code is kept, changed, or removed, or which item comes next |
| `repo-map.md`          | You need to find where something lives, or whether a path is legacy                      |
| `lessons.md`           | A tool, command, or agent behaves unexpectedly; before writing a new rule                |
| `dev/agent-routing.md` | You choose an agent or model, or write an executor or reviewer prompt                    |
| `work/US-xx-plan.md`   | You implement a story whose plan the owner approved                                      |
| `../evals/tasks.md`    | You change AGENTS.md, a folder AGENTS.md, or this index                                  |
| `01-brief.md`          | A product-scope question the spec does not answer                                        |

If two files disagree: spec wins on behavior, domain wins on names and invariants, ADR wins on structure. Report the conflict instead of choosing.
