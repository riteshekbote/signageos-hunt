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

## RANKED HYPOTHESES 2026-08-10 14:47:21 UTC

## RANKED HYPOTHESES 2026-08-10 15:46:49 UTC
- [95] box.signageos.io/status: box /status unauthenticated internal-infra info-leak (PoC finalize) (from reports/hypotheses-bigpickle.txt)

## RANKED HYPOTHESES 2026-08-10 16:39:17 UTC

## RANKED HYPOTHESES 2026-08-10 17:37:38 UTC
- [95] box.signageos.io/status: box /status unauthenticated K8s infra info-leak (from reports/hypotheses-longcat.txt)
- [95] box.signageos.io/status: Box /status unauthenticated internal-infra info-leak behind CloudFront (from reports/hypotheses-laguna.txt)
- NEXT(hypotheses-laguna.txt): PROBE: Finalize box /status PoC evidence package — `curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_status_b.tx
- NEXT(hypotheses-longcat.txt): PROBE: Finalize box /status PoC evidence package — `curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_status_b.tx
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology; head
- LEARN: CHANGED box.signageos.io/ & /login/: Now fronted by CloudFront with full hardening (HSTS+xfo+xcto+CSP) — differential vs /status confirmed
- LEARN: CHANGED api.signageos.io/status: Now fronted by CloudFront — retains HSTS+xfo+xcto hardening, no new surface
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes 403 JWT/X-Auth-gated, no passive bypass (reconfirmed)
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS/CSP: Reconfirmed — 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard, no credentials flag, CSP
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: All routes JWT/X-Auth gated (403), no passive bypass across 30+ cycles. Cross-tenant chain remains AUTH_HEL
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: CHANGED box.signageos.io/status: Now fronted by CloudFront (x-cache, via, x-amz-cf-pop) — routing change only, body and header security posture unchanged.
- LEARN: CHANGED api.signageos.io/status: Now also fronted by CloudFront (x-cache, via, x-amz-cf-pop) — retains HSTS/xfo/xcto hardening.

## RANKED HYPOTHESES 2026-08-10 18:33:44 UTC

## RANKED HYPOTHESES 2026-08-10 19:38:47 UTC
- [95] box.signageos.io/status: box /status unauthenticated internal-infra info-leak (standing, PoC finalized) (from reports/hypotheses-bigpickle.txt)
- [95] box.signageos.io/status: Box /status unauthenticated K8s topology leak behind CloudFront (from reports/hypotheses-laguna.txt)
- NEXT(hypotheses-bigpickle.txt): HUMAN: Execute the standing cross-tenant chain PoC (only unverified high-value lead): 1) `sos login` (Auth0 device-code) → account JWT; 2) baseline `curl -H "X-
- NEXT(hypotheses-laguna.txt): PROBE: `curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_status_b.txt && echo "hardening_headers: $(grep -cE 'st

## RANKED HYPOTHESES 2026-08-10 20:23:24 UTC
- [95] box.signageos.io/status: box /status unauthenticated internal-infra info-leak (standing, PoC finalized) (from reports/hypotheses-bigpickle.txt)
- [95] box.signageos.io/status: Box /status unauthenticated K8s topology leak behind CloudFront with zero hardening headers (from reports/hypotheses-laguna.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: Finalize box /status PoC evidence package — `curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_status_b.tx
- NEXT(hypotheses-laguna.txt): PROBE: Finalize box `/status` PoC evidence package and record immutable artifacts:
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: Reconfirmed all routes 403 JWT/X-Auth-gated, no passive bypass — cross-tenant chain remains AUTH_HELPED onl
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology; head
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NO
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403

## RANKED HYPOTHESES 2026-08-10 21:13:50 UTC
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute standing cross-tenant chain PoC for api target — 1) `sos login` (Auth0 device-code) → account JWT; 2) baseline `curl -X POST -H "X-Auth: <account
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 

## RANKED HYPOTHESES 2026-08-10 22:04:33 UTC
- [95] box.signageos.io/status: box /status unauthenticated internal-infra info-leak (standing, PoC finalized) (from reports/hypotheses-bigpickle.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Execute standing cross-tenant chain PoC for api target — 1) `sos login` (Auth0 device-code) → account JWT; 2) baseline `curl -X POST -H "X-Auth: <account
- NEXT(hypotheses-bigpickle.txt): HUMAN: Execute the standing cross-tenant chain PoC (only unverified high-value lead): 1) `sos login` (Auth0 device-code) → account JWT; 2) baseline `curl -H "X-
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NO

## RANKED HYPOTHESES 2026-08-10 22:55:17 UTC
- [95] box.signageos.io/status: Box /status unauthenticated K8s topology leak behind CloudFront with zero hardening headers (from reports/hypotheses-laguna.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: Finalize box /status PoC evidence package — `curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_status_b.tx
- NEXT(hypotheses-laguna.txt): PROBE: Re-confirm box `/status` evidence package with immutable sha256 capture and persist to artifacts for PoC archive:
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NO
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Fresh probe confirms HTTP 200 JSON leaking hostname `box-7c8c876945-496p2`, 40-hex process uid `83d7c558844acc458f
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: Confirmed HTTP 200 "OK" (2 bytes) — trivial health check, no data leaked.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: Reconfirmed all routes 403 JWT/X-Auth-gated (/v1/device, /v1/organization, /v1/organization/test, /v2/devic
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: NO ACAO on any path including /status, /v1/*, /v2/* (grep=0) — not CORS-exploitable.
- LEARN: REJECTED MISCONFIG @ box.signageos.io CSP report-uri: /csp-report → 302 login redirect — not an exposed endpoint.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS/CSP: 17 static ACAO on `/ + /login/` (no credentials flag); CSP ~59+ origins with triplicated Auth0 oauth/token — unc
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward).

## RANKED HYPOTHESES 2026-08-10 23:25:50 UTC
- [95] box.signageos.io/status: box /status unauthenticated K8s infra info-leak behind CloudFront (from reports/hypotheses-longcat.txt)
- NEXT(hypotheses-longcat.txt): PROBE: Finalize box `/status` PoC evidence package with immutable sha256 capture and persist to artifacts for PoC archive:
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS/CSP: Reconfirmed — 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard, no credentials flag, CSP
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: All routes JWT/X-Auth gated (403), no passive bypass across 30+ cycles. Cross-tenant chain remains AUTH_HEL
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 

## RANKED HYPOTHESES 2026-08-11 00:03:53 UTC
- [95] box.signageos.io/status: box.signageos.io/status unauthenticated K8s infra leak behind CloudFront (from reports/hypotheses-laguna.txt)
- [95] box.signageos.io/status: box /status unauthenticated internal-infra info-leak (PoC complete, re-archived) (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-bigpickle.txt): PROBE: One passive reconfirmation of the box /status PoC package next cycle (`curl -sD - https://box.signageos.io/status` → verify sha256 delta + grep security 
- NEXT(hypotheses-laguna.txt): PROBE: Finalize box `/status` PoC evidence package with immutable sha256 capture: `curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/sta
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod `box-7c8c876945-gkzcp`, process.uid `772fc40ca8b5733a305b3000d2042557f1502a77b17c00cd07`, N
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live — pod `api-6f69db97d5-9kg9l`, Node v24.19.0, 8 services, hardened with HSTS+xfo+xcto behind Cloud
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: /organization/someorg returns 403 (NO_ORGANIZATION_TO_AUTHENTICATE / 403075), confirming org identity deriv
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks NO_ORGANIZATION_TO_AUTHENTICATE/NO_ORGANIZATION (403075) — excluded per scope.yml 
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding still not passively testable without tenant/authenticated session (carried forwa

## RANKED HYPOTHESES 2026-08-11 02:23:21 UTC

## RANKED HYPOTHESES 2026-08-11 04:17:36 UTC
- [95] box.signageos.io/status: box /status unauthenticated K8s infra info-leak behind CloudFront (from reports/hypotheses-longcat.txt)
- NEXT(hypotheses-longcat.txt): PROBE: Finalize box `/status` PoC evidence package with immutable sha256 capture and persist to artifacts for PoC archive:
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS/CSP: Reconfirmed — 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard, no credentials flag, CSP
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: All routes JWT/X-Auth gated (403), no passive bypass across 30+ cycles. Cross-tenant chain remains AUTH_HEL
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: CHANGED box.signageos.io/status: Now fronted by CloudFront (x-cache, via, x-amz-cf-pop) — routing change only, body and header security posture unchanged.
- LEARN: CHANGED api.signageos.io/status: Now also fronted by CloudFront (x-cache, via, x-amz-cf-pop) — retains HSTS/xfo/xcto hardening.

## RANKED HYPOTHESES 2026-08-11 05:35:42 UTC

## RANKED HYPOTHESES 2026-08-11 06:11:49 UTC
- [95] box.signageos.io/status: box /status unauthenticated K8s infra info-leak behind CloudFront (from reports/hypotheses-longcat.txt)
- NEXT(hypotheses-longcat.txt): PROBE: Finalize box `/status` PoC evidence package with immutable sha256 capture and persist to artifacts for PoC archive:
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS/CSP: Reconfirmed — 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard, no credentials flag, CSP
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: All routes JWT/X-Auth gated (403), no passive bypass across 30+ cycles. Cross-tenant chain remains AUTH_HEL
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: CHANGED box.signageos.io/status: Now fronted by CloudFront (x-cache, via, x-amz-cf-pop) — routing change only, body and header security posture unchanged.
- LEARN: CHANGED api.signageos.io/status: Now also fronted by CloudFront (x-cache, via, x-amz-cf-pop) — retains HSTS/xfo/xcto hardening.

## RANKED HYPOTHESES 2026-08-11 07:39:54 UTC

## RANKED HYPOTHESES 2026-08-11 08:39:48 UTC
- [95] box.signageos.io/status: box /status unauthenticated infra-info-leak (PoC complete — standing deliverable) (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-bigpickle.txt): PROBE: One passive reconfirmation of the box /status PoC package next cycle (`curl -s -D /tmp/opencode/box_status_h.txt -o /tmp/opencode/box_status_body.txt htt

## RANKED HYPOTHESES 2026-08-11 09:50:06 UTC

## RANKED HYPOTHESES 2026-08-11 10:43:48 UTC
- [95] box.signageos.io/status: box /status unauthenticated infra-info-leak (PoC package live, standing deliverable) (from reports/hypotheses-bigpickle.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: box / + /login/ static CORS whitelist incl plaintext HTTP + wildcard (standing MISCONFIG) (from reports/hypotheses-laguna.txt)
- NEXT(hypotheses-laguna.txt): PROBE: Re-confirm box `/status` evidence package with immutable sha256 capture and persist to artifacts for PoC archive:
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Fresh probe confirms HTTP 200 JSON leaking hostname `box-7c8c876945-496p2`, 40-hex process uid `83d7c558844acc458f
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: Confirmed HTTP 200 "OK" (2 bytes) — trivial health check, no data leaked.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: Reconfirmed all routes 403 JWT/X-Auth-gated (/v1/device, /v1/organization, /v1/organization/test, /v2/devic
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: NO ACAO on any path including /status, /v1/*, /v2/* (grep=0) — not CORS-exploitable.
- LEARN: REJECTED MISCONFIG @ box.signageos.io CSP report-uri: /csp-report → 302 login redirect — not an exposed endpoint.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CORS/CSP: 17 static ACAO on `/ + /login/` (no credentials flag); CSP ~59+ origins with triplicated Auth0 oauth/token — unc
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward).
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod `box-7c8c876945-gkzcp`, process.uid `772fc40ca8b5733a305b3000d2042557f1502a77b17c00cd07`, N
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live — pod `api-6f69db97d5-9kg9l`, Node v24.19.0, 8 services, hardened with HSTS+xfo+xcto behind Cloud
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: /organization/someorg returns 403 (NO_ORGANIZATION_TO_AUTHENTICATE / 403075), confirming org identity deriv
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks NO_ORGANIZATION_TO_AUTHENTICATE/NO_ORGANIZATION (403075) — excluded per scope.yml 
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding still not passively testable without tenant/authenticated session (carried forwa

## RANKED HYPOTHESES 2026-08-11 11:36:45 UTC
- [95] box.signageos.io/status: box /status unauthenticated infra-info-leak (PoC package live, standing deliverable) (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-bigpickle.txt): HUMAN: Cross-tenant security-token test is the only higher-value unverified lead and is gated on operator auth. Requires: `sos login` (Auth0 device-code) to obt
- NEXT(hypotheses-laguna.txt): PROBE: Finalize + archive box `/status` PoC evidence package (already captured this cycle) with immutable sha256 fingerprints persisted to artifacts: `sha256sum
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod `box-7cd9ddcc8c-55pj6`, uid `3b72b9b9a11f59752d4edb5212e85011f2b66c67b6edac125f`, Node v20.

## RANKED HYPOTHESES 2026-08-11 12:28:10 UTC
- [95] box.signageos.io/status: box /status unauthenticated infra-info-leak (PoC package LIVE, now durably archived) (from reports/hypotheses-bigpickle.txt)
- [95] box.signageos.io/status: box /status unauth K8s infra leak behind CloudFront (standing PoC, evidence refreshed) (from reports/hypotheses-laguna.txt)
- [95] box.signageos.io/status: Cross-tenant security-token mint via X-Auth org-UID override (from reports/hypotheses-longcat.txt)
- NEXT(hypotheses-bigpickle.txt): PROBE: box /status evidence package is now durably persisted (artifacts/box-status/manifest.sha256) — the standing deliverable is complete and immutable. Highes
- NEXT(hypotheses-laguna.txt): PROBE: Archive the freshly-captured box `/status` PoC evidence package (pod t2w7w, uid e2a3b4…4c77bc, sha256_body=`e3d1ae393f652e3b582cdb1ca23a245af3fc240af4856
- NEXT(hypotheses-longcat.txt): HUMAN: Cross-tenant security-token test is the only higher-value unverified lead and is gated on operator auth. Requires: `sos login` (Auth0 device-code) to obt
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod box-7cd9ddcc8c-5bnfd, uid 077b032238f6e3e717c868472b7132dcddd615ec206b8aa8cf, Node v20.20.2
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed hardened (HSTS/xfo/xcto grep=3, cache-control: no-store), CloudFront SFO53-P12. Info-leak (hostname/ui
- LEARN: REJECTED CORS-exploit @ box.signageos.io /login/: 17 static ACAO, evil.test NOT reflected, 0 credentials flag — no credential-theft path; MISCONFIG-only. NOTE: 
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass — cross-tenant chain remains AUTH_HELPED only.
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward).
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: RECONFIRMED LIVE this cycle — pod `box-7cd9ddcc8c-t2w7w`, uid=`e2a3b4…4c77bc`, Node v20.20.2, 9 svc topology, 0 ha
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: RECONFIRMED — pod `api-6d67cd6668-vg7c2`, Node v24.19.0, hardened HSTS+xfo+xcto (3), zero ACAO under any Origin; s
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: RECONFIRMED all 403 JWT/X-Auth-gated, no ACAO under spoofed `evil.test`, no bypass surface — AUTH_HELPED on
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable.
- LEARN: REJECTED MISCONFIG @ box.signageos.io /ready: 200 "OK" (2 bytes), trivial health check, no data.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod `box-7cd9ddcc8c-55pj6`, uid `3b72b9b9a11f59752d4edb5212e85011f2b66c67b6edac125f`, Node v20.

## RANKED HYPOTHESES 2026-08-11 14:03:56 UTC
- [95] box.signageos.io/status: box /status unauthenticated K8s infra leak behind CloudFront (PoC evidence archived) (from reports/hypotheses-laguna.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token mint via X-Auth org-UID override (from reports/hypotheses-longcat.txt)
- NEXT(hypotheses-laguna.txt): PROBE: Verify the newly-archived box `/status` PoC evidence package is immutable by re-probing and confirming sha256 stability. Execute: `curl -sS -D -o /tmp/op
- NEXT(hypotheses-longcat.txt): HUMAN: Cross-tenant security-token test is the only higher-value unverified lead. Requires: `sos login` (Auth0 device-code) to obtain account JWT, then 1) basel
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: PoC complete and durably archived — 30+ cycles confirm unauthenticated JSON leak of pod hostname/uid/Node/topology
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ + /login/: 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard, no creds flag — confirmed across 30+
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: All routes JWT/X-Auth gated (403), no passive bypass across 30+ cycles.
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403
- LEARN: REJECTED MISCONFIG @ box.signageos.io /ready: 200 "OK" (2 bytes), trivial health check, no data.

## RANKED HYPOTHESES 2026-08-11 15:04:40 UTC
- [95] box.signageos.io/status: box /status unauthenticated infra-info-leak (from reports/hypotheses-longcat.txt)
- [95] box.signageos.io/status: box /status unauthenticated K8s infra leak behind CloudFront (PoC archived) (from reports/hypotheses-laguna.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org-UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Cross-tenant security-token test — requires `sos login` (Auth0 device-code) to obtain account JWT, then 1) baseline POST /v1/organization/<own-org-uid>/s
- NEXT(hypotheses-longcat.txt): PROBE: Re-archive box `/status` PoC evidence package with new sha256 (`82f3f196136e38d638f4d2984f1d90ca7b02f98f2adb9fc49dd6b0804f4ca808`) and fresh headers sha2
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NO
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod `box-7cd9ddcc8c-756mn`, uid `a3a5ce07981b4b879d62578023dcda0fb1c267c9257026d6d9`, Node v20.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ + /login/: 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard, 0 creds flag — reconfirmed across 30

## RANKED HYPOTHESES 2026-08-11 16:11:43 UTC
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org-UID override (from reports/hypotheses-nemotron3.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token mint via X-Auth org-UID override (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Cross-tenant security-token test — requires `sos login` (Auth0 device-code) to obtain account JWT, then 1) baseline POST /v1/organization/<own-org-uid>/s
- NEXT(hypotheses-bigpickle.txt): PROBE: Re-archive cycle is complete (artifacts/box-status/ now immutable, sha256 `23a4cdd4…`). Standing low-rps cycle: one passive reconfirm of box /status next
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NO
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live this cycle — pod `box-7cd9ddcc8c-szxmq`, uid `786f4aff…0b0a9609`, Node v20.20.2, 9 succeededServi
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & /: Reconfirmed — 17 static ACAO incl `http://` plaintext + `https://*.zdusercontent.com` wildcard + api sibling +
- LEARN: REJECTED CORS-exploit @ box.signageos.io /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass — cross-tenant chain remains AUTH_HELPED only.
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward).

## RANKED HYPOTHESES 2026-08-11 17:16:22 UTC
- [95] box.signageos.io/status: box /status unauthenticated infra-info-leak (from reports/hypotheses-longcat.txt)
- [95] box.signageos.io/status: box /status unauthenticated K8s infra leak (standing, reconfirmed this cycle) (from reports/hypotheses-bigpickle.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org-UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Cross-tenant security-token test — requires `sos login` (Auth0 device-code) to obtain account JWT, then 1) baseline POST /v1/organization/<own-org-uid>/s
- NEXT(hypotheses-bigpickle.txt): PROBE: Re-archive box /status evidence package this cycle — body sha256 changed (`b0d07ba34cb883eace6de41c23550c61cc2bb796c42b5bf93e9c1c5ca9a722d5`, pod 7xc7l, 
- NEXT(hypotheses-longcat.txt): PROBE: Standing passive reconfirm at ≤1 rps. `curl -sS https://box.signageos.io/status | sha256sum` (expect 200 JSON, zero hardening headers) + `curl -sI -H "Or
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NO
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod `box-7cd9ddcc8c-7xc7l`, uid `bba45210…`, Node v20.20.2, 9 succeededServices, zero hardening
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed hardened (HSTS/xfo/xcto grep=3), new body sha256 `135ad077…`, CloudFront ORD56-P6. Info-leak persists 
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass — cross-tenant chain remains AUTH_HELPED only.
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403
- LEARN: REJECTED CORS-exploit @ box.signageos.io /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only.
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward).
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation (`box-7cd9ddcc8c-756mn`), zero security headers, full topology l
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ + /login/: 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard, 0 creds flag — reconfirmed.
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: All routes JWT/X-Auth gated (403), no passive bypass across 30+ cycles.
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data.

## RANKED HYPOTHESES 2026-08-11 18:14:29 UTC
- [95] box.signageos.io/status: box /status unauthenticated infra-info-leak (from reports/hypotheses-longcat.txt)
- [95] box.signageos.io/status: box /status unauthenticated K8s infra-info-leak behind CloudFront (from reports/hypotheses-laguna.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org-UID override (from reports/hypotheses-nemotron3.txt)
- [60] api.signageos.io/v1/{device,organization,alert,...}: Cross-tenant IDOR via organizationUid on api.signageos.io /v1 (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: Re-archive box /status evidence package this cycle — body sha256 changed (`b0d07ba34cb883eace6de41c23550c61cc2bb796c42b5bf93e9c1c5ca9a722d5`, pod 7xc7l, 
- NEXT(hypotheses-bigpickle.txt): RAG: fetch public REST-API docs `https://docs.signageos.io/hc/en-us/articles/4405231278482` (REST APIs) and `https://docs.signageos.io/hc/en-us/articles/4405239
- NEXT(hypotheses-laguna.txt): HUMAN: Cross-tenant IDOR test on api.signageos.io. Phase=POC for box is COMPLETE — box /status PoC fully verified live (3rd fresh probe confirms identical leak 
- NEXT(hypotheses-longcat.txt): PROBE: Standing passive reconfirm at ≤1 rps. `curl -sS https://box.signageos.io/status | sha256sum` (expect 200 JSON, zero hardening headers) + `curl -sI -H "Or
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NO
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod `box-7cd9ddcc8c-7v5xw`, uid `6c51553e…`, Node v20.20.2, 9 succeededServices, zero hardening
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed hardened (HSTS/xfo/xcto grep=3, cache-control:no-store), new body sha256 `f8f9f7e0…`. Info-leak persis
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: Reconfirmed — 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard + path-bearing
- LEARN: REJECTED CORS-exploit @ box.signageos.io /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only (carried forward).
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass — cross-tenant chain remains AUTH_HELPED only (carried forwa
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward).
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ + /login/: 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard, 0 creds flag — reconfirmed.
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS+xfo+xcto — differential vs box persists.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: All routes JWT/X-Auth gated (403), no passive bypass across 30+ cycles.
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: excluded class per scope.yml.

## RANKED HYPOTHESES 2026-08-11 19:22:45 UTC
- [95] box.signageos.io/status: Unauthenticated K8s topology leak via /status missing security headers (from reports/hypotheses-nemotron3.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token mint via X-Auth org-UID path override (from reports/hypotheses-laguna.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token mint via X-Auth org-UID override (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Cross-tenant IDOR test on api.signageos.io. Phase=POC for box is COMPLETE — box /status PoC fully verified live (3rd fresh probe confirms identical leak 
- NEXT(hypotheses-bigpickle.txt): PROBE: Standing reconfirm — `curl -s https://box.signageos.io/status | sha256sum` next cycle; re-archive only if sha changes from `ee6129df…`. Highest-value ope
- NEXT(hypotheses-laguna.txt): HUMAN: Cross-tenant IDOR test on api.signageos.io. box phase=POC is COMPLETE (status PoC verified 30+ cycles, evidence archived). Transition to api phase: requi
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NO
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live 30+ cycles — pod rotation (box-7cd9ddcc8c-*), zero hardening headers (grep=0), full topology leak
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ + /login/: 17 static ACAO incl http:// plaintext + *.zdusercontent.com wildcard, 0 credentials flag, evil.test NOT reflec
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: All 60+ routes JWT/X-Auth-gated (403), 0 ACAO under evil.test — not pre-auth bypassable; cross-tenant chain
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 access-control-allow-credentials → no credential-theft path; MISCONFIG-only.
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session; no unauthenticate
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes) — trivial health check, no data leaked.
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed hardened (HSTS/xfo/xcto grep=3) behind CloudFront; info-leak (hostname/uid/Node) persists but header p

## RANKED HYPOTHESES 2026-08-11 20:11:36 UTC
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org-UID override (from reports/hypotheses-nemotron3.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token mint via X-Auth org-UID path override on /organization/{uid} (from reports/hypotheses-laguna.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide valid signageOS account JWT (X-Auth header) and a foreign organization UID to test cross-tenant IDOR on api.signageos.io/v1/organization/{uid} an
- NEXT(hypotheses-bigpickle.txt): PROBE: Standing reconfirm — next cycle `curl -s https://box.signageos.io/status | sha256sum`; re-archive only if sha changes from `77529aac…`. Highest-value ope
- NEXT(hypotheses-laguna.txt): HUMAN: Cross-tenant IDOR test on api.signageos.io. box phase POC is COMPLETE (box /status PoC verified 30+ cycles, evidence archived to /tmp/opencode/artifacts/
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NO
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod `box-7cd9ddcc8c-qxz52`, uid `3d32a3ee…`, Node v20.20.2, 9 succeededServices, zero hardening
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed hardened (HSTS/xfo/xcto grep=3, cache-control:no-store), new body sha256 `f89710b9…`. Info-leak persis
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: Reconfirmed — 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard; 0 credentials
- LEARN: REJECTED CORS-exploit @ box.signageos.io /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only (carried forward).
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass — cross-tenant chain remains AUTH_HELPED only (carried forwa
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward).
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check — no data leaked (unchanged this cycle).
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session; no unauthenticate
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: unauthenticated JSON infra-leak (hostname/uid/Node/topology) + zero hardening headers persists; PoC complete & arc
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ + /login/: 17 static ACAO incl http:// + *.zdusercontent.com, 0 access-control-allow-credentials, evil.test not reflected
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all 60+ routes JWT/X-Auth-gated (403), zero ACAO under evil.test — not pre-auth bypassable; cross-tenant ch

## RANKED HYPOTHESES 2026-08-11 21:07:09 UTC
- [95] box.signageos.io/status: box /status unauthenticated infra-info-leak (standing) (from reports/hypotheses-bigpickle.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org-UID override (from reports/hypotheses-nemotron3.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token mint via X-Auth org-UID override (from reports/hypotheses-laguna.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide valid signageOS account JWT (X-Auth header) and a foreign organization UID to test cross-tenant IDOR on api.signageos.io/v1/organization/{uid} an
- NEXT(hypotheses-laguna.txt): HUMAN: Provide valid signageOS account JWT (X-Auth header) and a foreign organization UID to test cross-tenant IDOR on `https://api.signageos.io/v1/organization
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NO
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live 30+ cycles — pod rotation (box-7cd9ddcc8c-*), zero hardening headers (grep=0), full topology leak
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ + /login/: 17 static ACAO incl `http://` plaintext + `*.zdunpkgdomains.com` wildcard, 0 credentials flag, evil.test NOT r
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak `WRONG_JWT_TOKEN`/`NO_ORGANIZATION_TO_AUTHENTICATE`/`WRONG_ACCOUNT_SECRET` + 4030
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: All 60+ routes JWT/X-Auth-gated (403), zero ACAO under `evil.test` — not pre-auth bypassable; cross-tenant 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 `access-control-allow-credentials` → no credential-theft path; MISCONFIG-only.
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session; no unauthenticate
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes) — trivial health check, no data leaked.
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed hardened (HSTS/xfo/xcto grep=3) behind CloudFront; info-leak (hostname/uid/Node) persists but header p

## RANKED HYPOTHESES 2026-08-11 22:06:07 UTC
- [95] box.signageos.io/status: box /status unauthenticated infra-info-leak (from reports/hypotheses-longcat.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org-UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide valid signageOS account JWT (X-Auth header) and a foreign organization UID to test cross-tenant IDOR on api.signageos.io/v1/organization/{uid} an
- NEXT(hypotheses-laguna.txt): HUMAN: Box phase POC is complete (box /status infra-leak verified 30+ cycles, evidence archived to `/tmp/opencode/artifacts/box-status/`). Transition to API pha
- NEXT(hypotheses-longcat.txt): PROBE: Standing passive reconfirm at <=1 rps. `curl -sS https://box.signageos.io/status | sha256sum` (expect 200 JSON, zero hardening headers) + `curl -sI -H "O
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NO
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation (box-7cd9ddcc8c-*), zero hardening headers (grep=0), full topolo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ + /login/: 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard, 0 credentials flag, evil.test NOT re
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: All 60+ routes JWT/X-Auth-gated (403), zero ACAO under evil.test — not pre-auth bypassable; cross-tenant ch
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes) — trivial health check, no data.
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 access-control-allow-credentials -> no credential-theft path; MISCONFIG-only.
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session.

## RANKED HYPOTHESES 2026-08-11 22:58:24 UTC
- [95] box.signageos.io/status: box.signageos.io/status unauthenticated infra-info-leak with zero hardening headers (from reports/hypotheses-laguna.txt)
- [95] box.signageos.io/status: Unauthenticated K8s topology leak via /status missing security headers (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: Standing passive reconfirm at ≤1 rps. `curl -sS https://box.signageos.io/status | sha256sum` (expect 200 JSON, zero hardening headers) + `curl -sI -H "Or
- NEXT(hypotheses-laguna.txt): PROBE: `curl -sS -D - -o /tmp/opencode/artifacts/box-status/body.json https://box.signageos.io/status` → confirm 200 JSON leak; `jq '{hostname,uid:.process.uid,
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NO
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable

## RANKED HYPOTHESES 2026-08-11 23:51:33 UTC
- [95] box.signageos.io/status: box /status unauthenticated infra-info-leak with zero hardening headers (from reports/hypotheses-laguna.txt)
- [95] box.signageos.io/status: box /status unauthenticated infra-info-leak (standing) (from reports/hypotheses-bigpickle.txt)
- [95] box.signageos.io/status: box /status unauthenticated infra-info-leak (from reports/hypotheses-longcat.txt)
- [95] box.signageos.io/status: Unauthenticated K8s topology leak via /status missing security headers (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: Standing passive reconfirm at ≤1 rps. `curl -sS https://box.signageos.io/status | sha256sum` (expect 200 JSON, zero hardening headers) + `curl -sI -H "Or
- NEXT(hypotheses-bigpickle.txt): PROBE: Standing reconfirm — next cycle `curl -sS https://box.signageos.io/status | sha256sum`; re-archive only if sha changes from `f8927951c406…`. Highest-valu
- NEXT(hypotheses-laguna.txt): HUMAN: Box phase POC is complete and archived (box /status infra-leak verified 30+ cycles, evidence at `/tmp/opencode/artifacts/box-status/`, body sha `82155343
- NEXT(hypotheses-longcat.txt): PROBE: Standing passive durability reconfirm at ≤1 rps — `curl -sS https://box.signageos.io/status | sha256sum` (expect 200 JSON, zero hardening headers) + `cur
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NO
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod `box-7cd9ddcc8c-6m52v`, uid `89e006c0…`, Node v20.20.2, 9 succeededServices, zero hardening
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: Reconfirmed — 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard; 0 credentials
- LEARN: REJECTED CORS-exploit @ box.signageos.io /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only (carried forward).
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass — cross-tenant chain remains AUTH_HELPED only (carried forwa
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward).
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live 30+ cycles — pod rotation (box-7cd9ddcc8c-*), zero hardening headers (grep=0), full topology leak
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed hardened (HSTS/xfo/xcto grep=3) behind CloudFront; info-leak persists but header posture hardened vs b
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ + /login/: 17 static ACAO incl http:// plaintext + *.zdusercontent.com wildcard, 0 credentials flag, evil.test NOT reflec
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: All 60+ routes JWT/X-Auth gated (403), zero ACAO under evil.test — no passive bypass.
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes) — trivial health check, no data.
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 access-control-allow-credentials → no credential-theft path; MISCONFIG-only.
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session.

## RANKED HYPOTHESES 2026-08-12 00:51:58 UTC
- [95] box.signageos.io/status: box/status unauthenticated infra-info-leak with zero hardening headers (reconfirmed with new pod 7v5xw) (from reports/hypotheses-laguna.txt)
- [95] box.signageos.io/status: box /status unauthenticated infra-info-leak (standing) (from reports/hypotheses-bigpickle.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org-UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide valid account JWT (X-Auth: <accountJWT>) and a foreign org UID to test cross-tenant POST /v1/organization/<foreign-org-uid>/security-token and GE
- NEXT(hypotheses-bigpickle.txt): PROBE: Standing reconfirm — next cycle `curl -sS https://box.signageos.io/status | sha256sum`; re-archive only if sha changes from `9559bb2a…`. Highest-value op
- NEXT(hypotheses-laguna.txt): PROBE: Confirm the standing POC durability with the rotated pod — already executed this cycle (pod 7v5xw, body sha `297672ef…4f06b2d`, grep=0). POC is complete 
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NO
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod `box-7cd9ddcc8c-6m52v` (stable this cycle), uid `89e006c0…`, Node v20.20.2, 9 succeededServ
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed hardened (HSTS/xfo/xcto/no-store), pod rotated to `api-6d67cd6668-ddtdf`, new body sha256 `b43532d5…`.
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: Reconfirmed — 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard; 0 credentials
- LEARN: REJECTED CORS-exploit @ box.signageos.io /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only (carried forward).
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass — cross-tenant chain remains AUTH_HELPED only (carried forwa
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward).

## RANKED HYPOTHESES 2026-08-12 03:17:48 UTC
- [95] box.signageos.io/status: box/status unauthenticated infra-info-leak with zero hardening headers (from reports/hypotheses-laguna.txt)
- [95] box.signageos.io/status: box /status unauthenticated infra-info-leak (standing) (from reports/hypotheses-bigpickle.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org-UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide valid account JWT (X-Auth: <accountJWT>) and a foreign org UID to test cross-tenant POST /v1/organization/<foreign-org-uid>/security-token and GE
- NEXT(hypotheses-laguna.txt): HUMAN: Box phase POC complete & archived at /tmp/opencode/artifacts/box-status/ (30+ cycles, current pod 7cd9ddcc8c-6m52v, body sha `f8927951c406…743ec`, grep=0
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NO
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* across 30+ cycles — not CORS-exploitable
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass — cross-tenant chain remains AUTH_HELPED only
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod box-7cd9ddcc8c-* rotation, zero security headers (grep=0), full topology leak unchanged beh
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed hardened (HSTS/xfo/xcto/no-store) behind CloudFront; info-leak persists but header posture hardened vs

## RANKED HYPOTHESES 2026-08-12 05:12:52 UTC
- [95] box.signageos.io/status: box /status unauthenticated infra-info-leak (standing) (from reports/hypotheses-bigpickle.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org-UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide valid account JWT (X-Auth: <accountJWT>) and a foreign org UID to test cross-tenant POST /v1/organization/<foreign-org-uid>/security-token and GE
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NO
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable

## RANKED HYPOTHESES 2026-08-12 06:49:00 UTC
- [95] box.signageos.io/status: box /status unauthenticated infra-info-leak with zero hardening headers (from reports/hypotheses-laguna.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org-UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide valid account JWT (X-Auth: <accountJWT>) and a foreign org UID to test cross-tenant POST /v1/organization/<foreign-org-uid>/security-token and GE
- NEXT(hypotheses-laguna.txt): HUMAN: Box phase POC complete & archived at `/tmp/opencode/artifacts/box-status/` (30+ cycles, pod `box-7cd9ddcc8c-f6xwn`, body sha `5bafacaf…`, zero hardening)
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NO
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: live this cycle (pod f6xwn, zero hardening, behind CloudFront) — box POC DONE
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: live (8 svc, mongoDB3 absent, HSTS+xfo+xcto+no-store intact) — hardening differential vs box persists
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ + /login/ CORS: 17 static ACAO unchanged, 0 creds flag — MISCONFIG-only
- LEARN: REJECTED IDOR @ api.signageos.io/v1/* pre-auth: /v1/org/test→403, /v2/device→403, all JWT/X-Auth-gated, no bypass — AUTH_HELPED only
- LEARN: REJECTED MISCONFIG @ box/signageos.io/ready: 200 "OK" (2 bytes), trivial — not reportable
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO — not exploitable
- LEARN: REJECTED AUTH @ box/signageos.io/login: Auth0 OAuth2 not passively testable without tenant session

## RANKED HYPOTHESES 2026-08-12 08:10:07 UTC
- [96] box.signageos.io/status: box /status unauthenticated infra-info-leak with zero hardening headers (from reports/hypotheses-laguna.txt)
- [95] box.signageos.io/status: Unauthenticated K8s topology leak via /status missing security headers (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide valid account JWT (X-Auth: <accountJWT>) and a foreign org UID to test cross-tenant POST /v1/organization/<foreign-org-uid>/security-token and GE
- NEXT(hypotheses-laguna.txt): HUMAN: Box phase POC complete & archived at `/tmp/opencode/artifacts/box-status/` (30+ cycles, pod `box-7cd9ddcc8c-bh6m7`, body sha `453f4a0b…`, zero hardening 
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NO
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: ACCEPTED @ box.signageos.io/status: Pod rotated to `box-7cd9ddcc8c-bh6m7`, uid `d450f1ea…`, full topology (amqp0/redis0-3/mongoDB0-3) + Node v20.20.2 + per-serv
- LEARN: ACCEPTED @ api.signageos.io/status: Still leaks hostname/uid/Node/topology; hardened with HSTS+xfo+xcto+no-store behind CloudFront SFO53-P12; info-leak persists
- LEARN: REJECTED @ box.signageos.io/ready: 200 OK (2 bytes), trivial health check, no data leaked.
- LEARN: REJECTED @ api.signageos.io/v1/*+v2/* pre-auth: All routes 403 JWT/X-Auth-gated, no passive bypass; cross-tenant chain remains AUTH_HELPED only (blocked on cred
- LEARN: ACCEPTED @ box.signageos.io/ + /login/ CORS: 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard, 0 credentials flag, evil.test NOT reflect

## RANKED HYPOTHESES 2026-08-12 09:28:40 UTC
- [96] box.signageos.io/status: box /status unauthenticated infra-info-leak with zero hardening headers (from reports/hypotheses-laguna.txt)
- [95] box.signageos.io/status: box /status unauthenticated infra-info-leak (standing) (from reports/hypotheses-bigpickle.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org-UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide valid account JWT (X-Auth: <accountJWT>) and a foreign org UID to test cross-tenant POST /v1/organization/<foreign-org-uid>/security-token and GE
- NEXT(hypotheses-bigpickle.txt): HUMAN: Box phase POC is complete and archived; the only remaining CRITICAL hypothesis is AUTH_HELPED. Request a valid account JWT (`sos login` output) and a sec
- NEXT(hypotheses-laguna.txt): HUMAN: Box phase POC complete & archived at `/tmp/opencode/artifacts/box-status/` (30+ cycles, pod `box-7cd9ddcc8c-25fdq`, zero hardening headers, grep=0). **Pr
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronte
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs bo
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NO
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable

## RANKED HYPOTHESES 2026-08-12 10:53:14 UTC
- [96] box.signageos.io/status: box /status unauthenticated infra-info-leak (standing, POC DONE) (from reports/hypotheses-bigpickle.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org-UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide valid account JWT (X-Auth: <accountJWT>) and a foreign org UID to test cross-tenant POST /v1/organization/<foreign-org-uid>/security-token and GE
- NEXT(hypotheses-bigpickle.txt): PROBE: box /status delta re-probe already executed this cycle (pod `box-7cd9ddcc8c-dn5db`, sha `578ce714…`, secgrep=0). POC phase on box is complete; escalate t
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged behind CloudFront
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS/xfo/xcto/no-store — differential vs box persists
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant session
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live 30+ cycles — pod rotation (`box-7cd9ddcc8c-dn5db`), zero hardening headers (secgrep=0), full topo
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed hardened (HSTS/xfo/xcto secgrep=3) behind CloudFront; info-leak (hostname/uid/Node/topology) persists 
- LEARN: REJECTED CORS-exploit @ box.signageos.io /login/: 17 static ACAO, 0 access-control-allow-credentials → no credential-theft path; MISCONFIG-only (carried forward
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: All routes 403 JWT/X-Auth-gated, no passive bypass; cross-tenant chain remains AUTH_HELPED only (blocked on
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403

## RANKED HYPOTHESES 2026-08-12 11:30:45 UTC
- [96] box.signageos.io/status: box /status unauthenticated infra-info-leak (standing, POC DONE) (from reports/hypotheses-bigpickle.txt)
- [96] box.signageos.io/status: box /status unauthenticated infra info-leak with zero response hardening (from reports/hypotheses-laguna.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org-UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide valid account JWT (X-Auth: <accountJWT>) and a foreign org UID to test cross-tenant POST /v1/organization/<foreign-org-uid>/security-token and GE
- NEXT(hypotheses-laguna.txt): HUMAN: Box phase POC complete & archived at `/tmp/opencode/artifacts/box-status/` (fresh probe: pod `box-8676fb5f57-fs8wj`, body sha `bdd3778a…`, zero hardening
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged behind CloudFront
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS/xfo/xcto/no-store — differential vs box persists
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant session
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: ACCEPTED @ box.signageos.io/status: Pod rotated to `box-8676fb5f57-fs8wj` (new rs `8676fb5f57`, was `7cd9ddcc8c`), uid `91fa0a7a…`, Node v20.20.2, 9 succeededSe
- LEARN: ACCEPTED @ api.signageos.io/status: Pod `api-86db648db5-p94sg` (new rs `86db648db5`, was `86db648db5-*`), uid `72556714…`, Node v24.19.0, 8 services (mongoDB3 a
- LEARN: ACCEPTED @ box.signageos.io/ + /login/ CORS: 17 static ACAO incl `http://` + `*.zdusercontent.com` wildcard, grep(credentials)=0, evil.test NOT reflected — MISC
- LEARN: REJECTED @ box.signageos.io/ready: 200 OK (2 bytes), trivial health check, no data leaked.
- LEARN: REJECTED @ api.signageos.io/v1/*+v2/* pre-auth: All routes 403 JWT/X-Auth-gated (confirmed /v1/organization/test → 403 WRONG_JWT_TOKEN/403105, /v2/device → 403)
- LEARN: REJECTED @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403076/403105

## RANKED HYPOTHESES 2026-08-12 12:36:47 UTC
- [96] box.signageos.io/status: box /status unauthenticated infra-info-leak with zero response hardening (from reports/hypotheses-laguna.txt)
- [96] box.signageos.io/status: box /status unauthenticated infra-info-leak (standing, POC DONE) (from reports/hypotheses-bigpickle.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org-UID override (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide valid account JWT (X-Auth: <accountJWT>) and a foreign org UID to test cross-tenant POST /v1/organization/<foreign-org-uid>/security-token and GE
- NEXT(hypotheses-bigpickle.txt): HUMAN: Provide a valid account JWT (`X-Auth: <accountJWT>` after `sos login`) plus one foreign org UID so I can run `curl -H "X-Auth: <accountJWT>" https://api.
- NEXT(hypotheses-laguna.txt): HUMAN: Box phase POC complete & archived at `/tmp/opencode/artifacts/box-status/` (fresh probe: pod `box-8676fb5f57-2lmr2`, body sha `0a88b388…`, zero hardening
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged behind CloudFront
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS/xfo/xcto/no-store — differential vs box persists
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant session
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 OK (2 bytes), trivial health check, no data leaked.
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable.
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks WRONG_JWT_TOKEN/Account not found/NO_ORGANIZATION_TO_AUTHENTICATE + 403105/403075 
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session.
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 access-control-allow-credentials → no credential-theft path; MISCONFIG-only.
- LEARN: ACCEPTED @ box.signageos.io/status: Reconfirmed live — pod rotated to `box-8676fb5f57-2lmr2` (uid `ce3b7110f5b14fa0c69147ae78c6a22e20ae55122e7ee3755f`, Node v20
- LEARN: ACCEPTED @ api.signageos.io/v1/organization/{uid}/security-token: PASSIVE-confirm 403 (WRONG_JWT_TOKEN/403105) on `.../test/security-token`; no pre-auth bypass;

## RANKED HYPOTHESES 2026-08-12 14:10:40 UTC
- [96] box.signageos.io/status: box /status unauthenticated infra-info-leak with zero response hardening (from reports/hypotheses-laguna.txt)
- [96] box.signageos.io/status: box /status unauthenticated infra-info-leak (standing, POC DONE) (from reports/hypotheses-bigpickle.txt)
- [96] box.signageos.io/status: Unauthenticated K8s topology leak via /status missing security headers (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide valid account JWT (X-Auth: <accountJWT>) and a foreign org UID to test cross-tenant POST /v1/organization/<foreign-org-uid>/security-token and GE
- NEXT(hypotheses-bigpickle.txt): HUMAN: Box phase POC is complete (artifacts re-archived; /status, CORS/CSP, /ready, login-Auth0 all dispositioned). Only high-value test left is AUTH_HELPED: pr
- NEXT(hypotheses-laguna.txt): HUMAN: Box phase POC complete & archived at `/tmp/opencode/artifacts/box-status/` (fresh probe: pod `box-8676fb5f57-2lmr2`, body sha `0a88b388…`, zero hardening
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged behind CloudFront
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS/xfo/xcto/no-store — differential vs box persists
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant session
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotated to `box-8676fb5f57-2lmr2` (new rs `8676fb5f57`), uid `ce3b7110…`, Node v20.20.2, fu
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live — pod rotation continuing, hardening intact (HSTS/xfo/xcto/no-store), info-leak (hostname/uid/Nod
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: Reconfirmed dead — all 60+ routes return 403 JWT/X-Auth-gated, zero ACAO under any Origin. No passive bypas
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: Reconfirmed — 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRE
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ + /login/ CORS: Reconfirmed — 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard + api sibling; 0 a
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: Reconfirmed — /login/ CSP 59+ distinct origins with triplicated Auth0 oauth/token; hardened (HSTS/xfo/xcto/CSP) on /+

## RANKED HYPOTHESES 2026-08-12 15:16:00 UTC
- [96] box.signageos.io/status: box /status unauthenticated infra-leak with zero response hardening (from reports/hypotheses-laguna.txt)
- [96] box.signageos.io/status: box /status unauthenticated infra-info-leak (standing, POC DONE) (from reports/hypotheses-bigpickle.txt)
- [96] box.signageos.io/status: Unauthenticated K8s topology leak via /status missing security headers (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: GET https://box.signageos.io/status (confirm live leak + zero hardening headers; expect 200 JSON with pod hostname/uid/topology, security-header grep=0)
- NEXT(hypotheses-bigpickle.txt): HUMAN: Box phase POC is final (re-archived: body sha `8e6b6596…`, secgrep=0, CORS 17 static/0-creds, CSP hardened). Only high-value test left is AUTH_HELPED: pr
- NEXT(hypotheses-laguna.txt): PROBE: api.signageos.io/v1/organization/{uid}/security-token
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged behind CloudFront
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS/xfo/xcto/no-store — differential vs box persists
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant session
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Fresh probe confirms pod box-8676fb5f57-t5z8v, Node v20.20.2, 9-service topology, zero hardening headers (grep=0) 
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Fresh probe confirms pod api-86db648db5-622tc, Node v24.19.0, 9-service topology (mongoDB3 healthy), hardened HSTS
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: Confirmed 200 OK (2 bytes) — trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ box.signageos.io CORS credential-theft: 17 static ACAO, access-control-allow-credentials grep=0 → no credential-theft path; MISCONFIG-only
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: All routes 403 JWT/X-Auth-gated (/organization/test/security-token → 403, /v2/device → 403, /v1/organizatio

## RANKED HYPOTHESES 2026-08-12 16:17:06 UTC
- [96] box.signageos.io/status: box /status unauthenticated infrastructure leak with zero response hardening (from reports/hypotheses-laguna.txt)
- [96] box.signageos.io/status: Unauthenticated K8s topology leak via /status missing security headers (from reports/hypotheses-nemotron3.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token mint via X-Auth org-UID path override (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: GET https://box.signageos.io/status (confirm live leak + zero hardening headers; expect 200 JSON with pod hostname/uid/topology, security-header grep=0)
- NEXT(hypotheses-bigpickle.txt): HUMAN: Box phase POC is final (re-archived: body sha `1ab65c16…`, secgrep=0, CORS 17 static/0-creds, CSP hardened). Only high-value test left is AUTH_HELPED: pr
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged behind CloudFront
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS/xfo/xcto/no-store — differential vs box persists
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant session
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: ACCEPTED @ box.signageos.io/status: Reconfirmed live — pod `box-8676fb5f57-9s62x`, uid `a5ec22b0…`, Node v20.20.2, 9-service topology, zero security headers (gr
- LEARN: ACCEPTED @ api.signageos.io/status: Reconfirmed live — pod `api-86db648db5-twc7j`, uid `a3356c02…`, Node v24.19.0, 8-service topology (mongoDB3 absent this cycl
- LEARN: ACCEPTED @ box.signageos.io/ + /login/ CORS: Reconfirmed — 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard + api sibling + path-bearing
- LEARN: ACCEPTED @ box.signageos.io CSP: Reconfirmed — /login/ CSP 59+ origins with triplicated Auth0 oauth/token; hardened (HSTS/xfo/xcto/CSP present on / + /login/). 
- LEARN: REJECTED @ box.signageos.io/ready: 200 "OK" (2 bytes) — trivial health check, no data leaked (unchanged this cycle).
- LEARN: REJECTED @ box.signageos.io/csp-report: 302 login redirect — not an exposed endpoint.
- LEARN: REJECTED @ api.signageos.io/ root: HTTP 200, 0 ACAO under any Origin, 3 hardening headers — not CORS-exploitable.
- LEARN: REJECTED @ api.signageos.io v1/*+v2/* pre-auth: All routes 403 JWT/X-Auth-gated (/v1/organization/test → 403, /v2/device → 403, /organization/test/security-toke
- LEARN: REJECTED @ api.signageos.io v1/* descriptive errors: 403 body leaks `WRONG_JWT_TOKEN`/`NO_ORGANIZATION_TO_AUTHENTICATE`/`WRONG_ACCOUNT_SECRET` + errorCode 40310
- LEARN: REJECTED @ box.signageos.io/login Auth0 OAuth2: redirect_uri/state binding — not passively testable without tenant/authenticated session; all unauthenticated au

## RANKED HYPOTHESES 2026-08-12 17:29:45 UTC
- [96] box.signageos.io/status: box /status unauthenticated infrastructure leak with zero response hardening (from reports/hypotheses-laguna.txt)
- [96] box.signageos.io/status: Unauthenticated K8s topology leak via /status missing security headers (from reports/hypotheses-nemotron3.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token mint via X-Auth org-UID path override (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: GET https://box.signageos.io/status (confirm live leak + zero hardening headers; expect 200 JSON with pod hostname/uid/topology, security-header grep=0)
- NEXT(hypotheses-bigpickle.txt): HUMAN: Box phase POC is final (status leak re-archived, body sha `baa2b543…`, secgrep=0; CORS/CSP settled). Only high-value test left is AUTH_HELPED: provide a 
- NEXT(hypotheses-laguna.txt): HUMAN: Box phase POC is final (re-archived: body sha `1ab65c16…`, secgrep=0, CORS 17 static/0-creds, CSP hardened). Only high-value test left is AUTH_HELPED: pr
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged behind CloudFront
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS/xfo/xcto/no-store — differential vs box persists
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant session
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: ACCEPTED @ box.signageos.io/status: Reconfirmed live — pod `box-8676fb5f57-9s62x`, uid `a5ec22b0…`, Node v20.20.2, 9-service topology, zero security headers (gr
- LEARN: ACCEPTED @ api.signageos.io/status: Reconfirmed live — pod `api-86db648db5-twc7j`, uid `a3356c02…`, Node v24.19.0, 8-service topology (mongoDB3 absent this cycl
- LEARN: ACCEPTED @ box.signageos.io/ + /login/ CORS: Reconfirmed — 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard + api sibling + path-bearing
- LEARN: ACCEPTED @ box.signageos.io CSP: Reconfirmed — /login/ CSP 59+ origins with triplicated Auth0 oauth/token; hardened (HSTS/xfo/xcto/CSP present on / + /login/). 
- LEARN: REJECTED @ box.signageos.io/ready: 200 "OK" (2 bytes) — trivial health check, no data leaked (unchanged this cycle).
- LEARN: REJECTED @ box.signageos.io/csp-report: 302 login redirect — not an exposed endpoint.
- LEARN: REJECTED @ api.signageos.io/ root: HTTP 200, 0 ACAO under any Origin, 3 hardening headers — not CORS-exploitable.
- LEARN: REJECTED @ api.signageos.io v1/*+v2/* pre-auth: All routes 403 JWT/X-Auth-gated (/v1/organization/test → 403, /v2/device → 403, /organization/test/security-toke
- LEARN: REJECTED @ api.signageos.io v1/* descriptive errors: 403 body leaks `WRONG_JWT_TOKEN`/`NO_ORGANIZATION_TO_AUTHENTICATE`/`WRONG_ACCOUNT_SECRET` + errorCode 40310
- LEARN: REJECTED @ box.signageos.io/login Auth0 OAuth2: redirect_uri/state binding — not passively testable without tenant/authenticated session; all unauthenticated au
- LEARN: ACCEPTED @ box.signageos.io/status: Reconfirmed live — pod `box-8676fb5f57-9s62x`, uid `a5ec22b0…`, Node v20.20.2, 9-service topology, zero security headers (gr
- LEARN: ACCEPTED @ api.signageos.io/status: Reconfirmed live — pod `api-86db648db5-twc7j`, uid `a3356c02…`, Node v24.19.0, 8-service topology (mongoDB3 absent this cycl
- LEARN: ACCEPTED @ box.signageos.io/ + /login/ CORS: Reconfirmed — 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard + api sibling + path-bearing
- LEARN: ACCEPTED @ box.signageos.io CSP: Reconfirmed — /login/ CSP 59+ origins with triplicated Auth0 oauth/token; hardened (HSTS/xfo/xcto/CSP present on / + /login/). 
- LEARN: REJECTED @ box.signageos.io/ready: 200 "OK" (2 bytes) — trivial health check, no data leaked (unchanged this cycle).
- LEARN: REJECTED @ box.signageos.io/csp-report: 302 login redirect — not an exposed endpoint.
- LEARN: REJECTED @ api.signageos.io/ root: HTTP 200, 0 ACAO under any Origin, 3 hardening headers — not CORS-exploitable.
- LEARN: REJECTED @ api.signageos.io v1/*+v2/* pre-auth: All routes 403 JWT/X-Auth-gated (/v1/organization/test → 403, /v2/device → 403, /organization/test/security-toke
- LEARN: REJECTED @ api.signageos.io v1/* descriptive errors: 403 body leaks `WRONG_JWT_TOKEN`/`NO_ORGANIZATION_TO_AUTHENTICATE`/`WRONG_ACCOUNT_SECRET` + errorCode 40310
- LEARN: REJECTED @ box.signageos.io/login Auth0 OAuth2: redirect_uri/state binding — not passively testable without tenant/authenticated session; all unauthenticated au
- LEARN: ACCEPTED @ box.signageos.io/status: Reconfirmed live — pod `box-8676fb5f57-9s62x`, uid `a5ec22b0…`, Node v20.20.2, 9-service topology, zero security headers (gr
- LEARN: ACCEPTED @ api.signageos.io/status: Reconfirmed live — pod `api-86db648db5-twc7j`, uid `a3356c02…`, Node v24.19.0, 8-service topology (mongoDB3 absent this cycl
- LEARN: ACCEPTED @ box.signageos.io/ + /login/ CORS: Reconfirmed — 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard + api sibling + path-bearing
- LEARN: ACCEPTED @ box.signageos.io CSP: Reconfirmed — /login/ CSP 59+ origins with triplicated Auth0 oauth/token; hardened (HSTS/xfo/xcto/CSP present on / + /login/). 
- LEARN: REJECTED @ box.signageos.io/ready: 200 "OK" (2 bytes) — trivial health check, no data leaked (unchanged this cycle).
- LEARN: REJECTED @ box.signageos.io/csp-report: 302 login redirect — not an exposed endpoint.
- LEARN: REJECTED @ api.signageos.io/ root: HTTP 200, 0 ACAO under any Origin, 3 hardening headers — not CORS-exploitable.
- LEARN: REJECTED @ api.signageos.io v1/*+v2/* pre-auth: All routes 403 JWT/X-Auth-gated (/v1/organization/test → 403, /v2/device → 403, /organization/test/security-toke
- LEARN: REJECTED @ api.signageos.io v1/* descriptive errors: 403 body leaks `WRONG_JWT_TOKEN`/`NO_ORGANIZATION_TO_AUTHENTICATE`/`WRONG_ACCOUNT_SECRET` + errorCode 40310
- LEARN: REJECTED @ box.signageos.io/login Auth0 OAuth2: redirect_uri/state binding — not passively testable without tenant/authenticated session; all unauthenticated au

## RANKED HYPOTHESES 2026-08-12 18:18:43 UTC
- [96] box.signageos.io/status: Unauthenticated K8s topology leak via /status missing security headers (from reports/hypotheses-nemotron3.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token mint via X-Auth org-UID path override (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: GET https://box.signageos.io/status (confirm live leak + zero hardening headers; expect 200 JSON with pod hostname/uid/topology, security-header grep=0)
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged behind CloudFront
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS/xfo/xcto/no-store — differential vs box persists
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant session
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable

## RANKED HYPOTHESES 2026-08-12 19:38:19 UTC
- [96] box.signageos.io/status: box /status unauthenticated infra-info-leak (standing, POC final) (from reports/hypotheses-laguna.txt)
- [96] box.signageos.io/status: box /status unauthenticated infra-info-leak (standing, POC DONE) (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-laguna.txt): HUMAN: Box POC is final and archived. Only high-value test left is AUTH_HELPED on the CRITICAL api chain: provide a valid account JWT (`<accountJWT>` after `sos
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: confirmed live — 403 body leaks `WRONG_JWT_TOKEN`/`Account not found`/`errorCode 403105`/`errorNa
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: confirmed — 0 ACAO on /, /status, /v1/*, /v2/* under spoofed Origin `https://evil.test`; `vary: Origin` + `access-co
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: reconfirmed live — pod `box-8676fb5f57-9s62x` (new uid `7c62c9f1…`), Node v20.20.2, 9-svc topology, secgrep=0, beh
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: reconfirmed live — pod `api-86db648db5-v8vpm` (rs rotation), Node v24.19.0, 8-svc (mongoDB3 absent), hardened HSTS
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: reconfirmed — `/v1/organization/test` → 403 WRONG_JWT_TOKEN/403105, `/v2/device` → 403; all routes JWT/X-Au

## RANKED HYPOTHESES 2026-08-12 20:10:20 UTC
- [96] box.signageos.io/status: Unauthenticated K8s topology leak via /status missing security headers (from reports/hypotheses-nemotron3.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token mint via X-Auth org-UID path override (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-nemotron3.txt): PROBE: GET https://box.signageos.io/status (confirm live leak + zero hardening headers; expect 200 JSON with pod hostname/uid/topology, security-header grep=0)
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged behind CloudFront
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS/xfo/xcto/no-store — differential vs box persists
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant session
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable

## RANKED HYPOTHESES 2026-08-12 21:05:37 UTC
- [96] box.signageos.io/status: box /status unauthenticated infra-info-leak (from reports/hypotheses-laguna.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org-UID override (from reports/hypotheses-nemotron3.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token mint via X-Auth org-UID path override (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide a valid account JWT (`<accountJWT>` after `sos login`) + a foreign org UID to test the CRITICAL cross-tenant chain on api.signageos.io/v1/organiz
- NEXT(hypotheses-bigpickle.txt): HUMAN: Box POC is final and archived. The only remaining high-value test is the CRITICAL AUTH_HELPED chain: provide a valid account JWT from `sos login` (state:
- NEXT(hypotheses-laguna.txt): HUMAN: Box POC is final and archived (body sha `a261a928…`, secgrep=0, 30+ cycles stable). Only remaining high-value test is AUTH_HELPED on the CRITICAL api cha
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged behind CloudFront
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS/xfo/xcto/no-store — differential vs box persists
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant session
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: reconfirmed — `/v1/organization/test` → 403 WRONG_JWT_TOKEN/403105, `/v2/device` → 403; all routes JWT/X-Au
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: reconfirmed live — pod `box-8676fb5f57-2lmr2`, Node v20.20.2, 9-svc topology, secgrep=0, behind CloudFront IAD55-P
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: reconfirmed live — pod `api-86db648db5-p94sg`, Node v24.19.0, 8-svc (mongoDB3 absent), hardened HSTS/xfo/xcto/no-s
- LEARN: ACCEPTED @ box.signageos.io/status: Reconfirmed live this cycle — pod box-8676fb5f57-2lmr2 (uid ce3b7110…), Node v20.20.2, 9-svc topology (amqp0/redis0-3/mongoD
- LEARN: ACCEPTED @ api.signageos.io/status: Reconfirmed live — pod api-86db648db5-twc7j (uid a3356c02…), Node v24.19.0, 8 services (mongoDB3 absent), hardened HSTS/xfo/
- LEARN: ACCEPTED @ box.signageos.io/ + /login/ CORS: Reconfirmed — 17 static ACAO incl http://plaintext + *.zdusercontent.com wildcard + api sibling; 0 credentials flag
- LEARN: REJECTED @ api.signageos.io/v1/*+v2/* pre-auth: All 60+ routes 403 JWT/X-Auth-gated, 0 ACAO, no passive bypass — cross-tenant mint remains AUTH_HELPED only.
- LEARN: REJECTED @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403076/403105
- LEARN: REJECTED @ box.signageos.io/login Auth0 OAuth2: redirect_uri/state binding — not passively testable without tenant/authenticated session.

## RANKED HYPOTHESES 2026-08-12 22:00:43 UTC
- [96] box.signageos.io/status: Unauthenticated K8s topology leak via /status missing security headers (from reports/hypotheses-nemotron3.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token mint via X-Auth org-UID path override (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide a valid account JWT (`<accountJWT>` after `sos login`) + a foreign org UID to test the CRITICAL cross-tenant chain on api.signageos.io/v1/organiz
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged behind CloudFront
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS/xfo/xcto/no-store — differential vs box persists
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant session
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable

## RANKED HYPOTHESES 2026-08-12 22:55:22 UTC
- [96] box.signageos.io/status: box /status unauthenticated infra-info-leak (zero headers) (from reports/hypotheses-laguna.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token minting via X-Auth org-UID override (from reports/hypotheses-nemotron3.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token mint via X-Auth org-UID path override (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide a valid account JWT (`<accountJWT>` after `sos login`) + a foreign org UID to test the CRITICAL cross-tenant chain on api.signageos.io/v1/organiz
- NEXT(hypotheses-bigpickle.txt): HUMAN: Box POC final and archived (30+ cycles stable, secgrep=0). No new passive surface after pod-rotation-only delta. Only remaining high-value test is the CR
- NEXT(hypotheses-laguna.txt): HUMAN: Box POC final & archived (30+ cycles, body sha in artifacts/box-status/). Only remaining CRITICAL test is AUTH_HELPED on api: provide a valid account JWT
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged behind CloudFront
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS/xfo/xcto/no-store — differential vs box persists
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant session
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: reconfirmed live this cycle — pod box-8676fb5f57-2lmr2, secgrep=0, cloudfront front, 9-svc topology incl mongoDB3 
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: reconfirmed hardened (HSTS/xfo/xcto/no-store) — differential vs box persists, info-leak persists.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: reconfirmed all 403 JWT/X-Auth-gated, 0 ACAO under evil.test — no passive bypass; cross-tenant mint remains
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 access-control-allow-credentials → no credential-theft path → MISCONFIG-only.
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state — not passively testable without tenant/authenticated session; no unauth authn surface b

## RANKED HYPOTHESES 2026-08-12 23:41:27 UTC
- [96] box.signageos.io/status: box /status unauthenticated infra-info-leak (zero security headers) (from reports/hypotheses-laguna.txt)
- [96] box.signageos.io/status: Unauthenticated K8s topology leak via /status missing security headers (from reports/hypotheses-nemotron3.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token mint via X-Auth org-UID path override (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide a valid account JWT (`<accountJWT>` after `sos login`) + a foreign org UID to test the CRITICAL cross-tenant chain on api.signageos.io/v1/organiz
- NEXT(hypotheses-laguna.txt): HUMAN: Box POC final & archived (30+ cycles stable, secgrep=0, confirmed live this cycle after transient-504 recovery). Only remaining CRITICAL test is AUTH_HEL
- NEXT(hypotheses-bigpickle.txt): HUMAN: Box POC final and archived (30+ cycles stable, secgrep=0, body sha `bc5ea93c…`). Only remaining high-value test is the CRITICAL AUTH_HELPED chain — provi
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged behind CloudFront
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS/xfo/xcto/no-store — differential vs box persists
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant session
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: REJECTED @ box.signageos.io/status: transient HTTP 504 at 2026-08-12 22:00 UTC — recovered to 200 in next cycle, no functional impact (confirmed live via fresh 
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: reconfirmed live this cycle — pod box-8676fb5f57-2lmr2, Node v20.20.2, 9-service topology, secgrep=0, behind Cloud
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/ + /login/ CORS: reconfirmed 17 static ACAO incl http:// plaintext + *.zdusercontent.com wildcard, 0 access-control-allow-
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: reconfirmed /login/ has 59+ connect-src/frame-src origins (triplicated Auth0 oauth/token) — hardened (HSTS/xfo/xcto/C
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: reconfirmed live this cycle — Node v24.19.0, 8 services (mongoDB3 absent), hardened HSTS/xfo/xcto (grep=3, cache-c
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: reconfirmed — all 60+ routes 403 JWT/X-Auth-gated (/v1/org/test → 403, /v2/device → 403), zero ACAO under e
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + 403075/403
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* under any Origin — not CORS-exploitable (carried forward)
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes) — trivial health check, no data leaked (carried forward)
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: reconfirmed live this cycle — pod `box-8676fb5f57-ff2s4`, secgrep=0 (x-powered-by: Express only), full 9-svc topol
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: reconfirmed hardened (HSTS/xfo/xcto grep=3) behind CloudFront LAX50-P4 — differential vs box persists.
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: unchanged — all 60+ routes 403 JWT/X-Auth-gated, zero ACAO under any Origin; no passive bypass; cross-tenan
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: unchanged — 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET 
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 OK (2 bytes), trivial health check, no data leaked.
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 access-control-allow-credentials → no credential-theft path; MISCONFIG-only.

## RANKED HYPOTHESES 2026-08-13 00:44:28 UTC
- [96] box.signageos.io/status: box /status unauthenticated infra-info-leak (POC final) (from reports/hypotheses-bigpickle.txt)
- [96] box.signageos.io/status: Unauthenticated K8s topology leak via /status missing security headers (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide a valid account JWT (`<accountJWT>` after `sos login`) + a foreign org UID to test the CRITICAL cross-tenant chain on api.signageos.io/v1/organiz
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged behind CloudFront
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS/xfo/xcto/no-store — differential vs box persists
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant session
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable

## RANKED HYPOTHESES 2026-08-13 03:27:55 UTC
- [96] box.signageos.io/status: box /status unauthenticated infra-info-leak with zero response hardening (from reports/hypotheses-laguna.txt)
- [96] box.signageos.io/status: box /status unauthenticated infra-info-leak (POC final) (from reports/hypotheses-bigpickle.txt)
- [96] box.signageos.io/status: Unauthenticated K8s topology leak via /status missing security headers (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide a valid account JWT (`<accountJWT>` after `sos login`) + a foreign org UID to test the CRITICAL cross-tenant chain on api.signageos.io/v1/organiz
- NEXT(hypotheses-laguna.txt): PROBE: `curl -s -o /tmp/api_status_body.json -D /tmp/api_status_headers.txt https://api.signageos.io/status` → confirm HTTP 200 JSON leaking hostname/uid/Node v
- NEXT(hypotheses-bigpickle.txt): HUMAN: Box POC final/archived (this cycle pod `h6d4t`, secgrep=0, body sha `97bd6ec0…`). Only remaining CRITICAL test is AUTH_HELPED — provide a valid account J
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged behind CloudFront
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS/xfo/xcto/no-store — differential vs box persists
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant session
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live this cycle — pod `box-8676fb5f57-l4pxv` (uid `dadfa18d…`), Node v20.20.2, 9-service topology (amq
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live this cycle — pod `api-86db648db5-p94sg` (uid `72556714…`), Node v24.19.0, 8 services (mongoDB3 ab
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: Reconfirmed — /v1/organization/test → 403, /v2/device → 403, /v1/device → 403, /v1/organization/test/securi
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked — unchanged
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* under any Origin — not CORS-exploitable
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session; no unauthenticate
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl http:// plaintext + *.zdusercontent.com wildcard + api sibling; evil.test NOT reflecte

## RANKED HYPOTHESES 2026-08-13 05:14:47 UTC
- [96] box.signageos.io/status: box /status unauthenticated infra-leak with zero response hardening (from reports/hypotheses-laguna.txt)
- [96] box.signageos.io/status: box /status unauthenticated infra-info-leak (POC final) (from reports/hypotheses-bigpickle.txt)
- [96] box.signageos.io/status: Unauthenticated K8s topology leak via /status missing security headers (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide a valid account JWT (`<accountJWT>` after `sos login`) + a foreign org UID to test the CRITICAL cross-tenant chain on api.signageos.io/v1/organiz
- NEXT(hypotheses-laguna.txt): PROBE: curl -s -o /tmp/api_status_body.json -D /tmp/api_status_headers.txt https://api.signageos.io/status → confirm HTTP 200 JSON leaking hostname/uid/Node v24
- NEXT(hypotheses-bigpickle.txt): HUMAN: Box POC final/archived (this cycle pod `ld6rr`, secgrep=0, IAD55-P8). Only remaining CRITICAL test is AUTH_HELPED — provide a valid account JWT from `sos
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged behind CloudFront
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS/xfo/xcto/no-store — differential vs box persists
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant session
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 OK (2 bytes) — trivial health check, no data leaked (unchanged this cycle)
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant session
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live this cycle — pod `box-8676fb5f57-l4pxv` (uid `dadfa18d…`), Node v20.20.2, 9-service topology, zer
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live this cycle — pod `api-86db648db5-p94sg` (uid `72556714…`), Node v24.19.0, 8 services (mongoDB3 ab
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: Reconfirmed — /v1/organization/test → 403, /v2/device → 403, /v1/device → 403, /v1/organization/test/securi
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 

## RANKED HYPOTHESES 2026-08-13 06:51:52 UTC
- [96] box.signageos.io/status: Unauthenticated K8s topology leak via /status missing security headers (from reports/hypotheses-nemotron3.txt)
- [78] api.signageos.io/v1/organization/{uid}/security-token: Cross-tenant security-token mint via X-Auth account-id path override (from reports/hypotheses-bigpickle.txt)
- NEXT(hypotheses-nemotron3.txt): HUMAN: Provide a valid account JWT (`<accountJWT>` after `sos login`) + a foreign org UID to test the CRITICAL cross-tenant chain on api.signageos.io/v1/organiz
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged behind CloudFront
- LEARN: ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS/xfo/xcto/no-store — differential vs box persists
- LEARN: REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed)
- LEARN: REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 
- LEARN: REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant session
- LEARN: REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
- LEARN: REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
