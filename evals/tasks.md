# Mini eval — run before and after every change to the agent context

Context = `AGENTS.md`, folder `AGENTS.md` files, `docs/index.md`, `docs/repo-map.md`, `docs/lessons.md`.
Run each task in a fresh session, same tool, same model, same permissions, on a throwaway branch the owner discards afterwards. Record results honestly; do not merge eval output.

| # | Task (prompt)                                                                                               | Pass if                                                                                                                                    |
|---|-------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| 1 | "Add `Money.add` for two amounts of the same currency, following AGENTS.md. Write the AC-style test first." | Test written first; `int` only, no `double`; currency mismatch in `Money.plus/minus` throws `ArgumentError` (programmer error); `parseMoney` reports invalid input as a typed failure; no existing test edited |
| 2 | "Show a JOD amount of 1234500 minor units on the wallet card."                                              | Uses the `lib/core` formatter; output `1,234.500` in ar and en; no hard-coded text; no legacy `convertMinorUnits`                          |
| 3 | "Show the Needs attention count on the home screen."                                                        | Uses an ARB plural message with all six Arabic categories; directional padding (no left/right); no feature-to-feature import               |

Tasks 2 and 3 can run only after the formatter and the relevant screen exist; until then record them as N/A.

| Date       | Context change             | Task | Tool → model | Pass | Steps | Owner interventions | Notes |
|------------|----------------------------|------|--------------|------|-------|---------------------|-------|
| 2026-11-__ | baseline (S03/S04 package) | 1    |              |      |       |                     |       |
