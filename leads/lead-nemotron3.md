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
