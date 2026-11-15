# 02-spec — FinTrack-AI

Status: Accepted v1.3 · 2026-11-16 · Owner: Fadi Abd AlJawwad
Changes in v1.1: test-immutability rule added to Conventions.
Changes in v1.2 (from 03-domain review): account creation ACs (AC-01.6, AC-01.7); "transfer fee" wording; AC-04.3 wording; category renaming listed as Not now.
Changes in v1.3 (from architecture review): AC-04.8 arrival order; AC-03.7 wallet appearance; AC-08.7 image budget; "outdated" measured from the last successful refresh (AC-10.4, BR-17, MSG-10); NFR-02 split into voice and receipt; network assumption.
Source of truth above this file: `docs/01-brief.md` (Accepted v1.1). Where they conflict, the brief wins until this spec is accepted.
Review log: Gemini skeptical-tester review of v1, accepted/rejected items recorded in `claude/fintrack/02-spec-review-v1.md`.

## Conventions

- Stories: `US-NN`. Acceptance criteria: `AC-NN.M` (Given / When / Then). One automated test per AC, named by its ID, unless marked *(manual)*.
- **Tests are the contract.** An AC test is written and approved before its implementation and must fail first. When it fails later, the implementation changes, never the test. A test changes only when its AC changes, and an AC changes only through a spec revision approved by the owner.
- Rules: `BR-NN` in EARS form. Non-functional requirements: `NFR-NN` (metric, threshold, condition, verification).
- Messages: `MSG-NN` (section 3). An AC that shows a message asserts the message ID, not its wording. Every message exists in Arabic and English.
- **Invalid field**: the field shows its validation message and saving stays blocked. Used wherever an AC says a field "is invalid".
- **Without a network round-trip**: the visible result updates from local data alone, with no manual refresh.
- Source tags on rules not stated in the brief:
  - `[DERIVED: X]` = follows logically from brief rule or BR X.
  - `[PROPOSED]` = drafted by Claude to close a gap. All approved by the owner on 2026-11-15.
  - `[ASSUMPTION]` = not verified.

---

## 1. Glossary (preview — full version in `03-domain.md`)

| Term | Meaning |
|---|---|
| Owner | The single person who operates the account |
| Wallet | A place where the owner holds money. Kind: cash, e-wallet, or bank. One currency per wallet |
| Opening balance | Amount in a wallet at creation. Not a transaction; not income |
| Transaction | Income, expense, or transfer |
| Transfer | One record that moves money between two of the owner's wallets |
| Transfer fee ("fee") | Expense in category "Fees", linked to one transfer, from that transfer's source wallet. The Fees category can also be used for manual expenses |
| Draft | Unsaved, editable transaction produced by voice or receipt input |
| Display currency | Currency used for net worth and reports (ILS, USD, or JOD) |
| Reference rate | Daily exchange rate from the shared reference source. "Current" = the latest stored daily rate |
| Net worth | Sum of all wallet balances, converted to the display currency |
| Needs attention | In-app list of local changes the server rejected |

---

## 2. User stories and acceptance criteria

### US-01 — Account access
As the owner, I want to sign in to my account, so that my data is available on any of my devices.

- **AC-01.1 (happy)** Given a registered owner, when they sign in with email/password or Google, then their wallets and transactions are shown.
- **AC-01.2 (unhappy: wrong credentials)** Given a registered owner, when they enter a wrong password, then sign-in fails with MSG-01 and no data is shown.
- **AC-01.3 (unhappy: offline first sign-in)** Given a device with no stored account, when the owner submits sign-in without connectivity, then sign-in stops with MSG-02.
- **AC-01.4 (password reset)** Given a registered email, when the owner requests a password reset, then a reset email is sent and MSG-14 is shown.
- **AC-01.5 (sign out)** Given a signed-in owner, when they sign out, then the device contains no financial data of that account. `[PROPOSED]`
- **AC-01.6 (create account)** Given a new email and a valid password, when the person signs up, then an account is created with display currency ILS and the system categories, and the owner lands on wallet creation. `[DERIVED: brief v1.1 sign-in]`; `[PROPOSED]` for default ILS (approved 2026-11-15).
- **AC-01.7 (first Google sign-in)** Given a Google account never used before, when the person signs in with Google, then an account is created as in AC-01.6. `[DERIVED: brief v1.1 sign-in]`

### US-02 — App lock
As the owner, I want the app to lock, so that someone holding my phone cannot see my money.

- App lock is opt-in from settings; the app offers it once after the first sign-in. `[PROPOSED]`
- **AC-02.1 (happy)** Given app lock is on, when the owner opens the app, then biometric authentication is required before any data is shown.
- **AC-02.2 (fallback)** Given app lock is on and biometrics fail or are unavailable, when the owner chooses the fallback, then the device PIN/pattern unlocks the app.
- **AC-02.3 (relock)** Given the app is unlocked, when it stays in the background for 30 seconds or more, then it is locked on return.
- **AC-02.4 (no relock)** Given the app is unlocked, when it returns from the background in less than 30 seconds, then it stays unlocked.
- **AC-02.5 (unhappy: no device security)** Given the device has no biometric and no device PIN/pattern enrolled, when the owner turns on app lock, then the setting stays off and MSG-03 is shown. `[PROPOSED]`
- **AC-02.6 (unhappy: authentication cancelled or failed)** Given the lock screen, when the owner cancels or fails both biometric and device PIN/pattern, then the app stays locked, no data is shown, and the owner can retry or sign out. `[PROPOSED]`

### US-03 — Create a wallet
As the owner, I want to create wallets with their currency and opening balance, so that balances match reality from day one.

- **AC-03.1 (happy)** Given the owner enters a name, a kind (cash / e-wallet / bank), a currency, and an opening balance, when they save, then the wallet appears with that balance in its currency. Wallet kinds are a closed set in v1. `[PROPOSED]`
- **AC-03.2 (unhappy: missing field)** Given any required field is empty, when the owner saves, then the wallet is not created and each empty field is invalid.
- **AC-03.3 (unhappy: precision)** Given currency JOD, when the owner enters an opening balance with 4 decimals, then the opening balance is invalid. `[DERIVED: BR-01]`
- **AC-03.4** Given a wallet created with opening balance 500, when income and expense totals are shown, then the 500 is not counted as income.
- **AC-03.5 (unhappy: duplicate name)** Given an active wallet with the same name (case-insensitive), when the owner saves a new wallet with that name, then the name is invalid. `[PROPOSED]`
- **AC-03.6 (unhappy: negative opening balance)** Given a negative opening balance, when the owner saves, then the opening balance is invalid. `[PROPOSED]`
- **AC-03.7 (appearance)** Given a wallet, when the owner picks an optional icon and color, then the wallet shows them on every signed-in device. `[PROPOSED]` (owner, DQ-2)

### US-04 — Archive, restore, or delete a wallet
As the owner, I want to remove wallets I no longer use, without breaking my history.

- **AC-04.1 (delete)** Given a wallet with no transactions, when the owner deletes it and confirms, then it is removed.
- **AC-04.2 (archive)** Given a wallet with transactions, when the owner removes it, then it is archived, not deleted, and its transactions stay in history and reports.
- **AC-04.3** Given an archived wallet, when the owner records or edits any transaction (income, expense, or transfer), then the archived wallet is not offered.
- **AC-04.4** Given an archived wallet with a non-zero balance, when net worth is shown, then that balance is included. `[PROPOSED]`
- **AC-04.5 (restore)** Given an archived wallet, when the owner restores it, then it is offered again for new transactions. `[PROPOSED]`
- **AC-04.6 (unhappy: cancel)** Given the delete or archive confirmation, when the owner cancels, then nothing changes.
- **AC-04.7 (unhappy: restore name collision)** Given an active wallet now has the same name as an archived one, when the owner restores the archived wallet, then restore is blocked until one of them is renamed. `[DERIVED: AC-03.5]`
- **AC-04.8 (unhappy: offline race)** Given device A deleted an empty wallet offline and device B added a transaction to it offline, when both sync, then the change that reaches the server first wins: if the deletion arrives first, B's transaction is rejected and goes to Needs attention, where the owner can move it to another wallet; if the transaction arrives first, the deletion is rejected and the wallet stays. `[DERIVED: BR-05, BR-25]`

### US-05 — Record income or expense manually
As the owner, I want to record income and expenses in seconds, so that tracking does not become a chore.

- **AC-05.1 (happy)** Given an active ILS wallet, when the owner chooses type "expense", enters 25.50, picks category "Food", keeps today's date, and saves, then the expense is saved and the wallet balance drops by 25.50 ILS without a network round-trip.
- **AC-05.2 (unhappy: no type)** Given no type is selected, when the owner saves, then the type field is invalid.
- **AC-05.3 (unhappy: missing fields)** Given amount, wallet, or category is missing, when the owner saves, then each missing field is invalid.
- **AC-05.4 (unhappy: invalid amount)** Given the amount is zero, negative, or has more decimals than the wallet currency allows, when the owner saves, then the amount is invalid. `[PROPOSED]` for amount > 0; `[DERIVED: BR-01]` for decimals.
- **AC-05.5 (unhappy: future date)** Given a date after the device's local current date, when the owner saves, then the date is invalid.
- **AC-05.6 (insufficient balance)** Given a wallet balance of 10 USD, when the owner saves an expense of 15 USD, then MSG-06 asks for confirmation; after confirmation the expense is saved and the balance becomes −5 USD.
- **AC-05.7** Given income or expense is saved, when the owner views it, then its amount is in the wallet's currency and the optional note is kept.

### US-06 — Transfer between wallets
As the owner, I want to move money between my wallets, including across currencies and with fees, so that every wallet stays accurate without inflating income or expenses.

- **AC-06.1 (happy: same currency)** Given wallets A and B in ILS, when the owner transfers 100 ILS from A to B, then A drops by 100, B rises by 100, and income and expense totals do not change.
- **AC-06.2 (happy: cross currency)** Given wallet A in USD and wallet B in ILS, when the owner transfers 100 USD and enters 362.00 ILS received, then A drops by 100 USD and B rises by 362.00 ILS.
- **AC-06.3 (received amount suggestion)** Given a cross-currency transfer and a stored reference rate, when the owner enters the amount sent, then the amount received is pre-filled from that rate and stays editable. `[PROPOSED]`
- **AC-06.4 (fee)** Given a transfer of 100 USD with a fee of 2 USD, when the owner saves, then the transfer and a 2 USD fee from the source wallet are both saved. `[PROPOSED]` for category name "Fees".
- **AC-06.5 (atomic)** Given a transfer with a fee, when the fee write fails during save (simulated failure), then neither the transfer nor the fee exists. `[PROPOSED]`
- **AC-06.6 (unhappy: same wallet)** Given the source and destination are the same wallet, when the owner saves, then the destination is invalid. `[PROPOSED]`
- **AC-06.7 (unhappy: no rate, no received amount)** Given a cross-currency transfer, no stored reference rate, and an empty received amount, when the owner saves, then the received amount is invalid.
- **AC-06.8 (insufficient balance)** Given the source balance is lower than amount plus fee, when the owner saves, then MSG-06 asks for confirmation and the transfer is saved after confirmation.
- **AC-06.9 (delete with fee)** Given a transfer with a fee, when the owner deletes the transfer and confirms, then the fee is deleted too. `[PROPOSED]`
- **AC-06.10 (edit with fee)** Given a transfer with a fee, when the owner changes its source wallet or date, then the fee moves to the same source wallet and date. `[PROPOSED]`
- **AC-06.11 (fee edited through transfer)** Given a fee in the transaction list, when the owner opens it, then the transfer that owns it opens; setting the fee to 0 removes the fee. `[PROPOSED]`

### US-07 — Voice entry
As the owner, I want to say a transaction aloud, so that I can record it hands-free.

- **AC-07.1 (first use)** Given the owner has never used voice or receipt entry, when they start it, then MSG-08 states that the content is sent to an external AI service, and entry continues only after the owner acknowledges it.
- **AC-07.2 (happy)** Given online, acknowledgment given, an active wallet named "Cash", and the recognized transcript "30 shekels on transport from cash", when the AI response arrives, then a draft opens with amount 30.00, currency ILS, category Transport, wallet Cash, today's date, and an empty type.
- **AC-07.3 (never auto-save)** Given any AI response, when the draft opens, then nothing is saved until the owner confirms.
- **AC-07.4 (type always empty)** Given any transcript, including words such as "spent" or "received", when the draft opens, then the type is empty and must be chosen. `[DERIVED: BR-07]`
- **AC-07.5 (unhappy: offline)** Given no connectivity, when the entry options open, then voice and receipt entry are disabled with MSG-04, and manual entry stays enabled.
- **AC-07.6 (unhappy: service failure)** Given a pending AI request, when it returns an error or exceeds 20 seconds, then MSG-05 is shown and the manual form opens with the recognized transcript in the note. `[PROPOSED]` for the 20-second timeout.
- **AC-07.7 (leave draft)** Given an unsaved draft, when the owner leaves the screen, then MSG-07 asks for confirmation; after confirmation the draft is discarded.
- **AC-07.8 (privacy)** Given a voice request, when it is sent, then its payload contains only the transcript — no balances, wallet list, or account data.

### US-08 — Receipt entry
As the owner, I want to photograph a receipt, so that I don't type amounts and merchants.

- **AC-08.1 (happy)** Given online and acknowledgment given (AC-07.1), when the owner photographs a receipt showing 45.000 JOD, merchant "Market X", dated yesterday, then a draft opens with amount 45.000, currency JOD, note "Market X", yesterday's date, a suggested category, and an empty type. `[PROPOSED]` for merchant stored as note.
- **AC-08.2 (minimal extraction)** Given an AI response with fields outside {amount, currency, date, merchant, category}, or a merchant text containing a digit sequence of 13–19 digits (with optional spaces or dashes), when the response is processed, then the extra fields and the digit sequence are removed before display or storage. `[PROPOSED]` for the card-number filter.
- **AC-08.3 (currency mismatch)** Given the extracted currency differs from the selected wallet's currency, when the draft opens, then the wallet is invalid until the owner picks a wallet in that currency or enters the amount in the selected wallet's currency. `[DERIVED: BR-02]`
- **AC-08.4 (unhappy: no amount)** Given the AI response has no valid amount, when the draft opens, then the amount is empty and invalid.
- **AC-08.5 (unhappy: future date)** Given the extracted date is after today, when the draft opens, then the date is invalid.
- **AC-08.7 (image budget)** Given a captured receipt, when it is sent, then it is a grayscale image of at most 60 KB with its long side at most 1000 px. `[PROPOSED]`
- **AC-08.6 (no image kept)** Given interpretation finished, when the owner saves or discards the draft, then the app's storage holds no image from that capture and no image is written to the app's backend.
- AC-07.3, AC-07.5, AC-07.6, AC-07.7 apply to receipts as well.

### US-09 — Edit or delete a transaction
As the owner, I want to fix mistakes, so that balances and reports stay trustworthy.

- **AC-09.1 (happy: edit)** Given a saved expense of 50 ILS, when the owner changes it to 40 ILS, then the wallet balance and all reports reflect 40 without a network round-trip.
- **AC-09.2 (delete)** Given a saved transaction, when the owner deletes it and confirms, then it disappears from history, balances, and reports.
- **AC-09.3 (unhappy: cancel delete)** Given the delete confirmation, when the owner cancels, then nothing changes.
- **AC-09.4 (unhappy: invalid edit)** Given an edit that breaks any save rule of US-05 or US-06, when the owner saves, then the edit is blocked.
- **AC-09.5 (wallet change)** Given the owner moves a transaction to a wallet in another currency, when they save, then the amount is invalid until re-entered in the new currency. `[DERIVED: BR-02]`
- **AC-09.6 (unchanged date)** Given a saved transaction whose date is now after the device's local date (for example after a time-zone change), when the owner edits another field and saves, then the unchanged date is accepted. `[PROPOSED]`
- **AC-09.7 (concurrent edits)** Given device A's edit reaches the server before device B's edit of the same transaction, when both devices sync, then both show device B's edit.
- **AC-09.8 (edit vs delete)** Given device A deleted a transaction and device B edited it offline, when both sync, then the transaction stays deleted and B's edit goes to Needs attention. `[DERIVED: BR-23]`

### US-10 — Balances and net worth
As the owner, I want to see how much I have in each wallet and in total, so that I know my position at any moment.

- **AC-10.1 (wallet balance)** Given a wallet, when the owner views it, then its balance = opening balance + income − expenses − transfers out + transfers in, in the wallet's currency, over all time.
- **AC-10.2 (net worth)** Given wallets in ILS, USD, and JOD, when the owner views net worth, then each balance is converted to the display currency at the current reference rate and summed.
- **AC-10.3 (switch display currency)** Given net worth is shown in ILS, when the owner switches to USD, then net worth and reports are shown in USD and no stored amount changes.
- **AC-10.4 (outdated rates)** Given the last successful rate refresh happened more than 3 days ago, when converted totals are shown, then they carry the "outdated" label (MSG-10) with the date of that refresh. A source that publishes no rate on weekends or holidays does not make rates outdated.
- **AC-10.5 (no rates)** Given no rate exists for a currency pair, when net worth is shown, then the converted total carries the "unavailable" label (MSG-11) and each wallet balance is still shown in its own currency.
- **AC-10.6 (all time)** Given transactions older than one year, when balances are shown, then those transactions are included.

### US-11 — Spending insights
As the owner, I want to see where my money goes, so that I can change habits.

- **AC-11.1 (by category)** Given expenses in a period, when the owner views insights, then expenses are grouped by category and income is shown separately; transfers appear in neither.
- **AC-11.2 (historical rate)** Given a USD expense dated 2026-10-01, when October expenses are shown in ILS, then it is converted at the 2026-10-01 rate, not the current rate.
- **AC-11.3 (period comparison)** Given a selected period (month or custom range), when the owner compares, then each category shows the selected period and the immediately preceding period of equal length. `[PROPOSED]` for "equal length".
- **AC-11.4 (custom range)** Given a custom date range, when insights load, then only transactions dated inside the range are counted. `[ASSUMPTION]`
- **AC-11.5 (missing rate for a date)** Given no rate is stored for a transaction's date, when it is converted, then the nearest earlier rate within 7 days is used and the total carries the "approximate" label (MSG-12); if none exists within 7 days, AC-11.6 applies. `[PROPOSED]`
- **AC-11.6 (unhappy: no usable rate)** Given an amount with no usable rate, when converted totals are shown, then that amount is excluded from the converted total, and the total states how many transactions were excluded (MSG-11). `[PROPOSED]`
- **AC-11.7 (unhappy: invalid range)** Given a custom range whose start is after its end, or whose end is after today, when the owner applies it, then the range is invalid.

### US-12 — Monthly budgets
As the owner, I want a monthly limit per expense category, so that I see early when I overspend.

- **AC-12.1 (happy)** Given a Food budget of 800 ILS, when October Food expenses reach 600 ILS, then the budget shows 600 / 800 and 200 remaining.
- **AC-12.2 (over budget)** Given expenses exceed the budget, when the owner views budgets, then the category is marked over budget with the excess amount.
- **AC-12.3 (no rollover)** Given 200 ILS unused in October, when November starts, then the November limit is 800, not 1000.
- **AC-12.4 (unhappy: invalid amount)** Given a budget amount of zero or less, when the owner saves, then the amount is invalid. `[PROPOSED]`
- **AC-12.5 (recurrence)** Given a budget is set, when months pass, then it applies every month until changed; a change applies from the current month, and past months keep their old limit. `[PROPOSED]`
- **AC-12.6 (currency)** Given a budget currency differs from an expense's currency, when progress is calculated, then the expense is converted at its transaction-date rate (AC-11.5 and AC-11.6 apply). Budget currency = display currency at creation. `[PROPOSED]`
- **AC-12.7 (unhappy: duplicate)** Given a category already has a budget, when the owner creates another for it, then the existing budget opens for editing instead. `[PROPOSED]`
- **AC-12.8 (unhappy: income category)** Given an income category, when the owner creates a budget, then income categories are not offered. `[PROPOSED]`

### US-13 — Categories
As the owner, I want my own categories in addition to defaults, so that reports match my life.

- **AC-13.1 (defaults)** Given a new account, when the owner opens categories, then default expense and income categories exist, including "Fees" and "Other". `[PROPOSED]`
- **AC-13.2 (typed)** Given the owner creates an expense category, when they record income, then that category is not offered. `[PROPOSED]`
- **AC-13.3 (unhappy: duplicate)** Given a category with the same name and type exists (case-insensitive), when the owner creates it, then the name is invalid. `[PROPOSED]`
- **AC-13.4 (delete custom)** Given a custom category with transactions, when the owner deletes it and confirms, then its transactions move to "Other" and its budget is removed. `[PROPOSED]`
- **AC-13.5 (unhappy: delete default)** Given a default category, when the owner tries to delete it, then deletion is not offered. `[PROPOSED]`
- **AC-13.6 (offline race)** Given device A deleted category "Coffee" offline and device B recorded "Coffee" expenses offline, when both sync, then B's expenses move to "Other". `[DERIVED: AC-13.4]`

### US-14 — Offline use and sync
As the owner, I want the app to work without internet, so that connectivity never stops me recording.

- **AC-14.1 (happy)** Given no connectivity, when the owner records, edits, deletes, or transfers, then the change is saved on the device and balances update without a network round-trip.
- **AC-14.2 (sync)** Given offline changes, when connectivity returns, then they sync without owner action and keep their entered dates.
- **AC-14.3 (rejected change)** Given a synced change is rejected, when the rejection arrives, then an in-app banner (MSG-09) appears and the item stays in Needs attention, where it can be edited and retried or discarded. No OS push notification is used.
- **AC-14.4 (convergence)** Given two devices changed data offline, when both are online again, then both show the same data.
- **AC-14.5 (offline reading)** Given no connectivity, when the owner views balances, history, insights, and budgets, then all are available from local data.
- **AC-14.6 (unhappy: connection drops mid-sync)** Given sync is in progress, when connectivity drops, then unsent changes stay queued, sync resumes when connectivity returns, and no change is duplicated or lost.
- **AC-14.7 (unhappy: session expired)** Given the sign-in session expired while offline, when connectivity returns, then queued changes stay on the device, MSG-13 asks the owner to sign in, and sync completes after sign-in without loss.

---

## 3. Messages

Each message exists in Arabic and English. Tests assert the ID.

| ID | Meaning |
|---|---|
| MSG-01 | Wrong email or password |
| MSG-02 | First sign-in on this device needs a connection |
| MSG-03 | App lock needs a biometric or device PIN/pattern on this device |
| MSG-04 | Voice and receipt entry need a connection |
| MSG-05 | AI service failed; continue manually |
| MSG-06 | Amount exceeds wallet balance; confirm to continue |
| MSG-07 | Leaving discards this draft; confirm to continue |
| MSG-08 | Voice text and receipt images are sent to an external AI service; acknowledge to continue |
| MSG-09 | A change could not be saved; review it in Needs attention |
| MSG-10 | Label: converted with outdated rates (date of last successful refresh shown) |
| MSG-11 | Label: conversion unavailable (count of excluded items shown when relevant) |
| MSG-12 | Label: approximate conversion |
| MSG-13 | Session expired; sign in to finish syncing |
| MSG-14 | Password reset email sent |

---

## 4. Business rules (EARS)

| ID | Rule |
|---|---|
| BR-01 | The system shall store every amount in its wallet's currency as an exact value with that currency's precision (ILS 2, USD 2, JOD 3 decimals). |
| BR-02 | The system shall allow exactly one currency per wallet; a transaction's currency is its wallet's currency. |
| BR-03 | The system shall support ILS, USD, and JOD only in v1. |
| BR-04 | The system shall not count opening balances as income. |
| BR-05 | When a wallet has transactions, the system shall archive it instead of deleting it. |
| BR-06 | The system shall not save income or expense without type, amount > 0, wallet, category, and date; or a transfer without source, destination, and amount sent > 0. |
| BR-07 | The system shall never infer a transaction type; AI drafts always leave the type empty. |
| BR-08 | If a new or changed transaction date is after the device's local current date, then the system shall reject it. |
| BR-09 | The system shall exclude transfers from income and expense totals. |
| BR-10 | When a transfer has a fee, the system shall save, change, and delete the transfer and its fee together or not at all. |
| BR-11 | When a transfer is cross-currency, the system shall store both the amount sent and the amount received. |
| BR-12 | If an expense or transfer exceeds the wallet balance, then the system shall warn the owner and save only after confirmation. |
| BR-13 | The system shall compute wallet balances over all time from the opening balance and current transactions. |
| BR-14 | The system shall convert net worth at the current reference rate and period income/expense at each transaction's date rate. |
| BR-15 | The system shall compute totals from exact values and round only for display, half-up, to the target currency's precision. `[PROPOSED]` |
| BR-16 | The system shall not let the owner override reference rates, except the amount received in a cross-currency transfer. |
| BR-17 | While the last successful rate refresh is more than 3 days old, the system shall label converted totals "outdated". |
| BR-18 | The system shall refresh reference rates at most once per day while online. `[PROPOSED]` |
| BR-19 | The system shall never save AI output without owner confirmation, and shall not keep unsaved drafts. |
| BR-20 | The system shall send only the voice transcript or the receipt image to the AI service, and shall keep only amount, currency, date, merchant (as note), and category from its response. |
| BR-21 | The system shall not store receipt images. |
| BR-22 | When the owner first uses voice or receipt entry, the system shall disclose external AI processing and require acknowledgment. |
| BR-23 | While offline, the system shall provide every function except voice and receipt entry. |
| BR-24 | If the server rejects a synced change, then the system shall show an in-app banner and keep the item in Needs attention. |
| BR-25 | When two devices change the same transaction, the system shall keep the change that reached the server last; a deletion wins over an edit. |
| BR-26 | While app lock is on, the system shall require biometric or device-credential authentication at launch and after 30 seconds or more in the background. |
| BR-27 | The system shall allow only the owner to read or change the account's data. |
| BR-28 | The system shall not carry unused budget into the next month. |
| BR-29 | The system shall provide the full UI in Arabic (right-to-left) and English. |

---

## 5. Non-functional requirements

Network profile "3G" = 750 kbps down, 250 kbps up, 100 ms round-trip latency, emulated.

| ID | Attribute | Metric and threshold | Condition | Verification |
|---|---|---|---|---|
| NFR-01 | Entry speed | Manual entry ≤ 15 s | Form open to saved, owner after one practice run | Manual benchmark, 10 timed runs, median |
| NFR-02a | AI latency, voice | Draft shown ≤ 8 s in 90% of attempts | 3G profile | Instrumented test, 30 runs |
| NFR-02b | AI latency, receipt | Draft shown ≤ 12 s in 90% of attempts | 3G profile, image within AC-08.7 budget | Instrumented test, 30 runs |
| NFR-03 | AI accuracy | Amount and currency correct ≥ 90% | Fixed test set: 30 receipts + 30 transcripts, Arabic and English | Scripted evaluation |
| NFR-04 | Offline endurance | 500 transactions created offline over a simulated 30 days, 0 lost or duplicated after sync | Device with 3 GB RAM | Automated test |
| NFR-05 | Correctness | Exact (unrounded) balances match the expected fixture values 100% | Fixture of 50 mixed transactions incl. cross-currency transfers and fees | Automated test |
| NFR-06 | Adoption | Owner records daily for 14 consecutive days | Real use after release | Product metric from history (not automated) |
| NFR-07 | Numeric exactness | 0 floating-point errors in stored or summed amounts | All BR-01 currencies | Unit tests |
| NFR-08 | Data isolation | 0 cross-account reads or writes succeed | Access-rule tests | Automated, before every rules deploy |
| NFR-09 | AI privacy | 100% of AI requests contain only allowed content (BR-20) | Request-payload tests | Automated |
| NFR-10 | Localization | 100% of user-visible strings exist in Arabic and English; layouts render RTL in Arabic | All screens | Automated string-coverage test + manual RTL pass |

Display rounding note: category totals are each rounded for display, so their displayed sum may differ from the displayed grand total by up to half a minor unit per category. This is expected and not a correctness defect.

---

## 6. Not now

Everything in `01-brief.md` → Not now. In addition:
- OS push notifications of any kind (sync issues use in-app banners).
- Budget alerts outside the app.
- Wallet kinds beyond cash, e-wallet, bank.
- Changing an existing budget's currency.
- Renaming categories.
- Redaction of identifiers other than card-number digit sequences (phone, email, tax ID).
- Protection against deliberate device-clock manipulation.

---

## 7. Assumptions

- [ASSUMPTION] Several wallets of the same kind are allowed.
- [ASSUMPTION] Custom date ranges are allowed in insights and period comparison (AC-11.3, AC-11.4).
- [ASSUMPTION] Target devices: mid- or low-end Android on 3G-class connections.
- [ASSUMPTION] The owner's real network in Gaza is weak but unmeasured (owner, 2026-11-16). The 3G profile stays as the test condition; measure the real connection (median of daily speed tests over one week) before release and recalibrate NFR-02a/02b.
- [ASSUMPTION] A 3-day threshold for outdated rates and a 7-day lookback for missing historical rates are adequate.

## 8. Open questions

| ID | Question | Status |
|---|---|---|
| O-3 | Do the AI service's terms allow sending receipts and voice text without training use? | Decided in the assisted-entry ADR |
| O-5 | Approval of all `[PROPOSED]` rules in v2 | Resolved 2026-11-15: all approved |

---

## 9. Traceability (brief → spec)

| Brief section | Stories / rules |
|---|---|
| Users & roles, sign-in | US-01, BR-27 |
| Money & wallets | US-03, US-04, BR-01–05 |
| Transactions | US-05, US-06, US-09, BR-06–12 |
| Balances & conversion | US-10, US-11, BR-13–18 |
| Assisted entry | US-07, US-08, BR-19–22 |
| Offline, sync & devices | US-14, BR-23–25 |
| Budgets & security | US-12, US-13, US-02, BR-26, BR-28 |
| Language | BR-29, NFR-10 |
| Success criteria | NFR-01–06 |
