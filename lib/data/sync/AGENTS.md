# lib/data/sync — rules (ADR-0002, ADR-0010)

- One sync cycle = push, then pull.
- Push the outbox strictly in creation order. A transfer and its fee go in one Firestore batch.
- If the server rejects an entry, hold every later entry that references the same record; show them together in Needs attention (MSG-09).
- Pull: `serverUpdatedAt >= cursor`, ordered by (`serverUpdatedAt`, document id). Cursor = greatest `serverUpdatedAt` received, never the device clock.
- Applying a pulled document is idempotent. Pulled documents are trusted (server rules validated them).
- Deletion is a marker (`deleted = true`); never write to a deleted document.
- Firestore offline persistence stays off.
- Outbox payload is JSON with JSON-native types only; `serverUpdatedAt` is never in it and is added at push as `FieldValue.serverTimestamp()`. Pull-apply and restore never write outbox rows and decode before writing (ADR-0010/10). No network call inside `UnitOfWork.run`: read rows (tx) → send (no tx) → mark or remove (tx).
