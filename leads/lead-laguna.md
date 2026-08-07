# LEADS laguna (seed)
- SEED: no model output yet.
## 2026-08-07 18:29:13 UTC [box] (model laguna)
## 2026-08-07 18:47:14 UTC [box] (model laguna)
## 2026-08-07 20:15:07 UTC [box] (model laguna)
[NEW] box.signageos.io/status: unauthenticated JSON (HTTP 200, application/json) leaking K8s pod hostname (`box-7c8c876945-gkzcp`), process UID (40-hex), Node v20.20.2, uptime, CPU/memory, and internal service topology (`amqp0`, `redis0-3`, `mongoDB0-3`)
[NEW] api.signageos.io/status: unauthenticated JSON (HTTP 200, application/json) leaking K8s pod hostname (`api-6f69db97d5-9szk2`), process UID, Node v24.19.0, service topology (redis0-3, mongoDB0-2, amqp0)
[NEW] api.signageos.io: real REST endpoints at `/v1/{device,organization,account,license,content-guard/item,location,company,bulk-operation,export/device,device/screenshot,device/telemetry/latest,...}` + `/v2/{device,firmware,logout}` — all return 403 with `{"errorName":"WRONG_JWT_TOKEN","errorCode":403105}` (JWT required)
[NEW] box.signageos.io: 18× static `access-control-allow-origin` header values on `/` (302) and `/login/` (200) — including `http://box.signageos.io` (HTTP/plaintext variant), `https://*.zdusercontent.com` (wildcard), plus sentry.io/zendesk.com/storage.googleapis.com — no `Access-Control-Allow-Credentials` observed; not Origin-reflected
[CHANGED] box.signageos.io CSP: `connect-src`/`frame-src` enlarged vs seed (additional S3 buckets + triplicated Auth0 `oauth/token` entries); CSP still ACCEPTED from seed
[PRIO] box.signageos.io/status — score **6.90**
[PRIO] box.signageos.io CORS (ACAO on `/` + `/login/`) — score **6.20**
[PRIO] api.signageos.io/v1/{...} JWT API — score **5.85**
[HYP] box.signageos.io /status Infrastructure Information Disclosure
class: MISCONFIG
asset: box.signageos.io/status
confidence: 75
reasoning: Unauthenticated GET returns application/json with pod hostname `box-7c8c876945-gkzcp`, process UID (hex), Node.js v20.20.2, and service topology `amqp0`,`redis0-3`,`mongoDB0-3`. No ACAO on this path (not browser-readable cross-origin), but directly accessible by any anonymous requester. Not a banner/stack-trace (excluded); it is a structured health endpoint exposing internal architecture.
evidence_needed: 200 application/json with `hostname` + `succeededServices` without any auth cookie/header
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 application/json containing `"hostname":"box-..."` and `"succeededServices":["amqp0","redis0",...]`
impact: Reconnaissance — internal pod hostnames, backend service names (Redis/MongoDB/AMQP), Node version, and resource metrics enable targeted SSRF enumeration and informed logic-flaw probing. Severity: Low-Medium.
testability: PASSIVE
[HYP] box.signageos.io CORS Origin Whitelist Trust-Boundary Expansion
class: MISCONFIG
asset: box.signageos.io (`/` and `/login/`)
confidence: 50
reasoning: 18 static `access-control-allow-origin` values on the login/redirect responses, including `http://box.signageos.io` (HTTP variant — defeats STS), `https://*.zdusercontent.com` (literal wildcard origin string), and third-party domains (sentry.io, zendesk.com, storage.googleapis.com, google.com/recaptcha). ACAO is static (Origin: https://evil.test yields identical list); no `Access-Control-Allow-Credentials` observed.
evidence_needed: Confirm ACAO list unchanged under spoofed Origin, and confirm absence of Allow-Credentials
verify_steps: PASSIVE: (1) GET https://box.signageos.io/ -H "Origin: https://evil.test" → ACAO list unchanged; (2) grep full headers for `Access-Control-Allow-Credentials` → absent
impact: Any script on a matching listed origin can read box signageos.io redirect/login-HTML cross-origin. The HTTP variant plus wildcard are particularly weak. Combined with CSP (already ACCEPTED), expands postMessage/origin trust boundary. Severity: Low (no credentials).
testability: PASSIVE
[HYP] api.signageos.io/v1/{device,organization,account} JWT-Gated API Cross-Tenant Access
class: IDOR
asset: api.signageos.io/v1/{...}
confidence: 30
reasoning: Client bundle (bundle.js) reveals 40+ endpoint paths on api.signageos.io (e.g., /v1/device, /v1/organization, /v1/account, /v1/license). All return 403 without JWT (errorName WRONG_JWT_TOKEN / 403105). Cannot test IDOR scope without a valid token — blocked under passive-first constraint.
evidence_needed: Valid JWT + proof that /v1/device/{uid} returns a non-owned organization's data
verify_steps: AUTH_HELPED: GET https://api.signageos.io/v1/device/{targetUid} -H "Authorization: Bearer <jwt>" → compare organizationUid in response body vs own tenant
impact: Read/cross-tenant access to devices, organizations, accounts, content. Severity: High-Critical (if exploitable).
testability: AUTH_HELPED
[PARKED] box.signageos.io CORS ACAO — confidence 50 ≥ 40, not on REJECTED list. KEPT but ranked last: static (not reflected), no Allow-Credentials, only covers login/redirect HTML (not /status JSON). Limited direct exploitation without a foothold on a listed third-party origin.
[PARKED] api.signageos.io/v1/{device,organization,account} Cross-Tenant IDOR — confidence 30 < 40. DROPPED. All endpoints return 403 JWT-required; no unauthenticated bypass found. Requires valid token (AUTH_HELPED) — not available under passive-first ≤1 rps GET/HEAD constraint. Endpoint map confirmed but auth gate is solid via passive probes.
[FINAL] (re-ranked, top first):
[NEXT] RAG: Clone `github.com/signageos/sdk` and grep for: (1) `apiBase`/`baseUrl`/`API_URL` constants → full endpoint paths; (2) `Authorization` header construction (Bearer JWT vs API key vs SigV4) → auth-bypass opportunities; (3) any fetch/axios calls to `/v1/...` paths invoked WITHOUT a token (pre-auth endpoints). Focus on `src/api/`, `src/auth/`, `lib/` subdirs.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed NEW. Unauthenticated JSON health endpoint leaks K8s pod hostname, process UID, Node version, and backend service topology (redis0-3, mongoDB0-3, amqp0). Not on the rejected list (not banner/stack-trace, not file/dir disclosure, not outdated-version-only).
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CORS: Confirmed NEW. 18× static `access-control-allow-origin` headers (incl `http://` HTTP variant + `https://*.zdusercontent.com` wildcard) on `/` and `/login/`. No `Access-Control-Allow-Credentials` observed. Not on the rejected list.
[LEARN] REJECTED IDOR @ api.signageos.io: Real `/v1/*` endpoints confirmed via client bundle (bundle.js) — 40+ paths mapped. BUT all return 403 with `WRONG_JWT_TOKEN`/`403105` without a JWT. No unauthenticated data access found → IDOR not testable passively. The earlier seed rejection ("all common paths 404") was based on probing wrong paths (`/api/v1`, `/v1`) that don't exist; the real paths DO exist but are JWT-gated.
[LEARN] REJECTED MISCONFIG @ api.signageos.io: 403 error body leaks descriptive auth detail (`"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 403105`, `errorName WRONG_JWT_TOKEN`) — falls under "descriptive error messages" (excluded per scope.yml).
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation — still not testable passively without tenant config access (carried forward).
[LEARN] REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state — excluded per "CSRF on anonymous-accessible forms" (carried forward).
[RISK] box.signageos.io: 60 — Unauthenticated /status leak (K8s hostnames + backend service topology: Redis/MongoDB/AMQP), CORS ACAO whitelist including HTTP variant + wildcard Zendesk, broad CSP connect-src/frame-src (ACCEPTED). Login flow behind Auth0 redirect (302 → /login). All non-/status paths redirect to login. Moderate operational-exposure, limited direct data access.
[RISK] api.signageos.io: 48 — Unauthenticated /status leak (pod hostname + service topology), but all `/v1/*` JWT endpoints return 403 (auth gate solid via passive probing). Root serves static HTML landing (no JSON API without JWT). No CORS ACAO observed on API responses (CORS ACAO only on box). Lower data-exposure risk than box; main concern is infra recon aid.
## 2026-08-07 21:04:35 UTC [box] (model laguna)
[PRIO] box.signageos.io/status: **7.95**
[PRIO] box.signageos.io CORS ACAO (/ + /login/): **7.15**
[PRIO] box.signageos.io CSP (broad connect-src/frame-src, 40+ origins): **5.50**
[PRIO] api.signageos.io/status: **7.95** (parallel to box /status)
[PRIO] api.signageos.io /v1/*+v2/* JWT-gated API: **7.45** — AUTH_HELPED, not passively testable
[HYP] box.signageos.io/status: Unauthenticated Infrastructure Information Disclosure
class: MISCONFIG
asset: box.signageos.io/status
confidence: 90
reasoning: Unauthenticated GET (no auth cookie/header) returns application/json with live K8s pod hostname (box-7c8c876945-mtnct), 40-hex process UID, Node.js v20.20.2, uptime, CPU/memory metrics, and internal service topology (amqp0, redis0-3, mongoDB0-3). Pod hostname rotates across requests (gkzcp → mtnct observed), confirming it reflects live runtime state. Not banner/stack-trace (excluded); it is a structured health endpoint.
evidence_needed: 200 application/json with hostname + succeededServices without any auth header
verify_steps: PASSIVE: `GET https://box.signageos.io/status` → 200 application/json containing `"hostname":"box-7c8c876945-..."` and `"succeededServices":["amqp0","redis0",...]`; no cookie/header required
impact: Reconnaissance — pod hostnames, backend service names (Redis/MongoDB/AMQP), Node version, and resource metrics enable targeted SSRF enumeration and informed logic-flaw probing. Severity: Low-Medium.
testability: PASSIVE
[HYP] box.signageos.io CORS ACAO Whitelist Trust-Boundary Expansion
class: MISCONFIG
asset: box.signageos.io (/ and /login/)
confidence: 60
reasoning: 18 static access-control-allow-origin values on the login/redirect responses, including `http://box.signageos.io` (HTTP variant — defeats HSTS for CORS reads), `https://*.zdusercontent.com` (literal wildcard origin string), and sibling origin `https://api.signageos.io`. ACAO is static (Origin: https://evil.test yields identical 18-value list); no `Access-Control-Allow-Credentials` observed.
evidence_needed: ACAO list unchanged under spoofed Origin; absence of Allow-Credentials
verify_steps: PASSIVE: (1) `GET https://box.signageos.io/ -H "Origin: https://evil.test"` → 18 static ACAO values (unchanged); (2) grep full response headers for `Access-Control-Allow-Credentials` → absent
impact: Any JS on a listed origin (e.g., compromised `*.zdusercontent.com` subdomain, or `api.signageos.io`-origin script) can read box's unauthenticated login/redirect HTML. The HTTP variant + wildcard are weak points. Severity: Low (no credentials).
testability: PASSIVE
[HYP] box.signageos.io CSP Overly Broad connect-src/frame-src Trust Boundary
class: MISCONFIG
asset: box.signageos.io (/login/)
confidence: 75
reasoning: CSP on /login/ response includes 40+ origins in connect-src/frame-src: Auth0 (sos-production.us.auth0.com, auth0.signageos.io), third-party device APIs (Sony, BroadSign, MoodMedia), S3 buckets (signageos-public, signageos-device-monitoring, signageos-device-bulk-provisioning-parser, signageos-user-data-exports), AWS API Gateway (qwfin59thg.execute-api.eu-central-1.amazonaws.com), and sibling origin api.signageos.io. /login/ CSP is broader than / (triplicated Auth0 oauth/token entries, additional recaptcha frame-src).
evidence_needed: CSP header on /login/ containing 40+ distinct origins in connect-src/frame-src
verify_steps: PASSIVE: `GET https://box.signageos.io/login/%2F` → inspect `content-security-policy` header → count distinct origins in connect-src directive
impact: Overly broad CSP expands implicit trust boundary — any XSS within box's own origin can exfiltrate to or interact with all listed origins, and any compromised listed origin gains elevated communication privileges. Severity: Low-Medium.
testability: PASSIVE
[HYP] box.signageos.io/status: confidence 90 ≥ 40, MISCONFIG not on REJECTED list, concrete verify_steps. **KEEP.**
[HYP] box.signageos.io CORS ACAO: confidence 60 ≥ 40, MISCONFIG not on REJECTED list, concrete verify_steps. **KEEP.** (Impact limited — no Allow-Credentials; only unauthenticated HTML readable. Ranked accordingly.)
[HYP] box.signageos.io CSP: confidence 75 ≥ 40, MISCONFIG not on REJECTED list, concrete verify_steps. **KEEP.** (Requires co-located XSS to fully exploit; ranked last among box hypotheses.)
[FINAL] (re-ranked, top first):
[NEXT] RAG: Clone `github.com/signageos/sdk`, grep `src/api/` + `src/auth/` for (1) any `/v1/` or `/v2/` endpoint invoked WITHOUT JWT/X-Auth at initialization (pre-auth bypass candidate), and (2) the `unsafeDecryptedToken` construction used in X-Auth for bulk provisioning — determine if the bulk-provisioning upload endpoint accepts X-Auth with a derivable client-side key, bypassing the JWT gate on api.signageos.io and enabling unauthenticated access to the 60+ mapped endpoints.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname (rotating: gkzcp → mtnct), process UID, Node v20.20.2, and service topology (amqp0, redis0-3, mongoDB0-3). Not on rejected list.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CORS: Confirmed live. 18 static ACAO values on / (302) + /login/ (200), unchanged under spoofed Origin `https://evil.test`. Includes `http://` variant + `https://*.zdusercontent.com` wildcard + sibling `api.signageos.io`. No `Access-Control-Allow-Credentials` on any box path. api.signageos.io has NO ACAO on any path (including /status, /v1/*, /v2/*).
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CSP: Confirmed live. /login/ CSP broadened vs / (triplicated Auth0 oauth/token, additional recaptcha frame-src). 40+ connect-src/frame-src origins spanning Auth0, Sony/BroadSign/MoodMedia device APIs, S3 buckets, AWS API Gateway, and api.signageos.io.
[LEARN] REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 `OK` (2 bytes) — trivial health check, no data leaked. Not reportable.
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All 60+ endpoints return 403 JWT-gated (WRONG_JWT_TOKEN/403105). No pre-auth bypass. Dual auth confirmed: JWT Bearer (main API) + X-Auth API-key format (`id:unsafeDecryptedToken`) for bulk provisioning.
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: 403/404 carry `vary: Origin` + `access-control-expose-headers: *` but NO ACAO under any Origin — not CORS-exploitable.
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation — not testable passively without tenant config access (carried forward).
[LEARN] REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state — excluded per "CSRF on anonymous-accessible forms" (carried forward).
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 403105` — falls under descriptive error messages (excluded).
[RISK] box.signageos.io: **58** — Unauthenticated `/status` info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl HTTP variant + zdusercontent wildcard); broad CSP (40+ origins). Everything except `/status`, `/login/`, `/ready`, `/assets/*` redirects to Auth0 login. Moderate operational exposure, no direct data access without credentials.
[RISK] api.signageos.io: **47** — Unauthenticated `/status` info leak (pod hostname + service topology); 60+ `/v1/*`+`/`v2/*` endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on `/`. Lower data-exposure risk — main concern is infra recon aid for the JWT-gated high-value API (devices, organizations, accounts, content).
