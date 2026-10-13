# App-of-Apps layers

## Why layers

PML does not put every workload Application in the root bootstrap. Bootstrap lists **layers**; each layer chart generates more Applications.

| Layer | Chart / path | Generates |
|-------|--------------|-----------|
| Root | `argocd-deployable/.../bootstrapping-apps.yaml` | One Application → bootstrap chart |
| Bootstrap | `platform/bootstrapping_*` | `platform-appprojects`, `platform-apps` |
| Apps App-of-Apps | `platform/*/project-platform/app-of-apps` | `storefront`, `checkout-api`, `admin-console` |

## Onboarding

Add to `applications:` in **both** env `app-of-apps/values.yaml` files. Do not add Application YAML by hand. Do not add workload entries to bootstrap `deployments:` (that list is for layers only).
