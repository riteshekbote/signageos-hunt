# signageos-hunt

24/7 multi-model bug-hunting automation for **signageOS**.

Scope: **box.signageos.io** and **api.signageos.io** only (full exclusion list in `scope.yml`).

How it works:

- 5 opencode models (Big Pickle, Nemotron 3 Ultra, Longcat, Ling 3.0, Laguna) hunt in parallel every **10 minutes**, rotating box / api
- Deep public-repo scan of the `signageos/` GitHub org every **30 minutes**
- Triager job validates every lead with a second model + live passive probe, keeping a running count in `reports/valid-bugs.md`
- All testing is **passive and read-only**; every report needs a concrete POC (scanner output alone is rejected by the program)
- Secrets are committed only as hashes

| Artifact | Purpose |
|---|---|
| `leads/` | Candidate findings (UNVALIDATED) |
| `triage/` | Validation verdicts |
| `reports/valid-bugs.md` | Validated findings + running count |
| `scope.yml` | Program scope and exclusions (edit to adjust) |
