# tools/rules-test — rules (ADR-0003)

- Every rule in `firestore.rules` has at least one allow test and one deny test here.
- Name tests by the invariant or AC they protect (for example `I-04 transfer to same wallet is denied`, `AC-04.8 deletion first`).
- Cover both arrival orders of AC-04.8 and the edit-after-delete case of AC-09.8.
- Run against the emulator before every rules deploy; CI runs the same suite.
