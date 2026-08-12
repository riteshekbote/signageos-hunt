# LEADS nemotron3 (seed)
- SEED: no model output yet.
## 2026-08-07 18:32:43 UTC [api] (model nemotron3)
[NEW] api.signageos.io: Root (/) serves static HTML landing page (37KB), not API JSON — no public API surface exposed (404 on /v1, /v2, /health, /docs, /api, /swagger.json, /openapi.json)
[NEW] box.signageos.io: 302 → /login/%2F with Auth0 OAuth2 flow (sos-production.us.auth0.com, auth0.signageos.io in CSP connect-src) — confirms Auth0 as IdP
[NEW] box.signageos.io CSP reveals extensive 3rd-party integrations: Mapbox, Sentry, MoodMedia/BroadSign/Sony device APIs, remote-desktop.signageos.io, upload.signageos.io, platform.signageos.io, license.signageos.io, S3 buckets, Zendesk — broad attack surface via postMessage/origin trust
[CHANGED] api.signageos.io auth model unknown — no public docs, no swagger, no obvious auth headers on root; SDK/cli repos (signageos org, 59 repos) likely contain actual endpoint mappings and auth schemes
[PRIO] box.signageos.io/login (Auth0 callback/origin flow), score=72, axes: attack=8, business=9, tech=8 (OAuth2/Auth0/nonce-CSP/trusted-types), gate=8 (no auth needed to probe login), cloud=7 (Auth0, S3, Mapbox, device APIs), fresh=7
[PRIO] api.signageos.io (root + hidden endpoints), score=68, axes: attack=7, business=9, tech=6 (CloudFront, no public spec), gate=10 (public root), cloud=7 (AWS, likely internal microservices), fresh=6
[PRIO] box.signageos.io CSP origins (remote-desktop, upload, platform, license, device APIs), score=65, axes: attack=8, business=8, tech=7 (postMessage/origin checks, websockets), gate=6 (requires login), cloud=8 (many subdomains/AWS), fresh=7
[HYP] Auth0 redirect_uri validation bypass on box.signageos.io
class: AUTH
asset: box.signageos.io/login
confidence: 65
reasoning: Auth0 OAuth2 flow with redirect to /login/%2F; CSP allows multiple auth0 origins (sos-production.us.auth0.com, auth0.signageos.io); nonce-based CSP with strict-dynamic may allow gadget chaining if redirect_uri not strictly validated against allowlist
evidence_needed: Test redirect_uri parameter manipulation to arbitrary allowed CSP origins (e.g., https://auth0.signageos.io, https://sos-production.us.auth0.com) or subdomain takeover targets
verify_steps: GET https://box.signageos.io/login/%2F?redirect_uri=https://auth0.signageos.io/xxx — observe if Auth0 accepts and redirects back with code; test state parameter reuse
impact: Account takeover via OAuth code theft; severity HIGH
testability: PASSIVE (initial probe), AUTH_HELPED (full flow)
[HYP] IDOR on api.signageos.io via undiscovered versioned endpoints
class: IDOR
asset: api.signageos.io
confidence: 55
reasoning: No public API spec; 404 on /v1,/v2,/health,/docs; SDK/cli repos (TypeScript) likely contain actual endpoint paths and auth headers; API root serves HTML not JSON suggesting versioned paths exist elsewhere or require specific headers
evidence_needed: Discovery of actual API base path (e.g., /api/v1, /rest, /graphql) and auth scheme (API key? JWT? mTLS?)
verify_steps: GET https://api.signageos.io/api/v1 (and common variants) with/without Authorization: Bearer <null>; check SDK source for baseURL patterns (passive: clone signageos/sdk repo)
impact: Unauthorized access to device management, content distribution, user data; severity CRITICAL
testability: PASSIVE (recon), AUTH_HELPED (with token)
[HYP] postMessage/origin confusion across box.signageos.io subdomains (remote-desktop, upload, platform, license)
class: OTHER
asset: box.signageos.io (CSP origins)
confidence: 50
reasoning: CSP connect-src/frame-src allows 20+ subdomains including remote-desktop.signageos.io, upload.signageos.io, platform.signageos.io, license.signageos.io; if any embed box in iframe or receive postMessage, origin validation flaws could leak tokens or trigger actions
evidence_needed: Identify which origins embed box or listen for postMessage; test messageEvent.origin checks
verify_steps: PASSIVE: enumerate subdomains via cert transparency; AUTH_HELPED: login, open devtools, inspect iframe/postMessage listeners on each CSP-listed origin
impact: Cross-origin data leakage, action forgery on integrated services; severity MEDIUM-HIGH
testability: AUTH_HELPED
[PARKED] Auth0 redirect_uri validation bypass on box.signageos.io: confidence 65 but verify_steps require Auth0 tenant interaction — may be blocked by Auth0 allowlist config; cannot confirm without tenant access
[PARKED] IDOR on api.signageos.io via undiscovered versioned endpoints: confidence 55 but no concrete endpoint discovered; pure speculation without SDK mapping
[PARKED] postMessage/origin confusion across box.signageos.io subdomains: confidence 50 but requires authenticated session and manual iframe analysis; no passive evidence of vulnerable listeners
[FINAL] (no surviving hypotheses above threshold — all parked due to insufficient passive evidence or auth-required verification)
[NEXT] RAG: Clone and grep signageos/sdk (TypeScript) and signageos/cli repos for API baseURL patterns, auth header construction, and endpoint paths — this maps the hidden api.signageos.io surface passively
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation not testable passively without tenant config access
[LEARN] REJECTED IDOR @ api.signageos.io: No public API endpoints discoverable via passive probing (all common paths 404)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CSP: Overly broad connect-src/frame-src (20+ origins) confirmed — expands postMessage/origin trust boundary
[RISK] box.signageos.io: 75 — Auth0 OAuth2 flow, broad CSP trust boundary (20+ origins including device mgmt APIs, S3, websockets), Sentry/reCAPTCHA nonces, CloudFront; high business value (player/dashboard admin)
[RISK] api.signageos.io: 60 — No public API surface, hidden behind CloudFront, auth model unknown, but high business value (core backend); risk driven by unknown attack surface via SDK/cli code
## 2026-08-07 18:56:16 UTC [api] (model nemotron3)
[PRIO] box.signageos.io/login (Auth0 OAuth2 callback), score=8.05, axes: attack=8, business=9, tech=8 (OAuth2/Auth0/nonce-CSP/trusted-types), gate=8 (no auth needed), cloud=7 (Auth0,S3,Mapbox,device APIs), fresh=7
[PRIO] api.signageos.io (root + hidden endpoints), score=7.70, axes: attack=7, business=9, tech=6 (CloudFront,no public spec), gate=10 (public root), cloud=7 (AWS,internal microservices), fresh=6
[PRIO] signageos/sdk & cli repos (GitHub), score=7.70, axes: attack=7, business=8, tech=7 (TS,auth headers,baseURL), gate=10 (public), cloud=6 (code refs), fresh=8 (active)
[PRIO] box.signageos.io CSP origins (remote-desktop,upload,platform,license), score=7.45, axes: attack=8, business=8, tech=7 (postMessage,WS,Express), gate=6 (needs login), cloud=8 (subdomains,AWS,S3), fresh=7
[HYP] api.signageos.io responds with API JSON when proper Accept header sent
class: IDOR
asset: api.signageos.io/
confidence: 50
reasoning: Root serves static HTML (37KB) with 404 on all common paths; SDK/cli repos likely reference actual API via headers (Accept: application/json, Authorization, x-api-key); CloudFront vary: Origin suggests content negotiation
evidence_needed: Response with JSON content-type and API structure when requesting with Accept: application/json or SDK-observed headers
verify_steps: GET https://api.signageos.io/ -H "Accept: application/json" -H "Authorization: Bearer null" -H "x-api-key: test" — observe Content-Type and body; passive RAG: clone signageos/sdk repo grep for baseURL, headers, auth patterns
impact: Unauthorized access to device management, content distribution, user data; severity CRITICAL
testability: PASSIVE
[HYP] postMessage origin validation bypass between box.signageos.io and remote-desktop/upload.signageos.io
class: OTHER
asset: box.signageos.io (CSP frame-src: remote-desktop.signageos.io, upload.signageos.io)
confidence: 45
reasoning: CSP allows frame-src for remote-desktop.signageos.io and upload.signageos.io; both serve identical Express HTML (same etag W/"90ac-...", 37036 bytes); if either embeds box in iframe or listens for postMessage, loose origin checks could leak tokens or trigger actions
evidence_needed: postMessage event listener on remote-desktop/upload that accepts messages from box.signageos.io without strict origin validation; or box embedding them without sandbox
verify_steps: PASSIVE: GET https://remote-desktop.signageos.io/ and https://upload.signageos.io/ — inspect HTML for postMessage listeners, iframe embeds, messageEvent.origin checks; AUTH_HELPED: login, open devtools, inspect iframe/postMessage on each CSP-listed origin
impact: Cross-origin data leakage, action forgery on device management/upload; severity MEDIUM-HIGH
testability: PASSIVE (initial), AUTH_HELPED (full)
[HYP] Auth0 OAuth2 state parameter not bound to session on box.signageos.io/login
class: AUTH
asset: box.signageos.io/login/%2F
confidence: 40
reasoning: Login initiates Auth0 OAuth2 flow to sos-production.us.auth0.com and auth0.signageos.io; CSP frame-src allows both; if state parameter not cryptographically bound to user session, login CSRF possible (distinct from excluded logout/anonymous-form CSRF)
evidence_needed: Auth0 authorization request accepts arbitrary state value and returns it unchanged without session binding; callback processes code without state verification
verify_steps: GET https://box.signageos.io/login/%2F — extract Auth0 authorize URL, observe state parameter generation; initiate flow with attacker-controlled state, observe if callback validates it against session
impact: Account takeover via login CSRF; severity HIGH
testability: PASSIVE (initial), AUTH_HELPED (full flow)
[PARKED] Auth0 OAuth2 state parameter not bound to session on box.signageos.io/login: class AUTH — login form is anonymous-accessible; program excludes "CSRF on forms that are available to anonymous users"; verify_steps require Auth0 tenant interaction for full validation; prior REJECTED AUTH @ box.signageos.io/login confirms this vector not viable passively
[FINAL] Ranked surviving hypotheses:
[NEXT] PROBE: GET https://api.signageos.io/ -H "Accept: application/json" -H "Authorization: Bearer null" -H "x-api-key: test" — observe Content-Type and body for JSON API surface
[LEARN] REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state parameter — class AUTH excluded as "CSRF on forms that are available to anonymous users" per scope.yml
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CSP: overly broad connect-src/frame-src (20+ origins) confirmed — expands postMessage/origin trust boundary (carried forward from 2026-08-07)
[LEARN] REJECTED IDOR @ api.signageos.io via undiscovered versioned endpoints: no public endpoints discoverable via passive probing (all common paths 404) — carried forward from 2026-08-07
[RISK] box.signageos.io: 75 — Auth0 OAuth2 flow, broad CSP trust boundary (20+ origins including device mgmt APIs, S3, websockets), Sentry/reCAPTCHA nonces, CloudFront; high business value (player/dashboard admin); postMessage/origin boundary expanded by remote-desktop/upload/platform/license subdomains
[RISK] api.signageos.io: 60 — No public API surface, hidden behind CloudFront, auth model unknown, but high business value (core backend); risk driven by unknown attack surface via SDK/cli code mappings
[PRIO] box.signageos.io/login (Auth0 OAuth2 callback), score=8.05, axes: attack=8, business=9, tech=8 (OAuth2/Auth0/nonce-CSP/trusted-types), gate=8 (no auth needed), cloud=7 (Auth0,S3,Mapbox,device APIs), fresh=7
[PRIO] api.signageos.io (root + hidden endpoints), score=7.70, axes: attack=7, business=9, tech=6 (CloudFront,no public spec), gate=10 (public root), cloud=7 (AWS,internal microservices), fresh=6
[PRIO] signageos/sdk & cli repos (GitHub), score=7.70, axes: attack=7, business=8, tech=7 (TS,auth headers,baseURL), gate=10 (public), cloud=6 (code refs), fresh=8 (active)
[PRIO] box.signageos.io CSP origins (remote-desktop,upload,platform,license), score=7.45, axes: attack=8, business=8, tech=7 (postMessage,WS,Express), gate=6 (needs login), cloud=8 (subdomains,AWS,S3), fresh=7
[HYP] api.signageos.io responds with API JSON when proper Accept header sent
class: IDOR
asset: api.signageos.io/
confidence: 50
reasoning: Root serves static HTML (37KB) with 404 on all common paths; SDK/cli repos likely reference actual API via headers (Accept: application/json, Authorization, x-api-key); CloudFront vary: Origin suggests content negotiation
evidence_needed: Response with JSON content-type and API structure when requesting with Accept: application/json or SDK-observed headers
verify_steps: GET https://api.signageos.io/ -H "Accept: application/json" -H "Authorization: Bearer null" -H "x-api-key: test" — observe Content-Type and body; passive RAG: clone signageos/sdk repo grep for baseURL, headers, auth patterns
impact: Unauthorized access to device management, content distribution, user data; severity CRITICAL
testability: PASSIVE
[HYP] postMessage origin validation bypass between box.signageos.io and remote-desktop/upload.signageos.io
class: OTHER
asset: box.signageos.io (CSP frame-src: remote-desktop.signageos.io, upload.signageos.io)
confidence: 45
reasoning: CSP allows frame-src for remote-desktop.signageos.io and upload.signageos.io; both serve identical Express HTML (same etag W/"90ac-...", 37036 bytes); if either embeds box in iframe or listens for postMessage, loose origin checks could leak tokens or trigger actions
evidence_needed: postMessage event listener on remote-desktop/upload that accepts messages from box.signageos.io without strict origin validation; or box embedding them without sandbox
verify_steps: PASSIVE: GET https://remote-desktop.signageos.io/ and https://upload.signageos.io/ — inspect HTML for postMessage listeners, iframe embeds, messageEvent.origin checks; AUTH_HELPED: login, open devtools, inspect iframe/postMessage on each CSP-listed origin
impact: Cross-origin data leakage, action forgery on device management/upload; severity MEDIUM-HIGH
testability: PASSIVE (initial), AUTH_HELPED (full)
[HYP] Auth0 OAuth2 state parameter not bound to session on box.signageos.io/login
class: AUTH
asset: box.signageos.io/login/%2F
confidence: 40
reasoning: Login initiates Auth0 OAuth2 flow to sos-production.us.auth0.com and auth0.signageos.io; CSP frame-src allows both; if state parameter not cryptographically bound to user session, login CSRF possible (distinct from excluded logout/anonymous-form CSRF)
evidence_needed: Auth0 authorization request accepts arbitrary state value and returns it unchanged without session binding; callback processes code without state verification
verify_steps: GET https://box.signageos.io/login/%2F — extract Auth0 authorize URL, observe state parameter generation; initiate flow with attacker-controlled state, observe if callback validates it against session
impact: Account takeover via login CSRF; severity HIGH
testability: PASSIVE (initial), AUTH_HELPED (full flow)
[PARKED] Auth0 OAuth2 state parameter not bound to session on box.signageos.io/login: class AUTH — login form is anonymous-accessible; program excludes "CSRF on forms that are available to anonymous users"; verify_steps require Auth0 tenant interaction for full validation; prior REJECTED AUTH @ box.signageos.io/login confirms this vector not viable passively
[FINAL] Ranked surviving hypotheses:
[NEXT] PROBE: GET https://api.signageos.io/ -H "Accept: application/json" -H "Authorization: Bearer null" -H "x-api-key: test" — observe Content-Type and body for JSON API surface
[LEARN] REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state parameter — class AUTH excluded as "CSRF on forms that are available to anonymous users" per scope.yml
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CSP: overly broad connect-src/frame-src (20+ origins) confirmed — expands postMessage/origin trust boundary (carried forward from 2026-08-07)
[LEARN] REJECTED IDOR @ api.signageos.io via undiscovered versioned endpoints: no public endpoints discoverable via passive probing (all common paths 404) — carried forward from 2026-08-07
[RISK] box.signageos.io: 75 — Auth0 OAuth2 flow, broad CSP trust boundary (20+ origins including device mgmt APIs, S3, websockets), Sentry/reCAPTCHA nonces, CloudFront; high business value (player/dashboard admin); postMessage/origin boundary expanded by remote-desktop/upload/platform/license subdomains
[RISK] api.signageos.io: 60 — No public API surface, hidden behind CloudFront, auth model unknown, but high business value (core backend); risk driven by unknown attack surface via SDK/cli code mappings
## 2026-08-07 19:21:18 UTC [api] (model nemotron3)
[NEW] api.signageos.io: Returns static HTML (37KB, text/html, etag W/"90ac-...") even with `Accept: application/json`, `Authorization: Bearer null`, `x-api-key: test` — no JSON API surface exposed
[NEW] remote-desktop.signageos.io & upload.signageos.io: Serve IDENTICAL Express HTML (same etag W/"90ac-...", same 37036 bytes, black background with base64 PNG) — confirms shared infrastructure
[NEW] platform.signageos.io: Returns HTTP 503 (service unavailable)
[CHANGED] license.signageos.io: No response / connection timeout
[PRIO] api.signageos.io (root + hidden endpoints), score=7.70, axes: attack=7, business=9, tech=6 (CloudFront, no public spec), gate=10 (public root), cloud=7 (AWS, internal microservices), fresh=6
[PRIO] signageos/sdk & cli repos (GitHub), score=7.70, axes: attack=7, business=8, tech=7 (TS, auth headers, baseURL), gate=10 (public), cloud=6 (code refs), fresh=8 (active)
[PRIO] box.signageos.io CSP origins (remote-desktop, upload, platform, license), score=7.45, axes: attack=8, business=8, tech=7 (postMessage, WS, Express), gate=6 (needs login), cloud=8 (subdomains, AWS, S3), fresh=7
[HYP] api.signageos.io responds with API JSON when proper Accept header sent
class: IDOR
asset: api.signageos.io/
confidence: 50
reasoning: Root serves static HTML (37KB) with 404 on all common paths; SDK/cli repos likely reference actual API via headers (Accept: application/json, Authorization, x-api-key); CloudFront vary: Origin suggests content negotiation
evidence_needed: Response with JSON content-type and API structure when requesting with Accept: application/json or SDK-observed headers
verify_steps: PASSIVE: GET https://api.signageos.io/ -H "Accept: application/json" -H "Authorization: Bearer null" -H "x-api-key: test" — observe Content-Type and body; PASSIVE RAG: clone signageos/sdk repo grep for baseURL, headers, auth patterns
impact: Unauthorized access to device management, content distribution, user data; severity CRITICAL
testability: PASSIVE
[HYP] signageos/sdk & cli repos map api.signageos.io endpoints and auth scheme
class: IDOR
asset: github.com/signageos/sdk, github.com/signageos/cli
confidence: 55
reasoning: 59 public repos in signageos org; sdk (TS) and cli (TS) are first-party; must contain baseURL, auth header construction, endpoint paths for api.signageos.io
evidence_needed: Source code showing API baseURL, authorization header patterns, endpoint paths, request/response types
verify_steps: PASSIVE RAG: git clone https://github.com/signageos/sdk && grep -r "baseURL\|api.signageos.io\|Authorization\|x-api-key" --include="*.ts"; same for cli repo
impact: Full API surface mapping enabling authz/logic flaw hunting; severity HIGH
testability: PASSIVE
[HYP] postMessage origin validation bypass between box.signageos.io and remote-desktop/upload.signageos.io
class: OTHER
asset: box.signageos.io (CSP frame-src: remote-desktop.signageos.io, upload.signageos.io)
confidence: 45
reasoning: CSP allows frame-src for both subdomains; both serve identical Express HTML (same etag, 37036 bytes); if either embeds box in iframe or listens for postMessage, loose origin checks could leak tokens or trigger actions
evidence_needed: postMessage event listener on remote-desktop/upload that accepts messages from box.signageos.io without strict origin validation; or box embedding them without sandbox
verify_steps: PASSIVE: GET https://remote-desktop.signageos.io/ and https://upload.signageos.io/ — inspect HTML for postMessage listeners, iframe embeds, messageEvent.origin checks; AUTH_HELPED: login, open devtools, inspect iframe/postMessage on each CSP-listed origin
impact: Cross-origin data leakage, action forgery on device management/upload; severity MEDIUM-HIGH
testability: PASSIVE (initial), AUTH_HELPED (full)
[PARKED] (none dropped — all confidence ≥40, no rejected classes, all have concrete verify_steps)
[FINAL] Ranked surviving hypotheses:
[NEXT] RAG: Clone and grep signageos/sdk (TypeScript) and signageos/cli repos for API baseURL patterns, auth header construction, and endpoint paths — this maps the hidden api.signageos.io surface
[LEARN] REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state parameter — class AUTH excluded as "CSRF on forms that are available to anonymous users" per scope.yml
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CSP: overly broad connect-src/frame-src (20+ origins) confirmed — expands postMessage/origin trust boundary (carried forward from 2026-08-07)
[LEARN] REJECTED IDOR @ api.signageos.io via undiscovered versioned endpoints: no public endpoints discoverable via passive probing (all common paths 404) — carried forward from 2026-08-07
[RISK] box.signageos.io: 75 — Auth0 OAuth2 flow, broad CSP trust boundary (20+ origins including device mgmt APIs, S3, websockets), Sentry/reCAPTCHA nonces, CloudFront; high business value (player/dashboard admin); postMessage/origin boundary expanded by remote-desktop/upload/platform/license subdomains
[RISK] api.signageos.io: 60 — No public API surface, hidden behind CloudFront, auth model unknown, but high business value (core backend); risk driven by unknown attack surface via SDK/cli code mappings
## 2026-08-07 20:05:45 UTC [api] (model nemotron3)
## 2026-08-07 20:54:09 UTC [api] (model nemotron3)
## 2026-08-07 21:31:21 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token: 7.80 (attack=9, business=10, tech=8, gate=3, cloud=8, fresh=8) — Cross-tenant org-token minting via account token; JWT-gated but high-value logic flaw if org UID not re-checked
[PRIO] api.signageos.io/v1/device/{uid}/peer-recovery: 7.55 (attack=8, business=9, tech=8, gate=3, cloud=8, fresh=8) — Legacy client-secret auth (X-Auth) not bound to target device UID; SDK takes arbitrary deviceUid path arg
[PRIO] api.signageos.io/v2/*: 6.65 (attack=7, business=8, tech=7, gate=10, cloud=7, fresh=7) — Partial v2 migration; /v2/device JWT-gated but /v2/account, /v2/organization 404; authz drift candidate, PASSIVE testable
[PRIO] box.signageos.io/status: 6.25 (attack=5, business=6, tech=5, gate=10, cloud=7, fresh=6) — Already accepted MISCONFIG; infra recon value for SSRF/logic-flaw chaining
[PRIO] remote-desktop.signageos.io / upload.signageos.io: 5.90 (attack=6, business=7, tech=6, gate=10, cloud=6, fresh=6) — Identical Express HTML (shared infra); CSP frame-src from box; postMessage boundary unprobed
[HYP] Cross-tenant org security-token minting via account token + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token (GET/POST)
confidence: 60
reasoning: Docs state one account token can create multiple orgs and mint org tokens; SDK builds `organization/<uid>/security-token` (path = resource key) while JWT auth-context is a separate client-supplied `?organizationUid=` query param; if path-UID membership vs query-UID is not re-checked server-side, any account token mints tokens for any org
evidence_needed: non-403 on POST/GET `/v1/organization/<foreign-uid>/security-token` with own account JWT
verify_steps: AUTH_HELPED: `GET /v1/organization/<own>/security-token` baseline 200; then `GET /v1/organization/<foreign-uid>/security-token` → 200 = cross-tenant mint; minted org token should then drive foreign devices (brightness/firmware/content/timing)
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant peer-recovery read/write via legacy client-secret not bound to target device UID
class: IDOR
asset: api.signageos.io/v1/device/{uid}/peer-recovery (GET list / PUT set)
confidence: 55
reasoning: Gate is org client-secret (`403083 MISSING_CLIENT_SECRET`), not JWT; SDK takes deviceUid as arbitrary path arg; org-context is client-controlled (`X-Auth: clientId:secret` or `?organizationUid=` for JWT), so server-side org→device binding is the only barrier
evidence_needed: with own org `X-Auth: clientId:secret`, GET/PUT peer-recovery against a device UID belonging to another org returns 200 (not 403)
verify_steps: AUTH_HELPED: `GET /v1/device/<own-uid>/peer-recovery -H "X-Auth: <ownClientId>:<ownSecret>"` baseline 200; repeat with foreign device UID → 200 = cross-tenant; then `PUT` with `{"enabled":true,"urlLauncherAddress":"https://attacker"}` to confirm write
impact: read + overwrite peer-recovery config on any tenant's devices; PUT can point device launcher at attacker URL → device/content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[HYP] v2 API partial-migration authz drift (route exists in v2, alternate/weaker auth)
class: AUTH
asset: api.signageos.io/v2/*
confidence: 45
reasoning: /v2/device is JWT-gated (403 WRONG_JWT) but /v2/account and /v2/organization are 404 — v2 is a selective port; freshly-migrated code paths commonly diverge on authorization checks; IOptions is version-agnostic (legacy clientId:secret works across v1/v2)
evidence_needed: any /v2 route returning 200 unauthenticated, or ≠403/404, or accepting legacy auth where v1 requires JWT
verify_steps: PASSIVE: probe /v2/device/{uid}, /v2/license, /v2/alert, /v2/location, /v2/content, /v2/bulk-operation, /v2/emulator without auth — anything ≠403/404 is a finding; AUTH_HELPED: compare own-creds response on same resource across /v1 vs /v2
impact: authz drift → data disclosure / cross-tenant access via an alternate code path; HIGH
testability: PASSIVE
[PARKED] (none dropped — all confidence ≥40, no rejected classes, all have concrete verify_steps)
[FINAL] (re-ranked, top first):
[NEXT] RAG: Clone `github.com/signageos/sdk` and grep `src/api/` + `src/auth/` + `src/requester.ts` for: (1) exact `X-Auth` header construction (`id:unsafeDecryptedToken` format) for v1/v2; (2) account-token mint call shape (`identification`/`password` param placement — query vs body); (3) whether `createApiV2` reuses v1 auth/orgUid semantics; (4) any `/v2/` endpoint invoked without JWT at initialization (pre-auth bypass candidate) — converts hypotheses 1/2/3 into exact AUTH_HELD/PASSIVE test recipes
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname (rotating: gkzcp → mtnct), process UID, Node v20.20.2, and service topology (amqp0, redis0-3, mongoDB0-3). Not on rejected list.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CORS: Confirmed live. 18 static ACAO values on / (302) + /login/ (200), unchanged under spoofed Origin `https://evil.test`. Includes `http://` variant + `https://*.zdusercontent.com` wildcard + sibling `api.signageos.io`. No `Access-Control-Allow-Credentials` on any box path. api.signageos.io has NO ACAO on any path (including /status, /v1/*, /v2/*).
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CSP: Confirmed live. /login/ CSP broadened vs / (triplicated Auth0 oauth/token, additional recaptcha frame-src). 40+ connect-src/frame-src origins spanning Auth0, Sony/BroadSign/MoodMedia device APIs, S3 buckets, AWS API Gateway, and api.signageos.io.
[LEARN] REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 `OK` (2 bytes) — trivial health check, no data leaked. Not reportable.
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All 60+ endpoints return 403 JWT-gated (WRONG_JWT_TOKEN/403105). No pre-auth bypass. Dual auth confirmed: JWT Bearer (main API) + X-Auth API-key format (`id:unsafeDecryptedToken`) for bulk provisioning.
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: 403/404 carry `vary: Origin` + `access-control-expose-headers: *` but NO ACAO under any Origin — not CORS-exploitable.
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation — not testable passively without tenant config access (carried forward).
[LEARN] REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state — excluded per "CSRF on anonymous-accessible forms" (carried forward).
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 403105` — falls under descriptive error messages (excluded).
[RISK] box.signageos.io: 58 — Unauthenticated `/status` info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl HTTP variant + zdusercontent wildcard); broad CSP (40+ origins). Everything except `/status`, `/login/`, `/ready`, `/assets/*` redirects to Auth0 login. Moderate operational exposure, no direct data access without credentials.
[RISK] api.signageos.io: 47 — Unauthenticated `/status` info leak (pod hostname + service topology); 60+ `/v1/*`+`/`v2/*` endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on `/`. Lower data-exposure risk — main concern is infra recon aid for the JWT-gated high-value API (devices, organizations, accounts, content).
## 2026-08-07 22:06:04 UTC [api] (model nemotron3)
[NEW] Hardcoded clientId/secret in `videowall-designer/sos/videoTiming.js` (line 18-19) authenticating against internal staging API `http://api.kiera.office.signageos.io` over HTTP — REAL_SECRET + ENDPOINT_LEAK confirmed via reposcan (secret SHA256: `564c293ba2a1d60dd6e8f508a7ef65400424ae42b80be0ae04498d528a8a774e`)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token: 7.80 (attack=9, business=10, tech=8, gate=3, cloud=8, fresh=8) — Cross-tenant org-token minting via account token; JWT-gated but high-value logic flaw if org UID not re-checked
[PRIO] api.signageos.io/v1/device/{uid}/peer-recovery: 7.55 (attack=8, business=9, tech=8, gate=3, cloud=8, fresh=8) — Legacy client-secret auth (X-Auth) not bound to target device UID; SDK takes arbitrary deviceUid path arg
[PRIO] api.signageos.io/v2/*: 6.65 (attack=7, business=8, tech=7, gate=10, cloud=7, fresh=7) — Partial v2 migration; /v2/device JWT-gated but /v2/account, /v2/organization 404; authz drift candidate, PASSIVE testable
[PRIO] api.kiera.office.signageos.io (internal staging): 6.20 (attack=7, business=6, tech=6, gate=10, cloud=8, fresh=6) — Hardcoded credentials in public repo (videowall-designer) hit this HTTP endpoint; credential reuse/replay risk against prod org boundaries
[PRIO] box.signageos.io/status: 6.25 (attack=5, business=6, tech=5, gate=10, cloud=7, fresh=6) — Already accepted MISCONFIG; infra recon value for SSRF/logic-flaw chaining
[HYP] Cross-tenant org security-token minting via account token + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token (GET/POST)
confidence: 65
reasoning: SDK builds `organization/<uid>/security-token` with path UID while JWT auth-context uses separate `?organizationUid=` query param; account tokens can create multiple orgs per docs; if server doesn't re-validate path-UID ∈ authenticated account's company, any account token mints tokens for any org
evidence_needed: non-403 on POST/GET `/v1/organization/<foreign-uid>/security-token` with own account JWT
verify_steps: AUTH_HELPED: `GET /v1/organization/<own>/security-token` baseline 200; then `GET /v1/organization/<foreign-uid>/security-token` → 200 = cross-tenant mint; minted org token should then drive foreign devices (brightness/firmware/content/timing)
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant peer-recovery read/write via legacy client-secret not bound to target device UID
class: IDOR
asset: api.signageos.io/v1/device/{uid}/peer-recovery (GET list / PUT set)
confidence: 55
reasoning: Gate is org client-secret (`403083 MISSING_CLIENT_SECRET`), not JWT; SDK takes deviceUid as arbitrary path arg; org-context is client-controlled (`X-Auth: clientId:secret` or `?organizationUid=` for JWT), so server-side org→device binding is the only barrier
evidence_needed: with own org `X-Auth: clientId:secret`, GET/PUT peer-recovery against a device UID belonging to another org returns 200 (not 403)
verify_steps: AUTH_HELPED: `GET /v1/device/<own-uid>/peer-recovery -H "X-Auth: <ownClientId>:<ownSecret>"` baseline 200; repeat with foreign device UID → 200 = cross-tenant; then `PUT` with `{"enabled":true,"urlLauncherAddress":"https://attacker"}` to confirm write
impact: read + overwrite peer-recovery config on any tenant's devices; PUT can point device launcher at attacker URL → device/content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[HYP] v2 API partial-migration authz drift (route exists in v2, alternate/weaker auth)
class: AUTH
asset: api.signageos.io/v2/*
confidence: 45
reasoning: /v2/device is JWT-gated (403 WRONG_JWT) but /v2/account and /v2/organization are 404 — v2 is a selective port; freshly-migrated code paths commonly diverge on authorization checks; IOptions is version-agnostic (legacy clientId:secret works across v1/v2)
evidence_needed: any /v2 route returning 200 unauthenticated, or ≠403/404, or accepting legacy auth where v1 requires JWT
verify_steps: PASSIVE: probe /v2/device/{uid}, /v2/license, /v2/alert, /v2/location, /v2/content, /v2/bulk-operation, /v2/emulator without auth — anything ≠403/404 is a finding; AUTH_HELPED: compare own-creds response on same resource across /v1 vs /v2
impact: authz drift → data disclosure / cross-tenant access via an alternate code path; HIGH
testability: PASSIVE
[PARKED] (none dropped — all confidence ≥40, no rejected classes, all have concrete verify_steps)
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] RAG: Clone `github.com/signageos/sdk` and grep `src/api/` + `src/auth/` + `src/requester.ts` for: (1) exact `X-Auth` header construction (`id:unsafeDecryptedToken` format) for v1/v2; (2) account-token mint call shape (`identification`/`password` param placement — query vs body); (3) whether `createApiV2` reuses v1 auth/orgUid semantics; (4) any `/v2/` endpoint invoked without JWT at initialization (pre-auth bypass candidate) — converts hypotheses 1/2/3 into exact AUTH_HELPED/PASSIVE test recipes
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname (rotating: gkzcp → mtnct), process UID, Node v20.20.2, and service topology (amqp0, redis0-3, mongoDB0-3). Not on rejected list.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CORS: Confirmed live. 18 static ACAO values on / (302) + /login/ (200), unchanged under spoofed Origin `https://evil.test`. Includes `http://` variant + `https://*.zdusercontent.com` wildcard + sibling `api.signageos.io`. No `Access-Control-Allow-Credentials` on any box path. api.signageos.io has NO ACAO on any path (including /status, /v1/*, /v2/*).
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CSP: Confirmed live. /login/ CSP broadened vs / (triplicated Auth0 oauth/token, additional recaptcha frame-src). 40+ connect-src/frame-src origins spanning Auth0, Sony/BroadSign/MoodMedia device APIs, S3 buckets, AWS API Gateway, and api.signageos.io.
[LEARN] REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 `OK` (2 bytes) — trivial health check, no data leaked. Not reportable.
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All 60+ endpoints return 403 JWT-gated (WRONG_JWT_TOKEN/403105). No pre-auth bypass. Dual auth confirmed: JWT Bearer (main API) + X-Auth API-key format (`id:unsafeDecryptedToken`) for bulk provisioning.
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: 403/404 carry `vary: Origin` + `access-control-expose-headers: *` but NO ACAO under any Origin — not CORS-exploitable.
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation — not testable passively without tenant config access (carried forward).
[LEARN] REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state — excluded per "CSRF on anonymous-accessible forms" (carried forward).
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 403105` — falls under descriptive error messages (excluded).
[LEARN] ACCEPTED SECRET_LEAK @ github.com/signageos/videowall-designer: Hardcoded clientId/secret (SHA256 `564c293ba2a1d60dd6e8f508a7ef65400424ae42b80be0ae04498d528a8a774e`) in `sos/videoTiming.js` targeting internal staging `http://api.kiera.office.signageos.io` over HTTP — credential reuse risk; not directly reportable (out-of-scope host) but informs prod org-boundary testing.
[RISK] box.signageos.io: 58 — Unauthenticated `/status` info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl HTTP variant + zdusercontent wildcard); broad CSP (40+ origins). Everything except `/status`, `/login/`, `/ready`, `/assets/*` redirects to Auth0 login. Moderate operational exposure, no direct data access without credentials.
[RISK] api.signageos.io: 62 — Unauthenticated `/status` info leak (pod hostname + service topology); 60+ `/v1/*`+`/v2/*` endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on `/`. **Risk raised** due to confirmed cross-tenant IDOR candidates (org-token minting, peer-recovery, v2 drift) that are AUTH_HELPED-testable with high business impact (device/firmware/content control). Main concern: JWT-gated high-value API with logic flaws in org-boundary enforcement.
## 2026-08-07 22:51:36 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token: 7.80 (attack=9, business=10, tech=8, gate=3, cloud=8, fresh=8) — Cross-tenant org-token minting via account token; JWT-gated but high-value logic flaw if org UID not re-checked
[PRIO] api.signageos.io/v1/device/{uid}/peer-recovery: 7.55 (attack=8, business=9, tech=8, gate=3, cloud=8, fresh=8) — Legacy client-secret auth (X-Auth) not bound to target device UID; SDK takes arbitrary deviceUid path arg
[PRIO] api.signageos.io/v2/*: 6.65 (attack=7, business=8, tech=7, gate=10, cloud=7, fresh=7) — Partial v2 migration; /v2/device JWT-gated but /v2/account, /v2/organization 404; authz drift candidate, PASSIVE testable
[HYP] Cross-tenant org security-token minting via account token + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 65
reasoning: SDK builds `organization/<uid>/security-token` with path UID while JWT auth-context uses separate `?organizationUid=` query param; account tokens can create multiple orgs per docs; if server doesn't re-validate path-UID ∈ authenticated account's company, any account token mints tokens for any org
evidence_needed: non-403 on POST/GET `/v1/organization/<foreign-uid>/security-token` with own account JWT
verify_steps: AUTH_HELPED: `GET /v1/organization/<own>/security-token` baseline 200; then `GET /v1/organization/<foreign-uid>/security-token` → 200 = cross-tenant mint; minted org token should then drive foreign devices (brightness/firmware/content/timing)
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant peer-recovery read/write via legacy client-secret not bound to target device UID
class: IDOR
asset: api.signageos.io/v1/device/{uid}/peer-recovery
confidence: 55
reasoning: Gate is org client-secret (`403083 MISSING_CLIENT_SECRET`), not JWT; SDK takes deviceUid as arbitrary path arg; org-context is client-controlled (`X-Auth: clientId:secret` or `?organizationUid=` for JWT), so server-side org→device binding is the only barrier
evidence_needed: with own org `X-Auth: clientId:secret`, GET/PUT peer-recovery against a device UID belonging to another org returns 200 (not 403)
verify_steps: AUTH_HELPED: `GET /v1/device/<own-uid>/peer-recovery -H "X-Auth: <ownClientId>:<ownSecret>"` baseline 200; repeat with foreign device UID → 200 = cross-tenant; then `PUT` with `{"enabled":true,"urlLauncherAddress":"https://attacker"}` to confirm write
impact: read + overwrite peer-recovery config on any tenant's devices; PUT can point device launcher at attacker URL → device/content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[HYP] v2 API partial-migration authz drift (route exists in v2, alternate/weaker auth)
class: AUTH
asset: api.signageos.io/v2/*
confidence: 45
reasoning: /v2/device is JWT-gated (403 WRONG_JWT) but /v2/account and /v2/organization are 404 — v2 is a selective port; freshly-migrated code paths commonly diverge on authorization checks; IOptions is version-agnostic (legacy clientId:secret works across v1/v2)
evidence_needed: any /v2 route returning 200 unauthenticated, or ≠403/404, or accepting legacy auth where v1 requires JWT
verify_steps: PASSIVE: probe /v2/device/{uid}, /v2/license, /v2/alert, /v2/location, /v2/content, /v2/bulk-operation, /v2/emulator without auth — anything ≠403/404 is a finding; AUTH_HELPED: compare own-creds response on same resource across /v1 vs /v2
impact: authz drift → data disclosure / cross-tenant access via an alternate code path; HIGH
testability: PASSIVE
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] RAG: Clone `github.com/signageos/sdk` and grep `src/api/` + `src/auth/` + `src/requester.ts` for: (1) exact `X-Auth` header construction (`id:unsafeDecryptedToken` format) for v1/v2; (2) account-token mint call shape (`identification`/`password` param placement — query vs body); (3) whether `createApiV2` reuses v1 auth/orgUid semantics; (4) any `/v2/` endpoint invoked without JWT at initialization (pre-auth bypass candidate) — converts hypotheses 1/2/3 into exact AUTH_HELPED/PASSIVE test recipes
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname (rotating: gkzcp → mtnct), process UID, Node v20.20.2, and service topology (amqp0, redis0-3, mongoDB0-3). Not on rejected list.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CORS: Confirmed live. 18 static ACAO values on / (302) + /login/ (200), unchanged under spoofed Origin `https://evil.test`. Includes `http://` variant + `https://*.zdusercontent.com` wildcard + sibling `api.signageos.io`. No `Access-Control-Allow-Credentials` on any box path. api.signageos.io has NO ACAO on any path.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CSP: Confirmed live. /login/ CSP broadened vs / (triplicated Auth0 oauth/token, additional recaptcha frame-src). 40+ connect-src/frame-src origins spanning Auth0, Sony/BroadSign/MoodMedia device APIs, S3 buckets, AWS API Gateway, and api.signageos.io.
[LEARN] REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 `OK` (2 bytes) — trivial health check, no data leaked. Not reportable.
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All 60+ endpoints return 403 JWT-gated (WRONG_JWT_TOKEN/403105). No pre-auth bypass. Dual auth confirmed: JWT Bearer (main API) + X-Auth API-key format (`id:unsafeDecryptedToken`) for bulk provisioning.
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: 403/404 carry `vary: Origin` + `access-control-expose-headers: *` but NO ACAO under any Origin — not CORS-exploitable.
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation — not testable passively without tenant config access (carried forward).
[LEARN] REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state — excluded per "CSRF on anonymous-accessible forms" (carried forward).
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 403105` — falls under descriptive error messages (excluded).
[LEARN] ACCEPTED SECRET_LEAK @ github.com/signageos/videowall-designer: Hardcoded clientId/secret (SHA256 `564c293ba2a1d60dd6e8f508a7ef65400424ae42b80be0ae04498d528a8a774e`) in `sos/videoTiming.js` targeting internal staging `http://api.kiera.office.signageos.io` over HTTP — credential reuse risk; not directly reportable (out-of-scope host) but informs prod org-boundary testing.
[RISK] box.signageos.io: 58 — Unauthenticated `/status` info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl HTTP variant + zdusercontent wildcard); broad CSP (40+ origins). Everything except `/status`, `/login/`, `/ready`, `/assets/*` redirects to Auth0 login. Moderate operational exposure, no direct data access without credentials.
[RISK] api.signageos.io: 62 — Unauthenticated `/status` info leak (pod hostname + service topology); 60+ `/v1/*`+`/v2/*` endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on `/`. **Risk raised** due to confirmed cross-tenant IDOR candidates (org-token minting, peer-recovery, v2 drift) that are AUTH_HELPED-testable with high business impact (device/firmware/content control). Main concern: JWT-gated high-value API with logic flaws in org-boundary enforcement.
## 2026-08-07 23:22:05 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token: 7.80 (attack=9, business=10, tech=8, gate=3, cloud=8, fresh=8) — Cross-tenant org-token minting via account token; JWT-gated but high-value logic flaw if org UID not re-checked  
[PRIO] api.signageos.io/v1/device/{uid}/peer-recovery: 7.55 (attack=8, business=9, tech=8, gate=3, cloud=8, fresh=8) — Legacy client-secret auth (X-Auth) not bound to target device UID; SDK takes arbitrary deviceUid path arg  
[PRIO] api.signageos.io/v2/*: 6.65 (attack=7, business=8, tech=7, gate=10, cloud=7, fresh=7) — Partial v2 migration; /v2/device JWT-gated but /v2/account, /v2/organization 404; authz drift candidate, PASSIVE testable  
[PRIO] box.signageos.io/status: 5.20 (attack=6, business=4, tech=5, gate=10, cloud=6, fresh=6) — Unauthenticated info leak (pod hostname, UID, Node v20.20.2, Redis/Mongo/AMQP topology)  
[PRIO] box.signageos.io CORS: 4.85 (attack=5, business=3, tech=6, gate=10, cloud=5, fresh=6) — 18 static ACAO incl HTTP variant + wildcard zdusercontent; no ACAO-Credentials  
[HYP] Cross-tenant org security-token minting via account token + client-supplied organizationUid  
class: IDOR  
asset: api.signageos.io/v1/organization/{uid}/security-token  
confidence: 65  
reasoning: SDK builds `organization/<uid>/security-token` with path UID while JWT auth-context uses separate `?organizationUid=` query param; account tokens can create multiple orgs per docs; if server doesn't re-validate path-UID ∈ authenticated account's company, any account token mints tokens for any org  
evidence_needed: non-403 on GET/POST `/v1/organization/<foreign-uid>/security-token` with own account JWT  
verify_steps: AUTH_HELPED: `GET /v1/organization/<own>/security-token` baseline 200; then `GET /v1/organization/<foreign-uid>/security-token` → 200 = cross-tenant mint; minted org token should then drive foreign devices (brightness/firmware/content/timing)  
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL  
testability: AUTH_HELPED  
[HYP] Cross-tenant peer-recovery read/write via legacy client-secret not bound to target device UID  
class: IDOR  
asset: api.signageos.io/v1/device/{uid}/peer-recovery  
confidence: 55  
reasoning: Gate is org client-secret (`403083 MISSING_CLIENT_SECRET`), not JWT; SDK takes deviceUid as arbitrary path arg; org-context is client-controlled (`X-Auth: clientId:secret` or `?organizationUid=` for JWT), so server-side org→device binding is the only barrier  
evidence_needed: with own org `X-Auth: clientId:secret`, GET/PUT peer-recovery against a device UID belonging to another org returns 200 (not 403)  
verify_steps: AUTH_HELPED: `GET /v1/device/<own-uid>/peer-recovery -H "X-Auth: <ownClientId>:<ownSecret>"` baseline 200; repeat with foreign device UID → 200 = cross-tenant; then `PUT` with `{"enabled":true,"urlLauncherAddress":"https://attacker"}` to confirm write  
impact: read + overwrite peer-recovery config on any tenant's devices; PUT can point device launcher at attacker URL → device/content takeover; HIGH→CRITICAL  
testability: AUTH_HELPED  
[HYP] v2 API partial-migration authz drift (route exists in v2, alternate/weaker auth)  
class: AUTH  
asset: api.signageos.io/v2/*  
confidence: 45  
reasoning: /v2/device is JWT-gated (403 WRONG_JWT) but /v2/account and /v2/organization are 404 — v2 is a selective port; freshly-migrated code paths commonly diverge on authorization checks; IOptions is version-agnostic (legacy clientId:secret works across v1/v2)  
evidence_needed: any /v2 route returning 200 unauthenticated, or ≠403/404, or accepting legacy auth where v1 requires JWT  
verify_steps: PASSIVE: probe /v2/device/{uid}, /v2/license, /v2/alert, /v2/location, /v2/content, /v2/bulk-operation, /v2/emulator without auth — anything ≠403/404 is a finding; AUTH_HELPED: compare own-creds response on same resource across /v1 vs /v2  
impact: authz drift → data disclosure / cross-tenant access via an alternate code path; HIGH  
testability: PASSIVE  
[PARKED] (none dropped — all confidence ≥40, no rejected classes, all have concrete verify_steps)  
[FINAL] Ranked surviving hypotheses (top first):  
[NEXT] RAG: Clone `github.com/signageos/sdk` and grep `src/api/` + `src/auth/` + `src/requester.ts` for: (1) exact `X-Auth` header construction (`id:unsafeDecryptedToken` format) for v1/v2; (2) account-token mint call shape (`identification`/`password` param placement — query vs body); (3) whether `createApiV2` reuses v1 auth/orgUid semantics; (4) any `/v2/` endpoint invoked without JWT at initialization (pre-auth bypass candidate) — converts hypotheses 1/2/3 into exact AUTH_HELPED/PASSIVE test recipes  
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname (rotating: gkzcp → st6zq), process UID, Node v24.19.0, and service topology (amqp0, redis0-3, mongoDB0-2). Not on rejected list.  
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname (rotating: gkzcp → bk4vh), process UID, Node v20.20.2, and service topology (amqp0, redis0-3, mongoDB0-3). Not on rejected list.  
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CORS: Confirmed live. 18 static ACAO values on / (302) + /login/ (200), unchanged under spoofed Origin `https://evil.test`. Includes `http://` variant + `https://*.zdusercontent.com` wildcard + sibling `api.signageos.io`. No `Access-Control-Allow-Credentials` on any box path. api.signageos.io has NO ACAO on any path.  
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CSP: Confirmed live. /login/ CSP broadened vs / (triplicated Auth0 oauth/token, additional recaptcha frame-src). 40+ connect-src/frame-src origins spanning Auth0, Sony/BroadSign/MoodMedia device APIs, S3 buckets, AWS API Gateway, and api.signageos.io.  
[LEARN] REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 `OK` (2 bytes) — trivial health check, no data leaked. Not reportable.  
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All 60+ endpoints return 403 JWT-gated (WRONG_JWT_TOKEN/403105). No pre-auth bypass. Dual auth confirmed: JWT Bearer (main API) + X-Auth API-key format (`id:unsafeDecryptedToken`) for bulk provisioning.  
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: 403/404 carry `vary: Origin` + `access-control-expose-headers: *` but NO ACAO under any Origin — not CORS-exploitable.  
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation — not testable passively without tenant config access (carried forward).  
[LEARN] REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state — excluded per "CSRF on anonymous-accessible forms" (carried forward).  
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 403105` — falls under descriptive error messages (excluded).  
[LEARN] ACCEPTED SECRET_LEAK @ github.com/signageos/videowall-designer: Hardcoded clientId/secret (SHA256 `564c293ba2a1d60dd6e8f508a7ef65400424ae42b80be0ae04498d528a8a774e`) in `sos/videoTiming.js` targeting internal staging `http://api.kiera.office.signageos.io` over HTTP — credential reuse risk; not directly reportable (out-of-scope host) but informs prod org-boundary testing.  
[RISK] box.signageos.io: 58 — Unauthenticated `/status` info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl HTTP variant + zdusercontent wildcard); broad CSP (40+ origins). Everything except `/status`, `/login/`, `/ready`, `/assets/*` redirects to Auth0 login. Moderate operational exposure, no direct data access without credentials.  
[RISK] api.signageos.io: 62 — Unauthenticated `/status` info leak (pod hostname + service topology); 60+ `/v1/*`+`/v2/*` endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on `/`. **Risk raised** due to confirmed cross-tenant IDOR candidates (org-token minting, peer-recovery, v2 drift) that are AUTH_HELPED-testable with high business impact (device/firmware/content control). Main concern: JWT-gated high-value API with logic flaws in org-boundary enforcement.
## 2026-08-07 23:54:27 UTC [api] (model nemotron3)
[NEW] api.signageos.io Node version upgraded to v24.19.0 (was v24.19.0 on some pods, v20.20.2 on others — mixed fleet confirmed)
[NEW] box.signageos.io pod hostname rotated to `box-7c8c876945-52dpt` (Node v20.20.2); api.signageos.io pod hostname rotated to `api-6f69db97d5-97fjw` (Node v24.19.0) — K8s rolling deploy confirmed
[CHANGED] api.signageos.io/v2/device now returns 403 JWT-gated (previously 404) — v2 migration advancing
[PRIO] api.signageos.io/v1/organization/{uid}/security-token: 8.00 (attack=9, business=10, tech=8, gate=3, cloud=8, fresh=8)
[PRIO] api.signageos.io/v2/*: 7.70 (attack=7, business=8, tech=7, gate=10, cloud=7, fresh=7)
[PRIO] api.signageos.io/v1/device/{uid}/peer-recovery: 7.50 (attack=8, business=9, tech=8, gate=3, cloud=8, fresh=8)
[HYP] Cross-tenant org security-token minting via account token + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 65
reasoning: SDK builds `organization/<uid>/security-token` with path UID while JWT auth-context uses separate `?organizationUid=` query param; account tokens can create multiple orgs per docs; if server doesn't re-validate path-UID ∈ authenticated account's company, any account token mints tokens for any org
evidence_needed: non-403 on GET/POST `/v1/organization/<foreign-uid>/security-token` with own account JWT
verify_steps: AUTH_HELPED: `GET /v1/organization/<own>/security-token` baseline 200; then `GET /v1/organization/<foreign-uid>/security-token` → 200 = cross-tenant mint; minted org token should then drive foreign devices (brightness/firmware/content/timing)
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[HYP] v2 API partial-migration authz drift (route exists in v2, alternate/weaker auth)
class: AUTH
asset: api.signageos.io/v2/*
confidence: 45
reasoning: /v2/device is JWT-gated (403 WRONG_JWT) but /v2/account and /v2/organization are 404 — v2 is a selective port; freshly-migrated code paths commonly diverge on authorization checks; IOptions is version-agnostic (legacy clientId:secret works across v1/v2)
evidence_needed: any /v2 route returning 200 unauthenticated, or ≠403/404, or accepting legacy auth where v1 requires JWT
verify_steps: PASSIVE: probe /v2/device/{uid}, /v2/license, /v2/alert, /v2/location, /v2/content, /v2/bulk-operation, /v2/emulator without auth — anything ≠403/404 is a finding; AUTH_HELPED: compare own-creds response on same resource across /v1 vs /v2
impact: authz drift → data disclosure / cross-tenant access via an alternate code path; HIGH
testability: PASSIVE
[HYP] Cross-tenant peer-recovery read/write via legacy client-secret not bound to target device UID
class: IDOR
asset: api.signageos.io/v1/device/{uid}/peer-recovery
confidence: 55
reasoning: Gate is org client-secret (`403083 MISSING_CLIENT_SECRET`), not JWT; SDK takes deviceUid as arbitrary path arg; org-context is client-controlled (`X-Auth: clientId:secret` or `?organizationUid=` for JWT), so server-side org→device binding is the only barrier
evidence_needed: with own org `X-Auth: clientId:secret`, GET/PUT peer-recovery against a device UID belonging to another org returns 200 (not 403)
verify_steps: AUTH_HELPED: `GET /v1/device/<own-uid>/peer-recovery -H "X-Auth: <ownClientId>:<ownSecret>"` baseline 200; repeat with foreign device UID → 200 = cross-tenant; then `PUT` with `{"enabled":true,"urlLauncherAddress":"https://attacker"}` to confirm write
impact: read + overwrite peer-recovery config on any tenant's devices; PUT can point device launcher at attacker URL → device/content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[PARKED] (none dropped — all confidence ≥40, no rejected classes, all have concrete verify_steps)
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] RAG: Clone `github.com/signageos/sdk` and grep `src/api/` + `src/auth/` + `src/requester.ts` for: (1) exact `X-Auth` header construction (`id:unsafeDecryptedToken` format) for v1/v2; (2) account-token mint call shape (`identification`/`password` param placement — query vs body); (3) whether `createApiV2` reuses v1 auth/orgUid semantics; (4) any `/v2/` endpoint invoked without JWT at initialization (pre-auth bypass candidate) — converts hypotheses 1/2/3 into exact AUTH_HELPED/PASSIVE test recipes
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live. HTTP 200 JSON leaks pod hostname (box-7c8c876945-52dpt), process UID, Node v20.20.2, service topology (amqp0, redis0-3, mongoDB0-3). Unchanged.
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live. HTTP 200 JSON leaks pod hostname (api-6f69db97d5-97fjw), process UID, Node v24.19.0, service topology (amqp0, redis0-3, mongoDB0-3). Unchanged.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CORS: Reconfirmed live. 18 static ACAO values on / (302) + /login/ (200), unchanged under spoofed Origin https://evil.test. No Access-Control-Allow-Credentials. Includes http:// variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling. Unchanged.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CSP: Reconfirmed live. /login/ CSP triplicates Auth0 oauth/token entries, 33+ distinct origin patterns across connect-src/frame-src directives. Unchanged.
[LEARN] REJECTED MISCONFIG @ box.signageos.io /ready: Reconfirmed. Returns 200 "OK" (2 bytes), trivial health check, no data leaked. Not reportable.
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All endpoints return 403 JWT-gated without pre-auth bypass. Requires AUTH_HELPED verification.
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: Confirmed — 403/404 responses carry vary: Origin + access-control-expose-headers: * but NO ACAO under any Origin. Not CORS-exploitable.
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 flow parameters hidden in minified bundle.js (v2.192.0); redirect_uri validation, OAuth2 state binding — not testable passively without Auth0 tenant access or authenticated session.
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 403105` — falls under descriptive error messages (excluded).
[RISK] box.signageos.io: 58 — Unauthenticated `/status` info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl HTTP variant + zdusercontent wildcard); broad CSP (40+ origins). Everything except `/status`, `/login/`, `/ready`, `/assets/*` redirects to Auth0 login. Moderate operational exposure, no direct data access without credentials.
[RISK] api.signageos.io: 62 — Unauthenticated `/status` info leak (pod hostname + service topology); 60+ `/v1/*`+`/v2/*` endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on `/`. **Risk raised** due to confirmed cross-tenant IDOR candidates (org-token minting, peer-recovery, v2 drift) that are AUTH_HELPED-testable with high business impact (device/firmware/content control). Main concern: JWT-gated high-value API with logic flaws in org-boundary enforcement.
## 2026-08-08 00:49:13 UTC [api] (model nemotron3)
[NEW] api.signageos.io Node version upgraded to v24.19.0 (mixed fleet: v24.19.0 + v20.20.2 pods confirmed)
[NEW] box.signageos.io pod hostname rotated to `box-7c8c876945-52dpt` (Node v20.20.2); api.signageos.io pod hostname rotated to `api-6f69db97d5-97fjw` (Node v24.19.0) — K8s rolling deploy confirmed
[CHANGED] api.signageos.io/v2/device now returns 403 JWT-gated (previously 404) — v2 migration advancing
[PRIO] api.signageos.io/v1/organization/{uid}/security-token: 7.85 (attack=9, business=10, tech=8, gate=3, cloud=8, fresh=8) — Cross-tenant org-token minting via account JWT + client-supplied org UID; JWT-gated but high-value logic flaw if path-UID membership not re-verified
[PRIO] api.signageos.io/v1/organization/{organizationUid}: 7.70 (attack=9, business=10, tech=8, gate=3, cloud=8, fresh=7) — Cross-tenant org OAuth client-secret disclosure via account JWT; SDK/CLI code-verified GET returns oauthClientSecret for arbitrary path UID
[PRIO] api.signageos.io/v1/device/{uid}/peer-recovery: 7.55 (attack=8, business=9, tech=8, gate=3, cloud=8, fresh=8) — Legacy X-Auth (clientId:secret) gate not bound to target device UID; org→device binding is sole barrier
[PRIO] api.signageos.io/v2/*: 6.95 (attack=7, business=8, tech=7, gate=10, cloud=7, fresh=9) — Partial v2 migration; /v2/device now JWT-gated (was 404), /v2/account + /v2/organization 404; authz drift candidate, PASSIVE testable
[PRIO] box.signageos.io/status: 5.20 (attack=6, business=4, tech=5, gate=10, cloud=6, fresh=6) — Unauthenticated info leak (pod hostname, UID, Node v20.20.2, Redis/Mongo/AMQP topology); reconfirmed stable
[PRIO] box.signageos.io CORS: 4.85 (attack=5, business=3, tech=6, gate=10, cloud=5, fresh=6) — 18 static ACAO incl HTTP variant + *.zdusercontent.com wildcard; no ACAO-Credentials; reconfirmed stable
[PRIO] box.signageos.io CSP: 4.60 (attack=5, business=3, tech=6, gate=10, cloud=4, fresh=5) — /login/ CSP 33+ connect-src/frame-src origins (Auth0, device APIs, S3, API Gateway, siblings); reconfirmed stable
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — `getOrganization()` sends `GET /v1/organization/{uid}` with `X-Auth: <accountJWT>` and NO `organizationUid` query param; response includes `oauthClientId` + `oauthClientSecret`; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 (not 403) on `GET /v1/organization/<foreign-org-uid>` returning `oauthClientSecret`
verify_steps: AUTH_HELPED: `curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>` = 200 baseline; repeat with foreign-org UID → 200 + `oauthClientSecret` = cross-tenant; escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device` → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 70
reasoning: `OrganizationTokenManagement.ts` code-verified — GET list + POST `{"name":...}` against `organization/{uid}/security-token` with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs
evidence_needed: own account JWT → 200 on `GET /v1/organization/<foreign-uid>/security-token`; POST mints token valid on `/v1/device`
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign UID → 200 = cross-tenant mint; POST `{"name":"poc"}` → validate minted token with `X-Auth: <token>` on `/v1/device`
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant device peer-recovery read/write via legacy client-secret not bound to target device UID
class: IDOR
asset: api.signageos.io/v1/device/{uid}/peer-recovery
confidence: 60
reasoning: `DevicePeerRecoveryManagement.ts` code-verified — GET list / PUT `{enabled, urlLauncherAddress, autoEnableTimeoutMs}` with deviceUid as arbitrary path arg; legacy `X-Auth: clientId:secret` derives org from credential (no UID param), so org→device binding is the only barrier; same class applies to `/device/{uid}/command` and `/device/{uid}/organization`
evidence_needed: own org legacy `X-Auth: <clientId>:<secret>` → 200 on `GET /v1/device/<foreign-uid>/peer-recovery`
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <ownClientId>:<ownSecret>" https://api.signageos.io/v1/device/<own-uid>/peer-recovery` = 200; foreign device UID → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write
impact: read/overwrite foreign device recovery-launcher config → device+content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[PARKED] (none dropped — all confidence ≥60, class IDOR not on REJECTED list, all have concrete AUTH_HELPED verify_steps)
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + `oauthClientSecret` (from `sos organization list` for own UID); 3) repeat with a foreign tenant's org UID (second test tenant) → **200 + oauthClientSecret = confirmed CRITICAL cross-tenant credential disclosure**; 4) escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"` to list foreign org devices; then test H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`) with the leaked org credential. Requires own org UID + a second test tenant.
[LEARN] NO_NEW_PROOF — This cycle is passive analysis only; no AUTH_HELPED tests executed. All previously ACCEPTED/REJECTED classes from 2026-08-07 23:54 reconfirmed via delta (status endpoints, CORS, CSP, /ready, api CORS, api descriptive errors, box Auth0 OAuth2). v2/device now 403 (was 404) supports AUTH hypothesis but not proven.
[RISK] box.signageos.io: 58 — Unauthenticated `/status` info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl HTTP variant + zdusercontent wildcard); broad CSP (33+ connect-src/frame-src origins). Everything except `/status`, `/login/`, `/ready`, `/assets/*` redirects to Auth0 login. Moderate operational exposure, no direct data access without credentials.
[RISK] api.signageos.io: 62 — Unauthenticated `/status` info leak (pod hostname + service topology); 60+ `/v1/*`+`/v2/*` endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on `/`. **Risk raised** due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery, v2 drift) that are AUTH_HELPED-testable with CRITICAL business impact (device/firmware/content control). Main concern: JWT-gated high-value API with logic flaws in org-boundary enforcement; v2 migration advancing (/v2/device now 403).
[NEW] api.signageos.io Node version upgraded to v24.19.0 (mixed fleet: v24.19.0 + v20.20.2 pods confirmed)
[NEW] box.signageos.io pod hostname rotated to `box-7c8c876945-52dpt` (Node v20.20.2); api.signageos.io pod hostname rotated to `api-6f69db97d5-97fjw` (Node v24.19.0) — K8s rolling deploy confirmed
[CHANGED] api.signageos.io/v2/device now returns 403 JWT-gated (previously 404) — v2 migration advancing
[PRIO] api.signageos.io/v1/organization/{uid}/security-token: 7.85 (attack=9, business=10, tech=8, gate=3, cloud=8, fresh=8) — Cross-tenant org-token minting via account JWT + client-supplied org UID; JWT-gated but high-value logic flaw if path-UID membership not re-verified
[PRIO] api.signageos.io/v1/organization/{organizationUid}: 7.70 (attack=9, business=10, tech=8, gate=3, cloud=8, fresh=7) — Cross-tenant org OAuth client-secret disclosure via account JWT; SDK/CLI code-verified GET returns oauthClientSecret for arbitrary path UID
[PRIO] api.signageos.io/v1/device/{uid}/peer-recovery: 7.55 (attack=8, business=9, tech=8, gate=3, cloud=8, fresh=8) — Legacy X-Auth (clientId:secret) gate not bound to target device UID; org→device binding is sole barrier
[PRIO] api.signageos.io/v2/*: 6.95 (attack=7, business=8, tech=7, gate=10, cloud=7, fresh=9) — Partial v2 migration; /v2/device now JWT-gated (was 404), /v2/account + /v2/organization 404; authz drift candidate, PASSIVE testable
[PRIO] box.signageos.io/status: 5.20 (attack=6, business=4, tech=5, gate=10, cloud=6, fresh=6) — Unauthenticated info leak (pod hostname, UID, Node v20.20.2, Redis/Mongo/AMQP topology); reconfirmed stable
[PRIO] box.signageos.io CORS: 4.85 (attack=5, business=3, tech=6, gate=10, cloud=5, fresh=6) — 18 static ACAO incl HTTP variant + *.zdusercontent.com wildcard; no ACAO-Credentials; reconfirmed stable
[PRIO] box.signageos.io CSP: 4.60 (attack=5, business=3, tech=6, gate=10, cloud=4, fresh=5) — /login/ CSP 33+ connect-src/frame-src origins (Auth0, device APIs, S3, API Gateway, siblings); reconfirmed stable
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — `getOrganization()` sends `GET /v1/organization/{uid}` with `X-Auth: <accountJWT>` and NO `organizationUid` query param; response includes `oauthClientId` + `oauthClientSecret`; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 (not 403) on `GET /v1/organization/<foreign-org-uid>` returning `oauthClientSecret`
verify_steps: AUTH_HELPED: `curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>` = 200 baseline; repeat with foreign-org UID → 200 + `oauthClientSecret` = cross-tenant; escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device` → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 70
reasoning: `OrganizationTokenManagement.ts` code-verified — GET list + POST `{"name":...}` against `organization/{uid}/security-token` with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs
evidence_needed: own account JWT → 200 on `GET /v1/organization/<foreign-uid>/security-token`; POST mints token valid on `/v1/device`
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign UID → 200 = cross-tenant mint; POST `{"name":"poc"}` → validate minted token with `X-Auth: <token>` on `/v1/device`
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant device peer-recovery read/write via legacy client-secret not bound to target device UID
class: IDOR
asset: api.signageos.io/v1/device/{uid}/peer-recovery
confidence: 60
reasoning: `DevicePeerRecoveryManagement.ts` code-verified — GET list / PUT `{enabled, urlLauncherAddress, autoEnableTimeoutMs}` with deviceUid as arbitrary path arg; legacy `X-Auth: clientId:secret` derives org from credential (no UID param), so org→device binding is the only barrier; same class applies to `/device/{uid}/command` and `/device/{uid}/organization`
evidence_needed: own org legacy `X-Auth: <clientId>:<secret>` → 200 on `GET /v1/device/<foreign-uid>/peer-recovery`
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <ownClientId>:<ownSecret>" https://api.signageos.io/v1/device/<own-uid>/peer-recovery` = 200; foreign device UID → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write
impact: read/overwrite foreign device recovery-launcher config → device+content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[PARKED] (none dropped — all confidence ≥60, class IDOR not on REJECTED list, all have concrete AUTH_HELPED verify_steps)
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + `oauthClientSecret` (from `sos organization list` for own UID); 3) repeat with a foreign tenant's org UID (second test tenant) → **200 + oauthClientSecret = confirmed CRITICAL cross-tenant credential disclosure**; 4) escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"` to list foreign org devices; then test H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`) with the leaked org credential. Requires own org UID + a second test tenant.
[LEARN] NO_NEW_PROOF — This cycle is passive analysis only; no AUTH_HELPED tests executed. All previously ACCEPTED/REJECTED classes from 2026-08-07 23:54 reconfirmed via delta (status endpoints, CORS, CSP, /ready, api CORS, api descriptive errors, box Auth0 OAuth2). v2/device now 403 (was 404) supports AUTH hypothesis but not proven.
[RISK] box.signageos.io: 58 — Unauthenticated `/status` info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl HTTP variant + zdusercontent wildcard); broad CSP (33+ connect-src/frame-src origins). Everything except `/status`, `/login/`, `/ready`, `/assets/*` redirects to Auth0 login. Moderate operational exposure, no direct data access without credentials.
[RISK] api.signageos.io: 62 — Unauthenticated `/status` info leak (pod hostname + service topology); 60+ `/v1/*`+`/v2/*` endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on `/`. **Risk raised** due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery, v2 drift) that are AUTH_HELPED-testable with CRITICAL business impact (device/firmware/content control). Main concern: JWT-gated high-value API with logic flaws in org-boundary enforcement; v2 migration advancing (/v2/device now 403).
## 2026-08-08 02:37:20 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{organizationUid}: 7.85 (attack=9, business=10, tech=8, gate=3, cloud=8, fresh=8)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token: 7.70 (attack=9, business=10, tech=8, gate=3, cloud=8, fresh=7)
[PRIO] api.signageos.io/v1/device/{uid}/peer-recovery: 7.55 (attack=8, business=9, tech=8, gate=3, cloud=8, fresh=8)
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — `getOrganization()` sends `GET /v1/organization/{uid}` with `X-Auth: <accountJWT>` and NO `organizationUid` query param; response includes `oauthClientId` + `oauthClientSecret`; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 (not 403) on `GET /v1/organization/<foreign-org-uid>` returning `oauthClientSecret`
verify_steps: AUTH_HELPED: `curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>` = 200 baseline; repeat with foreign-org UID → 200 + `oauthClientSecret` = cross-tenant; escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device` → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 70
reasoning: `OrganizationTokenManagement.ts` code-verified — GET list + POST `{"name":...}` against `organization/{uid}/security-token` with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs
evidence_needed: own account JWT → 200 on `GET /v1/organization/<foreign-uid>/security-token`; POST mints token valid on `/v1/device`
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign UID → 200 = cross-tenant mint; POST `{"name":"poc"}` → validate minted token with `X-Auth: <token>` on `/v1/device`
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant device peer-recovery read/write via legacy client-secret not bound to target device UID
class: IDOR
asset: api.signageos.io/v1/device/{uid}/peer-recovery
confidence: 60
reasoning: `DevicePeerRecoveryManagement.ts` code-verified — GET list / PUT `{enabled, urlLauncherAddress, autoEnableTimeoutMs}` with deviceUid as arbitrary path arg; legacy `X-Auth: clientId:secret` derives org from credential (no UID param), so org→device binding is the only barrier; same class applies to `/device/{uid}/command` and `/device/{uid}/organization`
evidence_needed: own org legacy `X-Auth: <clientId>:<secret>` → 200 on `GET /v1/device/<foreign-uid>/peer-recovery`
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <ownClientId>:<ownSecret>" https://api.signageos.io/v1/device/<own-uid>/peer-recovery` = 200; foreign device UID → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write
impact: read/overwrite foreign device recovery-launcher config → device+content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[PARKED] (none dropped — all confidence ≥60, class IDOR not on REJECTED list, all have concrete AUTH_HELPED verify_steps)
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + `oauthClientSecret` (from `sos organization list` for own UID); 3) repeat with a foreign tenant's org UID (second test tenant) → **200 + oauthClientSecret = confirmed CRITICAL cross-tenant credential disclosure**; 4) escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"` to list foreign org devices; then test H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`) with the leaked org credential. Requires own org UID + a second test tenant.
[LEARN] NO_NEW_PROOF — This cycle is passive analysis only; no AUTH_HELPED tests executed. All previously ACCEPTED/REJECTED classes from 2026-08-07 23:54 reconfirmed via delta (status endpoints, CORS, CSP, /ready, api CORS, api descriptive errors, box Auth0 OAuth2). v2/device now 403 (was 404) supports AUTH hypothesis but not proven.
[RISK] box.signageos.io: 58 — Unauthenticated `/status` info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl HTTP variant + zdusercontent wildcard); broad CSP (33+ connect-src/frame-src origins). Everything except `/status`, `/login/`, `/ready`, `/assets/*` redirects to Auth0 login. Moderate operational exposure, no direct data access without credentials.
[RISK] api.signageos.io: 62 — Unauthenticated `/status` info leak (pod hostname + service topology); 60+ `/v1/*`+`/v2/*` endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on `/`. **Risk raised** due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery, v2 drift) that are AUTH_HELPED-testable with CRITICAL business impact (device/firmware/content control). Main concern: JWT-gated high-value API with logic flaws in org-boundary enforcement; v2 migration advancing (/v2/device now 403).
## 2026-08-08 03:55:10 UTC [api] (model nemotron3)
[NEW] api.signageos.io/v2/device: now returns 403 JWT-gated (was 404) — v2 migration advancing
[PRIO] api.signageos.io/v1/organization/{organizationUid}: 7.85 (attack=9, business=10, tech=8, gate=3, cloud=8, fresh=8)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token: 7.70 (attack=9, business=10, tech=8, gate=3, cloud=8, fresh=7)
[PRIO] api.signageos.io/v1/device/{uid}/peer-recovery: 7.55 (attack=8, business=9, tech=8, gate=3, cloud=8, fresh=8)
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — `getOrganization()` sends `GET /v1/organization/{uid}` with `X-Auth: <accountJWT>` and NO `organizationUid` query param; response includes `oauthClientId` + `oauthClientSecret`; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 (not 403) on `GET /v1/organization/<foreign-org-uid>` returning `oauthClientSecret`
verify_steps: AUTH_HELPED: `curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>` = 200 baseline; repeat with foreign-org UID → 200 + `oauthClientSecret` = cross-tenant; escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device` → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 70
reasoning: `OrganizationTokenManagement.ts` code-verified — GET list + POST `{"name":...}` against `organization/{uid}/security-token` with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs
evidence_needed: own account JWT → 200 on `GET /v1/organization/<foreign-uid>/security-token`; POST mints token valid on `/v1/device`
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign UID → 200 = cross-tenant mint; POST `{"name":"poc"}` → validate minted token with `X-Auth: <token>` on `/v1/device`
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant device peer-recovery read/write via legacy client-secret not bound to target device UID
class: IDOR
asset: api.signageos.io/v1/device/{uid}/peer-recovery
confidence: 60
reasoning: `DevicePeerRecoveryManagement.ts` code-verified — GET list / PUT `{enabled, urlLauncherAddress, autoEnableTimeoutMs}` with deviceUid as arbitrary path arg; legacy `X-Auth: clientId:secret` derives org from credential (no UID param), so org→device binding is the only barrier; same class applies to `/device/{uid}/command` and `/device/{uid}/organization`
evidence_needed: own org legacy `X-Auth: <clientId>:<secret>` → 200 on `GET /v1/device/<foreign-uid>/peer-recovery`
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <ownClientId>:<ownSecret>" https://api.signageos.io/v1/device/<own-uid>/peer-recovery` = 200; foreign device UID → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write
impact: read/overwrite foreign device recovery-launcher config → device+content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[PARKED] (none dropped — all confidence ≥60, class IDOR not on REJECTED list, all have concrete AUTH_HELPED verify_steps)
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + `oauthClientSecret` (from `sos organization list` for own UID); 3) repeat with a foreign tenant's org UID (second test tenant) → **200 + oauthClientSecret = confirmed CRITICAL cross-tenant credential disclosure**; 4) escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"` to list foreign org devices; then test H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`) with the leaked org credential. Requires own org UID + a second test tenant.
[LEARN] NO_NEW_PROOF — This cycle is passive analysis only; no AUTH_HELPED tests executed. All previously ACCEPTED/REJECTED classes from 2026-08-07 23:54 reconfirmed via delta (status endpoints, CORS, CSP, /ready, api CORS, api descriptive errors, box Auth0 OAuth2). v2/device now 403 (was 404) supports AUTH hypothesis but not proven.
[RISK] box.signageos.io: 58 — Unauthenticated `/status` info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl HTTP variant + zdusercontent wildcard); broad CSP (33+ connect-src/frame-src origins). Everything except `/status`, `/login/`, `/ready`, `/assets/*` redirects to Auth0 login. Moderate operational exposure, no direct data access without credentials.
[RISK] api.signageos.io: 62 — Unauthenticated `/status` info leak (pod hostname + service topology); 60+ `/v1/*`+`/v2/*` endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on `/`. **Risk raised** due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery, v2 drift) that are AUTH_HELPED-testable with CRITICAL business impact (device/firmware/content control). Main concern: JWT-gated high-value API with logic flaws in org-boundary enforcement; v2 migration advancing (/v2/device now 403).
## 2026-08-08 04:45:47 UTC [api] (model nemotron3)
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — `getOrganization()` sends `GET /v1/organization/{uid}` with `X-Auth: <accountJWT>` and NO `organizationUid` query param; response includes `oauthClientId` + `oauthClientSecret`; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 (not 403) on `GET /v1/organization/<foreign-org-uid>` returning `oauthClientSecret`
verify_steps: AUTH_HELPED: `curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>` = 200 baseline; repeat with foreign-org UID → 200 + `oauthClientSecret` = cross-tenant; escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device` → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 70
reasoning: `OrganizationTokenManagement.ts` code-verified — GET list + POST `{"name":...}` against `organization/{uid}/security-token` with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs
evidence_needed: own account JWT → 200 on `GET /v1/organization/<foreign-uid>/security-token`; POST mints token valid on `/v1/device`
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign UID → 200 = cross-tenant mint; POST `{"name":"poc"}` → validate minted token with `X-Auth: <token>` on `/v1/device`
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant device peer-recovery read/write via legacy client-secret not bound to target device UID
class: IDOR
asset: api.signageos.io/v1/device/{uid}/peer-recovery
confidence: 60
reasoning: `DevicePeerRecoveryManagement.ts` code-verified — GET list / PUT `{enabled, urlLauncherAddress, autoEnableTimeoutMs}` with deviceUid as arbitrary path arg; legacy `X-Auth: clientId:secret` derives org from credential (no UID param), so org→device binding is the only barrier; same class applies to `/device/{uid}/command` and `/device/{uid}/organization`
evidence_needed: own org legacy `X-Auth: <clientId>:<secret>` → 200 on `GET /v1/device/<foreign-uid>/peer-recovery`
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <ownClientId>:<ownSecret>" https://api.signageos.io/v1/device/<own-uid>/peer-recovery` = 200; foreign device UID → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write
impact: read/overwrite foreign device recovery-launcher config → device+content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[PARKED] (none dropped — all confidence ≥60, class IDOR not on REJECTED list, all have concrete AUTH_HELPED verify_steps)
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + `oauthClientSecret` (from `sos organization list` for own UID); 3) repeat with a foreign tenant's org UID (second test tenant) → **200 + oauthClientSecret = confirmed CRITICAL cross-tenant credential disclosure**; 4) escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"` to list foreign org devices; then test H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`) with the leaked org credential. Requires own org UID + a second test tenant.
[LEARN] NO_NEW_PROOF — This cycle is passive analysis only; no AUTH_HELPED tests executed. All previously ACCEPTED/REJECTED classes from 2026-08-07 23:54 reconfirmed via delta (status endpoints, CORS, CSP, /ready, api CORS, api descriptive errors, box Auth0 OAuth2). v2/device now 403 (was 404) supports AUTH hypothesis but not proven.
[RISK] box.signageos.io: 58 — Unauthenticated `/status` info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl HTTP variant + zdusercontent wildcard); broad CSP (33+ connect-src/frame-src origins). Everything except `/status`, `/login/`, `/ready`, `/assets/*` redirects to Auth0 login. Moderate operational exposure, no direct data access without credentials.
[RISK] api.signageos.io: 62 — Unauthenticated `/status` info leak (pod hostname + service topology); 60+ `/v1/*`+`/v2/*` endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on `/`. **Risk raised** due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery, v2 drift) that are AUTH_HELPED-testable with CRITICAL business impact (device/firmware/content control). Main concern: JWT-gated high-value API with logic flaws in org-boundary enforcement; v2 migration advancing (/v2/device now 403).
## 2026-08-08 05:30:05 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 88, attack=10 business=10 tech=8 gate=5 cloud=9 fresh=8  
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 81, attack=9 business=10 tech=8 gate=5 cloud=9 fresh=7  
[PRIO] api.signageos.io/v1/device/{uid}/peer-recovery, 74, attack=8 business=9 tech=7 gate=4 cloud=8 fresh=7
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT  
class: IDOR  
asset: api.signageos.io/v1/organization/{organizationUid}  
confidence: 75  
reasoning: SDK/CLI code-verified — `getOrganization()` sends `GET /v1/organization/{uid}` with `X-Auth: <accountJWT>` and NO `organizationUid` query param; response includes `oauthClientId` + `oauthClientSecret`; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier  
evidence_needed: own account JWT → HTTP 200 (not 403) on `GET /v1/organization/<foreign-org-uid>` returning `oauthClientSecret`  
verify_steps: AUTH_HELPED: `curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>` = 200 baseline; repeat with foreign-org UID → 200 + `oauthClientSecret` = cross-tenant; escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device` → foreign org device list  
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL  
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid  
class: IDOR  
asset: api.signageos.io/v1/organization/{uid}/security-token  
confidence: 70  
reasoning: `OrganizationTokenManagement.ts` code-verified — GET list + POST `{"name":...}` against `organization/{uid}/security-token` with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs  
evidence_needed: own account JWT → 200 on `GET /v1/organization/<foreign-uid>/security-token`; POST mints token valid on `/v1/device`  
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign UID → 200 = cross-tenant mint; POST `{"name":"poc"}` → validate minted token with `X-Auth: <token>` on `/v1/device`  
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL  
testability: AUTH_HELPED
[HYP] Cross-tenant device peer-recovery read/write via legacy client-secret not bound to target device UID  
class: IDOR  
asset: api.signageos.io/v1/device/{uid}/peer-recovery  
confidence: 60  
reasoning: `DevicePeerRecoveryManagement.ts` code-verified — GET list / PUT `{enabled, urlLauncherAddress, autoEnableTimeoutMs}` with deviceUid as arbitrary path arg; legacy `X-Auth: clientId:secret` derives org from credential (no UID param), so org→device binding is the only barrier; same class applies to `/device/{uid}/command` and `/device/{uid}/organization`  
evidence_needed: own org legacy `X-Auth: <clientId>:<secret>` → 200 on `GET /v1/device/<foreign-uid>/peer-recovery`  
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <ownClientId>:<ownSecret>" https://api.signageos.io/v1/device/<own-uid>/peer-recovery` = 200; foreign device UID → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write  
impact: read/overwrite foreign device recovery-launcher config → device+content takeover; HIGH→CRITICAL  
testability: AUTH_HELPED
[PARKED] (none dropped — all confidence ≥60, class IDOR not on REJECTED list, all have concrete AUTH_HELPED verify_steps)  
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + `oauthClientSecret` (from `sos organization list` for own UID); 3) repeat with a foreign tenant's org UID (second test tenant) → **200 + oauthClientSecret = confirmed CRITICAL cross-tenant credential disclosure**; 4) escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"` to list foreign org devices; then test H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`) with the leaked org credential. Requires own org UID + a second test tenant.
[LEARN] NO_NEW_PROOF — This cycle is passive analysis only; no AUTH_HELPED tests executed. All previously ACCEPTED/REJECTED classes from 2026-08-07 23:54 reconfirmed via delta (status endpoints, CORS, CSP, /ready, api CORS, api descriptive errors, box Auth0 OAuth2). v2/device now 403 (was 404) supports AUTH hypothesis but not proven.
[RISK] box.signageos.io: 58 — Unauthenticated `/status` info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl HTTP variant + zdusercontent wildcard); broad CSP (33+ connect-src/frame-src origins). Everything except `/status`, `/login/`, `/ready`, `/assets/*` redirects to Auth0 login. Moderate operational exposure, no direct data access without credentials.
[RISK] api.signageos.io: 62 — Unauthenticated `/status` info leak (pod hostname + service topology); 60+ `/v1/*`+`/v2/*` endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on `/`. **Risk raised** due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery, v2 drift) that are AUTH_HELPED-testable with CRITICAL business impact (device/firmware/content control). Main concern: JWT-gated high-value API with logic flaws in org-boundary enforcement; v2 migration advancing (/v2/device now 403).
## 2026-08-08 06:07:07 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 76, attack=9 business=10 tech=8 gate=5 cloud=9 fresh=7  
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 69, attack=8 business=10 tech=8 gate=5 cloud=9 fresh=6  
[PRIO] api.signageos.io/v1/device/{uid}/peer-recovery, 63, attack=7 business=9 tech=7 gate=4 cloud=8 fresh=6  
[PRIO] box.signageos.io/status, 58, attack=4 business=3 tech=5 gate=10 cloud=6 fresh=8  
[PRIO] api.signageos.io/status, 52, attack=3 business=3 tech=4 gate=10 cloud=6 fresh=8
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT  
class: IDOR  
asset: api.signageos.io/v1/organization/{organizationUid}  
confidence: 75  
reasoning: SDK/CLI code-verified — `getOrganization()` sends `GET /v1/organization/{uid}` with `X-Auth: <accountJWT>` and NO `organizationUid` query param; response includes `oauthClientId` + `oauthClientSecret`; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier  
evidence_needed: own account JWT → HTTP 200 (not 403) on `GET /v1/organization/<foreign-org-uid>` returning `oauthClientSecret`  
verify_steps: AUTH_HELPED: `curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>` = 200 baseline; repeat with foreign-org UID → 200 + `oauthClientSecret` = cross-tenant; escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device` → foreign org device list  
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL  
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid  
class: IDOR  
asset: api.signageos.io/v1/organization/{uid}/security-token  
confidence: 70  
reasoning: `OrganizationTokenManagement.ts` code-verified — GET list + POST `{"name":...}` against `organization/{uid}/security-token` with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs  
evidence_needed: own account JWT → 200 on `GET /v1/organization/<foreign-uid>/security-token`; POST mints token valid on `/v1/device`  
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign UID → 200 = cross-tenant mint; POST `{"name":"poc"}` → validate minted token with `X-Auth: <token>` on `/v1/device`  
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL  
testability: AUTH_HELPED
[HYP] Cross-tenant device peer-recovery read/write via legacy client-secret not bound to target device UID  
class: IDOR  
asset: api.signageos.io/v1/device/{uid}/peer-recovery  
confidence: 60  
reasoning: `DevicePeerRecoveryManagement.ts` code-verified — GET list / PUT `{enabled, urlLauncherAddress, autoEnableTimeoutMs}` with deviceUid as arbitrary path arg; legacy `X-Auth: clientId:secret` derives org from credential (no UID param), so org→device binding is the only barrier; same class applies to `/device/{uid}/command` and `/device/{uid}/organization`  
evidence_needed: own org legacy `X-Auth: <clientId>:<secret>` → 200 on `GET /v1/device/<foreign-uid>/peer-recovery`  
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <ownClientId>:<ownSecret>" https://api.signageos.io/v1/device/<own-uid>/peer-recovery` = 200; foreign device UID → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write  
impact: read/overwrite foreign device recovery-launcher config → device+content takeover; HIGH→CRITICAL  
testability: AUTH_HELPED
[PARKED] Cross-tenant device peer-recovery read/write via legacy client-secret not bound to target device UID: confidence 60 ≥ 40, class IDOR not rejected, verify_steps concrete — KEPT  
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + `oauthClientSecret` (from `sos organization list` for own UID); 3) repeat with a foreign tenant's org UID (second test tenant) → **200 + oauthClientSecret = confirmed CRITICAL cross-tenant credential disclosure**; 4) escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"` to list foreign org devices; then test H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`) with the leaked org credential. Requires own org UID + a second test tenant.
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 403105` — falls under descriptive error messages (excluded per scope.yml)  
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (previously 404) — now JWT-gated, not a pre-auth bypass  
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Node v20.20.2, hostname box-7c8c876945-52dpt, succeededServices (amqp0, redis0-3, mongoDB0-3)  
[LEARN] REJECTED MISCONFIG @ box.signageos.io/cors: No `access-control-allow-credentials` observed on any box path despite 18 static ACAO values
[RISK] box.signageos.io: 58 — Unauthenticated `/status` info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl HTTP variant + zdusercontent wildcard); broad CSP (33+ connect-src/frame-src origins). Everything except `/status`, `/login/`, `/ready`, `/assets/*` redirects to Auth0 login. Moderate operational exposure, no direct data access without credentials.  
[RISK] api.signageos.io: 62 — Unauthenticated `/status` info leak (pod hostname + service topology); 60+ `/v1/*`+`/v2/*` endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on `/`. **Risk raised** due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery, v2 drift) that are AUTH_HELPED-testable with CRITICAL business impact (device/firmware/content control). Main concern: JWT-gated high-value API with logic flaws in org-boundary enforcement; v2 migration advancing (/v2/device now 403).
## 2026-08-08 07:09:42 UTC [api] (model nemotron3)
[CHANGED] box.signageos.io/status: pod hostname rotated to `box-7c8c876945-9v4gf` (Node v20.20.2) — K8s rolling deploy churn, no functional change
[CHANGED] api.signageos.io/status: pod hostname rotated to `api-6f69db97d5-9kg9l` (Node v24.19.0) — K8s rolling deploy churn, no functional change
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 75, attack=9 business=10 tech=8 gate=5 cloud=9 fresh=7
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 69, attack=8 business=10 tech=8 gate=5 cloud=9 fresh=6
[PRIO] api.signageos.io/v1/device/{uid}/peer-recovery, 63, attack=7 business=9 tech=7 gate=4 cloud=8 fresh=6
[PRIO] box.signageos.io/status, 58, attack=4 business=3 tech=5 gate=10 cloud=6 fresh=8
[PRIO] api.signageos.io/status, 52, attack=3 business=3 tech=4 gate=10 cloud=6 fresh=8
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — `getOrganization()` sends `GET /v1/organization/{uid}` with `X-Auth: <accountJWT>`; response includes `oauthClientId` + `oauthClientSecret`; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 (not 403) on `GET /v1/organization/<foreign-org-uid>` returning `oauthClientSecret`
verify_steps: AUTH_HELPED: `curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>` = 200 baseline; repeat with foreign-org UID → 200 + `oauthClientSecret` = cross-tenant; escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device` → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 70
reasoning: `OrganizationTokenManagement.ts` code-verified — GET list + POST `{"name":...}` against `organization/{uid}/security-token` with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs
evidence_needed: own account JWT → 200 on `GET /v1/organization/<foreign-uid>/security-token`; POST mints token valid on `/v1/device`
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign UID → 200 = cross-tenant mint; POST `{"name":"poc"}` → validate minted token with `X-Auth: <token>` on `/v1/device`
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant device peer-recovery read/write via legacy client-secret not bound to target device UID
class: IDOR
asset: api.signageos.io/v1/device/{uid}/peer-recovery
confidence: 60
reasoning: `DevicePeerRecoveryManagement.ts` code-verified — GET list / PUT `{enabled, urlLauncherAddress, autoEnableTimeoutMs}` with deviceUid as arbitrary path arg; legacy `X-Auth: clientId:secret` derives org from credential (no UID param), so org→device binding is the only barrier; same class applies to `/device/{uid}/command` and `/device/{uid}/organization`
evidence_needed: own org legacy `X-Auth: <clientId>:<secret>` → 200 on `GET /v1/device/<foreign-uid>/peer-recovery`
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <ownClientId>:<ownSecret>" https://api.signageos.io/v1/device/<own-uid>/peer-recovery` = 200; foreign device UID → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write
impact: read/overwrite foreign device recovery-launcher config → device+content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + `oauthClientSecret` (from `sos organization list` for own UID); 3) repeat with a foreign tenant's org UID (second test tenant) → **200 + oauthClientSecret = confirmed CRITICAL cross-tenant credential disclosure**; 4) escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"` to list foreign org devices; then test H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`) with the leaked org credential. Requires own org UID + a second test tenant.
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 403105` — falls under descriptive error messages (excluded per scope.yml)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (previously 404) — now JWT-gated, not a pre-auth bypass
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live. Node v20.20.2, pod box-7c8c876945-9v4gf, succeededServices (amqp0, redis0-3, mongoDB0-3). Unchanged.
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live. Node v24.19.0, pod api-6f69db97d5-9kg9l, succeededServices (amqp0, redis0-3, mongoDB0-2). Unchanged.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CORS: Reconfirmed — 17 static ACAO (incl https://*.zdusercontent.com wildcard), no credentials header, unchanged under spoofed Origin. Unchanged.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CSP: Reconfirmed — /login/ CSP 40+ connect-src/frame-src origins, triplicated Auth0 oauth/token. Unchanged.
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. Unchanged.
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 flow params still not testable passively. Carried forward.
[RISK] box.signageos.io: 58 — Unauthenticated `/status` info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard); broad CSP (40+ connect-src/frame-src origins). Everything except `/status`, `/login/`, `/ready`, `/assets/*` redirects to Auth0 login. Moderate operational exposure, no direct data access without credentials.
[RISK] api.signageos.io: 62 — Unauthenticated `/status` info leak (pod hostname + service topology); 60+ `/v1/*`+`/v2/*` endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on `/`. **Risk raised** due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery, v2 drift) that are AUTH_HELPED-testable with CRITICAL business impact (device/firmware/content control). Main concern: JWT-gated high-value API with logic flaws in org-boundary enforcement; v2 migration advancing (/v2/device now 403).
## 2026-08-08 07:58:29 UTC [api] (model nemotron3)
[CHANGED] box.signageos.io/status: pod hostname rotated to `box-7c8c876945-xmdhm` (Node v20.20.2) — K8s rolling deploy churn, no functional change
[CHANGED] api.signageos.io/status: pod hostname rotated to `api-6f69db97d5-jnncr` (Node v24.19.0) — K8s rolling deploy churn, no functional change
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 75, attack=9 business=10 tech=8 gate=5 cloud=9 fresh=7
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 69, attack=8 business=10 tech=8 gate=5 cloud=9 fresh=6
[PRIO] api.signageos.io/v1/device/{uid}/peer-recovery, 63, attack=7 business=9 tech=7 gate=4 cloud=8 fresh=6
[PRIO] box.signageos.io/status, 58, attack=4 business=3 tech=5 gate=10 cloud=6 fresh=8
[PRIO] api.signageos.io/status, 52, attack=3 business=3 tech=4 gate=10 cloud=6 fresh=8
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — `getOrganization()` sends `GET /v1/organization/{uid}` with `X-Auth: <accountJWT>`; response includes `oauthClientId` + `oauthClientSecret`; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 (not 403) on `GET /v1/organization/<foreign-org-uid>` returning `oauthClientSecret`
verify_steps: AUTH_HELPED: `curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>` = 200 baseline; repeat with foreign-org UID → 200 + `oauthClientSecret` = cross-tenant; escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device` → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 70
reasoning: `OrganizationTokenManagement.ts` code-verified — GET list + POST `{"name":...}` against `organization/{uid}/security-token` with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs
evidence_needed: own account JWT → 200 on `GET /v1/organization/<foreign-uid>/security-token`; POST mints token valid on `/v1/device`
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign UID → 200 = cross-tenant mint; POST `{"name":"poc"}` → validate minted token with `X-Auth: <token>` on `/v1/device`
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant device peer-recovery read/write via legacy client-secret not bound to target device UID
class: IDOR
asset: api.signageos.io/v1/device/{uid}/peer-recovery
confidence: 60
reasoning: `DevicePeerRecoveryManagement.ts` code-verified — GET list / PUT `{enabled, urlLauncherAddress, autoEnableTimeoutMs}` with deviceUid as arbitrary path arg; legacy `X-Auth: clientId:secret` derives org from credential (no UID param), so org→device binding is the only barrier; same class applies to `/device/{uid}/command` and `/device/{uid}/organization`
evidence_needed: own org legacy `X-Auth: <clientId>:<secret>` → 200 on `GET /v1/device/<foreign-uid>/peer-recovery`
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <ownClientId>:<ownSecret>" https://api.signageos.io/v1/device/<own-uid>/peer-recovery` = 200; foreign device UID → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write
impact: read/overwrite foreign device recovery-launcher config → device+content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + `oauthClientSecret` (from `sos organization list` for own UID); 3) repeat with a foreign tenant's org UID (second test tenant) → **200 + oauthClientSecret = confirmed CRITICAL cross-tenant credential disclosure**; 4) escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"` to list foreign org devices; then test H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`) with the leaked org credential. Requires own org UID + a second test tenant.
[LEARN] NO_NEW_PROOF — This cycle is passive analysis only; no AUTH_HELPED tests executed. All previously ACCEPTED/REJECTED classes from 2026-08-07 23:54 reconfirmed via delta (status endpoints, CORS, CSP, /ready, api CORS, api descriptive errors, box Auth0 OAuth2). v2/device now 403 (was 404) supports AUTH hypothesis but not proven.
[RISK] box.signageos.io: 58 — Unauthenticated `/status` info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard); broad CSP (40+ connect-src/frame-src origins). Everything except `/status`, `/login/`, `/ready`, `/assets/*` redirects to Auth0 login. Moderate operational exposure, no direct data access without credentials.
[RISK] api.signageos.io: 62 — Unauthenticated `/status` info leak (pod hostname + service topology); 60+ `/v1/*`+`/v2/*` endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on `/`. **Risk raised** due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery, v2 drift) that are AUTH_HELPED-testable with CRITICAL business impact (device/firmware/content control). Main concern: JWT-gated high-value API with logic flaws in org-boundary enforcement; v2 migration advancing (/v2/device now 403).
## 2026-08-08 08:30:20 UTC [api] (model nemotron3)
[NEW] None — latest cycle (2026-08-08 07:58) shows only K8s pod hostname rotation on `/status` endpoints (box-7c8c876945-xmdhm, api-6f69db97d5-jnncr), no functional surface change
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 75, attack=9 business=10 tech=8 gate=5 cloud=9 fresh=7
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 78, attack=8 business=10 tech=8 gate=5 cloud=9 fresh=6
[PRIO] api.signageos.io/v1/device/{uid}/peer-recovery, 63, attack=7 business=9 tech=7 gate=4 cloud=8 fresh=6
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — `getOrganization()` sends `GET /v1/organization/{uid}` with `X-Auth: <accountJWT>`; response includes `oauthClientId` + `oauthClientSecret`; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 (not 403) on `GET /v1/organization/<foreign-org-uid>` returning `oauthClientSecret`
verify_steps: AUTH_HELPED: `curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>` = 200 baseline; repeat with foreign-org UID → 200 + `oauthClientSecret` = cross-tenant; escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device` → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 70
reasoning: `OrganizationTokenManagement.ts` code-verified — GET list + POST `{"name":...}` against `organization/{uid}/security-token` with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs
evidence_needed: own account JWT → 200 on `GET /v1/organization/<foreign-uid>/security-token`; POST mints token valid on `/v1/device`
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign UID → 200 = cross-tenant mint; POST `{"name":"poc"}` → validate minted token with `X-Auth: <token>` on `/v1/device`
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant device peer-recovery read/write via legacy client-secret not bound to target device UID
class: IDOR
asset: api.signageos.io/v1/device/{uid}/peer-recovery
confidence: 60
reasoning: `DevicePeerRecoveryManagement.ts` code-verified — GET list / PUT `{enabled, urlLauncherAddress, autoEnableTimeoutMs}` with deviceUid as arbitrary path arg; legacy `X-Auth: clientId:secret` derives org from credential (no UID param), so org→device binding is the only barrier; same class applies to `/device/{uid}/command` and `/device/{uid}/organization`
evidence_needed: own org legacy `X-Auth: <clientId>:<secret>` → 200 on `GET /v1/device/<foreign-uid>/peer-recovery`
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <ownClientId>:<ownSecret>" https://api.signageos.io/v1/device/<own-uid>/peer-recovery` = 200; foreign device UID → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write
impact: read/overwrite foreign device recovery-launcher config → device+content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + `oauthClientSecret` (from `sos organization list` for own UID); 3) repeat with a foreign tenant's org UID (second test tenant) → **200 + oauthClientSecret = confirmed CRITICAL cross-tenant credential disclosure**; 4) escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"` to list foreign org devices; then test H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`) with the leaked org credential. Requires own org UID + a second test tenant.
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `WRONG_JWT_TOKEN`/`NO_ORGANIZATION_TO_AUTHENTICATE`/`WRONG_ACCOUNT_SECRET` + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (carried forward)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (previously 404) — now JWT-gated, not a pre-auth bypass (carried forward)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live. Node v20.20.2, pod box-7c8c876945-xmdhm, succeededServices (amqp0, redis0-3, mongoDB0-3). Unchanged.
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live. Node v24.19.0, pod api-6f69db97d5-jnncr, same topology. Unchanged.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CORS: Reconfirmed — 18 static ACAO (incl http:// variant + https://*.zdusercontent.com), no credentials header, unchanged under spoofed Origin. Unchanged.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CSP: Reconfirmed — /login/ CSP 40+ connect-src/frame-src origins (mapbox, events.mapbox, sentry, Auth0 oauth/token), triplicated Auth0 entries. Unchanged.
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. Unchanged.
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 flow params not passively testable without tenant/authenticated session (carried forward).
[LEARN] CONFIRMED MECHANISM @ api.signageos.io/v1/organization/{uid}: Dual-auth precisely enumerated — X-Auth format `id:unsafeDecryptedToken`; org identity derived from header first-part (before `:`); `/organization/{uid}`→403075, `/organization/{uid}/security-token`→403076, `/v1/device`→403105 (JWT-only). Org {uid} in path is client-supplied and distinct from auth-derived org — narrows IDOR verification to X-Auth org-crossing.
[RISK] box.signageos.io: 58 — Unauthenticated `/status` info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Everything except `/status`, `/login/`, `/ready`, `/assets/*` redirects to Auth0 login. Moderate operational exposure, no direct data access without credentials.
[RISK] api.signageos.io: 62 — Unauthenticated `/status` info leak (pod hostname + service topology); 60+ `/v1/*`+`/v2/*` endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on `/`. **Risk raised** due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery, v2 drift) that are AUTH_HELPED-testable with CRITICAL business impact (device/firmware/content control). Main concern: JWT-gated high-value API with logic flaws in org-boundary enforcement; v2 migration advancing (/v2/device now 403).
## 2026-08-08 09:12:37 UTC [api] (model nemotron3)
[NEW] api.signageos.io/status now carries proper security headers: `strict-transport-security: max-age=31536000`, `x-frame-options: DENY`, `x-content-type-options: nosniff` — previously absent
[CHANGED] api.signageos.io/v2/device confirmed 403 JWT-gated (was 404) — v2 migration advancing; carries same security headers as /status
[CHANGED] box.signageos.io/status pod hostname rotated to `box-7c8c876945-r5fm9` (Node v20.20.2) — still missing HSTS/xfo/xcto
[CHANGED] api.signageos.io/status pod hostname rotated to `api-6f69db97d5-9kg9l` (Node v24.19.0) — now hardened with security headers
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 75, attack=9 business=10 tech=8 gate=5 cloud=9 fresh=7
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 78, attack=8 business=10 tech=8 gate=5 cloud=9 fresh=6
[PRIO] api.signageos.io/v1/device/{uid}/peer-recovery, 63, attack=7 business=9 tech=7 gate=4 cloud=8 fresh=6
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — `getOrganization()` sends `GET /v1/organization/{uid}` with `X-Auth: <accountJWT>`; response includes `oauthClientId` + `oauthClientSecret`; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 (not 403) on `GET /v1/organization/<foreign-org-uid>` returning `oauthClientSecret`
verify_steps: AUTH_HELPED: `curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>` = 200 baseline; repeat with foreign-org UID → 200 + `oauthClientSecret` = cross-tenant; escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device` → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 70
reasoning: `OrganizationTokenManagement.ts` code-verified — GET list + POST `{"name":...}` against `organization/{uid}/security-token` with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs
evidence_needed: own account JWT → 200 on `GET /v1/organization/<foreign-uid>/security-token`; POST mints token valid on `/v1/device`
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign UID → 200 = cross-tenant mint; POST `{"name":"poc"}` → validate minted token with `X-Auth: <token>` on `/v1/device`
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant device peer-recovery read/write via legacy client-secret not bound to target device UID
class: IDOR
asset: api.signageos.io/v1/device/{uid}/peer-recovery
confidence: 60
reasoning: `DevicePeerRecoveryManagement.ts` code-verified — GET list / PUT `{enabled, urlLauncherAddress, autoEnableTimeoutMs}` with deviceUid as arbitrary path arg; legacy `X-Auth: clientId:secret` derives org from credential (no UID param), so org→device binding is the only barrier; same class applies to `/device/{uid}/command` and `/device/{uid}/organization`
evidence_needed: own org legacy `X-Auth: <clientId>:<secret>` → 200 on `GET /v1/device/<foreign-uid>/peer-recovery`
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <ownClientId>:<ownSecret>" https://api.signageos.io/v1/device/<own-uid>/peer-recovery` = 200; foreign device UID → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write
impact: read/overwrite foreign device recovery-launcher config → device+content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + `oauthClientSecret` (from `sos organization list` for own UID); 3) repeat with a foreign tenant's org UID (second test tenant) → **200 + oauthClientSecret = confirmed CRITICAL cross-tenant credential disclosure**; 4) escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"` to list foreign org devices; then test H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`) with the leaked org credential. Requires own org UID + a second test tenant.
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now carries proper security headers (HSTS, x-frame-options: DENY, x-content-type-options: nosniff) — hardening relative to box.status which lacks them
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `WRONG_JWT_TOKEN`/`NO_ORGANIZATION_TO_AUTHENTICATE`/`WRONG_ACCOUNT_SECRET` + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (carried forward)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (previously 404) — now JWT-gated, not a pre-auth bypass (carried forward)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live. Node v20.20.2, pod box-7c8c876945-r5fm9, succeededServices (amqp0, redis0-3, mongoDB0-3). Still missing HSTS/xfo/xcto.
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live. Node v24.19.0, pod api-6f69db97d5-9kg9l, same topology. Now hardened with security headers.
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 403).
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 flow params not passively testable without tenant/authenticated session (carried forward).
[RISK] box.signageos.io: 58 — Unauthenticated `/status` info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Everything except `/status`, `/login/`, `/ready`, `/assets/*` redirects to Auth0 login. Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated `/status` info leak (pod hostname + service topology); 60+ `/v1/*`+`/v2/*` endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on `/`. **Risk raised** due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery, v2 drift) that are AUTH_HELPED-testable with CRITICAL business impact (device/firmware/content control). Main concern: JWT-gated high-value API with logic flaws in org-boundary enforcement; v2 migration advancing (/v2/device now 403). api.status now hardened with HSTS/xfo/xcto.
## 2026-08-08 09:53:37 UTC [api] (model nemotron3)
[NEW] api.signageos.io/status now carries proper security headers: `strict-transport-security: max-age=31536000`, `x-frame-options: DENY`, `x-content-type-options: nosniff` — previously absent
[CHANGED] api.signageos.io/v2/device confirmed 403 JWT-gated (was 404) — v2 migration advancing; carries same security headers as /status
[CHANGED] box.signageos.io/status pod hostname rotated to `box-7c8c876945-rzvgp` (Node v20.20.2) — still missing HSTS/xfo/xcto
[CHANGED] api.signageos.io/status pod hostname rotated to `api-6f69db97d5-9kg9l` (Node v24.19.0) — now hardened with security headers
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 75, attack=9 business=10 tech=8 gate=5 cloud=9 fresh=7
[PRIO] api.signageos.io/v1/organization/{organizationUid}/security-token, 78, attack=8 business=10 tech=8 gate=5 cloud=9 fresh=6
[PRIO] api.signageos.io/v1/device/{uid}/peer-recovery, 63, attack=7 business=9 tech=7 gate=4 cloud=8 fresh=6
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — `getOrganization()` sends `GET /v1/organization/{uid}` with `X-Auth: <accountJWT>`; response includes `oauthClientId` + `oauthClientSecret`; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 (not 403) on `GET /v1/organization/<foreign-org-uid>` returning `oauthClientSecret`
verify_steps: AUTH_HELPED: `curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>` = 200 baseline; repeat with foreign-org UID → 200 + `oauthClientSecret` = cross-tenant; escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device` → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 70
reasoning: `OrganizationTokenManagement.ts` code-verified — GET list + POST `{"name":...}` against `organization/{uid}/security-token` with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs
evidence_needed: own account JWT → 200 on `GET /v1/organization/<foreign-uid>/security-token`; POST mints token valid on `/v1/device`
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign UID → 200 = cross-tenant mint; POST `{"name":"poc"}` → validate minted token with `X-Auth: <token>` on `/v1/device`
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant device peer-recovery read/write via legacy client-secret not bound to target device UID
class: IDOR
asset: api.signageos.io/v1/device/{uid}/peer-recovery
confidence: 60
reasoning: `DevicePeerRecoveryManagement.ts` code-verified — GET list / PUT `{enabled, urlLauncherAddress, autoEnableTimeoutMs}` with deviceUid as arbitrary path arg; legacy `X-Auth: clientId:secret` derives org from credential (no UID param), so org→device binding is the only barrier; same class applies to `/device/{uid}/command` and `/device/{uid}/organization`
evidence_needed: own org legacy `X-Auth: <clientId>:<secret>` → 200 on `GET /v1/device/<foreign-uid>/peer-recovery`
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <ownClientId>:<ownSecret>" https://api.signageos.io/v1/device/<own-uid>/peer-recovery` = 200; foreign device UID → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write
impact: read/overwrite foreign device recovery-launcher config → device+content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] HUMAN: Execute H1 POC with one box-minted account token — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <accountJWT>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + `oauthClientSecret` (from `sos organization list` for own UID); 3) repeat with a foreign tenant's org UID (second test tenant) → **200 + oauthClientSecret = confirmed CRITICAL cross-tenant credential disclosure**; 4) escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"` to list foreign org devices; then test H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`) with the leaked org credential. Requires own org UID + a second test tenant.
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now carries proper security headers (HSTS, x-frame-options: DENY, x-content-type-options: nosniff) — hardening relative to box.status which lacks them
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `WRONG_JWT_TOKEN`/`NO_ORGANIZATION_TO_AUTHENTICATE`/`WRONG_ACCOUNT_SECRET` + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (carried forward)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (previously 404) — now JWT-gated, not a pre-auth bypass (carried forward)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live. Node v20.20.2, pod box-7c8c876945-rzvgp, succeededServices (amqp0, redis0-3, mongoDB0-3). Still missing HSTS/xfo/xcto.
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live. Node v24.19.0, pod api-6f69db97d5-9kg9l, same topology. Now hardened with security headers.
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 403).
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 flow params not passively testable without tenant/authenticated session (carried forward).
[RISK] box.signageos.io: 58 — Unauthenticated `/status` info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Everything except `/status`, `/login/`, `/ready`, `/assets/*` redirects to Auth0 login. Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated `/status` info leak (pod hostname + service topology); 60+ `/v1/*`+`/v2/*` endpoints all solidly JWT-gated (403 without token); no CORS issues; static HTML landing on `/`. **Risk raised** due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery, v2 drift) that are AUTH_HELPED-testable with CRITICAL business impact (device/firmware/content control). Main concern: JWT-gated high-value API with logic flaws in org-boundary enforcement; v2 migration advancing (/v2/device now 403). api.status now hardened with HSTS/xfo/xcto.
## 2026-08-08 10:20:49 UTC [api] (model nemotron3)
[NEW] box.signageos.io/status pod hostname rotated to `box-7c8c876945-52dpt` (Node v20.20.2) — K8s rolling deploy
[CHANGED] api.signageos.io/status pod hostname rotated to `api-6f69db97d5-22g8d` (Node v24.19.0) — K8s rolling deploy; security headers (HSTS/xfo/xcto) confirmed present
[PRIO] box.signageos.io/status, 73, attack=9 business=6 tech=7 gate=10 cloud=8 fresh=7
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 75, attack=8 business=10 tech=8 gate=5 cloud=9 fresh=7
[PRIO] api.signageos.io/v1/organization/{organizationUid}/security-token, 73, attack=7 business=10 tech=8 gate=5 cloud=9 fresh=6
[HYP] Unauthenticated /status topology leak with zero security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live GET returns JSON with pod hostname, process UID, Node v20.20.2, full Redis/MongoDB/AMQP topology; headers show ONLY x-powered-by: Express — no HSTS, x-frame-options, x-content-type-options, CSP; api.status now hardened with all three
evidence_needed: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' returns zero matches
verify_steps: PASSIVE: curl -sD- https://box.signageos.io/status (confirm data + header deficit)
impact: Infrastructure topology + process identity exposed unauthenticated; aids reconnaissance for chained attacks; MEDIUM
testability: PASSIVE
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — getOrganization() sends GET /v1/organization/{uid} with X-Auth: <accountJWT>; response includes oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 (not 403) on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}/security-token
confidence: 70
reasoning: OrganizationTokenManagement.ts code-verified — GET list + POST {"name":...} against organization/{uid}/security-token with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs
evidence_needed: own account JWT → 200 on GET /v1/organization/<foreign-uid>/security-token; POST mints token valid on /v1/device
verify_steps: AUTH_HELPED: baseline GET /v1/organization/<own>/security-token = 200; foreign UID → 200 = cross-tenant mint; POST {"name":"poc"} → validate minted token with X-Auth: <token> on /v1/device
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] PROBE: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' — confirm zero security headers on /status
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname, process UID, Node v20.20.2, full service topology (amqp0, redis0-3, mongoDB0-3); headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology); 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues; api.status now hardened with HSTS/xfo/xcto. **Risk raised** due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-08 10:57:11 UTC [api] (model nemotron3)
[PRIO] box.signageos.io/status, 73, attack=9 business=6 tech=7 gate=10 cloud=8 fresh=7  
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 75, attack=8 business=10 tech=8 gate=5 cloud=9 fresh=7  
[PRIO] api.signageos.io/v1/organization/{organizationUid}/security-token, 73, attack=7 business=10 tech=8 gate=5 cloud=9 fresh=6  
[PRIO] api.signageos.io/v1/device/{uid}/peer-recovery, 70, attack=7 business=9 tech=8 gate=5 cloud=8 fresh=6  
[PRIO] box.signageos.io/login/ (CORS+CSP), 58, attack=6 business=5 tech=7 gate=10 cloud=6 fresh=5
[HYP] Unauthenticated /status topology leak with zero security headers  
class: MISCONFIG  
asset: box.signageos.io/status  
confidence: 95  
reasoning: Live GET returns JSON with pod hostname, process UID, Node v20.20.2, full Redis/MongoDB/AMQP topology; headers show ONLY x-powered-by: Express — no HSTS, x-frame-options, x-content-type-options, CSP; api.status now hardened with all three  
evidence_needed: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' returns zero matches  
verify_steps: PASSIVE: curl -sD- https://box.signageos.io/status (confirm data + header deficit)  
impact: Infrastructure topology + process identity exposed unauthenticated; aids reconnaissance for chained attacks; MEDIUM  
testability: PASSIVE  
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT  
class: IDOR  
asset: api.signageos.io/v1/organization/{organizationUid}  
confidence: 75  
reasoning: SDK/CLI code-verified — getOrganization() sends GET /v1/organization/{uid} with X-Auth: <accountJWT>; response includes oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier  
evidence_needed: own account JWT → HTTP 200 (not 403) on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret  
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list  
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL  
testability: AUTH_HELPED  
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid  
class: IDOR  
asset: api.signageos.io/v1/organization/{organizationUid}/security-token  
confidence: 70  
reasoning: OrganizationTokenManagement.ts code-verified — GET list + POST {"name":...} against organization/{uid}/security-token with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs  
evidence_needed: own account JWT → 200 on GET /v1/organization/<foreign-uid>/security-token; POST mints token valid on /v1/device  
verify_steps: AUTH_HELPED: baseline GET /v1/organization/<own>/security-token = 200; foreign UID → 200 = cross-tenant mint; POST {"name":"poc"} → validate minted token with X-Auth: <token> on /v1/device  
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL  
testability: AUTH_HELPED
[PARKED] Cross-tenant device peer-recovery via X-Auth legacy creds: confidence 65 but verify_steps require AUTH_HELPED with two tenant orgs — same gate as H1/H2, lower business impact (device config only vs full org creds); deferred until H1/H2 resolved  
[FINAL] Ranked surviving hypotheses (top first):  
[NEXT] PROBE: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' — confirm zero security headers on /status (final passive validation before reporting)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname, process UID, Node v20.20.2, full service topology (amqp0, redis0-3, mongoDB0-3); headers ONLY x-powered-by: Express — zero hardening headers  
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status  
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml  
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass  
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 403).  
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all entry requires tenant/authenticated session.
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.  
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology); 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues; api.status now hardened with HSTS/xfo/xcto. **Risk raised** due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery) that are AUTH_HELPED-testable with CRITICAL business impact (device/firmware/content control).
## 2026-08-08 11:21:31 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 8.1, attack=8 business=10 tech=8 gate=5 cloud=9 fresh=7
[PRIO] box.signageos.io/status, 7.8, attack=9 business=6 tech=7 gate=10 cloud=8 fresh=7
[PRIO] api.signageos.io/v1/organization/{organizationUid}/security-token, 7.7, attack=7 business=10 tech=8 gate=5 cloud=9 fresh=6
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — getOrganization() sends GET /v1/organization/{uid} with X-Auth: <accountJWT>; response includes oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 (not 403) on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated /status topology leak with zero security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live GET returns JSON with pod hostname, process UID, Node v20.20.2, full Redis/MongoDB/AMQP topology; headers show ONLY x-powered-by: Express — no HSTS, x-frame-options, x-content-type-options, CSP; api.status now hardened with all three
evidence_needed: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' returns zero matches
verify_steps: PASSIVE: curl -sD- https://box.signageos.io/status (confirm data + header deficit)
impact: Infrastructure topology + process identity exposed unauthenticated; aids reconnaissance for chained attacks; MEDIUM
testability: PASSIVE
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}/security-token
confidence: 70
reasoning: OrganizationTokenManagement.ts code-verified — GET list + POST {"name":...} against organization/{uid}/security-token with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs
evidence_needed: own account JWT → 200 on GET /v1/organization/<foreign-uid>/security-token; POST mints token valid on /v1/device
verify_steps: AUTH_HELPED: baseline GET /v1/organization/<own>/security-token = 200; foreign UID → 200 = cross-tenant mint; POST {"name":"poc"} → validate minted token with X-Auth: <token> on /v1/device
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] PROBE: curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_status_b.json && cat /tmp/poc_box_status_h.txt && echo "---" && cat /tmp/poc_box_status_b.json | jq . — finalize box /status PoC evidence package (headers + body) for reporting
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod box-7c8c876945-gkzcp, Node v20.20.2, process UID b341def86252cd23a7db1382d94c091a590c400c1b4d8d9602, full amqp0/redis0-3/mongoDB0-3 topology; headers ONLY x-powered-by: Express (zero hardening headers)
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live — pod api-6f69db97d5-22g8d, Node v24.19.0, full topology; now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — not a pre-auth bypass
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but now hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. **Risk raised** due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-08 11:46:46 UTC [api] (model nemotron3)
## 2026-08-08 12:03:27 UTC [api] (model nemotron3)
## 2026-08-08 13:06:41 UTC [api] (model nemotron3)
## 2026-08-08 13:54:02 UTC [api] (model nemotron3)
## 2026-08-08 14:21:49 UTC [api] (model nemotron3)
## 2026-08-08 14:56:29 UTC [api] (model nemotron3)
[PRIO] box.signageos.io/status, 7.8, attack=9 business=6 tech=7 gate=10 cloud=8 fresh=7
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.5, attack=7 business=10 tech=8 gate=5 cloud=9 fresh=6
[PRIO] api.signageos.io/v1/organization/{organizationUid}/security-token, 7.3, attack=7 business=10 tech=8 gate=5 cloud=9 fresh=6
[HYP] Unauthenticated /status topology leak with zero security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live GET returns JSON with pod hostname, process UID, Node v20.20.2, full Redis/MongoDB/AMQP topology; headers show ONLY x-powered-by: Express — no HSTS, x-frame-options, x-content-type-options, CSP; api.status now hardened with all three
evidence_needed: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' returns zero matches
verify_steps: PASSIVE: curl -sD- https://box.signageos.io/status (confirm data + header deficit)
impact: Infrastructure topology + process identity exposed unauthenticated; aids reconnaissance for chained attacks; MEDIUM
testability: PASSIVE
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — getOrganization() sends GET /v1/organization/{uid} with X-Auth: <accountJWT>; response includes oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 (not 403) on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}/security-token
confidence: 70
reasoning: OrganizationTokenManagement.ts code-verified — GET list + POST {"name":...} against organization/{uid}/security-token with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs
evidence_needed: own account JWT → 200 on GET /v1/organization/<foreign-uid>/security-token; POST mints token valid on /v1/device
verify_steps: AUTH_HELPED: baseline GET /v1/organization/<own>/security-token = 200; foreign UID → 200 = cross-tenant mint; POST {"name":"poc"} → validate minted token with X-Auth: <token> on /v1/device
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[PARKED] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid: confidence 70 but lower business impact than OAuth secret disclosure (token vs permanent cred); same AUTH_HELPED gate; deferred until H1 resolved
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] PROBE: curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_status_b.json && cat /tmp/poc_box_status_h.txt && echo "---" && cat /tmp/poc_box_status_b.json | jq . — finalize box /status PoC evidence package (headers + body) for reporting
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname, process UID, Node v20.20.2, full service topology (amqp0, redis0-3, mongoDB0-3); headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 403).
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all entry requires tenant/authenticated session.
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but now hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. **Risk raised** due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-08 15:17:50 UTC [api] (model nemotron3)
## 2026-08-08 15:48:28 UTC [api] (model nemotron3)
## 2026-08-08 17:03:53 UTC [api] (model nemotron3)
[HYP] Unauthenticated /status topology leak with zero security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live GET returns JSON with pod hostname, process UID, Node v20.20.2, full Redis/MongoDB/AMQP topology; headers show ONLY x-powered-by: Express — no HSTS, x-frame-options, x-content-type-options, CSP; api.status now hardened with all three
evidence_needed: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' returns zero matches
verify_steps: PASSIVE: curl -sD- https://box.signageos.io/status (confirm data + header deficit)
impact: Infrastructure topology + process identity exposed unauthenticated; aids reconnaissance for chained attacks; MEDIUM
testability: PASSIVE
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — getOrganization() sends GET /v1/organization/{uid} with X-Auth: <accountJWT>; response includes oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 (not 403) on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}/security-token
confidence: 70
reasoning: OrganizationTokenManagement.ts code-verified — GET list + POST {"name":...} against organization/{uid}/security-token with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs
evidence_needed: own account JWT → 200 on GET /v1/organization/<foreign-uid>/security-token; POST mints token valid on /v1/device
verify_steps: AUTH_HELPED: baseline GET /v1/organization/<own>/security-token = 200; foreign UID → 200 = cross-tenant mint; POST {"name":"poc"} → validate minted token with X-Auth: <token> on /v1/device
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] PROBE: curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content|content-security' /tmp/poc_status_h.txt && cat /tmp/poc_status_b.json | jq .
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 403).
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all entry requires tenant/authenticated session.
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but now hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-08 17:42:36 UTC [api] (model nemotron3)
## 2026-08-08 18:13:41 UTC [api] (model nemotron3)
## 2026-08-08 19:02:50 UTC [api] (model nemotron3)
## 2026-08-08 19:39:57 UTC [api] (model nemotron3)
## 2026-08-08 20:07:34 UTC [api] (model nemotron3)
## 2026-08-08 20:45:25 UTC [api] (model nemotron3)
## 2026-08-08 21:15:00 UTC [api] (model nemotron3)
## 2026-08-08 21:52:02 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.5, attack=8 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — getOrganization() sends GET /v1/organization/{uid} with X-Auth: <accountJWT>; response includes oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}/security-token
confidence: 70
reasoning: OrganizationTokenManagement.ts code-verified — GET list + POST {"name":...} against organization/{uid}/security-token with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs
evidence_needed: own account JWT → 200 on GET /v1/organization/<foreign-uid>/security-token; POST mints token valid on /v1/device
verify_steps: AUTH_HELPED: baseline GET /v1/organization/<own>/security-token = 200; foreign UID → 200 = cross-tenant mint; POST {"name":"poc"} → validate minted token with X-Auth: <token> on /v1/device
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated /status topology leak with zero security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live GET returns JSON with pod hostname, process UID, Node v20.20.2, full Redis/MongoDB/AMQP topology; headers show ONLY x-powered-by: Express — no HSTS, x-frame-options, x-content-type-options, CSP; api.status now hardened with all three
evidence_needed: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' returns zero matches
verify_steps: PASSIVE: curl -sD- https://box.signageos.io/status (confirm data + header deficit)
impact: Infrastructure topology + process identity exposed unauthenticated; aids reconnaissance for chained attacks; MEDIUM
testability: PASSIVE
[PARKED] Cross-tenant org OAuth client-secret disclosure via account JWT: requires AUTH_HELPED (valid account JWT + foreign org UID), off-phase for passive-first POC cycle
[PARKED] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid: requires AUTH_HELPED (valid account JWT + foreign org UID), off-phase for passive-first POC cycle
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] HUMAN: authorized-token test for Cross-tenant org OAuth client-secret disclosure — obtain valid account JWT via `sos login`, enumerate own org UID via /v1/organization (self), then test GET /v1/organization/<foreign-org-uid> with X-Auth: <accountJWT> to verify cross-tenant secret disclosure
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 403).
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all entry requires tenant/authenticated session.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59 distinct origins with triplicated Auth0 oauth/token on /login/
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but now hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-08 22:17:35 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.5, attack=8 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — getOrganization() sends GET /v1/organization/{uid} with X-Auth: <accountJWT>; response includes oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}/security-token
confidence: 70
reasoning: OrganizationTokenManagement.ts code-verified — GET list + POST {"name":...} against organization/{uid}/security-token with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs
evidence_needed: own account JWT → 200 on GET /v1/organization/<foreign-uid>/security-token; POST mints token valid on /v1/device
verify_steps: AUTH_HELPED: baseline GET /v1/organization/<own>/security-token = 200; foreign UID → 200 = cross-tenant mint; POST {"name":"poc"} → validate minted token with X-Auth: <token> on /v1/device
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated /status topology leak with zero security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live GET returns JSON with pod hostname, process UID, Node v20.20.2, full Redis/MongoDB/AMQP topology; headers show ONLY x-powered-by: Express — no HSTS, x-frame-options, x-content-type-options, CSP; api.status now hardened with all three
evidence_needed: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' returns zero matches
verify_steps: PASSIVE: curl -sD- https://box.signageos.io/status (confirm data + header deficit)
impact: Infrastructure topology + process identity exposed unauthenticated; aids reconnaissance for chained attacks; MEDIUM
testability: PASSIVE
[PARKED] Cross-tenant org OAuth client-secret disclosure via account JWT: requires AUTH_HELPED (valid account JWT + foreign org UID), off-phase for passive-first POC cycle
[PARKED] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid: requires AUTH_HELPED (valid account JWT + foreign org UID), off-phase for passive-first POC cycle
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] PROBE: curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content|content-security' /tmp/poc_status_h.txt && cat /tmp/poc_status_b.json | jq .
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 403).
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all entry requires tenant/authenticated session.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59 distinct origins with triplicated Auth0 oauth/token on /login/
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but now hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-08 22:54:55 UTC [api] (model nemotron3)
[NEW] box.signageos.io/status pod hostname rotated to `box-7c8c876945-chbwh` (Node v20.20.2, UID `db5ae9f2f2545ca6eac15f7ebcc244fd6c66c2abaf90f0fe21`) — K8s rolling deploy, still ONLY `x-powered-by: Express` header
[NEW] api.signageos.io/status pod hostname rotated to `api-6f69db97d5-wpppp` (Node v24.19.0, UID `2730e3d23aad18e08380a26c87ecb53369d27821392ff3476c`) — K8s rolling deploy, security headers (HSTS/xfo/xcto) confirmed present
[CHANGED] box.signageos.io CORS/CSP reconfirmed — 17 static ACAO (incl `http://box.signageos.io` plaintext + `https://*.zdusercontent.com` wildcard + `api.signageos.io`), evil.test NOT reflected, NO `access-control-allow-credentials`, CSP 59+ distinct origins with triplicated Auth0 oauth/token
[PRIO] api.signageos.io/v1/organization/{uid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.5, attack=8 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[PRIO] box.signageos.io/ CORS+CSP, 5.8, attack=6 business=3 tech=7 gate=10 cloud=5 fresh=5
[PRIO] api.signageos.io/status, 5.2, attack=5 business=4 tech=3 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — getOrganization() sends GET /v1/organization/{uid} with X-Auth: <accountJWT>; response includes oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}/security-token
confidence: 70
reasoning: OrganizationTokenManagement.ts code-verified — GET list + POST {"name":...} against organization/{uid}/security-token with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs
evidence_needed: own account JWT → 200 on GET /v1/organization/<foreign-uid>/security-token; POST mints token valid on /v1/device
verify_steps: AUTH_HELPED: baseline GET /v1/organization/<own>/security-token = 200; foreign UID → 200 = cross-tenant mint; POST {"name":"poc"} → validate minted token with X-Auth: <token> on /v1/device
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated /status topology leak with zero security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live GET returns JSON with pod hostname, process UID, Node v20.20.2, full Redis/MongoDB/AMQP topology; headers show ONLY x-powered-by: Express — no HSTS, x-frame-options, x-content-type-options, CSP; api.status now hardened with all three
evidence_needed: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' returns zero matches
verify_steps: PASSIVE: curl -sD- https://box.signageos.io/status (confirm data + header deficit)
impact: Infrastructure topology + process identity exposed unauthenticated; aids reconnaissance for chained attacks; MEDIUM
testability: PASSIVE
[PARKED] Cross-tenant org OAuth client-secret disclosure via account JWT: requires AUTH_HELPED (valid account JWT + foreign org UID), off-phase for passive-first POC cycle
[PARKED] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid: requires AUTH_HELPED (valid account JWT + foreign org UID), off-phase for passive-first POC cycle
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] PROBE: curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content|content-security' /tmp/poc_status_h.txt && cat /tmp/poc_status_b.json | jq .
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 403).
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all entry requires tenant/authenticated session.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59 distinct origins with triplicated Auth0 oauth/token on /login/
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but now hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-08 23:21:56 UTC [api] (model nemotron3)
[NEW] box.signageos.io/status pod hostname rotated to `box-7c8c876945-chbwh` (Node v20.20.2, UID `db5ae9f2f2545ca6eac15f7ebcc244fd6c66c2abaf90f0fe21`) — K8s rolling deploy, still ONLY `x-powered-by: Express`
[NEW] api.signageos.io/status pod hostname rotated to `api-6f69db97d5-wpppp` (Node v24.19.0, UID `2730e3d23aad18e08380a26c87ecb53369d27821392ff3476c`) — K8s rolling deploy, security headers (HSTS/xfo/xcto) confirmed present
[CHANGED] box.signageos.io CORS/CSP reconfirmed — 17 static ACAO (incl `http://box.signageos.io` plaintext + `https://*.zdusercontent.com` wildcard + `api.signageos.io`), evil.test NOT reflected, NO `access-control-allow-credentials`, CSP 59+ distinct origins with triplicated Auth0 oauth/token
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] api.signageos.io/v1/organization/{organizationUid}/security-token, 7.5, attack=8 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[PRIO] box.signageos.io/ CORS+CSP, 5.8, attack=6 business=3 tech=7 gate=10 cloud=5 fresh=5
[PRIO] api.signageos.io/status, 5.2, attack=5 business=4 tech=3 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — getOrganization() sends GET /v1/organization/{uid} with X-Auth: <accountJWT>; response includes oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}/security-token
confidence: 70
reasoning: OrganizationTokenManagement.ts code-verified — GET list + POST {"name":...} against organization/{uid}/security-token with client-supplied UID; requester sends org UID only as query param for JWT (not for this endpoint), so path UID + account JWT membership check is the only barrier; account tokens can create multiple orgs per docs
evidence_needed: own account JWT → 200 on GET /v1/organization/<foreign-uid>/security-token; POST mints token valid on /v1/device
verify_steps: AUTH_HELPED: baseline GET /v1/organization/<own>/security-token = 200; foreign UID → 200 = cross-tenant mint; POST {"name":"poc"} → validate minted token with X-Auth: <token> on /v1/device
impact: mint org tokens for any tenant → full foreign-device control (brightness, firmware, content, timing); CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated /status topology leak with zero security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live GET returns JSON with pod hostname, process UID, Node v20.20.2, full Redis/MongoDB/AMQP topology; headers show ONLY x-powered-by: Express — no HSTS, x-frame-options, x-content-type-options, CSP; api.status now hardened with all three
evidence_needed: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' returns zero matches
verify_steps: PASSIVE: curl -sD- https://box.signageos.io/status (confirm data + header deficit)
impact: Infrastructure topology + process identity exposed unauthenticated; aids reconnaissance for chained attacks; MEDIUM
testability: PASSIVE
[PARKED] Cross-tenant org OAuth client-secret disclosure via account JWT: requires AUTH_HELPED (valid account JWT + foreign org UID), off-phase for passive-first POC cycle
[PARKED] Cross-tenant org security-token minting via account JWT + client-supplied organizationUid: requires AUTH_HELPED (valid account JWT + foreign org UID), off-phase for passive-first POC cycle
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] PROBE: curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content|content-security' /tmp/poc_status_h.txt && cat /tmp/poc_status_b.json | jq .
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 403).
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all entry requires tenant/authenticated session.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59 distinct origins with triplicated Auth0 oauth/token on /login/
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but now hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-08 23:53:05 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[PRIO] box.signageos.io/ CORS+CSP, 5.8, attack=6 business=3 tech=7 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — getOrganization() sends GET /v1/organization/{uid} with X-Auth: <accountJWT>; response includes oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated /status topology leak with zero security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live GET returns JSON with pod hostname, process UID, Node v20.20.2, full Redis/MongoDB/AMQP topology; headers show ONLY x-powered-by: Express — no HSTS, x-frame-options, x-content-type-options, CSP; api.status now hardened with all three
evidence_needed: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' returns zero matches
verify_steps: PASSIVE: curl -sD- https://box.signageos.io/status (confirm data + header deficit)
impact: Infrastructure topology + process identity exposed unauthenticated; aids reconnaissance for chained attacks; MEDIUM
testability: PASSIVE
[HYP] Broad static CORS whitelist with http:// variant and zdusercontent wildcard
class: MISCONFIG
asset: box.signageos.io/
confidence: 90
reasoning: 17 static ACAO values incl http://box.signageos.io plaintext + https://*.zdusercontent.com wildcard + api.signageos.io sibling; unchanged under spoofed Origin evil.test; NO access-control-allow-credentials on any box path
evidence_needed: curl -H "Origin: https://evil.test" -sD- https://box.signageos.io/ shows same 17 ACAO without evil.test reflection
verify_steps: PASSIVE: curl -H "Origin: https://evil.test" -sD- https://box.signageos.io/ && curl -sD- https://box.signageos.io/login/ (confirm static whitelist, no credentials flag)
impact: Overly permissive CORS expands postMessage/origin trust boundary; no direct credential theft without credentials flag; LOW-MEDIUM
testability: PASSIVE
[PARKED] Cross-tenant org OAuth client-secret disclosure via account JWT: requires AUTH_HELPED (valid account JWT + foreign org UID), off-phase for passive-first POC cycle
[PARKED] Broad static CORS whitelist with http:// variant and zdusercontent wildcard: class MISCONFIG accepted but LOW-MEDIUM impact, passive reconfirmed, no new POC needed this cycle
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] PROBE: curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content|content-security' /tmp/poc_status_h.txt && cat /tmp/poc_status_b.json | jq .
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 403).
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all entry requires tenant/authenticated session.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59 distinct origins with triplicated Auth0 oauth/token on /login/
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but now hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-09 01:07:02 UTC [api] (model nemotron3)
## 2026-08-09 03:07:55 UTC [api] (model nemotron3)
## 2026-08-09 04:36:09 UTC [api] (model nemotron3)
## 2026-08-09 05:34:54 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/ CORS+CSP, 5.8, attack=6 business=3 tech=7 gate=10 cloud=5 fresh=5
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — getOrganization() sends GET /v1/organization/{uid} with X-Auth: <accountJWT>; response includes oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated /status topology leak with zero security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live GET returns JSON with pod hostname, process UID, Node v20.20.2, full Redis/MongoDB/AMQP topology; headers show ONLY x-powered-by: Express — no HSTS, x-frame-options, x-content-type-options, CSP; api.status now hardened with all three
evidence_needed: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' returns zero matches
verify_steps: PASSIVE: curl -sD- https://box.signageos.io/status (confirm data + header deficit)
impact: Infrastructure topology + process identity exposed unauthenticated; aids reconnaissance for chained attacks; MEDIUM
testability: PASSIVE
[HYP] Broad static CORS whitelist with http:// variant and zdusercontent wildcard
class: MISCONFIG
asset: box.signageos.io/
confidence: 90
reasoning: 17 static ACAO values incl http://box.signageos.io plaintext + https://*.zdusercontent.com wildcard + api.signageos.io sibling; unchanged under spoofed Origin evil.test; NO access-control-allow-credentials on any box path
evidence_needed: curl -H "Origin: https://evil.test" -sD- https://box.signageos.io/ shows same 17 ACAO without evil.test reflection
verify_steps: PASSIVE: curl -H "Origin: https://evil.test" -sD- https://box.signageos.io/ && curl -sD- https://box.signageos.io/login/ (confirm static whitelist, no credentials flag)
impact: Overly permissive CORS expands postMessage/origin trust boundary; no direct credential theft without credentials flag; LOW-MEDIUM
testability: PASSIVE
[PARKED] Cross-tenant org OAuth client-secret disclosure via account JWT: requires AUTH_HELPED (valid account JWT + foreign org UID), off-phase for passive-first POC cycle
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] PROBE: curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content|content-security' /tmp/poc_status_h.txt && cat /tmp/poc_status_b.json | jq .
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 403).
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all entry requires tenant/authenticated session.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59 distinct origins with triplicated Auth0 oauth/token on /login/
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but now hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-09 06:26:17 UTC [api] (model nemotron3)
## 2026-08-09 07:34:39 UTC [api] (model nemotron3)
## 2026-08-09 08:22:24 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/ CORS+CSP, 5.8, attack=6 business=3 tech=7 gate=10 cloud=5 fresh=5
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[PRIO] api.signageos.io/status, 5.4, attack=5 business=4 tech=4 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — getOrganization() sends GET /v1/organization/{uid} with X-Auth: <accountJWT>; response includes oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated /status topology leak with zero security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live GET returns JSON with pod hostname, process UID, Node v20.20.2, full Redis/MongoDB/AMQP topology; headers show ONLY x-powered-by: Express — no HSTS, x-frame-options, x-content-type-options, CSP; api.status now hardened with all three
evidence_needed: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' returns zero matches
verify_steps: PASSIVE: curl -sD- https://box.signageos.io/status (confirm data + header deficit)
impact: Infrastructure topology + process identity exposed unauthenticated; aids reconnaissance for chained attacks; MEDIUM
testability: PASSIVE
[HYP] Broad static CORS whitelist with http:// variant and zdusercontent wildcard
class: MISCONFIG
asset: box.signageos.io/
confidence: 90
reasoning: 17 static ACAO values incl http://box.signageos.io plaintext + https://*.zdusercontent.com wildcard + api.signageos.io sibling; unchanged under spoofed Origin evil.test; NO access-control-allow-credentials on any box path
evidence_needed: curl -H "Origin: https://evil.test" -sD- https://box.signageos.io/ shows same 17 ACAO without evil.test reflection
verify_steps: PASSIVE: curl -H "Origin: https://evil.test" -sD- https://box.signageos.io/ && curl -sD- https://box.signageos.io/login/ (confirm static whitelist, no credentials flag)
impact: Overly permissive CORS expands postMessage/origin trust boundary; no direct credential theft without credentials flag; LOW-MEDIUM
testability: PASSIVE
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] PROBE: curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content|content-security' /tmp/poc_status_h.txt && cat /tmp/poc_status_b.json | jq .
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 403).
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all entry requires tenant/authenticated session.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59 distinct origins with triplicated Auth0 oauth/token on /login/
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but now hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-09 09:11:44 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/ CORS+CSP, 5.8, attack=6 business=3 tech=7 gate=10 cloud=5 fresh=5
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[PRIO] api.signageos.io/status, 5.4, attack=5 business=4 tech=4 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — getOrganization() sends GET /v1/organization/{uid} with X-Auth: <accountJWT>; response includes oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Broad static CORS whitelist with http:// variant and zdusercontent wildcard
class: MISCONFIG
asset: box.signageos.io/
confidence: 90
reasoning: 17 static ACAO values incl http://box.signageos.io plaintext + https://*.zdusercontent.com wildcard + api.signageos.io sibling; unchanged under spoofed Origin evil.test; NO access-control-allow-credentials on any box path
evidence_needed: curl -H "Origin: https://evil.test" -sD- https://box.signageos.io/ shows same 17 ACAO without evil.test reflection
verify_steps: PASSIVE: curl -H "Origin: https://evil.test" -sD- https://box.signageos.io/ && curl -sD- https://box.signageos.io/login/ (confirm static whitelist, no credentials flag)
impact: Overly permissive CORS expands postMessage/origin trust boundary; no direct credential theft without credentials flag; LOW-MEDIUM
testability: PASSIVE
[HYP] Unauthenticated /status topology leak with zero security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live GET returns JSON with pod hostname, process UID, Node v20.20.2, full Redis/MongoDB/AMQP topology; headers show ONLY x-powered-by: Express — no HSTS, x-frame-options, x-content-type-options, CSP; api.status now hardened with all three
evidence_needed: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' returns zero matches
verify_steps: PASSIVE: curl -sD- https://box.signageos.io/status (confirm data + header deficit)
impact: Infrastructure topology + process identity exposed unauthenticated; aids reconnaissance for chained attacks; MEDIUM
testability: PASSIVE
[PARKED] Cross-tenant org OAuth client-secret disclosure via account JWT: requires AUTH_HELPED (valid account JWT + foreign org UID), off-phase for passive-first POC cycle; no second tenant available for verification
[FINAL] Ranked surviving hypotheses (top first):
[NEXT] PROBE: curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content|content-security' /tmp/poc_status_h.txt && cat /tmp/poc_status_b.json | jq .
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 403).
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all entry requires tenant/authenticated session.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59 distinct origins with triplicated Auth0 oauth/token on /login/
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but now hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-09 09:58:35 UTC [api] (model nemotron3)
## 2026-08-09 10:42:19 UTC [api] (model nemotron3)
## 2026-08-09 11:13:41 UTC [api] (model nemotron3)
## 2026-08-09 11:49:02 UTC [api] (model nemotron3)
## 2026-08-09 12:19:55 UTC [api] (model nemotron3)
## 2026-08-09 13:28:25 UTC [api] (model nemotron3)
## 2026-08-09 14:09:56 UTC [api] (model nemotron3)
## 2026-08-09 14:54:38 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[PRIO] box.signageos.io/ CORS+CSP, 5.8, attack=6 business=3 tech=7 gate=10 cloud=5 fresh=5
[PRIO] api.signageos.io/status, 5.4, attack=5 business=4 tech=4 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — getOrganization() sends GET /v1/organization/{uid} with X-Auth: <accountJWT>; response includes oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated /status topology leak with zero security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live GET returns JSON with pod hostname, process UID, Node v20.20.2, full Redis/MongoDB/AMQP topology; headers show ONLY x-powered-by: Express — no HSTS, x-frame-options, x-content-type-options, CSP; api.status now hardened with all three
evidence_needed: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' returns zero matches
verify_steps: PASSIVE: curl -sD- https://box.signageos.io/status (confirm data + header deficit)
impact: Infrastructure topology + process identity exposed unauthenticated; aids reconnaissance for chained attacks; MEDIUM
testability: PASSIVE
[HYP] Broad static CORS whitelist with http:// variant and zdusercontent wildcard
class: MISCONFIG
asset: box.signageos.io/
confidence: 90
reasoning: 17 static ACAO values incl http://box.signageos.io plaintext + https://*.zdusercontent.com wildcard + api.signageos.io sibling; unchanged under spoofed Origin evil.test; NO access-control-allow-credentials on any box path
evidence_needed: curl -H "Origin: https://evil.test" -sD- https://box.signageos.io/ shows same 17 ACAO without evil.test reflection
verify_steps: PASSIVE: curl -H "Origin: https://evil.test" -sD- https://box.signageos.io/ && curl -sD- https://box.signageos.io/login/ (confirm static whitelist, no credentials flag)
impact: Overly permissive CORS expands postMessage/origin trust boundary; no direct credential theft without credentials flag; LOW-MEDIUM
testability: PASSIVE
[FINAL] Surviving hypotheses (ranked):
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 with oauthClientSecret; 3) repeat with a foreign org UID → if 200 + oauthClientSecret = cross-tenant IDOR confirmed.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 403).
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all entry requires tenant/authenticated session.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59 distinct origins with triplicated Auth0 oauth/token on /login/
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but now hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-09 15:30:29 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[PRIO] box.signageos.io/ CORS+CSP, 5.8, attack=6 business=3 tech=7 gate=10 cloud=5 fresh=5
[PRIO] api.signageos.io/status, 5.4, attack=5 business=4 tech=4 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — getOrganization() sends GET /v1/organization/{uid} with X-Auth: <accountJWT>; response includes oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated /status topology leak with zero security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live GET returns JSON with pod hostname, process UID, Node v20.20.2, full Redis/MongoDB/AMQP topology; headers show ONLY x-powered-by: Express — no HSTS, x-frame-options, x-content-type-options, CSP; api.status now hardened with all three
evidence_needed: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' returns zero matches
verify_steps: PASSIVE: curl -sD- https://box.signageos.io/status (confirm data + header deficit)
impact: Infrastructure topology + process identity exposed unauthenticated; aids reconnaissance for chained attacks; MEDIUM
testability: PASSIVE
[HYP] Broad static CORS whitelist with http:// variant and zdusercontent wildcard
class: MISCONFIG
asset: box.signageos.io/
confidence: 90
reasoning: 17 static ACAO values incl http://box.signageos.io plaintext + https://*.zdusercontent.com wildcard + api.signageos.io sibling; unchanged under spoofed Origin evil.test; NO access-control-allow-credentials on any box path
evidence_needed: curl -H "Origin: https://evil.test" -sD- https://box.signageos.io/ shows same 17 ACAO without evil.test reflection
verify_steps: PASSIVE: curl -H "Origin: https://evil.test" -sD- https://box.signageos.io/ && curl -sD- https://box.signageos.io/login/ (confirm static whitelist, no credentials flag)
impact: Overly permissive CORS expands postMessage/origin trust boundary; no direct credential theft without credentials flag; LOW-MEDIUM
testability: PASSIVE
[PARKED] Cross-tenant org OAuth client-secret disclosure via account JWT: confidence 75 but class IDOR on api.signageos.io requires AUTH_HELPED (valid account JWT + foreign org UID) — off-phase for current passive-only cycle; no passive verify_steps exist
[FINAL] Surviving hypotheses (ranked):
[NEXT] PROBE: curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content|content-security' /tmp/poc_status_h.txt && cat /tmp/poc_status_b.json | jq .
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 403).
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all entry requires tenant/authenticated session.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59 distinct origins with triplicated Auth0 oauth/token on /login/
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but now hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-09 16:03:15 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/ CORS+CSP, 5.8, attack=6 business=3 tech=7 gate=10 cloud=5 fresh=5
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[PRIO] api.signageos.io/status, 5.4, attack=5 business=4 tech=4 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — getOrganization() sends GET /v1/organization/{uid} with X-Auth: <accountJWT>; response includes oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Broad static CORS whitelist with http:// variant and zdusercontent wildcard
class: MISCONFIG
asset: box.signageos.io/
confidence: 90
reasoning: 17 static ACAO values incl http://box.signageos.io plaintext + https://*.zdusercontent.com wildcard + api.signageos.io sibling; unchanged under spoofed Origin evil.test; NO access-control-allow-credentials on any box path
evidence_needed: curl -H "Origin: https://evil.test" -sD- https://box.signageos.io/ shows same 17 ACAO without evil.test reflection
verify_steps: PASSIVE: curl -H "Origin: https://evil.test" -sD- https://box.signageos.io/ && curl -sD- https://box.signageos.io/login/ (confirm static whitelist, no credentials flag)
impact: Overly permissive CORS expands postMessage/origin trust boundary; no direct credential theft without credentials flag; LOW-MEDIUM
testability: PASSIVE
[HYP] Unauthenticated /status topology leak with zero security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live GET returns JSON with pod hostname, process UID, Node v20.20.2, full Redis/MongoDB/AMQP topology; headers show ONLY x-powered-by: Express — no HSTS, x-frame-options, x-content-type-options, CSP; api.status now hardened with all three
evidence_needed: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' returns zero matches
verify_steps: PASSIVE: curl -sD- https://box.signageos.io/status (confirm data + header deficit)
impact: Infrastructure topology + process identity exposed unauthenticated; aids reconnaissance for chained attacks; MEDIUM
testability: PASSIVE
[FINAL] Surviving hypotheses (ranked):
[NEXT] PROBE: curl -s --max-time 20 https://box.signageos.io/status -o /tmp/poc_status_b.json -D /tmp/poc_status_h.txt && grep -icE 'strict-transport|x-frame|x-content|content-security' /tmp/poc_status_h.txt && cat /tmp/poc_status_b.json | jq .
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 403).
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all entry requires tenant/authenticated session.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59 distinct origins with triplicated Auth0 oauth/token on /login/
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but now hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-09 16:51:25 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/, 5.8, attack=6 business=3 tech=7 gate=10 cloud=5 fresh=5
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[PRIO] api.signageos.io/status, 5.4, attack=5 business=4 tech=4 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — getOrganization() sends GET /v1/organization/{uid} with X-Auth: <accountJWT>; response includes oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID (credential-derived), so server-side account∈company→org membership check on path UID is the sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Broad static CORS whitelist with http:// variant and zdusercontent wildcard
class: MISCONFIG
asset: box.signageos.io/
confidence: 90
reasoning: 17 static ACAO values incl http://box.signageos.io plaintext + https://*.zdusercontent.com wildcard + api.signageos.io sibling; unchanged under spoofed Origin evil.test; NO access-control-allow-credentials on any box path
evidence_needed: curl -H "Origin: https://evil.test" -sD- https://box.signageos.io/ shows same 17 ACAO without evil.test reflection
verify_steps: PASSIVE: curl -H "Origin: https://evil.test" -sD- https://box.signageos.io/ && curl -sD- https://box.signageos.io/login/ (confirm static whitelist, no credentials flag)
impact: Overly permissive CORS expands postMessage/origin trust boundary; no direct credential theft without credentials flag; LOW-MEDIUM
testability: PASSIVE
[HYP] Unauthenticated /status topology leak with zero security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live GET returns JSON with pod hostname, process UID, Node v20.20.2, full Redis/MongoDB/AMQP topology; headers show ONLY x-powered-by: Express — no HSTS, x-frame-options, x-content-type-options, CSP; api.status now hardened with all three
evidence_needed: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' returns zero matches
verify_steps: PASSIVE: curl -sD- https://box.signageos.io/status (confirm data + header deficit)
impact: Infrastructure topology + process identity exposed unauthenticated; aids reconnaissance for chained attacks; MEDIUM
testability: PASSIVE
[FINAL] Surviving hypotheses (ranked):
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → 200; 3) repeat with a foreign org UID (from sandbox/invite or second tenant) → observe 200 + oauthClientSecret = cross-tenant IDOR confirmed
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v2/device: Returns 403 JWT-gated (was 404) — now JWT-gated, not a pre-auth bypass
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. v2 migration advancing (/v2/device now 403).
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 state/redirect_uri binding — not passively testable, no unauthenticated authn surf remaining on box; all entry requires tenant/authenticated session.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59 distinct origins with triplicated Auth0 oauth/token on /login/
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but now hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting, peer-recovery) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-09 17:21:00 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 8.1, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=8
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST /v1/organization/{uid}/security-token with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID (credential-derived), so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — GET /v1/organization/{uid} with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated /status topology leak with zero security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live GET returns JSON with pod hostname, process UID, Node v20.20.2, full Redis/MongoDB/AMQP topology; headers show ONLY x-powered-by: Express — no HSTS, x-frame-options, x-content-type-options, CSP; api.status now hardened with all three
evidence_needed: curl -sD- https://box.signageos.io/status | grep -iE 'strict-transport|x-frame|x-content|content-security' returns zero matches
verify_steps: PASSIVE: curl -sD- https://box.signageos.io/status (confirm data + header deficit)
impact: Infrastructure topology + process identity exposed unauthenticated; aids reconnaissance for chained attacks; MEDIUM
testability: PASSIVE
[PARKED] Unauthenticated /status topology leak with zero security headers: already ACCEPTED at 95 confidence with live POC; not a new hypothesis for POC phase targeting api
[FINAL] Surviving hypotheses (ranked):
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → 200; 3) repeat with a foreign org UID (from sandbox/invite or second tenant) → observe 200 + oauthClientSecret = cross-tenant IDOR confirmed; 4) if step 3 succeeds, test POST /v1/organization/<foreign-org-uid>/security-token with same JWT → securityToken minting.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed hardened — HSTS/xfo/xcto present, differential vs box persists
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: class stable (WRONG_JWT_TOKEN/403075/403076/403105) — excluded per scope.yml
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-09 17:55:11 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 8.1, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=8
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST /v1/organization/{uid}/security-token with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID (credential-derived), so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — GET /v1/organization/{uid} with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[PARKED] Unauthenticated /status topology leak with zero security headers: already ACCEPTED at 95 confidence with live POC; not a new hypothesis for POC phase targeting api
[FINAL] Surviving hypotheses (ranked):
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → 200; 3) repeat with a foreign org UID (from sandbox/invite or second tenant) → observe 200 + oauthClientSecret = cross-tenant IDOR confirmed; 4) if step 3 succeeds, test POST /v1/organization/<foreign-org-uid>/security-token with same JWT → securityToken minting.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed hardened — HSTS/xfo/xcto present, differential vs box persists
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: class stable (WRONG_JWT_TOKEN/403075/403076/403105) — excluded per scope.yml
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-09 18:38:22 UTC [api] (model nemotron3)
## 2026-08-09 19:21:55 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 8.1, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=8
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST /v1/organization/{uid}/security-token with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID (credential-derived), so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — GET /v1/organization/{uid} with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[FINAL] Surviving hypotheses (ranked):
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → 200; 3) repeat with a foreign org UID (from sandbox/invite or second tenant) → observe 200 + oauthClientSecret = cross-tenant IDOR confirmed; 4) if step 3 succeeds, test POST /v1/organization/<foreign-org-uid>/security-token with same JWT → securityToken minting.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (40+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-09 19:55:21 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 8.1, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=8
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST /v1/organization/{uid}/security-token with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID (credential-derived), so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — GET /v1/organization/{uid} with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[PARKED] box.signageos.io/status info-leak: already ACCEPTED at 95 confidence with live POC; not a new hypothesis for POC phase targeting api
[FINAL] Surviving hypotheses (ranked):
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → 200; 3) repeat with a foreign org UID (from sandbox/invite or second tenant) → observe 200 + oauthClientSecret = cross-tenant IDOR confirmed; 4) if step 3 succeeds, test POST /v1/organization/<foreign-org-uid>/security-token with same JWT → securityToken minting.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-09 20:32:34 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 8.1, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=8
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[PRIO] box.signageos.io/login/, 5.3, attack=6 business=3 tech=4 gate=10 cloud=4 fresh=4
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST /v1/organization/{uid}/security-token with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID (credential-derived), so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — GET /v1/organization/{uid} with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[FINAL] Surviving hypotheses (ranked):
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → 200; 3) repeat with a foreign org UID (from sandbox/invite or second tenant) → observe 200 + oauthClientSecret = cross-tenant IDOR confirmed; 4) if step 3 succeeds, test POST /v1/organization/<foreign-org-uid>/security-token with same JWT → securityToken minting.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59 distinct origins with triplicated Auth0 oauth/token on /login/
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-09 21:09:24 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.9, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=8
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST /v1/organization/{uid}/security-token with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — GET /v1/organization/{uid} with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[FINAL] Surviving hypotheses (ranked):
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → 200; 3) repeat with a foreign org UID (from sandbox/invite or second tenant) → observe 200 + oauthClientSecret = cross-tenant IDOR confirmed; 4) if step 3 succeeds, test POST /v1/organization/<foreign-org-uid>/security-token with same JWT → securityToken minting.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59 distinct origins with triplicated Auth0 oauth/token on /login/
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-09 21:47:33 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.9, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=8
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST /v1/organization/{uid}/security-token with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — GET /v1/organization/{uid} with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[FINAL] Surviving hypotheses (ranked):
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → 200; 3) repeat with a foreign org UID (from sandbox/invite or second tenant) → observe 200 + oauthClientSecret = cross-tenant IDOR confirmed; 4) if step 3 succeeds, test POST /v1/organization/<foreign-org-uid>/security-token with same JWT → securityToken minting.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59 distinct origins with triplicated Auth0 oauth/token on /login/
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-09 22:15:43 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.9, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=8
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST /v1/organization/{uid}/security-token with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — GET /v1/organization/{uid} with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[FINAL] Surviving hypotheses (ranked):
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → 200; 3) repeat with a foreign org UID (from sandbox/invite or second tenant) → observe 200 + oauthClientSecret = cross-tenant IDOR confirmed; 4) if step 3 succeeds, test POST /v1/organization/<foreign-org-uid>/security-token with same JWT → securityToken minting.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59 distinct origins with triplicated Auth0 oauth/token on /login/
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-09 22:55:40 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.9, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=8
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.8, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.5, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST /v1/organization/{uid}/security-token with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — GET /v1/organization/{uid} with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[FINAL] Surviving hypotheses (ranked):
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → 200; 3) repeat with a foreign org UID (from sandbox/invite or second tenant) → observe 200 + oauthClientSecret = cross-tenant IDOR confirmed; 4) if step 3 succeeds, test POST /v1/organization/<foreign-org-uid>/security-token with same JWT → securityToken minting.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59 distinct origins with triplicated Auth0 oauth/token on /login/
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-09 23:33:00 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.85, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=8
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.75, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.45, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST /v1/organization/{uid}/security-token with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — GET /v1/organization/{uid} with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[FINAL] Surviving hypotheses (ranked):
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → 200; 3) repeat with a foreign org UID (from sandbox/invite or second tenant) → observe 200 + oauthClientSecret = cross-tenant IDOR confirmed; 4) if step 3 succeeds, test POST /v1/organization/<foreign-org-uid>/security-token with same JWT → securityToken minting.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59 distinct origins with triplicated Auth0 oauth/token on /login/
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-10 00:04:13 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.85, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=8
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.75, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.45, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST /v1/organization/{uid}/security-token with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — GET /v1/organization/{uid} with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[FINAL] Surviving hypotheses (ranked):
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → 200; 3) repeat with a foreign org UID (from sandbox/invite or second tenant) → observe 200 + oauthClientSecret = cross-tenant IDOR confirmed; 4) if step 3 succeeds, test POST /v1/organization/<foreign-org-uid>/security-token with same JWT → securityToken minting.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59 distinct origins with triplicated Auth0 oauth/token on /login/
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-10 02:31:00 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.85, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=8
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.75, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.45, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[PRIO] box.signageos.io/login/, 4.80, attack=5 business=3 tech=6 gate=10 cloud=4 fresh=4
[PRIO] api.signageos.io/status, 4.65, attack=5 business=3 tech=4 gate=10 cloud=5 fresh=4
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST /v1/organization/{uid}/security-token with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — GET /v1/organization/{uid} with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[FINAL] Surviving hypotheses (ranked):
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → 200; 3) repeat with a foreign org UID (from sandbox/invite or second tenant) → observe 200 + oauthClientSecret = cross-tenant IDOR confirmed; 4) if step 3 succeeds, test POST /v1/organization/<foreign-org-uid>/security-token with same JWT → securityToken minting.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Now hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/login/ & / CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59 distinct origins with triplicated Auth0 oauth/token on /login/
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins). Still missing HSTS/xfo/xcto on /status.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto; 60+ /v1/*+/v2/* endpoints all solidly JWT-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-10 04:19:16 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.85, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=8
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.75, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.45, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[PRIO] box.signageos.io/ & /login/ CORS+CSP, 5.20, attack=5 business=3 tech=6 gate=10 cloud=4 fresh=4
[CHANGED] box.signageos.io/status now fronted by CloudFront (x-cache, via, x-amz-cf-pop headers added) — body unchanged, still zero security headers (no HSTS/xfo/xcto/CSP)
[CHANGED] box.signageos.io/ and /login/ now served via CloudFront with full hardening headers (HSTS max-age=63072000; includeSubDomains; preload, xfo:DENY, xcto:nosniff, CSP) — differential vs /status persists
[NEW] api.signageos.io/status now also fronted by CloudFront (x-cache, via, x-amz-cf-pop) — retains HSTS/xfo/xcto hardening
[PARKED] Cross-tenant security-token minting via X-Auth org UID override: confidence 78 but testability AUTH_HELPED requires human sos login + foreign org UID — not passively verifiable in current phase
[PARKED] Cross-tenant org OAuth client-secret disclosure via account JWT: confidence 75 but testability AUTH_HELPED requires human sos login + foreign org UID — not passively verifiable in current phase
[FINAL] Surviving hypotheses (ranked):
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST /v1/organization/{uid}/security-token with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — GET /v1/organization/{uid} with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express + CloudFront — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/
[LEARN] CHANGED box.signageos.io/status: Now fronted by CloudFront (x-cache, via, x-amz-cf-pop) — routing change only, body and header security posture unchanged
[LEARN] CHANGED box.signageos.io/ & /login/: Now fronted by CloudFront with full hardening headers (HSTS/xfo/xcto/CSP) — differential vs /status confirmed
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → 200; 3) repeat with a foreign org UID (from sandbox/invite or second tenant) → observe 200 + oauthClientSecret = cross-tenant IDOR confirmed; 4) if step 3 succeeds, test POST /v1/organization/<foreign-org-uid>/security-token with same JWT → securityToken minting
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-10 05:52:21 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.85, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=8
[PRIO] api.signageos.io/v1/organization/{organizationUid}, 7.75, attack=9 business=10 tech=8 gate=2 cloud=8 fresh=7
[PRIO] box.signageos.io/status, 5.45, attack=6 business=4 tech=3 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST /v1/organization/{uid}/security-token with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid}
confidence: 75
reasoning: SDK/CLI code-verified — GET /v1/organization/{uid} with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[FINAL] Surviving hypotheses (ranked):
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → 200; 3) repeat with a foreign org UID (from sandbox/invite or second tenant) → observe 200 + oauthClientSecret = cross-tenant IDOR confirmed; 4) if step 3 succeeds, test POST /v1/organization/<foreign-org-uid>/security-token with same JWT → securityToken minting
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express + CloudFront — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/
[LEARN] CHANGED box.signageos.io/status: Now fronted by CloudFront (x-cache, via, x-amz-cf-pop) — routing change only, body and header security posture unchanged
[LEARN] CHANGED box.signageos.io/ & /login/: Now fronted by CloudFront with full hardening headers (HSTS/xfo/xcto/CSP) — differential vs /status confirmed
[LEARN] NEW api.signageos.io/status now also fronted by CloudFront (x-cache, via, x-amz-cf-pop) — retains HSTS/xfo/xcto hardening
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-10 07:11:35 UTC [api] (model nemotron3)
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
class: MISCONFIG
asset: box.signageos.io/ & /login/
confidence: 90
reasoning: 17 static ACAO values including http://box.signageos.io plaintext + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/
evidence_needed: curl -I -H "Origin: https://evil.test" shows static ACAO set unchanged; no credentials flag
verify_steps: PASSIVE: HEAD -H "Origin: https://evil.test" → confirm evil.test not in ACAO; grep access-control-allow-credentials = 0; count distinct ACAO = 17
impact: expands postMessage/origin trust boundary; no direct credential theft without credentials flag; MEDIUM if combined with XSS on trusted origin
testability: PASSIVE
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST /v1/organization/{uid}/security-token with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
## 2026-08-10 08:56:42 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.8, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.8, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] box.signageos.io/status, 6.85, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=5
[PRIO] box.signageos.io/ & /login/ (CORS/CSP), 5.95, attack=6 business=4 tech=7 gate=10 cloud=5 fresh=4
[PRIO] api.signageos.io/status, 5.5, attack=5 business=4 tech=5 gate=10 cloud=6 fresh=4
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST /v1/organization/{uid}/security-token with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET /v1/organization/{uid} with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied path arg; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → 200; 3) repeat with a foreign org UID (from sandbox/invite or second tenant) → observe 200 + oauthClientSecret = cross-tenant IDOR confirmed; 4) if step 3 succeeds, test POST /v1/organization/<foreign-org-uid>/security-token with same JWT → securityToken minting
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express + CloudFront — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (x-cache, via, x-amz-cf-pop)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/
[LEARN] CHANGED box.signageos.io/status: Now fronted by CloudFront (x-cache, via, x-amz-cf-pop) — routing change only, body and header security posture unchanged
[LEARN] CHANGED box.signageos.io/ & /login/: Now fronted by CloudFront with full hardening headers (HSTS/xfo/xcto/CSP) — differential vs /status confirmed
[LEARN] NEW api.signageos.io/status now also fronted by CloudFront (x-cache, via, x-amz-cf-pop) — retains HSTS/xfo/xcto hardening
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-10 10:10:34 UTC [api] (model nemotron3)
## 2026-08-10 11:30:55 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] box.signageos.io/status, 6.85, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=5
[PRIO] box.signageos.io/ & /login/ (CORS/CSP), 5.95, attack=6 business=4 tech=7 gate=10 cloud=5 fresh=4
[PRIO] api.signageos.io/status, 5.50, attack=5 business=4 tech=5 gate=10 cloud=6 fresh=4
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[PARKED] Cross-tenant security-token minting via X-Auth org UID override: confidence 78 but testability AUTH_HELPED (requires valid account JWT + foreign org UID) — off-phase for current passive-only cycle; not dropped, parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: confidence 75 but testability AUTH_HELPED — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] HUMAN: Execute standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → 200; 3) repeat with foreign org UID (from sandbox/invite or second tenant) → observe 200 + oauthClientSecret = cross-tenant IDOR confirmed; 4) if step 3 succeeds, test POST /v1/organization/<foreign-org-uid>/security-token with same JWT → securityToken minting
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express + CloudFront — zero hardening headers
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (x-cache, via, x-amz-cf-pop)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/
[LEARN] CHANGED box.signageos.io/status: Now fronted by CloudFront (x-cache, via, x-amz-cf-pop) — routing change only, body and header security posture unchanged
[LEARN] CHANGED box.signageos.io/ & /login/: Now fronted by CloudFront with full hardening headers (HSTS/xfo/xcto/CSP) — differential vs /status confirmed
[LEARN] NEW api.signageos.io/status now also fronted by CloudFront (x-cache, via, x-amz-cf-pop) — retains HSTS/xfo/xcto hardening
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 18 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-10 12:17:20 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] box.signageos.io/status, 6.85, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=5
[PRIO] box.signageos.io/ & /login/ (CORS/CSP), 5.95, attack=6 business=4 tech=7 gate=10 cloud=5 fresh=4
[PRIO] api.signageos.io/status, 5.50, attack=5 business=4 tech=5 gate=10 cloud=6 fresh=4
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[PARKED] Cross-tenant security-token minting via X-Auth org UID override: confidence 78 but testability AUTH_HELPED (requires valid account JWT + foreign org UID) — off-phase for current passive-only cycle; not dropped, parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: confidence 75 but testability AUTH_HELPED — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] HUMAN: Execute standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → 200; 3) repeat with foreign org UID (from sandbox/invite or second tenant) → observe 200 + oauthClientSecret = cross-tenant IDOR confirmed; 4) if step 3 succeeds, test POST /v1/organization/<foreign-org-uid>/security-token with same JWT → securityToken minting
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express + CloudFront — zero hardening headers (reconfirmed 30+ cycles)
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-10 13:50:53 UTC [api] (model nemotron3)
[PRIO] box.signageos.io/status, 6.85, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=5
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[PARKED] Cross-tenant security-token minting via X-Auth org UID override: confidence 78 but testability AUTH_HELPED (requires valid account JWT + foreign org UID) — off-phase for current passive-only cycle; not dropped, parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: confidence 75 but testability AUTH_HELPED — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] PROBE: Finalize box /status PoC evidence package — `curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_status_b.txt && curl -sD /tmp/poc_api_status_h.txt --max-time 20 https://api.signageos.io/status -o /tmp/poc_api_status_b.txt && diff -u /tmp/poc_box_status_h.txt /tmp/poc_api_status_h.txt`
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express + CloudFront — zero hardening headers (reconfirmed 30+ cycles)
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-10 14:47:01 UTC [api] (model nemotron3)
## 2026-08-10 15:46:33 UTC [api] (model nemotron3)
## 2026-08-10 16:39:06 UTC [api] (model nemotron3)
## 2026-08-10 17:37:26 UTC [api] (model nemotron3)
## 2026-08-10 18:32:35 UTC [api] (model nemotron3)
## 2026-08-10 19:38:00 UTC [api] (model nemotron3)
## 2026-08-10 20:23:11 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] box.signageos.io/status, 6.85, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=5
[PRIO] box.signageos.io/ & /login/ CORS+CSP, 5.75, attack=6 business=4 tech=5 gate=10 cloud=5 fresh=5
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[PARKED] Cross-tenant security-token minting via X-Auth org UID override: confidence 78 but testability AUTH_HELPED (requires valid account JWT + foreign org UID) — off-phase for current passive-only cycle; not dropped, parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: confidence 75 but testability AUTH_HELPED — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] PROBE: Finalize box /status PoC evidence package — `curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_status_b.txt && curl -sD /tmp/poc_api_status_h.txt --max-time 20 https://api.signageos.io/status -o /tmp/poc_api_status_b.txt && diff -u /tmp/poc_box_status_h.txt /tmp/poc_api_status_h.txt`
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express + CloudFront — zero hardening headers (reconfirmed 30+ cycles)
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-10 21:13:35 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] box.signageos.io/status, 6.85, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=5
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[PARKED] Cross-tenant security-token minting via X-Auth org UID override: AUTH_HELPED testability requires valid account JWT + foreign org UID — off-phase for current passive-only cycle; not dropped, parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: AUTH_HELPED testability requires valid account JWT + foreign org UID — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] HUMAN: Execute standing cross-tenant chain PoC for api target — 1) `sos login` (Auth0 device-code) → account JWT; 2) baseline `curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token` → expect 200; 3) repeat with foreign-org UID (from recon/intel) → 200 + securityToken = cross-tenant IDOR confirmed; 4) escalate `curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device` → foreign org device list
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Unauthenticated GET leaks pod hostname + 64-hex process.uid + Node v20.20.2 + full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express + CloudFront — zero hardening headers (reconfirmed 30+ cycles)
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-10 22:04:21 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] box.signageos.io/status, 6.85, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=5
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[PARKED] Cross-tenant security-token minting via X-Auth org UID override: AUTH_HELPED testability requires valid account JWT + foreign org UID — off-phase for current passive-only cycle; not dropped, parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: AUTH_HELPED testability requires valid account JWT + foreign org UID — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] HUMAN: Execute standing cross-tenant chain PoC for api target — 1) `sos login` (Auth0 device-code) → account JWT; 2) baseline `curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token` → expect 200; 3) repeat with foreign-org UID (from recon/intel) → 200 + securityToken = cross-tenant IDOR confirmed; 4) escalate `curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device` → foreign org device list
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronted by CloudFront (x-cache/via/x-amz-cf-pop) — routing change only, body/header security posture unchanged
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[LEARN] REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected (static whitelist); NO `access-control-allow-credentials` → no direct credential-theft path. Class stays MISCONFIG-only (broad origin trust boundary, not exploit without creds flag)
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-10 22:55:00 UTC [api] (model nemotron3)
[CHANGED] box.signageos.io/status now fronted by CloudFront (x-cache, via, x-amz-cf-pop headers) — routing change only, body/header security posture unchanged (still zero hardening headers, leaks topology)
[CHANGED] box.signageos.io/ & /login/ now served via CloudFront with full hardening headers (HSTS max-age=63072000; includeSubDomains; preload, xfo:DENY, xcto:nosniff, CSP) — differential vs /status persists
[CHANGED] api.signageos.io/status now also fronted by CloudFront (x-cache, via, x-amz-cf-pop) — retains HSTS+xfo+xcto hardening
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] box.signageos.io/status, 6.85, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=5
[HYP] Cross-tenant security-token minting via X-Auth org UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[PARKED] Cross-tenant security-token minting via X-Auth org UID override: AUTH_HELPED testability requires valid account JWT + foreign org UID — off-phase for current passive-only cycle; not dropped, parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: AUTH_HELPED testability requires valid account JWT + foreign org UID — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] PROBE: Finalize box /status PoC evidence package — `curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_status_b.txt && echo "hardening_headers: $(grep -cE 'strict-transport|x-frame|x-content|content-security' /tmp/poc_box_status_h.txt)" && cat /tmp/poc_box_status_b.txt | jq .`
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronted by CloudFront (x-cache/via/x-amz-cf-pop) — routing change only, body/header security posture unchanged
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[LEARN] REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected (static whitelist); NO `access-control-allow-credentials` → no direct credential-theft path. Class stays MISCONFIG-only (broad origin trust boundary, not exploit without creds flag)
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-10 23:25:39 UTC [api] (model nemotron3)
## 2026-08-11 00:01:54 UTC [api] (model nemotron3)
## 2026-08-11 02:22:54 UTC [api] (model nemotron3)
## 2026-08-11 04:17:18 UTC [api] (model nemotron3)
## 2026-08-11 05:35:30 UTC [api] (model nemotron3)
## 2026-08-11 06:11:12 UTC [api] (model nemotron3)
## 2026-08-11 07:39:03 UTC [api] (model nemotron3)
## 2026-08-11 08:38:11 UTC [api] (model nemotron3)
## 2026-08-11 09:41:39 UTC [api] (model nemotron3)
## 2026-08-11 10:36:10 UTC [api] (model nemotron3)
## 2026-08-11 11:28:42 UTC [api] (model nemotron3)
## 2026-08-11 12:26:33 UTC [api] (model nemotron3)
## 2026-08-11 13:55:55 UTC [api] (model nemotron3)
## 2026-08-11 15:04:29 UTC [api] (model nemotron3)
[NEW] api.signageos.io/status pod rotated to `api-6d67cd6668-vg7c2` (was `api-6f69db97d5-9kg9l`), body sha256 `ba5832802fb18f18844768e92a5d375cc2411c92a2342f193bff4b90eaeb988c`
[NEW] box.signageos.io/status pod rotated to `box-7cd9ddcc8c-t2w7w` (was `box-7cd9ddcc8c-5bnfd`), uid `e2a3b4…4c77bc`, body sha256 `e3d1ae393f652e3b582cdb1ca23a245af3fc240af4856...`
[CHANGED] Edge POP rotated to SFO53-P9 (box) / SFO53-P12 (api) — was PHX52-P1
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] box.signageos.io/status, 6.85, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=5
[HYP] Cross-tenant security-token minting via X-Auth org-UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[PARKED] Cross-tenant security-token minting via X-Auth org-UID override: AUTH_HELPED testability requires valid account JWT + foreign org UID — off-phase for current passive-only cycle; not dropped, parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: AUTH_HELPED testability requires valid account JWT + foreign org UID — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] HUMAN: Cross-tenant security-token test — requires `sos login` (Auth0 device-code) to obtain account JWT, then 1) baseline POST /v1/organization/<own-org-uid>/security-token → 200, 2) repeat with foreign org UID → 200 + securityToken = cross-tenant IDOR, 3) escalate with leaked token to /v1/device → foreign org device list
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronted by CloudFront (x-cache/via/x-amz-cf-pop) — routing change only, body/header security posture unchanged
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[LEARN] REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected (static whitelist); NO `access-control-allow-credentials` → no direct credential-theft path. Class stays MISCONFIG-only (broad origin trust boundary, not exploit without creds flag)
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
[LEARN] REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-11 16:11:33 UTC [api] (model nemotron3)
[NEW] api.signageos.io/status pod rotated to `api-6d67cd6668-vg7c2` (was `api-6f69db97d5-9kg9l`), body sha256 `ba5832802fb18f18844768e92a5d375cc2411c92a2342f193bff4b90eaeb988c`
[NEW] box.signageos.io/status pod rotated to `box-7cd9ddcc8c-t2w7w` (was `box-7cd9ddcc8c-5bnfd`), uid `e2a3b4…4c77bc`, body sha256 `e3d1ae393f652e3b582cdb1ca23a245af3fc240af4856...`
[CHANGED] Edge POP rotated to SFO53-P9 (box) / SFO53-P12 (api) — was PHX52-P1
[CHANGED] box.signageos.io/status pod rotated to `box-7cd9ddcc8c-756mn` (was t2w7w), process.uid `a3a5ce07…6d6d9`, body sha256 `82f3f196…a808` — data/headers unchanged, CloudFront POP SFO53-P6
[CHANGED] box.signageos.io/ root header sha256 now `3ac2f76a…6c15` — nonce hashes rotated, body/CORS/CSP unchanged
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] box.signageos.io/status, 6.85, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=5
[HYP] Cross-tenant security-token minting via X-Auth org-UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[PARKED] Cross-tenant security-token minting via X-Auth org-UID override: AUTH_HELPED testability requires valid account JWT + foreign org UID — off-phase for current passive-only cycle; not dropped, parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: AUTH_HELPED testability requires valid account JWT + foreign org UID — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] HUMAN: Cross-tenant security-token test — requires `sos login` (Auth0 device-code) to obtain account JWT, then 1) baseline POST /v1/organization/<own-org-uid>/security-token → 200, 2) repeat with foreign org UID → 200 + securityToken = cross-tenant IDOR, 3) escalate with leaked token to /v1/device → foreign org device list
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronted by CloudFront (x-cache/via/x-amz-cf-pop) — routing change only, body/header security posture unchanged
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[LEARN] REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected (static whitelist); NO `access-control-allow-credentials` → no direct credential-theft path. Class stays MISCONFIG-only (broad origin trust boundary, not exploit without creds flag)
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
[LEARN] REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-11 17:15:17 UTC [api] (model nemotron3)
[NEW] api.signageos.io/status pod rotated to `api-6d67cd6668-vg7c2` (was `api-6f69db97d5-9kg9l`), body sha256 `ba5832802fb18f18844768e92a5d375cc2411c92a2342f193bff4b90eaeb988c`
[NEW] box.signageos.io/status pod rotated to `box-7cd9ddcc8c-t2w7w` (was `box-7cd9ddcc8c-5bnfd`), uid `e2a3b4…4c77bc`, body sha256 `e3d1ae393f652e3b582cdb1ca23a245af3fc240af4856...`
[CHANGED] Edge POP rotated to SFO53-P9 (box) / SFO53-P12 (api) — was PHX52-P1
[CHANGED] box.signageos.io/status pod rotated to `box-7cd9ddcc8c-756mn` (was t2w7w), process.uid `a3a5ce07…6d6d9`, body sha256 `82f3f196…a808` — data/headers unchanged, CloudFront POP SFO53-P6
[CHANGED] box.signageos.io/ root header sha256 now `3ac2f76a…6c15` — nonce hashes rotated, body/CORS/CSP unchanged
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] box.signageos.io/status, 6.85, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=5
[HYP] Cross-tenant security-token minting via X-Auth org-UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[PARKED] Cross-tenant security-token minting via X-Auth org-UID override: AUTH_HELPED testability requires valid account JWT + foreign org UID — off-phase for current passive-only cycle; not dropped, parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: AUTH_HELPED testability requires valid account JWT + foreign org UID — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] HUMAN: Cross-tenant security-token test — requires `sos login` (Auth0 device-code) to obtain account JWT, then 1) baseline POST /v1/organization/<own-org-uid>/security-token → 200, 2) repeat with foreign org UID → 200 + securityToken = cross-tenant IDOR, 3) escalate with leaked token to /v1/device → foreign org device list
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronted by CloudFront (x-cache/via/x-amz-cf-pop) — routing change only, body/header security posture unchanged
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[LEARN] REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected (static whitelist); NO `access-control-allow-credentials` → no direct credential-theft path. Class stays MISCONFIG-only (broad origin trust boundary, not exploit without creds flag)
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
[LEARN] REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-11 18:12:50 UTC [api] (model nemotron3)
[NEW] api.signageos.io/status pod rotated to `api-6d67cd6668-vg7c2` (was `api-6f69db97d5-9kg9l`), body sha256 `ba5832802fb18f18844768e92a5d375cc2411c92a2342f193bff4b90eaeb988c`
[NEW] box.signageos.io/status pod rotated to `box-7cd9ddcc8c-t2w7w` (was `box-7cd9ddcc8c-5bnfd`), uid `e2a3b4…4c77bc`, body sha256 `e3d1ae393f652e3b582cdb1ca23a245af3fc240af4856...`
[CHANGED] Edge POP rotated to SFO53-P9 (box) / SFO53-P12 (api) — was PHX52-P1
[CHANGED] box.signageos.io/status pod rotated to `box-7cd9ddcc8c-756mn` (was t2w7w), process.uid `a3a5ce07…6d6d9`, body sha256 `82f3f196…a808` — data/headers unchanged, CloudFront POP SFO53-P6
[CHANGED] box.signageos.io/ root header sha256 now `3ac2f76a…6c15` — nonce hashes rotated, body/CORS/CSP unchanged
[NEW] box.signageos.io/status pod rotated to `box-7cd9ddcc8c-7xc7l` (was szxmq), uid `bba45210…62857`, body sha256 `b0d07ba34cb883ea…` (was `23a4cdd4…`) — data shape unchanged, headers still ONLY `x-powered-by: Express` + CloudFront
[NEW] api.signageos.io/status pod rotated, body sha256 `135ad0771be7df70…` — hardening unchanged (HSTS max-age=31536000, xfo:DENY, xcto:nosniff), POP ORD56-P6
[PRIO] box.signageos.io/status, 6.85, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=5
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] box.signageos.io/ & /login/ CORS+CSP, 5.20, attack=5 business=4 tech=5 gate=10 cloud=5 fresh=4
[PRIO] api.signageos.io/status, 5.50, attack=6 business=4 tech=5 gate=10 cloud=6 fresh=4
[HYP] Cross-tenant security-token minting via X-Auth org-UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[PARKED] Cross-tenant security-token minting via X-Auth org-UID override: AUTH_HELPED testability requires valid account JWT + foreign org UID — off-phase for current passive-only cycle; not dropped, parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: AUTH_HELPED testability requires valid account JWT + foreign org UID — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] PROBE: Re-archive box /status evidence package this cycle — body sha256 changed (`b0d07ba34cb883eace6de41c23550c61cc2bb796c42b5bf93e9c1c5ca9a722d5`, pod 7xc7l, uid `bba45210…62857`). Exact: `curl -sS https://box.signageos.io/status | tee artifacts/box-status/body.json | sha256sum` + `curl -sI https://box.signageos.io/status | tee artifacts/box-status/headers.txt | grep -cE 'strict-transport|x-frame|x-content|content-security'`
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronted by CloudFront (x-cache/via/x-amz-cf-pop) — routing change only, body/header security posture unchanged
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[LEARN] REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected (static whitelist); NO `access-control-allow-credentials` → no direct credential-theft path. Class stays MISCONFIG-only (broad origin trust boundary, not exploit without creds flag)
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
[LEARN] REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-11 19:22:33 UTC [api] (model nemotron3)
[NEW] api.signageos.io/status pod rotated to `api-6d67cd6668-vg7c2`, body sha256 `ba5832802fb18f18844768e92a5d375cc2411c92a2342f193bff4b90eaeb988c`
[NEW] box.signageos.io/status pod rotated to `box-7cd9ddcc8c-t2w7w`, uid `e2a3b4…4c77bc`, body sha256 `e3d1ae393f652e3b582cdb1ca23a245af3fc240af4856...`
[CHANGED] Edge POP rotated to SFO53-P9 (box) / SFO53-P12 (api) — was PHX52-P1
[CHANGED] box.signageos.io/status pod rotated to `box-7cd9ddcc8c-756mn`, process.uid `a3a5ce07…6d6d9`, body sha256 `82f3f196…a808` — data/headers unchanged
[CHANGED] box.signageos.io/ root header sha256 now `3ac2f76a…6c15` — nonce hashes rotated
[NEW] box.signageos.io/status pod rotated to `box-7cd9ddcc8c-7xc7l`, uid `bba45210…62857`, body sha256 `b0d07ba34cb883ea…` — headers still ONLY `x-powered-by: Express` + CloudFront
[NEW] api.signageos.io/status pod rotated, body sha256 `135ad0771be7df70…` — hardening unchanged (HSTS/xfo/xcto)
[PRIO] box.signageos.io/status, 6.85, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=5
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] box.signageos.io/ & /login/ CORS+CSP, 5.20, attack=5 business=4 tech=5 gate=10 cloud=5 fresh=4
[PRIO] api.signageos.io/status, 5.50, attack=6 business=4 tech=5 gate=10 cloud=6 fresh=4
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[HYP] Cross-tenant security-token minting via X-Auth org-UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[PARKED] Cross-tenant security-token minting via X-Auth org-UID override: AUTH_HELPED testability requires valid account JWT + foreign org UID — off-phase for current passive-only cycle; not dropped, parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: AUTH_HELPED testability requires valid account JWT + foreign org UID — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] HUMAN: Cross-tenant IDOR test on api.signageos.io. Phase=POC for box is COMPLETE — box /status PoC fully verified live (3rd fresh probe confirms identical leak across 30+ cycles). Need valid account JWT + foreign org UID to test /v1/organization/{uid} and /v1/organization/{uid}/security-token for cross-tenant access.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronted by CloudFront (x-cache/via/x-amz-cf-pop) — routing change only, body/header security posture unchanged
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[LEARN] REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected (static whitelist); NO `access-control-allow-credentials` → no direct credential-theft path. Class stays MISCONFIG-only (broad origin trust boundary, not exploit without creds flag)
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
[LEARN] REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-11 20:11:23 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] box.signageos.io/status, 6.85, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=5
[PRIO] api.signageos.io/status, 5.75, attack=6 business=4 tech=5 gate=10 cloud=6 fresh=4
[PRIO] box.signageos.io/ & /login/ CORS+CSP, 5.40, attack=5 business=4 tech=5 gate=10 cloud=5 fresh=4
[HYP] Cross-tenant security-token minting via X-Auth org-UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[PARKED] Cross-tenant security-token minting via X-Auth org-UID override: confidence 78 but testability AUTH_HELPED requires human-provided valid account JWT + foreign org UID — not executable in passive-only phase; parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: confidence 75 but testability AUTH_HELPED requires human-provided valid account JWT + foreign org UID — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] HUMAN: Provide valid signageOS account JWT (X-Auth header) and a foreign organization UID to test cross-tenant IDOR on api.signageos.io/v1/organization/{uid} and /v1/organization/{uid}/security-token — box phase POC complete (30+ cycles), api phase requires AUTH_HELPED verification.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronted by CloudFront (x-cache/via/x-amz-cf-pop) — routing change only, body/header security posture unchanged
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[LEARN] REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected (static whitelist); NO `access-control-allow-credentials` → no direct credential-theft path. Class stays MISCONFIG-only (broad origin trust boundary, not exploit without creds flag)
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
[LEARN] REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-11 21:06:55 UTC [api] (model nemotron3)
[NEW] box.signageos.io/status pod rotated to `box-7cd9ddcc8c-qxz52` (was 7v5xw), process.uid `3d32a3ee…`, new body sha256 `77529aac…` — data shape, topology, zero hardening headers unchanged
[NEW] api.signageos.io/status body sha256 now `f89710b9…` (was `f8f9f7e0…`), pod `api-6d67cd6668-vg7c2` unchanged, hardening intact (HSTS/xfo/xcto/no-store)
[CHANGED] Box /status still carries ONLY `x-powered-by: Express` + CloudFront (security-header grep=0); differential vs hardened `/`+`/login/` and api /status persists 30+ cycles
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] box.signageos.io/status, 6.85, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=5
[PRIO] api.signageos.io/status, 5.75, attack=6 business=4 tech=5 gate=10 cloud=6 fresh=4
[PRIO] box.signageos.io/ & /login/ CORS+CSP, 5.40, attack=5 business=4 tech=5 gate=10 cloud=5 fresh=4
[HYP] Cross-tenant security-token minting via X-Auth org-UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: Live unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology with per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (zero hardening: no HSTS/xfo/xcto/CSP) — differential vs api.status which carries all three
evidence_needed: curl -I https://box.signageos.io/status shows 0 security headers; curl https://box.signageos.io/status returns JSON with topology
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0; differential: same on api.signageos.io/status returns HSTS/xfo/xcto
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[PARKED] Cross-tenant security-token minting via X-Auth org-UID override: confidence 78 but testability AUTH_HELPED requires human-provided valid account JWT + foreign org UID — not executable in passive-only phase; parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: confidence 75 but testability AUTH_HELPED requires human-provided valid account JWT + foreign org UID — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] HUMAN: Provide valid signageOS account JWT (X-Auth header) and a foreign organization UID to test cross-tenant IDOR on api.signageos.io/v1/organization/{uid} and /v1/organization/{uid}/security-token — box phase POC complete (30+ cycles), api phase requires AUTH_HELPED verification.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronted by CloudFront (x-cache/via/x-amz-cf-pop) — routing change only, body/header security posture unchanged
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[LEARN] REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected (static whitelist); NO `access-control-allow-credentials` → no direct credential-theft path. Class stays MISCONFIG-only (broad origin trust boundary, not exploit without creds flag)
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
[LEARN] REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-11 22:02:04 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/status, 5.75, attack=6 business=4 tech=5 gate=10 cloud=6 fresh=4
[HYP] Cross-tenant security-token minting via X-Auth org-UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: api.signageos.io/status
confidence: 90
reasoning: Live unauthenticated GET returns pod hostname, process UID, Node v24.19.0, full amqp/redis/mongo topology; now hardened with HSTS/xfo/xcto behind CloudFront — info leak persists but header posture hardened vs box
evidence_needed: curl -I https://api.signageos.io/status shows HSTS/xfo/xcto; curl returns JSON with topology
verify_steps: PASSIVE: GET https://api.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content' = 3; differential: box.signageos.io/status returns 0 security headers
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[PARKED] Cross-tenant security-token minting via X-Auth org-UID override: confidence 78 but testability AUTH_HELPED requires human-provided valid account JWT + foreign org UID — not executable in passive-only phase; parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: confidence 75 but testability AUTH_HELPED requires human-provided valid account JWT + foreign org UID — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] HUMAN: Provide valid signageOS account JWT (X-Auth header) and a foreign organization UID to test cross-tenant IDOR on api.signageos.io/v1/organization/{uid} and /v1/organization/{uid}/security-token — box phase POC complete (30+ cycles), api phase requires AUTH_HELPED verification.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronted by CloudFront (x-cache/via/x-amz-cf-pop) — routing change only, body/header security posture unchanged
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[LEARN] REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected (static whitelist); NO `access-control-allow-credentials` → no direct credential-theft path. Class stays MISCONFIG-only (broad origin trust boundary, not exploit without creds flag)
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
[LEARN] REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-11 22:58:12 UTC [api] (model nemotron3)
[NEW] box.signageos.io/status pod rotated to `box-7cd9ddcc8c-qxz52`, uid `3d32a3ee…`, body sha256 `77529aac…` (was `5cc2ca62…`) — data shape/headers unchanged
[NEW] api.signageos.io/status body sha256 now `f89710b9…` (was `f8f9f7e0…`), pod `api-6d67cd6668-vg7c2` unchanged, hardening intact
[CHANGED] Edge POP rotated to SFO53-P9 (box) / SFO53-P12 (api) — was ORD58-P5/ORD56-P6
[CHANGED] box.signageos.io/ root header sha256 rotated (nonce hashes) — body/CORS/CSP unchanged
[PRIO] box.signageos.io/status, 7.13, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/status, 5.75, attack=6 business=4 tech=5 gate=10 cloud=6 fresh=4
[PRIO] box.signageos.io/ + /login/, 5.25, attack=6 business=3 tech=7 gate=10 cloud=5 fresh=4
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: 30+ cycles confirm unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (grep=0 for HSTS/xfo/xcto/CSP); differential vs hardened `/`+`/login/` and api /status persists
evidence_needed: curl -sS https://box.signageos.io/status | sha256sum (expect 200 JSON, zero hardening headers)
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version, process UID) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[HYP] Cross-tenant security-token minting via X-Auth org-UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[PARKED] Cross-tenant security-token minting via X-Auth org-UID override: confidence 78 but testability AUTH_HELPED requires human-provided valid account JWT + foreign org UID — not executable in passive-only phase; parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: confidence 75 but testability AUTH_HELPED requires human-provided valid account JWT + foreign org UID — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] PROBE: Standing passive reconfirm at ≤1 rps. `curl -sS https://box.signageos.io/status | sha256sum` (expect 200 JSON, zero hardening headers) + `curl -sI -H "Origin: https://evil.test" https://box.signageos.io/ | grep -i access-control` (expect 17 static ACAO, no credentials flag)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronted by CloudFront (x-cache/via/x-amz-cf-pop) — routing change only, body/header security posture unchanged
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[LEARN] REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected (static whitelist); NO `access-control-allow-credentials` → no direct credential-theft path. Class stays MISCONFIG-only (broad origin trust boundary, not exploit without creds flag)
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
[LEARN] REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-11 23:51:17 UTC [api] (model nemotron3)
[NEW] box.signageos.io/status pod rotated to `box-7cd9ddcc8c-qxz52`, uid `3d32a3ee…`, body sha256 `77529aac…` (was `5cc2ca62…`) — data shape/headers unchanged
[NEW] api.signageos.io/status body sha256 now `f89710b9…` (was `f8f9f7e0…`), pod `api-6d67cd6668-vg7c2` unchanged, hardening intact
[CHANGED] Edge POP rotated to SFO53-P9 (box) / SFO53-P12 (api) — was ORD58-P5/ORD56-P6
[CHANGED] box.signageos.io/ root header sha256 rotated (nonce hashes) — body/CORS/CSP unchanged
[PRIO] box.signageos.io/status, 7.13, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/status, 5.75, attack=6 business=4 tech=5 gate=10 cloud=6 fresh=4
[PRIO] box.signageos.io/ + /login/, 5.25, attack=6 business=3 tech=7 gate=10 cloud=5 fresh=4
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: 30+ cycles confirm unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (grep=0 for HSTS/xfo/xcto/CSP); differential vs hardened `/`+`/login/` and api /status persists
evidence_needed: curl -sS https://box.signageos.io/status | sha256sum (expect 200 JSON, zero hardening headers)
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version, process UID) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[HYP] Cross-tenant security-token minting via X-Auth org-UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[PARKED] Cross-tenant security-token minting via X-Auth org-UID override: confidence 78 but testability AUTH_HELPED requires human-provided valid account JWT + foreign org UID — not executable in passive-only phase; parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: confidence 75 but testability AUTH_HELPED requires human-provided valid account JWT + foreign org UID — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] PROBE: Standing passive reconfirm at ≤1 rps. `curl -sS https://box.signageos.io/status | sha256sum` (expect 200 JSON, zero hardening headers) + `curl -sI -H "Origin: https://evil.test" https://box.signageos.io/ | grep -i access-control` (expect 17 static ACAO, no credentials flag)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronted by CloudFront (x-cache/via/x-amz-cf-pop) — routing change only, body/header security posture unchanged
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[LEARN] REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected (static whitelist); NO `access-control-allow-credentials` → no direct credential-theft path. Class stays MISCONFIG-only (broad origin trust boundary, not exploit without creds flag)
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
[LEARN] REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-12 00:51:41 UTC [api] (model nemotron3)
[NEW] box.signageos.io/status pod rotated `box-7cd9ddcc8c-qxz52` → `box-7cd9ddcc8c-6m52v`, uid `89e006c08c8b…`, body sha256 `f8927951c406…743ec` (was `77529aac…`) — data shape/topology identical, zero hardening headers unchanged
[CHANGED] box /status edge POP IAD55-P8 (was SFO53-P9)
[CHANGED] api.signageos.io/status body sha256 now `f89710b9…` (was `f8f9f7e0…`), pod `api-6d67cd6668-vg7c2` unchanged, hardening intact (HSTS/xfo/xcto/no-store)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] box.signageos.io/status, 7.15, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=8
[PRIO] api.signageos.io/status, 5.75, attack=6 business=4 tech=5 gate=10 cloud=6 fresh=4
[PRIO] box.signageos.io/ + /login/, 5.75, attack=6 business=3 tech=7 gate=10 cloud=5 fresh=4
[HYP] Cross-tenant security-token minting via X-Auth org-UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: 30+ cycles confirm unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (grep=0 for HSTS/xfo/xcto/CSP); differential vs hardened `/`+`/login/` and api /status persists
evidence_needed: curl -sS https://box.signageos.io/status | sha256sum (expect 200 JSON, zero hardening headers)
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version, process UID) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[PARKED] Cross-tenant security-token minting via X-Auth org-UID override: confidence 78 but testability AUTH_HELPED requires human-provided valid account JWT + foreign org UID — not executable in passive-only phase; parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: confidence 75 but testability AUTH_HELPED requires human-provided valid account JWT + foreign org UID — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] HUMAN: Provide valid account JWT (X-Auth: <accountJWT>) and a foreign org UID to test cross-tenant POST /v1/organization/<foreign-org-uid>/security-token and GET /v1/organization/<foreign-org-uid> — both require AUTH_HELPED, not passively executable
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronted by CloudFront (x-cache/via/x-amz-cf-pop) — routing change only, body/header security posture unchanged
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[LEARN] REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected (static whitelist); NO `access-control-allow-credentials` → no direct credential-theft path. Class stays MISCONFIG-only (broad origin trust boundary, not exploit without creds flag)
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
[LEARN] REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-12 03:17:38 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] box.signageos.io/status, 7.15, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=8
[PRIO] box.signageos.io/ + /login/, 5.75, attack=6 business=3 tech=7 gate=10 cloud=5 fresh=4
[PRIO] api.signageos.io/status, 5.75, attack=6 business=4 tech=5 gate=10 cloud=6 fresh=4
[HYP] Cross-tenant security-token minting via X-Auth org-UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: 30+ cycles confirm unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (grep=0 for HSTS/xfo/xcto/CSP); differential vs hardened `/`+`/login/` and api /status persists
evidence_needed: curl -sS https://box.signageos.io/status | sha256sum (expect 200 JSON, zero hardening headers)
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version, process UID) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[PARKED] Cross-tenant security-token minting via X-Auth org-UID override: confidence 78 but testability AUTH_HELPED requires human-provided valid account JWT + foreign org UID — not executable in passive-only phase; parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: confidence 75 but testability AUTH_HELPED requires human-provided valid account JWT + foreign org UID — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] HUMAN: Provide valid account JWT (X-Auth: <accountJWT>) and a foreign org UID to test cross-tenant POST /v1/organization/<foreign-org-uid>/security-token and GET /v1/organization/<foreign-org-uid> — both require AUTH_HELPED, not passively executable
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronted by CloudFront (x-cache/via/x-amz-cf-pop) — routing change only, body/header security posture unchanged
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[LEARN] REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected (static whitelist); NO `access-control-allow-credentials` → no direct credential-theft path. Class stays MISCONFIG-only (broad origin trust boundary, not exploit without creds flag)
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
[LEARN] REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-12 05:12:44 UTC [api] (model nemotron3)
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] box.signageos.io/status, 7.15, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=8
[PRIO] box.signageos.io/ + /login/, 5.75, attack=6 business=3 tech=7 gate=10 cloud=5 fresh=4
[PRIO] api.signageos.io/status, 5.75, attack=6 business=4 tech=5 gate=10 cloud=6 fresh=4
[HYP] Cross-tenant security-token minting via X-Auth org-UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: 30+ cycles confirm unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (grep=0 for HSTS/xfo/xcto/CSP); differential vs hardened `/`+`/login/` and api /status persists
evidence_needed: curl -sS https://box.signageos.io/status | sha256sum (expect 200 JSON, zero hardening headers)
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version, process UID) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[PARKED] Cross-tenant security-token minting via X-Auth org-UID override: confidence 78 but testability AUTH_HELPED requires human-provided valid account JWT + foreign org UID — not executable in passive-only phase; parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: confidence 75 but testability AUTH_HELPED requires human-provided valid account JWT + foreign org UID — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] HUMAN: Provide valid account JWT (X-Auth: <accountJWT>) and a foreign org UID to test cross-tenant POST /v1/organization/<foreign-org-uid>/security-token and GET /v1/organization/<foreign-org-uid> — both require AUTH_HELPED, not passively executable
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronted by CloudFront (x-cache/via/x-amz-cf-pop) — routing change only, body/header security posture unchanged
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[LEARN] REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected (static whitelist); NO `access-control-allow-credentials` → no direct credential-theft path. Class stays MISCONFIG-only (broad origin trust boundary, not exploit without creds flag)
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
[LEARN] REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-12 06:44:36 UTC [api] (model nemotron3)
[NEW] box.signageos.io/status pod rotated to `box-7cd9ddcc8c-szxmq` (was `box-7cd9ddcc8c-6m52v`), process.uid `79c03bfca3a0…`, new body sha256 — data shape/topology/headers identical (zero hardening headers)
[NEW] api.signageos.io/status pod rotated (new replica set `api-6d67cd6668-*`), new body sha256 — hardening intact (HSTS/xfo/xcto/no-store)
[CHANGED] Edge POP rotated to DFW56-P1 (box) / DFW56-P11 (api) — was PHX52-P1/SFO53-P12
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] box.signageos.io/status, 7.15, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=8
[PRIO] box.signageos.io/ + /login/, 5.75, attack=6 business=3 tech=7 gate=10 cloud=5 fresh=4
[PRIO] api.signageos.io/status, 5.75, attack=6 business=4 tech=5 gate=10 cloud=6 fresh=4
[HYP] Cross-tenant security-token minting via X-Auth org-UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: 30+ cycles confirm unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (grep=0 for HSTS/xfo/xcto/CSP); differential vs hardened `/`+`/login/` and api /status persists
evidence_needed: curl -sS https://box.signageos.io/status | sha256sum (expect 200 JSON, zero hardening headers)
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version, process UID) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[PARKED] Cross-tenant security-token minting via X-Auth org-UID override: confidence 78 but testability AUTH_HELPED requires human-provided valid account JWT + foreign org UID — not executable in passive-only phase; parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: confidence 75 but testability AUTH_HELPED requires human-provided valid account JWT + foreign org UID — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] HUMAN: Provide valid account JWT (X-Auth: <accountJWT>) and a foreign org UID to test cross-tenant POST /v1/organization/<foreign-org-uid>/security-token and GET /v1/organization/<foreign-org-uid> — both require AUTH_HELPED, not passively executable
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronted by CloudFront (x-cache/via/x-amz-cf-pop) — routing change only, body/header security posture unchanged
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[LEARN] REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected (static whitelist); NO `access-control-allow-credentials` → no direct credential-theft path. Class stays MISCONFIG-only (broad origin trust boundary, not exploit without creds flag)
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
[LEARN] REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-12 08:08:07 UTC [api] (model nemotron3)
[NEW] box.signageos.io/status pod rotated to `box-7cd9ddcc8c-25fdq` (was `f6xwn`), uid `ff305d7be56fe223f4598de90e10d3fcc219e0f3d07719391b`, new body sha256 — data shape/topology/headers identical (zero hardening headers)
[NEW] api.signageos.io/status pod rotated to new replica set `api-86db648db5-mb2ds` (was `api-6d67cd6668-*`), uid `b55aabee660c8ae7902cf13e4444d9304568a6ba1a730e6ca3`, mongoDB3 absent (8 services vs 9), new body sha256 — hardening intact (HSTS/xfo/xcto/no-store)
[CHANGED] api edge POP → IAD89-P1 (was DFW56-P11) — routing only
[PRIO] box.signageos.io/status, 7.15, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/status, 5.75, attack=6 business=4 tech=5 gate=10 cloud=6 fresh=4
[PRIO] box.signageos.io/ + /login/, 5.75, attack=6 business=3 tech=7 gate=10 cloud=5 fresh=4
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 95
reasoning: 30+ cycles confirm unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (grep=0 for HSTS/xfo/xcto/CSP); differential vs hardened `/`+`/login/` and api /status persists
evidence_needed: curl -sS https://box.signageos.io/status | sha256sum (expect 200 JSON, zero hardening headers)
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version, process UID) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[HYP] Cross-tenant security-token minting via X-Auth org-UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[PARKED] Cross-tenant security-token minting via X-Auth org-UID override: confidence 78 but testability AUTH_HELPED requires human-provided valid account JWT + foreign org UID — not executable in passive-only phase; parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: confidence 75 but testability AUTH_HELPED requires human-provided valid account JWT + foreign org UID — same rationale, parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] HUMAN: Provide valid account JWT (X-Auth: <accountJWT>) and a foreign org UID to test cross-tenant POST /v1/organization/<foreign-org-uid>/security-token and GET /v1/organization/<foreign-org-uid> — both require AUTH_HELPED, not passively executable
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronted by CloudFront (x-cache/via/x-amz-cf-pop) — routing change only, body/header security posture unchanged
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[LEARN] REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected (static whitelist); NO `access-control-allow-credentials` → no direct credential-theft path. Class stays MISCONFIG-only (broad origin trust boundary, not exploit without creds flag)
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
[LEARN] REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-12 09:28:30 UTC [api] (model nemotron3)
[NEW] box.signageos.io/status pod rotated to `box-7cd9ddcc8c-25fdq` (was `f6xwn`), uid `ff305d7be56fe223f4598de90e10d3fcc219e0f3d07719391b`, new body sha256 — data shape/topology/headers identical (zero hardening headers)
[NEW] api.signageos.io/status pod rotated to new replica set `api-86db648db5-mb2ds` (was `api-6d67cd6668-*`), uid `b55aabee660c8ae7902cf13e4444d9304568a6ba1a730e6ca3`, mongoDB3 absent (8 services vs 9), new body sha256 — hardening intact (HSTS/xfo/xcto/no-store)
[CHANGED] api edge POP → IAD89-P1 (was DFW56-P11) — routing only
[NEW] box.signageos.io/status pod rotated `box-7cd9ddcc8c-f6xwn` → `box-7cd9ddcc8c-bh6m7` (uid `d450f1ea…`, new body sha256 `453f4a0b…`); data shape identical: full amqp0/redis0-3/mongoDB0-3 topology, Node v20.20.2, per-service responseTime, zero hardening headers
[CHANGED] /tmp/opencode/artifacts/box-status/ evidence archive re-archived (prev wiped by workspace reset): headers.txt sha `76013792…`, body.json sha `453f4a0b…`, security-header grep=0
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] box.signageos.io/status, 7.15, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=8
[HYP] Cross-tenant security-token minting via X-Auth org-UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 96
reasoning: 30+ cycles confirm unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (grep=0 for HSTS/xfo/xcto/CSP); differential vs hardened `/`+`/login/` and api /status persists
evidence_needed: curl -sS https://box.signageos.io/status | sha256sum (expect 200 JSON, zero hardening headers)
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version, process UID) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[PARKED] Cross-tenant security-token minting via X-Auth org-UID override: AUTH_HELPED requires human-provided valid account JWT + foreign org UID — not executable in current passive-only POC phase; parked for HUMAN phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: AUTH_HELPED requires human-provided valid account JWT + foreign org UID — not executable in current passive-only POC phase; parked for HUMAN phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] HUMAN: Provide valid account JWT (X-Auth: <accountJWT>) and a foreign org UID to test cross-tenant POST /v1/organization/<foreign-org-uid>/security-token and GET /v1/organization/<foreign-org-uid> — both require AUTH_HELPED, not passively executable
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live across 30+ cycles — pod rotation, zero security headers, full topology leak unchanged. Now fronted by CloudFront (x-cache/via/x-amz-cf-pop) — routing change only, body/header security posture unchanged
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS (max-age=31536000), x-frame-options: DENY, x-content-type-options: nosniff — differential vs box.status persists; now also fronted by CloudFront (reconfirmed)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/ & /login/ CORS+CSP: 17 static ACAO incl. http:// plaintext variant + https://*.zdusercontent.com wildcard + api.signageos.io sibling; evil.test NOT reflected (static whitelist); NO access-control-allow-credentials; CSP 59+ distinct origins with triplicated Auth0 oauth/token on /login/ (reconfirmed)
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed 30+ cycles)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml (reconfirmed)
[LEARN] REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO incl `http://` variant + `https://*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected (static whitelist); NO `access-control-allow-credentials` → no direct credential-theft path. Class stays MISCONFIG-only (broad origin trust boundary, not exploit without creds flag)
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant/authenticated session (carried forward)
[LEARN] REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-12 10:40:09 UTC [api] (model nemotron3)
[NEW] box.signageos.io/status pod rotated to `box-7cd9ddcc8c-9476l` (was `bh6m7`), uid `9eb6708d0cf974931c5cb05a5d741ee4fe078e235da22dada7`, full 9-service topology (amqp0/redis0-3/mongoDB0-3), zero hardening headers
[NEW] api.signageos.io/status pod rotated to `api-86db648db5-twc7j` (was `mb2ds`), uid `a3356c027689016d927b8c4945cb68a5bfd8d87a0a35498cbb`, 8 services (mongoDB3 absent), hardened (HSTS/xfo/xcto/no-store)
[CHANGED] Edge POPs: box → IAD55-P8, api → IAD89-P1
[PRIO] box.signageos.io/status, 7.15, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[HYP] Cross-tenant security-token minting via X-Auth org-UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 96
reasoning: 30+ cycles confirm unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (grep=0 for HSTS/xfo/xcto/CSP); differential vs hardened `/`+`/login/` and api /status persists
evidence_needed: curl -sS https://box.signageos.io/status | sha256sum (expect 200 JSON, zero hardening headers)
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version, process UID) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[PARKED] Cross-tenant security-token minting via X-Auth org-UID override: AUTH_HELPED requires human-provided valid account JWT + foreign org UID — not executable in current passive-only POC phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: AUTH_HELPED requires human-provided valid account JWT + foreign org UID — not executable in current passive-only POC phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] HUMAN: Provide valid account JWT (X-Auth: <accountJWT>) and a foreign org UID to test cross-tenant POST /v1/organization/<foreign-org-uid>/security-token and GET /v1/organization/<foreign-org-uid> — both require AUTH_HELPED, not passively executable
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged behind CloudFront
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS/xfo/xcto/no-store — differential vs box persists
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant session
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
## 2026-08-12 11:29:00 UTC [api] (model nemotron3)
[NEW] box.signageos.io/status pod rotated to `box-7cd9ddcc8c-9476l` (was `bh6m7`), uid `9eb6708d0cf974931c5cb05a5d741ee4fe078e235da22dada7`, full 9-service topology, zero hardening headers
[NEW] api.signageos.io/status pod rotated to `api-86db648db5-twc7j` (was `mb2ds`), uid `a3356c027689016d927b8c4945cb68a5bfd8d87a0a35498cbb`, 8 services (mongoDB3 absent), hardened (HSTS/xfo/xcto/no-store)
[CHANGED] Edge POPs: box → IAD55-P8, api → IAD89-P1
[NEW] box.signageos.io/status pod rotated to `box-7cd9ddcc8c-dn5db` (was `9476l`), uid `ffb245ef…`, body sha256 `578ce714…`, zero hardening headers, CloudFront IAD55-P8
[NEW] api.signageos.io/status pod rotated to `api-86db648db5-mrcf8` (was `twc7j`), body sha256 `7fea10d6…`, hardening intact (secgrep=3), IAD89-P1
[PRIO] box.signageos.io/status, 7.15, attack=8 business=5 tech=6 gate=10 cloud=7 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.80, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[PRIO] api.signageos.io/v1/organization/{uid}, 7.75, attack=9 business=10 tech=8 gate=3 cloud=6 fresh=8
[HYP] Cross-tenant security-token minting via X-Auth org-UID override
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 78
reasoning: SDK/CLI code-verified — POST with X-Auth: <accountJWT> returns org-scoped token; uid is client-supplied path arg; account JWT carries no org UID, so server-side membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on POST /v1/organization/<foreign-org-uid>/security-token returning securityToken
verify_steps: AUTH_HELPED: curl -X POST -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid>/security-token = 200 baseline; repeat with foreign-org UID → 200 + securityToken = cross-tenant; escalate: curl -H "X-Auth: <leakedSecurityToken>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org token → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}
confidence: 75
reasoning: SDK/CLI code-verified — GET with X-Auth: <accountJWT> returns oauthClientId + oauthClientSecret; uid is client-supplied; legacy creds carry no org UID, so server-side account∈company→org membership check on path UID is sole barrier
evidence_needed: own account JWT → HTTP 200 on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret
verify_steps: AUTH_HELPED: curl -H "X-Auth: <accountJWT>" https://api.signageos.io/v1/organization/<own-org-uid> = 200 baseline; repeat with foreign-org UID → 200 + oauthClientSecret = cross-tenant; escalate: curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device → foreign org device list
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology leak via /status missing security headers
class: MISCONFIG
asset: box.signageos.io/status
confidence: 96
reasoning: 30+ cycles confirm unauthenticated GET returns pod hostname, 64-hex process UID, Node v20.20.2, full amqp/redis/mongo topology + per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (grep=0 for HSTS/xfo/xcto/CSP); differential vs hardened `/`+`/login/` and api /status persists
evidence_needed: curl -sS https://box.signageos.io/status | sha256sum (expect 200 JSON, zero hardening headers)
verify_steps: PASSIVE: GET https://box.signageos.io/status → 200 JSON leak; GET -I → grep -cE 'strict-transport|x-frame|x-content|content-security' = 0
impact: infrastructure reconnaissance (pod naming, service mesh topology, Node version, process UID) aids chained attacks; LOW direct exploitability
testability: PASSIVE
[PARKED] Cross-tenant security-token minting via X-Auth org-UID override: AUTH_HELPED requires human-provided valid account JWT + foreign org UID — not executable in current passive-only POC phase
[PARKED] Cross-tenant OAuth client-secret disclosure via account JWT: AUTH_HELPED requires human-provided valid account JWT + foreign org UID — not executable in current passive-only POC phase
[FINAL] Surviving hypotheses (ranked by confidence):
[NEXT] HUMAN: Provide valid account JWT (X-Auth: <accountJWT>) and a foreign org UID to test cross-tenant POST /v1/organization/<foreign-org-uid>/security-token and GET /v1/organization/<foreign-org-uid> — both require AUTH_HELPED, not passively executable
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live — pod rotation, zero security headers, full topology leak unchanged behind CloudFront
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Hardened with HSTS/xfo/xcto/no-store — differential vs box persists
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/* pre-auth: all routes JWT/X-Auth-gated, no passive bypass (reconfirmed)
[LEARN] REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 bodies leak WRONG_JWT_TOKEN/NO_ORGANIZATION_TO_AUTHENTICATE/WRONG_ACCOUNT_SECRET + errorCode 403075/403076/403105 — class descriptive-error excluded per scope.yml
[LEARN] REJECTED CORS-exploit @ box.signageos.io / + /login/: 17 static ACAO, 0 credentials flag → no credential-theft path; MISCONFIG-only
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 redirect_uri/state binding — not passively testable without tenant session
[LEARN] REJECTED MISCONFIG @ box.signageos.io/ready: 200 "OK" (2 bytes), trivial health check, no data leaked
[LEARN] REJECTED MISCONFIG @ api.signageos.io CORS: zero ACAO on /status, /, /v1/*, /v2/* — not CORS-exploitable
[RISK] box.signageos.io: 58 — Unauthenticated /status info leak (pod hostname + Redis/MongoDB/AMQP topology + Node version + process UID); CORS ACAO whitelist with 17 origins (incl zdusercontent wildcard + http:// variant); broad CSP (59+ connect-src/frame-src origins with triplicated Auth0). Still missing HSTS/xfo/xcto on /status despite CloudFront fronting; / and /login/ now hardened.
[RISK] api.signageos.io: 62 — Unauthenticated /status info leak (pod hostname + service topology) but hardened with HSTS/xfo/xcto + CloudFront; 60+ /v1/*+/v2/* endpoints all solidly JWT/X-Auth-gated (403 without token); no CORS issues. Risk raised due to code-verified cross-tenant IDOR candidates (org OAuth secret disclosure, org-token minting) that are AUTH_HELPED-testable with CRITICAL business impact.
