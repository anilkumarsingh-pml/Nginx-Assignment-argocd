# Add a tenant

This repository keeps **one tenant** (`platform/`) by design.

PML hosts multiple tenants under one repo (e.g. `mfv2/`). Adding a second tenant here means a sibling folder with its own `argocd-deployable`, `bootstrapping_*`, and `prod|nonprod/project-*` trees — plus new AppProjects.

Prefer extending applications inside `platform/` unless multi-tenant isolation is explicitly required.
