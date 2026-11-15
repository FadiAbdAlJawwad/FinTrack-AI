# lib/domain — rules

- Pure Dart only: no `package:flutter`, `firebase_*`, `cloud_firestore`, `http`, `drift` (architecture tests enforce this).
- Names come from the glossary in `docs/03-domain.md`. Do not invent synonyms.
- Each invariant `I-xx` is enforced in one place here and has a test named by its ID.
- Per-item rules (`R-xx`: validation, conversion, budget version, draft rules) live here. Aggregates over many rows live in `lib/data/drift/` as SQL.
- Read the clock only through the `Clock` port.
- Expected failures are returned as typed results or typed failures, never as strings.
