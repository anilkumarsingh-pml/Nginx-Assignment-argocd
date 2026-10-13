# ADR 0001: GitOps with Argo CD and Helm

## Status

Accepted (learning lab)

## Context

We already had raw Kubernetes YAML (`Deployment` + `Service`) and a Kind workflow. The training assignment asks to:

- Study Helm
- Put app + Argo CD config in a Git repo
- Install the app with Argo CD and Helm on Kind

## Decision

1. Package the existing Deployment/Service as a **Helm chart** under `charts/nginx-app`.
2. Declare desired delivery with **Argo CD Application** manifests that render that chart.
3. Keep GitHub (`Nginx-Assignment-argocd`) as the remote Argo CD clones.
4. Keep the image local to Kind (`nginx-app:v1` + `IfNotPresent` + `kind load`) — no registry required for the lab.

## Consequences

**Positive**

- Learn industry-standard packaging (Helm) and delivery (Argo CD).
- Values files teach environment-specific config without forking templates.
- Cluster state can be audited from Git history.

**Trade-offs**

- Must push to GitHub before Argo CD sees changes (laptop disk is not the source).
- Private repos need an Argo CD repository credential.
- Local images still require a manual `kind load` step.
