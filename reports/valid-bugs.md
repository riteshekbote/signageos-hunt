# Validated Bugs

- 2026-08-07 ~18:15 UTC - SEED STATE: 0 valid bugs. Pipeline not yet run; hypotheses are recon-based and UNVALIDATED.

- 3 lead(s) marked VALID at 2026-08-07 21:05:33 UTC
  - | Q2 Reachable? | Requires valid JWT |
  - | Q2 Reachable? | Requires valid JWT |
  - | **VALID** | 0 | — |

- 7 lead(s) marked VALID at 2026-08-08 02:27:23 UTC
  - **Verdict: VALID** — Unauthenticated JSON health endpoint disclosing internal infrastructure.
  - **Verdict: VALID** — Unauthenticated JSON health endpoint disclosing internal infrastructure.
  - **Verdict: VALID** (borderline) — Static ACAO whitelist includes HTTP variant + literal wildcard, expanding trust boundary.
  - | Q2 Reachable? | **Requires valid account JWT** — not public/unauthenticated |
  - | Q2 Reachable? | **Requires valid account JWT** |
  - | Q2 Reachable? | **Requires valid org X-Auth (clientId:secret) or account JWT** |
  - | **VALID** | 3 | box.status, api.status, box CORS |

- 5 lead(s) marked VALID at 2026-08-08 06:03:13 UTC
  - | Q2 Reachable? | Requires valid JWT — not public/unauthenticated |
  - | Q2 Reachable? | Requires valid account JWT or X-Auth — not public |
  - | Q2 Reachable? | Requires valid account JWT or X-Auth — not public |
  - | Q2 Reachable? | Requires valid org X-Auth (clientId:secret) — not public |
  - | VALID | 0 |
