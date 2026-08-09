# TRIAGE REPORT — signageOS Bug Bounty

**Date:** 2026-08-09
**Triager:** strict-triage
**Program:** signageOS Bug Bounty (scope.yml)
**Scope Assets:** box.signageos.io, api.signageos.io

---

## UNIQUE LEADS IDENTIFIED

After deduplication across 5 models (bigpickle, laguna, ling3, longcat, nemotron3), the following unique leads emerge:

---

### LEAD 1: box.signageos.io/status — Unauthenticated Infrastructure Information Disclosure

**Finding:** Unauthenticated GET /status returns application/json leaking live K8s pod hostname (rotating: box-7c8c876945-*), 40-hex process UID, Node.js version (v20.20.2), uptime, CPU/memory metrics, and internal service topology (amqp0, redis0-3, mongoDB0-3) with per-service response times.

| Question | Answer |
|----------|--------|
| Q1 In scope? | **YES** — box.signageos.io is in-scope asset |
| Q2 Reachable? | **YES** — unauthenticated, public GET |
| Q3 Real impact? | **YES** — Low-Medium. Structured health data enables targeted SSRF enumeration, informed logic-flaw probing, and infrastructure mapping. Not directly exploitable but reduces attacker effort. |
| Q4 Passive proof? | **YES** — GET https://box.signageos.io/status → 200 application/json with hostname + succeededServices + process.uid + version |
| Q5 Novel? | **YES** — first report (found by multiple models, same finding) |
| Q6 Not rejected? | **YES** — not banner/stack-trace, not robots.txt, not outdated-version-only. Structured health endpoint is distinct from excluded categories. |
| Q7 Acceptable? | **YES** — reasonable triager accepts as Low-severity MISCONFIG |

**Verdict: VALID (Low)**

**Minimal read-only proof:**
1. `curl -s https://box.signageos.io/status`
2. Observe HTTP 200 application/json with no auth headers
3. Document: `hostname`, `process.uid`, `process.version`, `succeededServices` array

**Impact:** Reconnaissance — internal pod hostnames, backend service names (Redis/MongoDB/AMQP), Node version, and per-service response-time metrics enable targeted SSRF enumeration and informed logic-flaw probing.

**CVSS 3.1:** 5.3 (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N) — Medium-Low

**Reporting channel:** signageOS security channel per scope.yml (disclosure_policy: TBD — operator-provided; report via program's designated channel once confirmed)

---

### LEAD 2: box.signageos.io CORS ACAO Whitelist — Static 18-Origin Trust Boundary

**Finding:** GET / (302) and /login/ (200) return 18 static `access-control-allow-origin` values including `http://box.signageos.io` (HTTP plaintext variant) and `https://*.zdusercontent.com` (wildcard). No `Access-Control-Allow-Credentials` on any box path.

| Question | Answer |
|----------|--------|
| Q1 In scope? | **YES** — box.signageos.io |
| Q2 Reachable? | **YES** — public |
| Q3 Real impact? | **NO** — Static (not reflected) ACAO without Allow-Credentials. Only covers public login/redirect HTML. No credential theft possible. |
| Q4 Passive proof? | **YES** — GET with Origin header shows static list |
| Q5 Novel? | **YES** |
| Q6 Not rejected? | Borderline — CORS misconfiguration is not explicitly excluded, but impact is negligible |
| Q7 Acceptable? | **NO** — reasonable triager rejects: static ACAO + no credentials + public HTML = no actionable impact |

**Verdict: INVALID** — Static ACAO without Allow-Credentials has minimal security impact; only covers already-public login/redirect HTML. No credential theft or data exposure possible.

---

### LEAD 3: box.signageos.io CSP — Overly Broad connect-src/frame-src

**Finding:** /login/ CSP contains 40+ origins in connect-src/frame-src directives spanning Auth0, Sony/BroadSign/MoodMedia device APIs, S3 buckets, AWS API Gateway, and api.signageos.io.

| Question | Answer |
|----------|--------|
| Q1 In scope? | **YES** — box.signageos.io |
| Q2 Reachable? | **YES** — CSP header visible in response |
| Q3 Real impact? | **BORDERLINE** — expands trust boundary but requires co-located XSS to exploit |
| Q4 Passive proof? | **YES** — GET /login/%2F → inspect Content-Security-Policy header |
| Q5 Novel? | **YES** |
| Q6 Not rejected? | **YES** — CSP issues not on rejected list |
| Q7 Acceptable? | **BORDERLINE** — most triagers treat as informational; requires XSS to be actionable |

**Verdict: HOLD** — Overly broad CSP requires co-located XSS to exploit; informational severity. Defer until/unless XSS is found. Not reportable as standalone.

---

### LEAD 4: Cross-Tenant IDOR Family (api.signageos.io)

**Findings (4 variants):**
- H1: Cross-tenant org OAuth client-secret disclosure via account token (GET /v1/organization/{uid})
- H2: Cross-tenant org security-token minting (GET/POST /v1/organization/{uid}/security-token)
- H3: Cross-tenant device peer-recovery read/write (GET/PUT /v1/device/{uid}/peer-recovery)
- H4: Cross-tenant IDOR via organizationUid parameter on listing endpoints

| Question | Answer |
|----------|--------|
| Q1 In scope? | **YES** — api.signageos.io |
| Q2 Reachable? | **CONDITIONAL** — requires valid JWT or X-Auth token (low-priv account) |
| Q3 Real impact? | **YES** — CRITICAL if exploitable (cross-tenant data/control) |
| Q4 Passive proof? | **NO** — all endpoints return 403 without auth. Requires AUTH_HELPED testing with valid token. |
| Q5 Novel? | **YES** |
| Q6 Not rejected? | **YES** — IDOR not on rejected list |
| Q7 Acceptable? | **YES** — if proven with POC |

**Verdict: HOLD** — Credible high-impact hypotheses but cannot be proven with passive GET/HEAD only. All /v1/* and /v2/* endpoints return 403 JWT-gated (WRONG_JWT_TOKEN/403105). Requires AUTH_HELPED verification (valid account token + second test tenant). Per program rules (passive_first: true, no_account_creation: true), invasive testing requires program approval.

**Next step:** Request program approval for AUTH_HELPED testing with own account, or obtain test credentials from program.

---

### LEAD 5: v2 API Partial-Migration Authz Drift

**Finding:** /v2/device is JWT-gated (403 WRONG_JWT) but /v2/account and /v2/organization are 404. Hypothesis: migrated code paths may diverge on authorization.

| Question | Answer |
|----------|--------|
| Q1 In scope? | **YES** — api.signageos.io |
| Q2 Reachable? | N/A — no alternate auth path found |
| Q3 Real impact? | **UNPROVEN** — no evidence of drift |
| Q4 Passive proof? | **NO** — all probed /v2 routes return 403 or 404 as expected |
| Q5 Novel? | **YES** |
| Q6 Not rejected? | **YES** |
| Q7 Acceptable? | **NO** — no evidence of actual drift |

**Verdict: INVALID** — No evidence of authz drift found; all probed /v2 routes return expected 403/404 responses. Pure speculation without POC.

---

### LEAD 6: Hardcoded Credentials in videowall-designer (Public Repo)

**Finding:** Hardcoded clientId/secret in `signageos/videowall-designer/sos/videoTiming.js` targeting internal staging `http://api.kiera.office.signageos.io` over HTTP.

| Question | Answer |
|----------|--------|
| Q1 In scope? | **NO** — target is api.kiera.office.signageos.io, not in scope |
| Q2 Reachable? | N/A |
| Q3 Real impact? | Credential reuse risk, but target is out-of-scope |
| Q4 Passive proof? | **YES** — found in public repo |
| Q5 Novel? | **NO** — already triaged as duplicate (2026-08-07) |
| Q6 Not rejected? | N/A — out of scope |
| Q7 Acceptable? | **NO** — out-of-scope host |

**Verdict: INVALID** — Target (api.kiera.office.signageos.io) is out of scope. Already triaged as ACCEPTED SECRET_LEAK but not directly reportable per program scope. Credential reuse risk noted for prod org-boundary testing context.

---

### LEAD 7: Auth0 redirect_uri Validation Bypass (box.signageos.io/login)

**Finding:** Hypothesis that Auth0 OAuth2 redirect_uri parameter may be improperly validated, enabling OAuth code theft.

| Question | Answer |
|----------|--------|
| Q1 In scope? | **YES** — box.signageos.io |
| Q2 Reachable? | **NO** — requires Auth0 tenant interaction |
| Q3 Real impact? | HIGH if exploitable |
| Q4 Passive proof? | **NO** — not testable passively without Auth0 tenant config access |
| Q5 Novel? | **YES** |
| Q6 Not rejected? | **YES** |
| Q7 Acceptable? | **NO** — no passive POC possible |

**Verdict: INVALID** — Not testable passively without Auth0 tenant config access. Already rejected in prior analysis. Requires active OAuth flow manipulation which violates passive-first constraint.

---

### LEAD 8: Login CSRF via OAuth2 State Parameter

**Finding:** Hypothesis that OAuth2 state parameter is not cryptographically bound to session, enabling login CSRF.

| Question | Answer |
|----------|--------|
| Q1 In scope? | **YES** — box.signageos.io |
| Q2 Reachable? | **YES** — login form is anonymous-accessible |
| Q3 Real impact? | HIGH if exploitable |
| Q4 Passive proof? | Partially — can observe flow but full validation requires Auth0 interaction |
| Q5 Novel? | **YES** |
| Q6 Not rejected? | **NO** — explicitly excluded: "CSRF on forms that are available to anonymous users" |
| Q7 Acceptable? | **NO** — explicitly excluded per scope.yml |

**Verdict: INVALID** — Explicitly excluded per scope.yml "CSRF on forms that are available to anonymous users".

---

### LEAD 9: Descriptive Error Messages on api.signageos.io

**Finding:** 403 error body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, errorCode 403105.

| Question | Answer |
|----------|--------|
| Q1 In scope? | **YES** — api.signageos.io |
| Q2 Reachable? | **YES** — public |
| Q3 Real impact? | LOW — informational only |
| Q4 Passive proof? | **YES** |
| Q5 Novel? | **YES** |
| Q6 Not rejected? | **NO** — explicitly excluded: "Descriptive error messages or headers" |
| Q7 Acceptable? | **NO** — explicitly excluded per scope.yml |

**Verdict: INVALID** — Explicitly excluded per scope.yml "Descriptive error messages or headers (e.g. Stack Traces, banner grabbing)".

---

### LEAD 10: box.signageos.io/ready — Trivial Health Check

**Finding:** Returns 200 "OK" (2 bytes).

| Question | Answer |
|----------|--------|
| Q1 In scope? | **YES** |
| Q2 Reachable? | **YES** |
| Q3 Real impact? | **NONE** — trivial health check, no data leaked |
| Q4 Passive proof? | **YES** |
| Q5 Novel? | N/A |
| Q6 Not rejected? | N/A — no impact |
| Q7 Acceptable? | **NO** |

**Verdict: INVALID** — Trivial health check with no data leakage; no security impact.

---

## SUMMARY

| Lead | Verdict | Severity | Reason |
|------|---------|----------|--------|
| 1. box.signageos.io/status info leak | **VALID** | Low (5.3) | Unauthenticated infra disclosure; passive proof |
| 2. box.signageos.io CORS ACAO | **INVALID** | — | Static, no credentials, public HTML only |
| 3. box.signageos.io CSP broad | **HOLD** | — | Requires XSS; informational |
| 4. Cross-tenant IDOR family | **HOLD** | — | AUTH_HELPED only; needs program approval |
| 5. v2 authz drift | **INVALID** | — | No evidence; speculation |
| 6. Hardcoded creds (videowall) | **INVALID** | — | Out-of-scope host; duplicate |
| 7. Auth0 redirect_uri bypass | **INVALID** | — | Not testable passively |
| 8. Login CSRF (OAuth state) | **INVALID** | — | Excluded per scope.yml |
| 9. Descriptive error messages | **INVALID** | — | Excluded per scope.yml |
| 10. /ready health check | **INVALID** | — | No impact |

**Actionable findings:** 1 VALID, 2 HOLD, 7 INVALID

**Recommended next steps:**
1. Submit Lead 1 (box.status info leak) to signageOS security channel
2. Request program approval for AUTH_HELPED testing of Lead 4 (cross-tenant IDOR)
3. Deprioritize Lead 3 (CSP) unless XSS is discovered
