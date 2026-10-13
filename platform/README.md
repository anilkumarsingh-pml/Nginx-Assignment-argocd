# platform — the tenant

Single-tenant GitOps tree (lab analogue of PML `mfv2/`).

```
platform/
├── argocd-deployable/     # apply-once root Applications
├── bootstrapping_nonprod/ # root Helm → layer Applications
├── bootstrapping_prod/
├── nonprod/project-platform/
│   ├── infra-manifests/app-projects/
│   └── app-of-apps/       # Helm → workload Applications
└── prod/project-platform/
    ├── infra-manifests/app-projects/
    ├── app-of-apps/
    └── app-helm-chart/webapp/
```

Flow: root → bootstrap `deployments[]` → AppProjects + apps App-of-Apps → storefront / checkout-api / admin-console.

Demo app **sources** live at repo-root `apps/` (stand-in for separate product repos).
