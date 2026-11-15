# ADR-0004 — Assisted entry: Gemini behind a Cloudflare Worker proxy, behind one port

Status: Accepted · 2026-11-16 · Decider: Fadi Abd AlJawwad
Revision: v2 after devil's-advocate review. v1 kept Google Apps Script.
Drivers: secret safety, privacy (BR-20, NFR-09, O-3), latency on a weak network (NFR-02a ≤ 8 s voice, NFR-02b ≤ 12 s receipt, 3G profile), cost (no card), abuse resistance.

## Context
The owner's network is weak and unmeasured (spec assumption). On a 250 kbps uplink, upload time alone is size × 8 ÷ 250 kbps: a 150 KB image sent as Base64 (× 1.33) takes about 6.4 s, so image size and proxy overhead decide whether NFR-02 is reachable. Apps Script adds a 302 redirect (second TLS handshake), cold starts, and an extra `accounts:lookup` call per request. Sign-up is open (AC-01.6), so the proxy must survive scripted use.

## Alternatives
| Option | For | Against |
|---|---|---|
| A. Apps Script proxy (current) | Already working, free | 302 redirect and double TLS; cold start; extra token-lookup call; quotas on runtime and URL fetches; hard to test |
| B. Cloudflare Worker proxy; key in Worker secret; Firebase ID token verified locally against cached Google public keys | No redirect, near-zero cold start, no lookup round-trip; binary upload; testable code; free tier without a card | New platform; JWT verification code to own |
| C. On-device OCR + text-only request | Tiny upload | On-device text recognition lacks Arabic script; Arabic receipts fail |
| D. Key in the app | Simplest | Key extractable (rejected) |

## Decision
B.
- Request: transcript text, or one receipt image within the AC-08.7 budget (grayscale, ≤ 60 KB, long side ≤ 1000 px) sent as binary, plus the Firebase ID token in the `Authorization` header.
- Worker: verifies the token signature, audience, issuer, and expiry; applies a per-user limit and a global daily cap that protects the Gemini quota; forwards a fixed extraction prompt; returns only the allowed fields (R-16 also runs in the app); stores nothing.
- App: `AiExtractor` port; 20 s timeout (AC-07.6).
- Apps Script is retired after migration (`05-gap-analysis`).

## Open condition (O-3)
Before release, verify the current Gemini API terms for the tier in use. If submitted content may be used for training, MSG-08 states it explicitly.

## Consequences
Positive: latency budget reachable on weak links (image ≈ 2 s upload at 250 kbps); abuse limits in one place; proxy code testable.
Negative: a new platform to deploy and monitor; token verification correctness is now our responsibility (tests required).

## Verification
NFR-02a/02b instrumented runs on the 3G profile, then on the owner's measured network; NFR-03 evaluation set; NFR-09 payload tests; Worker unit tests for token rejection (expired, wrong audience, wrong issuer, bad signature) and limits.
