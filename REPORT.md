# NGINX Kubernetes Assignment — Written Report

This report answers the assignment questions using observations from the Kind cluster `nginx-assignment`. Supporting kubectl dumps live in [`evidence/`](evidence/).

---

## Environment notes

- Cluster: Kind context `kind-kind` (Colima Docker runtime)
- Images: `nginx-app:v1`, `nginx-app:v2` built locally and loaded with `kind load docker-image --name kind`
- Access: ClusterIP Service + `kubectl port-forward` (and in-cluster probes for mixed-version sampling)
- Assignment baseline after labs: 2 replicas, RollingUpdate `maxSurge/maxUnavailable: 25%`, image `nginx-app:v1`

---

## Section 4 — Scaling & Pod deletion

**Observed**

| State | Pods | ReplicaSet |
|-------|------|------------|
| Before | 2 | `nginx-app-7c946cf5d4` |
| After scale to 5 | 5 | same RS `nginx-app-7c946cf5d4` |
| After scale to 2 | 2 | same RS |

Scaling changed the **desired** replica count on the active ReplicaSet. No new ReplicaSet was created because the Pod template (image) did not change.

**What happens if one running Pod is manually deleted?**  
Kubernetes (via the ReplicaSet controller) notices that `current < desired` and creates a replacement Pod. In the lab, deleting `nginx-app-7c946cf5d4-phzgg` immediately created `nginx-app-7c946cf5d4-vwhgl` with a new name and IP while desired replicas stayed at 2. See [`evidence/02b-pod-delete-self-healing.txt`](evidence/02b-pod-delete-self-healing.txt).

---

## Section 6 — maxSurge / maxUnavailable experiments

Tested at **4 replicas** while flipping images between v1 and v2.

| Configuration | Replicas | maxSurge | maxUnavailable | Maximum / availability observed | Observed rollout behavior |
|---|---|---|---|---|---|
| 1 | 4 | 1 | 0 | minReady **4**; temporary total Pods up to 6 (incl. terminating) | Safer/slower: never below full ready; surge allowed |
| 2 | 4 | 0 | 1 | minReady **3** | No surge headroom; must terminate before creating; slight availability dip |
| 3 | 4 | 50% | 50% | minReady **2**; total Pods peaked at 8 | Aggressive: faster batch replacement; larger availability swing |

Raw watches: [`evidence/04-surge-1.txt`](evidence/04-surge-1.txt), [`evidence/04-surge-2.txt`](evidence/04-surge-2.txt), [`evidence/04-surge-3.txt`](evidence/04-surge-3.txt).

### Answers

**What does maxSurge control?**  
How many Pods above the desired replica count may exist during a rollout (absolute number or percent). It caps temporary extra capacity / cluster resource use.

**What does maxUnavailable control?**  
How many Pods may be unavailable (below desired) during a rollout. It caps how much serving capacity you are willing to lose while updating.

**How do these settings affect deployment speed?**  
Higher surge and/or higher unavailable let Kubernetes replace more Pods in parallel → faster rollouts. Low surge + zero unavailable forces a more serial create-then-delete pattern → slower.

**How do they affect application availability?**  
`maxUnavailable: 0` preserves full desired capacity (needs surge headroom). Higher `maxUnavailable` accepts temporary capacity loss. Aggressive percentages complete faster but risk more impact if the new version is bad.

**Preferred production configuration?**  
For a user-facing web app: **`maxUnavailable: 0`** and a modest **`maxSurge` (e.g. 1 or 25%)**, plus readiness probes. That prioritizes availability over raw rollout speed, assuming the cluster has spare capacity for the surge Pods.

---

## Section 7 — Can the Service route to both versions during a rolling update?

**Yes.**

During the slow rollout (4 replicas, `maxSurge=1`, `maxUnavailable=0`), both ReplicaSets had Running Pods at the same time. Sample 2 from the in-cluster probe showed:

- Pods on RS `58f949ff7c` serving **Version 2**
- Pods on RS `7c946cf5d4` serving **Version 1**
- Service hits returned both Version 2 and later Version 1

Evidence: [`evidence/03c-mixed-versions-incluster.txt`](evidence/03c-mixed-versions-incluster.txt).

**Why?** The Service selects Endpoints by **labels** (`app=nginx-app`), not by image tag. Old and new Pods share those labels during RollingUpdate, so both receive traffic until the old ReplicaSet scales to 0.

---

## Section 8 — Rollback

After deploying Version 2, `kubectl rollout undo deploy/nginx-app` restored Version 1.

**Observed after rollback**

- Deployment image: `nginx-app:v1`
- Active ReplicaSet: `nginx-app-7c946cf5d4` scaled back up
- Previous Version 2 ReplicaSet `nginx-app-58f949ff7c` remained at **0 replicas** (not deleted)
- Webpage: `NGINX Application — Version 1`

Evidence: [`evidence/05-rollback-and-analysis.txt`](evidence/05-rollback-and-analysis.txt).

**How does Kubernetes know which version to roll back to?**  
The Deployment controller stores revisions of the Pod template (ReplicaSet history, limited by `revisionHistoryLimit`). Undo reverts to the previous revision’s template.

**What happens to the Version 2 ReplicaSet?**  
It is scaled to 0 but typically kept so you can roll forward again or inspect history.

**Why is maintaining Deployment history useful?**  
Fast incident recovery, audit of what changed, and the ability to move between known-good revisions without rebuilding images.

---

## Section 9 — Deployment analysis (post-lab snapshot)

From [`evidence/06-final-deployment-analysis.txt`](evidence/06-final-deployment-analysis.txt) / live describe during rollback:

| Field | Value (at analysis time) |
|-------|---------------------------|
| Desired replicas | 4 (later scaled back toward 2 for cleanup) |
| Current / available / ready | 4 / 4 / 4 |
| Strategy | RollingUpdate |
| maxSurge | 1 (during rollback lab; YAML defaults to 25%) |
| maxUnavailable | 0 (during rollback lab; YAML defaults to 25%) |
| Current image | `nginx-app:v1` |
| ReplicaSets | `nginx-app-7c946cf5d4` (active), `nginx-app-58f949ff7c` (scaled to 0) |

### Relationship: Deployment → ReplicaSet → Pod → Container

The **Deployment** declares desired state (replicas, strategy, Pod template) and owns **ReplicaSets**. Each ReplicaSet keeps a set of identical **Pods** matching its template hash. Each Pod runs one or more **Containers** from an image (`nginx-app:v1` / `v2`). Scaling adjusts replica counts on the active ReplicaSet; changing the template creates a new ReplicaSet and rolls Pods; rollback reactivates a previous ReplicaSet.

---

## Submission questions (1–10)

### 1. What is the difference between a Deployment and a ReplicaSet?

A **ReplicaSet** ensures a fixed number of identical Pods for one Pod template. A **Deployment** sits above ReplicaSets: it creates/manages them, performs rolling updates when the template changes, tracks revisions, and supports rollback. You usually manage Deployments; ReplicaSets are the implementation detail.

### 2. How does Kubernetes maintain the desired number of replicas?

Controllers continuously reconcile. The ReplicaSet controller compares desired vs current Pod count for its selector and creates or deletes Pods until they match.

### 3. What happens when a Pod is deleted?

The Pod is terminated and removed. If it belonged to a ReplicaSet whose desired count is still N, a new Pod is created automatically (new name/IP). The Service continues to load-balance to the remaining/new ready Pods.

### 4. Explain RollingUpdate.

RollingUpdate gradually replaces old Pods with new ones. A new ReplicaSet is created for the new template; it scales up while the old ReplicaSet scales down, respecting `maxSurge` and `maxUnavailable`, so some capacity usually remains available throughout.

### 5. Explain maxSurge.

Maximum number (or percent) of Pods that may be created **above** the desired replica count during a rollout. Example: desired 4, `maxSurge: 1` → up to 5 Pods temporarily.

### 6. Explain maxUnavailable.

Maximum number (or percent) of Pods that may be **unavailable** relative to desired during a rollout. Example: desired 4, `maxUnavailable: 1` → as few as 3 available Pods temporarily.

### 7. Why can multiple ReplicaSets exist for the same Deployment?

Each unique Pod template hash gets its own ReplicaSet. During (and after) rollouts, the Deployment keeps the new RS and older RS objects (scaled down) for history and rollback, up to `revisionHistoryLimit`.

### 8. Can Version 1 and Version 2 receive traffic at the same time during a rolling update? Explain.

**Yes.** The Service selects by labels shared by both old and new Pods. While both ReplicaSets have ready Pods, Endpoints include both versions and traffic can hit either. Observed in this lab with in-cluster Service probes during rollout.

### 9. How does rollback work?

`kubectl rollout undo` moves the Deployment back to a previous revision. Kubernetes scales up the ReplicaSet for that older template and scales down the current one—reusing the prior Pod template already recorded in revision history.

### 10. What Deployment strategy/configuration would you recommend for production and why?

**RollingUpdate** with **`maxUnavailable: 0`**, modest **`maxSurge` (25% or 1)**, readiness probes, and enough cluster headroom for surge Pods. Prefer availability and controlled blast radius over the fastest possible rollout. For incompatible API changes, consider blue/green or canary instead of relying on mixed-version traffic.

---

## Bonus (brief)

At 4 replicas, increasing surge/unavailable (config 3: 50%/50%) completed the image flip in fewer controller steps and allowed ready count to drop to 2, while config 1 (`1`/`0`) took longer but kept ready ≥ 4. Larger replica counts amplify the absolute number of Pods touched per step when using percentages.
