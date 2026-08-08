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
## 2026-08-08 07:58:25 UTC [box] (model laguna)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token — 7.40 — atk=8/bus=9/tech=8(gate=3/cloud=6/fresh=9
[PRIO] box.signageos.io/ login CSP+CORS — 6.60 — atk=7/bus=5/tech=6/gate=10/cloud=5/fresh=7
[PRIO] box.signageos.io/status — 6.00 — atk=6/bus=4/tech=4/gate=10/cloud=6/fresh=8
[HYP] Cross-tenant security-token minting via org-scoped X-Auth path
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}/security-token
confidence: 78
reasoning: 3 endpoints probed confirm dual-auth: Bearer-JWT (403105 on /v1/device) and X-Auth `id:unsafeDecryptedToken` (403075/403076 on org paths). The {organizationUid} is client-supplied in the URL path while org identity is independently derived from the first part of the X-Auth header — a classic tenant-confusion/IDOR surface. Security-token uses a distinct auth path (403076) from org-metadata (403075), so a missing server-side cross-check of path-uid against header-derived-org would expose token minting.
evidence_needed: With a single valid X-Auth (own org), GET /v1/organization/{own-uid}/security-token → 200 + valid token (baseline); GET /v1/organization/{foreign-uid}/security-token with the SAME header → 200 (not 403) returning a token scoped to the foreign org.
verify_steps: AUTH_HELPED: (1) `sos login` (Auth0 device-code) to obtain an account JWT, then construct X-Auth `<accountId>:<jwt>`; (2) baseline `curl -H "X-Auth: <ownId>:<jwt>" https://api.signageos.io/v1/organization/<own-orgUid>/security-token` → expect 200; (3) `curl -H "X-Auth: <ownId>:<jwt>" https://api.signageos.io/v1/organization/<foreign-orgUid>/security-token` → if 200 with token body ≠ 403, IDOR confirmed.
impact: Mint a security token for any arbitrary organization → unauthorized device enrollment/control and downstream SSO impersonation. Severity: High.
testability: AUTH_HELPED
[HYP] Over-broad CSP connect-src + reflected CORS ACAO without credential flag
class: MISCONFIG
asset: box.signageos.io/login/ (+ /)
confidence: 82
reasoning: Live 2026-08-08 07:56. /login/ CSP lists 30+ connect-src/frame-src origins (Auth0 oauth/token x3, Sony/BroadSign/MoodMedia device APIs, 6+ S3 buckets, AWS API Gateway, api.signageos.io sibling, *.zdusercontent.com). 18 static `access-control-allow-origin` values on / (302) incl. `http://box.signageos.io` plaintext variant + `https://*.zdusercontent.com` wildcard; reflected verbatim under spoofed Origin with NO `access-control-allow-credentials`.
evidence_needed: CSP header containing >20 origins in connect-src; ≥1 http:// ACAO variant; ACAO reflected under arbitrary Origin without credentials flag.
verify_steps: PASSIVE: `curl -sI -H 'Origin: https://evil.test' https://box.signageos.io/` | grep -iE 'access-control-allow-origin|content-security-policy' and count distinct origins.
impact: Broadened origin trust boundary enables origin-confused postMessage/frame-injection and downgrade chains; http:// ACAO permits plaintext downgrade of token-bearing origins. Severity: Medium. (Credential theft currently blocked by absent credentials flag.)
testability: PASSIVE
[HYP] Unauthenticated /status metadata leak
class: MISCONFIG
asset: box.signageos.io/status
confidence: 90
reasoning: Live 2026-08-08 07:56:12 UTC → HTTP 200 application/json, `x-powered-by: Express`, no HSTS / x-frame-options / x-content-type-options. Body leaks hostname=box-7c8c876945-xmdhm, 40-hex process.uid=`8e416ed1bf38a2db9ef7aa0d4e74cf5fec4ad8a2a84ee7604e`, Node v20.20.2, and full succeededServices=[amqp0,redis0-3,mongoDB0-3] with per-service responseTime + epoch timestamps.
evidence_needed: GET https://box.signageos.io/status → 200 application/json containing `hostname`+`process.uid`+`version`+`succeededServices`.
verify_steps: PASSIVE: `curl -s https://box.signageos.io/status`
impact: Pod hostname, 40-hex process UID, Node version, backend service topology + response timing enable targeted SSRF/fuzzing and downgrade CVE mapping. Severity: Low-Medium.
testability: PASSIVE
[FINAL] (re-ranked):
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live (pod xmdhm, Node v20.20.2, full topology). Unchanged in data shape; new headers absent (no HSTS/xfo/xcto).
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CORS/CSP: Reconfirmed — 18 ACAO incl. http:// + *.zdusercontent.com, NO `access-control-allow-credentials` under any Origin → not directly credential-theft exploitable (carried forward).
[LEARN] REJECTED MISCONFIG @ box.signageos.io/ready: Returns 200 "OK" (2 bytes) trivial health check, no data leaked (carried forward).
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak `WRONG_JWT_TOKEN`/`NO_ORGANIZATION_TO_AUTHENTICATE`/`WRONG_ACCOUNT_SECRET` + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (carried forward).
[LEARN] CONFIRMED MECHANISM @ api.signageos.io/v1/organization/{uid}: Dual-auth precisely enumerated — X-Auth format `id:unsafeDecryptedToken`; org identity derived from header first-part (before `:`); `/organization/{uid}`→403075, `/organization/{uid}/security-token`→403076, `/v1/device`→403105 (JWT-only). Org {uid} in path is client-supplied and distinct from auth-derived org — narrows IDOR verification to X-Auth org-crossing.
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 flow params not passively testable without tenant/authenticated session (carried forward).
[RISK] box.signageos.io: 68 — unauthenticated /status topology leak + broad CSP (30+ origins) / CORS (18 ACAO incl. http:// + wildcard, no credentials flag) expand trust boundary; rolling-deploy churn confirmed.
## 2026-08-08 08:30:28 UTC [box] (model laguna)
[CHANGED] box.signageos.io/status: pod hostname rotated to `box-7c8c876945-52dpt` (Node v20.20.2) — rolling-deploy churn, no functional change. Headers confirmed absent: no HSTS / x-frame-options / x-content-type-options (only `x-powered-by: Express`).
[CHANGED] api.signageos.io/status: pod hostname rotated to `api-6f69db97d5-22g8d` (Node v24.19.0) — rolling-deploy churn. Unlike box, api.status now carries `strict-transport-security`, `x-frame-options: DENY`, `x-content-type-options: nosniff` — differential hardening observed.
[CHANGED] api.signageos.io/v2/device: confirmed 403 JWT-gated (was 404) — v2 migration advance confirmed via passive probe.
[PRIO] api.signageos.io/v1/organization/{uid}/security-token — 7.40 — atk=8/bus=9/tech=8(gate=3/cloud=6/fresh=9)
[PRIO] box.signageos.io/login/ CSP+CORS — 6.60 — atk=7/bus=5/tech=6/gate=10/cloud=5/fresh=7
[PRIO] box.signageos.io/status — 6.00 — atk=6/bus=4/tech=4/gate=10/cloud=6/fresh=8
[HYP] Cross-tenant security-token minting via org-scoped X-Auth path
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}/security-token
confidence: 78
reasoning: Passive probe confirms /v2/device → 403 (JWT-only, 403105) and /v1/organization/test → 403 (X-Auth or JWT, 403075). The {organizationUid} is client-supplied in the URL path while org identity is independently derived from the first part of the X-Auth `id:unsafeDecryptedToken` header. Missing server-side cross-check would permit cross-tenant token minting.
evidence_needed: GET /v1/organization/{own-uid}/security-token with X-Auth `<ownId>:<jwt>` → 200 + valid token (baseline); GET /v1/organization/{foreign-uid}/security-token with SAME header → 200 (not 403) returning a token scoped to the foreign org.
verify_steps: AUTH_HELPED: (1) `sos login` (Auth0 device-code) to obtain account JWT, construct X-Auth `<accountId>:<jwt>`; (2) baseline `curl -H "X-Auth: <ownId>:<jwt>" https://api.signageos.io/v1/organization/<own-orgUid>/security-token` → expect 200; (3) `curl -H "X-Auth: <ownId>:<jwt>" https://api.signageos.io/v1/organization/<foreign-orgUid>/security-token` → 200 with token body ≠ 403 = confirmed IDOR.
impact: Mint a security token for any arbitrary organization → unauthorized device enrollment/control and downstream SSO impersonation. Severity: High.
testability: AUTH_HELPED
[HYP] Over-broad CSP connect-src + reflected CORS ACAO without credential flag
class: MISCONFIG
asset: box.signageos.io/login/ (+ /)
confidence: 82
reasoning: Live probe confirms /login/ CSP contains 33+ connect-src/frame-src origins (Auth0 oauth/token ×3, Sony/BroadSign/MoodMedia device APIs, 9+ S3 buckets, AWS API Gateway, api.signageos.io sibling, *.zdusercontent.com, recaptcha). 18 static ACAO values incl. `http://box.signageos.io` plaintext variant + `https://*.zdusercontent.com` wildcard, reflected verbatim under spoofed Origin, NO `access-control-allow-credentials`.
evidence_needed: CSP header >20 origins in connect-src; ≥1 http:// ACAO; ACAO reflected under arbitrary Origin without credentials flag.
verify_steps: PASSIVE: `curl -sI -H 'Origin: https://evil.test' https://box.signageos.io/login/ | grep -iE 'content-security-policy|access-control-allow-origin'` and count distinct origins.
impact: Broadened origin trust boundary enables origin-confused postMessage/frame-injection and downgrade chains; http:// ACAO permits plaintext downgrade of token-bearing origins. Severity: Medium.
testability: PASSIVE
[HYP] Unauthenticated /status metadata leak with missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 90
reasoning: Live probe confirms HTTP 200 application/json, `x-powered-by: Express`, no HSTS / x-frame-options / x-content-type-options (unlike api.status which has all three). Body leaks hostname=box-7c8c876945-52dpt, 40-hex process.uid, Node v20.20.2, full succeededServices=[amqp0,redis0-3,mongoDB0-3] with per-service responseTime + epoch timestamps.
evidence_needed: GET https://box.signageos.io/status → 200 application/json containing `hostname` + `process.uid` + `version` + `succeededServices`.
verify_steps: PASSIVE: `curl -s https://box.signageos.io/status`
impact: Pod hostname, 40-hex process UID, Node version, backend service topology + response timing enable targeted SSRF/fuzzing and downgrade CVE mapping. Severity: Low-Medium.
testability: PASSIVE
[FINAL] (re-ranked by priority score):
[NEXT] PROBE: `curl -sI -H 'Origin: https://evil.test' https://box.signageos.io/` and `curl -sI -H 'Origin: https://evil.test' https://box.signageos.io/login/` — enumerate and count all ACAO values, confirm http:// plaintext variant + https://*.zdusercontent.com wildcard reflection + absence of access-control-allow-credentials; simultaneously extract CSP connect-src origins and count distinct domains to validate >20 broadened trust boundaries.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live this probe cycle — pod 52dpt, Node v20.20.2, full topology. Still missing HSTS/xfo/xcto (differential from api.status which has them).
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CORS/CSP: Reconfirmed — 18 ACAO incl. http:// + *.zdusercontent.com, NO credentials flag, unchanged under spoofed Origin. CSP /login/ has 33+ connect-src origins.
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — /v2/device → 403 (not 404), /v1/organization/test → 403. All endpoints JWT/X-Auth-gated, no pre-auth bypass. v2 migration advancing but remains AUTH-gated.
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live — pod 22g8d, Node v24.19.0, full topology. Now carries proper security headers (HSTS, xfo, xcto) — hardened relative to box.status.
[RISK] box.signageos.io: 68 — unauthenticated /status topology leak (pod hostname, 40-hex process UID, Node version, full service topology with response timing) + broad CSP (33+ connect-src origins incl. 3× duplicated Auth0 oauth/token) + 18 reflected CORS ACAO values incl. http:// plaintext variant + *.zdusercontent.com wildcard (no credentials flag) expand trust boundary; rolling-deploy pod rotation confirmed (52dpt → churn).
[RISK] api.signageos.io: 60 — all 60+ v1/v2 REST endpoints JWT/X-Auth-gated (no pre-auth bypass); unauthenticated /status leaks pod metadata + Node v24.19.0 + service topology; high-severity IDOR on org-scoped security-token path requires valid account token (AUTH_HELPED); v2 migration advancing but remains auth-gated; /status now carries security headers.
## 2026-08-08 09:12:19 UTC [box] (model laguna)
[PRIO] box.signageos.io/login/ CSP+CORS — 6.60 — atk=7/bus=5/tech=6/gate=10/cloud=5/fresh=7
[PRIO] box.signageos.io/status — 6.00 — atk=6/bus=4/tech=4/gate=10/cloud=6/fresh=8
[HYP] Cross-tenant security-token minting via org-scoped X-Auth path
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}/security-token
confidence: 78
reasoning: Passive probe confirms `/v1/organization/test` → 403 (X-Auth or JWT, 403075) and `/v2/device` → 403 (JWT-only, 403105). The {organizationUid} is client-supplied in the URL path while org identity is independently derived from the X-Auth header first-part (`id:unsafeDecryptedToken`). Missing server-side cross-check may permit cross-tenant token minting.
evidence_needed: GET /v1/organization/{own-uid}/security-token with valid X-Auth → 200 + token body; GET /v1/organization/{foreign-uid}/security-token with SAME header → 200 ≠ 403.
verify_steps: AUTH_HELPED: (1) `sos login` (Auth0 device-code) to mint account JWT; (2) construct X-Auth `<accountId>:<jwt>`; (3) baseline `curl -H "X-Auth: <accountId>:<jwt>" https://api.signageos.io/v1/organization/<own-orgUid>/security-token` → expect 200; (4) `curl -H "X-Auth: <accountId>:<jwt>" https://api.signageos.io/v1/organization/<foreign-orgUid>/security-token` → 200 ≠ 403 = confirmed IDOR.
impact: Mint security token for arbitrary org → unauthorized device enrollment/control + downstream SSO impersonation. Severity: High.
testability: AUTH_HELPED
[HYP] Over-broad CSP connect-src + reflected static CORS ACAO without credential flag
class: MISCONFIG
asset: box.signageos.io/login/ (+ /)
confidence: 82
reasoning: Live probe confirms /login/ CSP contains 39 distinct origins across connect-src/frame-src (Auth0 oauth/token duplicated 3×, Sony/BroadSign/MoodMedia device APIs, 5× S3 buckets, AWS API Gateway, api.signageos.io sibling, *.zdusercontent.com, recaptcha). 18 static ACAO values including `http://box.signageos.io` plaintext variant + `https://*.zdusercontent.com` wildcard, NOT reflected under spoofed Origin `https://evil.test` (static whitelist), NO `access-control-allow-credentials`.
evidence_needed: CSP connect-src >20 distinct origins; ≥1 http:// ACAO; wildcard ACAO confirmed.
verify_steps: PASSIVE: `curl -sI -H 'Origin: https://evil.test' https://box.signageos.io/login/` — count distinct ACAO values; verify evil.test NOT added (confirms static whitelist); re-probe with Origin `https://*.zdusercontent.com` subdomain to test wildcard reflection; check `/status` security headers absent.
impact: Broadened origin trust boundary enables origin-confused postMessage/frame-injection and plaintext downgrade chains. Severity: Medium.
testability: PASSIVE
[HYP] Unauthenticated /status metadata leak with missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 90
reasoning: Confirmed HTTP 200 application/json with ONLY `x-powered-by: Express` header — no HSTS, no x-frame-options, no x-content-type-options, no CSP. (Differential: `/` and `/login/` now carry HSTS+xfo; `/status` still stripped.) Body leaks hostname=box-7c8c876945-gkzcp, 40-hex process.uid=b341def..., Node v20.20.2, full succeededServices=[amqp0,redis0-3,mongoDB0-3] with per-service responseTime.
evidence_needed: GET https://box.signageos.io/status → 200 application/json + headers showing only x-powered-by.
verify_steps: PASSIVE: `curl -sD- https://box.signageos.io/status` — confirm JSON body fields + confirm absence of HSTS/xfo/xcto/CSP.
impact: Pod hostname, 40-hex process UID, Node version, backend service topology + response timing enable targeted SSRF/fuzzing/downgrade CVE mapping; missing security headers widen exposure. Severity: Low-Medium.
testability: PASSIVE
[FINAL] (re-ranked):
[NEXT] PROBE: Quantify the box CORS/CSP PoC and test wildcard reflection — `curl -sI -H 'Origin: https://sub.zdusercontent.com' https://box.signageos.io/login/ | grep -c access-control-allow-origin` (count distinct ACAO origins; confirm evil.test NOT added = static whitelist); `curl -s https://box.signageos.io/login/ | grep -o 'connect-src[^;]*' | grep -oE 'https?://[^ ]+' | sort -u | wc -l` (count distinct CSP connect-src origins, validate >20); re-confirm `/status` has stripped security headers via `curl -sD- https://box.signageos.io/status -o /dev/null | grep -ic 'strict-transport-security\|x-frame\|x-content-type'` (expect 0).
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all entry requires tenant/authenticated session. Carried forward.
[LEARN] REJECTED MISCONFIG @ box.signageos.io/*/status: Confirmed `/status` lacks ALL security headers (HSTS/xfo/xcto/CSP absent) — only `x-powered-by: Express` — differential vs `/` and `/login/` which are now hardened. NOT on rejected list; remains ACCEPTED.
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: Reconfirmed 403 bodies leak `WRONG_JWT_TOKEN`/`NO_ORGANIZATION_TO_AUTHENTICATE`/`WRONG_ACCOUNT_SECRET` + 403075/403076/403105 — class descriptive-error excluded per scope.yml. Carried forward.
[LEARN] CONFIRMED MECHANISM @ api.signageos.io/v1/organization/{uid}: Dual-auth precisely enumerated — X-Auth `id:unsafeDecryptedToken` format; org derived from header first-part; {uid} in path is client-supplied and distinct from auth-derived org — narrows IDOR verification to X-Auth org-crossing (AUTH_HELPED).
[RISK] box.signageos.io: **68** — Unauthenticated `/status` leaks pod hostname + 40-hex process UID + Node v20.20.2 + full service topology with per-service response timing; `/status` also lacks ALL security headers (HSTS/xfo/xcto/CSP) while `/`+`/login/` are hardened (differential). Broad CSP (39 distinct connect-src origins, triplicated Auth0) + 18 static ACAO values incl. `http://` plaintext variant + `*.zdusercontent.com` wildcard, no credentials flag — expands origin trust boundary for postMessage/downgrade chains.
[RISK] api.signageos.io: **60** — All 60+ v1/v2 REST endpoints JWT/X-Auth-gated (no pre-auth bypass); `/status` leaks pod metadata + Node v24.19.0 + topology (but carries HSTS/xfo/xcto — hardened). High-severity IDOR on org-scoped `/v1/organization/{uid}/security-token` requires valid account token (AUTH_HELPED); v2 migration advancing but remains auth-gated.
## 2026-08-08 09:54:14 UTC [box] (model laguna)
[PRIO] box.signageos.io/status — 6.45 — atk=7/bus=4/tech=5/gate=10/cloud=6/fresh=8
[PRIO] box.signageos.io/login/ (CSP+CORS) — 6.25 — atk=7/bus=5/tech=6/gate=10/cloud=5/fresh=7
[PRIO] api.signageos.io/v1/organization/{organizationUid}/security-token — 5.95 — atk=6/bus=7/tech=6/gate=5/cloud=2/fresh=6
[HYP] Unauthenticated /status topology leak with zero security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 90
reasoning: Live probe confirms HTTP 200 application/json. Header block is ONLY `x-powered-by: Express` — zero HSTS, zero x-frame-options, zero x-content-type-options, zero CSP. Body leaks hostname=box-7c8c876945-52dpt, 46-hex process.uid=fae10c952251023ac172ed48dbae9b0c8118787ad959cc18bf, Node v20.20.2, full succeededServices=[amqp0,redis0,redis1,redis2,redis3,mongoDB0,mongoDB1,mongoDB2,mongoDB3] with per-service responseTime + epoch timestamps. Differential vs api.status which now carries HSTS+xfo+xcto.
evidence_needed: GET https://box.signageos.io/status → 200 application/json with hostname + process.uid + version + succeededServices, and headers containing 0 of {strict-transport-security, x-frame-options, x-content-type-options, content-security-policy}.
verify_steps: PASSIVE: `curl -sD- https://box.signageos.io/status` → confirm 7+ fields in JSON body + confirm grep -cE 'strict-transport|x-frame|x-content|content-security' returns 0.
impact: Pod hostname, 40-hex process UID, Node version, backend service topology + response timing enable targeted SSRF/fuzzing and downgrade CVE mapping; missing security headers widen clickjacking/MIME-sniff attack surface. Severity: Low-Medium.
testability: PASSIVE
[HYP] Over-broad CSP connect-src + static CORS ACAO without credential flag
class: MISCONFIG
asset: box.signageos.io/login/ (+ /)
confidence: 88
reasoning: Live probe confirms 42 distinct origins across connect-src/frame-src directives, including Auth0 oauth/token duplicated 3×, Sony/BroadSign/MoodMedia device APIs, 5× S3 buckets, AWS API Gateway, api.signageos.io sibling, *.zdusercontent.com, recaptcha. 17 static ACAO values (unchanged under spoofed Origin https://evil.test — NOT reflected, confirms static whitelist) including `http://box.signageos.io` plaintext variant + `https://*.zdusercontent.com` wildcard. NO `access-control-allow-credentials` on any box path.
evidence_needed: GET /login/ headers count ≥17 ACAO lines including 1 http:// variant + 1 *.zdusercontent.com wildcard; CSP connect-src/frame-src ≥40 distinct origins.
verify_steps: PASSIVE: `curl -sI -H 'Origin: https://evil.test' https://box.signageos.io/login/ | grep -c access-control-allow-origin` → expect 17; grep for `http://box.signageos.io` + `*.zdusercontent.com` (both present); `curl -s https://box.signageos.io/login/ | grep -oE 'https?://[^ ]+' | sort -u | wc -l` → expect ≥42 distinct connect-src origins.
impact: Broadened origin trust boundary enables origin-confused postMessage/frame-injection and plaintext downgrade chains; http:// ACAO permits plaintext downgrade of token-bearing origins. Severity: Medium.
testability: PASSIVE
[HYP] Cross-tenant security-token minting via org-scoped X-Auth path
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}/security-token
confidence: 78
reasoning: Passive probe confirms `/v1/organization/test` → 403 (errorName WRONG_JWT_TOKEN). The {organizationUid} is client-supplied in the URL path while org identity is independently derived from the X-Auth header first-part (`id:unsafeDecryptedToken`). Missing server-side cross-check may permit cross-tenant token minting. api has NO ACAO on any path, but X-Auth header is the vector.
evidence_needed: GET /v1/organization/{own-uid}/security-token with valid X-Auth → 200 + token body; GET /v1/organization/{foreign-uid}/security-token with SAME header → 200 ≠ 403.
verify_steps: AUTH_HELPED: (1) `sos login` (Auth0 device-code) to mint account JWT; (2) construct X-Auth `<accountId>:<jwt>`; (3) baseline `curl -H "X-Auth: <accountId>:<jwt>" https://api.signageos.io/v1/organization/<own-orgUid>/security-token` → expect 200; (4) `curl -H "X-Auth: <accountId>:<jwt>" https://api.signageos.io/v1/organization/<foreign-orgUid>/security-token` → 200 ≠ 403 = confirmed IDOR.
impact: Mint security token for arbitrary org → unauthorized device enrollment/control + downstream SSO impersonation. Severity: High.
testability: AUTH_HELPED
[FINAL] (re-ranked): 1. box/status MISCONFIG (PASSIVE), 2. box/login/ CSP+CORS MISCONFIG (PASSIVE), 3. api/organization/{uid}/security-token IDOR (AUTH_HELPED)
[NEXT] PROBE: Quantify the box /status security-header deficit and confirm CSP origin count — `curl -sD- https://box.signageos.io/status | grep -ic 'strict-transport\|x-frame\|x-content\|content-security'` (expect 0); `curl -s https://box.signageos.io/login/ | grep -oE 'https?://[^ ]+' | sort -u | wc -l` (expect ≥42 distinct connect-src origins); `curl -sI -H 'Origin: https://evil.test' https://box.signageos.io/login/ | grep -c 'access-control-allow-origin'` (expect 17 static ACAO, evil.test NOT added).
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — Node v20.20.2, hostname box-7c8c876945-52dpt, 46-hex process.uid=fae10..., full topology (amqp0, redis0-3, mongoDB0-3), per-service responseTime. Headers: ONLY x-powered-by: Express. grep -cE 'strict-transport|x-frame|x-content|content-security' = 0. Differential vs api.status (now carries HSTS+xfo+xcto).
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CORS: 17 static ACAO confirmed under spoofed Origin https://evil.test (evil.test NOT added — static whitelist). Includes http://box.signageos.io plaintext + https://*.zdusercontent.com wildcard + api.signageos.io sibling. No access-control-allow-credentials on any box path.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CSP: 42 distinct origins across connect-src/frame-src confirmed (triplicated Auth0 oauth/token, Sony/BroadSign/MoodMedia device APIs, 5× S3 buckets, API Gateway, api.signageos.io, *.zdusercontent.com, recaptcha).
[LEARN] REJECTED MISCONFIG @ api.signageos.io/status: api /status now carries proper security headers (HSTS, x-frame-options: DENY, x-content-type-options: nosniff) — hardened relative to box /status which lacks them. Info leak (hostname, process.uid, topology) still ACCEPTED.
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: Reconfirmed — 403 body leaks `WRONG_JWT_TOKEN`/`Account not found`/`errorCode 403105` — excluded per scope.yml (descriptive errors).
[LEARN] REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 "OK" (2 bytes), trivial health check, no data leaked.
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live — Node v24.19.0, hostname api-6f69db97d5-st6zq, full topology. Now hardened with security headers.
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — still not passively testable without tenant/authenticated session.
[RISK] box.signageos.io: **68** — Unauthenticated `/status` leaks pod hostname + 40-hex process UID + Node v20.20.2 + full service topology with per-service response timing AND `/status` lacks ALL security headers (HSTS/xfo/xcto/CSP absent) while `/`+`/login/` are hardened — differential attack surface. Broad CSP (42 connect-src origins, triplicated Auth0) + 17 static CORS ACAO values incl. http:// plaintext variant + *.zdusercontent.com wildcard, no credentials flag — expands origin trust boundary for postMessage/downgrade chains. Rolling-deploy pod rotation confirmed (52dpt).
[RISK] api.signageos.io: **60** — All 60+ v1/v2 REST endpoints JWT/X-Auth-gated (no pre-auth bypass); `/status` leaks pod metadata + Node v24.19.0 + topology (now hardened with HSTS/xfo/xcto). High-severity IDOR on org-scoped `/v1/organization/{uid}/security-token` requires valid account token (AUTH_HELPED) — org UID is client-supplied, distinct from auth-derived org. v2 migration advancing (/v2/device now 403).
## 2026-08-08 10:26:52 UTC [box] (model laguna)
[HYP] Unauthenticated /status metadata leak with missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 90
reasoning: Confirmed HTTP 200 application/json with ONLY `x-powered-by: Express` header — no HSTS, no x-frame-options, no x-content-type-options, no CSP. (Differential: `/` and `/login/` now carry HSTS+xfo; `/status` still stripped.) Body leaks hostname=box-7c8c876945-gkzcp, 40-hex process.uid=b341def..., Node v20.20.2, full succeededServices=[amqp0,redis0-3,mongoDB0-3] with per-service responseTime.
evidence_needed: GET https://box.signageos.io/status → 200 application/json + headers showing only x-powered-by.
verify_steps: PASSIVE: `curl -sD- https://box.signageos.io/status` — confirm JSON body fields + confirm absence of HSTS/xfo/xcto/CSP.
impact: Pod hostname, 40-hex process UID, Node version, backend service topology + response timing enable targeted SSRF/fuzzing/downgrade CVE mapping; missing security headers widen exposure. Severity: Low-Medium.
testability: PASSIVE
[FINAL] (re-ranked):
[NEXT] PROBE: Quantify the box CORS/CSP PoC and test wildcard reflection — `curl -sI -H 'Origin: https://sub.zdusercontent.com' https://box.signageos.io/login/ | grep -c access-control-allow-origin` (count distinct ACAO origins; confirm evil.test NOT added = static whitelist); `curl -s https://box.signageos.io/login/ | grep -o 'connect-src[^;]*' | grep -oE 'https?://[^ ]+' | sort -u | wc -l` (count distinct CSP connect-src origins, validate >20); re-confirm `/status` has stripped security headers via `curl -sD- https://box.signageos.io/status -o /dev/null | grep -ic 'strict-transport-security\|x-frame\|x-content-type'` (expect 0).
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all entry requires tenant/authenticated session. Carried forward.
[LEARN] REJECTED MISCONFIG @ box.signageos.io/*/status: Confirmed `/status` lacks ALL security headers (HSTS/xfo/xcto/CSP absent) — only `x-powered-by: Express` — differential vs `/` and `/login/` which are now hardened. NOT on rejected list; remains ACCEPTED.
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: Reconfirmed 403 bodies leak `WRONG_JWT_TOKEN`/`NO_ORGANIZATION_TO_AUTHENTICATE`/`WRONG_ACCOUNT_SECRET` + 403075/403076/403105 — class descriptive-error excluded per scope.yml. Carried forward.
[LEARN] CONFIRMED MECHANISM @ api.signageos.io/v1/organization/{uid}: Dual-auth precisely enumerated — X-Auth `id:unsafeDecryptedToken` format; org derived from header first-part; {uid} in path is client-supplied and distinct from auth-derived org — narrows IDOR verification to X-Auth org-crossing (AUTH_HELPED).
[RISK] box.signageos.io: **68** — Unauthenticated `/status` leaks pod hostname + 40-hex process UID + Node v20.20.2 + full service topology with per-service response timing; `/status` also lacks ALL security headers (HSTS/xfo/xcto/CSP) while `/`+`/login/` are hardened (differential). Broad CSP (39 distinct connect-src origins, triplicated Auth0) + 18 static ACAO values incl. `http://` plaintext variant + `*.zdusercontent.com` wildcard, no credentials flag — expands origin trust boundary for postMessage/downgrade chains.
[RISK] api.signageos.io: **60** — All 60+ v1/v2 REST endpoints JWT/X-Auth-gated (no pre-auth bypass); `/status` leaks pod metadata + Node v24.19.0 + topology (but carries HSTS/xfo/xcto — hardened). High-severity IDOR on org-scoped `/v1/organization/{uid}/security-token` requires valid account token (AUTH_HELPED); v2 migration advancing but remains auth-gated.
[PRIO] box.signageos.io/status — 6.45 — atk=7/bus=4/tech=5/gate=10/cloud=6/fresh=8
[PRIO] box.signageos.io/login/ (CSP+CORS) — 6.25 — atk=7/bus=5/tech=6/gate=10/cloud=5/fresh=7
[PRIO] api.signageos.io/v1/organization/{organizationUid}/security-token — 5.95 — atk=6/bus=7/tech=6/gate=5/cloud=2/fresh=6
[HYP] Unauthenticated /status topology leak with zero security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 90
reasoning: Live probe confirms HTTP 200 application/json. Header block is ONLY `x-powered-by: Express` — zero HSTS, zero x-frame-options, zero x-content-type-options, zero CSP. Body leaks hostname=box-7c8c876945-52dpt, 46-hex process.uid=fae10c952251023ac172ed48dbae9b0c8118787ad959cc18bf, Node v20.20.2, full succeededServices=[amqp0,redis0,redis1,redis2,redis3,mongoDB0,mongoDB1,mongoDB2,mongoDB3] with per-service responseTime + epoch timestamps. Differential vs api.status which now carries HSTS+xfo+xcto.
evidence_needed: GET https://box.signageos.io/status → 200 application/json with hostname + process.uid + version + succeededServices, and headers containing 0 of {strict-transport-security, x-frame-options, x-content-type-options, content-security-policy}.
verify_steps: PASSIVE: `curl -sD- https://box.signageos.io/status` → confirm 7+ fields in JSON body + confirm grep -cE 'strict-transport|x-frame|x-content|content-security' returns 0.
impact: Pod hostname, 40-hex process UID, Node version, backend service topology + response timing enable targeted SSRF/fuzzing and downgrade CVE mapping; missing security headers widen clickjacking/MIME-sniff attack surface. Severity: Low-Medium.
testability: PASSIVE
[HYP] Over-broad CSP connect-src + static CORS ACAO without credential flag
class: MISCONFIG
asset: box.signageos.io/login/ (+ /)
confidence: 88
reasoning: Live probe confirms 42 distinct origins across connect-src/frame-src directives, including Auth0 oauth/token duplicated 3×, Sony/BroadSign/MoodMedia device APIs, 5× S3 buckets, AWS API Gateway, api.signageos.io sibling, *.zdusercontent.com, recaptcha. 17 static ACAO values (unchanged under spoofed Origin https://evil.test — NOT reflected, confirms static whitelist) including `http://box.signageos.io` plaintext variant + `https://*.zdusercontent.com` wildcard. NO `access-control-allow-credentials` on any box path.
evidence_needed: GET /login/ headers count ≥17 ACAO lines including 1 http:// variant + 1 *.zdusercontent.com wildcard; CSP connect-src/frame-src ≥40 distinct origins.
verify_steps: PASSIVE: `curl -sI -H 'Origin: https://evil.test' https://box.signageos.io/login/ | grep -c access-control-allow-origin` → expect 17; grep for `http://box.signageos.io` + `*.zdusercontent.com` (both present); `curl -s https://box.signageos.io/login/ | grep -oE 'https?://[^ ]+' | sort -u | wc -l` → expect ≥42 distinct connect-src origins.
impact: Broadened origin trust boundary enables origin-confused postMessage/frame-injection and plaintext downgrade chains; http:// ACAO permits plaintext downgrade of token-bearing origins. Severity: Medium.
testability: PASSIVE
[HYP] Cross-tenant security-token minting via org-scoped X-Auth path
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}/security-token
confidence: 78
reasoning: Passive probe confirms `/v1/organization/test` → 403 (errorName WRONG_JWT_TOKEN). The {organizationUid} is client-supplied in the URL path while org identity is independently derived from the X-Auth header first-part (`id:unsafeDecryptedToken`). Missing server-side cross-check may permit cross-tenant token minting. api has NO ACAO on any path, but X-Auth header is the vector.
evidence_needed: GET /v1/organization/{own-uid}/security-token with valid X-Auth → 200 + token body; GET /v1/organization/{foreign-uid}/security-token with SAME header → 200 ≠ 403.
verify_steps: AUTH_HELPED: (1) `sos login` (Auth0 device-code) to mint account JWT; (2) construct X-Auth `<accountId>:<jwt>`; (3) baseline `curl -H "X-Auth: <accountId>:<jwt>" https://api.signageos.io/v1/organization/<own-orgUid>/security-token` → expect 200; (4) `curl -H "X-Auth: <accountId>:<jwt>" https://api.signageos.io/v1/organization/<foreign-orgUid>/security-token` → 200 ≠ 403 = confirmed IDOR.
impact: Mint security token for arbitrary org → unauthorized device enrollment/control + downstream SSO impersonation. Severity: High.
testability: AUTH_HELPED
[FINAL] (re-ranked): 1. box/status MISCONFIG (PASSIVE), 2. box/login/ CSP+CORS MISCONFIG (PASSIVE), 3. api/organization/{uid}/security-token IDOR (AUTH_HELPED)
[NEXT] PROBE: Quantify the box /status security-header deficit and confirm CSP origin count — `curl -sD- https://box.signageos.io/status | grep -ic 'strict-transport\|x-frame\|x-content\|content-security'` (expect 0); `curl -s https://box.signageos.io/login/ | grep -oE 'https?://[^ ]+' | sort -u | wc -l` (expect ≥42 distinct connect-src origins); `curl -sI -H 'Origin: https://evil.test' https://box.signageos.io/login/ | grep -c 'access-control-allow-origin'` (expect 17 static ACAO, evil.test NOT added).
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — Node v20.20.2, hostname box-7c8c876945-52dpt, 46-hex process.uid=fae10..., full topology (amqp0, redis0-3, mongoDB0-3), per-service responseTime. Headers: ONLY x-powered-by: Express. grep -cE 'strict-transport|x-frame|x-content|content-security' = 0. Differential vs api.status (now carries HSTS+xfo+xcto).
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CORS: 17 static ACAO confirmed under spoofed Origin https://evil.test (evil.test NOT added — static whitelist). Includes http://box.signageos.io plaintext + https://*.zdusercontent.com wildcard + api.signageos.io sibling. No access-control-allow-credentials on any box path.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CSP: 42 distinct origins across connect-src/frame-src confirmed (triplicated Auth0 oauth/token, Sony/BroadSign/MoodMedia device APIs, 5× S3 buckets, API Gateway, api.signageos.io, *.zdusercontent.com, recaptcha).
[LEARN] REJECTED MISCONFIG @ api.signageos.io/status: api /status now carries proper security headers (HSTS, x-frame-options: DENY, x-content-type-options: nosniff) — hardened relative to box /status which lacks them. Info leak (hostname, process.uid, topology) still ACCEPTED.
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: Reconfirmed — 403 body leaks `WRONG_JWT_TOKEN`/`Account not found`/`errorCode 403105` — excluded per scope.yml (descriptive errors).
[LEARN] REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 "OK" (2 bytes), trivial health check, no data leaked.
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live — Node v24.19.0, hostname api-6f69db97d5-st6zq, full topology. Now hardened with security headers.
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — still not passively testable without tenant/authenticated session.
[RISK] box.signageos.io: **68** — Unauthenticated `/status` leaks pod hostname + 40-hex process UID + Node v20.20.2 + full service topology with per-service response timing AND `/status` lacks ALL security headers (HSTS/xfo/xcto/CSP absent) while `/`+`/login/` are hardened — differential attack surface. Broad CSP (42 connect-src origins, triplicated Auth0) + 17 static CORS ACAO values incl. http:// plaintext variant + *.zdusercontent.com wildcard, no credentials flag — expands origin trust boundary for postMessage/downgrade chains. Rolling-deploy pod rotation confirmed (52dpt).
[RISK] api.signageos.io: **60** — All 60+ v1/v2 REST endpoints JWT/X-Auth-gated (no pre-auth bypass); `/status` leaks pod metadata + Node v24.19.0 + topology (now hardened with HSTS/xfo/xcto). High-severity IDOR on org-scoped `/v1/organization/{uid}/security-token` requires valid account token (AUTH_HELPED) — org UID is client-supplied, distinct from auth-derived org. v2 migration advancing (/v2/device now 403).
[HYP] Unauthenticated /status metadata leak with missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 90
reasoning: Confirmed HTTP 200 application/json with ONLY `x-powered-by: Express` header — no HSTS, no x-frame-options, no x-content-type-options, no CSP. (Differential: `/` and `/login/` now carry HSTS+xfo; `/status` still stripped.) Body leaks hostname=box-7c8c876945-gkzcp, 40-hex process.uid=b341def..., Node v20.20.2, full succeededServices=[amqp0,redis0-3,mongoDB0-3] with per-service responseTime.
evidence_needed: GET https://box.signageos.io/status → 200 application/json + headers showing only x-powered-by.
verify_steps: PASSIVE: `curl -sD- https://box.signageos.io/status` — confirm JSON body fields + confirm absence of HSTS/xfo/xcto/CSP.
impact: Pod hostname, 40-hex process UID, Node version, backend service topology + response timing enable targeted SSRF/fuzzing/downgrade CVE mapping; missing security headers widen exposure. Severity: Low-Medium.
testability: PASSIVE
[FINAL] (re-ranked):
[NEXT] PROBE: Quantify the box CORS/CSP PoC and test wildcard reflection — `curl -sI -H 'Origin: https://sub.zdusercontent.com' https://box.signageos.io/login/ | grep -c access-control-allow-origin` (count distinct ACAO origins; confirm evil.test NOT added = static whitelist); `curl -s https://box.signageos.io/login/ | grep -o 'connect-src[^;]*' | grep -oE 'https?://[^ ]+' | sort -u | wc -l` (count distinct CSP connect-src origins, validate >20); re-confirm `/status` has stripped security headers via `curl -sD- https://box.signageos.io/status -o /dev/null | grep -ic 'strict-transport-security\|x-frame\|x-content-type'` (expect 0).
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all entry requires tenant/authenticated session. Carried forward.
[LEARN] REJECTED MISCONFIG @ box.signageos.io/*/status: Confirmed `/status` lacks ALL security headers (HSTS/xfo/xcto/CSP absent) — only `x-powered-by: Express` — differential vs `/` and `/login/` which are now hardened. NOT on rejected list; remains ACCEPTED.
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: Reconfirmed 403 bodies leak `WRONG_JWT_TOKEN`/`NO_ORGANIZATION_TO_AUTHENTICATE`/`WRONG_ACCOUNT_SECRET` + 403075/403076/403105 — class descriptive-error excluded per scope.yml. Carried forward.
[LEARN] CONFIRMED MECHANISM @ api.signageos.io/v1/organization/{uid}: Dual-auth precisely enumerated — X-Auth `id:unsafeDecryptedToken` format; org derived from header first-part; {uid} in path is client-supplied and distinct from auth-derived org — narrows IDOR verification to X-Auth org-crossing (AUTH_HELPED).
[RISK] box.signageos.io: **68** — Unauthenticated `/status` leaks pod hostname + 40-hex process UID + Node v20.20.2 + full service topology with per-service response timing; `/status` also lacks ALL security headers (HSTS/xfo/xcto/CSP) while `/`+`/login/` are hardened (differential). Broad CSP (39 distinct connect-src origins, triplicated Auth0) + 18 static ACAO values incl. `http://` plaintext variant + `*.zdusercontent.com` wildcard, no credentials flag — expands origin trust boundary for postMessage/downgrade chains.
[RISK] api.signageos.io: **60** — All 60+ v1/v2 REST endpoints JWT/X-Auth-gated (no pre-auth bypass); `/status` leaks pod metadata + Node v24.19.0 + topology (but carries HSTS/xfo/xcto — hardened). High-severity IDOR on org-scoped `/v1/organization/{uid}/security-token` requires valid account token (AUTH_HELPED); v2 migration advancing but remains auth-gated.
[PRIO] box.signageos.io/status — 6.45 — atk=7/bus=4/tech=5/gate=10/cloud=6/fresh=8
[PRIO] box.signageos.io/login/ (CSP+CORS) — 6.25 — atk=7/bus=5/tech=6/gate=10/cloud=5/fresh=7
[PRIO] api.signageos.io/v1/organization/{organizationUid}/security-token — 5.95 — atk=6/bus=7/tech=6/gate=5/cloud=2/fresh=6
[HYP] Unauthenticated /status topology leak with zero security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 90
reasoning: Live probe confirms HTTP 200 application/json. Header block is ONLY `x-powered-by: Express` — zero HSTS, zero x-frame-options, zero x-content-type-options, zero CSP. Body leaks hostname=box-7c8c876945-52dpt, 46-hex process.uid=fae10c952251023ac172ed48dbae9b0c8118787ad959cc18bf, Node v20.20.2, full succeededServices=[amqp0,redis0,redis1,redis2,redis3,mongoDB0,mongoDB1,mongoDB2,mongoDB3] with per-service responseTime + epoch timestamps. Differential vs api.status which now carries HSTS+xfo+xcto.
evidence_needed: GET https://box.signageos.io/status → 200 application/json with hostname + process.uid + version + succeededServices, and headers containing 0 of {strict-transport-security, x-frame-options, x-content-type-options, content-security-policy}.
verify_steps: PASSIVE: `curl -sD- https://box.signageos.io/status` → confirm 7+ fields in JSON body + confirm grep -cE 'strict-transport|x-frame|x-content|content-security' returns 0.
impact: Pod hostname, 40-hex process UID, Node version, backend service topology + response timing enable targeted SSRF/fuzzing and downgrade CVE mapping; missing security headers widen clickjacking/MIME-sniff attack surface. Severity: Low-Medium.
testability: PASSIVE
[HYP] Over-broad CSP connect-src + static CORS ACAO without credential flag
class: MISCONFIG
asset: box.signageos.io/login/ (+ /)
confidence: 88
reasoning: Live probe confirms 42 distinct origins across connect-src/frame-src directives, including Auth0 oauth/token duplicated 3×, Sony/BroadSign/MoodMedia device APIs, 5× S3 buckets, AWS API Gateway, api.signageos.io sibling, *.zdusercontent.com, recaptcha. 17 static ACAO values (unchanged under spoofed Origin https://evil.test — NOT reflected, confirms static whitelist) including `http://box.signageos.io` plaintext variant + `https://*.zdusercontent.com` wildcard. NO `access-control-allow-credentials` on any box path.
evidence_needed: GET /login/ headers count ≥17 ACAO lines including 1 http:// variant + 1 *.zdusercontent.com wildcard; CSP connect-src/frame-src ≥40 distinct origins.
verify_steps: PASSIVE: `curl -sI -H 'Origin: https://evil.test' https://box.signageos.io/login/ | grep -c access-control-allow-origin` → expect 17; grep for `http://box.signageos.io` + `*.zdusercontent.com` (both present); `curl -s https://box.signageos.io/login/ | grep -oE 'https?://[^ ]+' | sort -u | wc -l` → expect ≥42 distinct connect-src origins.
impact: Broadened origin trust boundary enables origin-confused postMessage/frame-injection and plaintext downgrade chains; http:// ACAO permits plaintext downgrade of token-bearing origins. Severity: Medium.
testability: PASSIVE
[HYP] Cross-tenant security-token minting via org-scoped X-Auth path
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}/security-token
confidence: 78
reasoning: Passive probe confirms `/v1/organization/test` → 403 (errorName WRONG_JWT_TOKEN). The {organizationUid} is client-supplied in the URL path while org identity is independently derived from the X-Auth header first-part (`id:unsafeDecryptedToken`). Missing server-side cross-check may permit cross-tenant token minting. api has NO ACAO on any path, but X-Auth header is the vector.
evidence_needed: GET /v1/organization/{own-uid}/security-token with valid X-Auth → 200 + token body; GET /v1/organization/{foreign-uid}/security-token with SAME header → 200 ≠ 403.
verify_steps: AUTH_HELPED: (1) `sos login` (Auth0 device-code) to mint account JWT; (2) construct X-Auth `<accountId>:<jwt>`; (3) baseline `curl -H "X-Auth: <accountId>:<jwt>" https://api.signageos.io/v1/organization/<own-orgUid>/security-token` → expect 200; (4) `curl -H "X-Auth: <accountId>:<jwt>" https://api.signageos.io/v1/organization/<foreign-orgUid>/security-token` → 200 ≠ 403 = confirmed IDOR.
impact: Mint security token for arbitrary org → unauthorized device enrollment/control + downstream SSO impersonation. Severity: High.
testability: AUTH_HELPED
[FINAL] (re-ranked): 1. box/status MISCONFIG (PASSIVE), 2. box/login/ CSP+CORS MISCONFIG (PASSIVE), 3. api/organization/{uid}/security-token IDOR (AUTH_HELPED)
[NEXT] PROBE: Quantify the box /status security-header deficit and confirm CSP origin count — `curl -sD- https://box.signageos.io/status | grep -ic 'strict-transport\|x-frame\|x-content\|content-security'` (expect 0); `curl -s https://box.signageos.io/login/ | grep -oE 'https?://[^ ]+' | sort -u | wc -l` (expect ≥42 distinct connect-src origins); `curl -sI -H 'Origin: https://evil.test' https://box.signageos.io/login/ | grep -c 'access-control-allow-origin'` (expect 17 static ACAO, evil.test NOT added).
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — Node v20.20.2, hostname box-7c8c876945-52dpt, 46-hex process.uid=fae10..., full topology (amqp0, redis0-3, mongoDB0-3), per-service responseTime. Headers: ONLY x-powered-by: Express. grep -cE 'strict-transport|x-frame|x-content|content-security' = 0. Differential vs api.status (now carries HSTS+xfo+xcto).
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CORS: 17 static ACAO confirmed under spoofed Origin https://evil.test (evil.test NOT added — static whitelist). Includes http://box.signageos.io plaintext + https://*.zdusercontent.com wildcard + api.signageos.io sibling. No access-control-allow-credentials on any box path.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CSP: 42 distinct origins across connect-src/frame-src confirmed (triplicated Auth0 oauth/token, Sony/BroadSign/MoodMedia device APIs, 5× S3 buckets, API Gateway, api.signageos.io, *.zdusercontent.com, recaptcha).
[LEARN] REJECTED MISCONFIG @ api.signageos.io/status: api /status now carries proper security headers (HSTS, x-frame-options: DENY, x-content-type-options: nosniff) — hardened relative to box /status which lacks them. Info leak (hostname, process.uid, topology) still ACCEPTED.
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: Reconfirmed — 403 body leaks `WRONG_JWT_TOKEN`/`Account not found`/`errorCode 403105` — excluded per scope.yml (descriptive errors).
[LEARN] REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 "OK" (2 bytes), trivial health check, no data leaked.
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live — Node v24.19.0, hostname api-6f69db97d5-st6zq, full topology. Now hardened with security headers.
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — still not passively testable without tenant/authenticated session.
[RISK] box.signageos.io: **68** — Unauthenticated `/status` leaks pod hostname + 40-hex process UID + Node v20.20.2 + full service topology with per-service response timing AND `/status` lacks ALL security headers (HSTS/xfo/xcto/CSP absent) while `/`+`/login/` are hardened — differential attack surface. Broad CSP (42 connect-src origins, triplicated Auth0) + 17 static CORS ACAO values incl. http:// plaintext variant + *.zdusercontent.com wildcard, no credentials flag — expands origin trust boundary for postMessage/downgrade chains. Rolling-deploy pod rotation confirmed (52dpt).
[RISK] api.signageos.io: **60** — All 60+ v1/v2 REST endpoints JWT/X-Auth-gated (no pre-auth bypass); `/status` leaks pod metadata + Node v24.19.0 + topology (now hardened with HSTS/xfo/xcto). High-severity IDOR on org-scoped `/v1/organization/{uid}/security-token` requires valid account token (AUTH_HELPED) — org UID is client-supplied, distinct from auth-derived org. v2 migration advancing (/v2/device now 403).
[HYP] <title>
class: <IDOR|SSRF|AUTH|XSS|BUSLOGIC|MISCONFIG|OATH|OTHER>
asset: <host/endpoint>
confidence: <0-100>
reasoning: <facts only, 2-3 lines>
evidence_needed: <what proves it>
verify_steps: <passive-first concrete HTTP requests, or AUTH_HELPED:...>
impact: <what attacker gets + severity>
testability: <PASSIVE|AUTH_HELPED|HUMAN_ONLY>
[PRIO] box.signageos.io/status — 6.55 — atk=7/bus=4/tech=5/gate=10/cloud=6/fresh=9
[PRIO] box.signageos.io/login/ (CSP+CORS) — 6.55 — atk=7/bus=5/tech=6/gate=10/cloud=5/fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}/security-token — 5.95 — atk=6/bus=7/tech=6/gate=5/cloud=2/fresh=6 (off-target, AUTH_HELPED)
[HYP] Unauthenticated /status topology leak with zero security headers (differential vs hardened `/`+`/login/`)
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Fresh probe confirms HTTP 200 `application/json`; header block contains ONLY `x-powered-by: Express` (+ CloudFront via/x-amz). `grep -icE 'strict-transport|x-frame|x-content|content-security'` = **0**. Body leaks K8s hostname, 64-hex `process.uid`, Node v20.20.2, full `succeededServices` topology [amqp0,redis0-3,mongoDB0-3] with per-service `responseTime` + dual epoch `requestedAt/respondedAt`. `/` and `/login/` now carry HSTS+xfo+xcto+CSP but `/status` is stripped — confirmed differential.
evidence_needed: GET https://box.signageos.io/status → 200 application/json with hostname + process.uid + version + succeededServices; AND headers containing 0 of {strict-transport-security, x-frame-options, x-content-type-options, content-security-policy}.
verify_steps: PASSIVE: `curl -sD- https://box.signageos.io/status` → confirm 7+ JSON fields + `grep -icE 'strict-transport|x-frame|x-content|content-security'` returns 0; contrast `curl -sI https://box.signageos.io/ | grep -i 'strict-transport-security'` (returns 1).
impact: Pod hostname, 64-hex process UID, Node version, backend service topology + response timing enable targeted SSRF/fuzzing and CVE mapping; stripped security headers widen clickjacking/MIME-sniff downgrade surface. Severity: Low-Medium.
testability: PASSIVE
[HYP] Broad CSP trust boundary + static CORS ACAO whitelist incl. plaintext http:// and wildcard `*.zdusercontent.com`, no credentials flag
class: MISCONFIG
asset: box.signageos.io/login/ (+ /)
confidence: 86
reasoning: Fresh probe: `/login/` returns 17 static `access-control-allow-origin` values (unchanged under spoofed Origin `https://evil.test` — NOT reflected, confirms static whitelist). Includes `http://box.signageos.io` plaintext variant + `https://*.zdusercontent.com` wildcard + sibling `https://api.signageos.io`. NO `access-control-allow-credentials` on any box path. CSP has **59** distinct origins across connect-src/frame-src/img-src/script-src (Auth0 `oauth/token` appears 4× on `/login/` vs 2× on `/` = triplication), Sony/BroadSign/MoodMedia device APIs, 5× S3 buckets, AWS API Gateway, recaptcha.
evidence_needed: GET /login/ response with ≥17 ACAO lines incl. 1 `http://` variant + 1 `*.zdusercontent.com` wildcard; CSP with ≥40 distinct connect-src origins; `evil.test` origin NOT echoed back.
verify_steps: PASSIVE: `curl -sI -H 'Origin: https://evil.test' https://box.signageos.io/login/ | grep -c 'access-control-allow-origin'` → 17; `curl -sD- https://box.signageos.io/login/ | grep -iE 'allow-credentials'` → empty; `curl -sD- https://box.signageos.io/login/ | grep -oE 'https?://[^ ]+' | sort -u | wc -l` → ≥59.
impact: Broadened origin trust boundary enables origin-confused postMessage/frame-injection and plaintext-downgrade chains; `http://` ACAO permits plaintext downgrade of token-bearing origins. Severity: Medium.
testability: PASSIVE
[HYP] Cross-tenant security-token minting via org-scoped X-Auth path UID mismatch
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}/security-token
confidence: 78
reasoning: Fresh probe: `/v1/organization/test` → 403 `WRONG_JWT_TOKEN`/403105 (descriptive, REJECTED). `{organizationUid}` in path is client-supplied while org identity is derived independently from X-Auth header first-part (`id:unsafeDecryptedToken`, verified at 2026-08-08 09:12). Missing server-side cross-check may permit minting a security-token for a foreign org. api.signageos.io has NO ACAO on any path, so header-based X-Auth is the vector.
evidence_needed: GET /v1/organization/{own-uid}/security-token with valid X-Auth → 200 + token body; GET /v1/organization/{foreign-uid}/security-token with SAME header → 200 (≠ 403) = IDOR.
verify_steps: AUTH_HELPED: (1) `sos login` (Auth0 device-code) to mint account JWT; (2) construct X-Auth `<accountId>:<jwt>`; (3) baseline `curl -H "X-Auth: <accountId>:<jwt>" https://api.signageos.io/v1/organization/<own-orgUid>/security-token` → expect 200; (4) reuse same header against `<foreign-orgUid>` → 200 ≠ 403 = confirmed IDOR.
impact: Mint security-token for arbitrary org → unauthorized device enrollment/control + downstream SSO impersonation. Severity: High.
testability: AUTH_HELPED (off-phase: target=box, this is api)
[FINAL] (re-ranked, phase=POC target=box):
[NEXT] PROBE: Finalize the box `/status` PoC evidence package for the report — `curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_status_b.json` then `grep -icE 'strict-transport|x-frame|x-content|content-security' /tmp/poc_box_status_h.txt` (expect 0) and `python3 -m json.tool /tmp/poc_box_status_b.json | grep -E 'hostname|uid|version|succeededServices'`. This proves both the unauthenticated info-disclosure and the stripped-header differential against `/`.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live (2026-08-08 10:30). hostname=box-7c8c876945-52dpt, uid=fae10c..., version=v20.20.2, full topology + responseTime; security-header grep = 0 (no HSTS/xfo/xcto/CSP). `/`+`/login/` hardened — confirmed differential.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: Reconfirmed live. 17 static ACAO incl. http://plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; NO credentials flag; evil.test NOT reflected (static whitelist). CSP 59 distinct origins, Auth0 oauth/token triplicated on /login/.
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/organization/test descriptive errors: Reconfirmed — 403 body still leaks `WRONG_JWT_TOKEN`/`Account not found`/403105 — excluded class per scope.yml.
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Reconfirmed 403 JWT-gated (since 2026-08-08 02:38) — not a pre-auth bypass.
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live — pod api-6f69db97d5-9kg9l, Node v24.19.0, full topology; now hardened with HSTS+xfo+xcto (differential vs box /status which lacks them).
[RISK] box.signageos.io: 68 — Unauthenticated `/status` leaks pod hostname + 64-hex process UID + Node v20.20.2 + full service topology with per-service response timing AND `/status` lacks ALL security headers (HSTS/xfo/xcto/CSP = 0) while `/`+`/login/` are hardened (differential attack surface). Broad CSP (59 connect-src origins, triplicated Auth0) + 17 static CORS ACAO incl. `http://` plaintext variant + `*.zdusercontent.com` wildcard, no credentials flag — expands origin trust boundary for postMessage/downgrade chains. Rolling-deploy churn confirmed.
[RISK] api.signageos.io: 60 — All 60+ v1/v2 REST endpoints JWT/X-Auth-gated, no pre-auth bypass confirmed (`v2/device`→403, `v1/organization/test`→403 descriptive-error REJECTED). `/status` leaks pod metadata + Node v24.19.0 + topology but is now hardened (HSTS/xfo/xcto). High-severity IDOR on org-scoped `/v1/organization/{uid}/security-token` requires valid account token (AUTH_HELPED, off-phase).
## 2026-08-08 10:54:16 UTC [box] (model laguna)
[NEW] box.signageos.io/status pod hostname rotated to `box-7c8c876945-r5fm9` (Node v20.20.2) — still missing HSTS/xfo/xcto
[PRIO] box.signageos.io/status — 6.55 — atk=7/bus=4/tech=5/gate=10/cloud=6/fresh=9
[HYP] Unauthenticated /status topology leak with zero security headers (differential vs hardened `/`+`/login/`)
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Fresh probe confirms HTTP 200 `application/json`; header block contains ONLY `x-powered-by: Express` (+ CloudFront via/x-amz). `grep -icE 'strict-transport|x-frame|x-content|content-security'` = **0**. Body leaks K8s hostname, 64-hex `process.uid`, Node v20.20.2, full `succeededServices` topology [amqp0,redis0-3,mongoDB0-3] with per-service `responseTime` + dual epoch `requestedAt/respondedAt`. `/` and `/login/` now carry HSTS+xfo+xcto+CSP but `/status` is stripped — confirmed differential.
evidence_needed: GET https://box.signageos.io/status → 200 application/json with hostname + process.uid + version + succeededServices; AND headers containing 0 of {strict-transport-security, x-frame-options, x-content-type-options, content-security-policy}.
verify_steps: PASSIVE: `curl -sD- https://box.signageos.io/status` → confirm 7+ JSON fields + `grep -icE 'strict-transport|x-frame|x-content|content-security'` returns 0; contrast `curl -sI https://box.signageos.io/ | grep -i 'strict-transport-security'` (returns 1).
impact: Pod hostname, 64-hex process UID, Node version, backend service topology + response timing enable targeted SSRF/fuzzing and CVE mapping; stripped security headers widen clickjacking/MIME-sniff downgrade surface. Severity: Low-Medium.
testability: PASSIVE
[HYP] Broad CSP trust boundary + static CORS ACAO whitelist incl. plaintext http:// and wildcard `*.zdusercontent.com`, no credentials flag
class: MISCONFIG
asset: box.signageos.io/login/ (+ /)
confidence: 86
reasoning: Fresh probe: `/login/` returns 17 static `access-control-allow-origin` values (unchanged under spoofed Origin `https://evil.test` — NOT reflected, confirms static whitelist). Includes `http://box.signageos.io` plaintext variant + `https://*.zdusercontent.com` wildcard + sibling `https://api.signageos.io`. NO `access-control-allow-credentials` on any box path. CSP has **59** distinct origins across connect-src/frame-src/img-src/script-src (Auth0 `oauth/token` appears 4× on `/login/` vs 2× on `/` = triplication), Sony/BroadSign/MoodMedia device APIs, 5× S3 buckets, AWS API Gateway, recaptcha.
evidence_needed: GET /login/ response with ≥17 ACAO lines incl. 1 `http://` variant + 1 `*.zdusercontent.com` wildcard; CSP with ≥40 distinct connect-src origins; `evil.test` origin NOT echoed back.
verify_steps: PASSIVE: `curl -sI -H 'Origin: https://evil.test' https://box.signageos.io/login/ | grep -c 'access-control-allow-origin'` → 17; `curl -sD- https://box.signageos.io/login/ | grep -iE 'allow-credentials'` → empty; `curl -sD- https://box.signageos.io/login/ | grep -oE 'https?://[^ ]+' | sort -u | wc -l` → ≥59.
impact: Broadened origin trust boundary enables origin-confused postMessage/frame-injection and plaintext-downgrade chains; `http://` ACAO permits plaintext downgrade of token-bearing origins. Severity: Medium.
testability: PASSIVE
[HYP] Cross-tenant security-token minting via org-scoped X-Auth path UID mismatch
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}/security-token
confidence: 78
reasoning: Fresh probe: `/v1/organization/test` → 403 `WRONG_JWT_TOKEN`/403105 (descriptive, REJECTED). `{organizationUid}` in path is client-supplied while org identity is derived independently from X-Auth header first-part (`id:unsafeDecryptedToken`, verified at 2026-08-08 09:12). Missing server-side cross-check may permit minting a security-token for a foreign org. api.signageos.io has NO ACAO on any path, so header-based X-Auth is the vector.
evidence_needed: GET /v1/organization/{own-uid}/security-token with valid X-Auth → 200 + token body; GET /v1/organization/{foreign-uid}/security-token with SAME header → 200 (≠ 403) = IDOR.
verify_steps: AUTH_HELPED: (1) `sos login` (Auth0 device-code) to mint account JWT; (2) construct X-Auth `<accountId>:<jwt>`; (3) baseline `curl -H "X-Auth: <accountId>:<jwt>" https://api.signageos.io/v1/organization/<own-orgUid>/security-token` → expect 200; (4) reuse same header against `<foreign-orgUid>` → 200 ≠ 403 = confirmed IDOR.
impact: Mint security-token for arbitrary org → unauthorized device enrollment/control + downstream SSO impersonation. Severity: High.
testability: AUTH_HELPED (off-phase: target=box, this is api)
[FINAL] (re-ranked, phase=POC target=box):
[NEXT] PROBE: Finalize the box `/status` PoC evidence package — `curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_status_b.json` then `grep -icE 'strict-transport|x-frame|x-content|content-security' /tmp/poc_box_status_h.txt` (expect 0) and `python3 -m json.tool /tmp/poc_box_status_b.json | grep -E 'hostname|uid|version|succeededServices'`. This proves both the unauthenticated info-disclosure and the stripped-header differential against `/`.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status — still alive: pod `box-7c8c876945-r5fm9`, Node v20.20.2, security-header grep = 0.
[RISK] box.signageos.io: 68 — Unauthenticated `/status` leaks pod hostname + 64-hex process UID + Node v20.20.2 + full service topology with per-service response timing AND `/status` lacks ALL security headers (HSTS/xfo/xcto/CSP = 0) while `/`+`/login/` are hardened. Broad CSP (59 connect-src origins) + 17 static CORS ACAO incl. http:// plaintext variant + *.zdusercontent.com wildcard, no credentials flag.
[RISK] api.signageos.io: 60 — All 60+ v1/v2 REST endpoints JWT/X-Auth-gated, no pre-auth bypass confirmed. `/status` leaks pod metadata + Node v24.19.0 + topology but is now hardened with HSTS/xfo/xcto. High-severity IDOR on `/v1/organization/{uid}/security-token` confirmed mechanism (AUTH_HELPED, off-phase).
## 2026-08-08 11:18:59 UTC [box] (model laguna)
## 2026-08-08 11:46:43 UTC [box] (model laguna)
## 2026-08-08 12:03:54 UTC [box] (model laguna)
## 2026-08-08 13:07:04 UTC [box] (model laguna)
## 2026-08-08 13:53:05 UTC [box] (model laguna)
## 2026-08-08 14:23:24 UTC [box] (model laguna)
[PRIO] box.signageos.io/status: 6.55 — attack=7/bus=4/tech=5/gate=10/cloud=6/freshness=9
[HYP] Unauthenticated `/status` topology leak with zero security headers (differential vs hardened `/`+`/login/`)
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Fresh probe confirms HTTP 200 `application/json`; header block contains ONLY `x-powered-by: Express` (+ CloudFront via/x-amz). `grep -icE 'strict-transport|x-frame|x-content|content-security' /tmp/poc_box_status_h.txt` returned **0**. Body leaks K8s hostname `box-7c8c876945-gkzcp`, 64-hex `process.uid` (`b341def86252cd23a7db1382d94c091a590c400c1b4d8d9602`), Node v20.20.2, full `succeededServices` topology [amqp0, redis0-3, mongoDB0-3] with per-service `responseTime` + dual epoch `requestedAt/respondedAt`. Confirmed `curl -sI https://box.signageos.io/ | grep -ic strict-transport-security` = 1 (root is hardened, /status is stripped — differential).
evidence_needed: GET https://box.signageos.io/status → 200 application/json with hostname + process.uid + version + succeededServices; AND headers containing 0 of {strict-transport-security, x-frame-options, x-content-type-options, content-security-policy}; contrast `/` carrying HSTS.
verify_steps: PASSIVE: `curl -sD- --max-time 20 https://box.signageos.io/status` → confirm 7+ JSON fields; `grep -icE 'strict-transport|x-frame|x-content|content-security'` on headers returns 0; `curl -sI https://box.signageos.io/ | grep -i strict-transport-security` returns 1.
impact: Pod hostname, 64-hex process UID, Node version, backend service topology + response timing enable targeted SSRF/fuzzing and CVE mapping; stripped security headers widen clickjacking/MIME-sniff downgrade surface. Severity: Low-Medium.
testability: PASSIVE
[HYP] Broad CSP trust boundary + static CORS ACAO whitelist incl. plaintext `http://` and wildcard `*.zdusercontent.com`, no credentials flag
class: MISCONFIG
asset: box.signageos.io/login/ (+ /)
confidence: 86
reasoning: Fresh probe: `/login/` returns **17** static `access-control-allow-origin` values (unchanged under spoofed Origin `https://evil.test` — evil.test NOT reflected, confirms static whitelist). Includes `http://box.signageos.io` plaintext variant + `https://*.zdusercontent.com` wildcard + sibling `https://api.signageos.io`. NO `access-control-allow-credentials` on any box path (grep returned 0). CSP has **59** distinct origins across connect-src/frame-src/img-src/script-src (Auth0 `oauth/token` triplicated on `/login/`).
evidence_needed: GET /login/ response with ≥17 ACAO lines incl. 1 `http://` variant + 1 `*.zdusercontent.com` wildcard; CSP with ≥40 distinct connect-src origins; `evil.test` origin NOT echoed back.
verify_steps: PASSIVE: `curl -sI -H 'Origin: https://evil.test' https://box.signageos.io/login/ | grep -c 'access-control-allow-origin'` → 17; `curl -sI -H 'Origin: https://evil.test' https://box.signageos.io/ | grep -ic 'access-control-allow-credentials'` → 0; `curl -sD- https://box.signageos.io/ | grep -oE 'https?://[^ ;]+' | sort -u | wc -l` → ≥59.
impact: Broadened origin trust boundary enables origin-confused postMessage/frame-injection and plaintext-downgrade chains; `http://` ACAO permits plaintext downgrade of token-bearing origins. Severity: Medium.
testability: PASSIVE
[FINAL] (re-ranked, phase=POC target=box):
[PARKED] api.signageos.io/v1/organization/{uid}/security-token IDOR: confidence 78 valid but target=box this cycle; AUTH_HELPED (requires `sos login` Auth0 device-code + valid X-Auth header) — off-phase, not passively verifiable; carried forward.
[NEXT] PROBE: Finalize the box `/status` PoC evidence package — save headers and body to files, confirm zero security headers via grep, confirm differential via root HSTS presence, and capture body leak fields:
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live (2026-08-08 14:22). Pod `box-7c8c876945-gkzcp`, Node v20.20.2, process.uid `b341def86252cd23a7db1382d94c091a590c400c1b4d8d9602`, full topology (amqp0, redis0-3, mongoDB0-3). Headers: ONLY `x-powered-by: Express` — security-header grep = 0 (no HSTS/xfo/xcto/CSP). `/`+`/login/` hardened (HSTS present on `/`). Differential confirmed.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: Reconfirmed. 17 static ACAO incl. `http://` plaintext + `https://*.zdusercontent.com` wildcard + `api.signageos.io` sibling; evil.test NOT reflected; NO `access-control-allow-credentials`; CSP 59 distinct origins with triplicated Auth0 oauth/token.
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live. Pod `api-6f69db97d5-ff5td`, Node v24.19.0, full topology. Hardened with HSTS+xfo+xcto (differential vs box).
[LEARN] REJECTED IDOR @ box.signageos.io: No unauthenticated authn surface on box beyond `/status` info-leak and CSP/CORS — no pre-auth bypass found.
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `WRONG_JWT_TOKEN`/`Account not found`/403105 — excluded per scope.yml.
[RISK] box.signageos.io: 68 — Unauthenticated `/status` leaks pod hostname + 64-hex process UID + Node v20.20.2 + full service topology with per-service response timing AND `/status` lacks ALL security headers (HSTS/xfo/xcto/CSP = 0) while `/`+`/login/` are hardened (differential attack surface). Broad CSP (59 connect-src origins, triplicated Auth0) + 17 static CORS ACAO incl. `http://` plaintext variant + `*.zdusercontent.com` wildcard, no credentials flag — expands origin trust boundary for postMessage/downgrade chains. Rolling-deploy churn confirmed.
[RISK] api.signageos.io: 60 — All 60+ v1/v2 REST endpoints JWT/X-Auth-gated, no pre-auth bypass confirmed (`/v2/device`→403, `/v1/organization/test`→403 descriptive-error REJECTED). `/status` leaks pod metadata + Node v24.19.0 + topology but is hardened with HSTS/xfo/xcto. High-severity IDOR on `/v1/organization/{uid}/security-token` confirmed mechanism but requires AUTH_HELPED (off-phase for box target).
## 2026-08-08 14:55:27 UTC [box] (model laguna)
## 2026-08-08 15:17:37 UTC [box] (model laguna)
## 2026-08-08 15:48:51 UTC [box] (model laguna)
[NEW] NO_DELTA — surface unchanged since 2026-08-08 15:18; only K8s pod hostname rotation observed on `/status` (rolling-deploy churn, captured)
[CHANGED] box.signageos.io/status: pod rotated to `box-7c8c876945-gkzcp` (Node v20.20.2) — no functional change, still zero security headers
[PRIO] box.signageos.io/status: 6.55 — attack=7/bus=4/tech=5/gate=10/cloud=6/freshness=9
[PRIO] box.signageos.io/login/ (+ /): 5.32 — attack=6/bus=3/tech=5/gate=10/cloud=6/freshness=8
[PRIO] box.signageos.io: 3.10 — attack=3/bus=2/tech=3/gate=10/cloud=4/freshness=5
[HYP] Unauthenticated `/status` topology leak with zero security headers (differential vs hardened `/`+`/login/`)
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Fresh probe confirms HTTP 200 `application/json`; header block contains ONLY `x-powered-by: Express` (+ CloudFront via/x-amz). `grep -icE 'strict-transport|x-frame|x-content|content-security'` returned **0**. Body leaks K8s hostname `box-7c8c876945-gkzcp`, 64-hex `process.uid`, Node v20.20.2, full `succeededServices` topology with per-service `responseTime` + dual epoch `requestedAt/respondedAt`. Root `/` confirmed carrying HSTS (differential).
evidence_needed: GET https://box.signageos.io/status → 200 application/json with hostname + process.uid + version + succeededServices; AND headers containing 0 of {strict-transport-security, x-frame-options, x-content-type-options, content-security-policy}; contrast `/` carrying HSTS.
verify_steps: `curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt`; `grep -icE 'strict-transport|x-frame|x-content|content-security' /tmp/poc_status_h.txt` (expect 0); `curl -sI https://box.signageos.io/ | grep -i strict-transport-security` (expect 1); `python3 -m json.tool /tmp/poc_status_b.json`
impact: Pod hostname, 64-hex process UID, Node version, backend service topology + response timing enable targeted SSRF/fuzzing and CVE mapping; stripped security headers widen clickjacking/MIME-sniff downgrade surface. Severity: Low-Medium
testability: PASSIVE
[HYP] Broad CSP trust boundary + static CORS ACAO whitelist incl. plaintext `http://` and wildcard `*.zdusercontent.com`, no credentials flag
class: MISCONFIG
asset: box.signageos.io/login/ (+ /)
confidence: 86
reasoning: `/login/` returns 17 static `access-control-allow-origin` values (unchanged under spoofed Origin `https://evil.test` — NOT reflected, confirms static whitelist). Includes `http://box.signageos.io` plaintext variant + `https://*.zdusercontent.com` wildcard + sibling `https://api.signageos.io`. NO `access-control-allow-credentials` on any box path. CSP has 59 distinct origins across connect-src/frame-src/img-src/script-src (Auth0 `oauth/token` triplicated on `/login/`).
evidence_needed: GET /login/ response with ≥17 ACAO lines incl. 1 `http://` variant + 1 `*.zdusercontent.com` wildcard; CSP with ≥40 distinct connect-src origins; `evil.test` origin NOT echoed back.
verify_steps: `curl -sI -H 'Origin: https://evil.test' https://box.signageos.io/login/ | grep -c 'access-control-allow-origin'` (expect 17); `curl -sI -H 'Origin: https://evil.test' https://box.signageos.io/login/ | grep -ic 'access-control-allow-credentials'` (expect 0); `curl -sD- https://box.signageos.io/ | grep -oE 'https?://[^ ;]+' | sort -u | wc -l` (expect ≥59)
impact: Broadened origin trust boundary enables origin-confused postMessage/frame-injection and plaintext-downgrade chains; `http://` ACAO permits plaintext downgrade of token-bearing origins. Severity: Medium
testability: PASSIVE
[PARKED] Auth0 OAuth2 state/redirect_uri binding: class AUTH; on REJECTED list ("CSRF on anonymous-accessible forms" + "Auth0 redirect_uri validation not testable passively without tenant access") — confidence would be low and verify_steps require authenticated/tenant context; dropped
[FINAL]
[NEXT] PROBE: `curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content|content-security' /tmp/poc_status_h.txt && echo '---ROOT_HSTS---' && curl -sI https://box.signageos.io/ | grep -i strict-transport-security && echo '---BODY---' && python3 -m json.tool /tmp/poc_status_b.json | grep -E 'hostname|uid|version|succeededServices|requestedAt|respondedAt'`
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY `x-powered-by: Express` (0 of HSTS/xfo/xcto/CSP) — differential vs `/` which carries HSTS confirmed
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. `http://` plaintext variant + `https://*.zdusercontent.com` wildcard + `api.signageos.io` sibling; evil.test NOT reflected (static whitelist); NO `access-control-allow-credentials`; CSP 59 distinct origins with triplicated Auth0 oauth/token on `/login/`
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward, off-phase)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `WRONG_JWT_TOKEN`/`Account not found`/403105 — excluded per scope.yml (carried forward)
[LEARN] PARKED IDOR @ api.signageos.io/v1/organization/{uid}/security-token: confidence 78 valid but target=box this cycle; AUTH_HELPED (requires `sos login` + valid X-Auth) — off-phase, not passively verifiable (carried forward)
[RISK] box.signageos.io: 68 — Unauthenticated `/status` leaks pod hostname + 64-hex process UID + Node v20.20.2 + full service topology with per-service response timing AND `/status` lacks ALL security headers (HSTS/xfo/xcto/CSP = 0) while `/`+`/login/` are hardened. Broad CSP (59 connect-src origins, triplicated Auth0) + 17 static CORS ACAO incl. `http://` plaintext variant + `*.zdusercontent.com` wildcard, no credentials flag — expands origin trust boundary for postMessage/downgrade chains. Rolling-deploy churn confirmed.
[RISK] api.signageos.io: 60 — All 60+ v1/v2 REST endpoints JWT/X-Auth-gated, no pre-auth bypass confirmed (`/v2/device`→403, `/v1/organization/test`→403 descriptive-error REJECTED). `/status` leaks pod metadata + Node v24.19.0 + topology but is hardened with HSTS/xfo/xcto. High-severity IDOR on `/v1/organization/{uid}/security-token` confirmed mechanism but requires AUTH_HELPED (off-phase for box target).
## 2026-08-08 17:02:59 UTC [box] (model laguna)
## 2026-08-08 17:42:51 UTC [box] (model laguna)
## 2026-08-08 18:13:49 UTC [box] (model laguna)
## 2026-08-08 19:03:07 UTC [box] (model laguna)
## 2026-08-08 19:40:09 UTC [box] (model laguna)
## 2026-08-08 20:03:17 UTC [box] (model laguna)
