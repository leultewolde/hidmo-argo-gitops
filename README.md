# ArgoCD GitOps Repo

This repository manages ArgoCD projects and apps declaratively via GitOps.

## Structure

- `projects/` – ArgoCD `AppProject` definitions
- `apps/` – ArgoCD `Application` definitions
- `manifests/` – Raw Kubernetes resources for workloads

## Bootstrap

Create a bootstrap ArgoCD `Application` pointing to the `apps/` directory.
