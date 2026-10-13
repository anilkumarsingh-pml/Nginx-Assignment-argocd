# Local Kind GitOps onboarding

## Prerequisites

- Colima (or Docker Desktop) with enough RAM for **two** Kind clusters (~8 GiB recommended)
- `kind`, `kubectl`, `helm`, `docker`
- This repo pushed to `https://github.com/anilkumarsingh-pml/Nginx-Assignment-argocd.git`

## Clusters

```bash
kind create cluster --name non-prod-cluster
kind create cluster --name prod-cluster
```

Contexts:

- `kind-non-prod-cluster`
- `kind-prod-cluster`

If creating a second/third cluster fails while others are running (cgroup / node prep errors), stop one control-plane container (`docker stop <name>-control-plane`), create the new cluster, then `docker start` the stopped node.

Do **not** deploy this project's workloads onto an unrelated `dev-cluster`.

## App images (no registry)

```bash
for app in storefront checkout-api admin-console; do
  docker build -t "${app}:v1" "apps/${app}"
  kind load docker-image "${app}:v1" --name non-prod-cluster
  kind load docker-image "${app}:v1" --name prod-cluster
done
```

If `kind load` fails on multi-arch digests, import via containerd instead:

```bash
NODE=non-prod-cluster-control-plane   # or prod-cluster-control-plane
docker save storefront:v1 | docker exec -i "$NODE" ctr -n k8s.io images import -
```

To copy an image already on one Kind node to another:

```bash
SRC=non-prod-cluster-control-plane
DST=prod-cluster-control-plane
docker exec "$SRC" ctr -n k8s.io images export - storefront:v1 \
  | docker exec -i "$DST" ctr -n k8s.io images import -
```

## Argo CD images (when quay/ghcr pulls fail)

Pre-pull on the host, then import into both nodes (tags match Argo CD `v3.5.4` install):

```bash
IMAGES=(
  quay.io/argoproj/argocd:v3.5.4
  ghcr.io/dexidp/dex:v2.45.1
  public.ecr.aws/docker/library/redis:8.2.3-alpine
  haproxy:3.0.8-alpine
)

for cluster in non-prod-cluster prod-cluster; do
  for img in "${IMAGES[@]}"; do
    docker pull --platform linux/arm64 "$img"   # use amd64 on Intel Macs
    docker save "$img" | docker exec -i "${cluster}-control-plane" ctr -n k8s.io images import -
  done
done
```

After install, if pods still try to pull over TLS-broken networks, set `imagePullPolicy: IfNotPresent` on Argo CD Deployments/StatefulSet (including init containers).

## Install Argo CD

Use **server-side apply** so the ApplicationSet CRD is not rejected for oversized annotations:

```bash
ARGOCD_VERSION=v3.5.4

for ctx in kind-non-prod-cluster kind-prod-cluster; do
  kubectl --context "$ctx" create namespace argocd --dry-run=client -o yaml \
    | kubectl --context "$ctx" apply -f -
  kubectl --context "$ctx" apply --server-side --force-conflicts -n argocd \
    -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"
  kubectl --context "$ctx" -n argocd rollout status deploy/argocd-server --timeout=300s
done
```

Admin password (per cluster):

```bash
kubectl --context kind-non-prod-cluster -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d; echo

kubectl --context kind-prod-cluster -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d; echo
```

## Bootstrap apps (App-of-Apps)

Roots point at the bootstrap Helm charts. Those charts render AppProject, namespaces, and one Application CR per entry in `applications:`.

```bash
kubectl --context kind-non-prod-cluster apply -f argocd/nonprod/app-of-apps/root.yaml
kubectl --context kind-prod-cluster apply -f argocd/prod/app-of-apps/root.yaml
```

Watch sync:

```bash
kubectl --context kind-non-prod-cluster -n argocd get applications
kubectl --context kind-prod-cluster -n argocd get applications
```

Expected Applications (each env): `root-*`, `storefront`, `checkout-api`, `admin-console` → Synced / Healthy.

## Argo CD UI

Each cluster has its own Argo CD (two UIs). Port-forwards stop when the shell exits — restart them as needed:

```bash
# Terminal 1 — nonprod
kubectl --context kind-non-prod-cluster -n argocd port-forward svc/argocd-server 8080:443

# Terminal 2 — prod
kubectl --context kind-prod-cluster -n argocd port-forward svc/argocd-server 8081:443
```

| Env | URL | User |
|-----|-----|------|
| nonprod | https://localhost:8080 | `admin` |
| prod | https://localhost:8081 | `admin` |

Use **https** and accept the self-signed certificate warning.

## Verify a workload

```bash
kubectl --context kind-non-prod-cluster -n storefront port-forward svc/storefront 8088:80
# open http://localhost:8088 — expect the Storefront page
```

Prod uses `replicaCount: 2` via `charts/webapp/values-prod.yaml`.
