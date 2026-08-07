# Inventory: signageos

## Seed 2026-08-07 (passive recon)

### Hosts (in scope - ONLY these two)
- box.signageos.io — 302 (redirect target TBD; box = player/dashboard?)
- api.signageos.io — 200 on /

### Excluded / not eligible (do NOT report, see scope.yml)
- All the program's exclusion list (DoS, enumeration, TLS, CSRF-on-anonymous, clickjacking-no-exploit, email-verification, etc.)

### Code surface (github.com/signageos, 59 repos)
- First-party: sdk (TS), cli (TS), applet-sandbox, platform (C++), videowall-designer (TS), server-bootstrap (Shell), kubernetes-ingress (Go), minio
- Mostly forks: DefinitelyTyped, HTML5test, zip.js, libcec, raspidmx, WebGLSamples, node-amqp10, webpack-dev-server, aports, charts

### Open questions
- Where box.signageos.io redirects to (auth model, session cookies)
- API auth model of api.signageos.io (key? OAuth? JWT?)
- Relationship of sdk/cli repos to api.signageos.io endpoints
