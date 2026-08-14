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
