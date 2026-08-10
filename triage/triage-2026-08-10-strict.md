# TRIAGE REPORT — 2026-08-10 (strict-triage-pass)

**Scope:** signageos (scope.yml: box.signageos.io In, api.signageos.io In)
**Probe source:** probe-results.md (passive GET/HEAD only)
**Models surveyed:** bigpickle, laguna, longcat, ling3 (no output), nemotron3
**Prior triage runs:** 50+ cycles since 2026-08-07; 4 leads already accepted as VALID in valid-bugs.md

---

## DEDUPLICATION

All 5 models converged on the same ~11 unique lead families across 100+ cycles. This report collapses duplicates and triages each unique lead once.

---

## 7-QUESTION GATE — PER-LEAD ANALYSIS

### LEAD 1: box.signageos.io/status — Unauthenticated K8s infra info disclosure
**Class:** MISCONFIG | **Confidence:** 95 | **Source models:** all 5

| Q | Answer |
|---|--------|
| Q1 In scope? | YES — box.signageos.io is in-scope asset |
| Q2 Reachable? | YES — unauthenticated GET, no creds needed |
| Q3 Real impact? | YES — live K8s pod hostname, process UID, Node version, full Redis/MongoDB/AMQP service topology with per-service responseTimes |
| Q4 GET/HEAD proof? | YES — `curl -s https://box.signageos.io/status` returns 200 application/json (len=1433-1442) |
| Q5 Novel? | NO — reconfirmed 50+ times since 2026-08-07, already in valid-bugs.md |
| Q6 Not rejected? | YES — not banner/stack-trace, not file/dir disclosure, not outdated-version-only. Structured health endpoint leaking internal architecture. |
| Q7 Triager accept? | YES — accepted as VALID (Low) on every prior triage run |

**Verdict: VALID (Low)** — CVSS 3.1: **4.3** (AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N)

**Minimal proof:** `curl -s https://box.signageos.io/status` → 200 JSON with hostname + succeededServices (amqp0, redis0-3, mongoDB0-3) + process.version v20.20.2 + process.uid (40-hex). Zero security headers (HSTS/xfo/xcto/CSP all absent) — differential vs `/` and `/login/`.

**Impact:** Internal infrastructure mapping (pod naming convention, service topology, process UID, Node version) enabling targeted follow-up attacks. Reconnaissance enabler, not direct data compromise.

**Reporting channel:** signageOS security channel per scope.yml (disclosure policy TBD).

---

### LEAD 2: api.signageos.io/status — Unauthenticated K8s infra info disclosure
**Class:** MISCONFIG | **Confidence:** 95 | **Source models:** all 5

| Q | Answer |
|---|--------|
| Q1 In scope? | YES — api.signageos.io is in-scope asset |
| Q2 Reachable? | YES — unauthenticated GET |
| Q3 Real impact? | YES — same class of infra leak (pod hostname, process UID, Node v24.19.0, service topology) |
| Q4 GET/HEAD proof? | YES — probe confirms 200 application/json on this cycle |
| Q5 Novel? | NO — reconfirmed 50+ times since 2026-08-07 |
| Q6 Not rejected? | YES — same rationale as Lead 1 |
| Q7 Triager accept? | YES — accepted as VALID (Low) on every prior triage run |

**Verdict: VALID (Low)** — CVSS 3.1: **4.3** (AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N)

**Minimal proof:** Probe-confirmed 200 application/json. Returns pod hostname (api-6f69db97d5-*), succeededServices (amqp0, redis0-3, mongoDB0-2), process.version v24.19.0. Hardened with HSTS/xfo/xcto (differential vs box /status which lacks them).

**Impact:** Same recon value as box /status. Lower severity because API is otherwise properly gated.

**Reporting channel:** signageOS security channel per scope.yml.

---

### LEAD 3: box.signageos.io — CORS ACAO 18-origin static whitelist (http:// + wildcard)
**Class:** MISCONFIG | **Confidence:** 60 | **Source models:** bigpickle, laguna, longcat, nemotron3

| Q | Answer |
|---|--------|
| Q1 In scope? | YES — box.signageos.io |
| Q2 Reachable? | YES — unauthenticated, observable via GET with spoofed Origin |
| Q3 Real impact? | BORDERLINE — 18 static ACAO values incl http://box.signageos.io (plaintext) + https://*.zdusercontent.com (wildcard). No Access-Control-Allow-Credentials on any box path. |
| Q4 GET/HEAD proof? | YES — `curl -sI -H "Origin: https://evil.test" https://box.signageos.io/` shows static ACAO list unchanged |
| Q5 Novel? | NO — reconfirmed 50+ times |
| Q6 Not rejected? | YES — not best-practice-only; real trust-boundary expansion with HTTP variant + wildcard |
| Q7 Triager accept? | MARGINAL — accepted as VALID informational on prior runs. No credentials flag means no cookie/auth theft. |

**Verdict: VALID (Low, borderline)** — CVSS 3.1: **3.1** (AV:N/AC:H/PR:N/UI:R/S:U/C:L/I:N/A:N)

**Minimal proof:** `curl -sI -H "Origin: https://evil.test" https://box.signageos.io/` → 18 static ACAO values unchanged. Includes http:// variant + *.zdusercontent.com wildcard. No Access-Control-Allow-Credentials.

**Impact:** Any JS on a listed origin (e.g., compromised *.zdusercontent.com subdomain) can read box's unauthenticated login/redirect HTML. Severity: Low (no credentials).

**Reporting channel:** signageOS security channel per scope.yml.

---

### LEAD 4: box.signageos.io — CSP overly broad connect-src/frame-src (40+ origins)
**Class:** MISCONFIG | **Confidence:** 75 | **Source models:** bigpickle, laguna, longcat, nemotron3

| Q | Answer |
|---|--------|
| Q1 In scope? | YES — box.signageos.io |
| Q2 Reachable? | YES — unauthenticated GET on /login/ |
| Q3 Real impact? | BORDERLINE — 40+ origins spanning Auth0, Sony/BroadSign/MoodMedia device APIs, S3 buckets, AWS API Gateway. Requires co-located XSS to fully exploit. |
| Q4 GET/HEAD proof? | YES — `curl -sI https://box.signageos.io/login/%2F` shows CSP header |
| Q5 Novel? | NO — reconfirmed 50+ times |
| Q6 Not rejected? | YES — not best-practice-only; real trust-boundary expansion |
| Q7 Triager accept? | MARGINAL — defense-in-depth finding; triager may accept as informational |

**Verdict: VALID (Informational, borderline)** — CVSS 3.1: **3.1** (AV:N/AC:H/PR:N/UI:N/S:U/C:N/I:L/A:N)

**Minimal proof:** `curl -sI https://box.signageos.io/login/%2F` → CSP header with 40+ distinct origins in connect-src/frame-src. Triplicated Auth0 oauth/token entries.

**Impact:** Overly broad CSP expands implicit trust boundary — any XSS within box's own origin can exfiltrate to or interact with all listed origins.

**Reporting channel:** signageOS security channel per scope.yml.

---

### LEAD 5: api.signageos.io/v1/organization/{uid}/security-token — Cross-tenant org-token minting
**Class:** IDOR | **Confidence:** 78 | **Source models:** bigpickle, laguna, longcat, nemotron3

| Q | Answer |
|---|--------|
| Q1 In scope? | YES — api.signageos.io |
| Q2 Reachable? | NO (under passive-first) — requires valid account JWT |
| Q3 Real impact? | YES (if confirmed) — mint org tokens for any tenant → full foreign-device control |
| Q4 GET/HEAD proof? | NO — requires valid account JWT + second tenant |
| Q5 Novel? | NO — carried forward from prior runs |
| Q6 Not rejected? | YES |
| Q7 Triager accept? | NO — no POC possible without a valid account token and a second tenant |

**Verdict: HOLD** — AUTH_HELPED only; requires valid account JWT + second tenant to prove. Code-verified via SDK (OrganizationTokenManagement.ts:29-32) but unverifiable under passive-first constraint.

---

### LEAD 6: api.signageos.io/v1/organization/{uid} — Cross-tenant OAuth client-secret disclosure
**Class:** IDOR | **Confidence:** 76 | **Source models:** bigpickle, laguna, nemotron3

| Q | Answer |
|---|--------|
| Q1 In scope? | YES — api.signageos.io |
| Q2 Reachable? | NO — requires valid account JWT |
| Q3 Real impact? | YES (if confirmed) — obtain any tenant's org API credential |
| Q4 GET/HEAD proof? | NO — requires valid account JWT + second tenant |
| Q5 Novel? | NO |
| Q6 Not rejected? | YES |
| Q7 Triager accept? | NO — no POC possible without creds + second tenant |

**Verdict: HOLD** — AUTH_HELPED only; requires valid account JWT + second tenant. Code-verified via SDK (sosControlHelper.ts:130-136).

---

### LEAD 7: api.signageos.io/v1/device/{uid}/peer-recovery — Cross-tenant read/write
**Class:** IDOR | **Confidence:** 64 | **Source models:** bigpickle, laguna, nemotron3

| Q | Answer |
|---|--------|
| Q1 In scope? | YES — api.signageos.io |
| Q2 Reachable? | NO — requires valid org X-Auth (clientId:secret) |
| Q3 Real impact? | YES (if confirmed) — overwrite peer-recovery launcher config on any tenant's devices |
| Q4 GET/HEAD proof? | NO — requires valid org X-Auth + second tenant; PUT is invasive |
| Q5 Novel? | NO |
| Q6 Not rejected? | YES |
| Q7 Triager accept? | NO — PUT violates passive-only rule |

**Verdict: HOLD** — AUTH_HELPED only; requires valid org X-Auth + second tenant. PUT also violates passive-only rule.

---

### LEAD 8: api.signageos.io/v2/* — Authz drift on partial v2 migration
**Class:** AUTH | **Confidence:** 45 | **Source models:** bigpickle, laguna, nemotron3

| Q | Answer |
|---|--------|
| Q1 In scope? | YES — api.signageos.io |
| Q2 Reachable? | NO — all /v2 routes return 403/404 without auth |
| Q3 Real impact? | UNCERTAIN — no passive evidence of drift |
| Q4 GET/HEAD proof? | NO — all routes 403/404 |
| Q5 Novel? | NO |
| Q6 Not rejected? | YES |
| Q7 Triager accept? | NO — no passive evidence |

**Verdict: HOLD** — No passive evidence; all routes 403/404. Carried forward.

---

### LEAD 9: box.signageos.io/settings — Token-generation over-scope
**Class:** AUTH | **Confidence:** 45 | **Source models:** bigpickle

| Q | Answer |
|---|--------|
| Q1 In scope? | YES — box.signageos.io |
| Q2 Reachable? | NO — requires authenticated session |
| Q3 Real impact? | UNCERTAIN — requires live inspection of token-minting XHR |
| Q4 GET/HEAD proof? | NO — requires login + devtools |
| Q5 Novel? | NO |
| Q6 Not rejected? | YES |
| Q7 Triager accept? | NO — no passive POC |

**Verdict: HOLD** — AUTH_HELPED only; requires authenticated session.

---

### LEAD 10: api.signageos.io/v1/device/{uid}/* — Device-scoped weaker auth
**Class:** AUTH | **Confidence:** 45 | **Source models:** bigpickle

| Q | Answer |
|---|--------|
| Q1 In scope? | YES — api.signageos.io |
| Q2 Reachable? | NO — all probed routes return 403 without auth |
| Q3 Real impact? | UNCERTAIN — no passive evidence |
| Q4 GET/HEAD proof? | NO — all routes 403 |
| Q5 Novel? | NO |
| Q6 Not rejected? | YES |
| Q7 Triager accept? | NO — no passive evidence |

**Verdict: HOLD** — No passive evidence.

---

### LEAD 11: api.signageos.io/v1/account/security-token — Credentials in query string
**Class:** MISCONFIG | **Confidence:** 45 | **Source models:** bigpickle

| Q | Answer |
|---|--------|
| Q1 In scope? | YES — api.signageos.io |
| Q2 Reachable? | NO — requires valid org token to observe |
| Q3 Real impact? | POSSIBLE — credentials in URL logs, but spec-documented |
| Q4 GET/HEAD proof? | NO — not passively provable |
| Q5 Novel? | NO |
| Q6 Not rejected? | YES |
| Q7 Triager accept? | NO — spec-documented behavior, not passively provable |

**Verdict: HOLD** — Spec-documented but not passively provable.

---

### LEAD 12: github.com/signageos/videowall-designer — Hardcoded secret (staging host)
**Class:** SECRET_LEAK | **Confidence:** 95 | **Source models:** nemotron3

| Q | Answer |
|---|--------|
| Q1 In scope? | NO — targets http://api.kiera.office.signageos.io (staging, out-of-scope host). Eligible targets: box.signageos.io, api.signageos.io only. |
| Q2 Reachable? | N/A |
| Q3 Real impact? | N/A — out-of-scope host |
| Q4 GET/HEAD proof? | N/A |
| Q5 Novel? | NO — already documented in KB as ACCEPTED SECRET_LEAK |
| Q6 Not rejected? | N/A |
| Q7 Triager accept? | NO — out-of-scope host |

**Verdict: INVALID** — Out-of-scope host (api.kiera.office.signageos.io). Already documented. Not directly reportable.

---

### LEAD 13: box.signageos.io/login — Auth0 redirect_uri validation bypass
**Class:** AUTH | **Confidence:** 65 | **Source models:** nemotron3, laguna

| Q | Answer |
|---|--------|
| Q1 In scope? | YES — box.signageos.io |
| Q2 Reachable? | NO — Auth0 tenant-side allowlist, not testable passively |
| Q3 Real impact? | N/A |
| Q4 GET/HEAD proof? | NO — requires Auth0 tenant config access |
| Q5 Novel? | NO |
| Q6 Not rejected? | N/A |
| Q7 Triager accept? | NO — not testable passively without tenant config access |

**Verdict: INVALID** — Not testable passively without Auth0 tenant config access. Carried forward since seed.

---

### LEAD 14: box.signageos.io/login — Login CSRF via OAuth2 state parameter
**Class:** AUTH | **Confidence:** 40 | **Source models:** nemotron3

| Q | Answer |
|---|--------|
| Q1 In scope? | YES — box.signageos.io |
| Q2 Reachable? | NO — excluded class |
| Q3 Real impact? | N/A |
| Q4 GET/HEAD proof? | NO |
| Q5 Novel? | NO |
| Q6 Not rejected? | **YES — ON REJECTED LIST** — scope.yml excludes "CSRF on forms that are available to anonymous users" |
| Q7 Triager accept? | NO — explicitly excluded |

**Verdict: INVALID** — Excluded per scope.yml ("CSRF on forms that are available to anonymous users").

---

### LEAD 15: api.signageos.io — Root JSON API via Accept header
**Class:** IDOR | **Confidence:** 50 | **Source models:** nemotron3

| Q | Answer |
|---|--------|
| Q1 In scope? | YES — api.signageos.io |
| Q2 Reachable? | NO — disproven |
| Q3 Real impact? | N/A |
| Q4 GET/HEAD proof? | NO — returns HTML regardless of headers |
| Q5 Novel? | NO |
| Q6 Not rejected? | N/A |
| Q7 Triager accept? | NO — disproven |

**Verdict: INVALID** — Disproven. api.signageos.io returns static HTML (37KB) regardless of Accept/Authorization/x-api-key headers.

---

### LEAD 16: box.signageos.io — Subdomains postMessage origin bypass
**Class:** OTHER | **Confidence:** 50 | **Source models:** nemotron3

| Q | Answer |
|---|--------|
| Q1 In scope? | YES — box.signageos.io |
| Q2 Reachable? | NO — requires authenticated session + manual iframe analysis |
| Q3 Real impact? | UNCERTAIN — no passive evidence of vulnerable listeners |
| Q4 GET/HEAD proof? | NO — requires login + devtools |
| Q5 Novel? | NO |
| Q6 Not rejected? | YES |
| Q7 Triager accept? | NO — no passive evidence; impact limited |

**Verdict: INVALID** — No passive evidence; impact limited; requires authenticated session.

---

### LEAD 17: api.signageos.io/v1/* — Descriptive error messages
**Class:** MISCONFIG | **Confidence:** 90 | **Source models:** bigpickle, laguna, nemotron3

| Q | Answer |
|---|--------|
| Q1 In scope? | YES — api.signageos.io |
| Q2 Reachable? | YES — unauthenticated probes return 403 with descriptive body |
| Q3 Real impact? | N/A — informational only |
| Q4 GET/HEAD proof? | N/A |
| Q5 Novel? | NO |
| Q6 Not rejected? | **YES — ON REJECTED LIST** — scope.yml excludes "Descriptive error messages or headers (e.g. Stack Traces, banner grabbing)" |
| Q7 Triager accept? | NO — explicitly excluded |

**Verdict: INVALID** — Excluded per scope.yml ("Descriptive error messages or headers").

---

### LEAD 18: api.signageos.io/v1/*+v2/* — Pre-auth bypass (JWT gate bypass)
**Class:** IDOR | **Confidence:** 90 | **Source models:** bigpickle, laguna, nemotron3

| Q | Answer |
|---|--------|
| Q1 In scope? | YES — api.signageos.io |
| Q2 Reachable? | NO — all endpoints solidly JWT/X-Auth-gated (403 without auth) |
| Q3 Real impact? | N/A |
| Q4 GET/HEAD proof? | NO — all routes 403 |
| Q5 Novel? | NO |
| Q6 Not rejected? | N/A |
| Q7 Triager accept? | NO — all endpoints solidly gated |

**Verdict: INVALID** — All 60+ endpoints return 403 JWT-gated. No pre-auth bypass surface found across 50+ probe cycles.

---

## SUMMARY

| # | Lead | Class | Verdict | CVSS |
|---|------|-------|---------|------|
| 1 | box.signageos.io/status — infra info disclosure | MISCONFIG | **VALID (Low)** | 4.3 |
| 2 | api.signageos.io/status — infra info disclosure | MISCONFIG | **VALID (Low)** | 4.3 |
| 3 | box.signageos.io CORS ACAO whitelist (http:// + wildcard) | MISCONFIG | **VALID (Low, border)** | 3.1 |
| 4 | box.signageos.io CSP overly broad (40+ origins) | MISCONFIG | **VALID (Info, border)** | 3.1 |
| 5 | api.../v1/organization/{uid}/security-token — cross-tenant mint | IDOR | **HOLD** | — |
| 6 | api.../v1/organization/{uid} — OAuth secret disclosure | IDOR | **HOLD** | — |
| 7 | api.../v1/device/{uid}/peer-recovery — cross-tenant r/w | IDOR | **HOLD** | — |
| 8 | api.../v2/* — authz drift | AUTH | **HOLD** | — |
| 9 | box.../settings — token over-scope | AUTH | **HOLD** | — |
| 10 | api.../v1/device/{uid}/* — device weaker auth | AUTH | **HOLD** | — |
| 11 | api.../v1/account/security-token — creds in query | MISCONFIG | **HOLD** | — |
| 12 | videowall-designer hardcoded secret (staging) | SECRET_LEAK | **INVALID** | — |
| 13 | box/login Auth0 redirect_uri bypass | AUTH | **INVALID** | — |
| 14 | box/login login CSRF (OAuth2 state) | AUTH | **INVALID** | — |
| 15 | api root JSON API via Accept header | IDOR | **INVALID** | — |
| 16 | box subdomains postMessage origin bypass | OTHER | **INVALID** | — |
| 17 | api/v1/* descriptive errors | MISCONFIG | **INVALID** | — |
| 18 | api/v1+/* pre-auth bypass | IDOR | **INVALID** | — |

**VALID: 4** | **HOLD: 7** | **INVALID: 7**

---

## KEY TAKEAWAYS

- **No new VALID findings** — all 4 valid leads are reconfirmations of previously accepted findings (50+ confirmations since 2026-08-07).
- **CVSS range:** 3.1 (Informational/Low) to 4.3 (Low). No Medium+ this cycle.
- **HOLD unblock:** One valid account JWT + second test tenant. All 7 holds share this single dependency.
- **Rejected classes hit:** Leads 14 (CSRF on anonymous form) and 17 (descriptive errors) are explicitly on scope.yml rejected list.
- **Out-of-scope:** Lead 12 (staging host) is explicitly out of scope per scope.yml asset list.
- **Disproven:** Leads 15 (Accept header) and 18 (pre-auth bypass) are fully disproven by 50+ probe cycles.
- **Reporting channel:** signageOS security channel per scope.yml (disclosure policy TBD — operator to confirm public channel before submission).

---

## RECOMMENDATION

The 4 VALID leads are stable, passively provable, and have been confirmed across 50+ triage cycles. They should be reported to the signageOS security channel once the disclosure policy is confirmed. The 7 HOLD leads require AUTH_HELPED testing (valid account JWT + second tenant) which is outside the passive-first scope of this program. No new attack surface was discovered this cycle.
