## 2026-08-22 STATUS: CONFIRMED — END-TO-END DEMONSTRATED + SUPERSET ROOT CAUSE FOUND

- Researcher executed the mint leg live: POST /v1/organization/{victimUid}/security-token with account-tier X-Auth returned 201 + working securityToken on victim org (9249538cf67fd2931a0d0c3a708dba3a680a) -> token bec343d38d9123cd8d53 / secret 1029675... Q6 CLOSED.
- SUPERSET ROOT CAUSE reported by researcher: GET /v1/organization (list) returns ALL organizations platform-wide INCLUDING oauthClientId+oauthClientSecret per org; stolen pair authenticates as victim org on /v1/device. Full report submitted to security@signageos.io >4 days ago, awaiting response.
- Two-tier gate mapped live: unauth -> 403105 WRONG_JWT_TOKEN; org-tier token -> 403100 INAPPROPRIATE_ORGANIZATION_TOKEN; only ACCOUNT-tier tokens reach handler (principal-type boundary crossing = why binding was missing).
- DO-NOT-REDO: bots must not re-probe this endpoint family or re-draft; vendor submission is in flight.

## 2026-08-22 UPGRADED LEAD (source-audit deep-dive, ox-alpha-free)


EVIDENCE (all passive, verified 2026-08-22):
1. Live probe: unauth GET /v1/organization/0000000000000000/security-token -> 403 errorCode=403074 MISSING_ACCOUNT_ID_TO_AUTHENTICATE, errorDetail admits identity = first part of x-auth header (middleware consumes X-Auth BEFORE route resolution; all sibling paths return ENDPOINT_NOT_FOUND instead -> this endpoint uniquely pre-auths).
2. signageos/sdk src/RestApi/Organization/Token/OrganizationTokenManagement.ts: getUrl() builds organization/{uid}/security-token[/tokenId]; create() POSTs {name} and parses OrganizationFullToken {id,name,securityToken}; get() lists OrganizationToken {id,name,organizationUid}.
3. tests/unit/RestApi/helper.ts: auth header format confirmed x-auth: clientId:secret.
4. Git history of Token module (2024-07..2025-10): features/refactors only, NO security/binding fixes ever shipped.

UPGRADED TEST MATRIX (both orgs owned by tester; POST artifact named idor-poc, DELETEd after):
  A->A GET baseline expect 200 list
  A->B GET victim-uid expect ? (read leg)
  A->B POST {name:'idor-poc'} expect ? (MINT leg - Critical if 201+FullToken binds to B)
  B->A GET reverse control
  cleanup: DELETE any created token via returned id

IMPACT IF CONFIRMED: attacker with own valid X-Auth mints working API credentials inside arbitrary victim organization -> full device/applet/content API access as victim tenant -> Critical (CVSS ~9.1 AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:L equivalent class).
SCOPE NOTE: errorDetail text previously excluded descriptive errors per scope.yml; this lead is NOT error-text based - it is behavior-based (token minting), in-scope asset api.signageos.io.
