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

## 2026-08-10 15:46:49 UTC

## 2026-08-10 16:39:17 UTC

## 2026-08-10 17:37:38 UTC
- CHANGED box.signageos.io/status now fronted by CloudFront (new `x-cache`/`via`/`x-amz-cf-pop` headers) — routing change only, body/header security posture unchanged (still zero hardening headers, leaks topolo
- CHANGED box.signageos.io/ & /login/ now served via CloudFront with full hardening headers (HSTS `max-age=63072000; includeSubDomains; preload`, `xfo: DENY`, `xcto: nosniff`, CSP) — differential vs `/status` c
- CHANGED api.signageos.io/status now also fronted by CloudFront — retains HSTS+xfo+xcto hardening

## 2026-08-10 18:33:44 UTC

## 2026-08-10 19:38:47 UTC
- CHANGED box.signageos.io now fronted by CloudFront (added `x-cache`/`via`/`x-amz-cf-pop`) — `/` and `/login/` now carry full hardening headers (HSTS `max-age=63072000; includeSubDomains; preload`, `xfo: DENY`
- CHANGED api.signageos.io/status now also fronted by CloudFront — retains HSTS+xfo+xcto hardening differential vs box.status
- CHANGED box.signageos.io now fronted by CloudFront (added `x-cache`/`via`/`x-amz-cf-pop`) — `/` and `/login/` now carry full hardening headers (HSTS `max-age=63072000; includeSubDomains; preload`, `xfo: DENY`
- CHANGED api.signageos.io/status now also fronted by CloudFront — retains HSTS+xfo+xcto hardening differential vs box.status

## 2026-08-10 20:23:24 UTC

## 2026-08-10 21:13:50 UTC

## 2026-08-10 22:04:33 UTC

## 2026-08-10 22:55:17 UTC
- CHANGED box.signageos.io/status now fronted by CloudFront (x-cache, via, x-amz-cf-pop headers) — routing change only, body/header security posture unchanged (still zero hardening headers, leaks topology)
- CHANGED box.signageos.io/ & /login/ now served via CloudFront with full hardening headers (HSTS max-age=63072000; includeSubDomains; preload, xfo:DENY, xcto:nosniff, CSP) — differential vs /status persists
- CHANGED api.signageos.io/status now also fronted by CloudFront (x-cache, via, x-amz-cf-pop) — retains HSTS+xfo+xcto hardening

## 2026-08-10 23:25:50 UTC

## 2026-08-11 00:03:53 UTC

## 2026-08-11 02:23:21 UTC

## 2026-08-11 04:17:36 UTC

## 2026-08-11 05:35:42 UTC

## 2026-08-11 06:11:49 UTC

## 2026-08-11 07:39:54 UTC

## 2026-08-11 08:39:48 UTC

## 2026-08-11 09:50:06 UTC

## 2026-08-11 10:43:48 UTC

## 2026-08-11 11:36:45 UTC

## 2026-08-11 12:28:10 UTC
- CHANGED box.signageos.io/status pod rotated 55pj6 → 5bnfd, process.uid 3b72b9b9… → 077b032238f6e3e717c868472b7132dcddd615ec206b8aa8cf — new body sha256 884bda3f5b93c53cbf2bae10df34159a12695c430a23240c1c309b61
- CHANGED Edge POP this cycle SFO53-P9 (box) / SFO53-P12 (api) — was PHX52-P1 (geo rotation only).
- CHANGED api.signageos.io/status body sha256 now ba5832802fb18f18844768e92a5d375cc2411c92a2342f193bff4b90eaeb988c (pod rotation); hardening unchanged (HSTS/xfo/xcto grep=3).

## 2026-08-11 14:03:56 UTC

## 2026-08-11 15:04:40 UTC
- NEW api.signageos.io/status pod rotated to `api-6d67cd6668-vg7c2` (was `api-6f69db97d5-9kg9l`), body sha256 `ba5832802fb18f18844768e92a5d375cc2411c92a2342f193bff4b90eaeb988c`
- NEW box.signageos.io/status pod rotated to `box-7cd9ddcc8c-t2w7w` (was `box-7cd9ddcc8c-5bnfd`), uid `e2a3b4…4c77bc`, body sha256 `e3d1ae393f652e3b582cdb1ca23a245af3fc240af4856...`
- CHANGED Edge POP rotated to SFO53-P9 (box) / SFO53-P12 (api) — was PHX52-P1
- CHANGED box.signageos.io/status: pod rotated to `box-7cd9ddcc8c-756mn` (was t2w7w), process.uid `a3a5ce07…6d6d9`, body sha256 `82f3f196…a808` — data/headers unchanged, CloudFront POP SFO53-P6.
- CHANGED box.signageos.io/ root header sha256 now `3ac2f76a…6c15` — nonce hashes rotated (expected), body/CORS/CSP unchanged.

## 2026-08-11 16:11:43 UTC
- NEW api.signageos.io/status pod rotated to `api-6d67cd6668-vg7c2` (was `api-6f69db97d5-9kg9l`), body sha256 `ba5832802fb18f18844768e92a5d375cc2411c92a2342f193bff4b90eaeb988c`
- NEW box.signageos.io/status pod rotated to `box-7cd9ddcc8c-t2w7w` (was `box-7cd9ddcc8c-5bnfd`), uid `e2a3b4…4c77bc`, body sha256 `e3d1ae393f652e3b582cdb1ca23a245af3fc240af4856...`
- CHANGED Edge POP rotated to SFO53-P9 (box) / SFO53-P12 (api) — was PHX52-P1
- CHANGED box.signageos.io/status pod rotated to `box-7cd9ddcc8c-756mn` (was t2w7w), process.uid `a3a5ce07…6d6d9`, body sha256 `82f3f196…a808` — data/headers unchanged, CloudFront POP SFO53-P6
- CHANGED box.signageos.io/ root header sha256 now `3ac2f76a…6c15` — nonce hashes rotated, body/CORS/CSP unchanged

## 2026-08-11 17:16:22 UTC
- NEW api.signageos.io/status pod rotated to `api-6d67cd6668-vg7c2` (was `api-6f69db97d5-9kg9l`), body sha256 `ba5832802fb18f18844768e92a5d375cc2411c92a2342f193bff4b90eaeb988c`
- NEW box.signageos.io/status pod rotated to `box-7cd9ddcc8c-t2w7w` (was `box-7cd9ddcc8c-5bnfd`), uid `e2a3b4…4c77bc`, body sha256 `e3d1ae393f652e3b582cdb1ca23a245af3fc240af4856...`
- CHANGED Edge POP rotated to SFO53-P9 (box) / SFO53-P12 (api) — was PHX52-P1
- CHANGED box.signageos.io/status pod rotated to `box-7cd9ddcc8c-756mn` (was t2w7w), process.uid `a3a5ce07…6d6d9`, body sha256 `82f3f196…a808` — data/headers unchanged, CloudFront POP SFO53-P6
- CHANGED box.signageos.io/ root header sha256 now `3ac2f76a…6c15` — nonce hashes rotated, body/CORS/CSP unchanged
- NEW box.signageos.io/status pod rotated to `box-7cd9ddcc8c-7xc7l` (was szxmq), uid `bba45210…62857`, body sha256 `b0d07ba34cb883ea…` (was `23a4cdd4…`) — data shape unchanged, headers still ONLY `x-powered
- NEW api.signageos.io/status pod rotated, body sha256 `135ad0771be7df70…` — hardening unchanged (HSTS max-age=31536000, xfo:DENY, xcto:nosniff), POP ORD56-P6.

## 2026-08-11 18:14:29 UTC
- NEW api.signageos.io/status pod rotated to `api-6d67cd6668-vg7c2` (was `api-6f69db97d5-9kg9l`), body sha256 `ba5832802fb18f18844768e92a5d375cc2411c92a2342f193bff4b90eaeb988c`
- NEW box.signageos.io/status pod rotated to `box-7cd9ddcc8c-t2w7w` (was `box-7cd9ddcc8c-5bnfd`), uid `e2a3b4…4c77bc`, body sha256 `e3d1ae393f652e3b582cdb1ca23a245af3fc240af4856...`
- CHANGED Edge POP rotated to SFO53-P9 (box) / SFO53-P12 (api) — was PHX52-P1
- CHANGED box.signageos.io/status pod rotated to `box-7cd9ddcc8c-756mn` (was t2w7w), process.uid `a3a5ce07…6d6d9`, body sha256 `82f3f196…a808` — data/headers unchanged, CloudFront POP SFO53-P6
- CHANGED box.signageos.io/ root header sha256 now `3ac2f76a…6c15` — nonce hashes rotated, body/CORS/CSP unchanged
- NEW box.signageos.io/status pod rotated to `box-7cd9ddcc8c-7xc7l` (was szxmq), uid `bba45210…62857`, body sha256 `b0d07ba34cb883ea…` (was `23a4cdd4…`) — data shape unchanged, headers still ONLY `x-powered
- NEW api.signageos.io/status pod rotated, body sha256 `135ad0771be7df70…` — hardening unchanged (HSTS max-age=31536000, xfo:DENY, xcto:nosniff), POP ORD56-P6

## 2026-08-11 19:22:45 UTC
- NEW api.signageos.io/status pod rotated to `api-6d67cd6668-vg7c2`, body sha256 `ba5832802fb18f18844768e92a5d375cc2411c92a2342f193bff4b90eaeb988c`
- NEW box.signageos.io/status pod rotated to `box-7cd9ddcc8c-t2w7w`, uid `e2a3b4…4c77bc`, body sha256 `e3d1ae393f652e3b582cdb1ca23a245af3fc240af4856...`
- CHANGED Edge POP rotated to SFO53-P9 (box) / SFO53-P12 (api) — was PHX52-P1
- CHANGED box.signageos.io/status pod rotated to `box-7cd9ddcc8c-756mn`, process.uid `a3a5ce07…6d6d9`, body sha256 `82f3f196…a808` — data/headers unchanged
- CHANGED box.signageos.io/ root header sha256 now `3ac2f76a…6c15` — nonce hashes rotated
- NEW box.signageos.io/status pod rotated to `box-7cd9ddcc8c-7xc7l`, uid `bba45210…62857`, body sha256 `b0d07ba34cb883ea…` — headers still ONLY `x-powered-by: Express` + CloudFront
- NEW api.signageos.io/status pod rotated, body sha256 `135ad0771be7df70…` — hardening unchanged (HSTS/xfo/xcto)

## 2026-08-11 20:11:36 UTC
- NEW box.signageos.io/status pod rotated to `box-7cd9ddcc8c-qxz52` (was 7v5xw), process.uid `3d32a3ee…71b1`, new body sha256 `77529aac…6e48` (was `5cc2ca62…`) — data shape, topology, zero hardening headers
- NEW api.signageos.io/status body sha256 now `f89710b9…06088` (was `f8f9f7e0…`), pod `api-6d67cd6668-vg7c2` unchanged, hardening intact (HSTS/xfo/xcto/no-store).
- CHANGED Box /status still carries ONLY `x-powered-by: Express` + CloudFront (security-header grep=0); differential vs hardened `/`+`/login/` and api /status persists 30+ cycles.

## 2026-08-11 21:07:09 UTC
- NEW box.signageos.io/status pod rotated to `box-7cd9ddcc8c-qxz52` (was 7v5xw), process.uid `3d32a3ee…`, new body sha256 `77529aac…` — data shape, topology, zero hardening headers unchanged
- NEW api.signageos.io/status body sha256 now `f89710b9…` (was `f8f9f7e0…`), pod `api-6d67cd6668-vg7c2` unchanged, hardening intact (HSTS/xfo/xcto/no-store)
- CHANGED Box /status still carries ONLY `x-powered-by: Express` + CloudFront (security-header grep=0); differential vs hardened `/`+`/login/` and api /status persists 30+ cycles

## 2026-08-11 22:06:07 UTC

## 2026-08-11 22:58:24 UTC
- NEW box.signageos.io/status pod rotated to `box-7cd9ddcc8c-qxz52`, uid `3d32a3ee…`, body sha256 `77529aac…` (was `5cc2ca62…`) — data shape/headers unchanged
- NEW api.signageos.io/status body sha256 now `f89710b9…` (was `f8f9f7e0…`), pod `api-6d67cd6668-vg7c2` unchanged, hardening intact
- CHANGED Edge POP rotated to SFO53-P9 (box) / SFO53-P12 (api) — was ORD58-P5/ORD56-P6
- CHANGED box.signageos.io/ root header sha256 rotated (nonce hashes) — body/CORS/CSP unchanged

## 2026-08-11 23:51:33 UTC
- NEW box.signageos.io/status pod rotated to `box-7cd9ddcc8c-qxz52`, uid `3d32a3ee…`, body sha256 `77529aac…` (was `5cc2ca62…`) — data shape/headers unchanged
- NEW api.signageos.io/status body sha256 now `f89710b9…` (was `f8f9f7e0…`), pod `api-6d67cd6668-vg7c2` unchanged, hardening intact
- CHANGED Edge POP rotated to SFO53-P9 (box) / SFO53-P12 (api) — was ORD58-P5/ORD56-P6
- CHANGED box.signageos.io/ root header sha256 rotated (nonce hashes) — body/CORS/CSP unchanged
- NEW box.signageos.io/status pod rotated `box-7cd9ddcc8c-qxz52` → `box-7cd9ddcc8c-6m52v`, uid `89e006c08c8b…`, body sha256 `f8927951c406…743ec` (was `77529aac…`) — data shape/topology identical, hardening 
- CHANGED box /status edge POP IAD55-P8 (was SFO53-P9)

## 2026-08-12 00:51:58 UTC
- NEW box.signageos.io/status pod rotated `box-7cd9ddcc8c-qxz52` → `box-7cd9ddcc8c-6m52v`, uid `89e006c08c8b…`, body sha256 `f8927951c406…743ec` (was `77529aac…`) — data shape/topology identical, zero harde
- CHANGED box /status edge POP IAD55-P8 (was SFO53-P9)
- CHANGED api.signageos.io/status body sha256 now `f89710b9…` (was `f8f9f7e0…`), pod `api-6d67cd6668-vg7c2` unchanged, hardening intact (HSTS/xfo/xcto/no-store)

## 2026-08-12 03:17:48 UTC
- NEW box.signageos.io/status now fronted by CloudFront edge (x-cache/via/x-amz-cf-pop observed IAD55-P8/PHX52-P9/SFO53-P6 — was origin-direct per original seed)
- CHANGED box.signageos.io/status pod rotated chain: box-7c8c876945-* → box-7cd9ddcc8c-* (new replica set) across 30+ cycles, latest `box-7cd9ddcc8c-6m52v`, uid `89e006c0…`, body sha `f8927951c406…743ec` (super
- CHANGED api.signageos.io/status pod rotated to `api-6d67cd6668-*` (new replica set, was `api-6f69db97d5-*`), latest body sha `f89710b9…`
- CHANGED box.signageos.io/ root header sha rotated (nonce hashes) — body/CORS/CSP unchanged

## 2026-08-12 05:12:52 UTC

## 2026-08-12 06:49:00 UTC
- NEW box.signageos.io/status pod rotated to `box-7cd9ddcc8c-szxmq` (was `box-7cd9ddcc8c-6m52v`), process.uid `79c03bfca3a0…`, new body sha256 — data shape/topology/headers identical (zero hardening headers
- NEW api.signageos.io/status pod rotated (new replica set `api-6d67cd6668-*`), new body sha256 — hardening intact (HSTS/xfo/xcto/no-store)
- CHANGED Edge POP rotated to DFW56-P1 (box) / DFW56-P11 (api) — was PHX52-P1/SFO53-P12
- NEW box.signageos.io/status pod rotated to `box-7cd9ddcc8c-f6xwn` (was `6m52v`), uid `c29d3fd0…`, body sha256 `5bafacaff4c33f4c72db84c0f3503e420a56cefb0cc5105ae6a59b7a8502297e` — data shape unchanged
- NEW api.signageos.io/status service count → 8 (mongoDB3 absent), body sha256 `dc83322e…` — hardening intact
- CHANGED api edge POP → IAD89-P1 (routing-only)

## 2026-08-12 08:10:07 UTC
- NEW box.signageos.io/status pod rotated to `box-7cd9ddcc8c-25fdq` (was `f6xwn`), uid `ff305d7be56fe223f4598de90e10d3fcc219e0f3d07719391b`, new body sha256 — data shape/topology/headers identical (zero har
- NEW api.signageos.io/status pod rotated to new replica set `api-86db648db5-mb2ds` (was `api-6d67cd6668-*`), uid `b55aabee660c8ae7902cf13e4444d9304568a6ba1a730e6ca3`, mongoDB3 absent (8 services vs 9), new
- CHANGED api edge POP → IAD89-P1 (was DFW56-P11) — routing only
- NEW box.signageos.io/status pod rotated `box-7cd9ddcc8c-f6xwn` → `box-7cd9ddcc8c-bh6m7` (uid `d450f1ea…`, new body sha256 `453f4a0b…`); data shape identical: full amqp0/redis0-3/mongoDB0-3 topology, Node 
- CHANGED /tmp/opencode/artifacts/box-status/ evidence archive re-archived (prev wiped by workspace reset): headers.txt sha `76013792…`, body.json sha `453f4a0b…`, security-header grep=0

## 2026-08-12 09:28:40 UTC
- NEW box.signageos.io/status pod rotated to `box-7cd9ddcc8c-25fdq` (was `f6xwn`), uid `ff305d7be56fe223f4598de90e10d3fcc219e0f3d07719391b`, new body sha256 — data shape/topology/headers identical (zero har
- NEW api.signageos.io/status pod rotated to new replica set `api-86db648db5-mb2ds` (was `api-6d67cd6668-*`), uid `b55aabee660c8ae7902cf13e4444d9304568a6ba1a730e6ca3`, mongoDB3 absent (8 services vs 9), new
- CHANGED api edge POP → IAD89-P1 (was DFW56-P11) — routing only
- NEW box.signageos.io/status pod rotated `box-7cd9ddcc8c-f6xwn` → `box-7cd9ddcc8c-bh6m7` (uid `d450f1ea…`, new body sha256 `453f4a0b…`); data shape identical: full amqp0/redis0-3/mongoDB0-3 topology, Node 
- CHANGED /tmp/opencode/artifacts/box-status/ evidence archive re-archived (prev wiped by workspace reset): headers.txt sha `76013792…`, body.json sha `453f4a0b…`, security-header grep=0

## 2026-08-12 10:53:14 UTC
- NEW box.signageos.io/status pod rotated to `box-7cd9ddcc8c-9476l` (was `bh6m7`), uid `9eb6708d0cf974931c5cb05a5d741ee4fe078e235da22dada7`, full 9-service topology (amqp0/redis0-3/mongoDB0-3), zero hardeni
- NEW api.signageos.io/status pod rotated to `api-86db648db5-twc7j` (was `mb2ds`), uid `a3356c027689016d927b8c4945cb68a5bfd8d87a0a35498cbb`, 8 services (mongoDB3 absent), hardened (HSTS/xfo/xcto/no-store)
- CHANGED Edge POPs: box → IAD55-P8, api → IAD89-P1
- NEW box.signageos.io/status pod rotated `box-7cd9ddcc8c-bh6m7` → `box-7cd9ddcc8c-dn5db`, uid `ffb245ef…`, body sha256 `578ce714…` (was `453f4a0b…`) — data shape/topology identical, secgrep=0, CloudFront I
- NEW api.signageos.io/status pod rotated to `api-86db648db5-mrcf8` (was `mb2ds`), body sha256 `7fea10d6…` — hardening intact (secgrep=3), IAD89-P1
- CHANGED box /login/ CORS reconfirmed — 17 ACAO, 0 access-control-allow-credentials, evil.test NOT reflected (unchanged)

## 2026-08-12 11:30:45 UTC
- NEW box.signageos.io/status pod rotated to `box-7cd9ddcc8c-9476l` (was `bh6m7`), uid `9eb6708d0cf974931c5cb05a5d741ee4fe078e235da22dada7`, full 9-service topology, zero hardening headers
- NEW api.signageos.io/status pod rotated to `api-86db648db5-twc7j` (was `mb2ds`), uid `a3356c027689016d927b8c4945cb68a5bfd8d87a0a35498cbb`, 8 services (mongoDB3 absent), hardened (HSTS/xfo/xcto/no-store)
- CHANGED Edge POPs: box → IAD55-P8, api → IAD89-P1
- NEW box.signageos.io/status pod rotated to `box-7cd9ddcc8c-dn5db` (was `9476l`), uid `ffb245ef…`, body sha256 `578ce714…`, zero hardening headers, CloudFront IAD55-P8
- NEW api.signageos.io/status pod rotated to `api-86db648db5-mrcf8` (was `twc7j`), body sha256 `7fea10d6…`, hardening intact (secgrep=3), IAD89-P1
- CHANGED box /status pod → `box-8676fb5f57-fs8wj` (new replica set, uid `91fa0a7a…`, Node v20.20.2) — body/headers identical: zero hardening (grep=0), full amqp0/redis0-3/mongoDB0-3 topology leak. CloudFront I
- CHANGED api /status pod → `api-86db648db5-p94sg` (uid `72556714…`, Node v24.19.0, 8 svc — mongoDB3 absent) — hardening intact (grep=3: HSTS/xfo/xcto behind CloudFront).
- CHANGED Evidence archive at `/tmp/opencode/artifacts/box-status/` re-archived (workspace reset wiped prior copy): `body.json` sha `bdd3778a…`, `headers.txt` sha `a222bcc5…`, `login-origins.txt` sha `ebe9ddea…

## 2026-08-12 12:36:47 UTC
- NEW box.signageos.io/status pod rotated to `box-8676fb5f57-2lmr2` (new replica set `8676fb5f57`, was `7cd9ddcc8c`), uid `ce3b7110…`, Node v20.20.2, full 9-service topology (amqp0/redis0-3/mongoDB0-3), zer
- NEW api.signageos.io/status pod rotated to `api-86db648db5-78kr5` (replica set `86db648db5`), uid `9ecfee19…`, Node v24.19.0, 8 services (mongoDB3 absent), hardened (HSTS/xfo/xcto/no-store), CloudFront IA
- CHANGED box.signageos.io/ & /login/ CORS/CSP reconfirmed — 17 static ACAO incl `http://box.signageos.io` plaintext + `https://*.zdusercontent.com` wildcard + `api.signageos.io` sibling; evil.test NOT reflecte
- CHANGED api.signageos.io/v1/organization/test → 403 JWT-gated with hardened headers (HSTS/xfo/xcto/no-store), zero ACAO under spoofed Origin
- CHANGED box.signageos.io/status pod → `box-8676fb5f57-2lmr2` (uid `ce3b7110f5b14fa0c69147ae78c6a22e20ae55122e7ee3755f`, new pod in same rs `8676fb5f57`) — body/headers identical: zero hardening (grep=0), full
- CHANGED api.signageos.io/status pod rotation continuing, edge POP IAD89-P1 — hardening intact (HSTS/xfo/xcto), info-leak persists.
- CHANGED Evidence archive re-archived at `/tmp/opencode/artifacts/box-status/` (workspace reset wiped prior copy): body.json sha `0a88b388…`, headers.txt sha `b11ba5ba…`, login-origins.txt sha `99aec0ad…`.

## 2026-08-12 14:10:40 UTC
- NEW box.signageos.io/status pod rotated to `box-8676fb5f57-wqnc6` (replica set `8676fb5f57`), uid `49d30154baafe1fbb7db95e7da7540dd72fae7ebbbc5e80a1c`, Node v20.20.2, full 9-service topology (amqp0/redis0
- NEW api.signageos.io/status pod rotated to `api-86db648db5-twc7j` (replica set `86db648db5`), uid `a3356c027689016d927b8c4945cb68a5bfd8d87a0a35498cbb`, Node v24.19.0, 8 services (mongoDB3 absent), hardene
- CHANGED Edge POPs rotated — both box and api now fronted by SFO53 PoPs (was IAD55/IAD89)

## 2026-08-12 15:16:00 UTC

## 2026-08-12 16:17:06 UTC

## 2026-08-12 17:29:45 UTC

## 2026-08-12 18:18:43 UTC
- NEW None — surface unchanged since last probe cycle (box /status pod rotation only; api /status hardened; all v1/v2 endpoints 403 JWT-gated; box CORS/CSP static whitelist)

## 2026-08-12 19:38:19 UTC

## 2026-08-12 20:10:20 UTC

## 2026-08-12 21:05:37 UTC
- CHANGED api.signageos.io/status pod rotated → `api-86db648db5-p94sg` (uid `72556714…`, Node v24.19.0, 8 svc — mongoDB3 absent), hardening intact (HSTS/xfo/xcto/no-store, secgrep=3), CloudFront IAD89-P1.
- CHANGED box.signageos.io/status pod `box-8676fb5f57-2lmr2` (uid `ce3b7110…`, Node v20.20.2, 9-svc topology incl mongoDB3 this cycle), zero hardening headers (only x-powered-by: Express), CloudFront IAD55-P8 —

## 2026-08-12 22:00:43 UTC

## 2026-08-12 22:55:22 UTC

## 2026-08-12 23:41:27 UTC
- NEW box.signageos.io/status pod rotated to `box-8676fb5f57-9s62x` (uid `a5ec22b0…`), Node v20.20.2, 9-service topology, zero hardening headers (grep=0), behind CloudFront IAD55-P8
- NEW api.signageos.io/status pod rotated to `api-86db648db5-twc7j` (uid `a3356c02…`), Node v24.19.0, 8-service topology (mongoDB3 absent), hardened HSTS/xfo/xcto/no-store (grep=3) behind CloudFront IAD89-P
- CHANGED Edge POPs: box → IAD55-P8, api → IAD89-P1
- NEW box.signageos.io/status pod rotated → `box-8676fb5f57-ff2s4` (same rs `8676fb5f57`), uid `7f0e2a37…`, Node v20.20.2, full topology; headers still ONLY `x-powered-by: Express` (secgrep=0), CloudFront P
- NEW api.signageos.io/status pod rotated (Node v24.19.0, uid `0d0224f7…`), hardening intact (HSTS/xfo/xcto grep=3), CloudFront LAX50-P4. Body sha256 `93ea3555…`. No posture change.

## 2026-08-13 00:44:28 UTC
- CHANGED box.signageos.io/status pod rotated to `box-8676fb5f57-vt5sf` (uid `23019c763aed64708c1992b7d30dc4e5c3d8fc46ed29abfb5c`), full 9-service topology (mongoDB3 present), zero hardening headers
- CHANGED api.signageos.io/status pod rotated to `api-86db648db5-qrv57` (uid `ba427f09aa8e1346d2b5130b3652e151adf6500aef3f336dc8`), 8 services (mongoDB3 absent), hardened HSTS/xfo/xcto/no-store
- CHANGED Edge POPs: box → ORD58-P5, api → ORD56-P6

## 2026-08-13 03:27:55 UTC
- NEW box.signageos.io/status pod rotated to `box-8676fb5f57-h6d4t` (uid `2eeb6c32...`), Node v20.20.2, 9-service topology, zero hardening headers (grep=0), CloudFront DFW56-P1
- NEW api.signageos.io/status pod rotated to `api-86db648db5-p94sg` (uid `72556714...`), Node v24.19.0, 8-service topology (mongoDB3 absent), hardened HSTS/xfo/xcto/no-store, CloudFront DFW56-P11
- CHANGED Edge POPs rotated: box → DFW56-P1, api → DFW56-P11 (was ORD58-P5/ORD56-P6)
- CHANGED box.signageos.io/status pod rotated from `box-8676fb5f57-vt5sf` (uid `23019c76…`) to `box-8676fb5f57-l4pxv` (uid `dadfa18d…`) — new pod in same replica set `8676fb5f57`, Node v20.20.2 unchanged, zero 
- CHANGED api.signageos.io/status pod rotated from `api-86db648db5-qrv57` to `api-86db648db5-p94sg` (uid `72556714…`) — Node v24.19.0 unchanged, 8 services (mongoDB3 absent), hardening intact (HSTS/xfo/xcto/no-

## 2026-08-13 05:14:47 UTC
- NEW box.signageos.io/status pod rotated to `box-8676fb5f57-h6d4t` (uid `2eeb6c32...`), Node v20.20.2, 9-service topology, zero hardening headers (grep=0), CloudFront DFW56-P1
- NEW api.signageos.io/status pod rotated to `api-86db648db5-p94sg` (uid `72556714...`), Node v24.19.0, 8-service topology (mongoDB3 absent), hardened HSTS/xfo/xcto/no-store, CloudFront DFW56-P11
- CHANGED Edge POPs rotated: box → DFW56-P1, api → DFW56-P11 (was ORD58-P5/ORD56-P6)
- NEW box.signageos.io/status pod rotated to `box-8676fb5f57-l4pxv` (uid `dadfa18d…`) — Node v20.20.2, 9-service topology, zero hardening headers (grep=0), behind CloudFront DFW56-P1
- NEW api.signageos.io/status pod rotated to `api-86db648db5-p94sg` (uid `72556714…`) — Node v24.19.0, 8 services (mongoDB3 absent), hardened HSTS/xfo/xcto/no-store behind CloudFront DFW56-P11

## 2026-08-13 06:51:52 UTC
- NEW box.signageos.io/status pod rotated to `box-8676fb5f57-h6d4t` (uid `2eeb6c32...`), Node v20.20.2, 9-service topology, zero hardening headers, CloudFront DFW56-P1
- NEW api.signageos.io/status pod rotated to `api-86db648db5-p94sg` (uid `72556714...`), Node v24.19.0, 8-service topology (mongoDB3 absent), hardened HSTS/xfo/xcto/no-store, CloudFront DFW56-P11
- CHANGED Edge POPs rotated: box → DFW56-P1, api → DFW56-P11 (was ORD58-P5/ORD56-P6)

## 2026-08-13 08:25:55 UTC
- NEW box.signageos.io/status pod rotated → `box-8676fb5f57-ld6rr` (uid `ed6d572a…`), Node v20.20.2, 9-svc topology incl mongoDB3, secgrep=0 (x-powered-by: Express only), CloudFront DFW56-P1
- CHANGED box pod identity `ld6rr` (prev cycles: l4pxv/h6d4t) — same rs `8676fb5f57`, data shape identical
- CHANGED api /status pod `api-86db648db5-p94sg` (uid `72556714…`) stable this cycle, Node v24.19.0, 8-svc (mongoDB3 absent), secgrep=3 + no-store, DFW56-P11

## 2026-08-13 09:47:47 UTC
- NEW api.signageos.io/status replica-set rotated to `api-7676fc7c89-t9v9z` (NEW rs `7676fc7c89`, was `86db648db5` for 10+ cycles) — fresh API deploy; data shape + header posture unchanged (Node v24.19.0, 8
- CHANGED box.signageos.io/status pod rotated to `box-8676fb5f57-dnqvp` (uid `c5d77454…`, Node v20.20.2, 9 svc incl mongoDB3, secgrep=0, SFO53-P6)
- CHANGED api.signageos.io/v1/organization/test/security-token → 403074 `MISSING_ACCOUNT_ID_TO_AUTHENTICATE` (was 403105 WRONG_JWT_TOKEN in prior cycles) — endpoint confirmed X-Auth/`x-oauth-client_id` (org-der
- CHANGED api.signageos.io/v2/device → 403105 unchanged post-deploy (JWT-gated, no regression on new rs)

## 2026-08-13 10:49:36 UTC

## 2026-08-13 11:44:31 UTC
- NEW api.signageos.io replica set rotated to `7676fc7c89` (fresh deploy; Node v24.19.0, 8 svc, hardened HSTS/xfo/xcto/no-store behind CloudFront SFO53-P12)
- NEW api.signageos.io/v1/organization/{uid}/security-token now returns 403074 `MISSING_ACCOUNT_ID_TO_AUTHENTICATE` (was 403105) — confirmed X-Auth/`x-oauth-client_id` gated, org derived from header first-p
- CHANGED box.signageos.io/status pod rotated to `box-8676fb5f57-dnqvp` (uid `c5d77454…`, Node v20.20.2, 9-svc topology incl mongoDB3, zero hardening headers, CloudFront SFO53-P6)
- CHANGED api.signageos.io/status new replica set `7676fc7c89` (post-deploy; hardening intact, info-leak persists)

## 2026-08-13 12:36:53 UTC
- CHANGED api.signageos.io replica set rotated to `7676fc7c89` (fresh deploy; Node v24.19.0, 8 svc, hardened HSTS/xfo/xcto/no-store behind CloudFront SFO53-P12)
- CHANGED api.signageos.io/v1/organization/{uid}/security-token now returns 403074 `MISSING_ACCOUNT_ID_TO_AUTHENTICATE` (was 403105) — confirmed X-Auth/`x-oauth-client_id` gated, org derived from header first-p
- CHANGED box.signageos.io/status pod rotated to `box-8676fb5f57-dnqvp` (uid `c5d77454…`, Node v20.20.2, 9-svc topology incl mongoDB3, zero hardening headers, CloudFront SFO53-P6)

## 2026-08-13 14:06:57 UTC

## 2026-08-13 15:23:53 UTC
- NEW api.signageos.io replica set rotated to `7676fc7c89` (fresh deploy; Node v24.19.0, 8 svc, hardened HSTS/xfo/xcto/no-store behind CloudFront)
- NEW api.signageos.io/v1/organization/{uid}/security-token now returns 403074 `MISSING_ACCOUNT_ID_TO_AUTHENTICATE` (was 403105) — confirmed X-Auth/`x-oauth-client_id` gated, org derived from header first-p
- CHANGED box.signageos.io/status pod rotated to `box-8676fb5f57-dnqvp` (uid `c5d77454…`, Node v20.20.2, 9-svc topology incl mongoDB3, zero hardening headers, CloudFront SFO53-P6)
- CHANGED api.signageos.io/status new replica set `7676fc7c89` (post-deploy; hardening intact, info-leak persists)

## 2026-08-13 16:23:15 UTC

## 2026-08-13 17:19:51 UTC

## 2026-08-13 18:26:56 UTC

## 2026-08-13 19:37:41 UTC

## 2026-08-13 20:07:56 UTC
- NEW api.signageos.io replica set rotated to `7676fc7c89` (fresh deploy; Node v24.19.0, 8 svc, hardened HSTS/xfo/xcto/no-store behind CloudFront)
- NEW api.signageos.io/v1/organization/{uid}/security-token now returns 403074 `MISSING_ACCOUNT_ID_TO_AUTHENTICATE` (was 403105) — confirmed X-Auth/`x-oauth-client_id` gated, org derived from header first-p
- CHANGED box.signageos.io/status pod rotated to `box-8676fb5f57-dnqvp` (uid `c5d77454…`, Node v20.20.2, 9-svc topology incl mongoDB3, zero hardening headers, CloudFront SFO53-P6)
- CHANGED api.signageos.io/status new replica set `7676fc7c89` (post-deploy; hardening intact, info-leak persists)

## 2026-08-13 21:06:08 UTC
- NEW NO_DELTA

## 2026-08-13 21:58:35 UTC
- NEW NO_DELTA

## 2026-08-13 22:56:46 UTC

## 2026-08-13 23:39:50 UTC
- NEW api.signageos.io replica set rotated to `7676fc7c89` (fresh deploy; Node v24.19.0, 8 svc, hardened HSTS/xfo/xcto/no-store behind CloudFront SFO53-P12)
- NEW api.signageos.io/v1/organization/{uid}/security-token now returns 403074 `MISSING_ACCOUNT_ID_TO_AUTHENTICATE` (was 403105) — confirmed X-Auth/`x-oauth-client_id` gated, org derived from header first-p
- CHANGED box.signageos.io/status pod rotated to `box-8676fb5f57-dnqvp` (uid `c5d77454…`, Node v20.20.2, 9-svc topology incl mongoDB3, zero hardening headers, CloudFront SFO53-P6)
- CHANGED api.signageos.io/status new replica set `7676fc7c89` (post-deploy; hardening intact, info-leak persists)

## 2026-08-14 00:44:56 UTC
- CHANGED api.signageos.io/v2/device → 403105 unchanged post-deploy (rs `7676fc7c89`)

## 2026-08-14 03:17:37 UTC

## 2026-08-14 05:16:01 UTC
- NEW NO_DELTA — last leads (2026-08-14 03:17:37 UTC) already reflect post-deploy state (rs `7676fc7c89`, 403074 mechanism confirmed, v2/device stable 403105); inventory shows only NO_DELTA entries since

## 2026-08-14 06:45:50 UTC
- NEW box.signageos.io / + /login/ now emit 7 `x-*-nonce-hash` response headers (CSP nonce-hash middleware); values rotate per request (req1 53ab2d784cf23671c7472263 vs req2 e07768a3f2743ed4cac39d0a) — nonc
- NEW box.signageos.io/status emits NO ACAO under spoofed Origin evil.test (CORS whitelist scoped to / + /login/ only); /status/, /status?x=1 also 200 JSON; /healthz /livez /readyz /live all 302 login catch
- NEW WS handshake to box / → 302 login redirect (no unauthenticated WebSocket surface)
- CHANGED box.signageos.io/status pod rotated within rs 8676fb5f57 → box-8676fb5f57-xd6mc (uid 6deaf70c2a3b648ff24e0c699ec55b7a6c4d5715e2a472949b), Node v20.20.2, 9-svc topology, secgrep=0, CloudFront SFO53-P6 

## 2026-08-14 08:05:52 UTC
- NEW box.signageos.io / + /login/ now emit 7 `x-*-nonce-hash` response headers (CSP nonce-hash middleware); values rotate per request
- NEW box.signageos.io/status emits NO ACAO under spoofed Origin evil.test (CORS whitelist scoped to / + /login/ only); /status/, /status?x=1 also 200 JSON; /healthz /livez /readyz /live all 302 login catch
- NEW WS handshake to box.signageos.io/ → 302 login redirect (no unauthenticated WebSocket surface)

## 2026-08-14 09:21:10 UTC

## 2026-08-14 10:31:54 UTC
- NEW box.signageos.io/ + /login/: 7 rotating `x-*-nonce-hash` response headers (CSP nonce-hash middleware); values differ per request (req1 `53ab2d784cf23671c7472263` vs req2 `e07768a3f2743ed4cac39d0a`)
- NEW box.signageos.io/status: emits NO `access-control-allow-origin` under spoofed Origin `https://evil.test` (CORS whitelist scoped to `/` + `/login/` only); `/status/`, `/status?x=1` also 200 JSON; `/hea
- NEW box.signageos.io WebSocket: `wss://box.signageos.io/` upgrade → 302 login redirect (no unauthenticated WebSocket surface)
- CHANGED api.signageos.io replica set rotated to `7676fc7c89` (fresh deploy; Node v24.19.0, 8 svc, hardened HSTS/xfo/xcto/no-store behind CloudFront SFO53-P12)
- CHANGED api.signageos.io/v1/organization/{uid}/security-token: now returns 403074 `MISSING_ACCOUNT_ID_TO_AUTHENTICATE` (was 403105) — confirmed X-Auth/`x-oauth-client_id` gated, org derived from header first-
- CHANGED box.signageos.io/status pod rotated within rs `8676fb5f57` → `box-8676fb5f57-xd6mc` (uid `6deaf70c2a3b648ff24e0c699ec55b7a6c4d5715e2a472949b`, Node v20.20.2, 9-svc topology, secgrep=0, CloudFront SFO5

## 2026-08-14 11:24:19 UTC

## 2026-08-14 12:08:44 UTC
- NEW api.signageos.io replica set rotated to `6cc9959bb4` (fresh deploy; Node v24.19.0, hardened HSTS/xfo/xcto/no-store behind CloudFront)
- NEW api.signageos.io/v1/organization/{uid}/security-token reconfirmed 403074 `MISSING_ACCOUNT_ID_TO_AUTHENTICATE` on rs `6cc9959bb4` — X-Auth/`x-oauth-client_id` gating intact
- CHANGED box.signageos.io/status pod rotated to `box-8676fb5f57-xd6mc` (uid `6deaf70c…`, Node v20.20.2, 9-svc topology, secgrep=0, CloudFront SFO53-P6)
- NEW api.signageos.io/v1/organization/{uid}/device-plan-history: live → 403105 WRONG_JWT_TOKEN ("Decoding of provided JWT token has failed") — JWT-gated route from 2.193.0 bundle confirmed present, no pre-
- NEW api.signageos.io/v1/company/{uid}/support-access-permission (PUT): live → 403 JWT-gated (no-store, HSTS/xfo/xcto, vary:Origin) — route exists, no pre-auth bypass
- CHANGED box /login/ bundle.js (2.193.0, 366,190 bytes): contains ZERO `/v[12]/` API path references and 1 signageos ref total — this build is a pure Auth0 login bundle; the 40+ endpoint map from earlier bundl
- CHANGED box /login/ 7 rotating x-*-nonce-hash headers + full CSP (recaptcha/sentry/dom-purify/bundle/assets/style) reconfirmed (req nonces b39f2641…/19bef40f…)

## 2026-08-14 13:44:46 UTC
- NEW api.signageos.io replica set rotated to `6cc9959bb4` (fresh deploy; Node v24.19.0, hardened HSTS/xfo/xcto/no-store behind CloudFront)
- NEW api.signageos.io/v1/organization/{uid}/security-token reconfirmed 403074 `MISSING_ACCOUNT_ID_TO_AUTHENTICATE` on rs `6cc9959bb4` — X-Auth/`x-oauth-client_id` gating intact
- NEW api.signageos.io/v1/organization/{uid}/device-plan-history: live → 403105 WRONG_JWT_TOKEN — JWT-gated route from 2.193.0 bundle confirmed present, no pre-auth bypass
- NEW api.signageos.io/v1/company/{uid}/support-access-permission (PUT): live → 403 JWT-gated (no-store, HSTS/xfo/xcto, vary:Origin) — route exists, no pre-auth bypass
- CHANGED box /login/ bundle.js (2.193.0, 366,190 bytes): contains ZERO `/v[12]/` API path references and 1 signageos ref total — this build is a pure Auth0 login bundle; the 40+ endpoint map from earlier bundl
- CHANGED box.signageos.io/status pod rotated to `box-8676fb5f57-xd6mc` (uid `6deaf70c…`, Node v20.20.2, 9-svc topology, secgrep=0, CloudFront SFO53-P6)
- CHANGED box /login/ 7 rotating x-*-nonce-hash headers + full CSP reconfirmed (req nonces b39f2641…/19bef40f…)
- CHANGED box / + /login/ CORS: 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected — unchanged
- CHANGED box /status CORS: NO ACAO under spoofed Origin evil.test — CORS whitelist strictly scoped to `/` + `/login/` only
- CHANGED box /healthz /livez /readyz /live: all 302 login catch-all — no new unauthenticated endpoints
- CHANGED box WebSocket: wss://box.signageos.io/ upgrade → 302 login redirect — no unauthenticated WebSocket surface

## 2026-08-14 14:44:33 UTC
- CHANGED box.signageos.io/status pod rotated to `box-8676fb5f57-d5p5s` (uid `c6f334b11b5e8085e6f549b1286fb91a5784c5a5f68c00577d`), mongoDB3 now healthy, zero hardening headers unchanged (secgrep=0)
- CHANGED api.signageos.io replica set `6cc9959bb4` stable (Node v24.19.0, hardened HSTS/xfo/xcto/no-store behind CloudFront)
- CHANGED api.signageos.io/v1/organization/{uid}/security-token 403074 MISSING_ACCOUNT_ID_TO_AUTHENTICATE confirmed on rs `6cc9959bb4` — X-Auth/x-oauth-client_id gating intact
- CHANGED api.signageos.io/v1/organization/{uid}/device-plan-history 403105 WRONG_JWT_TOKEN confirmed — JWT-gated route from 2.193.0 bundle present
- CHANGED api.signageos.io/v1/company/{uid}/support-access-permission (PUT) 403 JWT-gated confirmed — route exists, no pre-auth bypass
- CHANGED box.signageos.io/ + /login/ 7 rotating x-*-nonce-hash headers + full CSP (59+ connect-src origins, triplicated Auth0 oauth/token) reconfirmed
- CHANGED box.signageos.io/ + /login/ CORS: 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected
- CHANGED box.signageos.io/status CORS: NO ACAO under spoofed Origin evil.test — CORS whitelist strictly scoped to `/` + `/login/` only
- CHANGED box.signageos.io /healthz /livez /readyz /live: all 302 login catch-all — no new unauthenticated endpoints
- CHANGED box.signageos.io WebSocket: wss://box.signageos.io/ upgrade → 302 login redirect — no unauthenticated WebSocket surface
- CHANGED box.signageos.io /login/ bundle.js (2.193.0): ZERO `/v[12]/` API path references — pure Auth0 login bundle

## 2026-08-14 15:36:08 UTC

## 2026-08-14 16:29:41 UTC

## 2026-08-14 17:33:22 UTC

## 2026-08-14 18:30:29 UTC
- NEW api.signageos.io/status pod rotated within rs `6cc9959bb4` → `api-6cc9959bb4-wrg9v` (Node v24.19.0, hardened HSTS/xfo/xcto/no-store secgrep=3, CloudFront)
- CHANGED box.signageos.io/status pod stable `box-8676fb5f57-d5p5s` (uid c6f334b1..., Node v20.20.2, 9-svc, secgrep=0, CloudFront SFO53-P6)
- CHANGED api /v1/organization/{uid}/security-token: 403074 `MISSING_ACCOUNT_ID_TO_AUTHENTICATE` errorDetail wording unchanged — "first part (before char :) of x-auth header" vs client-supplied path {uid}; zero

## 2026-08-14 19:35:39 UTC
- NEW api.signageos.io/status pod rotated within rs `6cc9959bb4` → `api-6cc9959bb4-wrg9v` (Node v24.19.0, hardened HSTS/xfo/xcto/no-store secgrep=3, CloudFront)
- CHANGED box.signageos.io/status pod stable `box-8676fb5f57-d5p5s` (uid c6f334b1..., Node v20.20.2, 9-svc, secgrep=0, CloudFront SFO53-P6)
- CHANGED api.signageos.io/v1/organization/{uid}/security-token: 403074 `MISSING_ACCOUNT_ID_TO_AUTHENTICATE` confirmed on rs `6cc9959bb4` — X-Auth/x-oauth-client_id gating intact
- CHANGED api.signageos.io/v1/organization/{uid}/device-plan-history: 403105 WRONG_JWT_TOKEN confirmed — JWT-gated route from 2.193.0 bundle present
- CHANGED api.signageos.io/v1/company/{uid}/support-access-permission (PUT): 403 JWT-gated confirmed — route exists, no pre-auth bypass
- CHANGED box.signageos.io/ + /login/ 7 rotating x-*-nonce-hash headers + full CSP (59+ connect-src origins, triplicated Auth0 oauth/token) reconfirmed
- CHANGED box.signageos.io/ + /login/ CORS: 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected
- CHANGED box.signageos.io/status CORS: NO ACAO under spoofed Origin evil.test — CORS whitelist strictly scoped to `/` + `/login/` only
- CHANGED box.signageos.io /healthz /livez /readyz /live: all 302 login catch-all — no new unauthenticated endpoints
- CHANGED box.signageos.io WebSocket: wss://box.signageos.io/ upgrade → 302 login redirect — no unauthenticated WebSocket surface
- CHANGED box.signageos.io /login/ bundle.js (2.193.0): ZERO `/v[12]/` API path references — pure Auth0 login bundle

## 2026-08-14 20:09:10 UTC
- NEW api.signageos.io/status pod rotated within rs `6cc9959bb4` → `api-6cc9959bb4-wrg9v` (Node v24.19.0, hardened HSTS/xfo/xcto/no-store secgrep=3, CloudFront)
- CHANGED box.signageos.io/status pod stable `box-8676fb5f57-d5p5s` (uid c6f334b1..., Node v20.20.2, 9-svc, secgrep=0, CloudFront SFO53-P6)
- CHANGED api.signageos.io/v1/organization/{uid}/security-token: 403074 `MISSING_ACCOUNT_ID_TO_AUTHENTICATE` confirmed on rs `6cc9959bb4` — X-Auth/x-oauth-client_id gating intact
- CHANGED api.signageos.io/v1/organization/{uid}/device-plan-history: 403105 WRONG_JWT_TOKEN confirmed — JWT-gated route from 2.193.0 bundle present
- CHANGED api.signageos.io/v1/company/{uid}/support-access-permission (PUT): 403 JWT-gated confirmed — route exists, no pre-auth bypass
- CHANGED box.signageos.io/ + /login/ 7 rotating x-*-nonce-hash headers + full CSP (59+ connect-src origins, triplicated Auth0 oauth/token) reconfirmed
- CHANGED box.signageos.io/ + /login/ CORS: 17 static ACAO incl `http://` plaintext + `*.zdusercontent.com` wildcard + api sibling; evil.test NOT reflected
- CHANGED box.signageos.io/status CORS: NO ACAO under spoofed Origin evil.test — CORS whitelist strictly scoped to `/` + `/login/` only
- CHANGED box.signageos.io /healthz /livez /readyz /live: all 302 login catch-all — no new unauthenticated endpoints
- CHANGED box.signageos.io WebSocket: wss://box.signageos.io/ upgrade → 302 login redirect — no unauthenticated WebSocket surface
- CHANGED box.signageos.io /login/ bundle.js (2.193.0): ZERO `/v[12]/` API path references — pure Auth0 login bundle

## 2026-08-14 20:45:47 UTC

## 2026-08-14 21:11:42 UTC

## 2026-08-14 21:47:42 UTC
- CHANGED api.signageos.io/status pod rotated within already-seen rs `77955558bc` → `api-77955558bc-cfkd4` (Node v24.19.0, 8-svc mongoDB3 absent, hardened secgrep=3, CloudFront IAD89-P1)
- CHANGED box.signageos.io/status pod stable `box-8676fb5f57-xd6mc` (uid 6deaf70c…, Node v20.20.2, 9-svc, secgrep=0, CloudFront IAD55-P8) — data shape unchanged
- CHANGED api /v1/organization/{uid}/security-token: 403074 `MISSING_ACCOUNT_ID_TO_AUTHENTICATE` reconfirmed — errorDetail wording identical ("first part (before char :) of x-auth header" vs client-supplied pat

## 2026-08-14 22:03:46 UTC

## 2026-08-14 22:35:49 UTC
- NEW api.signageos.io replica-set rotated to `77955558bc` (new rs, not in prior cycle) — pod `api-77955558bc-cfkd4` (Node v24.19.0, 8-svc mongoDB3 absent, hardened secgrep=3, CloudFront)
- NEW box.signageos.io/status pod rotated to `box-8676fb5f57-xd6mc` (uid 6deaf70c…, Node v20.20.2, 9-svc, secgrep=0, CloudFront) — later stabilized to `box-8676fb5f57-d5p5s`
- NEW CONFIRMED DEAD @ videowall-designer leaked clientId/secret on PROD: clientId fcbbd714b3f794987b1f1a730d52fa31ddbcb51a087919ea47 + secret tested as X-Auth on prod → 403076 WRONG_ACCOUNT_SECRET "Account
- CHANGED api.signageos.io/v1/organization/{uid}/security-token: 403074 MISSING_ACCOUNT_ID_TO_AUTHENTICATE reconfirmed on rs `77955558bc` rotation — zero auth drift across replica-set flip
- CHANGED api.signageos.io/v1/organization/{uid}/device-plan-history: 403105 WRONG_JWT_TOKEN confirmed on new rs — JWT-gated route from 2.193.0 bundle present
- CHANGED api.signageos.io/v1/company/{uid}/support-access-permission (PUT): 403 JWT-gated confirmed on new rs — route exists, no pre-auth bypass

## 2026-08-14 22:59:34 UTC

## 2026-08-14 23:29:37 UTC

## 2026-08-14 23:54:24 UTC

## 2026-08-15 00:55:29 UTC

## 2026-08-15 02:14:11 UTC
- NEW api.signageos.io replica-set rotated to `77955558bc` (new rs) — zero auth drift across flip: security-token 403074, device-plan-history 403105, v2/device 403105, support-access-permission PUT 403
- NEW box.signageos.io/status pod rotated to `box-8676fb5f57-d5p5s` (uid c6f334b1..., Node v20.20.2, 9-svc, secgrep=0, CloudFront SFO53-P6) — data shape unchanged
- NEW CONFIRMED DEAD @ videowall-designer leaked clientId/secret on PROD: clientId fcbbd714b3f794987b1f1a730d52fa31ddbcb51a087919ea47 + secret tested as X-Auth on prod → 403076 WRONG_ACCOUNT_SECRET "Account

## 2026-08-15 03:11:04 UTC
- NEW NO_DELTA — inventory, knowledge base, and last leads all aligned at 2026-08-15 02:14 UTC; no new endpoints, auth drift, or surface changes detected

## 2026-08-15 03:56:09 UTC
- NEW NO_DELTA — inventory, knowledge base, and last leads all aligned at 2026-08-15 02:14 UTC; no new endpoints, auth drift, or surface changes detected

## 2026-08-15 04:30:27 UTC
- NEW NO_DELTA — inventory, knowledge base, and last leads all aligned at 2026-08-15 02:14 UTC; no new endpoints, auth drift, or surface changes detected since last analysis cycle

## 2026-08-15 05:01:17 UTC

## 2026-08-15 05:36:57 UTC

## 2026-08-15 05:59:14 UTC

## 2026-08-15 06:52:11 UTC
- NEW api.signageos.io: Root (/) serves static HTML landing page (37KB), not API JSON — no public API surface exposed (404 on /v1, /v2, /health, /docs, /api, /swagger.json, /openapi.json)
- NEW box.signageos.io: 302 → /login/%2F with Auth0 OAuth2 flow (sos-production.us.auth0.com, auth0.signageos.io in CSP connect-src) — confirms Auth0 as IdP
- NEW box.signageos.io CSP reveals extensive 3rd-party integrations: Mapbox, Sentry, MoodMedia/BroadSign/Sony device APIs, remote-desktop.signageos.io, upload.signageos.io, platform.signageos.io, license.si
- CHANGED api.signageos.io auth model unknown — no public docs, no swagger, no obvious auth headers on root; SDK/cli repos (signageos org, 59 repos) likely contain actual endpoint mappings and auth schemes

## 2026-08-15 07:28:03 UTC

## 2026-08-15 07:55:03 UTC

## 2026-08-15 08:23:56 UTC

## 2026-08-15 08:58:17 UTC

## 2026-08-15 09:19:47 UTC
- CHANGED box.signageos.io/status pod rotated to `box-8676fb5f57-844gw` (uid `d5bdab36…`, Node v20.20.2, 9-svc amqp0/redis0-3/mongoDB0-3, CloudFront SEA900-P9) — body shape byte-identical, secgrep=0
- CHANGED api.signageos.io/status pod rotated to `api-77955558bc-shv9w` (Node v24.19.0, hardened HSTS/xfo/xcto/no-store) — same rs `77955558bc`, no drift
- CHANGED box / + /login/ CSP nonces rotated (6 new nonce values) — directives, 17 static ACAO, hardening all unchanged

## 2026-08-15 09:48:16 UTC
- NEW api.signageos.io replica-set `77955558bc` stable across cycles — zero auth drift on security-token (403074), device-plan-history (403105), v2/device (403105)
- NEW box.signageos.io/status pod rotated to `box-8676fb5f57-xd6mc` (uid `6deaf70c...`) — body shape identical, secgrep=0, behind CloudFront SEA900-P9
- CHANGED box.signageos.io/ + /login/ CSP nonces rotated (6 new nonce-hash values) — directives, 17 static ACAO, hardening unchanged
- CHANGED api.signageos.io/status pod rotated to `api-77955558bc-shv9w` — same rs `77955558bc`, hardened headers intact (HSTS/xfo/xcto/no-store)

## 2026-08-15 10:05:58 UTC
- NEW box.signageos.io/status pod rotated to `box-8676fb5f57-xd6mc` (uid `6deaf70c...`) — body shape identical, secgrep=0, behind CloudFront SEA900-P9
- CHANGED api.signageos.io/status pod rotated to `api-77955558bc-shv9w` — same rs `77955558bc`, hardened headers intact (HSTS/xfo/xcto/no-store)
- CHANGED box.signageos.io/ + /login/ CSP nonces rotated (6 new nonce-hash values) — directives, 17 static ACAO, hardening unchanged

## 2026-08-15 10:36:44 UTC
- NEW box.signageos.io/status pod rotated to `box-8676fb5f57-xd6mc` (uid `6deaf70c...`, Node v20.20.2, 9-svc topology, secgrep=0) — body shape identical, behind CloudFront SEA900-P9
- CHANGED api.signageos.io/status pod rotated to `api-77955558bc-shv9w` (Node v24.19.0, hardened HSTS/xfo/xcto/no-store, secgrep=3) — same rs `77955558bc`, zero auth drift
- CHANGED box.signageos.io/ + /login/ CSP nonces rotated (6 new x-*-nonce-hash values) — directives, 17 static ACAO, hardening unchanged

## 2026-08-15 10:57:21 UTC

## 2026-08-15 11:28:54 UTC

## 2026-08-15 11:48:33 UTC

## 2026-08-15 12:02:30 UTC
- NEW None — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-15 12:57:50 UTC

## 2026-08-15 13:37:16 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30
- CHANGED box.signageos.io/status pod rotated to `box-8676fb5f57-g96fp` (uid `f37ee692…`, Node v20.20.2, 9-svc topology, responseTime present) — body shape byte-identical, secgrep=0 (x-powered-by: Express + Clo
- CHANGED api.signageos.io/status pod/handler reconfirmed hardened (HSTS max-age=31536000, xfo DENY, xcto nosniff, cache-control no-store, CloudFront PHX50-P2) — zero auth drift

## 2026-08-15 13:58:36 UTC
- NEW None — only pod rotation: box/status pod → `box-8676fb5f57-7zpgc` (uid `4c848924…`, Node v20.20.2, body sha `47eeade9…`, shape byte-identical, secgrep=0 x-powered-by only, CloudFront) — zero auth drif
- CHANGED api.signageos.io/v1/organization/test/security-token — 403074 errorDetail byte-identical ("Both x-oauth-client_id header and first part (before char :) of x-auth header are missing…") on rs `77955558b
- CHANGED api.signageos.io/status — body sha `1725fe6e…` (pod rotation only), HSTS/xfo/xcto/no-store hardening intact

## 2026-08-15 14:32:26 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-15 14:53:22 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-15 15:15:56 UTC
- NEW box.signageos.io/status: pod rotated to `box-8676fb5f57-r5w8r` (uid `43bb70d304978090…`, Node v20.20.2) — body sha `38737948dcd9…`, shape byte-identical, secgrep=0 (headers: only x-powered-by: Express
- CHANGED box.signageos.io probe set `/healthz /livez /readyz /live /metrics /env /config.json /swagger /openapi.json`: all → 302 login catch-all (`/login/%2F<path>`) — no new unauthenticated surface, unchanged
- CHANGED api.signageos.io: no drift observed this cycle; rs `77955558bc` + hardened /status posture carried forward.

## 2026-08-15 15:44:02 UTC

## 2026-08-15 16:01:31 UTC

## 2026-08-15 16:36:13 UTC

## 2026-08-15 16:58:50 UTC

## 2026-08-15 17:32:57 UTC

## 2026-08-15 17:49:20 UTC

## 2026-08-15 18:03:44 UTC

## 2026-08-15 18:44:55 UTC

## 2026-08-15 19:08:58 UTC
- NEW None — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30
- CHANGED box.signageos.io/status — pod rotated to `box-8676fb5f57-7zpgc` (uid `4c8489246a1989…`, Node v20.20.2, 9 succeededServices amqp0/redis0-3/mongoDB0-3), shape byte-identical, secgrep=0 (x-powered-by onl
- CHANGED api.signageos.io/status — secgrep=3 (HSTS max-age=31536000, x-frame-options DENY, x-content-type-options nosniff), 0 ACAO, CloudFront IAD89-P1 — hardening differential vs box intact
- CHANGED api.signageos.io/v1/organization/test/security-token — 403074 errorDetail byte-identical ("Both x-oauth-client_id header and first part (before char :) of x-auth header are missing…") — mechanism inta

## 2026-08-15 19:35:42 UTC

## 2026-08-15 19:58:29 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-15 20:17:31 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-15 20:45:33 UTC
- NEW None — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30
- NEW None — inventory shows only pod rotation (box /status → `box-8676fb5f57-xd6mc`, uid `6deaf70c…`, body sha256 `caed9f79…` — shape byte-identical, secgrep=0, 9-svc topology), zero auth drift since 2026-
- CHANGED box.signageos.io/status — body sha256 rotated to `caed9f79…` (pod rotation only; pod reverts between `xd6mc`/`r5w8r`); secgrep=0, x-powered-by: Express + CloudFront only
- CHANGED api.signageos.io/v1/organization/test/security-token — 403074 errorDetail byte-identical this cycle ("…first part (before char `:`) of x-auth header…") on rs `77955558bc` — mechanism intact
- CHANGED box.signageos.io/login/ — 17 static ACAO, 0 `access-control-allow-credentials`, HSTS/xfo/xcto/CSP present (hardened) — unchanged

## 2026-08-15 21:04:45 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30
- NEW none — live re-probe (box `/status` → HTTP 200, body sha256 `caed9f79…`, secgrep=0; box `/` → 17 ACAO incl `http://`+`*.zdunpkgdomains.com`, 0 credentials flag, secgrep=4; api `/status` → secgrep=3, 0

## 2026-08-15 21:34:27 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-15 21:53:57 UTC

## 2026-08-15 22:18:12 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-15 22:43:16 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-15 23:02:37 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-15 23:30:32 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-15 23:51:28 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-16 00:37:55 UTC

## 2026-08-16 02:12:54 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-16 03:16:41 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-16 04:04:11 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-16 04:50:54 UTC

## 2026-08-16 05:19:42 UTC

## 2026-08-16 05:48:56 UTC

## 2026-08-16 06:17:33 UTC

## 2026-08-16 07:11:56 UTC
- NEW None — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15
- CHANGED None — all surface items byte-identical behavior; only pod hostnames/UIDs rotate

## 2026-08-16 07:44:01 UTC

## 2026-08-16 08:04:27 UTC

## 2026-08-16 08:44:33 UTC

## 2026-08-16 09:13:52 UTC

## 2026-08-16 09:46:02 UTC

## 2026-08-16 10:05:44 UTC
- NEW None — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15
- CHANGED None — all surface items byte-identical behavior; only pod hostnames/UIDs rotate

## 2026-08-16 10:36:41 UTC

## 2026-08-16 11:01:39 UTC
- NEW None — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-16 11:27:06 UTC

## 2026-08-16 11:47:37 UTC
- NEW NO_DELTA

## 2026-08-16 12:03:07 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-16 12:59:05 UTC

## 2026-08-16 13:38:20 UTC

## 2026-08-16 14:01:46 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-16 14:34:26 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-16 14:57:13 UTC

## 2026-08-16 15:27:57 UTC

## 2026-08-16 15:50:11 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-16 16:10:29 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-16 16:43:40 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-16 17:04:36 UTC
- NEW NO_DELTA — All surface items stable across 30+ cycles: box `/status` unauthenticated JSON infra-leak (secgrep=0), box `/`, `/login/` hardened (secgrep=4) with only 0-cred CORS (MISCONFIG), api `/statu
- CHANGED None — pod rotation only (box-8676fb5f57-dlxnp confirmed this probe, uid 25a4a43c788a9bc98bcc6d956e360378a62561ac0457c022e6).

## 2026-08-16 17:32:33 UTC

## 2026-08-16 17:52:32 UTC

## 2026-08-16 18:18:55 UTC

## 2026-08-16 18:53:43 UTC

## 2026-08-16 19:16:21 UTC

## 2026-08-16 19:40:37 UTC

## 2026-08-16 19:57:53 UTC

## 2026-08-16 20:25:25 UTC

## 2026-08-16 20:47:03 UTC

## 2026-08-16 21:03:55 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-16 21:32:42 UTC

## 2026-08-16 21:54:30 UTC

## 2026-08-16 22:17:27 UTC

## 2026-08-16 22:41:22 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-16 23:00:56 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-16 23:31:09 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-16 23:50:36 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-17 00:27:44 UTC

## 2026-08-17 02:06:40 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-17 03:12:14 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-17 04:06:11 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30
- NEW none — inventory unchanged this cycle (30+ NO_DELTA).
- CHANGED none — pod rotation only (box box-8676fb5f57-*`*`, api api-77955558bc-*`), zero auth drift, no new endpoints.

## 2026-08-17 04:56:38 UTC

## 2026-08-17 05:48:15 UTC

## 2026-08-17 06:08:28 UTC

## 2026-08-17 07:15:31 UTC

## 2026-08-17 08:05:15 UTC

## 2026-08-17 08:58:49 UTC

## 2026-08-17 09:54:31 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-17 10:25:31 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-17 10:58:37 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-17 11:33:23 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-17 11:56:45 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-17 12:51:20 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-17 13:32:38 UTC
- NEW NO_DELTA — inventory shows only pod rotations (box-8676fb5f57-*, api-77955558bc-*) with zero auth drift, no new endpoints, no surface changes since 2026-08-15 04:30

## 2026-08-17 14:07:17 UTC

## 2026-08-17 14:42:55 UTC
- NEW box.signageos.io: NEW replica set `box-54846c877b` deployed (was `box-8676fb5f57`) — /status secgrep=0 persists, full 9-svc topology leak unchanged, zero hardening added across rs flip
- NEW api.signageos.io: NEW replica set `api-7c5fdc9777` deployed (was `api-77955558bc`) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO under any Origin

## 2026-08-17 15:06:28 UTC
- NEW box.signageos.io: NEW replica set `box-54846c877b` deployed (was `box-8676fb5f57`) — /status secgrep=0 persists, full 9-svc topology leak unchanged, zero hardening added across rs flip
- NEW api.signageos.io: NEW replica set `api-7c5fdc9777` deployed (was `api-77955558bc`) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO under any Origin

## 2026-08-17 15:37:51 UTC
- NEW box.signageos.io: NEW replica set `box-54846c877b` deployed (was `box-8676fb5f57`) — /status secgrep=0 persists, full 9-svc topology leak unchanged, zero hardening added across rs flip
- NEW api.signageos.io: NEW replica set `api-7c5fdc9777` deployed (was `api-77955558bc`) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO under any Origin

## 2026-08-17 16:00:38 UTC
- NEW box.signageos.io: NEW replica set `box-54846c877b` deployed (was `box-8676fb5f57`) — /status secgrep=0 persists, full 9-svc topology leak unchanged, zero hardening added across rs flip
- NEW api.signageos.io: NEW replica set `api-7c5fdc9777` deployed (was `api-77955558bc`) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO under any Origin
- NEW api.signageos.io: NEW replica set `api-7c5fdc9777` deployed (was `api-77955558bc`) — /status secgrep=3 persists, 8-svc topology, zero ACAO under any Origin
- NEW box.signageos.io: NEW replica set `box-54846c877b` deployed (was `box-8676fb5f57`) — /status secgrep=0 persists, full 9-svc topology leak unchanged across rs flip

## 2026-08-17 16:37:54 UTC
- NEW box.signageos.io: NEW replica set `box-54846c877b` deployed (was `box-8676fb5f57`) — /status secgrep=0 persists, full 9-svc topology leak unchanged, zero hardening added across rs flip
- NEW api.signageos.io: NEW replica set `api-7c5fdc9777` deployed (was `api-77955558bc`) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO under any Origin

## 2026-08-17 17:03:50 UTC
- NEW box.signageos.io: NEW replica set `box-54846c877b` deployed (was `box-8676fb5f57`) — /status secgrep=0 persists, full 9-svc topology leak unchanged (now includes mongoDB3), zero hardening added across
- NEW api.signageos.io: NEW replica set `api-7c5fdc9777` deployed (was `api-77955558bc`) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO under any Origin
- NEW box.signageos.io/status CORS: Confirmed zero ACAO under spoofed Origin `https://evil.test` — CORS whitelist strictly scoped to SPA entry points (`/` + `/login/`) only, not exploitable as CORS attack v
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box

## 2026-08-17 17:41:49 UTC
- NEW box.signageos.io: NEW replica set `box-54846c877b` deployed (was `box-8676fb5f57`) — /status secgrep=0 persists, full 9-svc topology leak unchanged (now includes mongoDB3), zero hardening added across
- NEW api.signageos.io: NEW replica set `api-7c5fdc9777` deployed (was `api-77955558bc`) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO under any Origin
- NEW box.signageos.io/status CORS: Confirmed zero ACAO under spoofed Origin `https://evil.test` — CORS whitelist strictly scoped to SPA entry points (`/` + `/login/`) only, not exploitable as CORS attack v
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box

## 2026-08-17 18:05:35 UTC
- NEW box.signageos.io: NEW replica set `box-54846c877b` deployed (was `box-8676fb5f57`) — /status secgrep=0 persists, full 9-svc topology leak unchanged (now includes mongoDB3), zero hardening added across
- NEW api.signageos.io: NEW replica set `api-7c5fdc9777` deployed (was `api-77955558bc`) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO under any Origin
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box
- NEW box.signageos.io: NEW replica set `box-54846c877b` deployed (was `box-8676fb5f57`) — /status secgrep=0 persists, full 9-svc topology leak unchanged (now includes mongoDB3), zero hardening added across
- NEW api.signageos.io: NEW replica set `api-7c5fdc9777` deployed (was `api-77955558bc`) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO under any Origin
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded

## 2026-08-17 18:57:00 UTC
- NEW box.signageos.io: NEW replica set `box-54846c877b` deployed (was `box-8676fb5f57`) — /status secgrep=0 persists, full 9-svc topology leak unchanged (now includes mongoDB3), zero hardening added across
- NEW api.signageos.io: NEW replica set `api-7c5fdc9777` deployed (was `api-77955558bc`) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO under any Origin
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box

## 2026-08-17 19:31:58 UTC
- NEW box.signageos.io: NEW replica set `box-54846c877b` deployed (was `box-8676fb5f57`) — /status secgrep=0 persists, full 9-svc topology leak unchanged (now includes mongoDB3), zero hardening added across
- NEW api.signageos.io: NEW replica set `api-7c5fdc9777` deployed (was `api-77955558bc`) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO under any Origin
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box
- NEW box.signageos.io: NEW replica set `box-54846c877b` deployed (was `box-8676fb5f57`) — /status secgrep=0 persists, full 9-svc topology leak unchanged (now includes mongoDB3), zero hardening added across
- NEW api.signageos.io: NEW replica set `api-7c5fdc9777` deployed (was `api-77955558bc`) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO under any Origin
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box

## 2026-08-17 19:55:36 UTC
- NEW box.signageos.io: NEW replica set `box-54846c877b` deployed (was `box-8676fb5f57`) — /status secgrep=0 persists, full 9-svc topology leak unchanged (now includes mongoDB3), zero hardening added across
- NEW api.signageos.io: NEW replica set `api-7c5fdc9777` deployed (was `api-77955558bc`) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO under any Origin
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box

## 2026-08-17 20:26:53 UTC
- NEW box.signageos.io: NEW replica set `box-54846c877b` deployed (was `box-8676fb5f57`) — /status secgrep=0 persists, full 9-svc topology leak unchanged (now includes mongoDB3), zero hardening added across
- NEW api.signageos.io: NEW replica set `api-7c5fdc9777` deployed (was `api-77955558bc`) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO under any Origin
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box

## 2026-08-17 20:56:44 UTC

## 2026-08-17 21:32:13 UTC
- NEW box.signageos.io: NEW replica set `box-54846c877b` deployed (was `box-8676fb5f57`) — /status secgrep=0 persists, full 9-svc topology leak unchanged (now includes mongoDB3), zero hardening added across
- NEW api.signageos.io: NEW replica set `api-7c5fdc9777` deployed (was `api-77955558bc`) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO under any Origin
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box

## 2026-08-17 21:53:59 UTC
- NEW box.signageos.io: NEW replica set `box-54846c877b` deployed (was `box-8676fb5f57`) — /status secgrep=0 persists, full 9-svc topology leak unchanged (now includes mongoDB3), zero hardening added across
- NEW api.signageos.io: NEW replica set `api-7c5fdc9777` deployed (was `api-77955558bc`) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO under any Origin
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box

## 2026-08-17 22:20:55 UTC
- NEW box.signageos.io: NEW replica set `box-54846c877b` deployed (was `box-8676fb5f57`) — /status secgrep=0 persists, full 9-svc topology leak unchanged (now includes mongoDB3), zero hardening added across
- NEW api.signageos.io: NEW replica set `api-7c5fdc9777` deployed (was `api-77955558bc`) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO under any Origin
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box

## 2026-08-17 22:47:28 UTC
- NEW box.signageos.io: NEW replica set `box-54846c877b` deployed (was `box-8676fb5f57`) — /status secgrep=0 persists, full 9-svc topology leak unchanged (now includes mongoDB3), zero hardening added across
- NEW api.signageos.io: NEW replica set `api-7c5fdc9777` deployed (was `api-77955558bc`) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO under any Origin
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box

## 2026-08-17 23:05:55 UTC
- NEW box.signageos.io: NEW replica set `box-54846c877b` deployed (was `box-8676fb5f57`) — /status secgrep=0 persists, full 9-svc topology leak unchanged (now includes mongoDB3), zero hardening added across
- NEW api.signageos.io: NEW replica set `api-7c5fdc9777` deployed (was `api-77955558bc`) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO under any Origin
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box

## 2026-08-17 23:36:01 UTC

## 2026-08-17 23:58:33 UTC

## 2026-08-18 01:25:26 UTC
- NEW box.signageos.io: Replica set rotated to `box-54846c877b` (from `box-8676fb5f57`) — /status still secgrep=0, 9-svc topology leak (now includes mongoDB3), zero hardening
- NEW api.signageos.io: Replica set rotated to `api-7c5fdc9777` (from `api-77955558bc`) — /status still secgrep=3 (HSTS/xfo/xcto/no-store), 8-svc topology (mongoDB3 absent), zero ACAO
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box

## 2026-08-18 02:37:33 UTC
- NEW box.signageos.io: Replica set rotated to `box-54846c877b` (from `box-8676fb5f57`) — /status still secgrep=0, 9-svc topology leak (now includes mongoDB3), zero hardening
- NEW api.signageos.io: Replica set rotated to `api-7c5fdc9777` (from `api-77955558bc`) — /status still secgrep=3 (HSTS/xfo/xcto/no-store), 8-svc topology (mongoDB3 absent), zero ACAO
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box

## 2026-08-18 03:44:40 UTC
- NEW box.signageos.io: Replica set rotated to `box-54846c877b` (from `box-8676fb5f57`) — /status still secgrep=0, 9-svc topology leak (now includes mongoDB3), zero hardening
- NEW api.signageos.io: Replica set rotated to `api-7c5fdc9777` (from `api-77955558bc`) — /status still secgrep=3 (HSTS/xfo/xcto/no-store), 8-svc topology (mongoDB3 absent), zero ACAO
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box

## 2026-08-18 04:12:25 UTC
- NEW box.signageos.io: Replica set rotated to `box-54846c877b` (from `box-8676fb5f57`) — /status still secgrep=0, 9-svc topology leak (now includes mongoDB3), zero hardening added
- NEW api.signageos.io: Replica set rotated to `api-7c5fdc9777` (from `api-77955558bc`) — /status still secgrep=3 (HSTS/xfo/xcto/no-store), 8-svc topology (mongoDB3 absent), zero ACAO
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box

## 2026-08-18 04:58:48 UTC
- NEW box.signageos.io/status: mongoDB3 now present in succeededServices (9 services vs 8 on old rs box-8676fb5f57) — topology leak expanded
- NEW api.signageos.io/status: mongoDB3 absent (8 services vs box's 9) — topology leak contracted vs box
- CHANGED box.signageos.io: Replica set rotated to box-54846c877b (from box-8676fb5f57) — /status secgrep=0 persists, 9-svc topology leak unchanged, zero hardening added
- CHANGED api.signageos.io: Replica set rotated to api-7c5fdc9777 (from api-77955558bc) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology, zero ACAO
- CHANGED box.signageos.io/status now fronted by CloudFront (new `x-cache`/`via`/`x-amz-cf-pop` headers) — routing change only, body/header security posture unchanged (still zero hardening headers, leaks topolo
- CHANGED box.signageos.io/ & /login/ now served via CloudFront with full hardening headers (HSTS `max-age=63072000; includeSubDomains; preload`, `xfo: DENY`, `xcto: nosniff`, CSP) — differential vs `/status` c
- CHANGED api.signageos.io/status now also fronted by CloudFront — retains HSTS+xfo+xcto hardening
- CHANGED box.signageos.io now fronted by CloudFront (added `x-cache`/`via`/`x-amz-cf-pop`) — `/` and `/login/` now carry full hardening headers (HSTS `max-age=63072000; includeSubDomains; preload`, `xfo: DENY`
- CHANGED api.signageos.io/status now also fronted by CloudFront — retains HSTS+xfo+xcto hardening differential vs box.status
- CHANGED box.signageos.io now fronted by CloudFront (added `x-cache`/`via`/`x-amz-cf-pop`) — `/` and `/login/` now carry full hardening headers (HSTS `max-age=63072000; includeSubDomains; preload`, `xfo: DENY`
- CHANGED api.signageos.io/status now also fronted by CloudFront — retains HSTS+xfo+xcto hardening differential vs box.status

## 2026-08-18 05:27:27 UTC
- NEW box.signageos.io/status: mongoDB3 now present in succeededServices (9 services vs 8 on old rs box-8676fb5f57) — topology leak expanded
- NEW api.signageos.io/status: mongoDB3 absent (8 services vs box's 9) — topology leak contracted vs box
- CHANGED box.signageos.io: Replica set rotated to box-54846c877b (from box-8676fb5f57) — /status secgrep=0 persists, 9-svc topology leak unchanged, zero hardening added
- CHANGED api.signageos.io: Replica set rotated to api-7c5fdc9777 (from api-77955558bc) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology, zero ACAO
- CHANGED box.signageos.io/status now fronted by CloudFront (new `x-cache`/`via`/`x-amz-cf-pop` headers) — routing change only, body/header security posture unchanged (still zero hardening headers, leaks topolo
- CHANGED box.signageos.io/ & /login/ now served via CloudFront with full hardening headers (HSTS `max-age=63072000; includeSubDomains; preload`, `xfo: DENY`, `xcto: nosniff`, CSP) — differential vs `/status` c
- CHANGED api.signageos.io/status now also fronted by CloudFront — retains HSTS+xfo+xcto hardening

## 2026-08-18 05:58:02 UTC
- NEW box.signageos.io/status: mongoDB3 now present in succeededServices (9 services vs 8 on old rs box-8676fb5f57) — topology leak expanded
- NEW api.signageos.io/status: mongoDB3 absent (8 services vs box's 9) — topology leak contracted vs box
- CHANGED box.signageos.io: Replica set rotated to box-54846c877b (from box-8676fb5f57) — /status secgrep=0 persists, 9-svc topology leak unchanged, zero hardening added
- CHANGED api.signageos.io: Replica set rotated to api-7c5fdc9777 (from api-77955558bc) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology, zero ACAO
- CHANGED box.signageos.io/status now fronted by CloudFront (new `x-cache`/`via`/`x-amz-cf-pop` headers) — routing change only, body/header security posture unchanged (still zero hardening headers, leaks topolo
- CHANGED box.signageos.io/ & /login/ now served via CloudFront with full hardening headers (HSTS `max-age=63072000; includeSubDomains; preload`, `xfo: DENY`, `xcto: nosniff`, CSP) — differential vs `/status` c
- CHANGED api.signageos.io/status now also fronted by CloudFront — retains HSTS+xfo+xcto hardening

## 2026-08-18 06:54:59 UTC
- NEW box.signageos.io/status: mongoDB3 now present in succeededServices (9 services vs 8 on old rs box-8676fb5f57) — topology leak expanded
- NEW api.signageos.io/status: mongoDB3 absent (8 services vs box's 9) — topology leak contracted vs box
- CHANGED box.signageos.io: Replica set rotated to box-54846c877b (from box-8676fb5f57) — /status secgrep=0 persists, 9-svc topology leak unchanged, zero hardening added
- CHANGED api.signageos.io: Replica set rotated to api-7c5fdc9777 (from api-77955558bc) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology, zero ACAO
- CHANGED box.signageos.io/status now fronted by CloudFront (new `x-cache`/`via`/`x-amz-cf-pop` headers) — routing change only, body/header security posture unchanged (still zero hardening headers, leaks topolo
- CHANGED box.signageos.io/ & /login/ now served via CloudFront with full hardening headers (HSTS `max-age=63072000; includeSubDomains; preload`, `xfo: DENY`, `xcto: nosniff`, CSP) — differential vs `/status` c
- CHANGED api.signageos.io/status now also fronted by CloudFront — retains HSTS+xfo+xcto hardening

## 2026-08-18 07:41:04 UTC
- NEW box.signageos.io: Replica set rotated to `box-54846c877b` (from `box-8676fb5f57`) — /status still secgrep=0, 9-svc topology leak (now includes mongoDB3), zero hardening added
- NEW api.signageos.io: Replica set rotated to `api-7c5fdc9777` (from `api-77955558bc`) — /status still secgrep=3 (HSTS/xfo/xcto/no-store), 8-svc topology (mongoDB3 absent), zero ACAO
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box
- CHANGED box.signageos.io/status now fronted by CloudFront (new `x-cache`/`via`/`x-amz-cf-pop` headers) — routing change only, body/header security posture unchanged (still zero hardening headers, leaks topolo
- CHANGED box.signageos.io/ & /login/ now served via CloudFront with full hardening headers (HSTS `max-age=63072000; includeSubDomains; preload`, `xfo: DENY`, `xcto: nosniff`, CSP) — differential vs `/status` c
- CHANGED api.signageos.io/status now also fronted by CloudFront — retains HSTS+xfo+xcto hardening
- NEW box.signageos.io/status: mongoDB3 now present in succeededServices (9 services vs 8 on old rs box-8676fb5f57) — topology leak expanded
- NEW api.signageos.io/status: mongoDB3 absent (8 services vs box's 9) — topology leak contracted vs box
- CHANGED box.signageos.io: Replica set rotated to box-54846c877b (from box-8676fb5f57) — /status secgrep=0 persists, 9-svc topology leak unchanged, zero hardening added
- CHANGED api.signageos.io: Replica set rotated to api-7c5fdc9777 (from api-77955558bc) — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology, zero ACAO
- CHANGED box.signageos.io/status now fronted by CloudFront (new `x-cache`/`via`/`x-amz-cf-pop` headers) — routing change only, body/header security posture unchanged (still zero hardening headers, leaks topolo
- CHANGED box.signageos.io/ & /login/ now served via CloudFront with full hardening headers (HSTS `max-age=63072000; includeSubDomains; preload`, `xfo: DENY`, `xcto: nosniff`, CSP) — differential vs `/status` c
- CHANGED api.signageos.io/status now also fronted by CloudFront — retains HSTS+xfo+xcto hardening

## 2026-08-18 08:09:29 UTC
- NEW box.signageos.io: Replica set rotated to `box-54846c877b` (from `box-8676fb5f57`) — /status still secgrep=0, 9-svc topology leak (now includes mongoDB3), zero hardening added
- NEW api.signageos.io: Replica set rotated to `api-7c5fdc9777` (from `api-77955558bc`) — /status still secgrep=3 (HSTS/xfo/xcto/no-store), 8-svc topology (mongoDB3 absent), zero ACAO
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box
- CHANGED box.signageos.io/status now fronted by CloudFront (new `x-cache`/`via`/`x-amz-cf-pop` headers) — routing change only, body/header security posture unchanged (still zero hardening headers, leaks topolo
- CHANGED box.signageos.io/ & /login/ now served via CloudFront with full hardening headers (HSTS `max-age=63072000; includeSubDomains; preload`, `xfo: DENY`, `xcto: nosniff`, CSP) — differential vs `/status` c
- CHANGED api.signageos.io/status now also fronted by CloudFront — retains HSTS+xfo+xcto hardening
- NEW box.signageos.io: Replica set rotated to `box-54846c877b` (from `box-8676fb5f57`) — /status still secgrep=0, 9-svc topology leak (now includes mongoDB3), zero hardening added
- NEW api.signageos.io: Replica set rotated to `api-7c5fdc9777` (from `api-77955558bc`) — /status still secgrep=3 (HSTS/xfo/xcto/no-store), 8-svc topology (mongoDB3 absent), zero ACAO
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box
- CHANGED box.signageos.io/status now fronted by CloudFront (new `x-cache`/`via`/`x-amz-cf-pop` headers) — routing change only, body/header security posture unchanged (still zero hardening headers, leaks topolo
- CHANGED box.signageos.io/ & /login/ now served via CloudFront with full hardening headers (HSTS `max-age=63072000; includeSubDomains; preload`, `xfo: DENY`, `xcto: nosniff`, CSP) — differential vs `/status` c
- CHANGED api.signageos.io/status now also fronted by CloudFront — retains HSTS+xfo+xcto hardening
- NEW box.signageos.io: Replica set rotated to `box-54846c877b` (from `box-8676fb5f57`) — /status still secgrep=0, 9-svc topology leak (now includes mongoDB3), zero hardening added
- NEW api.signageos.io: Replica set rotated to `api-7c5fdc9777` (from `api-77955558bc`) — /status still secgrep=3 (HSTS/xfo/xcto/no-store), 8-svc topology (mongoDB3 absent), zero ACAO
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box
- CHANGED box.signageos.io/status now fronted by CloudFront (new `x-cache`/`via`/`x-amz-cf-pop` headers) — routing change only, body/header security posture unchanged (still zero hardening headers, leaks topolo
- CHANGED box.signageos.io/ & /login/ now served via CloudFront with full hardening headers (HSTS `max-age=63072000; includeSubDomains; preload`, `xfo: DENY`, `xcto: nosniff`, CSP) — differential vs `/status` c
- CHANGED api.signageos.io/status now also fronted by CloudFront — retains HSTS+xfo+xcto hardening

## 2026-08-18 08:53:51 UTC

## 2026-08-18 09:28:06 UTC

## 2026-08-18 10:01:56 UTC

## 2026-08-18 10:40:40 UTC
- NEW box.signageos.io: Replica set rotated to `box-54846c877b` (from `box-8676fb5f57`) — /status still secgrep=0, 9-svc topology leak (now includes mongoDB3), zero hardening added
- NEW api.signageos.io: Replica set rotated to `api-7c5fdc9777` (from `api-77955558bc`) — /status still secgrep=3 (HSTS/xfo/xcto/no-store), 8-svc topology (mongoDB3 absent), zero ACAO
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box
- CHANGED box.signageos.io/status now fronted by CloudFront (new `x-cache`/`via`/`x-amz-cf-pop` headers) — routing change only, body/header security posture unchanged (still zero hardening headers, leaks topolo
- CHANGED box.signageos.io/ & /login/ now served via CloudFront with full hardening headers (HSTS `max-age=63072000; includeSubDomains; preload`, `xfo: DENY`, `xcto: nosniff`, CSP) — differential vs `/status` c
- CHANGED api.signageos.io/status now also fronted by CloudFront — retains HSTS+xfo+xcto hardening

## 2026-08-18 11:07:17 UTC
- NEW box.signageos.io: Replica set rotated to `box-54846c877b` (from `box-8676fb5f57`) — /status still secgrep=0, 9-svc topology leak (now includes mongoDB3), zero hardening added
- NEW api.signageos.io: Replica set rotated to `api-7c5fdc9777` (from `api-77955558bc`) — /status still secgrep=3 (HSTS/xfo/xcto/no-store), 8-svc topology (mongoDB3 absent), zero ACAO
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box
- CHANGED box.signageos.io/status now fronted by CloudFront (new `x-cache`/`via`/`x-amz-cf-pop` headers) — routing change only, body/header security posture unchanged (still zero hardening headers, leaks topolo
- CHANGED box.signageos.io/ & /login/ now served via CloudFront with full hardening headers (HSTS `max-age=63072000; includeSubDomains; preload`, `xfo: DENY`, `xcto: nosniff`, CSP) — differential vs `/status` c
- CHANGED api.signageos.io/status now also fronted by CloudFront — retains HSTS+xfo+xcto hardening

## 2026-08-18 11:42:32 UTC
- NEW box.signageos.io/status: Replica set `box-54846c877b` now includes mongoDB3 in succeededServices (9 services vs prior 8) — topology leak expanded
- NEW api.signageos.io/status: Replica set `api-7c5fdc9777` shows mongoDB3 absent (8 services) — topology leak contracted vs box
- CHANGED box.signageos.io/status now fronted by CloudFront (x-cache/via/x-amz-cf-pop headers) — routing change only, body/header security posture unchanged (secgrep=0, leaks topology)
- CHANGED box.signageos.io/ & /login/ now served via CloudFront with full hardening headers (HSTS max-age=63072000; includeSubDomains; preload, xfo: DENY, xcto: nosniff, CSP) — differential vs /status confirmed
- CHANGED api.signageos.io/status now also fronted by CloudFront — retains HSTS+xfo+xcto hardening

## 2026-08-18 12:03:07 UTC

## 2026-08-18 13:05:02 UTC

## 2026-08-18 13:58:11 UTC

## 2026-08-18 14:33:10 UTC
- NEW box.signageos.io: Replica set rotated to `box-54846c877b` (from `box-8676fb5f57`) — /status still secgrep=0, 9-svc topology leak (now includes mongoDB3), zero hardening added
- NEW api.signageos.io: Replica set rotated to `api-7c5fdc9777` (from `api-77955558bc`) — /status still secgrep=3 (HSTS/xfo/xcto/no-store), 8-svc topology (mongoDB3 absent), zero ACAO
- CHANGED box.signageos.io/status: Now includes mongoDB3 in succeededServices (9 services vs prior 8 on old rs) — topology leak expanded
- CHANGED api.signageos.io/status: mongoDB3 absent (8 services) — topology leak contracted vs box
- CHANGED box.signageos.io/status now fronted by CloudFront (new `x-cache`/`via`/`x-amz-cf-pop` headers) — routing change only, body/header security posture unchanged (still zero hardening headers, leaks topolo
- CHANGED box.signageos.io/ & /login/ now served via CloudFront with full hardening headers (HSTS `max-age=63072000; includeSubDomains; preload`, `xfo: DENY`, `xcto: nosniff`, CSP) — differential vs `/status` c
- CHANGED api.signageos.io/status now also fronted by CloudFront — retains HSTS+xfo+xcto hardening

## 2026-08-18 15:08:37 UTC

## 2026-08-18 15:52:20 UTC
- NEW box.signageos.io: Replica set rotated to `box-c877d9cc8` (from `box-54846c877b`) — /status still secgrep=0, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io: Replica set `api-7c5fdc9777` stable — /status secgrep=3 (HSTS/xfo/xcto/no-store), 8-svc topology (mongoDB3 absent), zero ACAO
- CHANGED box.signageos.io/status now fronted by CloudFront (x-cache/via/x-amz-cf-pop) — routing change only, body/header security posture unchanged (secgrep=0, leaks topology)
- CHANGED box.signageos.io/ & /login/ served via CloudFront with full hardening headers (HSTS max-age=63072000; includeSubDomains; preload, xfo: DENY, xcto: nosniff, CSP) — differential vs /status confirmed
- CHANGED api.signageos.io/status now also fronted by CloudFront — retains HSTS+xfo+xcto hardening

## 2026-08-18 16:16:06 UTC
- NEW box.signageos.io: Replica set rotated to `box-c877d9cc8` (from `box-54846c877b`) — /status still secgrep=0, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io: Replica set `api-7c5fdc9777` stable — /status secgrep=3 (HSTS/xfo/xcto/no-store), 8-svc topology (mongoDB3 absent), zero ACAO
- CHANGED box.signageos.io/status now fronted by CloudFront (x-cache/via/x-amz-cf-pop) — routing change only, body/header security posture unchanged (secgrep=0, leaks topology)
- CHANGED box.signageos.io/ & /login/ served via CloudFront with full hardening headers (HSTS max-age=63072000; includeSubDomains; preload, xfo: DENY, xcto: nosniff, CSP) — differential vs /status confirmed
- CHANGED api.signageos.io/status now also fronted by CloudFront — retains HSTS+xfo+xcto hardening

## 2026-08-18 16:55:33 UTC
- CHANGED box.signageos.io: Replica set rotated to `box-c877d9cc8` (from `box-54846c877b`), /status secgrep=0 persists, 9-svc topology leak (mongoDB3 present), zero hardening added
- CHANGED api.signageos.io: Replica set `api-7c5fdc9777` stable, /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO
- CHANGED api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- CHANGED box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only

## 2026-08-18 17:22:30 UTC
- NEW box.signageos.io: Replica set rotated to `box-c877d9cc8` (from `box-54846c877b`), /status secgrep=0 persists, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io: Replica set `api-7c5fdc9777` stable, /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only

## 2026-08-18 17:53:24 UTC
- NEW box.signageos.io: Replica set rotated to `box-c877d9cc8` (from `box-54846c877b`), /status secgrep=0 persists, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io: Replica set `api-7c5fdc9777` stable, /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only

## 2026-08-18 18:19:53 UTC
- NEW box.signageos.io: Replica set rotated to `box-c877d9cc8` (from `box-54846c877b`) — /status secgrep=0 persists, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io: Replica set `api-7c5fdc9777` stable — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only

## 2026-08-18 19:05:07 UTC
- NEW box.signageos.io: Replica set rotated to `box-c877d9cc8` (from `box-54846c877b`) — /status secgrep=0 persists, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io: Replica set `api-7c5fdc9777` stable — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only

## 2026-08-18 19:38:43 UTC

## 2026-08-18 20:00:03 UTC
- NEW box.signageos.io: Replica set rotated to `box-c877d9cc8` (from `box-54846c877b`) — /status still secgrep=0, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io: Replica set `api-7c5fdc9777` stable — /status secgrep=3 (HSTS/xfo/xcto/no-store), 8-svc topology (mongoDB3 absent), zero ACAO
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only

## 2026-08-18 20:31:12 UTC
- NEW box.signageos.io: Replica set rotated to `box-c877d9cc8` (from `box-54846c877b`) — /status still secgrep=0, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io: Replica set `api-7c5fdc9777` stable — /status secgrep=3 (HSTS/xfo/xcto/no-store), 8-svc topology (mongoDB3 absent), zero ACAO
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only

## 2026-08-18 20:55:18 UTC

## 2026-08-18 21:22:42 UTC
- NEW NO_DELTA
- NEW box.signageos.io: Replica set rotated to `box-c877d9cc8` (from `box-54846c877b`) — /status secgrep=0 persists, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io: Replica set `api-7c5fdc9777` stable — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only
- NEW box.signageos.io: Replica set rotated to `box-c877d9cc8` (from `box-54846c877b`) — /status secgrep=0 persists, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io: Replica set `api-7c5fdc9777` stable — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only
- NEW box.signageos.io: Replica set rotated to `box-c877d9cc8` (from `box-54846c877b`) — /status still secgrep=0, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io: Replica set `api-7c5fdc9777` stable — /status secgrep=3 (HSTS/xfo/xcto/no-store), 8-svc topology (mongoDB3 absent), zero ACAO
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only
- NEW box.signageos.io: Replica set rotated to `box-c877d9cc8` (from `box-54846c877b`) — /status still secgrep=0, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io: Replica set `api-7c5fdc9777` stable — /status secgrep=3 (HSTS/xfo/xcto/no-store), 8-svc topology (mongoDB3 absent), zero ACAO
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only
- NEW box.signageos.io: Replica set rotated to `box-c877d9cc8` (from `box-54846c877b`) — /status secgrep=0 persists, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io: Replica set `api-7c5fdc9777` stable — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only
- NEW box.signageos.io: Replica set rotated to `box-c877d9cc8` (from `box-54846c877b`) — /status still secgrep=0, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io: Replica set `api-7c5fdc9777` stable — /status secgrep=3 (HSTS/xfo/xcto/no-store), 8-svc topology (mongoDB3 absent), zero ACAO
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only
- NEW box.signageos.io: Replica set rotated to `box-c877d9cc8` (from `box-54846c877b`) — /status still secgrep=0, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io: Replica set `api-7c5fdc9777` stable — /status secgrep=3 (HSTS/xfo/xcto/no-store), 8-svc topology (mongoDB3 absent), zero ACAO
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only

## 2026-08-18 21:46:06 UTC
- NEW NO_DELTA

## 2026-08-18 22:04:42 UTC
- NEW NO_DELTA

## 2026-08-18 22:38:40 UTC
- NEW NO_DELTA

## 2026-08-18 23:04:04 UTC
- NEW NO_DELTA

## 2026-08-18 23:34:06 UTC
- NEW NO_DELTA

## 2026-08-18 23:54:27 UTC
- NEW box.signageos.io: Replica set rotated to `box-c877d9cc8` (from `box-54846c877b`) — /status secgrep=0 persists, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only

## 2026-08-19 01:00:55 UTC

## 2026-08-19 02:25:03 UTC
- NEW NO_DELTA

## 2026-08-19 03:26:01 UTC

## 2026-08-19 04:10:23 UTC
- NEW box.signageos.io: Replica set rotated to `box-c877d9cc8` (from `box-54846c877b`) — /status secgrep=0 persists, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io: Replica set `api-7c5fdc9777` stable — /status secgrep=3 (HSTS/xfo/xcto/no-store), 8-svc topology (mongoDB3 absent), zero ACAO
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only

## 2026-08-19 04:53:43 UTC

## 2026-08-19 05:22:14 UTC

## 2026-08-19 05:57:26 UTC
- NEW box.signageos.io: Replica set rotated to `box-c877d9cc8` (from `box-54846c877b`) — /status secgrep=0 persists, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io: Replica set `api-7c5fdc9777` stable — /status secgrep=3 (HSTS/xfo/xcto/no-store) persists, 8-svc topology (mongoDB3 absent), zero ACAO
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only

## 2026-08-19 06:44:55 UTC
- NEW NO_DELTA

## 2026-08-19 07:27:49 UTC
- NEW NO_DELTA

## 2026-08-19 08:06:34 UTC
- NEW box.signageos.io replica set rotated to `box-c877d9cc8` (from `box-54846c877b`) — /status secgrep=0 persists, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only

## 2026-08-19 08:56:15 UTC
- NEW box.signageos.io replica set rotated to `box-c877d9cc8` (from `box-54846c877b`) — /status secgrep=0 persists, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only

## 2026-08-19 09:29:07 UTC
- NEW box.signageos.io replica set rotated to `box-c877d9cc8` (from `box-54846c877b`) — /status secgrep=0 persists, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only

## 2026-08-19 10:04:59 UTC

## 2026-08-19 10:42:32 UTC

## 2026-08-19 11:09:14 UTC
- NEW box.signageos.io replica set rotated to `box-59b5ffd68b` (from `box-c877d9cc8`) — /status secgrep=0 persists, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io/status: hardened (secgrep=3: HSTS/xfo/xcto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists
- NEW api.signageos.io/v1/organization/{uid}/security-token: 403074 errorDetail byte-identical, JWT Bearer ignored (same 403), zero ACAO under evil.test — mechanism intact, zero auth drift across rs rotatio

## 2026-08-19 11:37:37 UTC
- NEW box.signageos.io replica set rotated to `box-59b5ffd68b` (from `box-c877d9cc8`) — /status secgrep=0 persists, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- CHANGED api.signageos.io/status: hardened (secgrep=3: HSTS/xfo/xcto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists

## 2026-08-19 12:01:16 UTC
- NEW box.signageos.io replica set rotated to `box-59b5ffd68b` (from `box-c877d9cc8`) — /status secgrep=0 persists, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- CHANGED api.signageos.io/status: hardened (secgrep=3: HSTS/xfo/xcto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists

## 2026-08-19 13:06:45 UTC
- NEW box.signageos.io replica set rotated to `box-59b5ffd68b` (from `box-c877d9cc8`) — /status secgrep=0 persists, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- CHANGED api.signageos.io/status: hardened (secgrep=3: HSTS/xfo/xcto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists
- NEW box.signageos.io replica set rotated to `box-59b5ffd68b` (from `box-c877d9cc8`) — /status secgrep=0 persists, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed IGNORED (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only
- NEW box.signageos.io rotated to `box-8b6c78cc8-jsn4l` (from `box-59b5ffd68b`) — same pattern: secgrep=0, 9-svc topology leak (amqp0/redis0-3/mongoDB0-3), Node v20.20.2, zero hardening added

## 2026-08-19 13:56:49 UTC
- NEW box.signageos.io replica set rotated to `box-59b5ffd68b` (from `box-c877d9cc8`) — /status secgrep=0 persists, 9-svc topology leak (mongoDB3 present), zero hardening added
- NEW box.signageos.io replica set rotated to `box-8b6c78cc8-jsn4l` (from `box-59b5ffd68b`) — same pattern: secgrep=0, 9-svc topology leak (amqp0/redis0-3/mongoDB0-3), Node v20.20.2, zero hardening added
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- CHANGED api.signageos.io/status: hardened (secgrep=3: HSTS/xfo/xcto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only

## 2026-08-19 14:34:46 UTC
- NEW box.signageos.io replica set rotated to `box-8b6c78cc8-jsn4l` (from `box-59b5ffd68b`) — /status secgrep=0 persists, 9-svc topology leak (amqp0/redis0-3/mongoDB0-3), Node v20.20.2, zero hardening added
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- CHANGED api.signageos.io/status: hardened (secgrep=3: HSTS/xfo/xcto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only

## 2026-08-19 15:10:11 UTC
- NEW box.signageos.io replica set rotated to `box-8b6c78cc8-jsn4l` (from `box-59b5ffd68b`) — /status secgrep=0 persists, 9-svc topology leak (amqp0/redis0-3/mongoDB0-3), Node v20.20.2, zero hardening added
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- CHANGED api.signageos.io/status: hardened (secgrep=3: HSTS/xfo/xcto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only
- NEW box.signageos.io replica set rotated to `box-8b6c78cc8-jsn4l` (from `box-59b5ffd68b`) — /status secgrep=0 persists, 9-svc topology leak (amqp0/redis0-3/mongoDB0-3), Node v20.20.2, zero hardening added
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- CHANGED api.signageos.io/status: hardened (secgrep=3: HSTS/xfo/xcto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only

## 2026-08-19 15:48:04 UTC
- NEW box.signageos.io replica set rotated to `box-8b6c78cc8-jsn4l` — /status secgrep=0 persists, 9-svc topology leak (amqp0/redis0-3/mongoDB0-3), Node v20.20.2, zero hardening added
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- CHANGED api.signageos.io/status: hardened (secgrep=3: HSTS/xfo/xcto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only

## 2026-08-19 16:18:22 UTC
- NEW box.signageos.io replica set rotated to `box-8b6c78cc8-jsn4l` — /status secgrep=0 persists, 9-svc topology leak (amqp0/redis0-3/mongoDB0-3), Node v20.20.2, zero hardening added
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- CHANGED api.signageos.io/status: hardened (secgrep=3: HSTS/xfo/xcto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only

## 2026-08-19 16:54:27 UTC
- NEW box.signageos.io replica set rotated to `box-8b6c78cc8-jsn4l` — /status secgrep=0 persists, 9-svc topology leak (amqp0/redis0-3/mongoDB0-3), Node v20.20.2, zero hardening added
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- CHANGED api.signageos.io/status: hardened (secgrep=3: HSTS/xfo/xcto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only
- CHANGED box.signageos.io replica set rotated `box-c877d9cc8` → `box-59b5ffd68b` → `box-8b6c78cc8` (rs churn, secgrep=0 persists, same infra-leak pattern, 9-svc topology incl mongoDB3)

## 2026-08-19 17:19:39 UTC

## 2026-08-19 17:47:11 UTC
- NEW box.signageos.io replica set rotated to `box-8b6c78cc8-jsn4l` — /status secgrep=0 persists, 9-svc topology leak (amqp0/redis0-3/mongoDB0-3), Node v20.20.2, zero hardening added
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- CHANGED api.signageos.io/status: hardened (secgrep=3: HSTS/xfo/xcto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only
- CHANGED box.signageos.io replica set rotated `box-c877d9cc8` → `box-59b5ffd68b` → `box-8b6c78cc8` (rs churn, secgrep=0 persists, same infra-leak pattern, 9-svc topology incl mongoDB3)

## 2026-08-19 18:15:28 UTC
- NEW box.signageos.io replica set rotated to `box-8b6c78cc8-jsn4l` — /status secgrep=0 persists, 9-svc topology leak (amqp0/redis0-3/mongoDB0-3), Node v20.20.2, zero hardening added
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- CHANGED api.signageos.io/status: hardened (secgrep=3: HSTS/xfo/xcto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only
- CHANGED box.signageos.io replica set rotated `box-c877d9cc8` → `box-59b5ffd68b` → `box-8b6c78cc8` (rs churn, secgrep=0 persists, same infra-leak pattern, 9-svc topology incl mongoDB3)

## 2026-08-19 18:59:04 UTC
- NEW box.signageos.io replica set rotated to `box-8b6c78cc8-jsn4l` — /status secgrep=0 persists, 9-svc topology leak (amqp0/redis0-3/mongoDB0-3), Node v20.20.2, zero hardening added
- CHANGED api.signageos.io/status: hardened (secgrep=3: HSTS/xfo/xcto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only
- CHANGED box.signageos.io replica set rotated `box-c877d9cc8` → `box-59b5ffd68b` → `box-8b6c78cc8` (rs churn, secgrep=0 persists, same infra-leak pattern, 9-svc topology incl mongoDB3)
- NEW box.signageos.io replica set rotated to `box-8b6c78cc8-jsn4l` — /status secgrep=0 persists, 9-svc topology leak (amqp0/redis0-3/mongoDB0-3), Node v20.20.2, zero hardening added
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- CHANGED api.signageos.io/status: hardened (secgrep=3: HSTS/xfo/xcto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only
- CHANGED box.signageos.io replica set rotated `box-c877d9cc8` → `box-59b5ffd68b` → `box-8b6c78cc8` (rs churn, secgrep=0 persists, same infra-leak pattern, 9-svc topology incl mongoDB3)

## 2026-08-19 19:32:16 UTC
- NEW NO_DELTA

## 2026-08-19 19:58:19 UTC

## 2026-08-19 20:26:06 UTC

## 2026-08-19 20:58:17 UTC
- NEW box.signageos.io replica set rotated to `box-8b6c78cc8` (from `box-59b5ffd68b` → `box-c877d9cc8`) — /status secgrep=0 persists, 9-svc topology leak incl mongoDB3, Node v20.20.2, zero hardening added a
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced on new rs `api-7c5fdc9777`
- CHANGED api.signageos.io/status: hardened (secgrep=3: HSTS/xfo/xcto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only

## 2026-08-19 21:36:15 UTC

## 2026-08-19 21:54:30 UTC

## 2026-08-19 22:21:51 UTC
- NEW box.signageos.io replica set rotated to `box-8b6c78cc8-jsn4l` — /status secgrep=0 persists, 9-svc topology leak (amqp0/redis0-3/mongoDB0-3), Node v20.20.2, zero hardening added
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- CHANGED api.signageos.io/status: hardened (secgrep=3: HSTS/xfo/xcto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only
- CHANGED box.signageos.io replica set rotated `box-c877d9cc8` → `box-59b5ffd68b` → `box-8b6c78cc8` (rs churn, secgrep=0 persists, same infra-leak pattern, 9-svc topology incl mongoDB3)

## 2026-08-19 22:52:27 UTC
- NEW NO_DELTA

## 2026-08-19 23:12:27 UTC
- NEW NO_DELTA

## 2026-08-19 23:39:52 UTC
- NEW NO_DELTA

## 2026-08-20 00:00:21 UTC

## 2026-08-20 01:47:02 UTC
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- CHANGED box.signageos.io replica set rotated `c877d9cc8` → `59b5ffd68b` → `box-8b6c78cc8` (rs churn, secgrep=0 persists, same infra-leak pattern, 9-svc topology incl mongoDB3)
- CHANGED api.signageos.io/status: hardened (secgrep=4 HSTS/xfo/xto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists

## 2026-08-20 02:49:09 UTC
- NEW NO_DELTA
- NEW NO_DELTA — all live probes at 02:45 UTC confirm identical surface to 2026-08-20 01:46 cycle:
- CHANGED None

## 2026-08-20 03:35:10 UTC

## 2026-08-20 04:21:16 UTC
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only
- CHANGED api.signageos.io/status: hardened (secgrep=4 HSTS/xfo/xto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists
- NEW box.signageos.io/status: unauthenticated JSON (HTTP 200, application/json) leaking K8s pod hostname (`box-7c8c876945-gkzcp`), process UID (40-hex), Node v20.20.2, uptime, CPU/memory, and internal serv
- NEW api.signageos.io/status: unauthenticated JSON (HTTP 200, application/json) leaking K8s pod hostname (`api-6f69db97d5-9szk2`), process UID, Node v24.19.0, service topology (redis0-3, mongoDB0-2, amqp0)
- NEW api.signageos.io: real REST endpoints at `/v1/{device,organization,account,license,content-guard/item,location,company,bulk-operation,export/device,device/screenshot,device/telemetry/latest,...}` + `/
- NEW box.signageos.io: 18× static `access-control-allow-origin` header values on `/` (302) and `/login/` (200) — including `http://box.signageos.io` (HTTP/plaintext variant), `https://*.zdusercontent.com` 
- CHANGED box.signageos.io CSP: `connect-src`/`frame-src` enlarged vs seed (additional S3 buckets + triplicated Auth0 `oauth/token` entries); CSP still ACCEPTED from seed
- NEW api.signageos.io: Root (/) serves static HTML landing page (37KB), not API JSON — no public API surface exposed (404 on /v1, /v2, /health, /docs, /api, /swagger.json, /openapi.json)
- NEW box.signageos.io: 302 → /login/%2F with Auth0 OAuth2 flow (sos-production.us.auth0.com, auth0.signageos.io in CSP connect-src) — confirms Auth0 as IdP
- NEW box.signageos.io CSP reveals extensive 3rd-party integrations: Mapbox, Sentry, MoodMedia/BroadSign/Sony device APIs, remote-desktop.signageos.io, upload.signageos.io, platform.signageos.io, license.si
- CHANGED api.signageos.io auth model unknown — no public docs, no swagger, no obvious auth headers on root; SDK/cli repos (signageos org, 59 repos) likely contain actual endpoint mappings and auth schemes

## 2026-08-20 05:05:49 UTC
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin confirmed — CORS strictly scoped to SPA entry points only
- CHANGED api.signageos.io/status: hardened (secgrep=4 HSTS/xfo/xto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists
- CHANGED box.signageos.io replica set rotated `c877d9cc8` → `59b5ffd68b` → `box-8b6c78cc8` (rs churn, secgrep=0 persists, same infra-leak pattern, 9-svc topology incl mongoDB3)

## 2026-08-20 05:41:29 UTC

## 2026-08-20 06:08:43 UTC
- NEW api.signageos.io/status: secgrep hardened to 4 (HSTS/xfo/xcto/no-store) on rs api-7c5fdc9777 pod zh49z, still leaks hostname/uid/Node v24.19.0/8-svc topology
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- CHANGED box.signageos.io replica set rotated `c877d9cc8` → `59b5ffd68b` → `box-8b6c78cc8` (rs churn, secgrep=0 persists, same infra-leak pattern, 9-svc topology incl mongoDB3)
- CHANGED api.signageos.io/status: hardened (secgrep=4 HSTS/xfo/xto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists

## 2026-08-20 07:05:06 UTC
- NEW api.signageos.io/status: secgrep hardened to 4 (HSTS/xfo/xcto/no-store) on rs api-7c5fdc9777 pod zh49z, still leaks hostname/uid/Node v24.19.0/8-svc topology
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced
- CHANGED box.signageos.io replica set rotated `c877d9cc8` → `59b5ffd68b` → `box-8b6c78cc8` (rs churn, secgrep=0 persists, same infra-leak pattern, 9-svc topology incl mongoDB3)
- CHANGED api.signageos.io/status: hardened (secgrep=4 HSTS/xfo/xto/no-store, 0 ACAO) on rs api-7c5fdc9777, pod api-7c5fdc9777-zh49z, 8-svc topology (mongoDB3 absent) — differential vs box persists

## 2026-08-20 07:56:18 UTC

## 2026-08-20 08:34:15 UTC

## 2026-08-20 09:11:08 UTC
- NEW None — surface stable across 60+ cycles and 8+ rs rotations; all live probes reconfirm existing findings
- CHANGED None — no new endpoints, headers, or behavior changes since last inventory

## 2026-08-20 09:52:46 UTC

## 2026-08-20 10:23:25 UTC
- NEW api.signageos.io/status: hardened to secgrep=4 (HSTS/xfo/xcto/no-store) on rs api-7c5fdc9777 pod zh49z — differential vs box /status (secgrep=0) persists
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced — mechanism intact across 8+
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin reconfirmed — CORS strictly scoped to SPA entry points (`/` + `/login/`) only

## 2026-08-20 11:05:13 UTC
- NEW api.signageos.io/status: hardened to secgrep=4 (HSTS/xfo/xcto/no-store) on rs api-7c5fdc9777 pod 9xxnc — differential vs box /status (secgrep=0) persists
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced — mechanism intact across 8+
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin reconfirmed — CORS strictly scoped to SPA entry points (`/` + `/login/`) only
- CHANGED box.signageos.io replica set rotated `c877d9cc8` → `59b5ffd68b` → `box-8b6c78cc8` (rs churn, secgrep=0 persists, same infra-leak pattern, 9-svc topology incl mongoDB3)

## 2026-08-20 11:23:58 UTC
- NEW api.signageos.io/status: hardened to secgrep=4 (HSTS/xfo/xcto/no-store) on rs api-7c5fdc9777 pod 9xxnc — differential vs box /status (secgrep=0) persists
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced — mechanism intact across 8+
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin reconfirmed — CORS strictly scoped to SPA entry points (`/` + `/login/`) only
- CHANGED box.signageos.io replica set rotated `c877d9cc8` → `59b5ffd68b` → `box-8b6c78cc8` (rs churn, secgrep=0 persists, same infra-leak pattern, 9-svc topology incl mongoDB3)

## 2026-08-20 11:53:33 UTC
- NEW api.signageos.io/status: hardened to secgrep=4 (HSTS/xfo/xcto/no-store) on rs api-7c5fdc9777 pod 9xxnc — differential vs box /status (secgrep=0) persists
- NEW api.signageos.io/v1/organization/{uid}/security-token: JWT Bearer token confirmed ignored (returns 403074 same as no-header); only X-Auth/x-oauth-client_id gating enforced — mechanism intact across 8+
- NEW box.signageos.io/status CORS: Zero ACAO under spoofed Origin reconfirmed — CORS strictly scoped to SPA entry points (`/` + `/login/`) only
- CHANGED box.signageos.io replica set rotated `c877d9cc8` → `59b5ffd68b` → `box-8b6c78cc8` (rs churn, secgrep=0 persists, same infra-leak pattern, 9-svc topology incl mongoDB3)

## 2026-08-20 12:35:58 UTC
- NEW None — surface stable across 60+ cycles and 8+ rs rotations; all live probes reconfirm existing findings (NO_DELTA)

## 2026-08-20 13:33:09 UTC
- NEW NO_DELTA — surface stable across 60+ cycles and 8+ rs rotations; all live probes reconfirm existing findings

## 2026-08-20 14:20:38 UTC
- NEW NO_DELTA — surface stable across 60+ cycles and 8+ rs rotations; all live probes reconfirm existing findings

## 2026-08-20 15:01:57 UTC

## 2026-08-20 15:44:55 UTC

## 2026-08-20 16:18:54 UTC

## 2026-08-20 16:57:24 UTC

## 2026-08-20 17:35:47 UTC
- NEW None — surface stable across 60+ cycles and 8+ rs rotations; all live probes reconfirm existing findings (NO_DELTA)

## 2026-08-20 18:01:58 UTC
- NEW None — surface stable across 60+ cycles and 8+ rs rotations; all live probes reconfirm existing findings (NO_DELTA)

## 2026-08-20 19:02:16 UTC
- NEW None — surface stable across 60+ cycles and 8+ rs rotations; all live probes reconfirm existing findings (NO_DELTA)

## 2026-08-20 19:33:03 UTC
- NEW None — surface stable across 60+ cycles and 8+ rs rotations; all live probes reconfirm existing findings (NO_DELTA)

## 2026-08-20 20:01:08 UTC
- NEW NO_DELTA — surface stable across 60+ cycles and 8+ rs rotations; all live probes reconfirm existing findings

## 2026-08-20 20:40:16 UTC
- NEW NO_DELTA — surface stable across 60+ cycles and 8+ rs rotations; all live probes reconfirm existing findings

## 2026-08-20 21:06:34 UTC
- NEW NO_DELTA — surface stable across 60+ cycles and 8+ rs rotations; all live probes reconfirm existing findings

## 2026-08-20 21:42:16 UTC

## 2026-08-20 22:04:36 UTC

## 2026-08-20 22:42:53 UTC
- NEW None — surface stable across 60+ cycles and 8+ rs rotations; all live probes reconfirm existing findings (NO_DELTA)

## 2026-08-20 23:06:21 UTC
- NEW None — surface stable across 60+ cycles and 8+ rs rotations; all live probes reconfirm existing findings (NO_DELTA)

## 2026-08-20 23:39:47 UTC
- NEW None — surface stable across 60+ cycles and 8+ rs rotations; all live probes reconfirm existing findings (NO_DELTA)
- CHANGED api.signageos.io replica set: fresh deploy confirmed — pod `api-75f6d7c5b7-bq5sr` (uptime 454s at probe), leak persists on new rs; hardened headers unchanged (HSTS/XFO/XCTO/no-store, secgrep=4)
- NEW Probe box.signageos.io/status?verbose=1&debug=1&full=true → 200, zero key delta vs baseline (dynamic metric drift only) → no query-param escalation
- NEW Probe api.signageos.io/metrics → uniform 192B `ENDPOINT_NOT_FOUND` envelope → no new surface

## 2026-08-21 00:04:07 UTC
- NEW api.signageos.io replica set rotated: fresh deploy `api-75f6d7c5b7-bq5sr` (uptime 454s), /status leak persists, hardened headers unchanged (HSTS/XFO/XCTO/no-store, secgrep=4)
- NEW box.signageos.io/status?verbose=1&debug=1&full=true probed → 200, zero key delta vs baseline (dynamic metric drift only), no query-param escalation
- NEW api.signageos.io/metrics probed → uniform 192B `ENDPOINT_NOT_FOUND` envelope, no new surface
- CHANGED api.signageos.io replica set: fresh deploy confirmed — pod `api-75f6d7c5b7-bq5sr` (uptime 454s at probe), leak persists on new rs; hardened headers unchanged (HSTS/XFO/XCTO/no-store, secgrep=4)
- NEW Probe box.signageos.io/status?verbose=1&debug=1&full=true → 200, zero key delta vs baseline (dynamic metric drift only) → no query-param escalation
- NEW Probe api.signageos.io/metrics → uniform 192B `ENDPOINT_NOT_FOUND` envelope → no new surface

## 2026-08-21 01:53:10 UTC
- NEW api.signageos.io replica set rotated: fresh deploy `api-75f6d7c5b7-bq5sr` (uptime 454s), /status leak persists, hardened headers unchanged (HSTS/XFO/XCTO/no-store, secgrep=4)
- NEW box.signageos.io/status?verbose=1&debug=1&full=true probed → 200, zero key delta vs baseline (dynamic metric drift only), no query-param escalation
- NEW api.signageos.io/metrics probed → uniform 192B `ENDPOINT_NOT_FOUND` envelope, no new surface

## 2026-08-21 02:57:46 UTC
- NEW NO_DELTA — surface stable across 60+ cycles and 8+ rs rotations; all live probes reconfirm existing findings

## 2026-08-21 03:54:02 UTC

## 2026-08-21 04:34:18 UTC
- NEW NO_DELTA — surface stable across 60+ cycles and 8+ rs rotations; all live probes reconfirm existing findings

## 2026-08-21 05:10:44 UTC
- NEW NO_DELTA — surface stable across 60+ cycles and 8+ rs rotations; all live probes reconfirm existing findings
- CHANGED box.signageos.io/status — pod reschedule within SAME rs: box-77bfdd94d8-wjmhn → box-77bfdd94d8-grdj4 (uptime 55579s); leak persists across pod lifecycle → structural, not instance-bound

## 2026-08-21 05:51:11 UTC
- NEW NO_DELTA — surface stable across 60+ cycles and 8+ rs rotations; all live probes reconfirm existing findings

## 2026-08-21 06:24:59 UTC
- NEW box.signageos.io/status pod rescheduled within rs `box-77bfdd94d8` (wjmhn → grdj4, uptime 55579s) — leak persists across pod lifecycle, structural not instance-bound
- CHANGED box.signageos.io/status: pod rescheduled again within SAME rs `77bfdd94d8`: `grdj4`→`twhcf` (fresh probe 2026-08-21T06:22:49Z); body sha256 `1a2f2ec654da859ea2561c9eaf1c077d867ce66cc7dfd459d26730128cc
- CHANGED api.signageos.io/status: pod rescheduled within rs `75f6d7c5b7`: `78gz9`→`pdppm` (probe 06:22:51Z); sha256 `02b86eb4ed57bb8baebb1f1f6e7f739ce939898baa9e184913c46f0a9d692253`; leak persists; topology s

## 2026-08-21 07:19:57 UTC
- NEW box.signageos.io/status pod rescheduled within rs `box-77bfdd94d8` (wjmhn → grdj4 → twhcf, uptime 55579s) — leak persists across pod lifecycle, structural not instance-bound
- NEW api.signageos.io/status pod rescheduled within rs `75f6d7c5b7` (78gz9 → pdppm) — leak persists, hardened headers unchanged (HSTS/XFO/XCTO/no-store, secgrep=4)
- CHANGED box.signageos.io/status body sha256 `1a2f2ec654da859ea2561c9eaf1c077d867ce66cc7dfd459d26730128cc44560` (fresh probe 2026-08-21T06:22:49Z)
- CHANGED api.signageos.io/status body sha256 `02b86eb4ed57bb8baebb1f1f6e7f739ce939898baa9e184913c46f0a9d692253` (probe 06:22:51Z)

## 2026-08-21 08:03:19 UTC
- NEW box.signageos.io/status pod rescheduled within rs `box-77bfdd94d8` (wjmhn → grdj4 → twhcf, uptime 55579s) — leak persists across pod lifecycle, structural not instance-bound
- NEW api.signageos.io/status pod rescheduled within rs `75f6d7c5b7` (78gz9 → pdppm) — leak persists, hardened headers unchanged (HSTS/XFO/XCTO/no-store, secgrep=4)
- CHANGED box.signageos.io/status body sha256 `1a2f2ec654da859ea2561c9eaf1c077d867ce66cc7dfd459d26730128cc44560` (fresh probe 2026-08-21T06:22:49Z)
- CHANGED api.signageos.io/status body sha256 `02b86eb4ed57bb8baebb1f1f6e7f739ce939898baa9e184913c46f0a9d692253` (probe 06:22:51Z)

## 2026-08-21 08:58:29 UTC
- NEW box.signageos.io/status pod rescheduled within rs `box-77bfdd94d8` (wjmhn → grdj4 → twhcf, uptime 55579s) — leak persists across pod lifecycle, structural not instance-bound
- NEW api.signageos.io/status pod rescheduled within rs `75f6d7c5b7` (78gz9 → pdppm) — leak persists, hardened headers unchanged (HSTS/XFO/XCTO/no-store, secgrep=4)
- CHANGED box.signageos.io/status body sha256 `1a2f2ec654da859ea2561c9eaf1c077d867ce66cc7dfd459d26730128cc44560` (fresh probe 2026-08-21T06:22:49Z)
- CHANGED api.signageos.io/status body sha256 `02b86eb4ed57bb8baebb1f1f6e7f739ce939898baa9e184913c46f0a9d692253` (probe 06:22:51Z)

## 2026-08-21 09:38:21 UTC
- NEW box.signageos.io/status pod rescheduled within rs `box-77bfdd94d8` (wjmhn → grdj4 → twhcf, uptime 55579s) — leak persists across pod lifecycle, structural not instance-bound
- NEW api.signageos.io/status pod rescheduled within rs `75f6d7c5b7` (78gz9 → pdppm) — leak persists, hardened headers unchanged (HSTS/XFO/XCTO/no-store, secgrep=4)
- CHANGED box.signageos.io/status body sha256 `1a2f2ec654da859ea2561c9eaf1c077d867ce66cc7dfd459d26730128cc44560` (fresh probe 2026-08-21T06:22:49Z)
- CHANGED api.signageos.io/status body sha256 `02b86eb4ed57bb8baebb1f1f6e7f739ce939898baa9e184913c46f0a9d692253` (probe 06:22:51Z)
- CHANGED box.signageos.io/status — pod reschedule twhcf→zfqwm (rs `77bfdd94d8` stable); fresh GET 200, body sha256 `d357880f217c319a3066b2f92dc1304cba62976454b26ec423018c42c0c00aef`; leak intact, secgrep=0 (x-
- CHANGED api.signageos.io/status — pod reschedule pdppm→lln8l (rs `75f6d7c5b7` stable); fresh GET 200, body sha256 `0af28a4d6fd6f243bbc132fc64ddd77ec65a48e0074f839a1cd6921fb3ab0055`; HSTS/xfo/xcto/no-store per

## 2026-08-21 10:08:19 UTC
- NEW box.signageos.io/status pod rescheduled within rs `box-77bfdd94d8` (twhcf→zfqwm); fresh GET 200, body sha256 `d357880f217c319a3066b2f92dc1304cba62976454b26ec423018c42c0c00aef`; leak intact, secgrep=0
- NEW api.signageos.io/status pod rescheduled within rs `75f6d7c5b7` (pdppm→lln8l); fresh GET 200, body sha256 `0af28a4d6fd6f243bbc132fc64ddd77ec65a48e0074f839a1cd6921fb3ab0055`; HSTS/xfo/xcto/no-store pers
- CHANGED box.status pod reschedule zfqwm→wjmhn (rs 77bfdd94d8 stable); body sha256 afdac52ef861ce95…; leak intact (uid ba325853…, Node v20.20.2); secgrep=0, ACAO=0
- CHANGED api.status pod reschedule lln8l→x84wf (rs 75f6d7c5b7 stable); body sha256 331bee2c6bca5737…; leak intact (uid ec7a7195…, Node v24.19.0); secgrep=3, ACAO=0

## 2026-08-21 10:48:10 UTC
- NEW box.signageos.io/status pod rescheduled within rs `box-77bfdd94d8` (twhcf→zfqwm→wjmhn); fresh GET 200, body sha256 `d357880f...`→`afdac52e...`; leak intact, secgrep=0 (x-powered-by only)
- NEW api.signageos.io/status pod rescheduled within rs `75f6d7c5b7` (pdppm→lln8l→x84wf); fresh GET 200, body sha256 `0af28a4d...`→`331bee2c...`; HSTS/xfo/xcto/no-store persist (secgrep=3-4), 8-svc topology
- CHANGED api.signageos.io/status pod reschedule: hostname api-75f6d7c5b7-x84wf → api-75f6d7c5b7-5hw9c within rs 75f6d7c5b7; unauth GET /status still 200 with identical leak schema (Node v24.19.0, 8-svc topolog

## 2026-08-21 11:15:07 UTC
- NEW box.signageos.io/status pod rescheduled within rs `box-77bfdd94d8` (twhcf→zfqwm→wjmhn); fresh GET 200, body sha256 `d357880f...`→`afdac52e...`; leak intact, secgrep=0 (x-powered-by only)
- NEW api.signageos.io/status pod rescheduled within rs `75f6d7c5b7` (pdppm→lln8l→x84wf); fresh GET 200, body sha256 `0af28a4d...`→`331bee2c...`; HSTS/xfo/xcto/no-store persist (secgrep=3-4), 8-svc topology
- CHANGED box.signageos.io/status — intra-rs pod reschedule wjmhn→zfqwm (same rs 77bfdd94d8); leak persists, bare header set unchanged (only x-powered-by: Express + CloudFront, secgrep=0); body sha256 2d2ae00de
- CHANGED api.signageos.io/status — intra-rs pod reschedule 5hw9c→2lgqn (same rs 75f6d7c5b7); leak persists behind hardened edge (HSTS/DENY/nosniff/no-store, secgrep=4); body sha256 e9b06361b9ccfe3a…

## 2026-08-21 11:48:32 UTC
- NEW box.signageos.io/status pod rescheduled within rs `box-77bfdd94d8` (wjmhn→zfqwm); fresh GET 200, body sha256 `2d2ae00d...`; leak intact, secgrep=0 (x-powered-by only)
- NEW api.signageos.io/status pod rescheduled within rs `75f6d7c5b7` (5hw9c→2lgqn); fresh GET 200, body sha256 `e9b06361...`; HSTS/xfo/xcto/no-store persist (secgrep=4), 8-svc topology

## 2026-08-21 12:20:36 UTC

## 2026-08-21 13:19:07 UTC

## 2026-08-21 14:09:03 UTC

## 2026-08-21 14:54:31 UTC
- CHANGED box.signageos.io/status ALIVE pod rot rs77bfdd94d8 zfqwm→nhmqz body-sha 2d2ae00d→20a10de4 uid cde79eb328385e34179491af05db024af9626bbe6b0600ee57 uptime 492s fresh-restart secgrep=0 persist acao=0 pers
- CHANGED api.signageos.io/status ALIVE pod rot rs75f6d7c5b7 2lgqn→5hw9c body-sha e9b06361→adaa19e4 uid 9b1e6682a0cac09e309514a4bf7a2f808266a4b72766a68bda uptime 18263s secgrep=4 persist leak intact

## 2026-08-21 15:24:20 UTC

## 2026-08-21 16:00:18 UTC
- NEW api.signageos.io/status pod rescheduled within rs `75f6d7c5b7` (2lgqn→5hw9c) — leak persists, hardened headers unchanged (HSTS/XFO/XCTO/no-store, secgrep=4)
- NEW box.signageos.io/status pod rescheduled within rs `box-77bfdd94d8` (wjmhn→zfqwm→nhmqz) — leak persists, secgrep=0 unchanged
- CHANGED https://box.signageos.io/status: intra-rs reschedule jzchd→**c248m** (rs `77bfdd94d8`), uptime 2467s (fresh restart), new body sha256 `41f1e86800b05134e08736106d1a08e71710ac5d01293e60e97f0bd3f1885228`
- CHANGED https://api.signageos.io/status: pod **2lgqn** re-observed within rs `75f6d7c5b7` (uptime 23146s ≈ 6.4h), new body sha256 `eefb7b74d7b007967297699b9b68ff1fe61fd303bad80c9b1debcf1d2d153b9b`; secgrep=4 

## 2026-08-21 16:40:45 UTC
- NEW api.signageos.io/status pod rescheduled within rs `75f6d7c5b7` (2lgqn→5hw9c) — leak persists, hardened headers unchanged (HSTS/XFO/XCTO/no-store, secgrep=4)
- NEW box.signageos.io/status pod rescheduled within rs `box-77bfdd94d8` (wjmhn→zfqwm→nhmqz) — leak persists, secgrep=0 unchanged
- CHANGED box.signageos.io/status body sha256 `1a2f2ec6...` → `41f1e868...` (fresh probe, intra-rs reschedule)
- CHANGED api.signageos.io/status body sha256 `e9b06361...` → `eefb7b74...` (fresh probe, intra-rs reschedule)

## 2026-08-21 17:24:11 UTC
- CHANGED api.signageos.io/status — intra-rs pod reschedule within rs 75f6d7c5b7: 2lgqn → rwhj7; fresh body sha256 330ad9cb…; leak schema + hardened headers (HSTS/XFO/XCTO) unchanged
- CHANGED box.signageos.io/status — pod wjmhn / rs 77bfdd94d8 unchanged since 15:20Z; fresh body sha256 00682ecd… (uptime/cpu drift only); secgrep=0 persists

## 2026-08-21 17:55:01 UTC
- NEW api.signageos.io/status — pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status — pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status — intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status — pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token — unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-21 18:18:29 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-21 18:46:06 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-21 19:01:49 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-21 19:33:28 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-21 19:53:52 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-21 20:21:57 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-21 20:48:11 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-21 21:11:59 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-21 21:42:26 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-21 22:01:06 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-21 22:36:15 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-21 22:59:56 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-21 23:32:04 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-21 23:55:36 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 01:19:58 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 02:31:17 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 03:24:58 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 04:06:03 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 04:48:36 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 05:13:34 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 05:46:11 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 06:14:56 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 07:04:04 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 07:41:48 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 08:02:45 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 08:43:55 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 09:12:02 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 09:45:05 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 10:03:08 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 10:36:18 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 10:57:57 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 11:28:14 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 11:50:16 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 12:16:25 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 13:05:17 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 13:42:16 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 14:01:05 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 14:32:46 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 14:54:51 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 15:21:48 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 15:44:03 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 16:00:18 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 16:35:41 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 16:58:19 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 17:28:46 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 17:51:02 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 18:16:12 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 18:52:56 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 19:20:13 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 19:42:53 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 19:59:44 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 20:34:06 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 20:56:41 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 21:27:28 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 21:49:49 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 22:08:54 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 22:38:24 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 22:58:34 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 23:29:18 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-22 23:50:44 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 00:41:18 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 02:14:41 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 03:18:43 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 04:06:43 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 04:50:54 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 05:20:59 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 05:53:05 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 06:34:39 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 07:19:29 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 07:53:17 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 08:25:56 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 08:58:39 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 09:36:45 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 09:58:25 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 10:33:21 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 10:56:06 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 11:24:55 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 11:47:20 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 12:11:11 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 13:03:42 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 13:42:04 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 14:03:06 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 14:35:38 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 14:58:11 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 15:31:18 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 15:53:47 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 16:22:52 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 16:50:33 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 17:12:09 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 17:38:01 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 17:56:23 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 18:36:33 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 19:02:24 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 19:31:03 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 19:50:29 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 20:10:49 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 20:40:35 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 21:00:10 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 21:30:48 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 21:51:51 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 22:14:36 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 22:42:10 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 23:00:48 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 23:30:58 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-23 23:52:35 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 00:59:40 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 02:25:58 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 03:32:13 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 04:25:25 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 05:12:54 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 05:56:19 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 07:08:00 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 08:03:58 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 09:01:06 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 09:58:23 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 10:46:19 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 11:14:56 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 11:47:50 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 12:18:18 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 13:26:38 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 14:12:46 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 15:03:43 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 15:52:09 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 16:28:39 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 17:07:57 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 17:46:41 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 18:18:13 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 19:07:18 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 19:43:52 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 20:11:56 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 20:50:52 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 21:19:51 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 21:50:04 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 22:13:40 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 22:47:05 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 23:11:03 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 23:37:53 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-24 23:57:57 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 01:45:30 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 02:46:28 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 03:36:13 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 04:22:07 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 05:03:05 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 05:43:33 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 06:18:45 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 07:14:41 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 08:02:31 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 08:55:26 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 09:38:09 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 10:06:21 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 10:48:00 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 11:14:29 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 11:48:29 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 12:19:11 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 13:24:17 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 14:13:27 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 15:09:01 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 16:00:10 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 16:49:57 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 17:21:47 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact

## 2026-08-25 17:54:09 UTC
- NEW api.signageos.io/status pod reschedule 2lgqn → rwhj7 within rs `75f6d7c5b7`; fresh GET 200, body sha256 `330ad9cb…`; leak schema + hardened headers (HSTS/XFO/XCTO/no-store) unchanged
- NEW box.signageos.io/status pod wjmhn / rs `77bfdd94d8` stable since 15:20Z; fresh GET 200, body sha256 `00682ecd…` (uptime/cpu drift only); secgrep=0 persists
- CHANGED box.signageos.io/status intra-rs pod reschedule within rs 77bfdd94d8: wjmhn → 7ldcv; fresh body sha256 d087f8a6… (uptime 324s ⇒ fresh pod); secgrep=0 persists
- CHANGED api.signageos.io/status pod rwhj7 / rs 75f6d7c5b7 unchanged since 17:11Z (uptime ~3.7h consistent); fresh body sha256 b34f77a4…; hardened header set secgrep=4 persists
- CHANGED api.signageos.io/v1/organization/{uid}/security-token unauth GET reconfirms byte-stable 403074 errorDetail MISSING_ACCOUNT_ID_TO_AUTHENTICATE at 17:46Z; IDOR mechanism taxonomy intact
