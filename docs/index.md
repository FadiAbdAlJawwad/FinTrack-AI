# Docs index

Open only the file and section the task needs. IDs (`US-`, `AC-`, `BR-`, `NFR-`, `I-`, `R-`, `MSG-`) are stable anchors; prompts cite them.

| File | Holds | Canonical for |
|---|---|---|
| `01-brief.md` | Problem, users, product rules, success criteria, not now | Product scope |
| `02-spec.md` | Stories US-01..14, acceptance criteria, BR-01..29, NFR-01..10, messages MSG-01..14 | **Behavior** (what the app does) |
| `03-domain.md` | Glossary, ERD, invariants I-01..27, rules R-01..17, lifecycles | **Names and invariants** (code names come from the glossary) |
| `04-architecture.md` | Quality attributes, C4, ports, Firestore layout, security model | Structure overview (links to ADRs) |
| `adr/0001..0008` | Decisions with alternatives and consequences | **Each decision** (never edited after acceptance; superseded by a new ADR) |
| `05-gap-analysis.md` | Code vs docs: keep / change / missing / remove; backlog | Delivery order |
| `progress.md` | Current stage, current story, next | Session state |
| `repo-map.md` | Folders and what lives where | File locations |
| `dev/agent-routing.md` | Which agent and model for which task; executor prompt template | Agent workflow |
| `legacy/production-notes.md` | Old implementation notes | Nothing (delete after stage 2) |

If two files disagree: spec wins on behavior, domain wins on names and invariants, ADR wins on structure. Report the conflict instead of choosing.
