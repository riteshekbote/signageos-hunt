# LEADS bigpickle (seed)
- SEED: no model output yet.
## 2026-08-07 18:29:41 UTC [box] (model bigpickle)
## 2026-08-07 18:50:25 UTC [box] (model bigpickle)
[HYP] Cross-tenant IDOR via organizationUid on api.signageos.io /v1
class: IDOR
asset: api.signageos.io/v1/{device,organization,alert,...}
confidence: 60
reasoning: 19 routes confirmed present (403-only, no auth header). SDK appends `organizationUid` query param to JWT calls and builds `apiUrl/version/resource`; JWT identifies account, UID selects tenant — if authorization is per-JWT and not re-checked per-UID, cross-org reads/writes are possible. Untestable without a token.
evidence_needed: valid `X-Auth` JWT + observed 200 vs 403 for a foreign `organizationUid`.
verify_steps: AUTH_HELPED: with a box-generated token, `GET https://api.signageos.io/v1/device` (own org), then `GET /v1/device?organizationUid=<other-org-uid>` and `GET /v1/organization/<foreign-uid>` — any non-403 is a finding.
impact: cross-tenant device/org data disclosure and manipulation; CRITICAL
testability: AUTH_HELPED
[HYP] Device-scoped endpoint auth weaker than user JWT on telemetry/alive/peer-recovery
class: AUTH
asset: api.signageos.io/v1/device/{uid}/telemetry/latest
confidence: 45
reasoning: device-side resources (`telemetry/latest`, `device/{uid}/alive`, `peer-recovery`) may accept device tokens or no-auth in device onboarding path; `device/telemetry/latest` confirmed 403 today but subresource matrix unprobed.
evidence_needed: any `/v1/device/*` subresource returning ≠403 unauthenticated.
verify_steps: PASSIVE: `GET /v1/device/<uid>/alive`, `/v1/device/<uid>/peer-recovery`, `/v1/device/<uid>/organization` (no header) — 403 confirms route, 200/401-with-different-error hints alternate auth.
impact: unauthenticated device state/telemetry read; MEDIUM
testability: PASSIVE
[HYP] Box dashboard token-generation surface over-scopes API credentials
class: AUTH
asset: box.signageos.io/settings
confidence: 45
reasoning: CLI docs direct users to `box.signageos.io/settings` to mint `SOS_API_IDENTIFICATION`/`SOS_API_SECURITY_TOKEN`; box is in-scope and CSP `connect-src` includes `api.signageos.io`, so box is the token minting origin. If minted tokens lack scope/expiry constraints, any XSS/CSRF on box amplifies to full API.
evidence_needed: authenticated inspection of the token-minting XHR (scopes, expiry, org binding).
verify_steps: AUTH_HELPED: login to box, observe XHR to `api.signageos.io/v1/*` from box origin in devtools, test whether minted token honors `organizationUid` and expiry.
impact: over-scoped long-lived API creds enabling cross-org access; HIGH
testability: AUTH_HELPED
[PARKED] Auth0 redirect_uri validation bypass @ box/login: no longer actionable — Auth0 tenant-side allowlist, not testable passively (already learned).
[PARKED] JWT audience=Auth0 Management API v2 confusion: audience string is public but minting a Management-API token requires tenant credentials; no passive POC. confidence <45.
[FINAL] 1) Cross-tenant IDOR via organizationUid (60, AUTH_HELPED)  2) Device-scoped endpoint auth bypass (45, PASSIVE)  3) Box token-generation over-scope (45, AUTH_HELPED)
[NEXT] RAG: fetch public REST-API docs `https://docs.signageos.io/hc/en-us/articles/4405231278482` (REST APIs) and `https://docs.signageos.io/hc/en-us/articles/4405239033234` (REST-API-Authentication) to extract the complete v1/v2 endpoint catalog + any unauthenticated/token-less endpoints, then re-probe only non-403 candidates on api.signageos.io.
[RISK] box.signageos.io: 72 — Auth0 OAuth2 dashboard, API-token minting origin, broad CSP trust boundary (20+ origins incl. device/upload/remote-desktop APIs); exposure stable.
[RISK] api.signageos.io: 78 — previously dismissed as "no surface", now confirmed versioned JWT API (19+ routes, device-management data, cross-tenant IDOR potential); risk materially raised.
## 2026-08-07 19:19:23 UTC [box] (model bigpickle)
## 2026-08-07 20:07:10 UTC [box] (model bigpickle)
[HYP] Cross-tenant org-token minting via account token
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUID}/security-token (GET/POST)
confidence: 55
reasoning: Spec marks this XAuthAccount-only; org UID is a path key. Account token scopes to a Company, yet docs say one account token "can create multiple organizations" and mint org tokens. If company-membership is not re-checked per UID, any account token mints tokens for any org, and org tokens fully control devices (brightness/firmware/content/timing).
evidence_needed: 200 (not 403) on the foreign-UID path with own account token.
verify_steps: AUTH_HELPED: `GET https://api.signageos.io/v1/organization/<own-org>/security-token` (baseline 200), then `GET /v1/organization/<foreign-org-uid>/security-token` — 200 = cross-tenant token mint → full device control of foreign org.
impact: mint org tokens for any tenant → device/content/timing takeover; CRITICAL
testability: AUTH_HELPED
[HYP] Account-token filtered listing ignores tenant scope (organizationUid/companyUid)
class: IDOR
asset: api.signageos.io/v1/organization (GET), /v1/emulator (GET), /v1/device (GET)
confidence: 50
reasoning: account-token listing endpoints take `organizationUid(s)`/`companyUid` as free filters; docs explicitly require organizationUid for org-scoped listing with account tokens. If the filter is applied without a "filter ∈ my company" check, account tokens read foreign tenants' org/device/emulator data.
evidence_needed: 200 with non-empty foreign data for a foreign uid filter.
verify_steps: AUTH_HELPED: `GET /v1/organization?companyUid=<foreign>` and `GET /v1/device?organizationUid=<foreign>` with own account token — non-403/empty is a finding.
impact: cross-tenant device/org/telemetry disclosure; HIGH
testability: AUTH_HELPED
[HYP] Credentials exposed in query string on account-token mint
class: MISCONFIG
asset: api.signageos.io/v1/account/security-token (POST/DELETE)
confidence: 45
reasoning: `identification` + `password` defined as **query** params (spec) on a POST behind CloudFront — user credentials land in URL logs/referrers; alternate auth path bypasses normal session flow.
evidence_needed: confirmed CloudFront/access-log capture of query creds (infra-side, not provable passively) + spec-level confirmation of param location.
verify_steps: AUTH_HELPED: with org token, POST `/v1/account/security-token?identification=<u>&password=<p>` and inspect request/response + any logging headers.
impact: credential leakage via shared-infra logs; MEDIUM
testability: AUTH_HELPED
[NEXT] RAG: fetch `github.com/signageos/sdk` source to confirm exact `X-Auth` construction for v1/v2, the account-token mint call shape (`identification`/`password` param placement), and whether `createApiV2` reuses v1 auth/orgUid semantics — converts hypothesis 1/2 into exact AUTH_HELPED test recipes.
## 2026-08-07 20:56:31 UTC [box] (model bigpickle)
[HYP] Cross-tenant peer-recovery read/write via legacy client-secret not bound to target device UID
class: IDOR
asset: api.signageos.io/v1/device/{uid}/peer-recovery (GET list / PUT set)
confidence: 55
reasoning: gate is org client-secret (`403083 MISSING_CLIENT_SECRET`), not JWT; SDK takes deviceUid as an arbitrary path arg (DevicePeerRecoveryManagement.ts:22,36); org-context is client-controlled (`X-Auth: clientId:secret`, or `?organizationUid=` for JWT), so the server-side org→device binding is the only barrier.
evidence_needed: with own org `X-Auth: clientId:secret`, GET/PUT peer-recovery against a device UID belonging to another org returns 200 (not 403).
verify_steps: AUTH_HELPED: `GET /v1/device/<own-uid>/peer-recovery -H "X-Auth: <ownClientId>:<ownSecret>"` baseline 200; repeat with foreign device UID → 200 = cross-tenant; then `PUT` with `{"enabled":true,"urlLauncherAddress":"https://attacker"}` to confirm write.
impact: read + overwrite peer-recovery config on any tenant's devices; PUT can point device launcher at attacker URL → device/content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account token + client-supplied organizationUid
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token (GET/POST)
confidence: 60
reasoning: docs state one account token can create multiple orgs and mint org tokens; SDK builds `organization/<uid>/security-token` (path = resource key) while JWT auth-context is a separate client-supplied `?organizationUid=` (requester.ts:41-44); if path-UID membership vs query-UID is not re-checked server-side, any account token mints tokens for any org.
evidence_needed: non-403 on POST/GET `/v1/organization/<foreign-uid>/security-token` with own account JWT.
verify_steps: AUTH_HELPED: `GET /v1/organization/<own>/security-token` baseline 200; then `GET /v1/organization/<foreign-uid>/security-token` → 200 = cross-tenant mint; minted org token should then drive foreign devices (brightness/firmware/content/timing).
impact: mint org tokens for any tenant → full foreign-device control; CRITICAL
testability: AUTH_HELPED
[HYP] v2 API partial-migration authz drift (route exists in v2, alternate/weaker auth)
class: AUTH
asset: api.signageos.io/v2/*
confidence: 45
reasoning: /v2/device is JWT-gated (403 WRONG_JWT) but /v2/account and /v2/organization are 404 — v2 is a selective port; freshly-migrated code paths commonly diverge on authorization checks; IOptions is version-agnostic (legacy clientId:secret works across v1/v2).
evidence_needed: any /v2 route returning 200 unauthenticated, or ≠403/404, or accepting legacy auth where v1 requires JWT.
verify_steps: PASSIVE: probe /v2/device/{uid}, /v2/license, /v2/alert, /v2/location, /v2/content, /v2/bulk-operation, /v2/emulator without auth — anything ≠403/404 is a finding; AUTH_HELPED: compare own-creds response on same resource across /v1 vs /v2.
impact: authz drift → data disclosure / cross-tenant access via an alternate code path; HIGH
testability: PASSIVE
## 2026-08-07 21:34:01 UTC [box] (model bigpickle)
[HYP] Cross-tenant IDOR via organizationUid on api.signageos.io /v1
class: IDOR
asset: api.signageos.io/v1/{device,organization,alert,...}
confidence: 60
reasoning: 19 routes confirmed present (403-only, no auth header). SDK appends `organizationUid` query param to JWT calls and builds `apiUrl/version/resource`; JWT identifies account, UID selects tenant — if authorization is per-JWT and not re-checked per-UID, cross-org reads/writes are possible. Untestable without a token.
evidence_needed: valid `X-Auth` JWT + observed 200 vs 403 for a foreign `organizationUid`.
verify_steps: AUTH_HELPED: with a box-generated token, `GET https://api.signageos.io/v1/device` (own org), then `GET /v1/device?organizationUid=<other-org-uid>` and `GET /v1/organization/<foreign-uid>` — any non-403 is a finding.
impact: cross-tenant device/org data disclosure and manipulation; CRITICAL
testability: AUTH_HELPED
[HYP] Device-scoped endpoint auth weaker than user JWT on telemetry/alive/peer-recovery
class: AUTH
asset: api.signageos.io/v1/device/{uid}/telemetry/latest
confidence: 45
reasoning: device-side resources (`telemetry/latest`, `device/{uid}/alive`, `peer-recovery`) may accept device tokens or no-auth in device onboarding path; `device/telemetry/latest` confirmed 403 today but subresource matrix unprobed.
evidence_needed: any `/v1/device/*` subresource returning ≠403 unauthenticated.
verify_steps: PASSIVE: `GET /v1/device/<uid>/alive`, `/v1/device/<uid>/peer-recovery`, `/v1/device/<uid>/organization` (no header) — 403 confirms route, 200/401-with-different-error hints alternate auth.
impact: unauthenticated device state/telemetry read; MEDIUM
testability: PASSIVE
[HYP] Box dashboard token-generation surface over-scopes API credentials
class: AUTH
asset: box.signageos.io/settings
confidence: 45
reasoning: CLI docs direct users to `box.signageos.io/settings` to mint `SOS_API_IDENTIFICATION`/`SOS_API_SECURITY_TOKEN`; box is in-scope and CSP `connect-src` includes `api.signageos.io`, so box is the token minting origin. If minted tokens lack scope/expiry constraints, any XSS/CSRF on box amplifies to full API.
evidence_needed: authenticated inspection of the token-minting XHR (scopes, expiry, org binding).
verify_steps: AUTH_HELPED: login to box, observe XHR to `api.signageos.io/v1/*` from box origin in devtools, test whether minted token honors `organizationUid` and expiry.
impact: over-scoped long-lived API creds enabling cross-org access; HIGH
testability: AUTH_HELPED
[PARKED] Auth0 redirect_uri validation bypass @ box/login: no longer actionable — Auth0 tenant-side allowlist, not testable passively (already learned).
[PARKED] JWT audience=Auth0 Management API v2 confusion: audience string is public but minting a Management-API token requires tenant credentials; no passive POC. confidence <45.
[FINAL] 1) Cross-tenant IDOR via organizationUid (60, AUTH_HELPED)  2) Device-scoped endpoint auth bypass (45, PASSIVE)  3) Box token-generation over-scope (45, AUTH_HELPED)
[NEXT] RAG: fetch public REST-API docs `https://docs.signageos.io/hc/en-us/articles/4405231278482` (REST APIs) and `https://docs.signageos.io/hc/en-us/articles/4405239033234` (REST-API-Authentication) to extract the complete v1/v2 endpoint catalog + any unauthenticated/token-less endpoints, then re-probe only non-403 candidates on api.signageos.io.
[RISK] box.signageos.io: 72 — Auth0 OAuth2 dashboard, API-token minting origin, broad CSP trust boundary (20+ origins incl. device/upload/remote-desktop APIs); exposure stable.
[RISK] api.signageos.io: 78 — previously dismissed as "no surface", now confirmed versioned JWT API (19+ routes, device-management data, cross-tenant IDOR potential); risk materially raised.
[HYP] Cross-tenant org-token minting via account token
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUID}/security-token (GET/POST)
confidence: 55
reasoning: Spec marks this XAuthAccount-only; org UID is a path key. Account token scopes to a Company, yet docs say one account token "can create multiple organizations" and mint org tokens. If company-membership is not re-checked per UID, any account token mints tokens for any org, and org tokens fully control devices (brightness/firmware/content/timing).
evidence_needed: 200 (not 403) on the foreign-UID path with own account token.
verify_steps: AUTH_HELPED: `GET https://api.signageos.io/v1/organization/<own-org>/security-token` (baseline 200), then `GET /v1/organization/<foreign-org-uid>/security-token` — 200 = cross-tenant token mint → full device control of foreign org.
impact: mint org tokens for any tenant → device/content/timing takeover; CRITICAL
testability: AUTH_HELPED
[HYP] Account-token filtered listing ignores tenant scope (organizationUid/companyUid)
class: IDOR
asset: api.signageos.io/v1/organization (GET), /v1/emulator (GET), /v1/device (GET)
confidence: 50
reasoning: account-token listing endpoints take `organizationUid(s)`/`companyUid` as free filters; docs explicitly require organizationUid for org-scoped listing with account tokens. If the filter is applied without a "filter ∈ my company" check, account tokens read foreign tenants' org/device/emulator data.
evidence_needed: 200 with non-empty foreign data for a foreign uid filter.
verify_steps: AUTH_HELPED: `GET /v1/organization?companyUid=<foreign>` and `GET /v1/device?organizationUid=<foreign>` with own account token — non-403/empty is a finding.
impact: cross-tenant device/org/telemetry disclosure; HIGH
testability: AUTH_HELPED
[HYP] Credentials exposed in query string on account-token mint
class: MISCONFIG
asset: api.signageos.io/v1/account/security-token (POST/DELETE)
[HYP] Cross-tenant org OAuth client-secret disclosure via account token
class: IDOR
asset: api.signageos.io/v1/organization/{uid} (GET)
confidence: 65
reasoning: SDK fetches an org's oauthClientId/oauthClientSecret using only ACCOUNT auth (sosControlHelper.ts:130-136 → organizationManagement.get(uid) with accountDI; RestApi.ts:65). If server does not verify account∈company→org, any account token reads any org's full API credential.
evidence_needed: `GET /v1/organization/<foreign-uid>` with own account token returns 200 containing `oauthClientSecret`.
verify_steps: AUTH_HELPED: `GET /v1/organization/<own-org> -H "X-Auth: <ownId>:<ownToken>"` baseline 200; repeat with foreign org UID → 200 = cross-tenant credential disclosure; then use leaked secret as org X-Auth on `/v1/device`.
impact: obtain any tenant's org API credential → full device/content/timing/firmware control; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org-token minting via account credentials on security-token endpoint
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token (GET/POST)
confidence: 60
reasoning: live gate is account-scoped (403074/403076, accepts x-oauth-client_id/secret or X-Auth id:secret), not JWT nor org-scoped; SDK builds `organization/<uid>/security-token` with the same account auth (OrganizationTokenManagement.ts:29-32). Cross-tenant iff path-UID is not bound to the authenticated account's company.
evidence_needed: with own account creds, `GET /v1/organization/<foreign-uid>/security-token` returns 200 (not 403).
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign UID → 200 = cross-tenant; `POST {"name":"x"}` mints a working org token.
impact: mint org tokens for any tenant → full foreign-device control; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant peer-recovery write via legacy org client-secret (device UID not bound to org)
class: IDOR
asset: api.signageos.io/v1/device/{uid}/peer-recovery (GET/PUT), /brightness, /resolution
confidence: 55
reasoning: only these device subresources are client-secret-gated (403083/403075) instead of JWT (403105); deviceUid is a client-supplied path arg; org is derived only from X-Auth credential, so org→device membership is the sole barrier.
evidence_needed: with own org X-Auth, `GET/PUT /v1/device/<foreign-uid>/peer-recovery` returns 200.
verify_steps: AUTH_HELPED: baseline `GET /v1/device/<own-uid>/peer-recovery` = 200; foreign UID → 200 = cross-tenant; `PUT {"enabled":true,"urlLauncherAddress":"https://attacker"}` confirms write.
impact: read/overwrite any tenant's device recovery launcher config → device+content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
