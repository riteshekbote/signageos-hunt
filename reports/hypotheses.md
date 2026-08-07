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
