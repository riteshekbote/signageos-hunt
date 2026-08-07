# Ranked Hypotheses

## SEED 2026-08-07 (from passive recon, not model-generated yet)
- [55] api.signageos.io: 200-on-root API — enumerate auth model and API surface for authz/logic flaws (from inventory seed)
- [50] box.signageos.io: 302 redirect flow — check session handling and post-login logic (from inventory seed)
- [45] signageos org sdk/cli repos: first-party client code referencing api endpoints — map endpoints for logic hunting (from inventory seed)

## RANKED HYPOTHESES 2026-08-07 18:32:56 UTC
- [65] box.signageos.io/login: Auth0 redirect_uri validation bypass on box.signageos.io (from reports/hypotheses-nemotron3.txt)
- NEXT(hypotheses-nemotron3.txt): RAG: Clone and grep signageos/sdk (TypeScript) and signageos/cli repos for API baseURL patterns, auth header construction, and endpoint paths — this maps the hi
- LEARN: REJECTED AUTH @ box.signageos.io/login: Auth0 redirect_uri validation not testable passively without tenant config access
- LEARN: REJECTED IDOR @ api.signageos.io: No public API endpoints discoverable via passive probing (all common paths 404)
- LEARN: ACCEPTED MISCONFIG @ box.signageos.io CSP: Overly broad connect-src/frame-src (20+ origins) confirmed — expands postMessage/origin trust boundary
