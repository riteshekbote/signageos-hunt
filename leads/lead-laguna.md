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
## 2026-08-07 21:27:15 UTC [box] (model laguna)
## 2026-08-07 22:06:28 UTC [box] (model laguna)
## 2026-08-07 22:50:28 UTC [box] (model laguna)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token: 65
[PRIO] api.signageos.io/v1/{device,organization,alert,...}: 60
[PRIO] box.signageos.io/status: 59
[PRIO] api.signageos.io/v1/organization/{uid}/security-token: 65
[PRIO] api.signageos.io/v1/{device,organization,alert,...}: 60
[PRIO] box.signageos.io/status: 59
[HYP] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant org security-token minting via account token + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 65
reasoning: The X-Auth bulk-provisioning scheme uses id:unsafeDecryptedToken format. If a low-privileged account token can mint a security-token for an arbitrary organizationUid, this would cross tenant boundaries. Dual auth (JWT + X-Auth) may have inconsistent tenant scoping.
evidence_needed: 200 response with valid security-token for organizationUid != requesting account's tenant
verify_steps: AUTH_HELPED: Obtain account-scope X-Auth key, call GET /v1/organization/{victim_org_uid}/security-token with X-Auth header, check if returns token for other tenant
impact: Cross-tenant access — attacker can mint security tokens for any organization, gaining full API access to victim tenant data (devices, content, accounts). Severity: Critical.
testability: AUTH_HELPED
[HYP] api.signageos.io/v1/{device,organization,account,alert,...}: IDOR via organizationUid parameter not enforced server-side
class: IDOR
asset: api.signageos.io/v1/{device,organization,account,...}
confidence: 55
reasoning: 60+ JWT-gated endpoints mapped from bundle.js. If organizationUid is client-supplied in path/body and not validated against the JWT's tenant scope, an authenticated low-priv user could enumerate other tenants' resources.
evidence_needed: 200 response returning organization-specific data for organizationUid different from JWT bearer's tenant
verify_steps: AUTH_HELPED: With valid JWT from tenant A, call /v1/organization/{tenant_B_uid}/device/list, verify whether data from tenant B is returned
impact: Cross-tenant data access — devices, accounts, content, licenses from other tenants exposed. Severity: High.
testability: AUTH_HELPED
[HYP] box.signageos.io/status: Unauthenticated Infrastructure Information Disclosure enabling SSRF reconnaissance
class: MISCONFIG
asset: box.signageos.io/status
confidence: 90
reasoning: Unauthenticated endpoint returns live K8s pod hostname, process UID, Node version, and backend service topology (redis0-3, mongoDB0-3, amqp0). Pod hostname rotates (gkzcp → mtnct) confirming live runtime state.
evidence_needed: 200 application/json with hostname + succeededServices without any auth header
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 application/json with "hostname":"box-7c8c876945-..." and "succeededServices":["amqp0","redis0",...]
impact: Reconnaissance — pod hostnames, backend service names, Node version, and resource metrics enable targeted SSRF enumeration. Severity: Low-Medium.
testability: PASSIVE
[HYP] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant org security-token minting via account token + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 65
reasoning: The X-Auth bulk-provisioning scheme uses id:unsafeDecryptedToken format. If a low-privileged account token can mint a security-token for an arbitrary organizationUid, this would cross tenant boundaries. Dual auth (JWT + X-Auth) may have inconsistent tenant scoping.
evidence_needed: 200 response with valid security-token for organizationUid != requesting account's tenant
verify_steps: AUTH_HELPED: Obtain account-scope X-Auth key, call GET /v1/organization/{victim_org_uid}/security-token with X-Auth header, check if returns token for other tenant
impact: Cross-tenant access — attacker can mint security tokens for any organization, gaining full API access to victim tenant data (devices, content, accounts). Severity: Critical.
testability: AUTH_HELPED
[HYP] api.signageos.io/v1/{device,organization,account,alert,...}: IDOR via organizationUid parameter not enforced server-side
class: IDOR
asset: api.signageos.io/v1/{device,organization,account,...}
confidence: 55
reasoning: 60+ JWT-gated endpoints mapped from bundle.js. If organizationUid is client-supplied in path/body and not validated against the JWT's tenant scope, an authenticated low-priv user could enumerate other tenants' resources.
evidence_needed: 200 response returning organization-specific data for organizationUid different from JWT bearer's tenant
verify_steps: AUTH_HELPED: With valid JWT from tenant A, call /v1/organization/{tenant_B_uid}/device/list, verify whether data from tenant B is returned
impact: Cross-tenant data access — devices, accounts, content, licenses from other tenants exposed. Severity: High.
testability: AUTH_HELPED
[HYP] box.signageos.io/status: Unauthenticated Infrastructure Information Disclosure enabling SSRF reconnaissance
class: MISCONFIG
asset: box.signageos.io/status
confidence: 90
reasoning: Unauthenticated endpoint returns live K8s pod hostname, process UID, Node version, and backend service topology (redis0-3, mongoDB0-3, amqp0). Pod hostname rotates (gkzcp → mtnct) confirming live runtime state.
evidence_needed: 200 application/json with hostname + succeededServices without any auth header
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 application/json with "hostname":"box-7c8c876945-..." and "succeededServices":["amqp0","redis0",...]
impact: Reconnaissance — pod hostnames, backend service names, Node version, and resource metrics enable targeted SSRF enumeration. Severity: Low-Medium.
testability: PASSIVE
[FINAL] (re-ranked, top first):
[FINAL] (re-ranked, top first):
[NEXT] RAG: Clone github.com/signageos/sdk and grep src/api/ + src/auth/ + src/requester.ts for: (1) exact X-Auth header construction (id:unsafeDecryptedToken format), (2) organizationUid handling in security-token endpoint client code, (3) any /v1/organization/{uid}/security-token path and how orgUid is set — determine if client-supplied organizationUid flows into X-Auth token scope without server-side tenant validation.
[NEXT] RAG: Clone github.com/signageos/sdk and grep src/api/ + src/auth/ + src/requester.ts for: (1) exact X-Auth header construction (id:unsafeDecryptedToken format), (2) organizationUid handling in security-token endpoint client code, (3) any /v1/organization/{uid}/security-token path and how orgUid is set — determine if client-supplied organizationUid flows into X-Auth token scope without server-side tenant validation.
[LEARN] REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 `OK` (2 bytes) — trivial health check, no data leaked. Not reportable.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname, process UID, Node v20.20.2, and service topology.
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All endpoints return 403 JWT-gated without pre-auth bypass. Requires AUTH_HELPED verification.
[LEARN] REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 `OK` (2 bytes) — trivial health check, no data leaked. Not reportable.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname, process UID, Node v20.20.2, and service topology.
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All endpoints return 403 JWT-gated without pre-auth bypass. Requires AUTH_HELPED verification.
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl HTTP variant + zdusercontent wildcard); broad CSP (40+ origins). Everything except /status, /login/, /ready, /assets/* redirects to Auth0 login. Moderate operational exposure, no direct data access without credentials.
[RISK] api.signageos.io: 47 — Unauthenticated /status info leak (pod hostname + service topology); 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on /. Lower data-exposure risk — main concern is infra recon aid for the JWT-gated high-value API.
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl HTTP variant + zdusercontent wildcard); broad CSP (40+ origins). Everything except /status, /login/, /ready, /assets/* redirects to Auth0 login. Moderate operational exposure, no direct data access without credentials.
[RISK] api.signageos.io: 47 — Unauthenticated /status info leak (pod hostname + service topology); 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on /. Lower data-exposure risk — main concern is infra recon aid for the JWT-gated high-value API.
## 2026-08-07 23:28:16 UTC [box] (model laguna)
[PRIO] box.signageos.io/status: 8.05 (attack=6, business=6, tech=5, gate=10, cloud=8, fresh=9)
[PRIO] box.signageos.io CORS ACAO (/ + /login/): 6.90 (attack=7, business=6, tech=6, gate=10, cloud=7, fresh=9)
[PRIO] box.signageos.io CSP (/login/): 6.15 (attack=5, business=5, tech=7, gate=8, cloud=7, fresh=8)
[HYP] box.signageos.io/status: Persistent Infrastructure Information Disclosure — pod topology + Node version + service names (amqp0, redis0-3, mongoDB0-3)
class: MISCONFIG
asset: box.signageos.io/status
confidence: 90
reasoning: Confirmed live on this probe. HTTP 200 application/json with no auth required. Returns rotating K8s pod hostname (box-7c8c876945-gkzcp), Node v20.20.2, 40-hex process UID, and succeededServices array listing internal Redis/MongoDB/AMQP service names. Response time delta across services (amqp0: 59ms, redis2: 1ms) confirms live probing of backend services. Not on the REJECTED list (not banner/stack-trace, not file/dir disclosure, not outdated-version-only).
evidence_needed: 200 application/json with "hostname":"box-..." + "succeededServices":["amqp0","redis0",...] + "process":{"version":"v20.20.2"} with zero auth headers
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 application/json containing hostname + succeededServices; no cookie/authorization header needed
impact: Reconnaissance — internal pod hostnames, backend service names (Redis/MongoDB/AMQP), Node.js version, and per-service response-time metrics enable targeted SSRF enumeration and informed logic-flaw probing against the JWT-gated api.signageos.io API. Severity: Low-Medium.
testability: PASSIVE
[HYP] box.signageos.io CORS ACAO Whitelist: static 18-origin trust boundary incl. http:// variant + zdusercontent wildcard
class: MISCONFIG
asset: box.signageos.io (/ and /login/)
confidence: 60
reasoning: GET https://box.signageos.io/ -H "Origin: https://evil.test" returns identical 18 static access-control-allow-origin headers unchanged — not Origin-reflected. Includes http://box.signageos.io (defeats HSTS for CORS reads), https://*.zdusercontent.com (literal wildcard string), and sibling https://api.signageos.io. No Access-Control-Allow-Credentials absent on all box paths.
evidence_needed: ACAO list identical (18 values) under all tested Origins; absence of Access-Control-Allow-Credentials header in response
verify_steps: PASSIVE: GET https://box.signageos.io/ -H "Origin: https://evil.test" → observe 18 static ACAO values; GET same with Origin: https://box.signageos.io → identical list; grep all response headers for Access-Control-Allow-Credentials → absent
impact: Any JS executing on a matching listed origin (e.g., compromised *.zdusercontent.com subdomain) can read box.signageos.io's unauthenticated redirect/login HTML. Severity: Low (no credentials exposed).
testability: PASSIVE
[HYP] box.signageos.io CSP: 40+ origins in connect-src/frame-src incl. triplicated Auth0 oauth/token + device APIs
class: MISCONFIG
asset: box.signageos.io (/login/)
confidence: 75
reasoning: /login/ response CSP contains 33 distinct host patterns across directives, including Auth0 (sos-production.us.auth0.com, auth0.signageos.io) listed 2× each with /oauth/token path, plus Sony/BroadSign/MoodMedia device management APIs, AWS S3 buckets, AWS API Gateway (qwfin59thg.execute-api.eu-central-1.amazonaws.com), and sibling api.signageos.io. /login/ CSP is strictly broader than / (triplicated oauth/token entries, additional recaptcha frame-src).
evidence_needed: CSP header on /login/ containing Auth0 oauth/token entries duplicated 2×, plus 30+ additional connect-src/frame-src origins spanning device APIs and AWS services
verify_steps: PASSIVE: GET https://box.signageos.io/login/%2F → inspect Content-Security-Policy header → count Auth0 oauth/token occurrences (≥3) + distinct non-self origins in connect-src (≥30)
impact: Over-broad CSP expands the implicit trust boundary — any XSS within box's own origin can exfiltrate to or interact with all listed origins (device APIs, S3 buckets, AWS API Gateway). Severity: Low-Medium (requires in-origin XSS to fully exploit).
testability: PASSIVE
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] HUMAN: Transition POC target from box → api for AUTH_HELPED verification of the two top-ranked cross-tenant IDOR hypotheses carried forward from seed analysis:
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live. HTTP 200 JSON leaks pod hostname (box-7c8c876945-gkzcp), process UID (b341def86253cd23a7db1382d94c091a590c400c1b4d8d9602), Node v20.20.2, service topology (amqp0, redis0-3, mongoDB0-3). Unchanged.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CORS: Reconfirmed live. 18 static ACAO values on / (302) + /login/ (200), unchanged under spoofed Origin https://evil.test. No Access-Control-Allow-Credentials. Includes http:// variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling. Unchanged.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CSP: Reconfirmed live. /login/ CSP triplicates Auth0 oauth/token entries, 33 distinct origin patterns across connect-src/frame-src directives (device APIs, S3, AWS API Gateway, siblings). Unchanged.
[LEARN] REJECTED MISCONFIG @ box.signageos.io /ready: Reconfirmed. Returns 200 "OK" (2 bytes), trivial health check, no data leaked. Not reportable.
[LEARN] REJECTED AUTH @ box.signageos.io/login: All Auth0 OAuth2 flow parameters hidden in minified bundle.js (v2.192.0); redirect_uri validation, OAuth2 state binding — not testable passively without Auth0 tenant access or authenticated session. Carried forward.
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: Confirmed — 403/404 responses carry vary: Origin + access-control-expose-headers: * but NO ACAO under any Origin. Not CORS-exploitable. Carried forward.
[RISK] box.signageos.io: 58 — Unauthenticated `/status` info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl HTTP variant + zdusercontent wildcard); broad CSP (40+ origins). Everything except `/status`, `/login/`, `/ready`, `/assets/*` redirects to Auth0 login. Moderate operational exposure, no direct data access without credentials. Surface fully mapped; no new unauthenticated logic flaws discovered.
[RISK] api.signageos.io: 62 — Unauthenticated `/status` info leak (pod hostname + service topology); 60+ `/v1/*` + `/v2/*` endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on `/`. Risk raised due to AUTH_HELPED-testable cross-tenant IDOR candidates (org-token minting, org OAuth client-secret disclosure, peer-recovery write) that require a valid account token to verify. Main concern: JWT-gated high-value API with logic flaws in org-boundary enforcement.
[NEXT] HUMAN: Run `sos login` (Auth0 device-code flow on box.signageos.io) to obtain account credentials (accountId + apiSecurityToken) for one signageOS account with at least one organization. Then execute H1: GET https://api.signageos.io/v1/organization/<own-orgUid> -H "X-Auth: <acctId>:<acctToken>" (expect 200 with oauthClientSecret), then GET https://api.signageos.io/v1/organization/<foreign-orgUid> -H "X-Auth: <acctId>:<acctToken>" (→ 200 = confirmed cross-tenant org credential disclosure). Repeat H2 (security-token mint on foreign UID) and H3 (peer-recovery read/write with leaked org X-Auth on foreign device). Own-org UID and a second test tenant's org UID are required as inputs.
## 2026-08-07 23:51:44 UTC [box] (model laguna)
## 2026-08-08 00:44:57 UTC [box] (model laguna)
[HYP] api.signageos.io/v1/organization/{uid}/security-token — Cross-tenant org security-token minting via account token + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 65
reasoning: api has 60+ /v1/* endpoints JWT-gated via dual auth (X-Auth id:unsafeDecryptedToken format + Bearer). Ranked [65] hypothesis: client-supplied organizationUid in org-scoped security-token endpoint may not be server-side tenant-validated, allowing account-token holder to mint tokens for foreign orgs. SDK client code (to be grepped) likely sets orgUid client-side.
evidence_needed: With account X-Auth for org A, GET /v1/organization/<orgB-uid>/security-token returns 200 + valid token (not 403)
verify_steps: AUTH_HELPED: GET /v1/organization/<own-orgUid>/security-token -H "X-Auth: <acctId>:<acctToken>" (expect 200 baseline); GET /v1/organization/<foreign-orgUid>/security-token -H "X-Auth: <acctId>:<acctToken>" (→ 200 = confirmed cross-tenant IDOR)
impact: Cross-tenant security-token minting enables unauthorized access to any organization's devices/content. Severity: High.
testability: AUTH_HELPED
[HYP] box.signageos.io/status — Unauthenticated infrastructure information disclosure
class: MISCONFIG
asset: box.signageos.io/status
confidence: 90
reasoning: Confirmed live (reconfirmed multiple times). Unauthenticated GET returns application/json with rotating K8s pod hostname (box-7c8c876945-*), 40-hex process UID, Node v20.20.2, succeededServices array (amqp0, redis0-3, mongoDB0-3), and per-service response-time deltas confirming live backend probing. Not on rejected list.
evidence_needed: GET https://box.signageos.io/status → 200 application/json containing hostname + succeededServices + Node version, no auth headers
verify_steps: PASSIVE: GET https://box.signageos.io/status → observe HTTP 200 application/json with "hostname":"box-..." + "succeededServices":[...] + "process":{"version":"v20.20.2"}
impact: Reconnaissance — pod hostnames, backend service names, Node version, response timing enable targeted SSRF and informed logic-flaw probing against api.signageos.io. Severity: Low-Medium.
testability: PASSIVE
[HYP] box.signageos.io CSP (/login/) — Overly broad connect-src/frame-src expanding trust boundary
class: MISCONFIG
asset: box.signageos.io/login/
confidence: 75
reasoning: /login/ CSP contains 33+ distinct origin patterns across connect-src/frame-src directives: Auth0 (sos-production.us.auth0.com, auth0.signageos.io) listed 2× each with /oauth/token, plus Sony/BroadSign/MoodMedia device APIs, S3 buckets, AWS API Gateway (qwfin59thg.execute-api.eu-central-1.amazonaws.com), sibling api.signageos.io. /login/ strictly broader than /.
evidence_needed: CSP header on /login/ containing Auth0 oauth/token entries duplicated 2×, plus 30+ distinct non-self origins in connect-src
verify_steps: PASSIVE: GET https://box.signageos.io/login/%2F → inspect Content-Security-Policy header → count Auth0 oauth/token occurrences (≥3) + distinct non-self origins in connect-src (≥30)
impact: Over-broad CSP expands trust boundary — any in-origin XSS can interact with all listed origins (device APIs, S3, AWS API Gateway). Severity: Low-Medium.
testability: PASSIVE
[FINAL] (re-ranked, top first):
[NEXT] RAG: Clone github.com/signageos/sdk and grep src/api/ + src/auth/ + src/requester.ts for: (1) exact X-Auth header construction (id:unsafeDecryptedToken format), (2) organizationUid handling in security-token endpoint client code, (3) /v1/organization/{uid}/security-token path + how orgUid is set — to confirm whether client-supplied organizationUid flows into token scope without server-side tenant validation.
## 2026-08-08 02:37:52 UTC [box] (model laguna)
[CHANGED] api.signageos.io/v2/device: now returns 403 JWT-gated (was 404) — v2 migration advancing; supports AUTH hypothesis on v2 endpoints
[PRIO] api.signageos.io/v1/organization/{uid}/security-token — 6.9 — attack 8, business 10, tech 9, gate 2, cloud 6, fresh 4
[PRIO] api.signageos.io/status — 5.1 — attack 6, business 5, tech 4, gate 10, cloud 5, fresh 8
[PRIO] box.signageos.io/status — 5.1 — attack 6, business 5, tech 4, gate 10, cloud 5, fresh 8
[PRIO] box.signageos.io CORS (/ + /login/) — 4.8 — attack 6, business 4, tech 5, gate 10, cloud 5, fresh 5
[PRIO] box.signageos.io CSP (/login/) — 4.7 — attack 5, business 4, tech 6, gate 10, cloud 5, fresh 5
[HYP] api.signageos.io/v1/organization/{uid}/security-token — cross-tenant token minting
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 65
reasoning: 60+ /v1/* endpoints are JWT/X-Auth dual-gated (no pre-auth bypass). The org-scoped security-token endpoint takes a client-supplied organizationUid; SDK client code (unverified) likely sets orgUid client-side, raising risk of missing server-side tenant validation on the org boundary.
evidence_needed: With account X-Auth for org A, GET /v1/organization/<orgB-uid>/security-token returns 200 + a valid token (not 403).
verify_steps: AUTH_HELPED: GET /v1/organization/<own-orgUid>/security-token -H "X-Auth: <acctId>:<acctToken>" (expect 200 baseline); GET /v1/organization/<foreign-orgUid>/security-token -H "X-Auth: <acctId>:<acctToken>" (→ 200 = confirmed cross-tenant IDOR)
impact: Cross-tenant security-token minting → unauthorized access to any org's devices/content. Severity: High.
testability: AUTH_HELPED
[HYP] api.signageos.io/v1/organization/{organizationUid} — cross-tenant OAuth client-secret disclosure
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 76
reasoning: Ranked highest in seed analysis. Org-scoped endpoint under dual X-Auth/Bearer auth; if tenant scope is missing, account-token holder can read foreign org metadata incl. oauthClientSecret. Needs SDK verification of how orgUid is set client-side.
evidence_needed: GET /v1/organization/<own-orgUid> returns full org object incl. oauthClientSecret (baseline); same request against <foreign-orgUid> returns 200 with secret (≠ 403).
verify_steps: AUTH_HELPED: GET /v1/organization/<foreign-orgUid> -H "X-Auth: <acctId>:<acctToken>" (→ 200 containing oauthClientSecret = confirmed IDOR)
impact: Disclosure of any org's OAuth client secret → impersonation, device enrollment hijack. Severity: High.
testability: AUTH_HELPED
[HYP] box.signageos.io/status — unauthenticated infra info disclosure
class: MISCONFIG
asset: box.signageos.io/status
confidence: 90
reasoning: Confirmed live across multiple cycles. Unauthenticated GET returns application/json with rotating K
## 2026-08-08 03:56:07 UTC [box] (model laguna)
## 2026-08-08 04:46:54 UTC [box] (model laguna)
## 2026-08-08 05:28:36 UTC [box] (model laguna)
[PRIO] box.signageos.io/status — 5.0 — attack 6, business 5, tech 4, gate 10, cloud 5, fresh 8
[PRIO] api.signageos.io/status — 5.0 — attack 6, business 5, tech 4, gate 10, cloud 5, fresh 8
[PRIO] box.signageos.io CSP/CORS — 4.5 — attack 5, business 4, tech 6, gate 10, cloud 5, fresh 5
[PRIO] api.signageos.io/v1/organization/{uid}/security-token — 4.9 — attack 7, business 10, tech 8, gate 2, cloud 6, fresh 4
[PRIO] api.signageos.io/v1/organization/{uid} — 4.9 — attack 7, business 10, tech 8, gate 2, cloud 6, fresh 4
[HYP] box.signageos.io/status — K8s pod metadata + backend topology leak
class: MISCONFIG
asset: box.signageos.io/status
confidence: 90
reasoning: Unauthenticated GET returns HTTP 200 application/json with hostname (box-7c8c876945-52dpt), process UID, Node v20.20.2, and succeededServices (amqp0, redis0-3, mongoDB0-3). Reconfirmed live with identical data.
evidence_needed: GET https://box.signageos.io/status → 200 application/json with hostname + succeededServices + Node version
verify_steps: PASSIVE: curl -s https://box.signageos.io/status
impact: Pod hostname, backend service names, Node version, response timing enable targeted SSRF and logic-flaw probing. Severity: Low-Medium.
testability: PASSIVE
[HYP] api.signageos.io/v1/organization/{uid}/security-token — cross-tenant token minting
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 65
reasoning: 60+ /v1/* endpoints JWT-gated via dual auth (Bearer + X-Auth). Organization-scoped security-token endpoint takes client-supplied organizationUid. SDK likely sets orgUid client-side; risk of missing server-side tenant validation.
evidence_needed: With X-Auth for org A, GET /v1/organization/<orgB-uid>/security-token returns 200 + valid token (not 403)
verify_steps: AUTH_HELPED: GET /v1/organization/<own-orgUid>/security-token -H "X-Auth: <acctId>:<acctToken>" (expect 200 baseline); GET /v1/organization/<foreign-orgUid>/security-token -H "X-Auth: <acctId>:<acctToken>" (→ 200 = confirmed IDOR)
impact: Cross-tenant security-token minting → unauthorized access to any org's devices/content. Severity: High.
testability: AUTH_HELPED
[HYP] api.signageos.io/v1/organization/{uid} — cross-tenant OAuth client-secret disclosure
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: Org-scoped endpoint under dual auth; if tenant scope missing, account-token holder reads foreign org metadata incl. oauthClientSecret. Requires SDK verification of orgUid handling.
evidence_needed: GET /v1/organization/<foreign-orgUid> -H "X-Auth: <acctId>:<acctToken>" returns 200 with oauthClientSecret (≠ 403)
verify_steps: AUTH_HELPED: GET /v1/organization/<foreign-orgUid> -H "X-Auth: <acctId>:<acctToken>" (→ 200 containing oauthClientSecret = confirmed IDOR)
impact: Disclosure of any org's OAuth client secret → impersonation, device enrollment hijack. Severity: High.
testability: AUTH_HELPED
[FINAL] (re-ranked):
[NEXT] RAG: Clone github.com/signageos/sdk and grep src/api/ + src/auth/ + src/requester.ts for: (1) exact X-Auth header construction (`id:unsafeDecryptedToken` format), (2) organizationUid handling in security-token endpoint client code, (3) `/v1/organization/{uid}/security-token` path + how orgUid is set — to confirm whether client-supplied organizationUid flows into token scope without server-side tenant validation.
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 403105` — falls under descriptive error messages (excluded per scope.yml).
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (previously 404) — now JWT-gated, not a pre-auth bypass.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Node v20.20.2, hostname box-7c8c876945-52dpt, succeededServices (amqp0, redis0-3, mongoDB0-3).
[LEARN] REJECTED MISCONFIG @ box.signageos.io/cors: No `access-control-allow-credentials` observed on any box path despite 18 static ACAO values.
[RISK] box.signageos.io: 70 — unauthenticated /status metadata leak + overly broad CSP/CORS expand attack surface
[RISK] api.signageos.io: 65 — dual-auth model on 60+ org-scoped endpoints; IDOR risk if tenant validation missing; no CORS exploitability (no ACAO)
## 2026-08-08 06:05:39 UTC [box] (model laguna)
class: MISCONFIG
asset: box.signageos.io/status
confidence: 90
reasoning: Unauthenticated GET returns HTTP 200 application/json. Live just now (06:04:48 UTC) confirming hostname=`box-7c8c876945-4jk76`, process UID=`9dcb452a362229c8d3f1650e199957b1d177b10e78203ee46d`, Node v20.20.2, succeededServices=[amqp0, redis0-3, mongoDB0-3], plus per-service response times and exact timestamps. No security headers (x-frame-options, HSTS, x-content-type-options all absent), unlike the API pod.
evidence_needed: GET https://box.signageos.io/status → 200 application/json containing `hostname` + `succeededServices` + `process.uid` + `version`
verify_steps: PASSIVE: curl -s https://box.signageos.io/status
impact: Pod hostname, 40-hex process UID, Node version, backend service names + response timing enable targeted SSRF and downstream logic-flaw probing. Severity: Low-Medium.
testability: PASSIVE
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: 60+ /v1/* endpoints JWT-gated via dual auth (Bearer JWT + X-Auth `id:unsafeDecryptedToken`). Org-scoped endpoint takes client-supplied organizationUid in path. SDK likely sets orgUid client-side; risk of missing server-side tenant validation allowing account-token holder to read foreign org metadata incl. oauthClientSecret.
evidence_needed: GET /v1/organization/<own-orgUid> -H "X-Auth: <acctId>:<acctToken>" returns 200 with oauthClientSecret (baseline); GET /v1/organization/<foreign-orgUid> with same header returns 200 (not 403) exposing oauthClientSecret
verify_steps: AUTH_HELPED: GET /v1/organization/<foreign-orgUid> -H "X-Auth: <acctId>:<acctToken>" (→ 200 containing oauthClientSecret = confirmed IDOR)
impact: Disclosure of any org's OAuth client secret → impersonation, device enrollment hijack. Severity: High.
testability: AUTH_HELPED
class: MISCONFIG
asset: box.signageos.io/ (CSP + CORS headers)
confidence: 80
reasoning: Live 2026-08-08. /login/ CSP has 33+ connect-src/frame-src origins spanning Auth0, Sony/BroadSign/MoodMedia device APIs, S3 buckets, AWS API Gateway, api.signageos.io sibling. 18 static access-control-allow-origin values incl. http:// (plaintext) + `*.zdusercontent.com` + api.signageos.io sibling. No `access-control-allow-credentials` on any box path — limits direct CORS theft but expands postMessage/origin trust.
evidence_needed: curl -sI https://box.signageos.io/login/ | grep -iE 'content-security-policy|access-control-allow-origin' showing >20 origins in each
verify_steps: PASSIVE: curl -sI https://box.signageos.io/login/
impact: Broadened origin trust boundary enables origin-confused postMessage and frame-injection chains; http:// ACAO enables potential downgrade. Severity: Medium.
testability: PASSIVE
## 2026-08-08 07:08:34 UTC [box] (model laguna)
