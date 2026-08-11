# Triage Report — 2026-08-11

Scope: signageOS Bug Bounty (box.signageos.io, api.signageos.io)
Probe basis: Passive GET/HEAD only, http_code per url from probe-results.md

---

## UNIQUE LEADS DEDUPLICATED ACROSS 5 MODELS

### LEAD 1: box.signageos.io/status — Infrastructure Information Disclosure

**Source models:** bigpickle, laguna, longcat, nemotron3 (all 4 box-targeting models converged)

**Q1 In scope?** YES — box.signageos.io is in-scope per scope.yml:7.

**Q2 Reachable?** YES — Unauthenticated GET returns HTTP 200 application/json with zero auth headers required. Confirmed across 30+ probes spanning 4 days with rotating pod hostnames (live runtime state, not cached).

**Q3 Real impact?** YES — Exposes live K8s pod hostname (rotating: box-7c8c876945-gkzcp → mtnct → 52dpt → xmdhm → 4jk76 → bk4vh → st6zq), 40-hex process UID, Node.js v20.20.2, uptime, CPU/memory metrics, and full backend service topology (amqp0, redis0-3, mongoDB0-3) with per-service response-time deltas confirming live backend probing. This enables targeted SSRF enumeration, informed logic-flaw probing against api.signageos.io, and K8s pod-naming reconnaissance.

**Q4 Provable (GET/HEAD only)?** YES — `curl -s https://box.signageos.io/status` returns the full JSON body.

**Q5 Novel?** YES — First confirmed in this hunt. Not a duplicate of any prior report.

**Q6 Not rejected?** YES — Not "banner grabbing" (that's server software banners like "Apache/2.x"), not "descriptive error messages", not "outdated-version-only" (the version is one component of a larger structured leak), not "known public files or directories" (/status is not robots.txt/sitemap.xml — it's a health endpoint exposing internal runtime state). Falls squarely under MISCONFIG: unauthenticated info disclosure.

**Q7 Reasonable triager?** YES — Structured health endpoint leaking live pod hostnames, process UIDs, internal service topology, and resource metrics is an accepted info-disclosure class.

**Verdict: VALID**

Minimal read-only proof:
```
curl -sD /tmp/poc_box_status_h.txt --max-time 20 https://box.signageos.io/status -o /tmp/poc_box_status_b.txt && cat /tmp/poc_box_status_b.txt
```
Expected: HTTP 200 application/json containing `hostname` (pod name), `process.uid` (40-hex), `process.version` ("v20.20.2"), `succeededServices` (["amqp0","redis0","redis1","redis2","redis3","mongoDB0","mongoDB1","mongoDB2","mongoDB3"]).

Impact: Internal infrastructure mapping enabling targeted follow-up attacks. Low-Medium severity (reconnaissance enabler, not direct data compromise).

CVSS 3.1: **5.3 (AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N)** — CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N

Reporting channel: signageOS security channel per scope.yml (disclosure policy TBD — operator-provided).

---

### LEAD 2: api.signageos.io/status — Infrastructure Information Disclosure

**Source models:** laguna, longcat, nemotron3

**Q1 In scope?** YES — api.signageos.io is in-scope per scope.yml:9.

**Q2 Reachable?** YES — Unauthenticated GET returns HTTP 200 application/json.

**Q3 Real impact?** YES — Same class as LEAD 1 but on the API pod: leaks pod hostname (api-6f69db97d5-9szk2 → 97fjw → dw2j2), Node v24.19.0, process UID, service topology (amqp0, redis0-3, mongoDB0-2). Confirms the API backend's internal architecture, aiding auth-bypass and logic-flaw research against the 60+ JWT-gated endpoints.

**Q4 Provable?** YES — `curl -s https://api.signageos.io/status`

**Q5 Novel?** YES — Same class as LEAD 1 but different asset (api vs box). Report separately.

**Q6 Not rejected?** YES — Same rationale as LEAD 1.

**Q7 Reasonable triager?** YES

**Verdict: VALID**

Minimal read-only proof:
```
curl -s https://api.signageos.io/status
```
Expected: HTTP 200 application/json with `hostname`, `process.uid`, `process.version` ("v24.19.0"), `succeededServices`.

Impact: Same reconnaissance-enabler class as LEAD 1, on the high-value API asset.

CVSS 3.1: **5.3 (AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N)** — CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N

Reporting channel: signageOS security channel per scope.yml.

---

### LEAD 3: box.signageos.io — CORS Static Whitelist with HTTP Variant + Wildcard

**Source models:** bigpickle, laguna, longcat, nemotron3

**Q1 In scope?** YES — box.signageos.io.

**Q2 Reachable?** YES — GET with any Origin header returns static `access-control-allow-origin` list.

**Q3 Real impact?** LOW — 18 static ACAO values on `/` (302) + `/login/` (200), including:
- `http://box.signageos.io` (plaintext HTTP variant — defeats HSTS for CORS reads)
- `https://*.zdusercontent.com` (literal wildcard origin string)
- sibling `https://api.signageos.io`
- third-party domains (sentry.io, zendesk.com, storage.googleapis.com, google.com/recaptcha)

No `Access-Control-Allow-Credentials` observed on any box path — blocks credentialed cross-origin reads. Impact limited to: any JS executing on a listed origin (e.g. compromised `*.zdusercontent.com` subdomain) can read box's unauthenticated redirect/login HTML. Static (not Origin-reflected), so no arbitrary-origin exploitation.

**Q4 Provable?** YES — `curl -sI -H "Origin: https://evil.test" https://box.signageos.io/`

**Q5 Novel?** YES — First confirmed in this hunt.

**Q6 Not rejected?** YES — CORS is not explicitly excluded. The HTTP variant + wildcard are concrete trust-boundary expansions, not "best practice" alone.

**Q7 Reasonable triager?** Borderline — Most programs accept CORS issues with demonstrable impact. Here the impact is limited (no credentials flag, only unauthenticated HTML readable). The HTTP variant is the most notable finding. Likely rated LOW by a reasonable triager.

**Verdict: VALID (LOW)**

Minimal read-only proof:
```
curl -sI -H "Origin: https://evil.test" https://box.signageos.io/ 2>&1 | grep -iE 'access-control'
```
Expected: 18 static ACAO values including `http://box.signageos.io` and `https://*.zdusercontent.com`.

Impact: Cross-origin trust boundary expansion; any listed-origin script can read unauthenticated login/redirect HTML. Limited by absent credentials flag.

CVSS 3.1: **3.7 (AV:N/AC:H/PR:N/UI:R/S:U/C:L/I:N/A:N)** — CVSS:3.1/AV:N/AC:H/PR:N/UI:R/S:U/C:L/I/N/A:N

Reporting channel: signageOS security channel per scope.yml.

---

### LEAD 4: box.signageos.io — Cross-Tenant Org OAuth Client-Secret Disclosure via Account JWT

**Source models:** bigpickle, laguna, nemotron3, longcat (all models converged)

**Q1 In scope?** YES — api.signageos.io/v1/organization/{uid}.

**Q2 Reachable?** YES — Account token can be minted via `sos login` (Auth0 device-code flow) by any registered user.

**Q3 Real impact?** CRITICAL if confirmed — `GET /v1/organization/{uid}` with `X-Auth: <accountJWT>` returns `oauthClientId` + `oauthClientSecret`. If the server does not re-verify that the path-UID belongs to the authenticated account's company, any account holder can read any tenant's full API credential → full device/content/timing/firmware control.

**Q4 Provable without invasive testing?** NO — Requires AUTH_HELPED: a valid account JWT for two distinct tenants. Probe results confirm all v1 endpoints return 403 JWT-gated. No passive bypass found. The program rules enforce `passive_first: true` and `no_account_creation: true`.

**Q5 Novel?** YES — Same finding across models, same single vulnerability.

**Q6 Not rejected?** YES — IDOR is not on the rejected list.

**Q7 Reasonable triager?** YES if proven — but currently unproven.

**Verdict: HOLD — AUTH_HELPED verification required**

Reason: Cannot prove without valid account tokens for two tenants. Program rules prohibit account creation and enforce passive-first. Awaiting human POC execution:
1. `sos login` (Auth0 device-code) → account JWT
2. `curl -H "X-Auth: <jwt>" https://api.signageos.io/v1/organization/<own-org-uid>` → 200 + oauthClientSecret (baseline)
3. Same header on `<foreign-org-uid>` → 200 + oauthClientSecret = confirmed CRITICAL cross-tenant credential disclosure
4. Escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device`

If confirmed: CVSS ~9.1 (AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:N) — cross-tenant credential disclosure with full device control.

---

### LEAD 5: Cross-Tenant Org Security-Token Minting via Account JWT

**Source models:** bigpickle, laguna, nemotron3, longcat

**Q1 In scope?** YES — api.signageos.io/v1/organization/{uid}/security-token.

**Q2 Reachable?** YES — Account-token accessible endpoint.

**Q3 Real impact?** CRITICAL if confirmed — Mint org-scoped security tokens for any tenant → full device/content/timing/firmware control of foreign org's devices.

**Q4 Provable without invasive testing?** NO — AUTH_HELPED required. 403-gated without valid token.

**Q5 Novel?** YES — Same class as LEAD 4 but distinct endpoint.

**Q6 Not rejected?** YES.

**Q7 Reasonable triager?** YES if proven.

**Verdict: HOLD — AUTH_HELPED verification required (bundled with LEAD 4 POC)**

Reason: Same barrier as LEAD 4. POC chain:
1. Same account JWT setup as LEAD 4
2. `GET /v1/organization/<foreign-uid>/security-token` → 200 = cross-tenant mint
3. `POST {"name":"poc"}` mints working org token → validate against `/v1/device`

---

### LEAD 6: Cross-Tenant Device Peer-Recovery Read/Write via Client-Supplied deviceUid

**Source models:** bigpickle, laguna, nemotron3

**Q1 In scope?** YES — api.signageos.io/v1/device/{uid}/peer-recovery.

**Q2 Reachable?** YES — Org client-secret accessible.

**Q3 Real impact?** HIGH→CRITICAL if confirmed — Read/overwrite any tenant's device recovery-launcher config; PUT can point device launcher at attacker URL → device+content takeover.

**Q4 Provable without invasive testing?** NO — AUTH_HELPED (needs valid org legacy creds `clientId:secret`).

**Q5 Novel?** YES.

**Q6 Not rejected?** YES.

**Q7 Reasonable triager?** YES if proven.

**Verdict: HOLD — AUTH_HELPED verification required**

Reason: Requires org credentials to test. POC:
1. `curl -H "X-Auth: <ownClientId>:<ownSecret>" https://api.signageos.io/v1/device/<own-uid>/peer-recovery` → 200 baseline
2. Same header on `<foreign-device-uid>` → 200 = cross-tenant
3. `PUT {"enabled":true,"urlLauncherAddress":"https://attacker"}` confirms write

---

### LEAD 7: v2 API Partial-Migration Authz Drift

**Source models:** bigpickle, nemotron3

**Q1 In scope?** YES — api.signageos.io/v2/*.

**Q2 Reachable?** Partially — /v2/device now returns 403 JWT-gated (was 404 earlier). /v2/account + /v2/organization remain 404.

**Q3 Real impact?** HIGH if confirmed — Authz drift on migrated code paths.

**Q4 Provable without invasive testing?** NO — Passive probes show only expected behavior (403 JWT-gated, 404 for non-existent). The hypothesis ("freshly-migrated code paths commonly diverge on authorization checks") is speculative with no supporting evidence. All tested v2 routes behave correctly.

**Q5 Novel?** N/A — Not substantiated.

**Q6 Not rejected?** YES — but not on rejected list.

**Q7 Reasonable triager?** NO — No evidence. All observed responses are correct (403 on existing routes, 404 on non-existent routes). Speculation without a finding.

**Verdict: INVALID — No evidence; all tested routes behave as expected**

---

### LEAD 8: box.signageos.io/login CSRF via OAuth2 State

**Source models:** nemotron3

**Q1 In scope?** YES — box.signageos.io.

**Q2 Reachable?** YES — Login is anonymous-accessible.

**Q3 Real impact?** HIGH — Account takeover via login CSRF.

**Q4 Provable?** PARTIALLY — Requires Auth0 tenant interaction for full validation.

**Q5 Novel?** N/A — Excluded by program rules.

**Q6 Not rejected?** NO — Explicitly excluded: "CSRF on forms that are available to anonymous users" (scope.yml:24).

**Q7 Reasonable triager?** NO — Program excludes this class.

**Verdict: INVALID — Excluded per scope.yml "CSRF on forms that are available to anonymous users"**

---

### LEAD 9: box.signageos.io Auth0 redirect_uri Validation Bypass

**Source models:** nemotron3, laguna, longcat

**Q1 In scope?** YES — box.signageos.io.

**Q2 Reachable?** YES — Login is anonymous-accessible.

**Q3 Real impact?** HIGH — Account takeover via OAuth code theft.

**Q4 Provable?** NO — Cannot validate redirect_uri allowlist without Auth0 tenant config access. Requires initiating OAuth flows, which is beyond passive GET/HEAD.

**Q5 Novel?** N/A — Cannot confirm.

**Q6 Not rejected?** Not explicitly excluded, but untestable.

**Q7 Reasonable triager?** NO — Cannot be validated passively. Auth0 redirect_uri validation is a tenant-side allowlist, not testable without tenant config access.

**Verdict: INVALID — Not testable passively without Auth0 tenant access**

---

### LEAD 10: box.signageos.io CSP Overly Broad connect-src/frame-src

**Source models:** bigpickle, laguna, longcat, nemotron3

**Q1 In scope?** YES — box.signageos.io.

**Q2 Reachable?** YES — Anonymous GET.

**Q3 Real impact?** LOW-MEDIUM — Overly broad CSP (40+ connect-src/frame-src origins) expands trust boundary. Requires co-located XSS to exploit.

**Q4 Provable?** YES — CSP header is observable.

**Q5 Novel?** YES.

**Q6 Not rejected?** Borderline — "best practice" is in the always-rejected list. Overly broad CSP is a defense-in-depth/best-practice concern without direct exploitability without another vulnerability.

**Q7 Reasonable triager?** NO — Classified as best practice. No direct impact without a co-located XSS on box's own origin.

**Verdict: INVALID — "best practice" class; no direct impact without co-located XSS**

---

### LEAD 11: api.signageos.io Descriptive Error Messages in 403 Bodies

**Source models:** bigpickle, laguna, longcat, nemotron3

**Q1 In scope?** YES.

**Q2 Reachable?** YES — 403 responses leak error details.

**Q3 Real impact?** None — Informational.

**Q4 Provable?** YES.

**Q5 Novel?** N/A — Excluded.

**Q6 Not rejected?** NO — Explicitly excluded: "Descriptive error messages or headers (e.g. Stack Traces, banner grabbing)" (scope.yml:13). 403 bodies leak `"Account not found"`, `"Decoding of provided JWT token has failed"`, `errorCode 403105`.

**Q7 Reasonable triager?** NO — Excluded class.

**Verdict: INVALID — Excluded per scope.yml "Descriptive error messages or headers"**

---

### LEAD 12: box.signageos.io/ready — Trivial Health Check

**Source models:** bigpickle, laguna, longcat, nemotron3

**Q1 In scope?** YES.

**Q2 Reachable?** YES — 200 "OK" (2 bytes).

**Q3 Real impact?** None — Trivial health check, no data leaked.

**Q4 Provable?** YES.

**Q5 Novel?** N/A — Not reportable.

**Q6 Not rejected?** Not excluded, but no data leaked.

**Q7 Reasonable triager?** NO — No information disclosed.

**Verdict: INVALID — No data leaked, trivial health check**

---

### LEAD 13: api.signageos.io CORS (No ACAO)

**Source models:** bigpickle, laguna, nemotron3

**Q1 In scope?** YES.

**Q2 Reachable?** YES.

**Q3 Real impact?** None — 403/404 responses carry `vary: Origin` + `access-control-expose-headers: *` but NO ACAO under any Origin. Not CORS-exploitable.

**Q4 Provable?** YES.

**Q5 Novel?** N/A — Not exploitable.

**Q6 Not rejected?** YES — but no vulnerability exists.

**Q7 Reasonable triager?** NO — No misconfiguration present.

**Verdict: INVALID — No ACAO on API responses, not CORS-exploitable**

---

## SUMMARY

| # | Lead | Verdict | Reason |
|---|------|---------|--------|
| 1 | box.signageos.io/status infra info leak | **VALID** | Unauthenticated live K8s topology leak |
| 2 | api.signageos.io/status infra info leak | **VALID** | Same class, different asset |
| 3 | box.signageos.io CORS wildcard + HTTP variant | **VALID (LOW)** | Static whitelist trust-boundary expansion |
| 4 | Cross-tenant org OAuth secret disclosure | **HOLD** | AUTH_HELPED, needs 2-tenant POC |
| 5 | Cross-tenant org security-token minting | **HOLD** | AUTH_HELPED, bundled with #4 POC |
| 6 | Cross-tenant device peer-recovery R/W | **HOLD** | AUTH_HELPED, needs org creds |
| 7 | v2 API authz drift | **INVALID** | No evidence, all routes correct |
| 8 | Login CSRF via OAuth2 state | **INVALID** | Excluded: CSRF on anonymous forms |
| 9 | Auth0 redirect_uri bypass | **INVALID** | Not testable passively |
| 10 | box overly broad CSP | **INVALID** | Best practice, needs co-located XSS |
| 11 | api descriptive error messages | **INVALID** | Excluded: descriptive errors |
| 12 | box /ready trivial health check | **INVALID** | No data leaked |
| 13 | api CORS (no ACAO) | **INVALID** | Not exploitable |

**3 VALID** — reportable now via signageOS security channel.
**3 HOLD** — high-value AUTH_HELPED candidates awaiting human POC execution with `sos login` + second tenant.
**7 INVALID** — correctly excluded or unprovable under passive-first constraints.

---

## RECOMMENDED REPORTING

File LEADs 1, 2, and 3 to signageOS security channel per scope.yml disclosure policy.

For HOLD items (4, 5, 6): Queue for AUTH_HELPED testing phase with:
- Own org UID + one second-test-tenant org UID
- `sos login` device-code flow to mint account JWT
- Execute POC chains exactly as code-verified by SDK/CLI grep
