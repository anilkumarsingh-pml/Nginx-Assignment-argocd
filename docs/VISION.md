# Vision

Deliver the same GitOps topology as PML `pml-argocd`: tenant folder, argocd-deployable roots, bootstrap Helm, nested app-of-apps — running on Kind for nonprod and prod.

Scope of this repository:

- One tenant (`platform/`)
- Two clusters (`non-prod-cluster`, `prod-cluster`)
- Three applications (`storefront`, `checkout-api`, `admin-console`)

Out of scope (present in full PML platforms, not here): multi-repo product delivery and a full cluster infra stack (Istio, Kafka, observability).
