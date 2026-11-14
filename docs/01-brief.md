# 01-brief — FinTrack-AI

Status: Accepted v1.0 · 2026-11-14 · Owner: Fadi Abd AlJawwad
Sources: ChatGPT interview (2 rounds), Gemini review, Claude review v2, decisions D1–D16 (2026-11-13), open-question answers (2026-11-14).
Detailed scenarios and edge cases are input for `02-spec.md`, not part of this brief.

## Problem

People who manage personal or household money across several currencies (ILS, USD, JOD) and several holding methods (cash, e-wallets, bank accounts) cannot tell at any moment how much they hold in each place or where their money goes. Manual recording is slow and error-prone, connectivity is intermittent, and once balances stop matching reality users abandon tracking.

## Users & roles

- **Owner (only role):** one person operates the account and is the only one who records, edits, deletes, and views its data.
- **Household use:** the owner may track money for family members through separate wallets named after them. Family members get no access.
- No external actors.

## Core flow

1. The owner signs in and unlocks the app.
2. The owner creates wallets; each wallet has one currency and a required opening balance.
3. The owner records an income, an expense, or a transfer between wallets — by typing, by voice, or by photographing a receipt.
4. Voice and receipt input produce an editable draft; nothing is saved until the owner reviews and confirms it.
5. The owner sees each wallet's balance, total net worth in the chosen display currency, spending by category, monthly category budgets, and period comparisons.
6. The owner corrects or deletes past transactions; balances and reports reflect the change immediately.
7. Without internet, everything except voice and receipt input keeps working; changes sync automatically when connectivity returns.

## Key product rules

**Money & wallets**
- Every amount is kept in its original currency, at that currency's precision (ILS and USD: 2 decimals; JOD: 3 decimals).
- One currency per wallet. The opening balance is not counted as income.
- A wallet that has transactions is archived, not deleted.
- Supported currencies in v1: ILS, USD, JOD. The display currency can be switched among them.

**Transactions**
- Types: income, expense, transfer. Type must always be chosen explicitly; it is never assumed.
- A transaction cannot be saved without its required fields.
- A transfer is one record that moves money between two of the owner's wallets; it never counts as income or expense.
- A cross-currency transfer records both the amount sent and the amount received.
- A transfer fee is recorded as a separate expense from the source wallet.
- An expense or transfer larger than the wallet balance triggers a warning but is allowed.
- The transaction date is the owner's local calendar date; future dates are not allowed in v1.
- Deleting a transaction requires confirmation. Categories: defaults plus owner-defined categories.

**Balances & currency conversion**
- Balances cover all time and are always consistent with the current transactions.
- Wallet balances are shown in the wallet's own currency.
- Net worth uses current exchange rates; income and expense reports for a period use the rate of each transaction's date.
- Exchange rates come from one shared reference source; the owner cannot override them. The only exception is the amount actually received in a cross-currency transfer.
- Recording never depends on exchange rates being available. Converted totals are marked "outdated" when the stored rates are older than 3 days, and "unavailable" when no rate exists.

**Assisted entry (voice / receipt)**
- Output is always a draft; drafts are not kept if the owner leaves without saving (the owner is warned).
- Only the voice text or the receipt image is sent for interpretation — never balances or account data.
- Minimal extraction: only amount, currency, date, merchant, and category are kept. Card numbers and other personal identifiers are never returned or stored; any other extracted field is discarded.
- Receipt images are not stored after interpretation.
- Before first use, the owner is told that voice text and receipt images are sent to an external AI service.

**Offline, sync & devices**
- Recording, editing, transfers, balances, and history work offline.
- If a synced change is rejected, the owner is notified and the item is kept for correction — never silently discarded.
- Several devices may differ while offline and must converge after sync.
- When two devices edit the same transaction, the last saved edit wins.

**Budgets & security**
- Monthly budgets per expense category; unused amounts do not roll over.
- The app locks with biometrics, falls back to the device PIN/pattern, and relocks after 30 seconds in the background.

## Success criteria

| Criterion | Target | Measured under |
|---|---|---|
| Manual entry time | ≤ 15 s | From opening the form to saved |
| Voice / receipt draft time | ≤ 8 s in 90% of attempts | 3G connection |
| Amount + currency extraction accuracy | ≥ 90% | Test set: 30 receipts + 30 voice notes (Arabic / English) |
| Offline endurance | 500 transactions over 30 days, then sync with zero loss | Device with 3 GB RAM |
| Balance correctness | 100% match with hand calculation | 50 mixed transactions incl. cross-currency transfers |
| Real use | Owner uses it daily for 14 consecutive days | Transaction history |

## Not now

- Debts, loans, investments, assets.
- Automatic bank or e-wallet integration.
- Shared accounts or multi-user access.
- Notifications and reminders.
- Recurring transactions, subscriptions, scheduled or future-dated transactions *(future candidate)*.
- Export to Excel / PDF and advanced reports *(future candidate)*.
- Edit history / audit log, budget rollover, saved AI drafts.
- Remote wipe and remote session revocation.
- Manual exchange-rate overrides.
- Conflict detection or merging for concurrent edits.
- On-device redaction of receipt images before sending.

## Assumptions

- [ASSUMPTION] The owner can create several wallets of the same kind (e.g., two cash wallets).
- [ASSUMPTION] Period comparison allows a custom date range, not only fixed months.
- [ASSUMPTION] Invalid or missing fields are highlighted individually before saving.
- [ASSUMPTION] Target users mostly use mid-range or low-end Android phones on 3G-class connections.
- [ASSUMPTION] A 3-day threshold is right for labeling rates outdated (rates update daily; weekends add 1–2 days of normal lag).

## Resolved questions (2026-11-14)

| # | Question | Decision |
|---|---|---|
| 1 | Background time before the app relocks | 30 seconds |
| 2 | Manual exchange-rate override | Not allowed; only the amount actually received in a cross-currency transfer may differ from the reference rate |
| 3 | Two devices edit the same transaction | Last saved edit wins; conflict detection is out of scope |
| 4 | Age after which stored rates are labeled outdated | 3 days |
| 5 | Redaction of receipt content | Minimal extraction (amount, currency, date, merchant, category); identifiers never returned or stored; images not stored; on-device redaction out of scope |

## Open questions

1. Do the chosen AI service's usage terms allow sending receipt images and voice text without them being used for model training? To be verified and recorded in the architecture decision for assisted entry.
