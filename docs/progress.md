# Progress

Read first. Update last (one line per finished item; keep this file under 40 lines).

## Now
- Phase: P3 execution, stage 0 (foundation). Docs 01–05 and ADR-0001..0008 accepted. Program deadline: Tue 2026-11-24 (target: stage 0 complete, stage 1 as far as it goes).
- Current item: none started.
- Next item: domain kernel (`Money`, `CurrencyCode`, `Clock`, integer rates and exact conversion per ADR-0007) — gap C-01, C-12. Before it: legacy cleanup branch (`claude` review 2026-11-15).

## Stage 0 checklist
- [ ] Domain kernel
- [ ] Drift schema v1 + `UnitOfWork` + outbox table
- [ ] Architecture tests (ADR-0001) + CI test-change gate
- [ ] Access rules v2 + emulator tests; delete Firestore test data
- [ ] Walking skeleton: US-03 create wallet end to end
- [ ] Spike N-5: Frankfurter v2 historical range request
- [x] Spike C-21: current code blocks; US-05 changes it to warn + confirm

## Done
- 2026-11-15: docs chain accepted (01-brief v1.2, 02-spec v1.4, 03-domain v1.3, 04-architecture v1.2, ADR-0001..0008, 05-gap-analysis v1.1).

## Open
- O-3 (02-spec): Gemini terms on training use, before release.
- Measure the owner's real network before release (02-spec assumption).
