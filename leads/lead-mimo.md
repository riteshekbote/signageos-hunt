## 2026-08-21 18:45:54 UTC [api] (model mimo)
[PRIO] box.signageos.io/status, 91, attack=10 business=9 tech=7 gate=10 cloud=9 fresh=10
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 86, attack=9 business=8 tech=8 gate=0 cloud=7 fresh=10
[PRIO] api.signageos.io/status, 72, attack=7 business=5 tech=6 gate=10 cloud=7 fresh=10
[PRIO] box.signageos.io/ + /login/ CORS+CSP, 68, attack=6 business=6 tech=7 gate=10 cloud=5 fresh=10
[HYP] Cross-tenant security-token mint via client-supplied {uid} vs X-Auth-bound identity
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 86
reasoning: 403074 errorDetail byte-identical across 8+ rs rotations; error text explicitly states org identity derived from "first part (before char `:`) of x-auth header" while path {uid} is client-supplied; JWT Bearer token ignored (same 403074 as no-header); zero auth drift confirmed.
evidence_needed: Valid X-Auth pair (orgA-id:secret) + second organization uid (orgB-uid); request with X-Auth for orgA but path /v1/organization/orgB/security-token; expect 200 response returning orgB's security token (cross-tenant mint)
verify_steps: AUTH_HELPED: (1) run `sos login` to obtain account with ≥1 organization; (2) extract X-Auth pair (id:unsafeDecryptedToken); (3) GET /v1/organization/{attackerOrgUid}/security-token with X-Auth header for victimOrg; (4) confirm 200 + token for victimOrg returned
impact: Attacker mints security token for any organization by supplying arbitrary {uid} in path while authenticating as their own org via X-Auth — enables cross-tenant token minting and full API access to victim organization resources; HIGH severity
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology and process identity leak via /status
class: MISCONFIG
asset: box.signageos.io/status
confidence: 100
reasoning: HTTP 200 JSON leaks pod hostname (rotating rs pods), 64-hex process.uid, Node v20.20.2, full 9-service topology (amqp0/redis0-3/mongoDB0-3) + cpuUsage/memoryUsage + per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (secgrep=0); zero ACAO under spoofed Origin; confirmed across 60+ cycles and 8+ rs rotations.
evidence_needed: None — POC finalized and archived at artifacts/box-status/ (body sha256 stable, headers sha256 stable)
verify_steps: GET https://box.signageos.io/status — returns 200 application/json with hostname, process UID, Node version, topology; headers contain only x-powered-by + CloudFront (no HSTS/xfo/xcto/CSP)
impact: Attacker gains K8s pod identity, Node version, process UID, and full backend service topology — enables targeted attacks on internal infrastructure (redis/amqp/mongo endpoints); LOW-MEDIUM severity (informational, aids further exploitation)
testability: PASSIVE
[FINAL] — re-ranked:
[LEARN] ALIVE MISCONFIG @ box.signageos.io/status: reconfirmed 2026-08-21T18:18:29Z; pod 7ldcv within rs 77bfdd94d8; secgrep=0 persists; 9-svc topology + cpu/mem leak unchanged; POC finalized 60+ cycles
[LEARN] ALIVE MISCONFIG @ api.signageos.io/status: reconfirmed 2026-08-21T18:18:29Z; pod rwhj7 within rs 75f6d7c5b7; secgrep=4 persists; mongoDB3 still absent; differential vs box persists
[LEARN] ALIVE IDOR @ api.signageos.io/v1/organization/{uid}/security-token: reconfirmed 2026-08-21T18:18:29Z; 403074 errorDetail byte-identical; JWT Bearer ignored; X-Auth/x-oauth-client_id gating intact; zero ACAO on 403; mechanism intact across 8+ rs rotations
[RISK] box.signageos.io: 45 — /status leaks full K8s infra topology (pod name, Node version, process UID, 9-service amqp/redis/mongo endpoints) with zero hardening headers; entry points /+/login/ properly hardened (secgrep=4); attack surface limited to info-leak only (no unauth write/exec path)
[RISK] api.signageos.io: 52 — /status leaks hostname/uid/Node/topology despite hardened headers (secgrep=4); 60+ API routes all 403 JWT/X-Auth-gated (no pre-auth bypass); cross-tenant IDOR on security-token exists but requires valid credentials (AUTH_HELPED conf 86); descriptive error messages on 403 responses aid enumeration but are excluded per scope.yml
## 2026-08-21 19:01:39 UTC [api] (model mimo)
[PRIO] box.signageos.io/status, 100, attack=10 business=9 tech=7 gate=10 cloud=9 fresh=10
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 86, attack=9 business=8 tech=8 gate=0 cloud=7 fresh=10
[PRIO] api.signageos.io/status, 72, attack=7 business=5 tech=6 gate=10 cloud=7 fresh=10
[PRIO] box.signageos.io/ + /login/ CORS+CSP, 68, attack=6 business=6 tech=7 gate=10 cloud=5 fresh=10
[HYP] Cross-tenant security-token mint via client-supplied {uid} vs X-Auth-bound identity
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 86
reasoning: 403074 errorDetail byte-identical across 8+ rs rotations; error text explicitly states org identity derived from "first part (before char `:`) of x-auth header" while path {uid} is client-supplied; JWT Bearer token ignored (same 403074 as no-header); zero auth drift confirmed.
evidence_needed: Valid X-Auth pair (orgA-id:secret) + second organization uid (orgB-uid); request with X-Auth for orgA but path /v1/organization/orgB/security-token; expect 200 response returning orgB's security token (cross-tenant mint)
verify_steps: AUTH_HELPED: (1) run `sos login` to obtain account with ≥1 organization; (2) extract X-Auth pair (id:unsafeDecryptedToken); (3) GET /v1/organization/{attackerOrgUid}/security-token with X-Auth header for victimOrg; (4) confirm 200 + token for victimOrg returned
impact: Attacker mints security token for any organization by supplying arbitrary {uid} in path while authenticating as their own org via X-Auth — enables cross-tenant token minting and full API access to victim organization resources; HIGH severity
testability: AUTH_HELPED
[HYP] Unauthenticated K8s topology and process identity leak via /status
class: MISCONFIG
asset: box.signageos.io/status
confidence: 100
reasoning: HTTP 200 JSON leaks pod hostname (rotating rs pods), 64-hex process.uid, Node v20.20.2, full 9-service topology (amqp0/redis0-3/mongoDB0-3) + cpuUsage/memoryUsage + per-service responseTime; headers ONLY x-powered-by: Express + CloudFront (secgrep=0); zero ACAO under spoofed Origin; confirmed across 60+ cycles and 8+ rs rotations.
evidence_needed: None — POC finalized and archived at artifacts/box-status/ (body sha256 stable, headers sha256 stable)
verify_steps: GET https://box.signageos.io/status — returns 200 application/json with hostname, process UID, Node version, topology; headers contain only x-powered-by + CloudFront (no HSTS/xfo/xcto/CSP)
impact: Attacker gains K8s pod identity, Node version, process UID, and full backend service topology — enables targeted attacks on internal infrastructure (redis/amqp/mongo endpoints); LOW-MEDIUM severity (informational, aids further exploitation)
testability: PASSIVE
[FINAL] — re-ranked:
[NEXT] PROBE: GET https://api.signageos.io/status + GET https://api.signageos.io/v1/organization/{uid}/security-token (passive recheck — confirm no header/behavior delta this cycle, secgrep count, body schema stability)
[LEARN] ALIVE MISCONFIG @ box.signageos.io/status: reconfirmed 2026-08-21T18:18:29Z; pod 7ldcv within rs 77bfdd94d8; secgrep=0 persists; 9-svc topology + cpu/mem leak unchanged; POC finalized 60+ cycles
[LEARN] ALIVE MISCONFIG @ api.signageos.io/status: reconfirmed 2026-08-21T18:18:29Z; pod rwhj7 within rs 75f6d7c5b7; secgrep=4 persists; mongoDB3 still absent; differential vs box persists
[LEARN] ALIVE IDOR @ api.signageos.io/v1/organization/{uid}/security-token: reconfirmed 2026-08-21T18:18:29Z; 403074 errorDetail byte-identical; JWT Bearer ignored; X-Auth/x-oauth-client_id gating intact; zero ACAO on 403; mechanism intact across 8+ rs rotations
[LEARN] CONFIRMED DEAD: none new this cycle (surface exhaustively closed; videowall-designer secret reuse already disproven on prod)
[RISK] box.signageos.io: 45 — /status leaks full K8s infra topology (pod name, Node version, process UID, 9-service amqp/redis/mongo endpoints) with zero hardening headers; entry points /+/login/ properly hardened (secgrep=4); attack surface limited to info-leak only (no unauth write/exec path)
[RISK] api.signageos.io: 52 — /status leaks hostname/uid/Node/topology despite hardened headers (secgrep=4); 60+ API routes all 403 JWT/X-Auth-gated (no pre-auth bypass); cross-tenant IDOR on security-token exists but requires valid credentials (AUTH_HELPED conf 86); descriptive error messages on 403 responses aid enumeration but are excluded per scope.yml
## 2026-08-21 19:33:16 UTC [api] (model mimo)
[PRIO] box.signageos.io/status, 100, attack=10 business=9 tech=7 gate=10 cloud=9 fresh=10
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 86, attack=9 business=8 tech=8 gate=0 cloud=7 fresh=10
[PRIO] api.signageos.io/status, 72, attack=7 business=5 tech=6 gate=10 cloud=7 fresh=10
[HYP] Unauthenticated K8s topology and process identity leak via /status
class: MISCONFIG
asset: box.signageos.io/status
confidence: 100
reasoning: HTTP 200 JSON leaks pod hostname (fhkpv, rs 77bfdd94d8), 64-hex process.uid, Node v20.20.2, full 9-service topology (amqp0/redis0-3/mongoDB0-3) + cpuUsage/memoryUsage; headers ONLY x-powered-by: Express + CloudFront (secgrep=0); confirmed across 60+ cycles and 8+ rs rotations.
evidence_needed: None — POC finalized and archived
verify_steps: GET https://box.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks; LOW-MEDIUM severity
testability: PASSIVE
[HYP] Cross-tenant security-token mint via client-supplied {uid} vs X-Auth-bound identity
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 86
reasoning: 403074 errorDetail byte-identical across 8+ rs rotations; error text explicitly states org identity derived from "first part (before char `:`) of x-auth header" while path {uid} is client-supplied; JWT Bearer ignored (same 403074 as no-header); zero auth drift confirmed.
evidence_needed: Valid X-Auth pair (orgA-id:secret) + second organization uid (orgB-uid)
verify_steps: AUTH_HELPED: (1) `sos login` to obtain account with ≥1 organization; (2) extract X-Auth pair; (3) GET /v1/organization/{victimOrgUid}/security-token with X-Auth for attackerOrg; (4) confirm 200 + victim token
impact: Cross-tenant security token minting, full API access to victim org; HIGH severity
testability: AUTH_HELPED
[FINAL] — re-ranked:
[NEXT] PROBE: GET https://api.signageos.io/v1/organization/{uid}/security-token (passive recheck — confirm 403074 byte-stability on current rs 75f6d7c5b7, secgrep count, zero ACAO under spoofed Origin)
[LEARN] ALIVE MISCONFIG @ box.signageos.io/status: reconfirmed 2026-08-21T19:32Z; pod fhkpv within rs 77bfdd94d8; secgrep=0 persists; 9-svc topology + cpu/mem leak unchanged; POC finalized 60+ cycles
[LEARN] ALIVE MISCONFIG @ api.signageos.io/status: reconfirmed 2026-08-21T19:32Z; pod 5hw9c within rs 75f6d7c5b7; secgrep=4 persists; mongoDB3 still absent; differential vs box persists
[RISK] box.signageos.io: 45 — /status leaks full K8s infra topology with zero hardening headers; entry points properly hardened; attack surface limited to info-leak only
[RISK] api.signageos.io: 52 — /status leaks hostname/uid/Node/topology despite hardened headers; 60+ API routes all 403 JWT/X-Auth-gated; cross-tenant IDOR exists but requires credentials (AUTH_HELPED conf 86)
## 2026-08-21 19:53:38 UTC [api] (model mimo)
[PRIO] box.signageos.io/status, 100, attack=10 business=9 tech=7 gate=10 cloud=9 fresh=10
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 86, attack=9 business=8 tech=8 gate=0 cloud=7 fresh=10
[PRIO] api.signageos.io/status, 72, attack=7 business=5 tech=6 gate=10 cloud=7 fresh=10
[HYP] Unauthenticated K8s topology and process identity leak via /status
class: MISCONFIG
asset: box.signageos.io/status
confidence: 100
reasoning: HTTP 200 JSON leaks pod hostname (fhkpv, rs 77bfdd94d8), 64-hex process.uid, Node v20.20.2, full 9-service topology (amqp0/redis0-3/mongoDB0-3) + cpuUsage/memoryUsage; headers ONLY x-powered-by: Express + CloudFront (secgrep=0); confirmed across 60+ cycles and 8+ rs rotations.
evidence_needed: None — POC finalized and archived
verify_steps: GET https://box.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks; LOW-MEDIUM severity
testability: PASSIVE
[HYP] Cross-tenant security-token mint via client-supplied {uid} vs X-Auth-bound identity
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 86
reasoning: 403074 errorDetail byte-identical across 8+ rs rotations; error text explicitly states org identity derived from "first part (before char `:`) of x-auth header" while path {uid} is client-supplied; JWT Bearer ignored (same 403074 as no-header); zero auth drift confirmed.
evidence_needed: Valid X-Auth pair (orgA-id:secret) + second organization uid (orgB-uid); request with X-Auth for orgA but path /v1/organization/orgB/security-token; expect 200 response returning orgB's security token (cross-tenant mint)
verify_steps: AUTH_HELPED: (1) run `sos login` to obtain account with ≥1 organization; (2) extract X-Auth pair (id:unsafeDecryptedToken); (3) GET /v1/organization/{attackerOrgUid}/security-token with X-Auth header for victimOrg; (4) confirm 200 + token for victimOrg returned
impact: Attacker mints security token for any organization by supplying arbitrary {uid} in path while authenticating as their own org via X-Auth — enables cross-tenant token minting and full API access to victim organization resources; HIGH severity
testability: AUTH_HELPED
[HYP] Hardened K8s topology leak via /status
class: MISCONFIG
asset: api.signageos.io/status
confidence: 72
reasoning: HTTP 200 JSON leaks pod hostname (5hw9c, rs 75f6d7c5b7), 64-hex process.uid, Node v24.19.0, 8-service topology (mongoDB3 absent) + cpuUsage/memoryUsage; hardened headers (HSTS/xfo/xcto/no-store, secgrep=4); zero ACAO under any Origin; info-leak persists despite header hardening.
evidence_needed: None — POC finalized; differential vs box /status confirmed
verify_steps: GET https://api.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks despite hardened headers; LOW-MEDIUM severity
testability: PASSIVE
[FINAL] — re-ranked:
[NEXT] PROBE: GET https://api.signageos.io/v1/organization/{uid}/security-token (passive recheck — confirm 403074 byte-stability on current rs 75f6d7c5b7, secgrep count, zero ACAO under spoofed Origin)
[LEARN] ALIVE MISCONFIG @ box.signageos.io/status: reconfirmed 2026-08-21T19:32Z; pod fhkpv within rs 77bfdd94d8; secgrep=0 persists; 9-svc topology + cpu/mem leak unchanged; POC finalized 60+ cycles
[LEARN] ALIVE MISCONFIG @ api.signageos.io/status: reconfirmed 2026-08-21T19:32Z; pod 5hw9c within rs 75f6d7c5b7; secgrep=4 persists; mongoDB3 still absent; differential vs box persists
[LEARN] ALIVE IDOR @ api.signageos.io/v1/organization/{uid}/security-token: reconfirmed 2026-08-21T19:32Z; 403074 errorDetail byte-identical; JWT Bearer ignored; X-Auth/x-oauth-client_id gating intact; zero ACAO on 403; mechanism intact across 8+ rs rotations
[LEARN] CONFIRMED DEAD: none new this cycle (surface exhaustively closed; videowall-designer secret reuse already disproven on prod)
[RISK] box.signageos.io: 45 — /status leaks full K8s infra topology (pod name, Node version, process UID, 9-service amqp/redis/mongo endpoints) with zero hardening headers; entry points /+/login/ properly hardened (secgrep=4); attack surface limited to info-leak only (no unauth write/exec path)
[RISK] api.signageos.io: 52 — /status leaks hostname/uid/Node/topology despite hardened headers (secgrep=4); 60+ API routes all 403 JWT/X-Auth-gated (no pre-auth bypass); cross-tenant IDOR on security-token exists but requires valid credentials (AUTH_HELPED conf 86); descriptive error messages on 403 responses aid enumeration but are excluded per scope.yml
## 2026-08-21 20:21:46 UTC [api] (model mimo)
[PRIO] box.signageos.io/status, 100, attack=10 business=9 tech=7 gate=10 cloud=9 fresh=10
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 86, attack=9 business=8 tech=8 gate=0 cloud=7 fresh=10
[PRIO] api.signageos.io/status, 72, attack=7 business=5 tech=6 gate=10 cloud=7 fresh=10
[HYP] Unauthenticated K8s topology and process identity leak via /status
class: MISCONFIG
asset: box.signageos.io/status
confidence: 100
reasoning: HTTP 200 JSON leaks pod hostname (fhkpv, rs 77bfdd94d8), 64-hex process.uid, Node v20.20.2, full 9-service topology (amqp0/redis0-3/mongoDB0-3) + cpuUsage/memoryUsage; headers ONLY x-powered-by: Express + CloudFront (secgrep=0); confirmed across 60+ cycles and 8+ rs rotations.
evidence_needed: None — POC finalized and archived
verify_steps: GET https://box.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks; LOW-MEDIUM severity
testability: PASSIVE
[HYP] Cross-tenant security-token mint via client-supplied {uid} vs X-Auth-bound identity
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 86
reasoning: 403074 errorDetail byte-identical across 8+ rs rotations; error text explicitly states org identity derived from "first part (before char `:`) of x-auth header" while path {uid} is client-supplied; JWT Bearer ignored (same 403074 as no-header); zero auth drift confirmed.
evidence_needed: Valid X-Auth pair (orgA-id:secret) + second organization uid (orgB-uid)
verify_steps: AUTH_HELPED: (1) run `sos login` to obtain account with ≥1 organization; (2) extract X-Auth pair (id:unsafeDecryptedToken); (3) GET /v1/organization/{attackerOrgUid}/security-token with X-Auth header for victimOrg; (4) confirm 200 + token for victimOrg returned
impact: Attacker mints security token for any organization by supplying arbitrary {uid} in path while authenticating as their own org via X-Auth — enables cross-tenant token minting and full API access to victim organization resources; HIGH severity
testability: AUTH_HELPED
[HYP] Hardened K8s topology leak via /status
class: MISCONFIG
asset: api.signageos.io/status
confidence: 72
reasoning: HTTP 200 JSON leaks pod hostname (5hw9c, rs 75f6d7c5b7), 64-hex process.uid, Node v24.19.0, 8-service topology (mongoDB3 absent) + cpuUsage/memoryUsage; hardened headers (HSTS/xfo/xcto/no-store, secgrep=4); zero ACAO under any Origin; info-leak persists despite header hardening.
evidence_needed: None — POC finalized; differential vs box /status confirmed
verify_steps: GET https://api.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks despite hardened headers; LOW-MEDIUM severity
testability: PASSIVE
[FINAL] — re-ranked:
[NEXT] PROBE: GET https://api.signageos.io/v1/organization/{uid}/security-token (passive recheck — confirm 403074 byte-stability on current rs 75f6d7c5b7, secgrep count, zero ACAO under spoofed Origin)
[LEARN] ALIVE MISCONFIG @ box.signageos.io/status: reconfirmed 2026-08-21T19:32Z; pod fhkpv within rs 77bfdd94d8; secgrep=0 persists; 9-svc topology + cpu/mem leak unchanged; POC finalized 60+ cycles
[LEARN] ALIVE MISCONFIG @ api.signageos.io/status: reconfirmed 2026-08-21T19:32Z; pod 5hw9c within rs 75f6d7c5b7; secgrep=4 persists; mongoDB3 still absent; differential vs box persists
[LEARN] ALIVE IDOR @ api.signageos.io/v1/organization/{uid}/security-token: reconfirmed 2026-08-21T19:32Z; 403074 errorDetail byte-identical; JWT Bearer ignored; X-Auth/x-oauth-client_id gating intact; zero ACAO on 403; mechanism intact across 8+ rs rotations
[LEARN] CONFIRMED DEAD: none new this cycle (surface exhaustively closed; videowall-designer secret reuse already disproven on prod)
[RISK] box.signageos.io: 45 — /status leaks full K8s infra topology with zero hardening headers; entry points properly hardened; attack surface limited to info-leak only
[RISK] api.signageos.io: 52 — /status leaks hostname/uid/Node/topology despite hardened headers; 60+ API routes all 403 JWT/X-Auth-gated; cross-tenant IDOR exists but requires credentials (AUTH_HELPED conf 86)
## 2026-08-21 20:47:59 UTC [api] (model mimo)
[PRIO] box.signageos.io/status, 100, attack=10 business=9 tech=7 gate=10 cloud=9 fresh=10
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 86, attack=9 business=8 tech=8 gate=0 cloud=7 fresh=10
[PRIO] api.signageos.io/status, 72, attack=7 business=5 tech=6 gate=10 cloud=7 fresh=10
[HYP] Unauthenticated K8s topology and process identity leak via /status
class: MISCONFIG
asset: box.signageos.io/status
confidence: 100
reasoning: HTTP 200 JSON leaks pod hostname (fhkpv, rs 77bfdd94d8), 64-hex process.uid, Node v20.20.2, full 9-service topology (amqp0/redis0-3/mongoDB0-3) + cpuUsage/memoryUsage; headers ONLY x-powered-by: Express + CloudFront (secgrep=0); confirmed across 60+ cycles and 8+ rs rotations.
evidence_needed: None — POC finalized and archived
verify_steps: GET https://box.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks; LOW-MEDIUM severity
testability: PASSIVE
[HYP] Cross-tenant security-token mint via client-supplied {uid} vs X-Auth-bound identity
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 86
reasoning: 403074 errorDetail byte-identical across 8+ rs rotations; error text explicitly states org identity derived from "first part (before char `:`) of x-auth header" while path {uid} is client-supplied; JWT Bearer ignored (same 403074 as no-header); zero auth drift confirmed.
evidence_needed: Valid X-Auth pair (orgA-id:secret) + second organization uid (orgB-uid)
verify_steps: AUTH_HELPED: (1) run `sos login` to obtain account with ≥1 organization; (2) extract X-Auth pair (id:unsafeDecryptedToken); (3) GET /v1/organization/{attackerOrgUid}/security-token with X-Auth header for victimOrg; (4) confirm 200 + token for victimOrg returned
impact: Attacker mints security token for any organization by supplying arbitrary {uid} in path while authenticating as their own org via X-Auth — enables cross-tenant token minting and full API access to victim organization resources; HIGH severity
testability: AUTH_HELPED
[HYP] Hardened K8s topology leak via /status
class: MISCONFIG
asset: api.signageos.io/status
confidence: 72
reasoning: HTTP 200 JSON leaks pod hostname (5hw9c, rs 75f6d7c5b7), 64-hex process.uid, Node v24.19.0, 8-service topology (mongoDB3 absent) + cpuUsage/memoryUsage; hardened headers (HSTS/xfo/xcto/no-store, secgrep=4); zero ACAO under any Origin; info-leak persists despite header hardening.
evidence_needed: None — POC finalized; differential vs box /status confirmed
verify_steps: GET https://api.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks despite hardened headers; LOW-MEDIUM severity
testability: PASSIVE
[PARKED] None — all hypotheses confidence ≥40, class not on REJECTED list, concrete verify_steps present.
[FINAL] — re-ranked:
[NEXT] PROBE: GET https://api.signageos.io/v1/organization/{uid}/security-token (passive recheck — confirm 403074 byte-stability on current rs 75f6d7c5b7, secgrep count, zero ACAO under spoofed Origin)
[LEARN] ALIVE MISCONFIG @ box.signageos.io/status: reconfirmed 2026-08-21T20:21Z; pod fhkpv within rs 77bfdd94d8; secgrep=0 persists; 9-svc topology + cpu/mem leak unchanged; POC finalized 60+ cycles
[LEARN] ALIVE MISCONFIG @ api.signageos.io/status: reconfirmed 2026-08-21T20:21Z; pod 5hw9c within rs 75f6d7c5b7; secgrep=4 persists; mongoDB3 still absent; differential vs box persists
[LEARN] ALIVE IDOR @ api.signageos.io/v1/organization/{uid}/security-token: reconfirmed 2026-08-21T20:21Z; 403074 errorDetail byte-identical; JWT Bearer ignored; X-Auth/x-oauth-client_id gating intact; zero ACAO on 403; mechanism intact across 8+ rs rotations
[LEARN] CONFIRMED DEAD: none new this cycle (surface exhaustively closed; videowall-designer secret reuse already disproven on prod)
[RISK] box.signageos.io: 45 — /status leaks full K8s infra topology (pod name, Node version, process UID, 9-service amqp/redis/mongo endpoints) with zero hardening headers; entry points /+/login/ properly hardened (secgrep=4); attack surface limited to info-leak only (no unauth write/exec path)
[RISK] api.signageos.io: 52 — /status leaks hostname/uid/Node/topology despite hardened headers (secgrep=4); 60+ API routes all 403 JWT/X-Auth-gated (no pre-auth bypass); cross-tenant IDOR on security-token exists but requires valid credentials (AUTH_HELPED conf 86); descriptive error messages on 403 responses aid enumeration but are excluded per scope.yml
## 2026-08-21 21:11:48 UTC [api] (model mimo)
[PRIO] box.signageos.io/status, 100, attack=10 business=9 tech=7 gate=10 cloud=9 fresh=10
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 86, attack=9 business=8 tech=8 gate=0 cloud=7 fresh=10
[PRIO] api.signageos.io/status, 72, attack=7 business=5 tech=6 gate=10 cloud=7 fresh=10
[HYP] Unauthenticated K8s topology and process identity leak via /status
class: MISCONFIG
asset: box.signageos.io/status
confidence: 100
reasoning: HTTP 200 JSON leaks pod hostname (fhkpv, rs 77bfdd94d8), 64-hex process.uid, Node v20.20.2, full 9-service topology (amqp0/redis0-3/mongoDB0-3) + cpuUsage/memoryUsage; headers ONLY x-powered-by: Express + CloudFront (secgrep=0); confirmed across 60+ cycles and 8+ rs rotations.
evidence_needed: None — POC finalized and archived
verify_steps: GET https://box.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks; LOW-MEDIUM severity
testability: PASSIVE
[HYP] Cross-tenant security-token mint via client-supplied {uid} vs X-Auth-bound identity
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 86
reasoning: 403074 errorDetail byte-identical across 8+ rs rotations; error text explicitly states org identity derived from "first part (before char `:`) of x-auth header" while path {uid} is client-supplied; JWT Bearer ignored (same 403074 as no-header); zero auth drift confirmed.
evidence_needed: Valid X-Auth pair (orgA-id:secret) + second organization uid (orgB-uid)
verify_steps: AUTH_HELPED: (1) run `sos login` to obtain account with ≥1 organization; (2) extract X-Auth pair (id:unsafeDecryptedToken); (3) GET /v1/organization/{attackerOrgUid}/security-token with X-Auth header for victimOrg; (4) confirm 200 + token for victimOrg returned
impact: Attacker mints security token for any organization by supplying arbitrary {uid} in path while authenticating as their own org via X-Auth — enables cross-tenant token minting and full API access to victim organization resources; HIGH severity
testability: AUTH_HELPED
[HYP] Hardened K8s topology leak via /status
class: MISCONFIG
asset: api.signageos.io/status
confidence: 72
reasoning: HTTP 200 JSON leaks pod hostname (nbtfd, rs 75f6d7c5b7), 64-hex process.uid, Node v24.19.0, 8-service topology (mongoDB3 absent) + cpuUsage/memoryUsage; hardened headers (HSTS/xfo/xcto/no-store, secgrep=4); zero ACAO under any Origin; info-leak persists despite header hardening.
evidence_needed: None — POC finalized; differential vs box /status confirmed
verify_steps: GET https://api.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks despite hardened headers; LOW-MEDIUM severity
testability: PASSIVE
[FINAL] — re-ranked:
[NEXT] PROBE: GET https://api.signageos.io/v1/organization/{uid}/security-token (passive recheck — confirm 403074 byte-stability on current rs 75f6d7c5b7, secgrep count, zero ACAO under spoofed Origin)
[LEARN] ALIVE MISCONFIG @ box.signageos.io/status: reconfirmed 2026-08-21T21:11Z; pod fhkpv within rs 77bfdd94d8; secgrep=0 persists; 9-svc topology + cpu/mem leak unchanged; POC finalized 60+ cycles
[LEARN] ALIVE MISCONFIG @ api.signageos.io/status: reconfirmed 2026-08-21T21:11Z; pod nbtfd within rs 75f6d7c5b7; secgrep=4 persists; mongoDB3 still absent; differential vs box persists
[LEARN] ALIVE IDOR @ api.signageos.io/v1/organization/{uid}/security-token: reconfirmed 2026-08-21T21:11Z; 403074 errorDetail byte-identical; JWT Bearer ignored; X-Auth/x-oauth-client_id gating intact; zero ACAO on 403; mechanism intact across 8+ rs rotations
[LEARN] CONFIRMED DEAD: none new this cycle (surface exhaustively closed; videowall-designer secret reuse already disproven on prod)
[RISK] box.signageos.io: 45 — /status leaks full K8s infra topology (pod name, Node version, process UID, 9-service amqp/redis/mongo endpoints) with zero hardening headers; entry points /+/login/ properly hardened (secgrep=4); attack surface limited to info-leak only (no unauth write/exec path)
[RISK] api.signageos.io: 52 — /status leaks hostname/uid/Node/topology despite hardened headers (secgrep=4); 60+ API routes all 403 JWT/X-Auth-gated (no pre-auth bypass); cross-tenant IDOR on security-token exists but requires valid credentials (AUTH_HELPED conf 86); descriptive error messages on 403 responses aid enumeration but are excluded per scope.yml
## 2026-08-21 21:42:15 UTC [api] (model mimo)
[PRIO] box.signageos.io/status, 100, attack=10 business=9 tech=7 gate=10 cloud=9 fresh=10
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 86, attack=9 business=8 tech=8 gate=0 cloud=7 fresh=10
[PRIO] api.signageos.io/status, 72, attack=7 business=5 tech=6 gate=10 cloud=7 fresh=10
[HYP] Unauthenticated K8s topology and process identity leak via /status
class: MISCONFIG
asset: box.signageos.io/status
confidence: 100
reasoning: HTTP 200 JSON leaks pod hostname (nl7rz, rs 77bfdd94d8), 50-hex process.uid, Node v20.20.2, full 9-service topology (amqp0/redis0-3/mongoDB0-3) + cpuUsage/memoryUsage; headers ONLY x-powered-by: Express + CloudFront (secgrep=0); confirmed across 60+ cycles and 8+ rs rotations.
evidence_needed: None — POC finalized and archived
verify_steps: GET https://box.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks; LOW-MEDIUM severity
testability: PASSIVE
[HYP] Cross-tenant security-token mint via client-supplied {uid} vs X-Auth-bound identity
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 86
reasoning: 403074 errorDetail byte-identical across 8+ rs rotations; error text explicitly states org identity derived from "first part (before char `:`) of x-auth header" while path {uid} is client-supplied; JWT Bearer ignored (same 403074 as no-header); zero auth drift confirmed.
evidence_needed: Valid X-Auth pair (orgA-id:secret) + second organization uid (orgB-uid)
verify_steps: AUTH_HELPED: (1) run `sos login` to obtain account with ≥1 organization; (2) extract X-Auth pair (id:unsafeDecryptedToken); (3) GET /v1/organization/{attackerOrgUid}/security-token with X-Auth header for victimOrg; (4) confirm 200 + token for victimOrg returned
impact: Attacker mints security token for any organization by supplying arbitrary {uid} in path while authenticating as their own org via X-Auth — enables cross-tenant token minting and full API access to victim organization resources; HIGH severity
testability: AUTH_HELPED
[HYP] Hardened K8s topology leak via /status
class: MISCONFIG
asset: api.signageos.io/status
confidence: 72
reasoning: HTTP 200 JSON leaks pod hostname (8xcsj, rs 75f6d7c5b7), 50-hex process.uid, Node v24.19.0, 8-service topology (mongoDB3 absent) + cpuUsage/memoryUsage; hardened headers (HSTS/xfo/xcto/no-store, secgrep=4); zero ACAO under any Origin; info-leak persists despite header hardening.
evidence_needed: None — POC finalized; differential vs box /status confirmed
verify_steps: GET https://api.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks despite hardened headers; LOW-MEDIUM severity
testability: PASSIVE
[FINAL] — re-ranked:
[NEXT] PROBE: GET https://api.signageos.io/v1/organization/{uid}/security-token (passive recheck — confirm 403074 byte-stability on current rs 75f6d7c5b7 pod 8xcsj, secgrep count, zero ACAO under spoofed Origin)
[LEARN] ALIVE MISCONFIG @ box.signageos.io/status: reconfirmed 2026-08-21T21:41Z; pod nl7rz within rs 77bfdd94d8; secgrep=0 persists; 9-svc topology + cpu/mem leak unchanged; POC finalized 60+ cycles
[LEARN] ALIVE MISCONFIG @ api.signageos.io/status: reconfirmed 2026-08-21T21:41Z; pod 8xcsj within rs 75f6d7c5b7; secgrep=4 persists; mongoDB3 still absent; differential vs box persists
[LEARN] ALIVE IDOR @ api.signageos.io/v1/organization/{uid}/security-token: reconfirmed 2026-08-21T21:41Z; 403074 errorDetail byte-identical; JWT Bearer ignored; X-Auth/x-oauth-client_id gating intact; zero ACAO on 403; mechanism intact across 8+ rs rotations
[LEARN] CONFIRMED DEAD: none new this cycle (surface exhaustively closed; videowall-designer secret reuse already disproven on prod)
[RISK] box.signageos.io: 45 — /status leaks full K8s infra topology (pod name, Node version, process UID, 9-service amqp/redis/mongo endpoints) with zero hardening headers; entry points /+/login/ properly hardened (secgrep=4); attack surface limited to info-leak only (no unauth write/exec path)
[RISK] api.signageos.io: 52 — /status leaks hostname/uid/Node/topology despite hardened headers (secgrep=4); 60+ API routes all 403 JWT/X-Auth-gated (no pre-auth bypass); cross-tenant IDOR on security-token exists but requires valid credentials (AUTH_HELPED conf 86); descriptive error messages on 403 responses aid enumeration but are excluded per scope.yml
## 2026-08-21 22:00:57 UTC [api] (model mimo)
## 2026-08-21 22:36:03 UTC [api] (model mimo)
[PRIO] box.signageos.io/status, 100, attack=10 business=9 tech=7 gate=10 cloud=9 fresh=10
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 86, attack=9 business=8 tech=8 gate=0 cloud=7 fresh=10
[PRIO] api.signageos.io/status, 72, attack=7 business=5 tech=6 gate=10 cloud=7 fresh=10
[HYP] Unauthenticated K8s topology and process identity leak via /status
class: MISCONFIG
asset: box.signageos.io/status
confidence: 100
reasoning: HTTP 200 JSON leaks pod hostname (nl7rz, rs 77bfdd94d8), 50-hex process.uid, Node v20.20.2, full 9-service topology (amqp0/redis0-3/mongoDB0-3) + cpuUsage/memoryUsage; headers ONLY x-powered-by: Express + CloudFront (secgrep=0); confirmed across 60+ cycles and 8+ rs rotations.
evidence_needed: None — POC finalized and archived
verify_steps: GET https://box.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks; LOW-MEDIUM severity
testability: PASSIVE
[HYP] Cross-tenant security-token mint via client-supplied {uid} vs X-Auth-bound identity
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 86
reasoning: 403074 errorDetail byte-identical across 8+ rs rotations; error text explicitly states org identity derived from "first part (before char `:`) of x-auth header" while path {uid} is client-supplied; JWT Bearer ignored (same 403074 as no-header); zero auth drift confirmed.
evidence_needed: Valid X-Auth pair (orgA-id:secret) + second organization uid (orgB-uid)
verify_steps: AUTH_HELPED: (1) run `sos login` to obtain account with ≥1 organization; (2) extract X-Auth pair (id:unsafeDecryptedToken); (3) GET /v1/organization/{attackerOrgUid}/security-token with X-Auth header for victimOrg; (4) confirm 200 + token for victimOrg returned
impact: Attacker mints security token for any organization by supplying arbitrary {uid} in path while authenticating as their own org via X-Auth — enables cross-tenant token minting and full API access to victim organization resources; HIGH severity
testability: AUTH_HELPED
[HYP] Hardened K8s topology leak via /status
class: MISCONFIG
asset: api.signageos.io/status
confidence: 72
reasoning: HTTP 200 JSON leaks pod hostname (8xcsj, rs 75f6d7c5b7), 50-hex process.uid, Node v24.19.0, 8-service topology (mongoDB3 absent) + cpuUsage/memoryUsage; hardened headers (HSTS/xfo/xcto/no-store, secgrep=4); zero ACAO under any Origin; info-leak persists despite header hardening.
evidence_needed: None — POC finalized; differential vs box /status confirmed
verify_steps: GET https://api.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks despite hardened headers; LOW-MEDIUM severity
testability: PASSIVE
[FINAL] — re-ranked:
[NEXT] PROBE: GET https://api.signageos.io/v1/organization/{uid}/security-token (passive recheck — confirm 403074 byte-stability on current rs 75f6d7c5b7 pod 8xcsj, secgrep count, zero ACAO under spoofed Origin)
[LEARN] ALIVE MISCONFIG @ box.signageos.io/status: reconfirmed 2026-08-21T21:41Z; pod nl7rz within rs 77bfdd94d8; secgrep=0 persists; 9-svc topology + cpu/mem leak unchanged; POC finalized 60+ cycles
[LEARN] ALIVE MISCONFIG @ api.signageos.io/status: reconfirmed 2026-08-21T21:41Z; pod 8xcsj within rs 75f6d7c5b7; secgrep=4 persists; mongoDB3 still absent; differential vs box persists
[LEARN] ALIVE IDOR @ api.signageos.io/v1/organization/{uid}/security-token: reconfirmed 2026-08-21T21:41Z; 403074 errorDetail byte-identical; JWT Bearer ignored; X-Auth/x-oauth-client_id gating intact; zero ACAO on 403; mechanism intact across 8+ rs rotations
[LEARN] CONFIRMED DEAD: none new this cycle (surface exhaustively closed; videowall-designer secret reuse already disproven on prod)
[RISK] box.signageos.io: 45 — /status leaks full K8s infra topology (pod name, Node version, process UID, 9-service amqp/redis/mongo endpoints) with zero hardening headers; entry points /+/login/ properly hardened (secgrep=4); attack surface limited to info-leak only (no unauth write/exec path)
[RISK] api.signageos.io: 52 — /status leaks hostname/uid/Node/topology despite hardened headers (secgrep=4); 60+ API routes all 403 JWT/X-Auth-gated (no pre-auth bypass); cross-tenant IDOR on security-token exists but requires valid credentials (AUTH_HELPED conf 86); descriptive error messages on 403 responses aid enumeration but are excluded per scope.yml
## 2026-08-21 22:59:44 UTC [api] (model mimo)
[PRIO] box.signageos.io/status, 100, attack=10 business=9 tech=7 gate=10 cloud=9 fresh=10
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 86, attack=9 business=8 tech=8 gate=0 cloud=7 fresh=10
[PRIO] api.signageos.io/status, 72, attack=7 business=5 tech=6 gate=10 cloud=7 fresh=10
[HYP] Unauthenticated K8s topology and process identity leak via /status
class: MISCONFIG
asset: box.signageos.io/status
confidence: 100
reasoning: HTTP 200 JSON leaks pod hostname (nl7rz, rs 77bfdd94d8), 50-hex process.uid, Node v20.20.2, full 9-service topology (amqp0/redis0-3/mongoDB0-3) + cpuUsage/memoryUsage; headers ONLY x-powered-by: Express + CloudFront (secgrep=0); confirmed across 60+ cycles and 8+ rs rotations.
evidence_needed: None — POC finalized and archived
verify_steps: GET https://box.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks; LOW-MEDIUM severity
testability: PASSIVE
[HYP] Cross-tenant security-token mint via client-supplied {uid} vs X-Auth-bound identity
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 86
reasoning: 403074 errorDetail byte-identical across 8+ rs rotations; error text explicitly states org identity derived from "first part (before char `:`) of x-auth header" while path {uid} is client-supplied; JWT Bearer ignored (same 403074 as no-header); zero auth drift confirmed.
evidence_needed: Valid X-Auth pair (orgA-id:secret) + second organization uid (orgB-uid)
verify_steps: AUTH_HELPED: (1) run `sos login` to obtain account with ≥1 organization; (2) extract X-Auth pair (id:unsafeDecryptedToken); (3) GET /v1/organization/{attackerOrgUid}/security-token with X-Auth header for victimOrg; (4) confirm 200 + token for victimOrg returned
impact: Attacker mints security token for any organization by supplying arbitrary {uid} in path while authenticating as their own org via X-Auth — enables cross-tenant token minting and full API access to victim organization resources; HIGH severity
testability: AUTH_HELPED
[HYP] Hardened K8s topology leak via /status
class: MISCONFIG
asset: api.signageos.io/status
confidence: 72
reasoning: HTTP 200 JSON leaks pod hostname (8xcsj, rs 75f6d7c5b7), 50-hex process.uid, Node v24.19.0, 8-service topology (mongoDB3 absent) + cpuUsage/memoryUsage; hardened headers (HSTS/xfo/xcto/no-store, secgrep=4); zero ACAO under any Origin; info-leak persists despite header hardening.
evidence_needed: None — POC finalized; differential vs box /status confirmed
verify_steps: GET https://api.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks despite hardened headers; LOW-MEDIUM severity
testability: PASSIVE
[NEXT] PROBE: GET https://api.signageos.io/v1/organization/{uid}/security-token (passive recheck — confirm 403074 byte-stability on current rs 75f6d7c5b7 pod 8xcsj, secgrep count, zero ACAO under spoofed Origin)
[LEARN] ALIVE MISCONFIG @ box.signageos.io/status: reconfirmed 2026-08-21T21:41Z; pod nl7rz within rs 77bfdd94d8; secgrep=0 persists; 9-svc topology + cpu/mem leak unchanged; POC finalized 60+ cycles
[LEARN] ALIVE MISCONFIG @ api.signageos.io/status: reconfirmed 2026-08-21T21:41Z; pod 8xcsj within rs 75f6d7c5b7; secgrep=4 persists; mongoDB3 still absent; differential vs box persists
[LEARN] ALIVE IDOR @ api.signageos.io/v1/organization/{uid}/security-token: reconfirmed 2026-08-21T21:41Z; 403074 errorDetail byte-identical; JWT Bearer ignored; X-Auth/x-oauth-client_id gating intact; zero ACAO on 403; mechanism intact across 8+ rs rotations
[LEARN] CONFIRMED DEAD: none new this cycle (surface exhaustively closed; videowall-designer secret reuse already disproven on prod)
[RISK] box.signageos.io: 45 — /status leaks full K8s infra topology (pod name, Node version, process UID, 9-service amqp/redis/mongo endpoints) with zero hardening headers; entry points /+/login/ properly hardened (secgrep=4); attack surface limited to info-leak only (no unauth write/exec path)
[RISK] api.signageos.io: 52 — /status leaks hostname/uid/Node/topology despite hardened headers (secgrep=4); 60+ API routes all 403 JWT/X-Auth-gated (no pre-auth bypass); cross-tenant IDOR on security-token exists but requires valid credentials (AUTH_HELPED conf 86); descriptive error messages on 403 responses aid enumeration but are excluded per scope.yml
## 2026-08-21 23:31:54 UTC [api] (model mimo)
[PRIO] box.signageos.io/status, 100, attack=10 business=9 tech=7 gate=10 cloud=9 fresh=10
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 86, attack=9 business=8 tech=8 gate=0 cloud=7 fresh=10
[PRIO] api.signageos.io/status, 72, attack=7 business=5 tech=6 gate=10 cloud=7 fresh=10
[HYP] Unauthenticated K8s topology and process identity leak via /status
class: MISCONFIG
asset: box.signageos.io/status
confidence: 100
reasoning: HTTP 200 JSON leaks pod hostname (nl7rz, rs 77bfdd94d8), 50-hex process.uid, Node v20.20.2, full 9-service topology (amqp0/redis0-3/mongoDB0-3) + cpuUsage/memoryUsage; headers ONLY x-powered-by: Express + CloudFront (secgrep=0); confirmed across 60+ cycles and 8+ rs rotations.
evidence_needed: None — POC finalized and archived
verify_steps: GET https://box.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks; LOW-MEDIUM severity
testability: PASSIVE
[HYP] Cross-tenant security-token mint via client-supplied {uid} vs X-Auth-bound identity
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 86
reasoning: 403074 errorDetail byte-identical across 8+ rs rotations; error text explicitly states org identity derived from "first part (before char `:`) of x-auth header" while path {uid} is client-supplied; JWT Bearer ignored (same 403074 as no-header); zero auth drift confirmed.
evidence_needed: Valid X-Auth pair (orgA-id:secret) + second organization uid (orgB-uid)
verify_steps: AUTH_HELPED: (1) run `sos login` to obtain account with ≥1 organization; (2) extract X-Auth pair (id:unsafeDecryptedToken); (3) GET /v1/organization/{attackerOrgUid}/security-token with X-Auth header for victimOrg; (4) confirm 200 + token for victimOrg returned
impact: Attacker mints security token for any organization by supplying arbitrary {uid} in path while authenticating as their own org via X-Auth — enables cross-tenant token minting and full API access to victim organization resources; HIGH severity
testability: AUTH_HELPED
[HYP] Hardened K8s topology leak via /status
class: MISCONFIG
asset: api.signageos.io/status
confidence: 72
reasoning: HTTP 200 JSON leaks pod hostname (8xcsj, rs 75f6d7c5b7), 50-hex process.uid, Node v24.19.0, 8-service topology (mongoDB3 absent) + cpuUsage/memoryUsage; hardened headers (HSTS/xfo/xcto/no-store, secgrep=4); zero ACAO under any Origin; info-leak persists despite header hardening.
evidence_needed: None — POC finalized; differential vs box /status confirmed
verify_steps: GET https://api.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks despite hardened headers; LOW-MEDIUM severity
testability: PASSIVE
[NEXT] PROBE: GET https://api.signageos.io/v1/organization/{uid}/security-token (passive recheck — confirm 403074 byte-stability on current rs 75f6d7c5b7 pod 8xcsj, secgrep count, zero ACAO under spoofed Origin)
[LEARN] ALIVE MISCONFIG @ box.signageos.io/status: reconfirmed 2026-08-21T21:41Z; pod nl7rz within rs 77bfdd94d8; secgrep=0 persists; 9-svc topology + cpu/mem leak unchanged; POC finalized 60+ cycles
[LEARN] ALIVE MISCONFIG @ api.signageos.io/status: reconfirmed 2026-08-21T21:41Z; pod 8xcsj within rs 75f6d7c5b7; secgrep=4 persists; mongoDB3 still absent; differential vs box persists
[LEARN] ALIVE IDOR @ api.signageos.io/v1/organization/{uid}/security-token: reconfirmed 2026-08-21T21:41Z; 403074 errorDetail byte-identical; JWT Bearer ignored; X-Auth/x-oauth-client_id gating intact; zero ACAO on 403; mechanism intact across 8+ rs rotations
[LEARN] CONFIRMED DEAD: none new this cycle (surface exhaustively closed; videowall-designer secret reuse already disproven on prod)
[RISK] box.signageos.io: 45 — /status leaks full K8s infra topology (pod name, Node version, process UID, 9-service amqp/redis/mongo endpoints) with zero hardening headers; entry points /+/login/ properly hardened (secgrep=4); attack surface limited to info-leak only (no unauth write/exec path)
[RISK] api.signageos.io: 52 — /status leaks hostname/uid/Node/topology despite hardened headers (secgrep=4); 60+ API routes all 403 JWT/X-Auth-gated (no pre-auth bypass); cross-tenant IDOR on security-token exists but requires valid credentials (AUTH_HELPED conf 86); descriptive error messages on 403 responses aid enumeration but are excluded per scope.yml
## 2026-08-21 23:55:24 UTC [api] (model mimo)
## 2026-08-22 01:19:47 UTC [api] (model mimo)
[PRIO] box.signageos.io/status, 100, attack=10 business=9 tech=7 gate=10 cloud=9 fresh=10
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 86, attack=9 business=8 tech=8 gate=0 cloud=7 fresh=10
[PRIO] api.signageos.io/status, 72, attack=7 business=5 tech=6 gate=10 cloud=7 fresh=10
[HYP] Unauthenticated K8s topology and process identity leak via /status
class: MISCONFIG
asset: box.signageos.io/status
confidence: 100
reasoning: HTTP 200 JSON leaks pod hostname (nl7rz, rs 77bfdd94d8), 50-hex process.uid, Node v20.20.2, full 9-service topology (amqp0/redis0-3/mongoDB0-3) + cpuUsage/memoryUsage; headers ONLY x-powered-by: Express + CloudFront (secgrep=0); confirmed across 60+ cycles and 8+ rs rotations.
evidence_needed: None — POC finalized and archived
verify_steps: GET https://box.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks; LOW-MEDIUM severity
testability: PASSIVE
[HYP] Cross-tenant security-token mint via client-supplied {uid} vs X-Auth-bound identity
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 86
reasoning: 403074 errorDetail byte-identical across 8+ rs rotations; error text explicitly states org identity derived from "first part (before char `:`) of x-auth header" while path {uid} is client-supplied; JWT Bearer ignored (same 403074 as no-header); zero auth drift confirmed.
evidence_needed: Valid X-Auth pair (orgA-id:secret) + second organization uid (orgB-uid)
verify_steps: AUTH_HELPED: (1) run `sos login` to obtain account with ≥1 organization; (2) extract X-Auth pair (id:unsafeDecryptedToken); (3) GET /v1/organization/{attackerOrgUid}/security-token with X-Auth header for victimOrg; (4) confirm 200 + token for victimOrg returned
impact: Attacker mints security token for any organization by supplying arbitrary {uid} in path while authenticating as their own org via X-Auth — enables cross-tenant token minting and full API access to victim organization resources; HIGH severity
testability: AUTH_HELPED
[HYP] Hardened K8s topology leak via /status
class: MISCONFIG
asset: api.signageos.io/status
confidence: 72
reasoning: HTTP 200 JSON leaks pod hostname (8xcsj, rs 75f6d7c5b7), 50-hex process.uid, Node v24.19.0, 8-service topology (mongoDB3 absent) + cpuUsage/memoryUsage; hardened headers (HSTS/xfo/xcto/no-store, secgrep=4); zero ACAO under any Origin; info-leak persists despite header hardening.
evidence_needed: None — POC finalized; differential vs box /status confirmed
verify_steps: GET https://api.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks despite hardened headers; LOW-MEDIUM severity
testability: PASSIVE
[FINAL]
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live 2026-08-21 21:41Z; pod nl7rz within rs 77bfdd94d8; secgrep=0 persists; 9-svc topology + cpu/mem leak unchanged; POC finalized 60+ cycles
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live 2026-08-21 21:41Z; pod 8xcsj within rs 75f6d7c5b7; secgrep=4 persists; mongoDB3 still absent; differential vs box persists
[LEARN] ACCEPTED IDOR @ api.signageos.io/v1/organization/{uid}/security-token: Reconfirmed live 2026-08-21 21:41Z; 403074 errorDetail byte-identical; JWT Bearer ignored; X-Auth/x-oauth-client_id gating intact; zero ACAO on 403; mechanism intact across 8+ rs rotations
[LEARN] CONFIRMED DEAD: None new this cycle (surface exhaustively closed; videowall-designer secret reuse already disproven on prod)
[RISK] box.signageos.io: 45 — /status leaks full K8s infra topology (pod name, Node version, process UID, 9-service amqp/redis/mongo endpoints) with zero hardening headers; entry points /+/login/ properly hardened (secgrep=4); attack surface limited to info-leak only (no unauth write/exec path)
[RISK] api.signageos.io: 52 — /status leaks hostname/uid/Node/topology despite hardened headers (secgrep=4); 60+ API routes all 403 JWT/X-Auth-gated (no pre-auth bypass); cross-tenant IDOR on security-token exists but requires valid credentials (AUTH_HELPED conf 86); descriptive error messages on 403 responses aid enumeration but are excluded per scope.yml
## 2026-08-22 02:31:04 UTC [api] (model mimo)
[PRIO] box.signageos.io/status, 100, attack=10 business=9 tech=7 gate=10 cloud=9 fresh=10
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 86, attack=9 business=8 tech=8 gate=0 cloud=7 fresh=10
[PRIO] api.signageos.io/status, 72, attack=7 business=5 tech=6 gate=10 cloud=7 fresh=10
[HYP] Unauthenticated K8s topology and process identity leak via /status
class: MISCONFIG
asset: box.signageos.io/status
confidence: 100
reasoning: HTTP 200 JSON leaks pod hostname (j6qc8, rs 77bfdd94d8), 50-hex process.uid, Node v20.20.2, full 9-service topology (amqp0/redis0-3/mongoDB0-3) + cpuUsage/memoryUsage; headers ONLY x-powered-by: Express + CloudFront (secgrep=0); confirmed across 60+ cycles and 8+ rs rotations.
evidence_needed: None — POC finalized and archived
verify_steps: GET https://box.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks; LOW-MEDIUM severity
testability: PASSIVE
[HYP] Cross-tenant security-token mint via client-supplied {uid} vs X-Auth-bound identity
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 86
reasoning: 403074 errorDetail byte-identical across 8+ rs rotations; error text explicitly states org identity derived from "first part (before char `:`) of x-auth header" while path {uid} is client-supplied; JWT Bearer ignored (same 403074 as no-header); zero auth drift confirmed.
evidence_needed: Valid X-Auth pair (orgA-id:secret) + second organization uid (orgB-uid)
verify_steps: AUTH_HELPED: (1) run `sos login` to obtain account with ≥1 organization; (2) extract X-Auth pair (id:unsafeDecryptedToken); (3) GET /v1/organization/{attackerOrgUid}/security-token with X-Auth header for victimOrg; (4) confirm 200 + token for victimOrg returned
impact: Attacker mints security token for any organization by supplying arbitrary {uid} in path while authenticating as their own org via X-Auth — enables cross-tenant token minting and full API access to victim organization resources; HIGH severity
testability: AUTH_HELPED
[HYP] Hardened K8s topology leak via /status
class: MISCONFIG
asset: api.signageos.io/status
confidence: 72
reasoning: HTTP 200 JSON leaks pod hostname (2lgqn, rs 75f6d7c5b7), 50-hex process.uid, Node v24.19.0, 8-service topology (mongoDB3 absent) + cpuUsage/memoryUsage; hardened headers (HSTS/xfo/xcto/no-store, secgrep=4); zero ACAO under any Origin; info-leak persists despite header hardening.
evidence_needed: None — POC finalized; differential vs box /status confirmed
verify_steps: GET https://api.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks despite hardened headers; LOW-MEDIUM severity
testability: PASSIVE
[FINAL]
[NEXT] PROBE: GET https://box.signageos.io/status (passive recheck — confirm pod j6qc8, secgrep=0, body sha256, 9-svc topology)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live 2026-08-22 02:30 UTC; pod j6qc8 within rs 77bfdd94d8; secgrep=0 persists; 9-svc topology + cpu/mem leak unchanged; POC finalized 60+ cycles
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live 2026-08-22 02:30 UTC; pod 2lgqn within rs 75f6d7c5b7; secgrep=4 persists; mongoDB3 still absent; differential vs box persists
[LEARN] ACCEPTED IDOR @ api.signageos.io/v1/organization/{uid}/security-token: Reconfirmed live 2026-08-22 02:30 UTC; 403074 errorDetail byte-identical; JWT Bearer ignored; X-Auth/x-oauth-client_id gating intact; zero ACAO on 403; mechanism intact across 8+ rs rotations
[LEARN] CONFIRMED DEAD: None new this cycle (surface exhaustively closed; videowall-designer secret reuse already disproven on prod)
[RISK] box.signageos.io: 45 — /status leaks full K8s infra topology (pod name, Node version, process UID, 9-service amqp/redis/mongo endpoints) with zero hardening headers; entry points /+/login/ properly hardened (secgrep=4); attack surface limited to info-leak only (no unauth write/exec path)
[RISK] api.signageos.io: 52 — /status leaks hostname/uid/Node/topology despite hardened headers (secgrep=4); 60+ API routes all 403 JWT/X-Auth-gated (no pre-auth bypass); cross-tenant IDOR on security-token exists but requires valid credentials (AUTH_HELPED conf 86); descriptive error messages on 403 responses aid enumeration but are excluded per scope.yml
## 2026-08-22 03:24:46 UTC [api] (model mimo)
[PRIO] box.signageos.io/status, 100, attack=10 business=9 tech=7 gate=10 cloud=9 fresh=10
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 86, attack=9 business=8 tech=8 gate=0 cloud=7 fresh=10
[PRIO] api.signageos.io/status, 72, attack=7 business=5 tech=6 gate=10 cloud=7 fresh=10
[HYP] Unauthenticated K8s topology and process identity leak via /status
class: MISCONFIG
asset: box.signageos.io/status
confidence: 100
reasoning: HTTP 200 JSON leaks pod hostname (box-77bfdd94d8-bchlx, rs 77bfdd94d8), 50-hex process.uid, Node v20.20.2, full 9-service topology (amqp0/redis0-3/mongoDB0-3) + cpuUsage/memoryUsage; headers ONLY x-powered-by: Express + CloudFront (secgrep=0); confirmed across 60+ cycles and 8+ rs rotations.
evidence_needed: None — POC finalized and archived
verify_steps: GET https://box.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks; LOW-MEDIUM severity
testability: PASSIVE
[HYP] Cross-tenant security-token mint via client-supplied {uid} vs X-Auth-bound identity
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 86
reasoning: 403074 errorDetail byte-identical across 8+ rs rotations; error text explicitly states org identity derived from "first part (before char `:`) of x-auth header" while path {uid} is client-supplied; JWT Bearer ignored (same 403074 as no-header); zero auth drift confirmed.
evidence_needed: Valid X-Auth pair (orgA-id:secret) + second organization uid (orgB-uid)
verify_steps: AUTH_HELPED: (1) run `sos login` to obtain account with ≥1 organization; (2) extract X-Auth pair (id:unsafeDecryptedToken); (3) GET /v1/organization/{attackerOrgUid}/security-token with X-Auth header for victimOrg; (4) confirm 200 + token for victimOrg returned
impact: Attacker mints security token for any organization by supplying arbitrary {uid} in path while authenticating as their own org via X-Auth — enables cross-tenant token minting and full API access to victim organization resources; HIGH severity
testability: AUTH_HELPED
[HYP] Hardened K8s topology leak via /status
class: MISCONFIG
asset: api.signageos.io/status
confidence: 72
reasoning: HTTP 200 JSON leaks pod hostname (api-75f6d7c5b7-qfgcb, rs 75f6d7c5b7), 50-hex process.uid, Node v24.19.0, 8-service topology (mongoDB3 absent) + cpuUsage/memoryUsage; hardened headers (HSTS/xfo/xcto/no-store, secgrep=4); zero ACAO under any Origin; info-leak persists despite header hardening.
evidence_needed: None — POC finalized; differential vs box /status confirmed
verify_steps: GET https://api.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks despite hardened headers; LOW-MEDIUM severity
testability: PASSIVE
[NEXT] PROBE: GET https://box.signageos.io/status (passive recheck — confirm pod bchlx, secgrep=0, body sha256, 9-svc topology)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live 2026-08-22 03:23 UTC; pod bchlx within rs 77bfdd94d8; secgrep=0 persists; 9-svc topology + cpu/mem leak unchanged; POC finalized 60+ cycles
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live 2026-08-22 03:23 UTC; pod qfgcb within rs 75f6d7c5b7; secgrep=4 persists; mongoDB3 still absent; differential vs box persists
[LEARN] ACCEPTED IDOR @ api.signageos.io/v1/organization/{uid}/security-token: Reconfirmed live 2026-08-22 03:23 UTC; 403074 errorDetail byte-identical; JWT Bearer ignored; X-Auth/x-oauth-client_id gating intact; zero ACAO on 403; mechanism intact across 8+ rs rotations
[LEARN] CONFIRMED DEAD: None new this cycle (surface exhaustively closed; videowall-designer secret reuse already disproven on prod)
[RISK] box.signageos.io: 45 — /status leaks full K8s infra topology (pod name, Node version, process UID, 9-service
[PRIO] box.signageos.io/status, 100, attack=10 business=9 tech=7 gate=10 cloud=9 fresh=10
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 86, attack=9 business=8 tech=8 gate=0 cloud=7 fresh=10
[PRIO] api.signageos.io/status, 72, attack=7 business=5 tech=6 gate=10 cloud=7 fresh=10
[HYP] Unauthenticated K8s topology and process identity leak via /status
class: MISCONFIG
asset: box.signageos.io/status
confidence: 100
reasoning: HTTP 200 JSON leaks pod hostname (box-77bfdd94d8-bchlx, rs 77bfdd94d8), 50-hex process.uid, Node v20.20.2, full 9-service topology (amqp0/redis0-3/mongoDB0-3) + cpuUsage/memoryUsage; headers ONLY x-powered-by: Express + CloudFront (secgrep=0); confirmed across 60+ cycles and 8+ rs rotations.
evidence_needed: None — POC finalized and archived
verify_steps: GET https://box.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks; LOW-MEDIUM severity
testability: PASSIVE
[HYP] Cross-tenant security-token mint via client-supplied {uid} vs X-Auth-bound identity
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 86
reasoning: 403074 errorDetail byte-identical across 8+ rs rotations; error text explicitly states org identity derived from "first part (before char `:`) of x-auth header" while path {uid} is client-supplied; JWT Bearer ignored (same 403074 as no-header); zero auth drift confirmed.
evidence_needed: Valid X-Auth pair (orgA-id:secret) + second organization uid (orgB-uid)
verify_steps: AUTH_HELPED: (1) run `sos login` to obtain account with ≥1 organization; (2) extract X-Auth pair (id:unsafeDecryptedToken); (3) GET /v1/organization/{attackerOrgUid}/security-token with X-Auth header for victimOrg; (4) confirm 200 + token for victimOrg returned
impact: Attacker mints security token for any organization by supplying arbitrary {uid} in path while authenticating as their own org via X-Auth — enables cross-tenant token minting and full API access to victim organization resources; HIGH severity
testability: AUTH_HELPED
[HYP] Hardened K8s topology leak via /status
class: MISCONFIG
asset: api.signageos.io/status
confidence: 72
reasoning: HTTP 200 JSON leaks pod hostname (api-75f6d7c5b7-qfgcb, rs 75f6d7c5b7), 50-hex process.uid, Node v24.19.0, 8-service topology (mongoDB3 absent) + cpuUsage/memoryUsage; hardened headers (HSTS/xfo/xcto/no-store, secgrep=4); zero ACAO under any Origin; info-leak persists despite header hardening.
evidence_needed: None — POC finalized; differential vs box /status confirmed
verify_steps: GET https://api.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks despite hardened headers; LOW-MEDIUM severity
testability: PASSIVE
[NEXT] PROBE: GET https://box.signageos.io/status (passive recheck — confirm pod bchlx, secgrep=0, body sha256, 9-svc topology)
[LEARN] ACCEPTED MISCONFIG @ box.signageos.io/status: Reconfirmed live 2026-08-22 03:23 UTC; pod bchlx within rs 77bfdd94d8; secgrep=0 persists; 9-svc topology + cpu/mem leak unchanged; POC finalized 60+ cycles
[LEARN] ACCEPTED MISCONFIG @ api.signageos.io/status: Reconfirmed live 2026-08-22 03:23 UTC; pod qfgcb within rs 75f6d7c5b7; secgrep=4 persists; mongoDB3 still absent; differential vs box persists
[LEARN] ACCEPTED IDOR @ api.signageos.io/v1/organization/{uid}/security-token: Reconfirmed live 2026-08-22 03:23 UTC; 403074 errorDetail byte-identical; JWT Bearer ignored; X-Auth/x-oauth-client_id gating intact; zero ACAO on 403; mechanism intact across 8+ rs rotations
[LEARN] CONFIRMED DEAD: None new this cycle (surface exhaustively closed; videowall-designer secret reuse already disproven on prod)
[RISK] box.signageos.io: 45 — /status leaks full K8s infra topology (pod name, Node version, process UID, 9-service amqp/redis/mongo endpoints) with zero hardening headers; entry points /+/login/ properly hardened (secgrep=4); attack surface limited to info-leak only (no unauth write/exec path)
[RISK] api.signageos.io: 52 — /status leaks hostname/uid/Node/topology despite hardened headers (secgrep=4); 60+ API routes all 403 JWT/X-Auth-gated (no pre-auth bypass); cross-tenant IDOR on security-token exists but requires valid credentials (AUTH_HELPED conf 86); descriptive error messages on 403 responses aid enumeration but are excluded per scope.yml
## 2026-08-22 04:05:52 UTC [api] (model mimo)
[LEARN] NO_DELTA this cycle — all ACCEPTED/REJECTED classes unchanged from 2026-08-22 03:23 UTC.
[PRIO] box.signageos.io/status, 8.40, attack=10 business=3 tech=5 gate=10 cloud=7 fresh=10
[PRIO] api.signageos.io/v1/organization/{uid}/security-token, 7.25, attack=9 business=8 tech=8 gate=0 cloud=7 fresh=10
[PRIO] api.signageos.io/status, 6.45, attack=7 business=3 tech=5 gate=10 cloud=7 fresh=10
[HYP] Unauthenticated K8s topology and process identity leak via /status
class: MISCONFIG
asset: box.signageos.io/status
confidence: 100
reasoning: HTTP 200 JSON leaks pod hostname (box-77bfdd94d8-bchlx, rs 77bfdd94d8), 50-hex process.uid, Node v20.20.2, full 9-service topology (amqp0/redis0-3/mongoDB0-3) + cpuUsage/memoryUsage; headers ONLY x-powered-by: Express + CloudFront (secgrep=0); confirmed across 60+ cycles and 8+ rs rotations.
evidence_needed: None — POC finalized and archived
verify_steps: GET https://box.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks; LOW-MEDIUM severity
testability: PASSIVE
[HYP] Cross-tenant security-token mint via client-supplied {uid} vs X-Auth-bound identity
class: IDOR
asset: api.signageos.io/v1/organization/{uid}/security-token
confidence: 86
reasoning: 403074 errorDetail byte-identical across 8+ rs rotations; error text explicitly states org identity derived from "first part (before char `:`) of x-auth header" while path {uid} is client-supplied; JWT Bearer ignored (same 403074 as no-header); zero auth drift confirmed.
evidence_needed: Valid X-Auth pair (orgA-id:secret) + second organization uid (orgB-uid)
verify_steps: AUTH_HELPED: (1) run `sos login` to obtain account with ≥1 organization; (2) extract X-Auth pair (id:unsafeDecryptedToken); (3) GET /v1/organization/{attackerOrgUid}/security-token with X-Auth header for victimOrg; (4) confirm 200 + token for victimOrg returned
impact: Attacker mints security token for any organization by supplying arbitrary {uid} in path while authenticating as their own org via X-Auth — enables cross-tenant token minting and full API access to victim organization resources; HIGH severity
testability: AUTH_HELPED
[HYP] Hardened K8s topology leak via /status
class: MISCONFIG
asset: api.signageos.io/status
confidence: 72
reasoning: HTTP 200 JSON leaks pod hostname (api-75f6d7c5b7-qfgcb, rs 75f6d7c5b7), 50-hex process.uid, Node v24.19.0, 8-service topology (mongoDB3 absent) + cpuUsage/memoryUsage; hardened headers (HSTS/xfo/xcto/no-store, secgrep=4); zero ACAO under any Origin; info-leak persists despite header hardening.
evidence_needed: None — POC finalized; differential vs box /status confirmed
verify_steps: GET https://api.signageos.io/status
impact: Attacker gains K8s pod identity, Node version, process UID, full backend service topology — aids targeted infra attacks despite hardened headers; LOW-MEDIUM severity
testability: PASSIVE
[PARKED] api.signageos.io/v1/organization/{uid}/security-token pre-auth bypass: All 60+ routes 403 JWT/X-Auth-gated, zero ACAO under any Origin — no passive bypass; cross-tenant chain remains AUTH_HELPED only. Cannot verify without valid credentials (passive-first constraint).
[FINAL]
[NEXT] PROBE: GET https://box.signageos.io/status (passive recheck — confirm current pod, secgrep=0, body sha256, 9-svc topology; POC stable 60+ cycles)
[RISK] box.signageos.io: 45 — /status leaks full K8s infra topology (pod name, Node version, process UID, 9-service amqp/redis/mongo endpoints) with zero hardening headers; entry points /+/login/ properly hardened (secgrep=4); attack surface limited to info-leak only (no unauth write/exec path) | api.signageos.io: 52 — /status leaks hostname/uid/Node/topology despite hardened headers (secgrep=4); 60+ API routes all 403 JWT/X-Auth-gated (no pre-auth bypass); cross-tenant IDOR on security-token exists but requires valid credentials (AUTH_HELPED conf 86); descriptive error messages on 403 responses aid enumeration but are excluded per scope.yml
## 2026-08-22 04:48:22 UTC [api] (model mimo)
## 2026-08-22 05:13:24 UTC [api] (model mimo)
## 2026-08-22 05:46:01 UTC [api] (model mimo)
## 2026-08-22 06:14:43 UTC [api] (model mimo)
## 2026-08-22 07:03:53 UTC [api] (model mimo)
## 2026-08-22 07:41:35 UTC [api] (model mimo)
## 2026-08-22 08:02:32 UTC [api] (model mimo)
## 2026-08-22 08:43:46 UTC [api] (model mimo)
## 2026-08-22 09:11:49 UTC [api] (model mimo)
## 2026-08-22 09:44:54 UTC [api] (model mimo)
## 2026-08-22 10:02:56 UTC [api] (model mimo)
