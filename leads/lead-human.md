## 2026-08-22 UPGRADED LEAD (source-audit deep-dive, ox-alpha-free)

[UNVALIDATED] api.signageos.io/v1/organization/{uid}/security-token: source audit of signageos/sdk reveals endpoint FAMILY not single endpoint - GET list + POST create (returns OrganizationFullToken with raw securityToken) + DELETE /{tokenId}. If path {uid} is not bound to X-Auth prefix org, POST variant = CROSS-TENANT CREDENTIAL MINTING (Critical), not just metadata read. Two owned accounts staged for demo. | confidence 86 -> pending 4-request matrix

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
