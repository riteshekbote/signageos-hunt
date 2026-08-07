# Inventory: signageos

## Seed 2026-08-07 (passive recon)

### Hosts (in scope - ONLY these two)
- box.signageos.io — 302 (redirect target TBD; box = player/dashboard?)
- api.signageos.io — 200 on /

### Excluded / not eligible (do NOT report, see scope.yml)
- All the program's exclusion list (DoS, enumeration, TLS, CSRF-on-anonymous, clickjacking-no-exploit, email-verification, etc.)

### Code surface (github.com/signageos, 59 repos)
- First-party: sdk (TS), cli (TS), applet-sandbox, platform (C++), videowall-designer (TS), server-bootstrap (Shell), kubernetes-ingress (Go), minio
- Mostly forks: DefinitelyTyped, HTML5test, zip.js, libcec, raspidmx, WebGLSamples, node-amqp10, webpack-dev-server, aports, charts

### Open questions
- Where box.signageos.io redirects to (auth model, session cookies)
- API auth model of api.signageos.io (key? OAuth? JWT?)
- Relationship of sdk/cli repos to api.signageos.io endpoints

## 2026-08-07 18:32:56 UTC
- NEW api.signageos.io: Root (/) serves static HTML landing page (37KB), not API JSON — no public API surface exposed (404 on /v1, /v2, /health, /docs, /api, /swagger.json, /openapi.json)
- NEW box.signageos.io: 302 → /login/%2F with Auth0 OAuth2 flow (sos-production.us.auth0.com, auth0.signageos.io in CSP connect-src) — confirms Auth0 as IdP
- NEW box.signageos.io CSP reveals extensive 3rd-party integrations: Mapbox, Sentry, MoodMedia/BroadSign/Sony device APIs, remote-desktop.signageos.io, upload.signageos.io, platform.signageos.io, license.si
- CHANGED api.signageos.io auth model unknown — no public docs, no swagger, no obvious auth headers on root; SDK/cli repos (signageos org, 59 repos) likely contain actual endpoint mappings and auth schemes

## 2026-08-07 18:56:31 UTC

## 2026-08-07 19:26:08 UTC
- NEW api.signageos.io: Returns static HTML (37KB, text/html, etag W/"90ac-...") even with `Accept: application/json`, `Authorization: Bearer null`, `x-api-key: test` — no JSON API surface exposed
- NEW remote-desktop.signageos.io & upload.signageos.io: Serve IDENTICAL Express HTML (same etag W/"90ac-...", same 37036 bytes, black background with base64 PNG) — confirms shared infrastructure
- NEW platform.signageos.io: Returns HTTP 503 (service unavailable)
- CHANGED license.signageos.io: No response / connection timeout
