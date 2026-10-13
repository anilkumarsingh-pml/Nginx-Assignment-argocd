# Add a tenant

This lab keeps **one tenant** (`platform/`) on purpose.

PML hosts multiple tenants under one repo (e.g. `mfv2/`). Adding a second tenant here would mean a sibling folder with its own `argocd-deployable`, `bootstrapping_*`, and `prod|nonprod/project-*` trees — plus new AppProjects.

Do that only if a human explicitly asks for multi-tenant practice; otherwise extend apps inside `platform/`.
