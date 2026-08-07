# Knowledge Base (seed)

## Program rules (from scope.yml)
- Eligible targets (ONLY): box.signageos.io, api.signageos.io
- Long exclusion list (all NOT eligible): DoS (network + account lockout), descriptive errors/headers, public file/dir disclosure, outdated libs, OPTIONS/TRACE, CSRF on logout, CSRF on anonymous forms, cookie flags on non-sensitive data, self-XSS, scanner reports without POC, physical access, social engineering, username enumeration, brute-force/lockout policies, SSL/TLS best practices + SSL attacks, clickjacking without demonstrated exploit, mail config, known-vulnerable lib without signageOS-specific exploit, password/account-recovery policies, autocomplete, public login panels, email verification gaps (registration/invite/password restore), session control on email/password change
- Reportable focus: real logic flaws (IDOR/authz/business logic/SSRF-type) with a concrete POC on the two eligible hosts
- Passive-first: GET/HEAD only, <=1 rps, no account creation, no data modification
- Secrets in commits: sha256 only, never raw

## Baseline surface (2026-08-07 passive recon)
- box.signageos.io: HTTP 302 (redirect - determine where; likely dashboard/player box admin)
- api.signageos.io: HTTP 200 on /
- signageos.io: 301 to www
- GitHub org signageos (59 public repos): first-party code incl. sdk (TS), cli (TS), applet-sandbox, platform (C++), videowall-designer (TS), server-bootstrap (Shell), kubernetes-ingress (Go), minio, plus many forks (DefinitelyTyped, HTML5test, zip.js, libcec, raspidmx, node-amqp10, WebGLSamples, webpack-dev-server, aports, charts)

## Rejected / parked (explicit program exclusions - never report)
- username enumeration on login/forgot-password, rate-limit/lockout policy, cookie flags non-sensitive, OPTIONS/TRACE, banner/stack-trace, robots.txt, outdated versions, SSL/TLS, clickjacking w/o exploit, CSRF on logout/anonymous forms, email verification gaps, session control on email/password change, autocomplete, public login panels, account recovery policies
- 2026-08-07 REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation not testable passively without tenant config access
- 2026-08-07 REJECTED IDOR @ api.signageos.io: No public API endpoints discoverable via passive probing (all common paths 404)
- 2026-08-07 ACCEPTED MISCONFIG @ box.signageos.io CSP: Overly broad connect-src/frame-src (20+ origins) confirmed — expands postMessage/origin trust boundary
- 2026-08-07 REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state parameter — class AUTH excluded as "CSRF on forms that are available to anonymous users" per scope.yml
- 2026-08-07 ACCEPTED MISCONFIG @ box.signageos.io CSP: overly broad connect-src/frame-src (20+ origins) confirmed — expands postMessage/origin trust boundary (carried forward from 2026-08-07)
- 2026-08-07 REJECTED IDOR @ api.signageos.io via undiscovered versioned endpoints: no public endpoints discoverable via passive probing (all common paths 404) — carried forward from 2026-08-07
- 2026-08-07 REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state parameter — class AUTH excluded as "CSRF on forms that are available to anonymous users" per scope.yml
- 2026-08-07 ACCEPTED MISCONFIG @ box.signageos.io CSP: overly broad connect-src/frame-src (20+ origins) confirmed — expands postMessage/origin trust boundary (carried forward from 2026-08-07)
- 2026-08-07 REJECTED IDOR @ api.signageos.io via undiscovered versioned endpoints: no public endpoints discoverable via passive probing (all common paths 404) — carried forward from 2026-08-07
- 2026-08-07 ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed NEW. Unauthenticated JSON health endpoint leaks K8s pod hostname, process UID, Node version, and backend service topology (redis0-3, mongoDB0-3, amqp0). Not on the rejected list (not banner/stack-trace, not file/dir disclosure, not outdated-version-only).
- 2026-08-07 ACCEPTED MISCONFIG @ box.signageos.io CORS: Confirmed NEW. 18× static `access-control-allow-origin` headers (incl `http://` HTTP variant + `https://*.zdusercontent.com` wildcard) on `/` and `/login/`. No `Access-Control-Allow-Credentials` observed. Not on the rejected list.
- 2026-08-07 REJECTED IDOR @ api.signageos.io: Real `/v1/*` endpoints confirmed via client bundle (bundle.js) — 40+ paths mapped. BUT all return 403 with `WRONG_JWT_TOKEN`/`403105` without a JWT. No unauthenticated data access found → IDOR not testable passively. The earlier seed rejection ("all common paths 404") was based on probing wrong paths (`/api/v1`, `/v1`) that don't exist; the real paths DO exist but are JWT-gated.
- 2026-08-07 REJECTED MISCONFIG @ api.signageos.io: 403 error body leaks descriptive auth detail (`"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 403105`, `errorName WRONG_JWT_TOKEN`) — falls under "descriptive error messages" (excluded per scope.yml).
- 2026-08-07 REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation — still not testable passively without tenant config access (carried forward).
- 2026-08-07 REJECTED AUTH @ box.signageos.io/login: login CSRF via OAuth2 state — excluded per "CSRF on anonymous-accessible forms" (carried forward).
- 2026-08-07 ACCEPTED MISCONFIG @ box.signageos.io/status: Confirmed live. Unauthenticated GET returns application/json leaking K8s pod hostname (rotating: gkzcp → mtnct), process UID, Node v20.20.2, and service topology (amqp0, redis0-3, mongoDB0-3). Not on rejected list.
- 2026-08-07 ACCEPTED MISCONFIG @ box.signageos.io CORS: Confirmed live. 18 static ACAO values on / (302) + /login/ (200), unchanged under spoofed Origin `https://evil.test`. Includes `http://` variant + `https://*.zdusercontent.com` wildcard + sibling `api.signageos.io`. No `Access-Control-Allow-Credentials` on any box path. api.signageos.io has NO ACAO on any path (including /status, /v1/*, /v2/*).
- 2026-08-07 ACCEPTED MISCONFIG @ box.signageos.io CSP: Confirmed live. /login/ CSP broadened vs / (triplicated Auth0 oauth/token, additional recaptcha frame-src). 40+ connect-src/frame-src origins spanning Auth0, Sony/BroadSign/MoodMedia device APIs, S3 buckets, AWS API Gateway, and api.signageos.io.
- 2026-08-07 REJECTED MISCONFIG @ box.signageos.io /ready: Returns 200 `OK` (2 bytes) — trivial health check, no data leaked. Not reportable.
- 2026-08-07 REJECTED IDOR @ api.signageos.io/v1/*+v2/*: All 60+ endpoints return 403 JWT-gated (WRONG_JWT_TOKEN/403105). No pre-auth bypass. Dual auth confirmed: JWT Bearer (main API) + X-Auth API-key format (`id:unsafeDecryptedToken`) for bulk provisioning.
- 2026-08-07 REJECTED MISCONFIG @ api.signageos.io CORS: 403/404 carry `vary: Origin` + `access-control-expose-headers: *` but NO ACAO under any Origin — not CORS-exploitable.
- 2026-08-07 REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation — not testable passively without tenant config access (carried forward).
- 2026-08-07 REJECTED MISCONFIG @ api.signageos.io/v1/* descriptive errors: 403 body leaks `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 403105` — falls under descriptive error messages (excluded).
