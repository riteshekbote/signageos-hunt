# Ranked Hypotheses

## SEED 2026-08-07 (from passive recon, not model-generated yet)
- [55] api.signageos.io: 200-on-root API — enumerate auth model and API surface for authz/logic flaws (from inventory seed)
- [50] box.signageos.io: 302 redirect flow — check session handling and post-login logic (from inventory seed)
- [45] signageos org sdk/cli repos: first-party client code referencing api endpoints — map endpoints for logic hunting (from inventory seed)

## RANKED HYPOTHESES 2026-08-07 18:32:56 UTC
- [65] box.signageos.io/login: Auth0 redirect_uri validation bypass on box.signageos.io (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): RAG: Clone and grep signageos/sdk (TypeScript) and signageos/cli repos for API baseURL patterns, auth header construction, and endpoint paths — this maps the hi
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation not testable passively without tenant config access
- LEARN: REJECTED IDOR @ api.signageos.io: No public API endpoints discoverable via passive probing (all common paths 404)
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: Overly broad connect-src/frame-src (20+ origins) confirmed — expands postMessage/origin trust boundary

## RANKED HYPOTHESES 2026-08-07 18:56:31 UTC
- [60] api.signageos.io/v1/{device,organization,alert,...}: Cross-tenant IDOR via organizationUid on api.signageos.io /v1 (from reports/hypotheses-bigpickle.txt)
- [50] api.signageos.io/: api.signageos.io responds with API JSON when proper Accept header sent (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: GET https://api.signageos.io/ -H "Accept: application/json" -H "Authorization: Bearer null" -H "x-api-key: test" — observe Content-Type and body for JSON
- NEXT(hypotheses-bigpickle.txt): RAG: fetch public REST-API docs `https://docs.signageos.io/hc/en-us/articles/4405231278482` (REST APIs) and `https://docs.signageos.io/hc/en-us/articles/4405239
- LEARN: REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state parameter — class AUTH excluded as "CSRF on forms that are available to anonymous users" per
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: overly broad connect-src/frame-src (20+ origins) confirmed — expands postMessage/origin trust boundary (carried forwa
- LEARN: REJECTED IDOR @ api.signageos.io via undiscovered versioned endpoints: no public endpoints discoverable via passive probing (all common paths 404) — carried for
- LEARN: REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state parameter — class AUTH excluded as "CSRF on forms that are available to anonymous users" per
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: overly broad connect-src/frame-src (20+ origins) confirmed — expands postMessage/origin trust boundary (carried forwa
- LEARN: REJECTED IDOR @ api.signageos.io via undiscovered versioned endpoints: no public endpoints discoverable via passive probing (all common paths 404) — carried for

## RANKED HYPOTHESES 2026-08-07 19:26:08 UTC
- [50] api.signageos.io/: api.signageos.io responds with API JSON when proper Accept header sent (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): RAG: Clone and grep signageos/sdk (TypeScript) and signageos/cli repos for API baseURL patterns, auth header construction, and endpoint paths — this maps the hi
- LEARN: REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state parameter — class AUTH excluded as "CSRF on forms that are available to anonymous users" per
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: overly broad connect-src/frame-src (20+ origins) confirmed — expands postMessage/origin trust boundary (carried forwa
- LEARN: REJECTED IDOR @ api.signageos.io via undiscovered versioned endpoints: no public endpoints discoverable via passive probing (all common paths 404) — carried for

## RANKED HYPOTHESES 2026-08-07 20:15:16 UTC
- [75] box.signageos.io/status: box.signageos.io /status Infrastructure Information Disclosure (from reports/hypotheses-laguna.txt)
- [55] api.signageos.io/v1/organization/{organizationUID}/security-token: Cross-tenant org-token minting via account token (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-bigpickle.txt): RAG: fetch `github.com/signageos/sdk` source to confirm exact `X-Auth` construction for v1/v2, the account-token mint call shape (`identification`/`password` pa
- NEXT(hypotheses-laguna.txt): RAG: Clone `github.com/signageos/sdk` and grep for: (1) `apiBase`/`baseUrl`/`API_URL` constants → full endpoint paths; (2) `Authorization` header construction (
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed NEW. Unauthenticated JSON health endpoint leaks K8s pod hostname, process UID, Node version, and backend
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: Confirmed NEW. 18× static `access-control-allow-origin` headers (incl `http://` HTTP variant + `https://*.zdusercont
- LEARN: REJECTED IDOR @ api.signageos.io: Real `/v1/*` endpoints confirmed via client bundle (bundle.js) — 40+ paths mapped. BUT all return 403 with `WRONG_JWT_TOKEN`/`
- LEARN: REJECTED MISCONFIG @ api.signageos.io: 403 error body leaks descriptive auth detail (`"Account not found"`, `"Decoding of provided JWT token has failed"`, `erro
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation — still not testable passively without tenant config access (carried forward).
- LEARN: REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state — excluded per "CSRF on anonymous-accessible forms" (carried forward).

## RANKED HYPOTHESES 2026-08-07 21:04:45 UTC
- [90] box.signageos.io/status: box.signageos.io/status: Unauthenticated Infrastructure Information Disclosure (from reports/hypotheses-laguna.txt)
- [55] api.signageos.io/v1/device/{uid}/peer-recovery: Cross-tenant peer-recovery read/write via legacy client-secret not bound to target device UID (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-laguna.txt): RAG: Clone `github.com/signageos/sdk`, grep `src/api/` + `src/auth/` for (1) any `/v1/` or `/v2/` endpoint invoked WITHOUT JWT/X-Auth at initialization (pre-aut
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname (rotating: gkzcp → mtnct), p
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: Confirmed live. 18 static ACAO values on / (302) + /login/ (200), unchanged under spoofed Origin `https://evil.test`
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: Confirmed live. /login/ CSP broadened vs / (triplicated Auth0 oauth/token, additional recaptcha frame-src). 40+ conne
- LEARN: REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 `OK` (2 bytes) — trivial health check, no data leaked. Not reportable.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All 60+ endpoints return 403 JWT-gated (WRONG_JWT_TOKEN/403105). No pre-auth bypass. Dual auth confirmed: JWT Bearer
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: 403/404 carry `vary: Origin` + `access-control-expose-headers: *` but NO ACAO under any Origin — not CORS-exploitabl
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation — not testable passively without tenant config access (carried forward).
- LEARN: REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state — excluded per "CSRF on anonymous-accessible forms" (carried forward).
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 4

## RANKED HYPOTHESES 2026-08-07 21:34:19 UTC
- [60] api.signageos.io/v1/{device,organization,alert,...}: Cross-tenant IDOR via organizationUid on api.signageos.io /v1 (from reports/hypotheses-bigpickle.txt)
- [60] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant org security-token minting via account token + client-supplied organizationUid (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): RAG: Clone `github.com/signageos/sdk` and grep `src/api/` + `src/auth/` + `src/requester.ts` for: (1) exact `X-Auth` header construction (`id:unsafeDecryptedTok
- NEXT(hypotheses-bigpickle.txt): RAG: fetch public REST-API docs `https://docs.signageos.io/hc/en-us/articles/4405231278482` (REST APIs) and `https://docs.signageos.io/hc/en-us/articles/4405239
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname (rotating: gkzcp → mtnct), p
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: Confirmed live. 18 static ACAO values on / (302) + /login/ (200), unchanged under spoofed Origin `https://evil.test`
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: Confirmed live. /login/ CSP broadened vs / (triplicated Auth0 oauth/token, additional recaptcha frame-src). 40+ conne
- LEARN: REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 `OK` (2 bytes) — trivial health check, no data leaked. Not reportable.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All 60+ endpoints return 403 JWT-gated (WRONG_JWT_TOKEN/403105). No pre-auth bypass. Dual auth confirmed: JWT Bearer
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: 403/404 carry `vary: Origin` + `access-control-expose-headers: *` but NO ACAO under any Origin — not CORS-exploitabl
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation — not testable passively without tenant config access (carried forward).
- LEARN: REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state — excluded per "CSRF on anonymous-accessible forms" (carried forward).
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 4

## RANKED HYPOTHESES 2026-08-07 22:07:31 UTC
- [65] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant org security-token minting via account token + client-supplied organizationUid (from reports/hypotheses-nemotron3.txt)
- [60] api.signageos.io/v1/{device,organization,alert,...}: Cross-tenant IDOR via organizationUid on api.signageos.io /v1 (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-nemotron3.txt): RAG: Clone `github.com/signageos/sdk` and grep `src/api/` + `src/auth/` + `src/requester.ts` for: (1) exact `X-Auth` header construction (`id:unsafeDecryptedTok
- NEXT(hypotheses-bigpickle.txt): RAG: fetch public REST-API docs `https://docs.signageos.io/hc/en-us/articles/4405231278482` (REST APIs) and `https://docs.signageos.io/hc/en-us/articles/4405239
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname (rotating: gkzcp → mtnct), p
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: Confirmed live. 18 static ACAO values on / (302) + /login/ (200), unchanged under spoofed Origin `https://evil.test`
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: Confirmed live. /login/ CSP broadened vs / (triplicated Auth0 oauth/token, additional recaptcha frame-src). 40+ conne
- LEARN: REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 `OK` (2 bytes) — trivial health check, no data leaked. Not reportable.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All 60+ endpoints return 403 JWT-gated (WRONG_JWT_TOKEN/403105). No pre-auth bypass. Dual auth confirmed: JWT Bearer
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: 403/404 carry `vary: Origin` + `access-control-expose-headers: *` but NO ACAO under any Origin — not CORS-exploitabl
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation — not testable passively without tenant config access (carried forward).
- LEARN: REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state — excluded per "CSRF on anonymous-accessible forms" (carried forward).
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 4
- LEARN: ACCEPTED SECRET_LEAK @ github.com/signageos/videowall-designer: Hardcoded clientId/secret (SHA256 `564c293ba2a1d60dd6e8f508a7ef65400424ae42b80be0ae04498d528a8a7
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname (rotating: gkzcp → mtnct), p
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: Confirmed live. 18 static ACAO values on / (302) + /login/ (200), unchanged under spoofed Origin `https://evil.test`
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: Confirmed live. /login/ CSP broadened vs / (triplicated Auth0 oauth/token, additional recaptcha frame-src). 40+ conne
- LEARN: REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 `OK` (2 bytes) — trivial health check, no data leaked. Not reportable.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All 60+ endpoints return 403 JWT-gated (WRONG_JWT_TOKEN/403105). No pre-auth bypass. Dual auth confirmed: JWT Bearer
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: 403/404 carry `vary: Origin` + `access-control-expose-headers: *` but NO ACAO under any Origin — not CORS-exploitabl
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation — not testable passively without tenant config access (carried forward).
- LEARN: REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state — excluded per "CSRF on anonymous-accessible forms" (carried forward).
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 4

## RANKED HYPOTHESES 2026-08-07 22:51:50 UTC
- [72] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account token (from reports/hypotheses-bigpickle.txt)
- [65] api.signageos.io/v1/organization/{uid}/security-token: api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant org security-token minting via account token + client-supplied organizationUid (from reports/hypotheses-laguna.txt)
- [65] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant org security-token minting via account token + client-supplied organizationUid (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): RAG: Clone `github.com/signageos/sdk` and grep `src/api/` + `src/auth/` + `src/requester.ts` for: (1) exact `X-Auth` header construction (`id:unsafeDecryptedTok
- NEXT(hypotheses-bigpickle.txt): HUMAN: Execute H1 POC with one box-minted account token — `sos login` (Auth0 device-code) then `curl -H "X-Auth: <acctId>:<acctToken>" https://api.signageos.io/
- NEXT(hypotheses-laguna.txt): RAG: Clone github.com/signageos/sdk and grep src/api/ + src/auth/ + src/requester.ts for: (1) exact X-Auth header construction (id:unsafeDecryptedToken format),
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname (rotating: gkzcp → mtnct), p
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: Confirmed live. 18 static ACAO values on / (302) + /login/ (200), unchanged under spoofed Origin `https://evil.test`
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: Confirmed live. /login/ CSP broadened vs / (triplicated Auth0 oauth/token, additional recaptcha frame-src). 40+ conne
- LEARN: REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 `OK` (2 bytes) — trivial health check, no data leaked. Not reportable.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All 60+ endpoints return 403 JWT-gated (WRONG_JWT_TOKEN/403105). No pre-auth bypass. Dual auth confirmed: JWT Bearer
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: 403/404 carry `vary: Origin` + `access-control-expose-headers: *` but NO ACAO under any Origin — not CORS-exploitabl
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation — not testable passively without tenant config access (carried forward).
- LEARN: REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state — excluded per "CSRF on anonymous-accessible forms" (carried forward).
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 4
- LEARN: ACCEPTED SECRET_LEAK @ github.com/signageos/videowall-designer: Hardcoded clientId/secret (SHA256 `564c293ba2a1d60dd6e8f508a7ef65400424ae42b80be0ae04498d528a8a7
- LEARN: REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 `OK` (2 bytes) — trivial health check, no data leaked. Not reportable.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname, process UID, Node v20.20.2,
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All endpoints return 403 JWT-gated without pre-auth bypass. Requires AUTH_HELPED verification.
- LEARN: REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 `OK` (2 bytes) — trivial health check, no data leaked. Not reportable.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname, process UID, Node v20.20.2,
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All endpoints return 403 JWT-gated without pre-auth bypass. Requires AUTH_HELPED verification.

## RANKED HYPOTHESES 2026-08-07 23:28:25 UTC
- [90] box.signageos.io/status: box.signageos.io/status: Persistent Infrastructure Information Disclosure — pod topology + Node version + service names (amqp0, redis0-3, mongoDB0-3) (from reports/hypotheses-laguna.txt)
- [72] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account token (from reports/hypotheses-bigpickle.txt)
- [65] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant org security-token minting via account token + client-supplied organizationUid (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): RAG: Clone `github.com/signageos/sdk` and grep `src/api/` + `src/auth/` + `src/requester.ts` for: (1) exact `X-Auth` header construction (`id:unsafeDecryptedTok
- NEXT(hypotheses-bigpickle.txt): HUMAN: Execute H1 POC with one box-minted account token — `sos login` (Auth0 device-code), baseline `curl -H "X-Auth: <acctId>:<acctToken>" https://api.signageo
- NEXT(hypotheses-laguna.txt): HUMAN: Transition POC target from box → api for AUTH_HELPED verification of the two top-ranked cross-tenant IDOR hypotheses carried forward from seed analysis:
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname (rotating: gkzcp → st6zq), p
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname (rotating: gkzcp → bk4vh), p
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: Confirmed live. 18 static ACAO values on / (302) + /login/ (200), unchanged under spoofed Origin `https://evil.test`
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: Confirmed live. /login/ CSP broadened vs / (triplicated Auth0 oauth/token, additional recaptcha frame-src). 40+ conne
- LEARN: REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 `OK` (2 bytes) — trivial health check, no data leaked. Not reportable.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All 60+ endpoints return 403 JWT-gated (WRONG_JWT_TOKEN/403105). No pre-auth bypass. Dual auth confirmed: JWT Bearer
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: 403/404 carry `vary: Origin` + `access-control-expose-headers: *` but NO ACAO under any Origin — not CORS-exploitabl
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation — not testable passively without tenant config access (carried forward).
- LEARN: REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state — excluded per "CSRF on anonymous-accessible forms" (carried forward).
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 4
- LEARN: ACCEPTED SECRET_LEAK @ github.com/signageos/videowall-designer: Hardcoded clientId/secret (SHA256 `564c293ba2a1d60dd6e8f508a7ef65400424ae42b80be0ae04498d528a8a7
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live. HTTP 200 JSON leaks pod hostname (box-7c8c876945-gkzcp), process UID (b341def86253cd23a7db1382d9
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: Reconfirmed live. 18 static ACAO values on / (302) + /login/ (200), unchanged under spoofed Origin https://evil.test
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: Reconfirmed live. /login/ CSP triplicates Auth0 oauth/token entries, 33 distinct origin patterns across connect-src/f
- LEARN: REJECTED MISCONFIG @ box.signageos.io /ready: Reconfirmed. Returns 200 "OK" (2 bytes), trivial health check, no data leaked. Not reportable.
- LEARN: REJECTED AUTH @ box.signageos.io/login: All Auth0 OAuth2 flow parameters hidden in minified bundle.js (v2.192.0); redirect_uri validation, OAuth2 state binding 
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: Confirmed — 403/404 responses carry vary: Origin + access-control-expose-headers: * but NO ACAO under any Origin. No

## RANKED HYPOTHESES 2026-08-07 23:54:39 UTC
- [72] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account token (from reports/hypotheses-bigpickle.txt)
- [65] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant org security-token minting via account token + client-supplied organizationUid (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): RAG: Clone `github.com/signageos/sdk` and grep `src/api/` + `src/auth/` + `src/requester.ts` for: (1) exact `X-Auth` header construction (`id:unsafeDecryptedTok
- NEXT(hypotheses-bigpickle.txt): HUMAN: Execute H1 POC with one box-minted account token — `sos login` (Auth0 device-code), baseline `curl -H "X-Auth: <acctId>:<acctToken>" https://api.signageo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live. HTTP 200 JSON leaks pod hostname (box-7c8c876945-52dpt), process UID, Node v20.20.2, service top
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live. HTTP 200 JSON leaks pod hostname (api-6f69db97d5-97fjw), process UID, Node v24.19.0, service top
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: Reconfirmed live. 18 static ACAO values on / (302) + /login/ (200), unchanged under spoofed Origin https://evil.test
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: Reconfirmed live. /login/ CSP triplicates Auth0 oauth/token entries, 33+ distinct origin patterns across connect-src/
- LEARN: REJECTED MISCONFIG @ box.signageos.io /ready: Reconfirmed. Returns 200 "OK" (2 bytes), trivial health check, no data leaked. Not reportable.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All endpoints return 403 JWT-gated without pre-auth bypass. Requires AUTH_HELPED verification.
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: Confirmed — 403/404 responses carry vary: Origin + access-control-expose-headers: * but NO ACAO under any Origin. No
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 flow parameters hidden in minified bundle.js (v2.192.0); redirect_uri validation, OAuth2 state binding — no
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 4
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname (rotating: gkzcp → st6zq), p
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname (rotating: gkzcp → bk4vh), p
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: Confirmed live. 18 static ACAO values on / (302) + /login/ (200), unchanged under spoofed Origin `https://evil.test`
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: Confirmed live. /login/ CSP broadened vs / (triplicated Auth0 oauth/token, additional recaptcha frame-src). 40+ conne
- LEARN: REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 `OK` (2 bytes) — trivial health check, no data leaked. Not reportable.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All 60+ endpoints return 403 JWT-gated (WRONG_JWT_TOKEN/403105). No pre-auth bypass. Dual auth confirmed: JWT Bearer
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: 403/404 carry `vary: Origin` + `access-control-expose-headers: *` but NO ACAO under any Origin — not CORS-exploitabl
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation — not testable passively without tenant config access (carried forward).
- LEARN: REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state — excluded per "CSRF on anonymous-accessible forms" (carried forward).
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 4
- LEARN: ACCEPTED SECRET_LEAK @ github.com/signageos/videowall-designer: Hardcoded clientId/secret (SHA256 `564c293ba2a1d60dd6e8f508a7ef65400424ae42b80be0ae04498d528a8a7

## RANKED HYPOTHESES 2026-08-08 00:49:27 UTC
- [76] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account token (from reports/hypotheses-bigpickle.txt)
- [65] api.signageos.io/v1/organization/{uid}/security-token: api.signageos.io/v1/organization/{uid}/security-token — Cross-tenant org security-token minting via account token + client-supplied organizationUid (from reports/hypotheses-laguna.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "h
- NEXT(hypotheses-bigpickle.txt): HUMAN: Execute H1 POC exactly as code-verified — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signa
- NEXT(hypotheses-laguna.txt): RAG: Clone github.com/signageos/sdk and grep src/api/ + src/auth/ + src/requester.ts for: (1) exact X-Auth header construction (id:unsafeDecryptedToken format),
- LEARN: NO_NEW_PROOF — This cycle is passive analysis only; no AUTH_HELPED tests executed. All previously ACCEPTED/REJECTED classes from 2026-08-07 23:54 reconfirmed vi
- LEARN: NO_NEW_PROOF — This cycle is passive analysis only; no AUTH_HELPED tests executed. All previously ACCEPTED/REJECTED classes from 2026-08-07 23:54 reconfirmed vi

## RANKED HYPOTHESES 2026-08-08 02:38:01 UTC
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-nemotron3.txt)
- [65] api.signageos.io/v1/organization/{uid}/security-token: api.signageos.io/v1/organization/{uid}/security-token — cross-tenant token minting (from reports/hypotheses-laguna.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "h
- LEARN: NO_NEW_PROOF — This cycle is passive analysis only; no AUTH_HELPED tests executed. All previously ACCEPTED/REJECTED classes from 2026-08-07 23:54 reconfirmed vi

## RANKED HYPOTHESES 2026-08-08 03:56:22 UTC
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account token (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "h
- NEXT(hypotheses-bigpickle.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- LEARN: NO_NEW_PROOF — This cycle is passive analysis only; no AUTH_HELPED tests executed. All previously ACCEPTED/REJECTED classes from 2026-08-07 23:54 reconfirmed vi

## RANKED HYPOTHESES 2026-08-08 04:47:05 UTC
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account token (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "h
- NEXT(hypotheses-bigpickle.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- LEARN: NO_NEW_PROOF — This cycle is passive analysis only; no AUTH_HELPED tests executed. All previously ACCEPTED/REJECTED classes from 2026-08-07 23:54 reconfirmed vi

## RANKED HYPOTHESES 2026-08-08 05:31:29 UTC
- [90] box.signageos.io/status: box.signageos.io/status — K8s pod metadata + backend topology leak (from reports/hypotheses-laguna.txt)
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "h
- NEXT(hypotheses-laguna.txt): RAG: Clone github.com/signageos/sdk and grep src/api/ + src/auth/ + src/requester.ts for: (1) exact X-Auth header construction (`id:unsafeDecryptedToken` format
- LEARN: NO_NEW_PROOF — This cycle is passive analysis only; no AUTH_HELPED tests executed. All previously ACCEPTED/REJECTED classes from 2026-08-07 23:54 reconfirmed vi
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 4
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (previously 404) — now JWT-gated, not a pre-auth bypass.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Node v20.20.2, hostname box-7c8c876945-52dpt, succeededServices (amqp0, redis0-3, mongoDB0-3).
- LEARN: REJECTED MISCONFIG @ box.signageos.io/cors: No `access-control-allow-credentials` observed on any box path despite 18 static ACAO values.

## RANKED HYPOTHESES 2026-08-08 06:07:19 UTC
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "h
- NEXT(hypotheses-bigpickle.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 4
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (previously 404) — now JWT-gated, not a pre-auth bypass
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Node v20.20.2, hostname box-7c8c876945-52dpt, succeededServices (amqp0, redis0-3, mongoDB0-3)
- LEARN: REJECTED MISCONFIG @ box.signageos.io/cors: No `access-control-allow-credentials` observed on any box path despite 18 static ACAO values
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live this cycle. Node v20.20.2, pod box-7c8c876945-gkzcp, succeededServices (amqp0, redis0-3, mongoDB0
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live this cycle. Node v24.19.0, pod api-6f69db97d5-st6zq, same topology. Unchanged.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: Reconfirmed — 17 static ACAO (incl http:// variant + https://*.zdusercontent.com), no credentials header, unchanged 
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: Reconfirmed — /login/ CSP 40+ connect-src/frame-src origins, triplicated Auth0 oauth/token. Unchanged.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. Unchanged.
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 flow params still not testable passively. Carried forward.

## RANKED HYPOTHESES 2026-08-08 07:09:50 UTC
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account token (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "h
- NEXT(hypotheses-bigpickle.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 4
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (previously 404) — now JWT-gated, not a pre-auth bypass
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live. Node v20.20.2, pod box-7c8c876945-9v4gf, succeededServices (amqp0, redis0-3, mongoDB0-3). Unchan
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live. Node v24.19.0, pod api-6f69db97d5-9kg9l, succeededServices (amqp0, redis0-3, mongoDB0-2). Unchan
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: Reconfirmed — 17 static ACAO (incl https://*.zdusercontent.com wildcard), no credentials header, unchanged under spo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: Reconfirmed — /login/ CSP 40+ connect-src/frame-src origins, triplicated Auth0 oauth/token. Unchanged.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. Unchanged.
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 flow params still not testable passively. Carried forward.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live. Node v20.20.2, pod box-7c8c876945-52dpt, succeededServices (amqp0, redis0-3, mongoDB0-3). Unchan
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live. Node v24.19.0, pod api-6f69db97d5-dw2j2, same topology. Unchanged.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: Reconfirmed — 17 static ACAO (incl http:// variant + https://*.zdusercontent.com), no credentials header, unchanged 
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: Reconfirmed — /login/ CSP 40+ connect-src/frame-src origins, triplicated Auth0 oauth/token. Unchanged.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. Unchanged.
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 flow params still not testable passively. Carried forward.

## RANKED HYPOTHESES 2026-08-08 07:58:45 UTC
- [78] api.signageos.io/v1/organization/{organizationUid}/security-token: Cross-tenant security-token minting via org-scoped X-Auth path (from reports/hypotheses-laguna.txt)
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "h
- NEXT(hypotheses-bigpickle.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- LEARN: NO_NEW_PROOF — This cycle is passive analysis only; no AUTH_HELPED tests executed. All previously ACCEPTED/REJECTED classes from 2026-08-07 23:54 reconfirmed vi
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live this cycle. Node v20.20.2, pod box-7c8c876945-gkzcp, succeededServices (amqp0, redis0-3, mongoDB0
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live this cycle. Node v24.19.0, pod api-6f69db97d5-dw2j2, same topology. Unchanged.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: Reconfirmed — 17 static ACAO (incl http:// variant + https://*.zdusercontent.com), no credentials header, unchanged 
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: Reconfirmed — /login/ CSP 40+ connect-src/frame-src origins (mapbox, events.mapbox, sentry, Auth0 oauth/token), tripl
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. Unchanged.
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 flow params still not testable passively. Carried forward.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live (pod xmdhm, Node v20.20.2, full topology). Unchanged in data shape; new headers absent (no HSTS/x
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS/CSP: Reconfirmed — 18 ACAO incl. http:// + *.zdusercontent.com, NO `access-control-allow-credentials` under any Origi
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: Returns 200 "OK" (2 bytes) trivial health check, no data leaked (carried forward).
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak `WRONG_JWT_TOKEN`/`NO_ORGANIZATION_TO_AUTHENTICATE`/`WRONG_ACCOUNT_SECRET` + erro
- LEARN: CONFIRMED MECHANISM @ api.signageos.io/v1/organization/{uid}: Dual-auth precisely enumerated — X-Auth format `id:unsafeDecryptedToken`; org identity derived fro
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 flow params not passively testable without tenant/authenticated session (carried forward).

## RANKED HYPOTHESES 2026-08-08 08:30:39 UTC
- [78] api.signageos.io/v1/organization/{organizationUid}/security-token: Cross-tenant security-token minting via org-scoped X-Auth path (from reports/hypotheses-laguna.txt)
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "h
- NEXT(hypotheses-bigpickle.txt): HUMAN: Execute the standing H1/H2 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/
- NEXT(hypotheses-laguna.txt): PROBE: `curl -sI -H 'Origin: https://evil.test' https://box.signageos.io/` and `curl -sI -H 'Origin: https://evil.test' https://box.signageos.io/login/` — enume
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `WRONG_JWT_TOKEN`/`NO_ORGANIZATION_TO_AUTHENTICATE`/`WRONG_ACCOUNT_SECRET` + error
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (previously 404) — now JWT-gated, not a pre-auth bypass (carried forward)
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live. Node v20.20.2, pod box-7c8c876945-xmdhm, succeededServices (amqp0, redis0-3, mongoDB0-3). Unchan
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live. Node v24.19.0, pod api-6f69db97d5-jnncr, same topology. Unchanged.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: Reconfirmed — 18 static ACAO (incl http:// variant + https://*.zdusercontent.com), no credentials header, unchanged 
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: Reconfirmed — /login/ CSP 40+ connect-src/frame-src origins (mapbox, events.mapbox, sentry, Auth0 oauth/token), tripl
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. Unchanged.
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 flow params not passively testable without tenant/authenticated session (carried forward).
- LEARN: CONFIRMED MECHANISM @ api.signageos.io/v1/organization/{uid}: Dual-auth precisely enumerated — X-Auth format `id:unsafeDecryptedToken`; org identity derived fro
- LEARN: REJECTED MISCONFIG @ box.signageos.io/csp-report: GET → 302 login redirect; not an exposed endpoint, report-uri/trusted-types are hardening additions, nothing r
- LEARN: REJECTED MISCONFIG @ api.signageos.io/status: No ACAO/vary headers on status path under any origin — CORS not exploitable (carried forward).
- LEARN: ACCEPTED MISCONFIG @ box/api /status: Reconfirmed live, data shape unchanged (box Node v20.20.2 / api v24.19.0, full amqp/redis/mongo topology) — carried forwar
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live this probe cycle — pod 52dpt, Node v20.20.2, full topology. Still missing HSTS/xfo/xcto (differen
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS/CSP: Reconfirmed — 18 ACAO incl. http:// + *.zdusercontent.com, NO credentials flag, unchanged under spoofed Origin. 
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — /v2/device → 403 (not 404), /v1/organization/test → 403. All endpoints JWT/X-Auth-gated, no pre-auth b
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live — pod 22g8d, Node v24.19.0, full topology. Now carries proper security headers (HSTS, xfo, xcto) 

## RANKED HYPOTHESES 2026-08-08 09:12:47 UTC
- [78] api.signageos.io/v1/organization/{organizationUid}/security-token: Cross-tenant security-token minting via org-scoped X-Auth path (from reports/hypotheses-laguna.txt)
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "h
- NEXT(hypotheses-laguna.txt): PROBE: Quantify the box CORS/CSP PoC and test wildcard reflection — `curl -sI -H 'Origin: https://sub.zdusercontent.com' https://box.signageos.io/login/ | grep 
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now carries proper security headers (HSTS, x-frame-options: DENY, x-content-type-options: nosniff) — hardening rel
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `WRONG_JWT_TOKEN`/`NO_ORGANIZATION_TO_AUTHENTICATE`/`WRONG_ACCOUNT_SECRET` + error
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (previously 404) — now JWT-gated, not a pre-auth bypass (carried forward)
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live. Node v20.20.2, pod box-7c8c876945-r5fm9, succeededServices (amqp0, redis0-3, mongoDB0-3). Still 
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live. Node v24.19.0, pod api-6f69db97d5-9kg9l, same topology. Now hardened with security headers.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 40
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 flow params not passively testable without tenant/authenticated session (carried forward).
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all en
- LEARN: REJECTED MISCONFIG @ box.signageos.io/*/status: Confirmed `/status` lacks ALL security headers (HSTS/xfo/xcto/CSP absent) — only `x-powered-by: Express` — diffe
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: Reconfirmed 403 bodies leak `WRONG_JWT_TOKEN`/`NO_ORGANIZATION_TO_AUTHENTICATE`/`WRONG_ACCOUNT_SE
- LEARN: CONFIRMED MECHANISM @ api.signageos.io/v1/organization/{uid}: Dual-auth precisely enumerated — X-Auth `id:unsafeDecryptedToken` format; org derived from header 

## RANKED HYPOTHESES 2026-08-08 09:54:23 UTC
- [90] box.signageos.io/status: Unauthenticated /status topology leak with zero security headers (from reports/hypotheses-laguna.txt)
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "h
- NEXT(hypotheses-laguna.txt): PROBE: Quantify the box /status security-header deficit and confirm CSP origin count — `curl -sD- https://box.signageos.io/status | grep -ic 'strict-transport\|
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now carries proper security headers (HSTS, x-frame-options: DENY, x-content-type-options: nosniff) — hardening rel
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `WRONG_JWT_TOKEN`/`NO_ORGANIZATION_TO_AUTHENTICATE`/`WRONG_ACCOUNT_SECRET` + error
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (previously 404) — now JWT-gated, not a pre-auth bypass (carried forward)
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live. Node v20.20.2, pod box-7c8c876945-rzvgp, succeededServices (amqp0, redis0-3, mongoDB0-3). Still 
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live. Node v24.19.0, pod api-6f69db97d5-9kg9l, same topology. Now hardened with security headers.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 40
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 flow params not passively testable without tenant/authenticated session (carried forward).
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — Node v20.20.2, hostname box-7c8c876945-52dpt, 46-hex process.uid=fae10..., full topology (amqp0
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: 17 static ACAO confirmed under spoofed Origin https://evil.test (evil.test NOT added — static whitelist). Includes h
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: 42 distinct origins across connect-src/frame-src confirmed (triplicated Auth0 oauth/token, Sony/BroadSign/MoodMedia d
- LEARN: REJECTED MISCONFIG @ api.signageos.io/status: api /status now carries proper security headers (HSTS, x-frame-options: DENY, x-content-type-options: nosniff) — h
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: Reconfirmed — 403 body leaks `WRONG_JWT_TOKEN`/`Account not found`/`errorCode 403105` — excluded 
- LEARN: REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 "OK" (2 bytes), trivial health check, no data leaked.
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live — Node v24.19.0, hostname api-6f69db97d5-st6zq, full topology. Now hardened with security headers
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — still not passively testable without tenant/authenticated session.

## RANKED HYPOTHESES 2026-08-08 10:27:07 UTC
- [95] box.signageos.io/status: Unauthenticated /status topology leak with zero security headers (from reports/hypotheses-nemotron3.txt)
- [90] box.signageos.io/status: Unauthenticated /status metadata leak with missing security headers (from reports/hypotheses-laguna.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant org token minting via org-scoped X-Auth path UID (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' — confirm zero security headers on /status
- NEXT(hypotheses-bigpickle.txt): HUMAN: Execute standing H1/H2 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>"
- NEXT(hypotheses-laguna.txt): PROBE: Quantify the box CORS/CSP PoC and test wildcard reflection — `curl -sI -H 'Origin: https://sub.zdusercontent.com' https://box.signageos.io/login/ | grep 
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname, process UID, Node v20.20.2, full service topology (amqp0, redis0-3, mongoD
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live this cycle — pod rotated to `box-7c8c876945-gkzcp`, Node v20.20.2, process.uid stable `b341def862
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed — pod `api-6f69db97d5-9kg9l`, Node v24.19.0, security headers (HSTS/xfo/xcto) present. Hardening diffe
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS/CSP: Reconfirmed — 17 static ACAO incl. `http://` variant + `https://*.zdusercontent.com`, no credentials flag; CSP c
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — /v2/device and /v1/organization/test both 403 JWT-gated with hardened headers; no pre-auth bypass surf
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all en
- LEARN: REJECTED MISCONFIG @ box.signageos.io/*/status: Confirmed `/status` lacks ALL security headers (HSTS/xfo/xcto/CSP absent) — only `x-powered-by: Express` — diffe
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: Reconfirmed 403 bodies leak `WRONG_JWT_TOKEN`/`NO_ORGANIZATION_TO_AUTHENTICATE`/`WRONG_ACCOUNT_SE
- LEARN: CONFIRMED MECHANISM @ api.signageos.io/v1/organization/{uid}: Dual-auth precisely enumerated — X-Auth `id:unsafeDecryptedToken` format; org derived from header 
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — Node v20.20.2, hostname box-7c8c876945-52dpt, 46-hex process.uid=fae10..., full topology (amqp0
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: 17 static ACAO confirmed under spoofed Origin https://evil.test (evil.test NOT added — static whitelist). Includes h
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: 42 distinct origins across connect-src/frame-src confirmed (triplicated Auth0 oauth/token, Sony/BroadSign/MoodMedia d
- LEARN: REJECTED MISCONFIG @ api.signageos.io/status: api /status now carries proper security headers (HSTS, x-frame-options: DENY, x-content-type-options: nosniff) — h
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: Reconfirmed — 403 body leaks `WRONG_JWT_TOKEN`/`Account not found`/`errorCode 403105` — excluded 
- LEARN: REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 "OK" (2 bytes), trivial health check, no data leaked.
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live — Node v24.19.0, hostname api-6f69db97d5-st6zq, full topology. Now hardened with security headers
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — still not passively testable without tenant/authenticated session.
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all en
- LEARN: REJECTED MISCONFIG @ box.signageos.io/*/status: Confirmed `/status` lacks ALL security headers (HSTS/xfo/xcto/CSP absent) — only `x-powered-by: Express` — diffe
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: Reconfirmed 403 bodies leak `WRONG_JWT_TOKEN`/`NO_ORGANIZATION_TO_AUTHENTICATE`/`WRONG_ACCOUNT_SE
- LEARN: CONFIRMED MECHANISM @ api.signageos.io/v1/organization/{uid}: Dual-auth precisely enumerated — X-Auth `id:unsafeDecryptedToken` format; org derived from header 
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — Node v20.20.2, hostname box-7c8c876945-52dpt, 46-hex process.uid=fae10..., full topology (amqp0
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: 17 static ACAO confirmed under spoofed Origin https://evil.test (evil.test NOT added — static whitelist). Includes h
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: 42 distinct origins across connect-src/frame-src confirmed (triplicated Auth0 oauth/token, Sony/BroadSign/MoodMedia d
- LEARN: REJECTED MISCONFIG @ api.signageos.io/status: api /status now carries proper security headers (HSTS, x-frame-options: DENY, x-content-type-options: nosniff) — h
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: Reconfirmed — 403 body leaks `WRONG_JWT_TOKEN`/`Account not found`/`errorCode 403105` — excluded 
- LEARN: REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 "OK" (2 bytes), trivial health check, no data leaked.
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live — Node v24.19.0, hostname api-6f69db97d5-st6zq, full topology. Now hardened with security headers
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — still not passively testable without tenant/authenticated session.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live (2026-08-08 10:30). hostname=box-7c8c876945-52dpt, uid=fae10c..., version=v20.20.2, full topology
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: Reconfirmed live. 17 static ACAO incl. http://plaintext variant + https://*.zdusercontent.com wildcar
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/organization/test descriptive errors: Reconfirmed — 403 body still leaks `WRONG_JWT_TOKEN`/`Account not found`/403105 —
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Reconfirmed 403 JWT-gated (since 2026-08-08 02:38) — not a pre-auth bypass.
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live — pod api-6f69db97d5-9kg9l, Node v24.19.0, full topology; now hardened with HSTS+xfo+xcto (differ

## RANKED HYPOTHESES 2026-08-08 10:57:22 UTC
- [95] box.signageos.io/status: Unauthenticated /status topology leak with zero security headers (differential vs hardened `/`+`/login/`) (from reports/hypotheses-laguna.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' — confirm zero security headers on /status (fi
- NEXT(hypotheses-laguna.txt): PROBE: Finalize the box `/status` PoC evidence package — `curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_statu
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname, process UID, Node v20.20.2, full service topology (amqp0, redis0-3, mongoD
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 40
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all en
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status — still alive: pod `box-7c8c876945-r5fm9`, Node v20.20.2, security-header grep = 0.

## RANKED HYPOTHESES 2026-08-08 11:21:47 UTC
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via org-scoped X-Auth path UID (from reports/hypotheses-bigpickle.txt)
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_status_b.json && cat /tmp/poc_box_status_h.txt && echo "
- NEXT(hypotheses-bigpickle.txt): PROBE: Finalize box /status PoC evidence package — `curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_status_b.tx
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod box-7c8c876945-gkzcp, Node v20.20.2, process UID b341def86252cd23a7db1382d94c091a590c400c1b
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live — pod api-6f69db97d5-22g8d, Node v24.19.0, full topology; now hardened with HSTS (max-age=3153600
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — not a pre-auth bypass
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 

## RANKED HYPOTHESES 2026-08-08 11:46:59 UTC
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via org-scoped X-Auth path UID (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-bigpickle.txt): PROBE: Finalize box /status PoC evidence package — `curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_status_b.tx

## RANKED HYPOTHESES 2026-08-08 12:04:05 UTC

## RANKED HYPOTHESES 2026-08-08 13:07:14 UTC

## RANKED HYPOTHESES 2026-08-08 13:54:14 UTC

## RANKED HYPOTHESES 2026-08-08 14:23:33 UTC
- [95] box.signageos.io/status: Unauthenticated `/status` topology leak with zero security headers (differential vs hardened `/`+`/login/`) (from reports/hypotheses-laguna.txt)
- NEXT(hypotheses-laguna.txt): PROBE: Finalize the box `/status` PoC evidence package — save headers and body to files, confirm zero security headers via grep, confirm differential via root H
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live (2026-08-08 14:22). Pod `box-7c8c876945-gkzcp`, Node v20.20.2, process.uid `b341def86252cd23a7db1
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: Reconfirmed. 17 static ACAO incl. `http://` plaintext + `https://*.zdusercontent.com` wildcard + `api
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live. Pod `api-6f69db97d5-ff5td`, Node v24.19.0, full topology. Hardened with HSTS+xfo+xcto (different
- LEARN: REJECTED IDOR @ box.signageos.io: No unauthenticated authn surface on box beyond `/status` info-leak and CSP/CORS — no pre-auth bypass found.
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `WRONG_JWT_TOKEN`/`Account not found`/403105 — excluded per scope.yml.

## RANKED HYPOTHESES 2026-08-08 14:56:41 UTC
- [95] box.signageos.io/status: Unauthenticated `/status` topology leak with zero security headers (differential vs hardened `/`+`/login/`) (from reports/hypotheses-bigpickle.txt)
- [95] box.signageos.io/status: Unauthenticated /status topology leak with zero security headers (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_status_b.json && cat /tmp/poc_box_status_h.txt && echo "
- NEXT(hypotheses-bigpickle.txt): PROBE: Finalize the box `/status` PoC evidence package — save headers and body to files, confirm zero security headers via grep, confirm differential via root H
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname, process UID, Node v20.20.2, full service topology (amqp0, redis0-3, mongoD
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 40
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all en
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live (2026-08-08 14:22). Pod `box-7c8c876945-gkzcp`, Node v20.20.2, process.uid `b341def86252cd23a7db1
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: Reconfirmed. 17 static ACAO incl. `http://` plaintext + `https://*.zdusercontent.com` wildcard + `api
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live. Pod `api-6f69db97d5-ff5td`, Node v24.19.0, full topology. Hardened with HSTS+xfo+xcto (different
- LEARN: REJECTED IDOR @ box.signageos.io: No unauthenticated authn surface on box beyond `/status` info-leak and CSP/CORS — no pre-auth bypass found.
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `WRONG_JWT_TOKEN`/`Account not found`/403105 — excluded per scope.yml.

## RANKED HYPOTHESES 2026-08-08 15:18:04 UTC

## RANKED HYPOTHESES 2026-08-08 15:49:04 UTC
- [95] box.signageos.io/status: Unauthenticated `/status` topology leak with zero security headers (differential vs hardened `/`+`/login/`) (from reports/hypotheses-laguna.txt)
- NEXT(hypotheses-laguna.txt): PROBE: `curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-conten
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. `http://` plaintext variant + `https://*.zdusercontent.com` wildcard + `api.sign
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward, 
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `WRONG_JWT_TOKEN`/`Account not found`/403105 — excluded per scope.yml (carried for
- LEARN: PARKED IDOR @ api.signageos.io/v1/organization/{uid}/security-token: confidence 78 valid but target=box this cycle; AUTH_HELPED (requires `sos login` + valid X-

## RANKED HYPOTHESES 2026-08-08 17:04:04 UTC
- [95] box.signageos.io/status: Unauthenticated /status topology leak with zero security headers (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 40
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all en

## RANKED HYPOTHESES 2026-08-08 17:43:05 UTC

## RANKED HYPOTHESES 2026-08-08 18:13:59 UTC

## RANKED HYPOTHESES 2026-08-08 19:03:14 UTC

## RANKED HYPOTHESES 2026-08-08 19:40:18 UTC

## RANKED HYPOTHESES 2026-08-08 20:07:46 UTC

## RANKED HYPOTHESES 2026-08-08 20:45:35 UTC

## RANKED HYPOTHESES 2026-08-08 21:15:22 UTC

## RANKED HYPOTHESES 2026-08-08 21:52:13 UTC
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: authorized-token test for Cross-tenant org OAuth client-secret disclosure — obtain valid account JWT via `sos login`, enumerate own org UID via /v1/organ
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 40
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all en
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos

## RANKED HYPOTHESES 2026-08-08 22:17:51 UTC
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 40
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all en
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos

## RANKED HYPOTHESES 2026-08-08 22:55:04 UTC
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 40
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all en
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos

## RANKED HYPOTHESES 2026-08-08 23:22:37 UTC
- [95] box.signageos.io/status: Unauthenticated /status info-leak with zero security headers (differential vs hardened /) (from reports/hypotheses-laguna.txt)
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content
- NEXT(hypotheses-laguna.txt): PROBE: `curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && echo '---HEADER_GREP---' && grep -icE 'stric
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 40
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all en
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Pod rotated to box-7c8c876945-chbwh (Node v20.20.2), still ONLY x-powered-by: Express with zero security headers —
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Pod rotated to api-6f69db97d5-wpppp (Node v24.19.0), security headers present — RECONFIRMED LIVE (hardened differe
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & /: 17 static ACAO reconfirmed incl http:// plaintext + *.zdusercontent.com wildcard + api.signageos.io sibling; e
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — /v2/device → 403, /v1/organization/test → 403; all JWT/X-Auth-gated, no pre-auth bypass — PARKED (AUTH

## RANKED HYPOTHESES 2026-08-08 23:53:17 UTC
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 40
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all en
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos

## RANKED HYPOTHESES 2026-08-09 01:07:13 UTC

## RANKED HYPOTHESES 2026-08-09 03:08:09 UTC

## RANKED HYPOTHESES 2026-08-09 04:36:22 UTC

## RANKED HYPOTHESES 2026-08-09 05:35:07 UTC
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 40
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all en
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos

## RANKED HYPOTHESES 2026-08-09 06:26:33 UTC

## RANKED HYPOTHESES 2026-08-09 07:34:54 UTC

## RANKED HYPOTHESES 2026-08-09 08:22:38 UTC
- [95] box.signageos.io/status: Unauthenticated /status info-leak with zero security headers (from reports/hypotheses-laguna.txt)
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content
- NEXT(hypotheses-laguna.txt): PROBE: `curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && echo '---HEADER_GREP---' && grep -icE 'stric
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 40
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all en
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod `box-7c8c876945-2g8bw` (K8s rolling rotation), Node v20.20.2, process UID `5d1934974f1fa15a
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: Reconfirmed — 17 static ACAO incl `http://box.signageos.io` plaintext + `https://*.zdusercontent.com`
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: Returns 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ box.signageos.io/csp-report: GET → 302 login redirect; not an exposed endpoint, nothing reportable
- LEARN: REJECTED IDS @ api.signageos.io/v1/*+v2/*: All 60+ endpoints 403 JWT/X-Auth-gated, no pre-auth bypass — v2/device → 403 (was 404)

## RANKED HYPOTHESES 2026-08-09 09:12:27 UTC
- [95] box.signageos.io/status: Unauthenticated /status info-leak with zero security headers (from reports/hypotheses-laguna.txt)
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content
- NEXT(hypotheses-laguna.txt): PROBE: curl -s --max-time 20 -D /tmp/poc_status_final.h.txt -o /tmp/poc_status_final.b.json https://box.signageos.io/status && python3 -m json.tool /tmp/poc_sta
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 40
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all en
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos

## RANKED HYPOTHESES 2026-08-09 09:58:45 UTC
- [75] box.signageos.io/status: box.signageos.io /status Infrastructure Information Disclosure (from reports/hypotheses-laguna.txt)
- NEXT(hypotheses-laguna.txt): RAG: Clone `github.com/signageos/sdk` and grep for: (1) `apiBase`/`baseUrl`/`API_URL` constants → full endpoint paths; (2) `Authorization` header construction (
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed NEW. Unauthenticated JSON health endpoint leaks K8s pod hostname, process UID, Node version, and backend
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: Confirmed NEW. 18× static `access-control-allow-origin` headers (incl `http://` HTTP variant + `https://*.zdusercont
- LEARN: REJECTED IDOR @ api.signageos.io: Real `/v1/*` endpoints confirmed via client bundle (bundle.js) — 40+ paths mapped. BUT all return 403 with `WRONG_JWT_TOKEN`/`
- LEARN: REJECTED MISCONFIG @ api.signageos.io: 403 error body leaks descriptive auth detail (`"Account not found"`, `"Decoding of provided JWT token has failed"`, `erro
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation — still not testable passively without tenant config access (carried forward).
- LEARN: REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state — excluded per "CSRF on anonymous-accessible forms" (carried forward).
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname (rotating: gkzcp → mtnct), p
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: Confirmed live. 18 static ACAO values on / (302) + /login/ (200), unchanged under spoofed Origin `https://evil.test`
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: Confirmed live. /login/ CSP broadened vs / (triplicated Auth0 oauth/token, additional recaptcha frame-src). 40+ conne
- LEARN: REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 `OK` (2 bytes) — trivial health check, no data leaked. Not reportable.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All 60+ endpoints return 403 JWT-gated (WRONG_JWT_TOKEN/403105). No pre-auth bypass. Dual auth confirmed: JWT Bearer
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: 403/404 carry `vary: Origin` + `access-control-expose-headers: *` but NO ACAO under any Origin — not CORS-exploitabl
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation — not testable passively without tenant config access (carried forward).
- LEARN: REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state — excluded per "CSRF on anonymous-accessible forms" (carried forward).
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 4

## RANKED HYPOTHESES 2026-08-09 10:42:56 UTC

## RANKED HYPOTHESES 2026-08-09 11:14:29 UTC

## RANKED HYPOTHESES 2026-08-09 11:49:26 UTC
- [95] box.signageos.io/status: Box /status unauthenticated internal-topology info-leak — PoC finalized (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-bigpickle.txt): HUMAN: Run the token-bearing verification of the org-IDOR chain (highest open value): `curl -H "X-Auth: <jwt>" https://api.signageos.io/v1/organization/<own-uid

## RANKED HYPOTHESES 2026-08-09 12:20:33 UTC

## RANKED HYPOTHESES 2026-08-09 13:32:48 UTC
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-laguna.txt)
- NEXT(hypotheses-bigpickle.txt): HUMAN: Token-bearing verification of the org-IDOR chain (highest open value; cannot advance passively): `curl -H "X-Auth: <jwt>" https://api.signageos.io/v1/org
- NEXT(hypotheses-laguna.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live (pods jfmtn/gkzcp, Node v20.20.2, full topology, 40-hex uid); zero security headers persists (gre
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS/CSP: Reconfirmed — 17 static ACAO incl http:// + *.zdusercontent.com, no credentials flag, evil.test not reflected; C
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed hardened (HSTS/xfo/xcto) — hardening differential vs box persists.
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: class stable (WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/40307
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All routes still JWT/X-Auth-gated pre-auth; no passive bypass. Cross-tenant org/security-token chain remains AUTH_HE
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live. Node v20.20.2, pod box-7c8c876945-52dpt, succeededServices (amqp0, redis0-3, mongoDB0-3). Unchan
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live. Node v24.19.0, pod api-6f69db97d5-dw2j2, same topology. Unchanged.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: Reconfirmed — 17 static ACAO (incl http:// variant + https://*.zdusercontent.com), no credentials header, unchanged 
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: Reconfirmed — /login/ CSP 40+ connect-src/frame-src origins, triplicated Auth0 oauth/token. Unchanged.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. Unchanged.
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 flow params still not testable passively. Carried forward.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live this cycle. Node v20.20.2, pod box-7c8c876945-gkzcp, succeededServices (amqp0, redis0-3, mongoDB0
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live this cycle. Node v24.19.0, pod api-6f69db97d5-dw2j2, same topology. Unchanged.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS: Reconfirmed — 17 static ACAO (incl http:// variant + https://*.zdusercontent.com), no credentials header, unchanged 
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: Reconfirmed — /login/ CSP 40+ connect-src/frame-src origins (mapbox, events.mapbox, sentry, Auth0 oauth/token), tripl
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. Unchanged.
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 flow params still not testable passively. Carried forward.
- LEARN: REJECTED MISCONFIG @ box.signageos.io/csp-report: GET → 302 login redirect; not an exposed endpoint, report-uri/trusted-types are hardening additions, nothing r
- LEARN: REJECTED MISCONFIG @ api.signageos.io/status: No ACAO/vary headers on status path under any origin — CORS not exploitable (carried forward).
- LEARN: ACCEPTED MISCONFIG @ box/api /status: Reconfirmed live, data shape unchanged (box Node v20.20.2 / api v24.19.0, full amqp/redis/mongo topology) — carried forwar
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live this cycle — pod rotated to `box-7c8c876945-gkzcp`, Node v20.20.2, process.uid stable `b341def862
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed — pod `api-6f69db97d5-9kg9l`, Node v24.19.0, security headers (HSTS/xfo/xcto) present. Hardening diffe
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS/CSP: Reconfirmed — 17 static ACAO incl. `http://` variant + `https://*.zdusercontent.com`, no credentials flag; CSP c
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — /v2/device and /v1/organization/test both 403 JWT-gated with hardened headers; no pre-auth bypass surf
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live (2026-08-08 14:22). Pod `box-7c8c876945-gkzcp`, Node v20.20.2, process.uid `b341def86252cd23a7db1
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: Reconfirmed. 17 static ACAO incl. `http://` plaintext + `https://*.zdusercontent.com` wildcard + `api
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live. Pod `api-6f69db97d5-ff5td`, Node v24.19.0, full topology. Hardened with HSTS+xfo+xcto (different
- LEARN: REJECTED IDOR @ box.signageos.io: No unauthenticated authn surface on box beyond `/status` info-leak and CSP/CORS — no pre-auth bypass found.
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `WRONG_JWT_TOKEN`/`Account not found`/403105 — excluded per scope.yml.

## RANKED HYPOTHESES 2026-08-09 14:10:34 UTC

## RANKED HYPOTHESES 2026-08-09 14:54:57 UTC
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 40
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all en
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos

## RANKED HYPOTHESES 2026-08-09 15:30:40 UTC
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 40
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all en
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos

## RANKED HYPOTHESES 2026-08-09 16:03:31 UTC
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 40
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all en
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos

## RANKED HYPOTHESES 2026-08-09 16:51:36 UTC
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting (from reports/hypotheses-bigpickle.txt)
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- NEXT(hypotheses-bigpickle.txt): HUMAN: Token-bearing verification of the org-IDOR chain (highest open value; cannot advance passively — box /status PoC already finalized at 95): `sos login` (A
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 40
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all en
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live this cycle — pod `box-7c8c876945-2g8bw`, uid `5d1934974f1fa15a…`, Node v20.20.2, full topology; z
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS: Reconfirmed — 17 static ACAO incl `http://` + `*.zdusercontent.com`, evil.test NOT reflected, 0 credentia
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed hardened (HSTS/xfo/xcto) — hardening differential vs box persists.
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: class stable (WRONG_JWT_TOKEN/403075/403076/403105) — excluded per scope.yml.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All routes still JWT/X-Auth-gated pre-auth; no passive bypass. Cross-tenant org/security-token chain remains AUTH_HE

## RANKED HYPOTHESES 2026-08-09 17:21:10 UTC
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant OAuth secret disclosure via org path UID (from reports/hypotheses-laguna.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- NEXT(hypotheses-laguna.txt): HUMAN: Run token-bearing org-IDOR baseline — `curl -H "X-Auth: <jwt>" https://api.signageos.io/v1/organization/<own-uid>` must =200; then replace `<own-uid>` wi
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed hardened — HSTS/xfo/xcto present, differential vs box persists
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: class stable (WRONG_JWT_TOKEN/403075/403076/403105) — excluded per scope.yml
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass

## RANKED HYPOTHESES 2026-08-09 17:55:20 UTC
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed hardened — HSTS/xfo/xcto present, differential vs box persists
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: class stable (WRONG_JWT_TOKEN/403075/403076/403105) — excluded per scope.yml
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass

## RANKED HYPOTHESES 2026-08-09 18:38:34 UTC

## RANKED HYPOTHESES 2026-08-09 19:22:08 UTC
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via org-scoped X-Auth path UID (from reports/hypotheses-laguna.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- NEXT(hypotheses-laguna.txt): PROBE: Finalize the box `/status` PoC evidence package — save headers and body to files, confirm zero security headers via grep, confirm differential via root H
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live (2026-08-08 14:22). Pod `box-7c8c876945-gkzcp`, Node v20.20.2, process.uid `b341def86252cd23a7db1
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: Reconfirmed. 17 static ACAO incl. `http://` plaintext + `https://*.zdusercontent.com` wildcard + `api
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live. Pod `api-6f69db97d5-ff5td`, Node v24.19.0, full topology. Hardened with HSTS+xfo+xcto (different
- LEARN: REJECTED IDOR @ box.signageos.io: No unauthenticated authn surface on box beyond `/status` info-leak and CSP/CORS — no pre-auth bypass found.
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `WRONG_JWT_TOKEN`/`Account not found`/403105 — excluded per scope.yml.

## RANKED HYPOTHESES 2026-08-09 19:55:33 UTC
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass

## RANKED HYPOTHESES 2026-08-09 20:32:44 UTC
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via org UID override (from reports/hypotheses-bigpickle.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- NEXT(hypotheses-bigpickle.txt): HUMAN: Execute the standing org-IDOR chain (highest open value; cannot advance passively — box /status PoC finalized at 95): `sos login` (Auth0 device-code) → b
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live this cycle — pod `box-7c8c876945-gkzcp`, uid `b341def86252…`, Node v20.20.2, full topology; zero 
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed hardened (HSTS/xfo/xcto) — hardening differential vs box persists.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS: Reconfirmed — 17 static ACAO incl `http://` + `*.zdusercontent.com`, evil.test NOT reflected, 0 credentia
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: class stable (WRONG_JWT_TOKEN/403075/403076/403105) — excluded per scope.yml.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All routes still JWT/X-Auth-gated pre-auth; no passive bypass. Cross-tenant org/security-token chain remains AUTH_HE

## RANKED HYPOTHESES 2026-08-09 21:09:37 UTC
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos

## RANKED HYPOTHESES 2026-08-09 21:47:44 UTC
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos

## RANKED HYPOTHESES 2026-08-09 22:15:51 UTC
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos

## RANKED HYPOTHESES 2026-08-09 22:55:49 UTC
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via org UID override (from reports/hypotheses-bigpickle.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- NEXT(hypotheses-bigpickle.txt): HUMAN: Execute the standing org-IDOR chain (highest open value; cannot advance passively — box /status PoC finalized at 95): `sos login` (Auth0 device-code) → b
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live this cycle — pod `box-7c8c876945-2g8bw`, uid `5d193497…d852a6`, Node v20.20.2, full topology; zer
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed hardened (HSTS/xfo/xcto) — hardening differential vs box persists.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: Reconfirmed — 17 static ACAO incl `http://` + `*.zdusercontent.com`, evil.test NOT reflected, 0 crede
- LEARN: REJECTED IDOR @ box.signageos.io: New path enumeration (/graphql, /health, /metrics, /env, /config.json, /debug, /__webpack_hmr) → all 302 login catch-all; no u
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: class stable (WRONG_JWT_TOKEN/403075/403076/403105) — excluded per scope.yml.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All routes still JWT/X-Auth-gated pre-auth; no passive bypass. Cross-tenant org/security-token chain remains AUTH_HE

## RANKED HYPOTHESES 2026-08-09 23:33:10 UTC
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos

## RANKED HYPOTHESES 2026-08-10 00:04:25 UTC
- [95] box.signageos.io/status: box /status unauthenticated internal-infra info-leak (PoC package, standing) (from reports/hypotheses-bigpickle.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- [75] api.signageos.io/v1/organization/{organizationUid}: Cross-tenant org OAuth client-secret disclosure via account JWT (from reports/hypotheses-laguna.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- NEXT(hypotheses-bigpickle.txt): PROBE: box /status is PoC-final and unchanged; instead take one fresh passive look at box response-header differential on the login redirect chain — `curl -sI -
- NEXT(hypotheses-laguna.txt): PROBE: Finalize box /status PoC evidence package — `curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_status_b.tx
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live this cycle — pod `box-7c8c876945-gkzcp`, uid `b341def86252…`, Node v20.20.2, full topology; zero 
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: Reconfirmed — 17 static ACAO incl `http://` + `*.zdusercontent.com`, evil.test NOT reflected, 0 crede
- LEARN: REJECTED IDOR @ box.signageos.io: Path enumeration (/api, /v1, /v2, /graphql, /actuator, /metrics, /swagger, /openapi.json, /.well-known/openid-configuration) →

## RANKED HYPOTHESES 2026-08-10 02:31:10 UTC
- [95] box.signageos.io/status: box /status unauthenticated internal-infra info-leak (PoC package, standing) (from reports/hypotheses-bigpickle.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- NEXT(hypotheses-bigpickle.txt): PROBE: No delta this cycle — box /status and /login/ chain reconfirmed identical. Take one fresh passive look at the newly-observed CloudFront edge on /status f
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential v
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live this cycle — pod `box-7c8c876945-2g8bw`, uid `5d193497…d852a6`, Node v20.20.2, full topology; zer
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: Reconfirmed — 17 static ACAO incl `http://` + `*.zdusercontent.com`, 0 credentials flag; CSP triplica
- LEARN: REJECTED IDOR @ box.signageos.io: No new unauthenticated bypass surface — all non-/status, non-/ready box paths remain behind login catch-all; CDN switch did no
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: class stable (WRONG_JWT_TOKEN/403075/403076/403105) — excluded per scope.yml.

## RANKED HYPOTHESES 2026-08-10 04:19:27 UTC
- [95] box.signageos.io/status: box /status unauthenticated internal-infra info-leak (PoC package, standing) (from reports/hypotheses-bigpickle.txt)
- [95] box.signageos.io/status: box /status unauthenticated K8s infra info-leak (from reports/hypotheses-longcat.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- NEXT(hypotheses-longcat.txt): PROBE: Fresh PoC capture of box /status behind CloudFront edge — `curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_b
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: CHANGED box.signageos.io/status: Now fronted by CloudFront (x-cache, via, x-amz-cf-pop) — routing change only, body and header security posture unchanged
- LEARN: CHANGED box.signageos.io/ & /login/: Now fronted by CloudFront with full hardening headers (HSTS/xfo/xcto/CSP) — differential vs /status confirmed
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS/CSP: Reconfirmed — 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard, no credentials flag, CSP
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: All routes JWT/X-Auth gated (403), no passive bypass across 30+ cycles. Cross-tenant chain remains AUTH_HEL

## RANKED HYPOTHESES 2026-08-10 05:52:32 UTC
- [95] box.signageos.io/status: box /status unauthenticated internal-infra info-leak (PoC package, standing) (from reports/hypotheses-bigpickle.txt)
- [95] box.signageos.io/status: box /status unauthenticated K8s infra info-leak (from reports/hypotheses-longcat.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- NEXT(hypotheses-bigpickle.txt): PROBE: One final passive differential this cycle — fetch box `/status` with a spoofed `Origin: https://evil.test` (HEAD, 1 request) to confirm the ACAO set on /
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: CHANGED box.signageos.io/status: Now fronted by CloudFront (x-cache, via, x-amz-cf-pop) — routing change only, body and header security posture unchanged
- LEARN: CHANGED box.signageos.io/ & /login/: Now fronted by CloudFront with full hardening headers (HSTS/xfo/xcto/CSP) — differential vs /status confirmed
- LEARN: NEW api.signageos.io/status now also fronted by CloudFront (x-cache, via, x-amz-cf-pop) — retains HSTS/xfo/xcto hardening

## RANKED HYPOTHESES 2026-08-10 07:11:45 UTC

## RANKED HYPOTHESES 2026-08-10 08:56:55 UTC
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/org
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: CHANGED box.signageos.io/status: Now fronted by CloudFront (x-cache, via, x-amz-cf-pop) — routing change only, body and header security posture unchanged
- LEARN: CHANGED box.signageos.io/ & /login/: Now fronted by CloudFront with full hardening headers (HSTS/xfo/xcto/CSP) — differential vs /status confirmed
- LEARN: NEW api.signageos.io/status now also fronted by CloudFront (x-cache, via, x-amz-cf-pop) — retains HSTS/xfo/xcto hardening

## RANKED HYPOTHESES 2026-08-10 10:11:31 UTC

## RANKED HYPOTHESES 2026-08-10 11:31:07 UTC
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organiz
- NEXT(hypotheses-bigpickle.txt): HUMAN: Execute the standing H1 POC for the cross-tenant chain — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "http
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: CHANGED box.signageos.io/status: Now fronted by CloudFront (x-cache, via, x-amz-cf-pop) — routing change only, body and header security posture unchanged
- LEARN: CHANGED box.signageos.io/ & /login/: Now fronted by CloudFront with full hardening headers (HSTS/xfo/xcto/CSP) — differential vs /status confirmed
- LEARN: NEW api.signageos.io/status now also fronted by CloudFront (x-cache, via, x-amz-cf-pop) — retains HSTS/xfo/xcto hardening

## RANKED HYPOTHESES 2026-08-10 12:17:33 UTC
- [95] box.signageos.io/status: Box /status unauthenticated internal-topology info-leak (PoC finalize) (from reports/hypotheses-laguna.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organiz
- NEXT(hypotheses-bigpickle.txt): HUMAN: Execute the standing H1 POC for the cross-tenant chain — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "http
- NEXT(hypotheses-laguna.txt): PROBE: Finalize box /status PoC evidence package — `curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_status_b.tx
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 

## RANKED HYPOTHESES 2026-08-10 13:51:05 UTC
- [95] box.signageos.io/status: Unauthenticated K8s topology leak via /status missing security headers (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: Finalize box /status PoC evidence package — `curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_status_b.tx
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
