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

- 9 lead(s) triaged at 2026-08-08 14:52 UTC (full 7-Question Gate, all models)
  - | 1 | `box.signageos.io/status` unauthenticated infra info disclosure | MISCONFIG | **VALID (Low)** | CVSS 3.7 | Passive PoC confirmed 15+ times |
  - | 2 | `api.signageos.io/status` unauthenticated infra info disclosure | MISCONFIG | **VALID (Low)** | CVSS 3.7 | Passive PoC confirmed |
  - | 3 | `box.signageos.io` CORS ACAO whitelist (http:// + wildcard) | MISCONFIG | **VALID (Low, borderline)** | CVSS 3.7 | Static whitelist, no credentials flag |
  - | 4 | `box.signageos.io` CSP overly broad (40+ origins) | MISCONFIG | **VALID (Low, borderline)** | CVSS 3.7 | Triplicated Auth0 + wildcard |
  - | 5 | `api.signageos.io/v1/organization/{uid}/security-token` cross-tenant mint | IDOR | **HOLD** | AUTH_HELPED — requires valid account JWT + second tenant |
  - | 6 | `api.signageos.io/v1/organization/{uid}` cross-tenant OAuth secret disclosure | IDOR | **HOLD** | AUTH_HELPED — requires valid account JWT + second tenant |
  - | 7 | `api.signageos.io/v1/device/{uid}/peer-recovery` cross-tenant read/write | IDOR | **HOLD** | AUTH_HELPED — requires valid org X-Auth + second tenant |
  - | 8 | `api.signageos.io/v2/*` authz drift | AUTH | **HOLD** | No passive evidence; all routes 403/404 |
  - | 9 | `videowall-designer` hardcoded secret (staging host) | SECRET_LEAK | **INVALID** | Out-of-scope host + known duplicate |

- 5 lead(s) marked VALID at 2026-08-08 14:55:57 UTC
  - - 4. **Prior triage consistency:** LEADs 1-3 were previously marked VALID in `valid-bugs.md`. This triage confirms those verdicts with full 7-Question Gate analysis.
  - | 1 | `box.signageos.io/status` — unauthenticated infra info disclosure | **VALID (Low)** | 3.7 |
  - | 2 | `api.signageos.io/status` — unauthenticated infra info disclosure | **VALID (Low)** | 3.7 |
  - | 3 | `box.signageos.io` CORS ACAO whitelist (http:// + wildcard) | **VALID (Low, borderline)** | 3.7 |
  - | 4 | `box.signageos.io` CSP overly broad (40+ origins) | **VALID (Low, borderline)** | 3.7 |

- 9 lead(s) marked VALID at 2026-08-08 16:59:58 UTC
  - **Verdict: VALID (Low)** | CVSS 3.1: 3.7 (AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N)
  - **Verdict: VALID (Low)** | CVSS 3.1: 3.7 (AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N)
  - **Verdict: VALID (Low, borderline)** | CVSS 3.1: 3.7 (AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N)
  - **Verdict: VALID (Low, borderline)** | CVSS 3.1: 3.7 (AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N)
  - | Q2 | NO — requires valid account JWT (403 without) |
  - **Verdict: HOLD** — AUTH_HELPED only; requires valid account JWT + second tenant
  - | Q2 | NO — requires valid account JWT |
  - | Q2 | NO — requires valid org X-Auth (clientId:secret) |
  - | **VALID** | 4 | box/status, api/status, box CORS, box CSP |

- 1 lead(s) marked VALID at 2026-08-08 17:55:35 UTC
  - | **VALID** | 4 | box/status, api/status, box CORS, box CSP |

- 4 lead(s) marked VALID at 2026-08-08 18:32:32 UTC
  - | **A** | `box.signageos.io/status` — unauthenticated K8s infra leak (pod hostname, process UID, Node version, Redis/Mongo/AMQP topology) | **VALID** | 4.3 Low |
  - | **B** | `api.signageos.io/status` — same class of infra leak | **VALID** | 4.3 Low |
  - | **C** | `box.signageos.io` CORS — 18 static ACAO values on `/` + `/login/` (http:// variant + `*.zdusercontent.com` wildcard, no credentials flag) | **VALID** | 3.1 Low |
  - | **D** | `box.signageos.io` CSP — overly broad connect-src/frame-src (40+ origins: Auth0, device APIs, S3, API Gateway) | **VALID** | 3.1 Low |

- 7 lead(s) marked VALID at 2026-08-08 19:50:51 UTC
  - | 1 | **box.signageos.io/status** — unauthenticated JSON leaks pod hostname, process UID, Node version, full amqp/redis/mongo topology; zero security headers (HSTS/xfo/xcto/CSP all absent) | **VALID**
  - | 2 | **box.signageos.io CORS** — 17-18 static ACAO values incl. `http://` plaintext variant + `https://*.zdusercontent.com` wildcard; no Access-Control-Allow-Credentials | **VALID** (already accepted
  - | 3 | **box.signageos.io CSP** — overly broad connect-src/frame-src (40-59 origins), triplicated Auth0 oauth/token | **VALID** (already accepted) |
  - | 4 | **api.signageos.io/status** — same info-leak class but now hardened with HSTS/xfo/xcto | **VALID** (already accepted) |
  - | 5 | Cross-tenant IDOR @ api.signageos.io/v1/organization/{uid}/security-token | **HOLD** — requires valid X-Auth token |
  - | 6 | Cross-tenant org OAuth client-secret disclosure @ api.signageos.io/v1/organization/{uid} | **HOLD** — requires valid account JWT |
  - | 7 | Cross-tenant peer-recovery overwrite @ api.signageos.io/v1/device/{uid}/peer-recovery | **HOLD** — requires valid org X-Auth |
