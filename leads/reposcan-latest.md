
===== REPOSCAN 2026-08-07 18:57:17 UTC =====
## Grep hits:
SCAN SUMMARY: 1055 code/config files scanned, 1 hits
reposcan-raw/signageos/videowall-designer/sos/videoTiming.js:19: secret: '9d5e257e02691412fa83eb3c256910609ba62fa68df0117479a4865e36bfe1c9',

## Model analysis:
[0m
> build · nemotron-3-ultra-free
[0m
[0m→ [0mRead reposcan-raw/signageos/videowall-designer/sos/videoTiming.js
[0m
[0m$ [0mecho -n '9d5e257e02691412fa83eb3c256910609ba62fa68df0117479a4865e36bfe1c9' | sha256sum
564c293ba2a1d60dd6e8f508a7ef65400424ae42b80be0ae04498d528a8a774e  -
[0m
### Classification Table

| Category | Hits |
|----------|------|
| **TEST_OR_EXAMPLE** | `reposcan-raw/signageos/videowall-designer/sos/videoTiming.js:19` — Default params for test fixture `setupVideoTimings()`; imports `@signageos/test`; `apiUrl` points to `api.kiera.office.signageos.io` (dev/staging) |
| REAL_SECRET | — |
| ENDPOINT_LEAK | — |
| INTERESTING | — |

### Verdict

| File:Line | Secret SHA256 (trunc) | Classification | REPORT_CANDIDATE |
|-----------|----------------------|----------------|------------------|
| reposcan-raw/signageos/videowall-designer/sos/videoTiming.js:19 | 564c293ba2a1d60d | TEST_OR_EXAMPLE | **no** |

**Summary**: Single hit is a test fixture with hardcoded default credentials for a dev/staging environment (`kiera.office.signageos.io`). Not a production secret — no reportable finding.
