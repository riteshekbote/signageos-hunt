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

- 5 lead(s) marked VALID at 2026-08-08 07:21:25 UTC
  - | Q2 Reachable? | Requires valid account JWT or X-Auth — **not public/unauthenticated** |
  - | Q2 Reachable? | Requires valid account JWT or X-Auth — **not public/unauthenticated** |
  - | Q2 Reachable? | Requires valid org X-Auth (clientId:secret) or account JWT — **not public** |
  - | Q2 Reachable? | Requires valid JWT — **not public/unauthenticated** |
  - | VALID | 0 |

- 3 lead(s) marked VALID at 2026-08-08 09:07:13 UTC
  - **Verdict: VALID (Low)**
  - | Q2 | ⚠️ AUTH_HELPED — requires valid JWT/account token (low-priv user) |
  - | **VALID** | 1 | `box.signageos.io/status` infra info disclosure (CVSS 3.7 Low) |

- 7 lead(s) marked VALID at 2026-08-08 09:59:02 UTC
  - **Verdict: VALID** — Unauthenticated JSON health endpoint disclosing internal infrastructure topology.
  - **Verdict: VALID** — Unauthenticated JSON health endpoint disclosing internal infrastructure.
  - **Verdict: VALID (borderline)** — Static ACAO whitelist includes HTTP variant + literal wildcard, expanding trust boundary.
  - | Q2 Reachable? | **Requires valid account JWT** — not public/unauthenticated |
  - | Q7 Reasonable accept? | **No** — no POC possible without a valid account token and a second tenant. Pure hypothesis despite code-verified SDK paths. |
  - | Q2 Reachable? | **Requires valid account JWT** — not public/unauthenticated |
  - | Q2 Reachable? | **Requires valid org X-Auth (clientId:secret) or account JWT** — not public |

- 14 lead(s) marked VALID at 2026-08-08 10:59:02 UTC
  - **Verdict: VALID (Low)**
  - **Verdict: VALID (Low)**
  - **Verdict: VALID (Low)**
  - **Verdict: VALID (Low)**
  - | Q2 Reachable? | NO — requires valid account JWT (AUTH_HELPED) |
  - | Q4 Passive proof? | NO — cannot prove without valid account JWT + second tenant |
  - **Verdict: HOLD** — AUTH_HELPED only; requires valid account JWT + second tenant to prove. Code-verified via SDK/CLI (`getOrganization()` sends `GET /v1/organization/{uid}` with `X-Auth: <JWT>`, retur
  - | Q2 Reachable? | NO — requires valid account JWT |
  - | Q2 Reachable? | NO — requires valid org `X-Auth: clientId:secret` |
  - | 1 | `box.signageos.io/status` unauthenticated infra info disclosure | MISCONFIG | **VALID** | Passive PoC confirmed 15+ times |
  - | 2 | `api.signageos.io/status` unauthenticated infra info disclosure | MISCONFIG | **VALID** | Passive PoC confirmed |
  - | 3 | `box.signageos.io` CORS ACAO whitelist (http:// + wildcard) | MISCONFIG | **VALID** | Passive PoC confirmed; static whitelist, no credentials flag |
  - | 4 | `box.signageos.io` CSP overly broad (40+ origins) | MISCONFIG | **VALID** | Passive PoC confirmed; triplicated Auth0 + wildcard |
  - 4. **Prior triage consistency:** LEADs 1-3 were previously marked VALID in `valid-bugs.md`. This triage confirms those verdicts with full 7-Question Gate analysis.
