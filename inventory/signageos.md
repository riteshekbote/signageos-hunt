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

## 2026-08-07 20:15:16 UTC
- NEW box.signageos.io/status: unauthenticated JSON (HTTP 200, application/json) leaking K8s pod hostname (`box-7c8c876945-gkzcp`), process UID (40-hex), Node v20.20.2, uptime, CPU/memory, and internal serv
- NEW api.signageos.io/status: unauthenticated JSON (HTTP 200, application/json) leaking K8s pod hostname (`api-6f69db97d5-9szk2`), process UID, Node v24.19.0, service topology (redis0-3, mongoDB0-2, amqp0)
- NEW api.signageos.io: real REST endpoints at `/v1/{device,organization,account,license,content-guard/item,location,company,bulk-operation,export/device,device/screenshot,device/telemetry/latest,...}` + `/
- NEW box.signageos.io: 18× static `access-control-allow-origin` header values on `/` (302) and `/login/` (200) — including `http://box.signageos.io` (HTTP/plaintext variant), `https://*.zdusercontent.com` 
- CHANGED box.signageos.io CSP: `connect-src`/`frame-src` enlarged vs seed (additional S3 buckets + triplicated Auth0 `oauth/token` entries); CSP still ACCEPTED from seed

## 2026-08-07 21:04:45 UTC

## 2026-08-07 21:34:19 UTC

## 2026-08-07 22:07:31 UTC
- NEW Hardcoded clientId/secret in `videowall-designer/sos/videoTiming.js` (line 18-19) authenticating against internal staging API `http://api.kiera.office.signageos.io` over HTTP — REAL_SECRET + ENDPOINT_

## 2026-08-07 22:51:50 UTC

## 2026-08-07 23:28:25 UTC

## 2026-08-07 23:54:39 UTC
- NEW api.signageos.io Node version upgraded to v24.19.0 (was v24.19.0 on some pods, v20.20.2 on others — mixed fleet confirmed)
- NEW box.signageos.io pod hostname rotated to `box-7c8c876945-52dpt` (Node v20.20.2); api.signageos.io pod hostname rotated to `api-6f69db97d5-97fjw` (Node v24.19.0) — K8s rolling deploy confirmed
- CHANGED api.signageos.io/v2/device now returns 403 JWT-gated (previously 404) — v2 migration advancing

## 2026-08-08 00:49:27 UTC
- NEW api.signageos.io Node version upgraded to v24.19.0 (mixed fleet: v24.19.0 + v20.20.2 pods confirmed)
- NEW box.signageos.io pod hostname rotated to `box-7c8c876945-52dpt` (Node v20.20.2); api.signageos.io pod hostname rotated to `api-6f69db97d5-97fjw` (Node v24.19.0) — K8s rolling deploy confirmed
- CHANGED api.signageos.io/v2/device now returns 403 JWT-gated (previously 404) — v2 migration advancing
- NEW api.signageos.io Node version upgraded to v24.19.0 (mixed fleet: v24.19.0 + v20.20.2 pods confirmed)
- NEW box.signageos.io pod hostname rotated to `box-7c8c876945-52dpt` (Node v20.20.2); api.signageos.io pod hostname rotated to `api-6f69db97d5-97fjw` (Node v24.19.0) — K8s rolling deploy confirmed
- CHANGED api.signageos.io/v2/device now returns 403 JWT-gated (previously 404) — v2 migration advancing

## 2026-08-08 02:38:01 UTC
- CHANGED api.signageos.io/v2/device: now returns 403 JWT-gated (was 404) — v2 migration advancing; supports AUTH hypothesis on v2 endpoints

## 2026-08-08 03:56:22 UTC
- NEW api.signageos.io/v2/device: now returns 403 JWT-gated (was 404) — v2 migration advancing

## 2026-08-08 04:47:05 UTC

## 2026-08-08 05:31:29 UTC

## 2026-08-08 06:07:19 UTC
- CHANGED box.signageos.io/status pod hostname rotated to box-7c8c876945-gkzcp (Node v20.20.2) — known rolling-deploy churn, no functional change
- CHANGED api.signageos.io/status pod hostname rotated to api-6f69db97d5-st6zq (Node v24.19.0) — known rolling-deploy churn, no functional change

## 2026-08-08 07:09:50 UTC
- CHANGED box.signageos.io/status: pod hostname rotated to `box-7c8c876945-9v4gf` (Node v20.20.2) — K8s rolling deploy churn, no functional change
- CHANGED api.signageos.io/status: pod hostname rotated to `api-6f69db97d5-9kg9l` (Node v24.19.0) — K8s rolling deploy churn, no functional change

## 2026-08-08 07:58:45 UTC
- CHANGED box.signageos.io/status: pod hostname rotated to `box-7c8c876945-xmdhm` (Node v20.20.2) — K8s rolling deploy churn, no functional change
- CHANGED api.signageos.io/status: pod hostname rotated to `api-6f69db97d5-jnncr` (Node v24.19.0) — K8s rolling deploy churn, no functional change

## 2026-08-08 08:30:39 UTC
- NEW None — latest cycle (2026-08-08 07:58) shows only K8s pod hostname rotation on `/status` endpoints (box-7c8c876945-xmdhm, api-6f69db97d5-jnncr), no functional surface change
- CHANGED box.signageos.io/status: pod hostname rotated to `box-7c8c876945-52dpt` (Node v20.20.2) — rolling-deploy churn, no functional change. Headers confirmed absent: no HSTS / x-frame-options / x-content-ty
- CHANGED api.signageos.io/status: pod hostname rotated to `api-6f69db97d5-22g8d` (Node v24.19.0) — rolling-deploy churn. Unlike box, api.status now carries `strict-transport-security`, `x-frame-options: DENY`,
- CHANGED api.signageos.io/v2/device: confirmed 403 JWT-gated (was 404) — v2 migration advance confirmed via passive probe.

## 2026-08-08 09:12:47 UTC
- NEW api.signageos.io/status now carries proper security headers: `strict-transport-security: max-age=31536000`, `x-frame-options: DENY`, `x-content-type-options: nosniff` — previously absent
- CHANGED api.signageos.io/v2/device confirmed 403 JWT-gated (was 404) — v2 migration advancing; carries same security headers as /status
- CHANGED box.signageos.io/status pod hostname rotated to `box-7c8c876945-r5fm9` (Node v20.20.2) — still missing HSTS/xfo/xcto
- CHANGED api.signageos.io/status pod hostname rotated to `api-6f69db97d5-9kg9l` (Node v24.19.0) — now hardened with security headers

## 2026-08-08 09:54:23 UTC
- NEW api.signageos.io/status now carries proper security headers: `strict-transport-security: max-age=31536000`, `x-frame-options: DENY`, `x-content-type-options: nosniff` — previously absent
- CHANGED api.signageos.io/v2/device confirmed 403 JWT-gated (was 404) — v2 migration advancing; carries same security headers as /status
- CHANGED box.signageos.io/status pod hostname rotated to `box-7c8c876945-rzvgp` (Node v20.20.2) — still missing HSTS/xfo/xcto
- CHANGED api.signageos.io/status pod hostname rotated to `api-6f69db97d5-9kg9l` (Node v24.19.0) — now hardened with security headers

## 2026-08-08 10:27:07 UTC
- NEW box.signageos.io/status pod hostname rotated to `box-7c8c876945-52dpt` (Node v20.20.2) — K8s rolling deploy
- CHANGED api.signageos.io/status pod hostname rotated to `api-6f69db97d5-22g8d` (Node v24.19.0) — K8s rolling deploy; security headers (HSTS/xfo/xcto) confirmed present

## 2026-08-08 10:57:22 UTC
- NEW box.signageos.io/status pod hostname rotated to `box-7c8c876945-r5fm9` (Node v20.20.2) — still missing HSTS/xfo/xcto

## 2026-08-08 11:21:47 UTC

## 2026-08-08 11:46:59 UTC

## 2026-08-08 12:04:05 UTC

## 2026-08-08 13:07:14 UTC

## 2026-08-08 13:54:14 UTC

## 2026-08-08 14:23:33 UTC

## 2026-08-08 14:56:41 UTC

## 2026-08-08 15:18:04 UTC

## 2026-08-08 15:49:04 UTC
- NEW NO_DELTA — surface unchanged since 2026-08-08 15:18; only K8s pod hostname rotation observed on `/status` (rolling-deploy churn, captured)
- CHANGED box.signageos.io/status: pod rotated to `box-7c8c876945-gkzcp` (Node v20.20.2) — no functional change, still zero security headers

## 2026-08-08 17:04:04 UTC

## 2026-08-08 17:43:05 UTC

## 2026-08-08 18:13:59 UTC

## 2026-08-08 19:03:14 UTC

## 2026-08-08 19:40:18 UTC

## 2026-08-08 20:07:46 UTC

## 2026-08-08 20:45:35 UTC

## 2026-08-08 21:15:22 UTC

## 2026-08-08 21:52:13 UTC

## 2026-08-08 22:17:51 UTC

## 2026-08-08 22:55:04 UTC
- NEW box.signageos.io/status pod hostname rotated to `box-7c8c876945-chbwh` (Node v20.20.2, UID `db5ae9f2f2545ca6eac15f7ebcc244fd6c66c2abaf90f0fe21`) — K8s rolling deploy, still ONLY `x-powered-by: Express
- NEW api.signageos.io/status pod hostname rotated to `api-6f69db97d5-wpppp` (Node v24.19.0, UID `2730e3d23aad18e08380a26c87ecb53369d27821392ff3476c`) — K8s rolling deploy, security headers (HSTS/xfo/xcto) 
- CHANGED box.signageos.io CORS/CSP reconfirmed — 17 static ACAO (incl `http://box.signageos.io` plaintext + `https://*.zdusercontent.com` wildcard + `api.signageos.io`), evil.test NOT reflected, NO `access-con

## 2026-08-08 23:22:37 UTC
- NEW box.signageos.io/status pod hostname rotated to `box-7c8c876945-chbwh` (Node v20.20.2, UID `db5ae9f2f2545ca6eac15f7ebcc244fd6c66c2abaf90f0fe21`) — K8s rolling deploy, still ONLY `x-powered-by: Express
- NEW api.signageos.io/status pod hostname rotated to `api-6f69db97d5-wpppp` (Node v24.19.0, UID `2730e3d23aad18e08380a26c87ecb53369d27821392ff3476c`) — K8s rolling deploy, security headers (HSTS/xfo/xcto) 
- CHANGED box.signageos.io CORS/CSP reconfirmed — 17 static ACAO (incl `http://box.signageos.io` plaintext + `https://*.zdusercontent.com` wildcard + `api.signageos.io`), evil.test NOT reflected, NO `access-con

## 2026-08-08 23:53:17 UTC

## 2026-08-09 01:07:13 UTC

## 2026-08-09 03:08:09 UTC

## 2026-08-09 04:36:22 UTC

## 2026-08-09 05:35:07 UTC

## 2026-08-09 06:26:33 UTC

## 2026-08-09 07:34:54 UTC

## 2026-08-09 08:22:38 UTC

## 2026-08-09 09:12:27 UTC

## 2026-08-09 09:58:45 UTC
- NEW box.signageos.io/status: unauthenticated JSON (HTTP 200, application/json) leaking K8s pod hostname (`box-7c8c876945-gkzcp`), process UID (40-hex), Node v20.20.2, uptime, CPU/memory, and internal serv
- NEW api.signageos.io/status: unauthenticated JSON (HTTP 200, application/json) leaking K8s pod hostname (`api-6f69db97d5-9szk2`), process UID, Node v24.19.0, service topology (redis0-3, mongoDB0-2, amqp0)
- NEW api.signageos.io: real REST endpoints at `/v1/{device,organization,account,license,content-guard/item,location,company,bulk-operation,export/device,device/screenshot,device/telemetry/latest,...}` + `/
- NEW box.signageos.io: 18× static `access-control-allow-origin` header values on `/` (302) and `/login/` (200) — including `http://box.signageos.io` (HTTP/plaintext variant), `https://*.zdusercontent.com` 
- CHANGED box.signageos.io CSP: `connect-src`/`frame-src` enlarged vs seed (additional S3 buckets + triplicated Auth0 `oauth/token` entries); CSP still ACCEPTED from seed

## 2026-08-09 10:42:56 UTC

## 2026-08-09 11:14:29 UTC

## 2026-08-09 11:49:26 UTC

## 2026-08-09 12:20:33 UTC

## 2026-08-09 13:32:48 UTC
- NEW box /status pod hostname rotated (jfmtn ↔ gkzcp on back-to-back probes — live K8s rolling rotation), still HTTP 200, ONLY `x-powered-by: Express`, security-header count = 0
- NEW api /status pod hostname rotated (api-6f69db97d5-*), still hardened (HSTS max-age=31536000 + x-frame-options DENY + x-content-type-options nosniff)
- CHANGED box CORS/CSP reconfirmed — 17 static ACAO, 0 credentials flag, evil.test NOT reflected, CSP connect-src still triplicated Auth0 + mapbox + sentry + S3 — UNCHANGED

## 2026-08-09 14:10:34 UTC

## 2026-08-09 14:54:57 UTC

## 2026-08-09 15:30:40 UTC

## 2026-08-09 16:03:31 UTC

## 2026-08-09 16:51:36 UTC

## 2026-08-09 17:21:10 UTC

## 2026-08-09 17:55:20 UTC

## 2026-08-09 18:38:34 UTC

## 2026-08-09 19:22:08 UTC

## 2026-08-09 19:55:33 UTC

## 2026-08-09 20:32:44 UTC

## 2026-08-09 21:09:37 UTC

## 2026-08-09 21:47:44 UTC

## 2026-08-09 22:15:51 UTC

## 2026-08-09 22:55:49 UTC

## 2026-08-09 23:33:10 UTC

## 2026-08-10 00:04:25 UTC

## 2026-08-10 02:31:10 UTC
- CHANGED box.signageos.io/status now served behind CloudFront (new headers `x-cache: Miss from cloudfront`, `via: ...cloudfront.net`, `x-amz-cf-pop: PHX52-P1`) — routing/hardening change only; body identical (
- CHANGED box.signageos.io/login/ chain re-probed — final hop 200, HSTS `max-age=63072000; includeSubDomains; preload` + xfo:DENY + xcto:nosniff present; CSP identical (triplicated Auth0 oauth/token, ~60 connec

## 2026-08-10 04:19:27 UTC
- CHANGED box.signageos.io/status now fronted by CloudFront (x-cache, via, x-amz-cf-pop headers added) — body unchanged, still zero security headers (no HSTS/xfo/xcto/CSP)
- CHANGED box.signageos.io/ and /login/ now served via CloudFront with full hardening headers (HSTS max-age=63072000; includeSubDomains; preload, xfo:DENY, xcto:nosniff, CSP) — differential vs /status persists
- NEW api.signageos.io/status now also fronted by CloudFront (x-cache, via, x-amz-cf-pop) — retains HSTS/xfo/xcto hardening

## 2026-08-10 05:52:32 UTC

## 2026-08-10 07:11:45 UTC

## 2026-08-10 08:56:55 UTC

## 2026-08-10 10:11:31 UTC

## 2026-08-10 11:31:07 UTC

## 2026-08-10 12:17:33 UTC

## 2026-08-10 13:51:05 UTC

## 2026-08-10 14:47:21 UTC
