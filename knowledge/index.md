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
